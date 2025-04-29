import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:news_app/di/injection_container.dart';
import 'package:news_app/features/news/data/models/news_model.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load .env file
  await Hive.initFlutter();
  Hive.registerAdapter(NewsModelAdapter());
  await initDependencies();
  runApp(const ProviderScope(child: NewsApp()));
}
