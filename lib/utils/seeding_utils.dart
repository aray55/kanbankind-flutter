import 'package:get/get.dart';
import 'package:kanbankit/core/utils/logger/app_logger.dart';
import '../core/services/database_seeder_service.dart';
import '../core/services/storage_service.dart';

/// Utility class for easy database seeding
class SeedingUtils {
  /// Initialize and run seeding if needed
  static Future<void> initializeSeeding() async {
    try {
      // Ensure storage service is available
      if (!Get.isRegistered<StorageService>()) {
        await Get.putAsync(() => StorageService().init());
      }

      final seeder = DatabaseSeederService();

      // Check if we need to seed
      if (!seeder.isSeeded) {
        AppLogger.info('🌱 First time setup - seeding database...');
        await seeder.seedQuickStart();

        // Verify seeding worked
        final stats = await seeder.getSeedingStats();
        final boardsCount = stats['boardsCount']?['active'] ?? 0;
        AppLogger.info('📋 Seeding completed. Active boards: $boardsCount');
      } else {
        AppLogger.info('✅ Database already seeded');

        // Show current stats
        final stats = await seeder.getSeedingStats();
        final boardsCount = stats['boardsCount']?['active'] ?? 0;
        AppLogger.info('📋 Current active boards: $boardsCount');
      }
    } catch (e) {
      AppLogger.error('❌ Seeding initialization failed: $e');
      // Don't throw - app should still work without seeding
    }
  }

  /// Force reseed for development
  static Future<void> developmentReseed() async {
    try {
      await Get.putAsync(() => StorageService().init());
      final seeder = DatabaseSeederService();
      await seeder.resetAndSeed(seedType: 'sample');
    } catch (e) {
      AppLogger.error('❌ Development reseed failed: $e');
    }
  }

  /// Quick start seeding
  static Future<void> quickSeed() async {
    try {
      await Get.putAsync(() => StorageService().init());
      final seeder = DatabaseSeederService();
      await seeder.seedQuickStart();
    } catch (e) {
      AppLogger.error('❌ Quick seed failed: $e');
    }
  }
}
