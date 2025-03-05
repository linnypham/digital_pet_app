import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "CardOrganizer.db";
  static const _databaseVersion = 1;

  // Table names
  static const foldersTable = 'folders';
  static const cardsTable = 'cards';

  // Folder table columns
  static const columnFolderId = 'id';
  static const columnFolderName = 'name';
  static const columnFolderTimestamp = 'timestamp';

  // Card table columns
  static const columnCardId = 'id';
  static const columnCardName = 'name';
  static const columnCardSuit = 'suit';
  static const columnCardImageUrl = 'imageUrl';
  static const columnCardFolderId = 'folderId';

  late Database _db;

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Initialize the database
  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $foldersTable (
        $columnFolderId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnFolderName TEXT NOT NULL,
        $columnFolderTimestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $cardsTable (
        $columnCardId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnCardName TEXT NOT NULL,
        $columnCardSuit TEXT NOT NULL,
        $columnCardImageUrl TEXT NOT NULL,
        $columnCardFolderId INTEGER,
        FOREIGN KEY ($columnCardFolderId) REFERENCES $foldersTable ($columnFolderId)
      )
    ''');

    await db.insert(foldersTable, {
      columnFolderName: 'Hearts',
      columnFolderTimestamp: DateTime.now().toString(),
    });
    await db.insert(foldersTable, {
      columnFolderName: 'Spades',
      columnFolderTimestamp: DateTime.now().toString(),
    });
    await db.insert(foldersTable, {
      columnFolderName: 'Diamonds',
      columnFolderTimestamp: DateTime.now().toString(),
    });
    await db.insert(foldersTable, {
      columnFolderName: 'Clubs',
      columnFolderTimestamp: DateTime.now().toString(),
    });

    // Enter URLS
    List<Map<String, String>> cards = [
      {'name': 'Ace of Hearts', 'suit': 'Hearts', 'imageUrl': 'URL'},
      {'name': 'King of Hearts', 'suit': 'Hearts', 'imageUrl': 'URL'},
      // Add more cards 
    ];

    for (var card in cards) {
      await db.insert(cardsTable, {
        columnCardName: card['name'],
        columnCardSuit: card['suit'],
        columnCardImageUrl: card['imageUrl'],
        columnCardFolderId: 1,
      });
    }
  }

  Future<int> insertFolder(Map<String, dynamic> folder) async {
    return await _db.insert(foldersTable, folder);
  }

  Future<List<Map<String, dynamic>>> getFolders() async {
    return await _db.query(foldersTable);
  }

  Future<int> insertCard(Map<String, dynamic> card) async {
    return await _db.insert(cardsTable, card);
  }

  Future<List<Map<String, dynamic>>> getCardsByFolder(int folderId) async {
    return await _db.query(
      cardsTable,
      where: '$columnCardFolderId = ?',
      whereArgs: [folderId],
    );
  }

  Future<int> updateCard(Map<String, dynamic> card) async {
    return await _db.update(
      cardsTable,
      card,
      where: '$columnCardId = ?',
      whereArgs: [card[columnCardId]],
    );
  }

  Future<int> deleteCard(int id) async {
    return await _db.delete(
      cardsTable,
      where: '$columnCardId = ?',
      whereArgs: [id],
    );
  }
}