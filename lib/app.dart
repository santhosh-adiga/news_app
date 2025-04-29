import 'package:flutter/material.dart';

import 'features/news/presentation/screens/news_list_screen.dart';

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NewsListScreen(),
    );
  }
}
