import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

void main() {
  runApp(const CardMatchingGame());
}

class CardMatchingGame extends StatelessWidget {
  const CardMatchingGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: GameScreen(),
      ),
    );
  }
}

class GameProvider extends ChangeNotifier {
  List<CardModel> cards = [];
  CardModel? firstSelected;
  CardModel? secondSelected;
  bool isProcessing = false;

  GameProvider() {
    _initializeGame();
  }

  void _initializeGame() {
    List<int> values = List.generate(8, (index) => index) + List.generate(8, (index) => index);
    values.shuffle(Random());
    cards = values.map((value) => CardModel(value: value)).toList();
    notifyListeners();
  }

  void flipCard(CardModel card) {
    if (isProcessing || card.isMatched || card.isFaceUp) return;

    card.isFaceUp = true;

    if (firstSelected == null) {
      firstSelected = card;
    } else if (secondSelected == null) {
      secondSelected = card;
      isProcessing = true;
      Future.delayed(Duration(seconds: 1), _checkMatch);
    }

    notifyListeners();
  }

  void _checkMatch() {
    if (firstSelected!.value == secondSelected!.value) {
      firstSelected!.isMatched = true;
      secondSelected!.isMatched = true;
    } else {
      firstSelected!.isFaceUp = false;
      secondSelected!.isFaceUp = false;
    }
    firstSelected = null;
    secondSelected = null;
    isProcessing = false;
    notifyListeners();
  }
}

class CardModel {
  final int value;
  bool isFaceUp = false;
  bool isMatched = false;

  CardModel({required this.value});
}

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Card Matching Game")),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          return GridView.builder(
            padding: EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: game.cards.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => game.flipCard(game.cards[index]),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: game.cards[index].isFaceUp || game.cards[index].isMatched ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: game.cards[index].isFaceUp || game.cards[index].isMatched
                        ? Text(
                      "${game.cards[index].value}",
                      style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    )
                        : Container(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
