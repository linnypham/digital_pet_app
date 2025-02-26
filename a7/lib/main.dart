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
        // Night Mode
        backgroundColor = Colors.black;
        
      } else {
        // Day Mode
        backgroundColor = Colors.blue;
        
      }
    });
  }

  void _showColorPicker() async {
    Color pickerColor = textColor;
    Color currentColor = textColor;

    final Color? selectedColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: Container(
              width: double.maxFinite,
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  pickerColor = color;
                },
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                setState(() {
                  currentColor = pickerColor;
                });
                Navigator.of(context).pop(currentColor);
              },
            ),
          ],
        );
      },
    );

    if (selectedColor != null) {
      setState(() {
        textColor = selectedColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text('Fading Text Animation', style: TextStyle(color: textColor)),
        iconTheme: IconThemeData(color: textColor),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.color_lens),
            onPressed: _showColorPicker,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _isVisible ? 1.0 : 0.0,
              duration: Duration(seconds: 1),
              child: Text(
                'Hello, Flutter!',
                style: TextStyle(fontSize: 24, color: textColor),
              ),
            ),
            const SizedBox(height: 20),
            DayNightSwitch(
              value: val,
              moonImage: AssetImage('assets/moon.png'),
              sunImage: AssetImage('assets/sun.png'),
              sunColor: sunColor,
              moonColor: moonColor,
              dayColor: dayColor,
              nightColor: nightColor,
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
      floatingActionButton: FloatingActionButton(
        onPressed: toggleVisibility,
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}

class ColorPicker extends StatefulWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({super.key, required this.pickerColor, required this.onColorChanged});

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.pickerColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: GridView.count(
            crossAxisCount: 4,
            children: List.generate(Colors.primaries.length, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentColor = Colors.primaries[index];
                  });
                  widget.onColorChanged(_currentColor);
                },
                child: Container(
                  color: Colors.primaries[index],
                  margin: EdgeInsets.all(8.0),
                ),
              );
            }),
          ),
        ),
        Container(
          width: 100,
          height: 50,
          color: _currentColor,
          margin: EdgeInsets.all(16.0),
        ),
      ],
    );
  }
}
