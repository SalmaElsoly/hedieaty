import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty/shared/theme.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// Mock class for SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('ThemeColorData Tests', () {
    late MockSharedPreferences mockSharedPreferences;
    late ThemeColorData themeColorData;

    setUp(() {
      // Initialize mock SharedPreferences
      mockSharedPreferences = MockSharedPreferences();
      themeColorData = ThemeColorData(mockSharedPreferences);
    });

    test('should load theme from SharedPreferences', () async {
      // Arrange: Mock the theme data to be true (dark theme)
      SharedPreferences.setMockInitialValues({'themeData': true});
      final prefs = await SharedPreferences.getInstance();
      themeColorData = ThemeColorData(prefs);

      // Act: Load the theme from SharedPreferences
      await themeColorData.loadThemeFromSharedPref();

      // Assert: Verify that the theme is dark
      expect(themeColorData.isDark, isTrue);
    });

    test('should default to dark theme if no theme is saved', () async {
      // Arrange: Mock that no theme is saved (returns null)
      SharedPreferences.setMockInitialValues(
          {}); // Initialize empty mock values
      when(mockSharedPreferences.getBool('themeData')).thenReturn(null);

      // Act: Load the theme from SharedPreferences
      await themeColorData.loadThemeFromSharedPref();

      // Assert: Verify that the default theme is dark
      expect(themeColorData.isDark, isTrue);
    });

    test('should toggle theme correctly', () async {
      // Arrange: Mock the initial theme state to be light (false)
      SharedPreferences.setMockInitialValues(
          {'themeData': false}); // Initialize mock values
      final prefs = await SharedPreferences.getInstance();
      themeColorData = ThemeColorData(prefs);
      await themeColorData.loadThemeFromSharedPref();

      // Act: Toggle the theme
      themeColorData.toggleTheme();

      // Assert: Verify that the theme state is now dark (true)
      expect(themeColorData.isDark, isTrue);

      // Act: Toggle again
      themeColorData.toggleTheme();

      // Assert: Verify that the theme state is now light again (false)
      expect(themeColorData.isDark, isFalse);
    });
    testWidgets('should notify listeners when theme changes',
        (WidgetTester tester) async {
      // Arrange: Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues(
          {'themeData': false}); // Initialize mock values
      final prefs = await SharedPreferences.getInstance();
      themeColorData = ThemeColorData(prefs);
      await themeColorData.loadThemeFromSharedPref();

      // Act: Build the widget with ChangeNotifierProvider
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeColorData>(
          create: (_) => themeColorData,
          child: MaterialApp(
            home: Scaffold(
              body: Consumer<ThemeColorData>(
                builder: (context, theme, child) {
                  return Text(theme.isDark ? 'Dark Theme' : 'Light Theme');
                },
              ),
            ),
          ),
        ),
      );

      // Assert: Verify that the theme text is correct (Light Theme)
      expect(find.text('Light Theme'), findsOneWidget);

      // Act: Toggle the theme
      themeColorData.toggleTheme();
      await tester.pump(); // Trigger a rebuild

      // Assert: Verify that the theme text is now correct (Dark Theme)
      expect(find.text('Dark Theme'), findsOneWidget);
    });
  });
}
