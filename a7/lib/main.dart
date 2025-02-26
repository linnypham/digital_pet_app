import 'package:flutter/material.dart';
import 'package:day_night_switch/day_night_switch.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light, 
      home: FadingTextAnimation(),
    );
  }
}

class FadingTextAnimation extends StatefulWidget {
  const FadingTextAnimation({super.key});

  @override
  _FadingTextAnimationState createState() => _FadingTextAnimationState();
}

class _FadingTextAnimationState extends State<FadingTextAnimation> {
  bool _isVisible = true;
  bool _showFrame = false;
  bool val = false;
  Color sunColor = Colors.yellow;
  Color moonColor = Colors.grey;
  Color dayColor = Colors.blue;
  Color nightColor = Colors.black;
  Color backgroundColor = Colors.white;
  Color textColor = Colors.black;

  void toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void toggleDayNight(bool value) {
    setState(() {
      if (value) {
        backgroundColor = Colors.black;
      } else {
        backgroundColor = Colors.blue;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text('Fading Text Animation', style: TextStyle(color: Colors.black)),
      ),
      body: PageView(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: toggleVisibility,
                  child: AnimatedOpacity(
                    opacity: _isVisible ? 1.0 : 0.0,
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    child: const Text(
                      'Hello, Flutter!',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DayNightSwitch(
                  value: val,
                  onChanged: (value) {
                    setState(() {
                      toggleDayNight(value);
                      val = value;               
                    });
                  },
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SwitchListTile(
                  title: const Text('Show Frame'),
                  value: _showFrame,
                  onChanged: (bool value) {
                    setState(() {
                      _showFrame = value;
                    });
                  },
                ),
                Container(
                  decoration: _showFrame
                      ? BoxDecoration(
                          border: Border.all(color: Colors.black, width: 4),
                        )
                      : null,
                  child: Image.asset('assets/panda.png', width: 100, height: 100),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleVisibility,
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
