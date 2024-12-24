import 'dart:ui';
import 'package:flutter/material.dart';
import 'home.dart';

class secondary_screen extends StatefulWidget {

  // Variáveis que armazenam os dados da anotação
  String nome;
  String descricao;
  String prioridade;
  String data;

  // Construtor para inicializar a tela com os dados
  secondary_screen(this.nome, this.descricao, this.prioridade, this.data);

  @override
  State<secondary_screen> createState() => secondary_screenState();
}

class secondary_screenState extends State<secondary_screen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar personalizada
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.black // Cor dos ícones na AppBar
        ),
        title: Text("BLOCO DE NOTAS",
          style: TextStyle(
            color: Colors.black, // Cor do título
            fontWeight: FontWeight.bold, // Deixa o título em negrito
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Color(0xFFBBDEFB), // Cor de fundo
                  borderRadius: BorderRadius.all(
                      Radius.circular(5) // Bordas arredondadas
                  ),
                  border: Border.all(width: 1, color: Colors.black) // Borda preta
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exibe o ícone de prioridade de acordo com a prioridade da anotação
                  Row(
                    children: [
                      if(widget.prioridade == 'baixa')...[
                        Icon(
                          Icons.bookmark,
                          color: Colors.white, // Ícone branco para prioridade baixa
                        ),
                      ], if(widget.prioridade == 'normal')...[
                        Icon(
                          Icons.bookmark,
                          color: Colors.blue, // Ícone azul para prioridade normal
                        ),
                      ], if(widget.prioridade == 'elevada')...[
                        Icon(
                          Icons.bookmark,
                          color: Colors.yellow, // Ícone amarelo para prioridade elevada
                        ),
                      ], if(widget.prioridade == 'urgente')...[
                        Icon(
                          Icons.bookmark,
                          color: Colors.red, // Ícone vermelho para prioridade urgente
                        ),
                      ],
                      // Exibe o título da anotação
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          '${widget.nome}', // Nome da anotação
                          style: TextStyle(
                            height: 1.5,
                            fontSize: 16,
                            fontWeight: FontWeight.bold, // Título em negrito
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Exibe a prioridade e a data de criação da anotação
                  Text("prioridade: ${widget.prioridade}."),
                  Text(
                    'salvo em: ${HomeState().formatarData(widget.data)}.\n',
                  ),
                  SizedBox(
                    width: 5,
                    height: 5,
                  ),
                  // Exibe a descrição da anotação
                  Container(
                    margin: EdgeInsets.all(2),
                    child: Text(
                      widget.descricao,
                      style: TextStyle(
                        height: 1.5,
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // Descrição em negrito
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
