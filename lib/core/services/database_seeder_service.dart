import 'package:get/get.dart';
import '../../data/seeds/board_seeds.dart';
import '../../data/repository/board_repository.dart';
import '../../core/services/storage_service.dart';
import '../../models/board_model.dart';

/// Service for seeding database with initial data
class DatabaseSeederService {
  static const String _seedKey = 'database_seeded';
  static const String _seedVersionKey = 'seed_version';
  static const int _currentSeedVersion = 1;

  final BoardRepository _boardRepository = BoardRepository();
  final StorageService _storageService = Get.find<StorageService>();

  /// Check if database has been seeded
  bool get isSeeded => _storageService.read(_seedKey) ?? false;

  /// Get current seed version
  int get seedVersion => _storageService.read(_seedVersionKey) ?? 0;

  /// Seed database with initial data if not already seeded
  Future<void> seedIfNeeded() async {
    if (!isSeeded || seedVersion < _currentSeedVersion) {
      await seedDatabase();
    }
  }

  /// Force seed database (useful for development)
  Future<void> seedDatabase() async {
    try {
      print('🌱 Starting database seeding...');

      // Clear existing boards (for development)
      await _clearExistingBoards();

      // Seed boards
      await _seedBoards();

      // Mark as seeded
      await _markAsSeeded();

      print('✅ Database seeding completed successfully!');
    } catch (e) {
      print('❌ Database seeding failed: $e');
      rethrow;
    }
  }

  /// Seed with quick start boards (minimal setup)
  Future<void> seedQuickStart() async {
    try {
      print('🚀 Seeding quick start boards...');

      final boards = BoardSeeds.starterBoards;
      await _createBoards(boards);

      await _markAsSeeded();
      print('✅ Quick start seeding completed!');
    } catch (e) {
      print('❌ Quick start seeding failed: $e');
      rethrow;
    }
  }

  /// Seed with sample boards (full setup)
  Future<void> seedSampleData() async {
    try {
      print('📚 Seeding sample boards...');

      final boards = BoardSeeds.sampleBoardModels;
      await _createBoards(boards);

      await _markAsSeeded();
      print('✅ Sample data seeding completed!');
    } catch (e) {
      print('❌ Sample data seeding failed: $e');
      rethrow;
    }
  }

  /// Seed with demo boards (showcase features)
  Future<void> seedDemoData() async {
    try {
      print('🎬 Seeding demo boards...');

      final boards = BoardSeeds.demoBoardModels;
      await _createBoards(boards);

      await _markAsSeeded();
      print('✅ Demo data seeding completed!');
    } catch (e) {
      print('❌ Demo data seeding failed: $e');
      rethrow;
    }
  }

  /// Seed boards by category
  Future<void> seedByCategory(String category) async {
    try {
      print('📂 Seeding $category boards...');

      final templates = BoardSeeds.boardTemplates;
      if (!templates.containsKey(category)) {
        throw Exception('Category "$category" not found');
      }

      final boards = templates[category]!;
      await _createBoards(boards);

      print('✅ $category boards seeded successfully!');
    } catch (e) {
      print('❌ $category seeding failed: $e');
      rethrow;
    }
  }

  /// Generate random test data
  Future<void> seedRandomData({int count = 10}) async {
    try {
      print('🎲 Generating $count random boards...');

      final boards = BoardSeeds.generateRandomBoards(count);
      await _createBoards(boards);

      print('✅ Random data generated successfully!');
    } catch (e) {
      print('❌ Random data generation failed: $e');
      rethrow;
    }
  }

  /// Reset database and reseed
  Future<void> resetAndSeed({String seedType = 'quick'}) async {
    try {
      print('🔄 Resetting and reseeding database...');

      // Clear seeded flag
      await _clearSeedFlags();

      // Seed based on type
      switch (seedType.toLowerCase()) {
        case 'quick':
          await seedQuickStart();
          break;
        case 'sample':
          await seedSampleData();
          break;
        case 'demo':
          await seedDemoData();
          break;
        case 'full':
          await seedDatabase();
          break;
        default:
          await seedQuickStart();
      }

      print('✅ Reset and reseed completed!');
    } catch (e) {
      print('❌ Reset and reseed failed: $e');
      rethrow;
    }
  }

  /// Get seeding statistics
  Future<Map<String, dynamic>> getSeedingStats() async {
    try {
      final stats = await _boardRepository.getBoardsStatistics();
      return {
        'isSeeded': isSeeded,
        'seedVersion': seedVersion,
        'currentVersion': _currentSeedVersion,
        'boardsCount': stats,
        'availableCategories': BoardSeeds.boardTemplates.keys.toList(),
        'lastSeeded': _storageService.read('last_seeded'),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'isSeeded': isSeeded,
        'seedVersion': seedVersion,
      };
    }
  }

  // Private helper methods

  Future<void> _seedBoards() async {
    // Start with quick start boards
    final quickBoards = BoardSeeds.starterBoards;
    await _createBoards(quickBoards);

    print('📋 Created ${quickBoards.length} starter boards');

    // Add some sample boards for variety
    final sampleBoards = BoardSeeds.sampleBoardModels.take(3).toList();
    await _createBoards(sampleBoards);

    print('📋 Created ${sampleBoards.length} sample boards');
  }

  Future<void> _createBoards(List<Board> boards) async {
    print('📋 Creating ${boards.length} boards...');

    for (final board in boards) {
      try {
        await _boardRepository.createBoard(
          uuid: board.uuid,
          title: board.title,
          description: board.description,
          color: board.color,
        );
        print('✅ Created board: ${board.title}');
      } catch (e) {
        print('⚠️ Failed to create board "${board.title}": $e');
        // Continue with other boards
      }
    }

    print('📋 Finished creating boards');
  }

  Future<void> _clearExistingBoards() async {
    try {
      // Only clear in development mode
      if (_isDevelopmentMode()) {
        final stats = await _boardRepository.getBoardsStatistics();
        final totalBoards = stats['active']! + stats['archived']!;

        if (totalBoards > 0) {
          print('🧹 Clearing $totalBoards existing boards...');
          // Note: Implement clearAllBoards in repository if needed
          // await _boardRepository.clearAllBoards();
        }
      }
    } catch (e) {
      print('⚠️ Failed to clear existing boards: $e');
      // Continue with seeding
    }
  }

  Future<void> _markAsSeeded() async {
    await _storageService.write(_seedKey, true);
    await _storageService.write(_seedVersionKey, _currentSeedVersion);
    await _storageService.write(
      'last_seeded',
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> _clearSeedFlags() async {
    await _storageService.remove(_seedKey);
    await _storageService.remove(_seedVersionKey);
    await _storageService.remove('last_seeded');
  }

  bool _isDevelopmentMode() {
    // Check if in development mode
    return true; // For now, always true. You can implement proper environment detection
  }

  /// Available seeding options for UI
  static List<Map<String, dynamic>> get seedingOptions => [
    {
      'key': 'quick',
      'title': 'Quick Start',
      'description': 'Essential boards to get started',
      'icon': '🚀',
      'boardCount': BoardSeeds.starterBoards.length,
    },
    {
      'key': 'sample',
      'title': 'Sample Data',
      'description': 'Comprehensive set of example boards',
      'icon': '📚',
      'boardCount': BoardSeeds.sampleBoardModels.length,
    },
    {
      'key': 'demo',
      'title': 'Demo Data',
      'description': 'Showcase boards with advanced features',
      'icon': '🎬',
      'boardCount': BoardSeeds.demoBoardModels.length,
    },
    {
      'key': 'categories',
      'title': 'By Category',
      'description': 'Choose specific board categories',
      'icon': '📂',
      'boardCount': BoardSeeds.boardTemplates.length,
    },
  ];
}
