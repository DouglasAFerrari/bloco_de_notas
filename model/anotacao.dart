import 'package:notas/helper/anotacao_helper.dart';

class Anotacao {

  // Atributos da classe Anotacao
  int? id;
  String? titulo;
  String? descricao;
  String? prioridade;
  String? data;

  // Construtor para criar uma anotação
  Anotacao(this.titulo, this.descricao, this.prioridade, this.data);

  // Construtor nomeado para criar uma anotação a partir de um Map (normalmente usado para reconstruir de um banco de dados)
  Anotacao.fromMap(Map map) {
    this.id = map["id"];            // Atribui o valor do id do Map ao id da anotação
    this.titulo = map["titulo"];    // Atribui o título do Map ao título da anotação
    this.descricao = map["descricao"]; // Atribui a descrição do Map à descrição da anotação
    this.prioridade = map["prioridade"]; // Atribui a prioridade do Map à prioridade da anotação
    this.data = map["data"];        // Atribui a data do Map à data da anotação
  }

  // Método para converter a anotação em um Map, usado para salvar no banco de dados
  Map toMap() {
    Map<String, dynamic> map = {
      "titulo": this.titulo,         // Adiciona o título ao Map
      "descricao": this.descricao,   // Adiciona a descrição ao Map
      "prioridade": this.prioridade, // Adiciona a prioridade ao Map
      "data": this.data,             // Adiciona a data ao Map
    };

    // Se a anotação já possui um id (caso seja uma atualização), adiciona ao Map
    if (this.id != null) {
      map["id"] = this.id;
    }

    // Retorna o Map que pode ser usado para inserir no banco de dados
    return map;
  }

}
