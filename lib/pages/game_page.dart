import 'package:bingo_tradicional/models/players.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<int> bolas = List.generate(99, (index) => index + 1);
  List<int> bolasAleatorias = [];
  List<Player> players = [];
  int currentBall = 0;

  @override
  void initState() {
    super.initState();
    bolasAleatorias = List.from(bolas);
    bolasAleatorias.shuffle();
    generatePlayers(2); // Generar jugadores con cartones para dos jugadores como ejemplo
  }

  void generatePlayers(int numPlayers) {
    for (int i = 0; i < numPlayers; i++) {
      List<int> cartonAleatorio = List.from(bolas);
      cartonAleatorio.shuffle();
      List<int> carton = cartonAleatorio.sublist(0, 25);
      players.add(Player(name: 'Jugador ${i + 1}', card: carton));
    }
  }

  void siguienteBola() {
    setState(() {
      if (bolasAleatorias.isNotEmpty) {
        currentBall = bolasAleatorias.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Juego de Bingo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Bola Actual: $currentBall',
              style: TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: siguienteBola,
              child: Text('Siguiente Bola'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cartón ${players[index].name}', style: TextStyle(fontSize: 20)),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 5,
                          children: List.generate(25, (i) {
                            int num = players[index].card[i];
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(8),
                                color: num == currentBall ? Colors.red : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  num < 10 ? '0$num' : '$num',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: num == currentBall ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
