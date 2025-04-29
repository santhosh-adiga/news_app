import 'package:equatable/equatable.dart';

class News extends Equatable {
  final String id;
  final String title;
  final String description;
  final String source;
  final String? imageUrl;
  final String? content;
  final DateTime publishedAt;

  const News({
    required this.id,
    required this.title,
    required this.description,
    required this.source,
    this.imageUrl,
    this.content,
    required this.publishedAt,
  });

  @override
  List<Object?> get props => [id, title, description, source, imageUrl, content, publishedAt];
}