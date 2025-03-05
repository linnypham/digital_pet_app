import 'package:flutter/material.dart';
import 'helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FoldersScreen(),
    );
  }
}

class FoldersScreen extends StatelessWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Folders'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getFolders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var folder = snapshot.data![index];
              return ListTile(
                title: Text(folder['name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardsScreen(folderId: folder['id']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class CardsScreen extends StatelessWidget {
  final int folderId;
  const CardsScreen({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cards'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getCardsByFolder(folderId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var card = snapshot.data![index];
              return Card(
                child: Column(
                  children: [
                    Image.network(card['imageUrl']),
                    Text(card['name']),
                    IconButton(
                      onPressed: () async {
                        await DatabaseHelper.instance.deleteCard(card['id']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Card deleted')
                          ),
                        );
                      },
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCardScreen(folderId: folderId),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddCardScreen extends StatefulWidget {
  final int folderId;
  const AddCardScreen({super.key, required this.folderId});

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _suitController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Card Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a card name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _suitController,
                decoration: InputDecoration(labelText: 'Card Suit'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a card suit';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addCard,
                child: Text('Add Card'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addCard() async {
    if (_formKey.currentState!.validate()) {
      // Check if the folder has fewer than 6 cards
      final cardCount = await DatabaseHelper.instance.getCardCountInFolder(widget.folderId);
      if (cardCount >= 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This folder can only hold 6 cards')),
        );
        return;
      }

      // Insert the card into the database
      await DatabaseHelper.instance.insertCard({
        'name': _nameController.text,
        'suit': _suitController.text,
        'imageUrl': _imageUrlController.text,
        'folderId': widget.folderId,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card added successfully')),
      );

      // Navigate back to the CardsScreen
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _suitController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
