import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MineSweeper extends FlameGame{
    MineSweeper({super.children});

    @override
    Color backgroundColor(){
        return Colors.green;
    }

    Widget build(BuildContext context){
        return Container(
            color: backgroundColor(),
            child: Center(
                child: Text('Hello World'),
            ),
        );
    }
}