import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

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
    final path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${AppConstants.tasksTable} (
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
      CREATE TABLE IF NOT EXISTS ${AppConstants.checklistItemsTable} (
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
      CREATE TABLE IF NOT EXISTS ${AppConstants.boardsTable} (
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
      'CREATE INDEX IF NOT EXISTS idx_boards_uuid ON ${AppConstants.boardsTable}(uuid)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_boards_archived ON ${AppConstants.boardsTable}(archived)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_boards_deleted ON ${AppConstants.boardsTable}(deleted_at)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_boards_updated_deleted ON ${AppConstants.boardsTable}(updated_at, deleted_at)',
    );

    // Create trigger for boards table
    await db.execute('''
      CREATE TRIGGER IF NOT EXISTS set_boards_updated_at
      AFTER UPDATE ON ${AppConstants.boardsTable}
      FOR EACH ROW
      WHEN NEW.title IS NOT OLD.title
         OR NEW.description IS NOT OLD.description
         OR NEW.color IS NOT OLD.color
         OR NEW.position IS NOT OLD.position
         OR NEW.archived IS NOT OLD.archived
         OR NEW.deleted_at IS NOT OLD.deleted_at
      BEGIN
        UPDATE ${AppConstants.boardsTable}
        SET updated_at = strftime('%s','now')
        WHERE id = OLD.id;
      END
    ''');

    // Create lists table
    await db.execute('''
CREATE TABLE IF NOT EXISTS ${AppConstants.listTable} (
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
CREATE INDEX IF NOT EXISTS idx_lists_board_id ON ${AppConstants.listTable}(board_id);
CREATE INDEX IF NOT EXISTS idx_lists_archived ON ${AppConstants.listTable}(archived);
CREATE INDEX IF NOT EXISTS idx_lists_position ON ${AppConstants.listTable}(position);
CREATE INDEX IF NOT EXISTS idx_lists_updated_at ON ${AppConstants.listTable}(updated_at);
''');

    await db.execute('''
CREATE TRIGGER IF NOT EXISTS set_lists_updated_at
AFTER UPDATE ON ${AppConstants.listTable}
FOR EACH ROW
BEGIN
  UPDATE ${AppConstants.listTable}
  SET updated_at = strftime('%s','now')
  WHERE id = OLD.id;
END;
''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < newVersion) {
      // Add migration logic as needed
    }
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
