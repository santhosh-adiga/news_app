import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/core/widgets/async_handler.dart';
import 'package:news_app/features/news/domain/entities/news.dart';
import 'package:news_app/features/news/presentation/providers/bookmark_provider.dart';
import 'package:news_app/features/news/presentation/providers/news_provider.dart';
import 'package:news_app/features/news/presentation/screens/news_detail_screen.dart';
import 'package:news_app/features/news/presentation/widgets/news_tile.dart';

class TabbedNewsView extends ConsumerStatefulWidget {
  const TabbedNewsView({super.key});

  @override
  ConsumerState<TabbedNewsView> createState() => _TabbedNewsViewState();
}

class _TabbedNewsViewState extends ConsumerState<TabbedNewsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(newsProvider.notifier).setQuery(query);
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category ?? '';
      ref.read(newsProvider.notifier).setCategory(_selectedCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    final newsState = ref.watch(newsProvider); // NFR 4: UI watches data

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('News App'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Sports'),
              Tab(text: 'Tech'),
              Tab(text: 'Bookmarks'),
            ],
            onTap: (index) {
              if (index == 0) {
                ref.read(newsProvider.notifier).setCategory('');
              } else if (index == 1) {
                ref.read(newsProvider.notifier).setCategory('sports');
              } else if (index == 2) {
                ref.read(newsProvider.notifier).setCategory('technology');
              }
              _searchController.clear();
              ref.read(newsProvider.notifier).setQuery('');
            },
          ),
        ),
        body: Column(
          children: [
            if (_tabController.index != 3) // Hide search/filter for Bookmarks
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search news...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value:
                          _selectedCategory.isEmpty ? null : _selectedCategory,
                      hint: const Text('Category'),
                      items: const [
                        DropdownMenuItem(value: '', child: Text('All')),
                        DropdownMenuItem(
                            value: 'business', child: Text('Business')),
                        DropdownMenuItem(
                            value: 'entertainment',
                            child: Text('Entertainment')),
                        DropdownMenuItem(
                            value: 'health', child: Text('Health')),
                      ],
                      onChanged: _onCategoryChanged,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // All News
                  _buildNewsList(newsState, ref),
                  // Sports News
                  _buildNewsList(newsState, ref),
                  // Tech News
                  _buildNewsList(newsState, ref),
                  // Bookmarks
                  _buildBookmarkList(ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsList(AsyncValue<List<News>> newsState, WidgetRef ref) {
    return AsyncHandler<List<News>>(
      value: newsState,
      builder: (news) => RefreshIndicator(
        onRefresh: () => ref.read(newsProvider.notifier).refresh(),
        child: ListView.builder(
          itemCount: news.length,
          itemBuilder: (context, index) {
            final item = news[index];
            return NewsTile(
              key: ValueKey(item.id), // NFR 9: Minimize rebuilds
              news: item,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NewsDetailScreen(news: item),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookmarkList(WidgetRef ref) {
    final bookmarkState = ref.watch(bookmarkProvider);
    return AsyncHandler<List<News>>(
      value: bookmarkState,
      builder: (bookmarks) => ListView.builder(
        itemCount: bookmarks.length,
        itemBuilder: (context, index) {
          final item = bookmarks[index];
          return NewsTile(
            key: ValueKey(item.id),
            news: item,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NewsDetailScreen(news: item),
              ),
            ),
          );
        },
      ),
    );
  }
}
