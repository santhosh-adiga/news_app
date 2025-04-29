import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/features/news/domain/entities/news.dart';
import 'package:news_app/features/news/presentation/providers/bookmark_provider.dart';

class NewsTile extends ConsumerWidget {
  final News news;
  final VoidCallback? onTap;

  const NewsTile({super.key, required this.news, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked =
        ref.watch(bookmarkProvider.select((state) => state.when(
              data: (bookmarks) => bookmarks.any((item) => item.id == news.id),
              loading: () => false,
              error: (_, __) => false,
            )));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: news.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: news.imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              : const Icon(Icons.article, size: 80),
          title: Text(
            news.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(news.source),
              const SizedBox(height: 4),
              Text(
                news.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${news.publishedAt.toLocal()}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () {
              if (isBookmarked) {
                ref.read(bookmarkProvider.notifier).remove(news.id);
              } else {
                ref.read(bookmarkProvider.notifier).add(news);
              }
            },
          ),
        ),
      ),
    );
  }
}
