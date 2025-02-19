import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  const DigitalPetApp({super.key});

  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  String newPetName = "";
  Color petColor = Colors.yellow;
  bool isWon = false;
  bool isGameOver = false;
  DateTime? happinessAbove80Time;


  // Function to increase happiness and update hunger when playing with the pet
  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
      _updateColor();
      _checkWin();
      _checkGameOver();
    });
  }

  // Function to decrease hunger and update happiness when feeding the pet
  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
      _updateColor();
      _checkWin();
      _checkGameOver();
    });
  }

  // Update happiness based on hunger level
  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

  // Increase hunger level slightly when playing with the pet
  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
  }

  void _changeName(String newPetName){
  setState(() {
    petName = newPetName;
  });
}

  void _updateColor() {
    if (happinessLevel > 70) {
      petColor = Colors.green;
    }
    else if (happinessLevel >= 30 && happinessLevel <= 70) {
      petColor = Colors.yellow;
    }
    else {
      petColor = Colors.red;
    }
  }

  String _getMood() {
    if (happinessLevel > 70) {
      return 'Happy 😊';
    }
    else if (happinessLevel >=30 && happinessLevel <= 70) {
      return 'Neutral 😐';
    }
    else {
      return 'Unhappy 😠';
    }
  }

  void _checkWin() {
    if (happinessLevel > 80) {
      if (happinessAbove80Time == null) {
        happinessAbove80Time = DateTime.now();
      }
      else {
        final duration = DateTime.now().difference(happinessAbove80Time!);
        if (duration.inSeconds >= 60) {
          setState(() {
            isWon = true;
          });
        }
      }
    }
    else {
      happinessAbove80Time = null;
    }
  }

  void _checkGameOver() {
    if(hungerLevel >= 100 && happinessLevel <= 10) {
      setState(() {
        isGameOver = true;
      });
    }
  }

  void _resetGame() {
    setState(() {
      happinessLevel = 50;
      hungerLevel = 50;
      isGameOver = false;
      isWon = false;
      happinessAbove80Time = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
            if (isGameOver)
              Text(
                'Game Over',
                style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.red),
              )
            else if (isWon)
              Text(
                'You Won',
                style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.green),
              ),

            Text(
              _getMood(),
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Container(
              color: petColor,
              padding: EdgeInsets.all(16.0),
              child: Image.asset('assets/images/pet.png'),
            ),
            
            Text(
              'Name: $petName',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Happiness Level: $happinessLevel',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Hunger Level: $hungerLevel',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _playWithPet,
              child: Text('Play with Your Pet'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _feedPet,
              child: Text('Feed Your Pet'),
            ),
            SizedBox(height: 16.0),
            TextField(
              onChanged: (text) {
                setState(() {
                  newPetName = text;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your pet name...',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _changeName(newPetName),
              child: Text('Enter'),
            ),
            if (isGameOver || isWon)
              ElevatedButton(
                onPressed: _resetGame,
                child: Text('Reset Game'),
              ),
          ],
        ),
      ),
    ),
    );
  }
}
