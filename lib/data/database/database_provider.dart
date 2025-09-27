import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
  deleted_at INTEGER,
  FOREIGN KEY(board_id) REFERENCES boards(id) ON DELETE CASCADE
);
''');

    await db.execute('''
CREATE INDEX IF NOT EXISTS idx_lists_board_id ON ${DatabaseConstants.listTable}(board_id);
CREATE INDEX IF NOT EXISTS idx_lists_archived ON ${DatabaseConstants.listTable}(archived);
CREATE INDEX IF NOT EXISTS idx_lists_position ON ${DatabaseConstants.listTable}(position);
CREATE INDEX IF NOT EXISTS idx_lists_updated_at ON ${DatabaseConstants.listTable}(updated_at);
CREATE INDEX IF NOT EXISTS idx_lists_deleted_at ON ${DatabaseConstants.listTable}(deleted_at);
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
  cover_color TEXT CHECK(length(cover_color) BETWEEN 4 AND 9),
  cover_image TEXT,
  completed_at INTEGER,
  due_date INTEGER,
  archived INTEGER NOT NULL DEFAULT 0 CHECK(archived IN (0,1)),
  deleted_at INTEGER,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  FOREIGN KEY(list_id) REFERENCES lists(id) ON DELETE CASCADE
);
''');

    await db.execute('''
CREATE INDEX IF NOT EXISTS idx_cards_due_date ON ${DatabaseConstants.cardsTable}(due_date);
CREATE INDEX IF NOT EXISTS idx_cards_list_id ON ${DatabaseConstants.cardsTable}(list_id);
CREATE INDEX IF NOT EXISTS idx_cards_archived ON ${DatabaseConstants.cardsTable}(archived);
CREATE INDEX IF NOT EXISTS idx_cards_position ON ${DatabaseConstants.cardsTable}(position);
CREATE INDEX IF NOT EXISTS idx_cards_status ON ${DatabaseConstants.cardsTable}(status);
CREATE INDEX IF NOT EXISTS idx_cards_updated_at ON ${DatabaseConstants.cardsTable}(updated_at);
CREATE INDEX IF NOT EXISTS idx_cards_deleted_at ON ${DatabaseConstants.cardsTable}(deleted_at);
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
    // Create checklists table
    await db.execute('''
CREATE TABLE IF NOT EXISTS ${DatabaseConstants.checklistsTable} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  card_id INTEGER NOT NULL,
  title TEXT NOT NULL CHECK(length(title) <= 255),
  position REAL NOT NULL DEFAULT 1024,
  archived INTEGER NOT NULL DEFAULT 0 CHECK(archived IN (0,1)),
  created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  deleted_at INTEGER,
  FOREIGN KEY(card_id) REFERENCES ${DatabaseConstants.cardsTable}(id) ON DELETE CASCADE
);
''');

    // Create indexes for checklists table
    await db.execute('''
CREATE INDEX IF NOT EXISTS idx_checklists_card_id ON ${DatabaseConstants.checklistsTable}(card_id);
CREATE INDEX IF NOT EXISTS idx_checklists_archived ON ${DatabaseConstants.checklistsTable}(archived);
CREATE INDEX IF NOT EXISTS idx_checklists_position ON ${DatabaseConstants.checklistsTable}(position);
CREATE INDEX IF NOT EXISTS idx_checklists_updated_deleted ON ${DatabaseConstants.checklistsTable}(updated_at, deleted_at);
''');

    // Create trigger for checklists table
    await db.execute('''
CREATE TRIGGER IF NOT EXISTS set_checklists_updated_at
AFTER UPDATE ON ${DatabaseConstants.checklistsTable}
FOR EACH ROW
WHEN NEW.title IS NOT OLD.title
   OR NEW.position IS NOT OLD.position
   OR NEW.archived IS NOT OLD.archived
   OR NEW.deleted_at IS NOT OLD.deleted_at
BEGIN
  UPDATE ${DatabaseConstants.checklistsTable}
  SET updated_at = strftime('%s','now')
  WHERE id = OLD.id;
END;
''');

    // Create checklist_items table
    await db.execute('''
CREATE TABLE IF NOT EXISTS ${DatabaseConstants.checklistItemsTable} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  checklist_id INTEGER NOT NULL,
  title TEXT NOT NULL CHECK(length(title) <= 255),
  is_done INTEGER NOT NULL DEFAULT 0 CHECK(is_done IN (0,1)),
  position REAL NOT NULL DEFAULT 1024,
  archived INTEGER NOT NULL DEFAULT 0 CHECK(archived IN (0,1)),
  created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  deleted_at INTEGER,
  FOREIGN KEY(checklist_id) REFERENCES ${DatabaseConstants.checklistsTable}(id) ON DELETE CASCADE
);
''');

    // Create indexes for checklist_items table
    await db.execute('''
CREATE INDEX IF NOT EXISTS idx_checklist_items_checklist_id ON ${DatabaseConstants.checklistItemsTable}(checklist_id);
CREATE INDEX IF NOT EXISTS idx_checklist_items_is_done ON ${DatabaseConstants.checklistItemsTable}(is_done);
CREATE INDEX IF NOT EXISTS idx_checklist_items_archived ON ${DatabaseConstants.checklistItemsTable}(archived);
CREATE INDEX IF NOT EXISTS idx_checklist_items_position ON ${DatabaseConstants.checklistItemsTable}(position);
CREATE INDEX IF NOT EXISTS idx_checklist_items_updated_deleted ON ${DatabaseConstants.checklistItemsTable}(updated_at, deleted_at);
''');

    // Create trigger for checklist_items table
    await db.execute('''
CREATE TRIGGER IF NOT EXISTS set_checklist_items_updated_at
AFTER UPDATE ON ${DatabaseConstants.checklistItemsTable}
FOR EACH ROW
WHEN NEW.title IS NOT OLD.title
   OR NEW.is_done IS NOT OLD.is_done
   OR NEW.position IS NOT OLD.position
   OR NEW.archived IS NOT OLD.archived
   OR NEW.deleted_at IS NOT OLD.deleted_at
BEGIN
  UPDATE ${DatabaseConstants.checklistItemsTable}
  SET updated_at = strftime('%s','now')
  WHERE id = OLD.id;
END;
''');

    // Create labels table
    await db.execute('''
CREATE TABLE IF NOT EXISTS ${DatabaseConstants.labelsTable} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  board_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  color TEXT NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
  deleted_at INTEGER,
  FOREIGN KEY(board_id) REFERENCES ${DatabaseConstants.boardsTable}(id) ON DELETE CASCADE
);
''');

    // Create indexes for labels table
    await db.execute('''
CREATE INDEX IF NOT EXISTS idx_labels_board_id ON ${DatabaseConstants.labelsTable}(board_id);
''');

    // Create trigger for labels table
    await db.execute('''
CREATE TRIGGER IF NOT EXISTS set_labels_updated_at
AFTER UPDATE ON ${DatabaseConstants.labelsTable}
FOR EACH ROW
WHEN NEW.name IS NOT OLD.name
   OR NEW.color IS NOT OLD.color
BEGIN
  UPDATE ${DatabaseConstants.labelsTable}
  SET updated_at = strftime('%s','now')
  WHERE id = OLD.id;
END;
''');

    // Create card_labels table
    await db.execute('''
CREATE TABLE IF NOT EXISTS ${DatabaseConstants.cardLabelsTable} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  card_id INTEGER NOT NULL,
  label_id INTEGER NOT NULL,
  deleted_at INTEGER,
  FOREIGN KEY(card_id) REFERENCES ${DatabaseConstants.cardsTable}(id) ON DELETE CASCADE,
  FOREIGN KEY(label_id) REFERENCES ${DatabaseConstants.labelsTable}(id) ON DELETE CASCADE
);
''');

    // Create indexes for card_labels table
    await db.execute('''
CREATE INDEX IF NOT EXISTS idx_card_labels_card_id ON ${DatabaseConstants.cardLabelsTable}(card_id);
CREATE INDEX IF NOT EXISTS idx_card_labels_label_id ON ${DatabaseConstants.cardLabelsTable}(label_id);
''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < newVersion) {
     
    }
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
