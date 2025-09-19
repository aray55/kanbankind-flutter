import 'package:flutter/material.dart';
import 'package:kanbankit/app.dart';
import 'core/services/service_initializer.dart';
import 'utils/seeding_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  await initializeServices();

  // Initialize database seeding
  await SeedingUtils.initializeSeeding();

  runApp(const KanbanKitApp());
}
