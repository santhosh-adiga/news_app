import 'package:hive/hive.dart';
import 'package:news_app/features/news/domain/entities/news.dart';

part 'news_model.g.dart';

@HiveType(typeId: 0)
class NewsModel extends News {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String source;
  @HiveField(4)
  final String? imageUrl;
  @HiveField(5)
  final String? content;
  @HiveField(6)
  final DateTime publishedAt;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.source,
    this.imageUrl,
    this.content,
    required this.publishedAt,
  }) : super(
    id: id,
    title: title,
    description: description,
    source: source,
    imageUrl: imageUrl,
    content: content,
    publishedAt: publishedAt,
  );

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['url'] ?? json['title'].hashCode.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      source: json['source']['name'] ?? 'Unknown',
      imageUrl: json['urlToImage'],
      content: json['content'],
      publishedAt: DateTime.parse(json['publishedAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'source': source,
      'urlToImage': imageUrl,
      'content': content,
      'publishedAt': publishedAt.toIso8601String(),
    };
  }
}