import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

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

  //Confetti
  late ConfettiController _controllerTopLeft;
  late ConfettiController _controllerTopRight;

  @override
  void initState() {
    super.initState();

    motionController = AnimationController(
      duration: const Duration(seconds: 1), //duration of the animation
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
        _controllerTopLeft.stop();
        _controllerTopRight.stop();
      } else if (status == AnimationStatus.dismissed) {
        motionController.forward();
        _controllerTopLeft.play();
        _controllerTopRight.play();
      }
    });

    //Confetti
    _controllerTopLeft = ConfettiController(duration: const Duration(seconds: 10));
    _controllerTopRight = ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    motionController.dispose();
    _controllerTopLeft.dispose();
    _controllerTopRight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Padding(
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
                    //Confetti Left and Right
                    Align(
                      alignment: Alignment.topLeft,
                      child: ConfettiWidget(
                        confettiController: _controllerTopLeft,
                        blastDirection: -45,
                        emissionFrequency: 0.1,
                        numberOfParticles: 10,
                        gravity: 0.1,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: ConfettiWidget(
                        confettiController: _controllerTopRight,
                        blastDirection: 105,
                        emissionFrequency: 0.1,
                        numberOfParticles: 10,
                        gravity: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}