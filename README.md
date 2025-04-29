# News App

A Flutter-based news application built with **Clean Architecture**, **SOLID principles**, and **Riverpod** for state management. The app fetches news articles from [NewsAPI](https://newsapi.org/), supports search, category sorting, bookmarking, and tabbed navigation (All News, Sports, Tech, Bookmarks). It includes a detailed news page and adheres to 10 non-functional requirements (NFRs) for robustness and scalability.

This README provides an overview of the app's folder structure, architecture, best practices, setup instructions, and testing strategy.

## Features

- **News List**: Displays recent news with search and category filtering (e.g., general, business, entertainment).
- **Tabs**: Navigate between All News, Sports News, Tech News, and Bookmarked News.
- **Search**: Filter news by keyword.
- **Bookmarks**: Save and view favorite articles locally.
- **News Detail Page**: View full article details with bookmark toggle.
- **Offline Support**: Displays cached news when offline.
- **Environment**: Stores API key securely in a `.env` file.

## Folder Structure

The project follows a modular, feature-based structure aligned with Clean Architecture:

```
news_app/
├── lib/
│   ├── core/
│   │   ├── error/
│   │   │   └── failures.dart
│   │   ├── network/
│   │   │   └── network_info.dart
│   │   └── widgets/
│   │       └── async_handler.dart
│   ├── features/
│   │   └── news/
│   │       ├── data/
│   │       │   ├── datasources/
│   │       │   │   ├── news_local_data_source.dart
│   │       │   │   └── news_remote_data_source.dart
│   │       │   ├── models/
│   │       │   │   └── news_model.dart
│   │       │   └── repositories/
│   │       │       └── news_repository_impl.dart
│   │       ├── domain/
│   │       │   ├── entities/
│   │       │   │   └── news.dart
│   │       │   ├── repositories/
│   │       │   │   └── news_repository.dart
│   │       │   └── usecases/
│   │       │       ├── add_bookmark.dart
│   │       │       ├── get_bookmarks.dart
│   │       │       ├── get_news.dart
│   │       │       └── remove_bookmark.dart
│   │       └── presentation/
│   │           ├── providers/
│   │           │   ├── bookmark_provider.dart
│   │           │   └── news_provider.dart
│   │           ├── screens/
│   │           │   ├── news_detail_screen.dart
│   │           │   └── news_list_screen.dart
│   │           └── widgets/
│   │               ├── news_tile.dart
│   │               └── tabbed_news_view.dart
│   ├── di/
│   │   └── injection_container.dart
│   └── main.dart
├── test/
│   ├── core/
│   ├── features/
│   │   └── news/
│   ├── fixtures/
│   └── test_utils.dart
├── .env
├── pubspec.yaml
├── README.md


```


### Structure Explanation

- **lib/core/**: Shared utilities across features.
  - `error/failures.dart`: Defines failure classes for error handling.
  - `network/network_info.dart`: Handles network connectivity checks.
  - `widgets/async_handler.dart`: Reusable widget for unified loading/error states (NFR 5).
- **lib/features/news/**: News feature, organized by Clean Architecture layers.
  - **data/**: Handles data operations (API, local storage).
    - `datasources/`: Remote (NewsAPI) and local (Hive) data sources.
    - `models/`: `NewsModel` for serialization.
    - `repositories/`: `NewsRepositoryImpl` combines data sources.
  - **domain/**: Business logic, framework-agnostic.
    - `entities/`: `News` entity for news articles.
    - `repositories/`: Abstract `NewsRepository` interface.
    - `usecases/`: Use cases for fetching news, bookmarks, and CRUD operations.
  - **presentation/**: UI and state management.
    - `providers/`: Riverpod providers for news and bookmarks.
    - `screens/`: Main screens (news list, detail).
    - `widgets/`: Reusable UI components (news tile, tabbed view).
- **lib/di/**: Dependency injection setup using a simple `GetIt` implementation.
- **lib/main.dart**: App entry point, initializes Hive and Riverpod.
- **test/**: Unit tests mirroring the `lib/` structure, with fixtures for mocking API responses.
- **.env**: Stores the NewsAPI key securely.
- **pubspec.yaml**: Lists dependencies (e.g., `flutter_riverpod`, `hive`, `connectivity_plus`).

## Architecture

The app follows **Clean Architecture**, dividing the codebase into three layers to ensure separation of concerns, testability, and scalability:

1. **Presentation Layer**:
   - Contains UI (`screens/`, `widgets/`) and state management (`providers/`).
   - Uses **Riverpod** for reactive state management, with `NewsNotifier` and `BookmarkNotifier` handling news and bookmark states.
   - Widgets watch providers to redraw on data changes (NFR 4).
   - Avoids direct API calls, relying on use cases (NFR 3).

2. **Domain Layer**:
   - Core business logic, independent of frameworks.
   - Includes `News` entity, `NewsRepository` interface, and use cases (`GetNews`, `GetBookmarks`, `AddBookmark`, `RemoveBookmark`).
   - Use cases encapsulate single responsibilities (e.g., fetching news), adhering to SOLID principles.

3. **Data Layer**:
   - Manages data operations (API, local storage).
   - `NewsRemoteDataSourceImpl` fetches news from NewsAPI.
   - `NewsLocalDataSourceImpl` caches news and bookmarks using Hive.
   - `NewsRepositoryImpl` combines data sources, handles caching (NFR 2), and provides offline support (NFR 7).

### SOLID Principles

- **Single Responsibility**: Each class has one job (e.g., `GetNews` fetches news, `NewsTile` renders UI).
- **Open/Closed**: The `NewsRepository` interface allows new data sources without modifying existing code.
- **Liskov Substitution**: `NewsRepositoryImpl` can be mocked without breaking use cases.
- **Interface Segregation**: `NewsRepository` exposes only necessary methods.
- **Dependency Inversion**: Use cases depend on abstractions (`NewsRepository`), not implementations.

### Riverpod

- **Scoped Providers**: `newsProvider` and `bookmarkProvider` are scoped to the news feature, reducing memory leaks.
- **Type Safety**: Ensures compile-time dependency checks.
- **Reactive State**: Widgets rebuild automatically on state changes (NFR 4).
- **Dependency Injection**: Providers inject use cases and repositories (via `GetIt`).

## Best Practices (10 NFRs)

The app implements the following non-functional requirements as best practices:

1. **Data Retention or Reset Based on Page Context**:
   - `newsProvider` uses `autoDispose` to reset state when the news list screen is popped, while bookmarks persist via Hive.

2. **Data Retention for 10 Minutes**:
   - `NewsRepositoryImpl` caches news for 10 minutes using a timestamp and cache key, reducing API calls.

3. **No API Calls from UI**:
   - UI widgets interact with providers, which trigger use cases, keeping API calls in the data layer.

4. **UI Watches Data Changes and Redraws**:
   - Widgets use `ref.watch` to reactively update on provider state changes.

5. **Unified Data Loading and Error Handling**:
   - `AsyncHandler` widget standardizes loading and error states across the app.

6. **Cancel Data Requests on Page Exit**:
   - `newsProvider` uses a `CancelToken` to cancel API requests when the screen is disposed.

7. **Show Previously Fetched Data Offline**:
   - `NewsRepositoryImpl` falls back to cached news when offline.

8. **Auto-Retry on Network Restoration**:
   - `NewsNotifier` listens to `Connectivity` changes and retries fetching news when the network is restored.

9. **Minimize UI Rebuilds for List Data**:
   - `NewsTile` uses `ValueKey(news.id)` with `ListView.builder` to optimize rendering.

10. **Flexible State Declaration**:
    - Riverpod providers allow global or scoped state access, supporting features like search and bookmarks.
