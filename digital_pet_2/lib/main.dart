import 'package:flutter/material.dart';
import 'dart:async';

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
  int energyLevel = 100;
  String newPetName = "";
  Color petColor = Colors.yellow;
  Timer? _hungerTimer;
  Timer? _winTimer;
  bool isWinning = false;

  void _resetState(){
    happinessLevel = 50;
    hungerLevel = 50;
    energyLevel = 100;
  }
  void _startHungerTimer() {
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (_) {
      setState(() {
        hungerLevel = (hungerLevel + 5).clamp(0, 100);
        _updateHappiness();
        _checkWinCondition();
        _checkLossCondition();
      });
    });
  }

  void _checkWinCondition() {
    if (happinessLevel > 80 && !isWinning) {
      isWinning = true;
      _winTimer = Timer(Duration(minutes: 1), () {
        _showWinDialog();
      });
    } else if (happinessLevel <= 80 && isWinning) {
      isWinning = false;
      _winTimer?.cancel();
    }
    
  }

  void _checkLossCondition() {
    if (hungerLevel >= 100 && happinessLevel <= 10) {
      _showLossDialog();
      
    }
    
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('You Win'),
          content: Text('Your pet is evolved!!!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetState();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLossDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Your pet is too hungry and unhappy. You lost!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetState();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to increase happiness and update hunger when playing with the pet
  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      energyLevel = (energyLevel - 10).clamp(0, 100);
      _updateHunger();
      _updateColor();
    });
  }

  // Function to decrease hunger and update happiness when feeding the pet
  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      energyLevel = (energyLevel + 20).clamp(0, 100);
      _updateHappiness();
      _updateColor();
    });
  }

  // Update happiness based on hunger level
  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel + 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel - 10).clamp(0, 100);
    }
    _checkWinCondition();
    _checkLossCondition();
  }

  // Increase hunger level slightly when playing with the pet
  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
    _checkWinCondition();
    _checkLossCondition();
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

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
  }
  @override
  void dispose() {
    _hungerTimer?.cancel();
    super.dispose();
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
            
            Text(
              _getMood(),
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),

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
            SizedBox(height: 16.0),
            Text(
              'Energy Level: $energyLevel',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 8.0),
            LinearProgressIndicator(
              value: energyLevel / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 32.0),
            
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
            ElevatedButton(
              onPressed: () => _changeName(newPetName),
              child: Text('Enter.'),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
