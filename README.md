# kanbankit

# KanbanKit

A modern Flutter Kanban board application for task management with drag-and-drop functionality.

## Features

- 📋 Three-column Kanban board (To Do, In Progress, Done)
- 🎯 Drag and drop tasks between columns
- ✏️ Create, edit, and delete tasks
- 📅 Due date tracking with visual indicators
- 🎨 Priority levels (High, Medium, Low)
- 💾 Local SQLite database storage
- 🎭 Clean Material Design 3 UI

## Project Structure

```
lib/
├── main.dart                   # App entry point
├── app.dart                    # App configuration & theme
│
├── core/
│   ├── constants/              # App constants
│   ├── utils/                  # Helper utilities (date formatting)
│   └── enums/                  # Enums (TaskStatus)
│
├── models/
│   └── task_model.dart         # Task data model
│
├── data/
│   ├── database/
│   │   ├── database_provider.dart   # Database initialization & migrations
│   │   └── task_dao.dart           # SQL CRUD operations
│   └── repository/
│       └── task_repository.dart    # Business logic layer
│
├── controllers/
│   └── board_controller.dart       # GetX state management
│
├── views/
│   ├── board/
│   │   ├── board_page.dart         # Main board view
│   │   └── column_list.dart        # Kanban column with task list
│   │
│   ├── widgets/
│   │   ├── task_card.dart          # Individual task card
│   │   └── task_editor.dart        # Task creation/editing form
│   │
│   └── components/                 # Reusable UI components
│
└── bindings/
    └── board_binding.dart          # GetX dependency injection

assets/
├── images/                     # Image assets
└── screenshots/                # App screenshots
```

## Dependencies

- **get**: State management and dependency injection
- **sqflite**: Local SQLite database
- **path**: File path utilities
- **intl**: Date formatting and internationalization

## Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd kanbankit
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Architecture

This project follows a clean architecture pattern with:

- **Presentation Layer**: Views and Controllers (GetX)
- **Domain Layer**: Models and Business Logic
- **Data Layer**: Database and Repository pattern
- **Core Layer**: Utilities, Constants, and Enums

## Usage

1. **Create a Task**: Tap the floating action button (+) to create a new task
2. **Edit a Task**: Tap on any task card to edit its details
3. **Move Tasks**: Drag and drop tasks between columns (To Do → In Progress → Done)
4. **Delete Tasks**: Use the menu button on task cards to delete tasks
5. **Set Priorities**: Assign High, Medium, or Low priority to tasks
6. **Due Dates**: Set optional due dates with visual indicators for overdue tasks

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
