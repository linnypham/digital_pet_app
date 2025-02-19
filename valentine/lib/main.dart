import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valentine',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Valentine'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController motionController;
  late Animation<double> motionAnimation;
  late ConfettiController _leftConfettiController;
  late ConfettiController _rightConfettiController;
  late Timer _timer;
  bool _shootLeft = true; 

  @override
  void initState() {
    super.initState();

    
    motionController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
      lowerBound: 0.5,
    );

    motionAnimation = CurvedAnimation(
      parent: motionController,
      curve: Curves.ease,
    );

    motionController.forward();
    motionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        motionController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        motionController.forward();
      }
    });

    
    _leftConfettiController = ConfettiController(duration: const Duration(seconds: 1));
    _rightConfettiController = ConfettiController(duration: const Duration(seconds: 1));

    
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_shootLeft) {
        _leftConfettiController.play();
      } else {
        _rightConfettiController.play();
      }
      _shootLeft = !_shootLeft; 
    });
  }

  @override
  void dispose() {
    motionController.dispose();
    _leftConfettiController.dispose();
    _rightConfettiController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 200, left: 8, right: 8),
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your message...',
                  ),
                ),
                Center(
                  child: SizedBox(
                    height: 200,
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: AnimatedBuilder(
                            animation: motionController,
                            builder: (context, child) {
                              return SizedBox(
                                height: motionController.value * 250,
                                child: child,
                              );
                            },
                            child: Image.asset('assets/images/heart.png'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Left
          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _leftConfettiController,
              blastDirection:
                  -3.14 / 4, 
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 100,
              minBlastForce: 80,
              gravity: 0.3,
            ),
          ),

          // Right
          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _rightConfettiController,
              blastDirection:
                  -3 * (3.14 / 4), 
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 100,
              minBlastForce: 80,
              gravity: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
