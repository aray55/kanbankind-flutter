class DatabaseConstants {
  // Database constants
  static const String databaseName = 'kanban_kit.db';
  static const int databaseVersion = 1; // Incremented for cards table
  static const String tasksTable = 'tasks';
  static const String checklistItemsTable = 'checklist_items';
  static const String boardsTable = 'boards';
  static const String listTable = 'lists';
  static const String cardsTable = 'cards';
  static const String checklistsTable = 'checklists';
  static const String labelsTable = 'labels';
  static const String cardLabelsTable = 'card_labels';
  
  // New tables for enhanced functionality
  static const String commentsTable = 'comments';
  static const String attachmentsTable = 'attachments';
  static const String activityLogTable = 'activity_log';
}
