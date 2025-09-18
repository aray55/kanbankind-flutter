import 'dart:io';

/// سكربت لتوليد ملف .env.example من أي ملف .env موجود.
/// - يستبدل القيم بـ `YOUR_VALUE_HERE`
/// - يضع قيم افتراضية لبعض المتغيرات الشائعة.
void main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ Usage: dart run tools/generate_env_example.dart <path_to_env_file>');
    exit(1);
  }

  final inputPath = args[0];
  final inputFile = File(inputPath);

  if (!await inputFile.exists()) {
    print('❌ File not found: $inputPath');
    exit(1);
  }

  final lines = await inputFile.readAsLines();
  final outputPath = '$inputPath.example';
  final outputFile = File(outputPath);

  final Map<String, String> defaults = {
    'API_URL': 'http://localhost:3000',
    'DEBUG_MODE': 'true',
    'ENVIRONMENT': 'development',
  };

  final newLines = lines.map((line) {
    if (line.trim().isEmpty || line.trim().startsWith('#')) {
      return line;
    }

    final parts = line.split('=');
    if (parts.length >= 2) {
      final key = parts[0].trim();
      final defaultValue = defaults[key] ?? 'YOUR_VALUE_HERE';
      return '$key=$defaultValue';
    }
    return line;
  }).toList();

  await outputFile.writeAsString(newLines.join('\n'));

  print('✅ Example file generated: $outputPath');
}
