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
    if (isProcessing || card.isMatched) return;

    card.isFaceUp = !card.isFaceUp;
    notifyListeners();

    if (card.isFaceUp) {
      if (firstSelected == null) {
        firstSelected = card;
      } else if (secondSelected == null) {
        secondSelected = card;
        _checkMatch();
      }
    } else {
      if (firstSelected == card) {
        firstSelected = null;
      } else if (secondSelected == card) {
        secondSelected = null;
      }
    }
  }

  void _checkMatch() {
    if (firstSelected != null && secondSelected != null) {
      isProcessing = true;
      Future.delayed(Duration(seconds: 1), () {
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
      });
    }
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
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return RotationYTransition(turns: animation, child: child);
                  },
                  child: game.cards[index].isFaceUp
                      ? Container(
                    key: ValueKey(game.cards[index].value),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        "${game.cards[index].value}",
                        style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                      : Container(
                    key: ValueKey(-1),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
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

class RotationYTransition extends AnimatedWidget {
  final Widget child;
  RotationYTransition({required Animation<double> turns, required this.child}) : super(listenable: turns);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(animation.value * pi * 2),
      child: animation.value > 0.5 ? child : Container(),
    );
  }
}
