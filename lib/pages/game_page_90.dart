import 'package:flutter/material.dart';
import 'package:bingo_tradicional/models/players.dart';
import 'dart:async';
import 'dart:math';

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

class GamePage90 extends StatefulWidget {
  @override
  _GamePage90State createState() => _GamePage90State();
}

class _GamePage90State extends State<GamePage90> {
  List<int> bolas = List.generate(90, (index) => index + 1);
  List<int> bolasAleatorias = [];
  List<int> bolasGuardadas = [];
  BingoPlayer? player;
  int currentBall = 0;
  Set<int> blockedIndexes = {};
  List<bool> markedNumbers = List.filled(27, false);
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
      List<int> carton = cartonAleatorio.sublist(0, 27);

      // Tapar 4 espacios en cada una de las 3 filas horizontales
      Random random = Random();
      blockedIndexes.clear();

      for (int row = 0; row < 3; row++) {
        Set<int> rowBlockedIndexes = {};
        while (rowBlockedIndexes.length < 4) {
          int index = random.nextInt(9) + row * 9;
          rowBlockedIndexes.add(index);
        }
        blockedIndexes.addAll(rowBlockedIndexes);
      }

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
    for (int i = 0; i < 27; i += 9) {
      bool lineaCompleta = true;
      for (int j = 0; j < 9; j++) {
        if (!markedNumbers[i + j] && !blockedIndexes.contains(i + j)) {
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
        title: Text(
          'Bingo 90 Bolas',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[900], // Dark blue color for the app bar
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
                  backgroundColor: Colors.blue[900],
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
                    double gridWidth = constraints.maxWidth * 0.9; // Ajustar el tamaño del grid
                    double cellSize = gridWidth / 9; // Ajustar el tamaño de las celdas

                    return Center(
                      child: Container(
                        width: gridWidth,
                        child: AspectRatio(
                          aspectRatio: 3 / 1,
                          child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 9,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: 27,
                            itemBuilder: (context, i) {
                              int num = player!.card[i];
                              bool isBlocked = blockedIndexes.contains(i);
                              bool isMarked = markedNumbers[i];
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isBlocked
                                      ? Colors.red
                                      : isMarked
                                          ? Colors.green
                                          : Colors.white,
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
                                      isBlocked ? '' : (num < 10 ? '0$num' : '$num'),
                                      style: TextStyle(
                                        fontSize: cellSize / 2.5, // Ajuste del tamaño de la fuente
                                        fontWeight: FontWeight.bold,
                                        color: isBlocked
                                            ? Colors.white
                                            : isMarked
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
                    backgroundColor: Colors.blue[900],
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
