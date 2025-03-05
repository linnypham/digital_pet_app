import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Folder {
  int? id;
  String name;
  String timestamp;

  Folder({this.id, required this.name, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'timestamp': timestamp,
    };
  }

  static Folder fromMap(Map<String, dynamic> map) {
    return Folder(
    id: map['id'],
    name: map['name'],
    timestamp: map['timestamp'],
    );
  }
}

class CardModel {
  int? id;
  String name;
  String suit;
  String imageUrl;
  int folderId;

  CardModel(
      {this.id,
      required this.name,
      required this.suit,
      required this.imageUrl,
      required this.folderId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'suit': suit,
      'imageUrl': imageUrl,
      'folderId': folderId,
    };
  }

  static CardModel fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'],
      name: map['name'],
      suit: map['suit'],
      imageUrl: map['imageUrl'],
      folderId: map['folderId'],
    );
  }
}

class DatabaseHelper {
  late Database _db;

  Future<Database> get db async {
    return _db;
      _db = await initializeDatabase();
    return _db;
  }

  Future<Database> initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'card_organizer.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        suit TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        folderId INTEGER NOT NULL,
        FOREIGN KEY (folderId) REFERENCES folders(id)
      )
    ''');

    //Pre-defined folders
    await db.insert('folders', {'name': 'Hearts', 'timestamp': DateTime.now().toString()});
    await db.insert('folders', {'name': 'Spades', 'timestamp': DateTime.now().toString()});
    await db.insert('folders', {'name': 'Diamonds', 'timestamp': DateTime.now().toString()});
    await db.insert('folders', {'name': 'Clubs', 'timestamp': DateTime.now().toString()});

    //Pre-populate cards (example)
    await db.insert('cards', {
      'name': 'Ace',
      'suit': 'Hearts',
      'imageUrl': 'https://example.com/ace_of_hearts.png',
      'folderId': 1
    });
    await db.insert('cards', {
      'name': 'King',
      'suit': 'Spades',
      'imageUrl': 'https://example.com/king_of_spades.png',
      'folderId': 2
    });
  }

  //Folder CRUD operations
  Future<List<Folder>> getFolders() async {
    final dbInstance = await db;
    final List<Map<String, dynamic>> maps = await dbInstance.query('folders');
    return List.generate(maps.length, (i) {
      return Folder.fromMap(maps[i]);
    });
  }

  Future<int> insertFolder(Folder folder) async {
    final dbInstance = await db;
    return await dbInstance.insert('folders', folder.toMap());
  }

  Future<int> updateFolder(Folder folder) async {
    final dbInstance = await db;
    return await dbInstance.update('folders', folder.toMap(),
        where: 'id = ?', whereArgs: [folder.id]);
  }

  Future<int> deleteFolder(int id) async {
    final dbInstance = await db;
    await dbInstance.delete('cards', where: 'folderId = ?', whereArgs: [id]);
    return await dbInstance.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  //Card CRUD operations
  Future<List<CardModel>> getCardsByFolderId(int folderId) async {
    final dbInstance = await db;
    final List<Map<String, dynamic>> maps = await dbInstance.query(
      'cards',
      where: 'folderId = ?',
      whereArgs: [folderId],
    );
    return List.generate(maps.length, (i) {
      return CardModel.fromMap(maps[i]);
    });
  }

  Future<int> insertCard(CardModel card) async {
    final dbInstance = await db;
    return await dbInstance.insert('cards', card.toMap());
  }

  Future<int> updateCard(CardModel card) async {
    final dbInstance = await db;
    return await dbInstance.update('cards', card.toMap(),
        where: 'id = ?', whereArgs: [card.id]);
  }

  Future<int> deleteCard(int id) async {
    final dbInstance = await db;
    return await dbInstance.delete('cards', where: 'id = ?', whereArgs: [id]);
  }
}
