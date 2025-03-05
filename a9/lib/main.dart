import 'package:flutter/material.dart';
import 'helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FolderScreen(),
    );
  }
}

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  late DatabaseHelper _databaseHelper;
  List<Folder> _folders = [];

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadFolders();
  }

  _loadFolders() async {
    _folders = await _databaseHelper.getFolders();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Organizer'),
      ),
      body: ListView.builder(
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          final folder = _folders[index];
          return Card(
            child: ListTile(
              leading: Icon(Icons.folder),
              title: Text(folder.name),
              subtitle: Text('Number of cards: (To be implemented)'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardScreen(folder: folder),
                  ),
                ).then((value) => _loadFolders()); // Refresh on return
              },
            ),
          );
        },
      ),
    );
  }
}

class CardScreen extends StatefulWidget {
  final Folder folder;

  const CardScreen({super.key, required this.folder});

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  late DatabaseHelper _databaseHelper;
  List<CardModel> _cards = [];

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _loadCards();
  }

  _loadCards() async {
    _cards = await _databaseHelper.getCardsByFolderId(widget.folder.id!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //TODO: Replace with Image.network(card.imageUrl)
                //For demo purposes, using a SizedBox
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Placeholder(),
                ),
                Text(card.name),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteCard(card);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addCard(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _addCard(BuildContext context) async {
    // Show a dialog or navigate to a screen to select a card to add
    // For simplicity, let's add a dummy card
    String newCardName = 'New Card'; // Replace with user input
    String newCardImageUrl =
        'https://example.com/image.png'; // Replace with user input

    final newCard = CardModel(
      name: newCardName,
      suit: widget.folder.name,
      imageUrl: newCardImageUrl,
      folderId: widget.folder.id!,
    );

    await _databaseHelper.insertCard(newCard);
    _loadCards();
  }

  Future<void> _deleteCard(CardModel card) async {
    await _databaseHelper.deleteCard(card.id!);
    _loadCards();
  }
}
