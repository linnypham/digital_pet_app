// helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "CardOrganizer.db";
  static final _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        suit TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        folderId INTEGER,
        FOREIGN KEY (folderId) REFERENCES folders (id)
      )
    ''');

    // Prepopulate folders
    List<String> suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    for (String suit in suits) {
      await db.insert('folders', {
        'name': suit,
        'timestamp': DateTime.now().millisecondsSinceEpoch
      });
    }

    // Prepopulate cards
    List<String> ranks = ['Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'];
    for (String suit in suits) {
      for (String rank in ranks) {
        await db.insert('cards', {
          'name': '$rank of $suit',
          'suit': suit,
          'imageUrl': 'https://example.com/${suit.toLowerCase()}_${rank.toLowerCase()}.png',
          'folderId': null
        });
      }
    }
  }

  Future<List<Folder>> getFolders() async {
    Database db = await instance.database;
    var folders = await db.query('folders');
    List<Folder> folderList = folders.isNotEmpty
        ? folders.map((c) => Folder.fromMap(c)).toList()
        : [];
    return folderList;
  }

  Future<List<Card>> getCards(int folderId) async {
    Database db = await instance.database;
    var cards = await db.query('cards', where: 'folderId = ?', whereArgs: [folderId]);
    List<Card> cardList = cards.isNotEmpty
        ? cards.map((c) => Card.fromMap(c)).toList()
        : [];
    return cardList;
  }

  Future<int> deleteCard(int id) async {
    Database db = await instance.database;
    return await db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }
}

class Folder {
  final int id;
  final String name;
  final int timestamp;
  final int cardCount;

  Folder({required this.id, required this.name, required this.timestamp, this.cardCount = 0});

  factory Folder.fromMap(Map<String, dynamic> json) => Folder(
    id: json['id'],
    name: json['name'],
    timestamp: json['timestamp'],
  );
}

class Card {
  final int id;
  final String name;
  final String suit;
  final String imageUrl;
  final int? folderId;

  Card({required this.id, required this.name, required this.suit, required this.imageUrl, this.folderId});

  factory Card.fromMap(Map<String, dynamic> json) => Card(
    id: json['id'],
    name: json['name'],
    suit: json['suit'],
    imageUrl: json['imageUrl'],
    folderId: json['folderId'],
  );
}
