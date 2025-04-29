import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/widgets/async_handler.dart';

void main() {
  testWidgets('AsyncHandler shows loading state', (WidgetTester tester) async {
    // Arrange
    const asyncValue = AsyncValue<String>.loading();

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: AsyncHandler<String>(
          value: asyncValue,
          builder: (data) => Text(data),
        ),
      ),
    );

    // Assert
    expect(find.byType(CircularProgressIndicator),
        findsOneWidget); // NFR 5: Unified loading
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('AsyncHandler shows data state', (WidgetTester tester) async {
    // Arrange
    const asyncValue = AsyncValue<String>.data('Test Data');

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: AsyncHandler<String>(
          value: asyncValue,
          builder: (data) => Text(data),
        ),
      ),
    );

    // Assert
    expect(find.text('Test Data'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('AsyncHandler shows error state', (WidgetTester tester) async {
    // Arrange
    final asyncValue =
        AsyncValue<String>.error('Error message', StackTrace.empty);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: AsyncHandler<String>(
          value: asyncValue,
          builder: (data) => Text(data),
        ),
      ),
    );

    // Assert
    expect(find.text('Error: Error message'),
        findsOneWidget); // NFR 5: Unified error
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(Text), findsWidgets); // Error text is a Text widget
  });
}
