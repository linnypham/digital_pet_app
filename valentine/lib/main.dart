import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController motionController;
  late Animation<double> motionAnimation;

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
      } else if (status == AnimationStatus.dismissed) {
        motionController.forward();
      }
    });
  }

  @override
  void dispose() {
    motionController.dispose();
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
    );
  }
}
