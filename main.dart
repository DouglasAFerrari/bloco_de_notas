import 'package:flutter/material.dart';
import 'package:notas/home.dart';

// Função principal do aplicativo
void main() {
  // Garante que o binding do Flutter esteja inicializado antes de rodar o aplicativo
  WidgetsFlutterBinding.ensureInitialized();

  // Inicia o aplicativo com o widget MaterialApp
  runApp(MaterialApp(
    // Define o widget principal da tela inicial do app, que neste caso é o Home
    home: Home(),

    // Desativa o banner de debug no canto superior direito
    debugShowCheckedModeBanner: false,

    // Define o tema global do aplicativo
    theme: ThemeData(
      // Cor principal do aplicativo (usada em botões, barra de navegação, etc.)
      primaryColor: Colors.blue,

      // Cor de fundo do Scaffold (a estrutura básica da página)
      scaffoldBackgroundColor: Colors.white,

      // Personaliza o BottomAppBar (a barra inferior de navegação)
      bottomAppBarTheme: BottomAppBarTheme(color: Colors.black),
    ),
  ));
}
