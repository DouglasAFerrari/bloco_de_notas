// Importando pacotes necessários
import 'package:notas/model/anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnotacaoHelper {
  // Nome da tabela no banco de dados
  static final String nomeTabela = "anotacao";

  // Instância singleton do helper
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();

  // Variável para armazenar o banco de dados
  late Database _db;

  // Fábrica para obter a instância do helper
  factory AnotacaoHelper(){
    return _anotacaoHelper;
  }

  // Construtor privado
  AnotacaoHelper._internal(){
  }

  // Getter para acessar o banco de dados, se já estiver inicializado, retorna o banco existente
  get db async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath);

    // Se o caminho do banco de dados for o esperado, apaga o banco antigo (opcional)
    if(path == "banco_minhas_anotacoes.db"){
      await deleteDatabase(path);
    }

    // Se o banco de dados já foi inicializado, retorna o banco existente
    if( _db != null ){
      return _db;
    } else {
      // Se não, inicializa o banco de dados
      _db = await inicializarDB();
      return _db;
    }
  }

  // Função chamada quando o banco de dados é criado pela primeira vez
  _onCreate(Database db, int version) async {
    // Comando SQL para criar a tabela de anotações
    String sql = "CREATE TABLE $nomeTabela ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "titulo VARCHAR, "
        "descricao TEXT, "
        "prioridade TEXT, "
        "data DATETIME)";
    await db.execute(sql); // Executa o comando SQL
  }

  // Função para inicializar o banco de dados
  inicializarDB() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, "minhas_anotacoes.db");

    // Abre ou cria o banco de dados com a versão 1 e a função de criação
    var db = await openDatabase(localBancoDados, version: 1, onCreate: _onCreate );
    return db;
  }

  // Função para salvar uma anotação no banco de dados
  Future<int> salvarAnotacao(Anotacao anotacao) async {
    var bancoDados = await db;
    // Insere a anotação na tabela e retorna o id da inserção
    int resultado = await bancoDados.insert(nomeTabela, anotacao.toMap());
    return resultado;
  }

  // Função para recuperar todas as anotações, ordenadas por data
  recuperarAnotacoes() async {
    var bancoDados = await db;
    String sql = "SELECT * FROM $nomeTabela ORDER BY data DESC"; // Consulta SQL
    // Executa a consulta e retorna uma lista de resultados
    List anotacoes = await bancoDados.rawQuery(sql);
    return anotacoes;
  }

  // Função para atualizar uma anotação no banco de dados
  Future<int> atualizarAnotacao(Anotacao anotacao) async {
    var bancoDados = await db;
    // Atualiza a anotação baseada no id
    return await bancoDados.update(
        nomeTabela,
        anotacao.toMap(),
        where: "id = ?",
        whereArgs: [anotacao.id]
    );
  }

  // Função para remover uma anotação do banco de dados
  Future<int> removerAnotacao(int id) async {
    var bancoDados = await db;
    // Remove a anotação com o id fornecido
    return await bancoDados.delete(
        nomeTabela,
        where: "id = ?",
        whereArgs: [id]
    );
  }
}
