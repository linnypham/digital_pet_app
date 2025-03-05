import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "CardOrganizerDatabase.db";
  static const _databaseVersion = 1;

  static const folderTable = 'folders';
  static const cardTable = 'cards';

  static const columnId = '_id';
  static const columnFolderName = 'folder_name';
  static const columnTimestamp = 'timestamp';
  static const columnCardName = 'card_name';
  static const columnSuit = 'suit';
  static const columnImageUrl = 'image_url';
  static const columnFolderId = 'folder_id';

  late Database _db;

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
      CREATE TABLE $folderTable (
        $columnId INTEGER PRIMARY KEY,
        $columnFolderName TEXT NOT NULL,
        $columnTimestamp INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $cardTable (
        $columnId INTEGER PRIMARY KEY,
        $columnCardName TEXT NOT NULL,
        $columnSuit TEXT NOT NULL,
        $columnImageUrl TEXT NOT NULL,
        $columnFolderId INTEGER,
        FOREIGN KEY ($columnFolderId) REFERENCES $folderTable ($columnId)
      )
    ''');

    await _prepopulateFolders(db);
    await _prepopulateCards(db);
  }

  Future<void> _prepopulateFolders(Database db) async {
    final folders = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    for (var folder in folders) {
      await db.insert(folderTable, {
        columnFolderName: folder,
        columnTimestamp: DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  Future<void> _prepopulateCards(Database db) async {
    final suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    final values = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];
    for (var suit in suits) {
      for (var value in values) {
        await db.insert(cardTable, {
          columnCardName: '$value of $suit',
          columnSuit: suit,
          columnImageUrl: '',
          columnFolderId: null, 
        });
      }
    }
  }

  Future<int> insertFolder(Map<String, dynamic> row) async {
    return await _db.insert(folderTable, row);
  }

  Future<int> insertCard(Map<String, dynamic> row) async {
    return await _db.insert(cardTable, row);
  }

  Future<List<Map<String, dynamic>>> queryAllFolders() async {
    return await _db.query(folderTable);
  }

  Future<List<Map<String, dynamic>>> queryAllCards() async {
    return await _db.query(cardTable);
  }

  Future<List<Map<String, dynamic>>> queryCardsInFolder(int folderId) async {
    return await _db.query(
      cardTable,
      where: '$columnFolderId = ?',
      whereArgs: [folderId],
    );
  }


  Future<int> updateFolder(Map<String, dynamic> row) async {
    int id = row[columnId];
    return await _db.update(
      folderTable,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateCard(Map<String, dynamic> row) async {
    int id = row[columnId];
    return await _db.update(
      cardTable,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteFolder(int id) async {
    return await _db.delete(
      folderTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCard(int id) async {
    return await _db.delete(
      cardTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> getCardCountInFolder(int folderId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) FROM $cardTable WHERE $columnFolderId = ?',
      [folderId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
