// main.dart

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'helper.dart' as helper;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await helper.DatabaseHelper.instance.database;
  runApp(CardOrganizerApp());
}

class CardOrganizerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FoldersScreen(),
    );
  }
}

class FoldersScreen extends StatefulWidget {
  @override
  _FoldersScreenState createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  List<helper.Folder> folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  _loadFolders() async {
    List<helper.Folder> loadedFolders = await helper.DatabaseHelper.instance.getFolders();
    setState(() {
      folders = loadedFolders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Card Organizer')),
      body: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: folders.length,
        itemBuilder: (context, index) {
          return FolderCard(folder: folders[index]);
        },
      ),
    );
  }
}

class FolderCard extends StatelessWidget {
  final helper.Folder folder;

  FolderCard({required this.folder});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardsScreen(folderId: folder.id),
          ),
        );
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://example.com/${folder.name.toLowerCase()}.png',
              height: 80,
              width: 80,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.folder, size: 80),
            ),
            SizedBox(height: 10),
            Text(folder.name),
            Text('${folder.cardCount} cards'),
          ],
        ),
      ),
    );
  }
}

class CardsScreen extends StatefulWidget {
  final int folderId;

  CardsScreen({required this.folderId});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  List<helper.Card> cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  _loadCards() async {
    List<helper.Card> loadedCards = await helper.DatabaseHelper.instance.getCards(widget.folderId);
    setState(() {
      cards = loadedCards;
    });
  }

  Future<void> _addCard() async {
    if (cards.length >= 6) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('This folder can only hold 6 cards.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    // TODO: Implement card addition logic
  }

  Future<void> _deleteCard(helper.Card card) async {
    await helper.DatabaseHelper.instance.deleteCard(card.id);
    _loadCards();

    if (cards.length < 3) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Warning'),
          content: Text('You need at least 3 cards in this folder.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cards')),
      body: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return CardItem(
            card: cards[index],
            onDelete: () => _deleteCard(cards[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        child: Icon(Icons.add),
      ),
    );
  }
}

class CardItem extends StatelessWidget {
  final helper.Card card;
  final VoidCallback onDelete;

  CardItem({required this.card, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                card.imageUrl,
                height: 60,
                width: 60,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.credit_card, size: 60),
              ),
              SizedBox(height: 5),
              Text(card.name),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
