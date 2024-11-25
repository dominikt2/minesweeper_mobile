import 'package:flutter/material.dart';
import 'dart:math';

var board = List.filled(100, 10);
var gamingboard = List.filled(100, 10);
int mines = 10;
int score = 10;
int boardSize = 10;
bool firstClick = true;
bool gameOver = false;
bool isFlagging = false;
bool playerWon = false;
int boardColor = 0xFF45494f;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  String _selectedOption = "Easy";
  final List<String> _options = ["Easy", "Medium", "Hard", "Custom"];

 @override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Minesweeper',
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20.0), 
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10.0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: AppBar(
          title: const Center(
            child: Text(
              'MINESWEEPER',
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: const Color(0xFF45494f), 
          elevation: 0,
        ),
      ),
    ),
      backgroundColor: Color(boardColor),
      body: Center(
        child: SingleChildScrollView( 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              //MENU WYBORU TRUDNOSCI
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: DropdownButton<String>(
                      value: _selectedOption,
                      items: _options.map((String option){
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (String? newValue){
                        setState((){
                          _selectedOption = newValue!;
                          resetGame();
                        });
                        asjustSettings();
                      }
                    ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 100.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isFlagging = !isFlagging;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(40, 40),
                          backgroundColor: isFlagging ? Color(0xFFFF555C) : Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero, 
                          ),
                          padding: EdgeInsets.zero, 
                        ),
                        child: Image.asset(
                          "assets/11.png",
                          width: MediaQuery.of(context).size.width * 0.075, 
                          height: MediaQuery.of(context).size.width * 0.075,
                        ),
                      ),
                    ),
                ],
              ),
              for (int i = 0; i < board.length; i += 10)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int j = i; j < i + 10; j++)
                      Padding(
                        padding: const EdgeInsets.all(0.5), // Minimal padding
                        child: GestureDetector(
                          onTap: () {
                            if (!gameOver){
                               handleCellClick(j);
                            }
                          },
                          child: Image.asset(
                            'assets/${board[j] == 10 ? "10" : board[j]}.png',
                            width: MediaQuery.of(context).size.width * 0.075, 
                            height: MediaQuery.of(context).size.width * 0.075,  
                                    ),
                                  ),
                                ),
                            ],
                          ),       
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text ("Mines: $score"),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      resetGame(); 
                    },
                    style: gameOver
                        ? ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              playerWon ? Color.fromARGB(255, 59, 226, 115) : Color.fromARGB(255, 231, 27, 34), 
                            ),
                          )
                        : null, 
                    child: const Icon(Icons.refresh),
                  ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}



  void handleCellClick(int index) {
    int row = index ~/ 10;
    int col = index % 10;
    if (firstClick) {
      fillMines(index);
      firstClick = false;
    }
    if(isFlagging && (board[index] == 10 || board[index] == 11)){
      setState(() {
      if(board[index] == 10){
        board[index] = 11;
        if(score > 0){
          score--;
        }
        checkScore();
      }else{
        score++;
        board[index] = 10;
      }
    });
    
    }else if(board[index] != 11){
      setState(() {
        if (gamingboard[index] == 0) {
          floodFill(row, col);
        } else if (gamingboard[index] == 9) {
          gameOver = true;
          revealBoard(index);
        }
        board[index] = gamingboard[index]; 
        if(board[index] == 9){
          board[index] = 12;
        }
      });
    }
  }

void fillMines(int index) {
  for (int i = 0; i < mines; i++) {
    int mineIndex;
    do {
      mineIndex = Random.secure().nextInt(boardSize*10);
    } while (mineIndex == index || gamingboard[mineIndex] == 9); 

    gamingboard[mineIndex] = 9;  
  }
  fillValues();  
}


  void fillValues() {
    for (int i = 0; i < gamingboard.length; i++) {
      if (gamingboard[i] == 9) {
        continue; 
      }
      int count = 0;
      int width = 10; 

      if (i >= width) {
        if (i % width != 0 && gamingboard[i - width - 1] == 9) count++;
        if (gamingboard[i - width] == 9) count++;
        if (i % width != width - 1 && gamingboard[i - width + 1] == 9) count++;
      }
      if (i % width != 0 && gamingboard[i - 1] == 9) count++;
      if (i % width != width - 1 && gamingboard[i + 1] == 9) count++;
      if (i < gamingboard.length - width) {
        if (i % width != 0 && gamingboard[i + width - 1] == 9) count++;
        if (gamingboard[i + width] == 9) count++;
        if (i % width != width - 1 && gamingboard[i + width + 1] == 9) count++;
      }

      gamingboard[i] = count; 
    }
  }

  void floodFill(int row, int col) {
    int width = 10;
    int height = boardSize;
    int index = row * width + col;

    if (row < 0 || col < 0 || row >= height || col >= width || board[index] != 10 || gamingboard[index] == 9) {
      return;
    }

    board[index] = gamingboard[index];

    if (gamingboard[index] == 0) {
      floodFill(row - 1, col - 1);  // Up-Left
      floodFill(row - 1, col);  // Up
      floodFill(row - 1, col + 1);  // Up-Right
      floodFill(row + 1, col - 1);  // Down-Left
      floodFill(row + 1, col);  // Down
      floodFill(row + 1, col + 1);  // Down-Right
      floodFill(row, col - 1);  // Left
      floodFill(row, col + 1);  // Right
    }
  }

  void asjustSettings(){
    if(_selectedOption == "Easy"){
      board = List.filled(100, 10);
      gamingboard = List.filled(100, 10);

      mines = 10;
      score = 10;
      boardSize = 10;

    }else if(_selectedOption == "Medium"){
      board = List.filled(150, 10);
      gamingboard = List.filled(150, 10);

      mines = 25;
      score = 25;
      boardSize = 15;

    }else if(_selectedOption == "Hard"){
      board = List.filled(250, 10);
      gamingboard = List.filled(250, 10);

      mines = 50;
      score =50;
      boardSize = 25;
    }
  }

  void resetGame(){
      boardColor = 0xFFFFFFFF;
      gameOver = false;
      firstClick = true;
      isFlagging = false;
      playerWon = false;
      score = mines;
      setState(() {
        for (int i = 0; i < board.length; i++) {
          board[i] = 10;
          gamingboard[i] = 10;
        }
      });
  }
  
  void revealBoard(int index) {
    boardColor = 0xFFFF555C;
    for (int i = 0; i < board.length; i++) {
      if (gamingboard[i] == 9) {
        board[i] = gamingboard[i];
      }
    }
  }

  void checkScore(){
    int howManyMines = 0;
    int howManyFlags = 0;
    for(int i = 0; i < board.length; i++){
      if(board[i] == 11){
        howManyFlags++;
        if(gamingboard[i] == 9){
          howManyMines++;
          print('Mines: $howManyMines');
        }
      }
      if(mines == howManyMines && howManyMines == howManyFlags){
        gameOver = true;
        playerWon = true;
        setState((){
          boardColor = 0xFF64e890;
        });
      }
    }
  }

}