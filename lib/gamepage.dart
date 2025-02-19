import 'dart:developer' as dev;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  ConfettiController confettiController = ConfettiController();
  bool playerOnePlaying = true;
  bool playerTwoPlaying = false;
  int? winner;

  List<int?> selectedData = List.filled(9, null);

  markTiles({required int index}) {
    if (selectedData[index] == null) {
      if (playerOnePlaying) {
        selectedData[index] = 1;
        playerOnePlaying = false;
        dev.log(selectedData.toString());
        playerTwoPlaying = true;
      } else if (playerTwoPlaying) {
        selectedData[index] = 0;
        playerTwoPlaying = false;
        dev.log(selectedData.toString());
        playerOnePlaying = true;
      }
      setState(() {
        winner = checkWinner(selectedData);
        if (winner != null) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Player ${winner! + 1} is the winner")));
          confettiController.play();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Tile is already marked"),
        ),
      );
    }
  }

  int? checkWinner(List<int?> selectedTiles) {
    List<List<int>> winConditions = [
      [0, 1, 2], // Rows
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6], // Columns
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8], // Diagonals
      [2, 4, 6]
    ];

    for (var condition in winConditions) {
      int a = condition[0], b = condition[1], c = condition[2];
      if (selectedTiles[a] != null &&
          selectedTiles[a] == selectedTiles[b] &&
          selectedTiles[a] == selectedTiles[c]) {
        return selectedTiles[a]; // Returns 0 (Player 1) or 1 (Player 2)
      }
    }

    return null; // No winner
  }

  resetData() {
    playerOnePlaying = true;
    playerTwoPlaying = false;
    selectedData = List.filled(9, null);
    winner = null;
    confettiController.stop();
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).height * .8 > 360
              ? 360
              : MediaQuery.sizeOf(context).height * .8,
          // height: MediaQuery.sizeOf(context).height * .8,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.hardEdge,
            children: [
              Image.asset(
                'android-frame.png',

                // width: 412,
                // height: 915,
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).height * .55,
                child: Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Turn : Player ${playerOnePlaying ? "1" : "2"}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      winner == null
                          ? "Keep Playing"
                          : "Winner - Player ${winner! + 1}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Visibility(
                        visible: winner != null,
                        child: FilledButton.tonal(
                            onPressed: () {
                              setState(() {
                                resetData();
                              });
                            },
                            child: Text(
                              "Play Again",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ))),
                    GridView.builder(
                      padding: EdgeInsets.all(35),
                      shrinkWrap: true,
                      itemCount: selectedData.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 1,
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4),
                      itemBuilder: (context, index) => InkWell(
                        onTap: () {
                          markTiles(index: index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.green,
                          ),
                          child: selectedData[index] != null
                              ? selectedData[index] == 1
                                  ? Icon(
                                      Icons.cancel_rounded,
                                      // size: MediaQuery.sizeOf(context).width *
                                      //     0.065,
                                      color: Colors.black,
                                    )
                                  : Icon(
                                      Icons.circle_outlined,
                                      // size: MediaQuery.sizeOf(context).width *
                                      //     0.065,
                                      color: Colors.black,
                                    )
                              : SizedBox(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: ConfettiWidget(
                  emissionFrequency: 0.08,
                  confettiController: confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
