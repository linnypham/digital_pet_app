import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper();
  await dbHelper.init();
  runApp(CardOrganizerApp(dbHelper: dbHelper));
}

class CardOrganizerApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  const CardOrganizerApp({Key? key, required this.dbHelper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(dbHelper: dbHelper),
    );
  }
}

class HomePage extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const HomePage({Key? key, required this.dbHelper}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final loadedFolders = await widget.dbHelper.queryAllFolders();
    setState(() {
      folders = loadedFolders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Organizer'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
        ),
        itemCount: folders.length,
        itemBuilder: (context, index) {
          final folder = folders[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FolderPage(
                    dbHelper: widget.dbHelper,
                    folderId: folder['_id'],
                    folderName: folder['folder_name'],
                  ),
                ),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder, size: 64, color: Colors.blue),
                  SizedBox(height: 8),
                  Text(folder['folder_name'], style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FolderPage extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final int folderId;
  final String folderName;

  const FolderPage({
    Key? key,
    required this.dbHelper,
    required this.folderId,
    required this.folderName,
  }) : super(key: key);

  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  List<Map<String, dynamic>> cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final loadedCards = await widget.dbHelper.queryCardsInFolder(widget.folderId);
    setState(() {
      cards = loadedCards;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: card['image_url'],
                  height: 100,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                SizedBox(height: 8),
                Text(card['card_name']),
              ],
            ),
          );
        },
      ),
    );
  }
}
