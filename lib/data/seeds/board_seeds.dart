import '../../models/board_model.dart';

/// Board seed data for development and testing purposes
class BoardSeeds {
  /// Sample board data with various colors and descriptions
  static List<Map<String, dynamic>> get sampleBoards => [
    {
      'uuid': 'board_personal_001',
      'title': 'Personal Projects',
      'description': 'Track your personal side projects and hobbies',
      'color': '#3498db',
      'position': 1024,
    },
    {
      'uuid': 'board_work_002',
      'title': 'Work Tasks',
      'description': 'Manage your daily work assignments and deadlines',
      'color': '#e74c3c',
      'position': 2048,
    },
    {
      'uuid': 'board_learning_003',
      'title': 'Learning Goals',
      'description':
          'Keep track of courses, books, and skills you want to learn',
      'color': '#2ecc71',
      'position': 3072,
    },
    {
      'uuid': 'board_home_004',
      'title': 'Home & Family',
      'description': 'Organize household tasks and family activities',
      'color': '#f39c12',
      'position': 4096,
    },
    {
      'uuid': 'board_health_005',
      'title': 'Health & Fitness',
      'description': 'Track your fitness goals and wellness activities',
      'color': '#9b59b6',
      'position': 5120,
    },
    {
      'uuid': 'board_travel_006',
      'title': 'Travel Planning',
      'description': 'Plan your trips and adventures',
      'color': '#1abc9c',
      'position': 6144,
    },
    {
      'uuid': 'board_finance_007',
      'title': 'Financial Goals',
      'description': 'Budget planning and financial milestones',
      'color': '#34495e',
      'position': 7168,
    },
    {
      'uuid': 'board_creative_008',
      'title': 'Creative Projects',
      'description': 'Art, writing, music, and other creative endeavors',
      'color': '#e67e22',
      'position': 8192,
    },
  ];

  /// Quick setup boards for immediate use
  static List<Map<String, dynamic>> get quickStartBoards => [
    {
      'uuid': 'board_quick_todo',
      'title': 'To-Do List',
      'description': 'Your daily tasks and reminders',
      'color': '#3498db',
      'position': 1024,
    },
    {
      'uuid': 'board_quick_ideas',
      'title': 'Ideas & Notes',
      'description': 'Capture your thoughts and inspiration',
      'color': '#f1c40f',
      'position': 2048,
    },
    {
      'uuid': 'board_quick_goals',
      'title': 'Goals Tracker',
      'description': 'Track your short and long-term goals',
      'color': '#2ecc71',
      'position': 3072,
    },
  ];

  /// Demo boards for showcasing features
  static List<Map<String, dynamic>> get demoBoards => [
    {
      'uuid': 'demo_software_project',
      'title': 'Software Development',
      'description': 'Sample software project with development stages',
      'color': '#3498db',
      'position': 1024,
    },
    {
      'uuid': 'demo_event_planning',
      'title': 'Event Planning',
      'description': 'Plan a wedding, party, or corporate event',
      'color': '#e91e63',
      'position': 2048,
    },
    {
      'uuid': 'demo_content_creation',
      'title': 'Content Creation',
      'description': 'Blog posts, videos, and social media content',
      'color': '#9c27b0',
      'position': 3072,
    },
    {
      'uuid': 'demo_business_launch',
      'title': 'Business Launch',
      'description': 'Steps to launch a new business or product',
      'color': '#ff9800',
      'position': 4096,
    },
  ];

  /// Educational boards for tutorials
  static List<Map<String, dynamic>> get tutorialBoards => [
    {
      'uuid': 'tutorial_kanban_basics',
      'title': 'Kanban Basics Tutorial',
      'description': 'Learn how to use Kanban boards effectively',
      'color': '#607d8b',
      'position': 1024,
    },
    {
      'uuid': 'tutorial_productivity',
      'title': 'Productivity Methods',
      'description': 'Explore different productivity techniques',
      'color': '#795548',
      'position': 2048,
    },
  ];

  /// Convert raw data to Board models
  static List<Board> boardsFromData(List<Map<String, dynamic>> boardsData) {
    return boardsData
        .map(
          (data) => Board(
            uuid: data['uuid'] as String,
            title: data['title'] as String,
            description: data['description'] as String?,
            color: data['color'] as String?,
            position: data['position'] as int? ?? 1024,
            createdAt: DateTime.now().subtract(
              Duration(
                days: boardsData.indexOf(data),
              ), // Stagger creation dates
            ),
          ),
        )
        .toList();
  }

  /// Get sample boards as Board models
  static List<Board> get sampleBoardModels => boardsFromData(sampleBoards);

  /// Get quick start boards as Board models
  static List<Board> get quickStartBoardModels =>
      boardsFromData(quickStartBoards);

  /// Get demo boards as Board models
  static List<Board> get demoBoardModels => boardsFromData(demoBoards);

  /// Get tutorial boards as Board models
  static List<Board> get tutorialBoardModels => boardsFromData(tutorialBoards);

  /// Get all boards combined
  static List<Board> get allSeedBoards => [
    ...quickStartBoardModels,
    ...sampleBoardModels,
  ];

  /// Get minimal set for first-time users
  static List<Board> get starterBoards => quickStartBoardModels;

  /// Get comprehensive set for power users
  static List<Board> get powerUserBoards => [
    ...sampleBoardModels,
    ...demoBoardModels,
  ];

  /// Custom board templates by category
  static Map<String, List<Board>> get boardTemplates => {
    'Personal': [
      ...boardsFromData([
        sampleBoards[0],
        sampleBoards[2],
        sampleBoards[3],
        sampleBoards[4],
      ]),
    ],
    'Professional': [
      ...boardsFromData([
        sampleBoards[1],
        sampleBoards[6],
        demoBoards[0],
        demoBoards[3],
      ]),
    ],
    'Creative': [
      ...boardsFromData([sampleBoards[7], demoBoards[2]]),
    ],
    'Learning': [
      ...boardsFromData([
        sampleBoards[2],
        tutorialBoards[0],
        tutorialBoards[1],
      ]),
    ],
    'Lifestyle': [
      ...boardsFromData([sampleBoards[3], sampleBoards[4], sampleBoards[5]]),
    ],
  };

  /// Generate random board data for testing
  static List<Board> generateRandomBoards(int count) {
    final colors = [
      '#3498db',
      '#e74c3c',
      '#2ecc71',
      '#f39c12',
      '#9b59b6',
      '#1abc9c',
      '#34495e',
      '#e67e22',
      '#f1c40f',
      '#e91e63',
    ];

    final titles = [
      'Project Alpha',
      'Marketing Campaign',
      'Research Tasks',
      'Development Sprint',
      'Customer Feedback',
      'Product Launch',
      'Team Building',
      'Budget Planning',
      'Content Strategy',
      'Quality Assurance',
      'User Testing',
      'Documentation',
    ];

    final descriptions = [
      'Important project milestone tracking',
      'Strategic planning and execution',
      'Research and development tasks',
      'Customer-focused initiatives',
      'Process improvement activities',
      'Creative and innovative projects',
    ];

    return List.generate(count, (index) {
      final randomTitle = titles[index % titles.length];
      final randomColor = colors[index % colors.length];
      final randomDescription = descriptions[index % descriptions.length];

      return Board(
        uuid: 'random_board_${DateTime.now().millisecondsSinceEpoch}_$index',
        title: '$randomTitle ${index + 1}',
        description: randomDescription,
        color: randomColor,
        position: (index + 1) * 1024,
        createdAt: DateTime.now().subtract(Duration(hours: index)),
      );
    });
  }
}
