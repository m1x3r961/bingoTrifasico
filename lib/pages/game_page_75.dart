import 'package:flutter/material.dart';
import 'package:bingo_tradicional/models/players.dart';
import 'dart:async';

class CreditManager {
  int _credits = 0;

  int get credits => _credits;

  void addCredits(int amount) {
    _credits += amount;
  }

  void deductCredits(int amount) {
    if (_credits >= amount) {
      _credits -= amount;
    } else {
      // Handle case where there aren't enough credits
    }
  }
}

class GamePage75 extends StatefulWidget {
  @override
  _GamePage75State createState() => _GamePage75State();
}

class _GamePage75State extends State<GamePage75> {
  List<int> bolas = List.generate(75, (index) => index + 1);
  List<int> bolasAleatorias = [];
  List<int> bolasGuardadas = [];
  BingoPlayer? player;
  int currentBall = 0;
  List<bool> markedNumbers = List.filled(25, false);
  final CreditManager creditManager = CreditManager();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    bolasAleatorias = List.from(bolas);
    bolasAleatorias.shuffle();
    generatePlayer();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void generatePlayer() {
    setState(() {
      List<int> cartonAleatorio = List.from(bolas);
      cartonAleatorio.shuffle();
      List<int> carton = cartonAleatorio.sublist(0, 24);
      carton.insert(12, 0); // Adding a free space in the middle
      player = BingoPlayer(name: 'Jugador 1', card: carton);
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      siguienteBola();
    });
  }

  void siguienteBola() {
    if (bolasAleatorias.isNotEmpty) {
      setState(() {
        currentBall = bolasAleatorias.removeAt(0);
        bolasGuardadas.add(currentBall);
        marcarNumeroEnCarton(currentBall);
        if (verificarLineaCompleta()) {
          mostrarAlertaBingo();
          creditManager.addCredits(10); // Añadir créditos por cada bingo
        }
      });
    } else {
      print('No hay más bolas disponibles'); // Registro de depuración
      timer?.cancel();
    }
  }

  void marcarNumeroEnCarton(int numero) {
    setState(() {
      for (int i = 0; i < player!.card.length; i++) {
        if (player!.card[i] == numero) {
          markedNumbers[i] = true;
        }
      }
    });
  }

  bool verificarLineaCompleta() {
    // Verificar cada fila
    for (int i = 0; i < 25; i += 5) {
      bool lineaCompleta = true;
      for (int j = 0; j < 5; j++) {
        if (!markedNumbers[i + j] && player!.card[i + j] != 0) {
          lineaCompleta = false;
          break;
        }
      }
      if (lineaCompleta) {
        return true;
      }
    }
    return false;
  }

  void mostrarAlertaBingo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('¡BINGO!'),
            content: Text('¡Felicidades! Has completado una línea. Has ganado 10 créditos.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bingo 75 Bolas'),
        backgroundColor: Colors.green[900], // Dark green color for the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bola Actual:   ',
                  style: TextStyle(fontSize: 24, color: Colors.blue[900]),
                ),
                SizedBox(width: 20),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green[900],
                  child: Text(
                    '$currentBall',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cartón ${player?.name}',
                  style: TextStyle(fontSize: 20, color: Colors.blue[900]),
                ),
                Text(
                  'Créditos: ${creditManager.credits}',
                  style: TextStyle(fontSize: 20, color: Colors.green),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (player != null)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double gridSize = constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth
                        : constraints.maxHeight;

                    double cellSize = gridSize / 5;

                    return Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(5, (index) {
                              return Text(
                                'BINGO'[index],
                                style: TextStyle(
                                  fontSize: cellSize / 3,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              );
                            }),
                          ),
                          SizedBox(width: 4),
                          Container(
                            width: gridSize,
                            height: gridSize,
                            child: GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: 25,
                              itemBuilder: (context, i) {
                                int num = player!.card[i];
                                bool isMarked = markedNumbers[i];
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(8),
                                    color: num == currentBall
                                        ? Colors.red
                                        : (num == 0
                                            ? Colors.green[100]
                                            : isMarked
                                                ? Colors.green
                                                : Colors.white),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        num == 0 ? 'FREE' : (num < 10 ? '0$num' : '$num'),
                                        style: TextStyle(
                                          fontSize: cellSize / 3, // Adjust font size dynamically
                                          fontWeight: FontWeight.bold,
                                          color: num == currentBall || isMarked
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 20),
            Text(
              'Bolas Anteriores:',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            SizedBox(height: 10),
            Container(
              height: 100, // Ajusta el tamaño según sea necesario
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: bolasGuardadas.map((bola) {
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green[900],
                    child: Text(
                      '$bola',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
