import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/database_constants.dart';

class DatabaseProvider {
  static Database? _database;
  static final DatabaseProvider _instance = DatabaseProvider._internal();

  factory DatabaseProvider() => _instance;
  DatabaseProvider._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, DatabaseConstants.databaseName);

    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.tasksTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        due_date INTEGER,
        priority INTEGER NOT NULL DEFAULT 2,
        updated_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.checklistItemsTable} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER NOT NULL,        -- رابط بالمهمة
    title TEXT NOT NULL,
    is_done INTEGER NOT NULL DEFAULT 0, -- 0 = false, 1 = true
    position INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE)

    ''');

    // Create boards table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseConstants.boardsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL UNIQUE,
        title TEXT NOT NULL CHECK(length(title) <= 255),
        description TEXT,
        color TEXT CHECK(length(color) BETWEEN 4 AND 9),
        position INTEGER DEFAULT 1024,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
        updated_at INTEGER DEFAULT (strftime('%s','now')),
        archived INTEGER NOT NULL DEFAULT 0 CHECK(archived IN (0,1)),
        deleted_at INTEGER
      )
    ''');

    // Create indexes for boards table
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_boards_uuid ON ${DatabaseConstants.boardsTable}(uuid)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_boards_archived ON ${DatabaseConstants.boardsTable}(archived)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_boards_deleted ON ${DatabaseConstants.boardsTable}(deleted_at)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_boards_updated_deleted ON ${DatabaseConstants.boardsTable}(updated_at, deleted_at)',
    );

    // Create trigger for boards table
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS set_boards_updated_at
      AFTER UPDATE ON ${DatabaseConstants.boardsTable}
      FOR EACH ROW
      WHEN NEW.title IS NOT OLD.title
         OR NEW.description IS NOT OLD.description
         OR NEW.color IS NOT OLD.color
         OR NEW.position IS NOT OLD.position
         OR NEW.archived IS NOT OLD.archived
         OR NEW.deleted_at IS NOT OLD.deleted_at
      BEGIN
        UPDATE ${DatabaseConstants.boardsTable}
        SET updated_at = strftime('%s','now')
        WHERE id = OLD.id;
      END
    ''');

    // Create lists table
    await db.execute('''
CREATE TABLE IF NOT EXISTS ${DatabaseConstants.listTable} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  board_id INTEGER NOT NULL,
  title TEXT NOT NULL CHECK(length(title) <= 255),
  color TEXT CHECK(length(color) BETWEEN 4 AND 9), -- دعم #FFF و #RRGGBBAA
  position REAL NOT NULL DEFAULT 1024,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  archived INTEGER NOT NULL DEFAULT 0 CHECK(archived IN (0,1)),
  FOREIGN KEY(board_id) REFERENCES boards(id) ON DELETE CASCADE
);
''');

    await db.execute('''
CREATE INDEX IF NOT EXISTS idx_lists_board_id ON ${DatabaseConstants.listTable}(board_id);
CREATE INDEX IF NOT EXISTS idx_lists_archived ON ${DatabaseConstants.listTable}(archived);
CREATE INDEX IF NOT EXISTS idx_lists_position ON ${DatabaseConstants.listTable}(position);
CREATE INDEX IF NOT EXISTS idx_lists_updated_at ON ${DatabaseConstants.listTable}(updated_at);
''');

    await db.execute('''
CREATE TRIGGER IF NOT EXISTS set_lists_updated_at
AFTER UPDATE ON ${DatabaseConstants.listTable}
FOR EACH ROW
BEGIN
  UPDATE ${DatabaseConstants.listTable}
  SET updated_at = strftime('%s','now')
  WHERE id = OLD.id;
END;
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS ${DatabaseConstants.cardsTable} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  list_id INTEGER NOT NULL,
  title TEXT NOT NULL CHECK(length(title) <= 255),
  description TEXT,
  position REAL NOT NULL DEFAULT 1024,
  status TEXT NOT NULL DEFAULT 'todo',
  completed_at INTEGER,
  archived INTEGER NOT NULL DEFAULT 0 CHECK(archived IN (0,1)),
  created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  FOREIGN KEY(list_id) REFERENCES lists(id) ON DELETE CASCADE
);
''');

    await db.execute('''
CREATE INDEX IF NOT EXISTS idx_cards_list_id ON ${DatabaseConstants.cardsTable}(list_id);
CREATE INDEX IF NOT EXISTS idx_cards_archived ON ${DatabaseConstants.cardsTable}(archived);
CREATE INDEX IF NOT EXISTS idx_cards_position ON ${DatabaseConstants.cardsTable}(position);
CREATE INDEX IF NOT EXISTS idx_cards_status ON ${DatabaseConstants.cardsTable}(status);
CREATE INDEX IF NOT EXISTS idx_cards_updated_at ON ${DatabaseConstants.cardsTable}(updated_at);
''');

    await db.execute('''
CREATE TRIGGER IF NOT EXISTS set_cards_updated_at
AFTER UPDATE ON ${DatabaseConstants.cardsTable}
FOR EACH ROW
BEGIN
  UPDATE ${DatabaseConstants.cardsTable}
  SET updated_at = strftime('%s','now')
  WHERE id = OLD.id;
END;''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < 2) {
      // Migration to version 2: Add cards table
      await db.execute('''
CREATE TABLE IF NOT EXISTS ${DatabaseConstants.cardsTable} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  list_id INTEGER NOT NULL,
  title TEXT NOT NULL CHECK(length(title) <= 255),
  description TEXT,
  position REAL NOT NULL DEFAULT 1024,
  status TEXT NOT NULL DEFAULT '',
  completed_at INTEGER,
  archived INTEGER NOT NULL DEFAULT 0 CHECK(archived IN (0,1)),
  created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  FOREIGN KEY(list_id) REFERENCES lists(id) ON DELETE CASCADE
);
''');

      await db.execute('''
CREATE INDEX IF NOT EXISTS idx_cards_list_id ON ${DatabaseConstants.cardsTable}(list_id);
CREATE INDEX IF NOT EXISTS idx_cards_archived ON ${DatabaseConstants.cardsTable}(archived);
CREATE INDEX IF NOT EXISTS idx_cards_position ON ${DatabaseConstants.cardsTable}(position);
CREATE INDEX IF NOT EXISTS idx_cards_status ON ${DatabaseConstants.cardsTable}(status);
CREATE INDEX IF NOT EXISTS idx_cards_updated_at ON ${DatabaseConstants.cardsTable}(updated_at);
''');

      await db.execute('''
CREATE TRIGGER IF NOT EXISTS set_cards_updated_at
AFTER UPDATE ON ${DatabaseConstants.cardsTable}
FOR EACH ROW
BEGIN
  UPDATE ${DatabaseConstants.cardsTable}
  SET updated_at = strftime('%s','now')
  WHERE id = OLD.id;
END;''');
    }
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
