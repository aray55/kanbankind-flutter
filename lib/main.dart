import 'package:flutter/material.dart';
import 'package:kanbankit/app.dart';
import 'core/services/service_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeServices();
  runApp(const KanbanKitApp());
}
