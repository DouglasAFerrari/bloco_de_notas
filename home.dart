import 'dart:async';
import 'dart:ui';
import 'package:notas/secondary_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:notas/helper/anotacao_helper.dart';
import 'package:notas/model/anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:share_plus/share_plus.dart';

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {

  // Lista de prioridades possíveis para a anotação
  var items = [
    'baixa',
    'normal',
    'elevada',
    'urgente',
  ];

  // Lista de filtros de prioridade para a pesquisa
  var items2 = [
    'todas',
    'baixa',
    'normal',
    'elevada',
    'urgente',
  ];

  // Variáveis de controle de visibilidade e valores selecionados
  bool naoExibido = true;
  String _selectPrior = 'normal'; // Prioridade selecionada
  String tipo = ''; // Filtro de tipo de anotação
  bool vistaNormal = true; // Define a visualização normal
  String _SelectSearch = 'todas'; // Filtro para pesquisa de anotações

  // Função de callback para alterar a prioridade
  void dropdownCallback(String selectedValue) {
    if (selectedValue is String) {
      setState(() {
        _selectPrior = selectedValue; // Altera a prioridade selecionada
      });
    }
  }

  // Controladores para os campos de texto de título e descrição
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();

  // Instanciação do banco de dados
  var _db = AnotacaoHelper();

  // Lista de anotações recuperadas do banco de dados
  List<Anotacao> _anotacoes = [];

  // Função para exibir a tela de cadastro ou atualização de anotação
  _exibirTelaCadastro({required Anotacao? anotacao}) {
    String textoSalvarAtualizar = "";

    // Caso a anotação seja nula, trata-se de uma nova anotação
    if (anotacao == null) {
      _tituloController.text = "";
      _descricaoController.text = "";
      setState(() {
        _selectPrior = 'normal'; // Prioridade padrão
      });
      textoSalvarAtualizar = "Salvar"; // Define a ação como "Salvar"
    } else { // Caso contrário, estamos editando uma anotação existente
      _tituloController.text = anotacao.titulo!;
      _descricaoController.text = anotacao.descricao!;
      setState(() {
        _selectPrior = anotacao.prioridade!; // Prioridade da anotação existente
      });
      textoSalvarAtualizar = "Atualizar"; // Define a ação como "Atualizar"
    }

    // Exibe o diálogo de cadastro/atualização
    showDialog(
        useRootNavigator: true,
        useSafeArea: true,
        context: context,
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              iconTheme: IconThemeData(
                  color: Colors.black // Cor do ícone de navegação
              ),
              title: Text("$textoSalvarAtualizar anotação",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              padding: EdgeInsets.all(4),
              margin: EdgeInsets.all(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: 10),

                  // Campo para digitar o título da anotação
                  TextField(
                    controller: _tituloController,
                    maxLines: 1,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: "Título",
                      hintText: "Digite o título...",
                      border: OutlineInputBorder(),
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Campo para digitar a descrição da anotação
                  Expanded(
                    child: TextField(
                      controller: _descricaoController,
                      maxLines: 40,
                      decoration: InputDecoration(
                        labelText: "Descrição",
                        hintText: "Digite a descrição...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Seção para escolher a prioridade da anotação
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[100],
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.black),
                    ),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text('Prioridade:'),
                          // Exibe o ícone de prioridade de acordo com a seleção
                          if(_selectPrior == 'baixa')...[
                            Icon(Icons.bookmark, color: Colors.white),
                          ],
                          if(_selectPrior == 'normal')...[
                            Icon(Icons.bookmark, color: Colors.blue),
                          ],
                          if(_selectPrior == 'elevada')...[
                            Icon(Icons.bookmark, color: Colors.yellow),
                          ],
                          if(_selectPrior == 'urgente')...[
                            Icon(Icons.bookmark, color: Colors.red),
                          ],
                          Text('$_selectPrior.'),
                          // Texto com a prioridade selecionada
                        ],
                      ),
                      trailing: PopupMenuButton(
                        icon: Icon(Icons.menu, color: Colors.black),
                        onSelected: (String selectedValue) {
                          setState(() {
                            _selectPrior = selectedValue; // Altera a prioridade
                          });
                        },
                        itemBuilder: (BuildContext context) =>
                            items.map((String item) {
                              return PopupMenuItem(
                                value: item,
                                child: Text(
                                    item), // Exibe a lista de prioridades
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Botões para salvar/atualizar ou cancelar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancelar',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Salva ou atualiza a anotação no banco de dados
                          _salvarAtualizarAnotacao(
                              anotacaoSelecionada: anotacao);
                          recuperarAnotacoes();
                          Navigator.pop(context);
                          if (naoExibido) {
                            setState(() {
                              naoExibido = false;
                            });
                            Timer.periodic(const Duration(minutes: 1), (timer) {
                              setState(() {
                                naoExibido = true;
                              });
                              timer.cancel();
                            });
                          }
                          setState(() {
                            _selectPrior =
                            'normal'; // Reseta a prioridade para 'normal'
                          });
                        },
                        child: Text(textoSalvarAtualizar,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  // Função para recuperar as anotações do banco de dados
  recuperarAnotacoes() async {
    // Recupera todas as anotações armazenadas no banco
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();

    // Lista temporária para armazenar as anotações mapeadas
    List<Anotacao>? listaTemporaria = [];

    // Itera sobre as anotações recuperadas
    for (var item in anotacoesRecuperadas) {
      // Mapeia cada item recuperado para o objeto Anotacao
      Anotacao anotacao = Anotacao.fromMap(item);

      // Adiciona a anotação mapeada na lista temporária
      listaTemporaria.add(anotacao);
    }

    // Atualiza o estado da aplicação com as anotações recuperadas
    setState(() {
      _anotacoes = listaTemporaria!; // Atualiza a lista de anotações no estado
      _SelectSearch = 'todas'; // Define o filtro de pesquisa como 'todas'
      vistaNormal = true; // Define a visualização como normal
    });

    // Limpa a lista temporária
    listaTemporaria = null;
  }

// Função para salvar ou atualizar uma anotação no banco de dados
  _salvarAtualizarAnotacao({required Anotacao? anotacaoSelecionada}) async {
    // Obtém os valores dos campos de entrada
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;
    String prioridade = _selectPrior;

    // Verifica se a anotação selecionada é nula (significa que é uma nova anotação)
    if (anotacaoSelecionada == null) {
      // Cria uma nova anotação e salva no banco de dados
      Anotacao anotacao = Anotacao(
          titulo, descricao, prioridade, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);
    } else {
      // Atualiza a anotação existente com os novos dados
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.prioridade = prioridade;
      anotacaoSelecionada.data = DateTime.now().toString();
      int resultado = await _db.atualizarAnotacao(anotacaoSelecionada);
    }

    // Limpa os campos de entrada
    _tituloController.clear();
    _descricaoController.clear();

    // Recupera novamente as anotações após a alteração
    recuperarAnotacoes();
  }

// Função para formatar a data no formato pt_BR
  formatarData(String data) {
    // Inicializa o formato de data para o idioma pt_BR
    initializeDateFormatting("pt_BR");

    // Define o formato de data desejado
    var formatador = DateFormat.yMd("pt_BR");

    // Converte a data string para DateTime
    DateTime dataConvertida = DateTime.parse(data);

    // Formata a data no formato desejado
    String dataFormatada = formatador.format(dataConvertida);
    return dataFormatada;
  }

// Função para remover uma anotação do banco de dados
  _removerAnotacao(int id) async {
    // Remove a anotação do banco com o id especificado
    await _db.removerAnotacao(id);

    // Recupera novamente as anotações após a remoção
    recuperarAnotacoes();
  }

// Método chamado quando a tela é inicializada
  @override
  void initState() {
    super.initState();

    // Recupera as anotações assim que a tela é carregada
    recuperarAnotacoes();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Configuração da AppBar (barra superior)
      appBar: AppBar(
        centerTitle: true, // Centraliza o título na AppBar
        iconTheme: IconThemeData(
          color: Colors.black, // Cor dos ícones da AppBar
        ),
        actions: [
          // Dropdown para selecionar filtro de pesquisa
          DropdownButton<String>(
            value: _SelectSearch, // Valor atual do filtro
            onChanged: (String? selectedValue) {
              setState(() {
                vistaNormal = false; // Desativa a vista normal enquanto filtra
                _SelectSearch = selectedValue!; // Atualiza o filtro
                _selectPrior =
                    selectedValue; // Atualiza a prioridade selecionada
                tipo =
                    _selectPrior; // Define o tipo de prioridade a ser exibido

                // Se o filtro for 'todas', habilita a vista normal
                if (selectedValue == 'todas') {
                  setState(() {
                    vistaNormal = true;
                  });
                }
              });
            },
            items: items2.map((String items) {
              return DropdownMenuItem(
                value: items,
                child: Text(items),
              );
            }).toList(),
          ),
        ],
        title: Text(
          "BLOCO DE NOTAS",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // Corpo da página
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Lista de anotações
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(2),
                children: [
                  for (final anotacao in _anotacoes)
                  // Verifica se a anotação corresponde ao filtro de prioridade ou se a vista normal está ativada
                    if (anotacao.prioridade == tipo || vistaNormal == true) ...[
                      // Card que exibe a anotação
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                        color: Colors.lightBlue[100],
                        // Cor de fundo do card
                        elevation: 2,
                        borderOnForeground: true,
                        child: ListTile(
                          title: Row(
                            children: [
                              // Ícones de acordo com a prioridade da anotação
                              if (anotacao.prioridade == 'baixa') ...[
                                Icon(
                                  Icons.bookmark,
                                  color: Colors.white,
                                ),
                              ],
                              if (anotacao.prioridade == 'normal') ...[
                                Icon(
                                  Icons.bookmark,
                                  color: Colors.blue,
                                ),
                              ],
                              if (anotacao.prioridade == 'elevada') ...[
                                Icon(
                                  Icons.bookmark,
                                  color: Colors.yellow,
                                ),
                              ],
                              if (anotacao.prioridade == 'urgente') ...[
                                Icon(
                                  Icons.bookmark,
                                  color: Colors.red,
                                ),
                              ],
                              // Exibe o título da anotação
                              Text(
                                ' ${anotacao.titulo}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Exibe a prioridade e a data de salvamento
                              Text('prioridade: ${anotacao.prioridade}.'),
                              Text("salvo em: ${formatarData(
                                  anotacao.data!)} \n "),
                              // Exibe a descrição da anotação
                              Container(
                                margin: EdgeInsets.all(5),
                                child: Text(
                                  "${anotacao.descricao}",
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              // Ícone para visualizar a anotação
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          secondary_screen(anotacao.titulo!,
                                              anotacao.descricao!,
                                              anotacao.prioridade!,
                                              anotacao.data!),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              // Ícone para compartilhar a anotação
                              GestureDetector(
                                onTap: () {
                                  Share.share(
                                      'título: ${anotacao
                                          .titulo}\nprioridade: ${anotacao
                                          .prioridade}\nsalvo em: ${formatarData(
                                          anotacao
                                              .data!)}\ndescrição: ${anotacao
                                          .descricao}');
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: Icon(
                                    Icons.share,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                              // Ícone para editar a anotação
                              GestureDetector(
                                onTap: () {
                                  _exibirTelaCadastro(anotacao: anotacao);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 16),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              // Ícone para remover a anotação
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              'Gostaria de remover a anotação?'),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text("Cancelar",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                _removerAnotacao(anotacao.id!);
                                                Navigator.pop(context);
                                              },
                                              child: Text('Confirmar',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            )
                                          ],
                                        );
                                      }
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 0),
                                  child: Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
      // Drawer (menu lateral)
      drawer: Drawer(
        elevation: 10,
        child: ListView(
          children: [
            // Cabeçalho do menu lateral
            UserAccountsDrawerHeader(
              accountName: Text('Aplicativo Bloco de notas.',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text('Sua ferramenta para salvar anotações.',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              currentAccountPicture: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                        Radius.circular(5)
                    ),
                    border: Border.all(width: 2, color: Colors.black)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Image.asset(
                    "imagens/icone.png",
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            // Itens do menu lateral
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: ListTile(
                leading: Icon(Icons.note),
                title: RichText(
                  text: TextSpan(
                    text: "Minhas anotações",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _exibirTelaCadastro(anotacao: null);
              },
              child: ListTile(
                leading: Icon(Icons.note_add),
                title: RichText(
                  text: TextSpan(
                    text: "Nova anotação",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Share.share(
                    'Bloco de Notas disponível na Play Store: https://play.google.com/store/apps/details?id=master.application.developer.notas');
              },
              child: ListTile(
                leading: Icon(Icons.share),
                title: RichText(
                  text: TextSpan(
                    text: "Compartilhar",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                var url = "https://play.google.com/store/apps/details?id=master.application.developer.notas";
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw "site fora do ar";
                }
              },
              child: ListTile(
                leading: Icon(Icons.star_rate),
                title: RichText(
                  text: TextSpan(
                    text: "Avalie-nos",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Botão flutuante para criar nova anotação
      floatingActionButton: FloatingActionButton(
          foregroundColor: Colors.black,
          child: Icon(Icons.note_add,
            size: 40,
          ),
          onPressed: () {
            _exibirTelaCadastro(anotacao: null);
          }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}


