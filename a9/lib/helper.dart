import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "CardOrganizer.db";
  static const _databaseVersion = 1;

  static const foldersTable = 'folders';
  static const cardsTable = 'cards';

  static const columnFolderId = 'id';
  static const columnFolderName = 'name';
  static const columnFolderTimestamp = 'timestamp';

  static const columnCardId = 'id';
  static const columnCardName = 'name';
  static const columnCardSuit = 'suit';
  static const columnCardImageUrl = 'imageUrl';
  static const columnCardFolderId = 'folderId';

  late Database _db;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }
  Future<int> insertCard(Map<String, dynamic> row) async {
    return await _db.insert(cardsTable, row);
  }

  Future<int> deleteCard(int id) async {
    return await _db.delete(
      cardsTable,
      where: '$columnCardId = ?',
      whereArgs: [id],
    );
  }

  Future _onCreate(Database db, int version) async {
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

    List<String> suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    for (var suit in suits) {
      await db.insert(foldersTable, {
        columnFolderName: suit,
        columnFolderTimestamp: DateTime.now().toIso8601String(),
      });
    }

    Map<String, List<String>> cardImages = {
      'Hearts': [
        'https://upload.wikimedia.org/wikipedia/commons/5/57/Playing_card_heart_A.svg',
        'https://upload.wikimedia.org/wikipedia/commons/d/d5/Playing_card_heart_2.svg',
        'https://upload.wikimedia.org/wikipedia/commons/b/b6/Playing_card_heart_3.svg',
        'https://upload.wikimedia.org/wikipedia/commons/a/a2/Playing_card_heart_4.svg',
        'https://upload.wikimedia.org/wikipedia/commons/5/52/Playing_card_heart_5.svg',
        'https://upload.wikimedia.org/wikipedia/commons/c/cd/Playing_card_heart_6.svg',
        'https://upload.wikimedia.org/wikipedia/commons/9/94/Playing_card_heart_7.svg',
        'https://upload.wikimedia.org/wikipedia/commons/5/50/Playing_card_heart_8.svg',
        'https://upload.wikimedia.org/wikipedia/commons/5/50/Playing_card_heart_9.svg',
        'https://upload.wikimedia.org/wikipedia/commons/9/98/Playing_card_heart_10.svg',
        'https://upload.wikimedia.org/wikipedia/commons/4/46/Playing_card_heart_J.svg',
        'https://upload.wikimedia.org/wikipedia/commons/7/72/Playing_card_heart_Q.svg',
        'https://upload.wikimedia.org/wikipedia/commons/d/dc/Playing_card_heart_K.svg'
      ],
      'Spades': [
        'https://upload.wikimedia.org/wikipedia/commons/2/25/Playing_card_spade_A.svg',
        'https://upload.wikimedia.org/wikipedia/commons/f/f2/Playing_card_spade_2.svg',
        'https://upload.wikimedia.org/wikipedia/commons/5/52/Playing_card_spade_3.svg',
        'https://upload.wikimedia.org/wikipedia/commons/2/2c/Playing_card_spade_4.svg',
        'https://upload.wikimedia.org/wikipedia/commons/9/94/Playing_card_spade_5.svg',
        'https://upload.wikimedia.org/wikipedia/commons/d/d2/Playing_card_spade_6.svg',
        'https://upload.wikimedia.org/wikipedia/commons/6/66/Playing_card_spade_7.svg',
        'https://upload.wikimedia.org/wikipedia/commons/2/21/Playing_card_spade_8.svg',
        'https://upload.wikimedia.org/wikipedia/commons/e/e0/Playing_card_spade_9.svg',
        'https://upload.wikimedia.org/wikipedia/commons/8/87/Playing_card_spade_10.svg',
        'https://upload.wikimedia.org/wikipedia/commons/b/bd/Playing_card_spade_J.svg',
        'https://upload.wikimedia.org/wikipedia/commons/5/51/Playing_card_spade_Q.svg',
        'https://upload.wikimedia.org/wikipedia/commons/9/9f/Playing_card_spade_K.svg'
      ],
      'Diamonds': [
        'https://upload.wikimedia.org/wikipedia/commons/d/d3/Playing_card_diamond_A.svg',
        'https://upload.wikimedia.org/wikipedia/commons/5/59/Playing_card_diamond_2.svg',
        'https://upload.wikimedia.org/wikipedia/commons/8/82/Playing_card_diamond_3.svg',
        'https://upload.wikimedia.org/wikipedia/commons/2/20/Playing_card_diamond_4.svg',
        'https://upload.wikimedia.org/wikipedia/commons/f/fd/Playing_card_diamond_5.svg',
        'https://upload.wikimedia.org/wikipedia/commons/a/ac/Playing_card_diamond_6.svg',
        'https://upload.wikimedia.org/wikipedia/commons/e/e6/Playing_card_diamond_7.svg',
        'https://upload.wikimedia.org/wikipedia/commons/7/78/Playing_card_diamond_8.svg',
        'https://upload.wikimedia.org/wikipedia/commons/9/9e/Playing_card_diamond_9.svg',
        'https://upload.wikimedia.org/wikipedia/commons/3/34/Playing_card_diamond_10.svg',
        'https://upload.wikimedia.org/wikipedia/commons/a/af/Playing_card_diamond_J.svg',
        'https://upload.wikimedia.org/wikipedia/commons/0/0b/Playing_card_diamond_Q.svg',
        'https://upload.wikimedia.org/wikipedia/commons/7/78/Playing_card_diamond_K.svg'
      ],
      'Clubs': [
        'https://upload.wikimedia.org/wikipedia/commons/3/36/Playing_card_club_A.svg',
        'https://upload.wikimedia.org/wikipedia/commons/f/f5/Playing_card_club_2.svg',
        'https://upload.wikimedia.org/wikipedia/commons/6/6b/Playing_card_club_3.svg',
        'https://upload.wikimedia.org/wikipedia/commons/3/3d/Playing_card_club_4.svg',
        'https://upload.wikimedia.org/wikipedia/commons/5/50/Playing_card_club_5.svg',
        'https://upload.wikimedia.org/wikipedia/commons/a/a0/Playing_card_club_6.svg',
        'https://upload.wikimedia.org/wikipedia/commons/4/4b/Playing_card_club_7.svg',
        'https://upload.wikimedia.org/wikipedia/commons/e/eb/Playing_card_club_8.svg',
        'https://upload.wikimedia.org/wikipedia/commons/2/27/Playing_card_club_9.svg',
        'https://upload.wikimedia.org/wikipedia/commons/3/3e/Playing_card_club_10.svg',
        'https://upload.wikimedia.org/wikipedia/commons/b/b7/Playing_card_club_J.svg',
        'https://upload.wikimedia.org/wikipedia/commons/f/f2/Playing_card_club_Q.svg',
        'https://upload.wikimedia.org/wikipedia/commons/2/22/Playing_card_club_K.svg'
      ]
    };

    List<String> cardNames = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];

    for (var suit in suits) {
      var folderId = await db.query(foldersTable, where: '$columnFolderName = ?', whereArgs: [suit]);
      for (int i = 0; i < 13; i++) {
        await db.insert(cardsTable, {
          columnCardName: cardNames[i],
          columnCardSuit: suit,
          columnCardImageUrl: cardImages[suit]![i],
          columnCardFolderId: folderId[0][columnFolderId],
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> getFolders() async {
    return await _db.query(foldersTable);
  }

  Future<List<Map<String, dynamic>>> getCardsByFolder(int folderId) async {
    return await _db.query(
      cardsTable,
      where: '$columnCardFolderId = ?',
      whereArgs: [folderId],
    );
  }

  Future<int> getCardCountInFolder(int folderId) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM $cardsTable WHERE $columnCardFolderId = ?',
      [folderId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
