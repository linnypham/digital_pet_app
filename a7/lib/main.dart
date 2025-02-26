import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      home: const AnimatedWidgetsDemo(),
    );
  }
}

class AnimatedWidgetsDemo extends StatefulWidget {
  const AnimatedWidgetsDemo({super.key});

  @override
  _AnimatedWidgetsDemoState createState() => _AnimatedWidgetsDemoState();
}

class _AnimatedWidgetsDemoState extends State<AnimatedWidgetsDemo>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true;
  bool _showFrame = false;
  bool _rotate = false;
  bool _fadeImage = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  void toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void toggleRotation() {
    setState(() {
      _rotate = !_rotate;
      if (_rotate) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  void toggleImageFade() {
    setState(() {
      _fadeImage = !_fadeImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Animations')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: toggleVisibility,
              child: AnimatedOpacity(
                opacity: _isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOutCubic,
                child: const Text(
                  'Hello, Animated Flutter!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotate ? _controller.value * 2 * pi : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: _showFrame
                          ? Border.all(color: Colors.blue, width: 5)
                          : null,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: AnimatedOpacity(
                        opacity: _fadeImage ? 0.3 : 1.0,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOut,
                        child: Image.asset('assets/panda.png', width: 100),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Show Frame'),
              value: _showFrame,
              onChanged: (bool value) {
                setState(() {
                  _showFrame = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: toggleVisibility,
              child: const Text('Toggle Text Visibility'),
            ),
            ElevatedButton(
              onPressed: toggleRotation,
              child: const Text('Toggle Rotation'),
            ),
            ElevatedButton(
              onPressed: toggleImageFade,
              child: const Text('Toggle Image Fade'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
