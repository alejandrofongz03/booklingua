import 'package:flutter_test/flutter_test.dart';
import 'package:booklingua/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('lightTheme is not null', () {
      final theme = AppTheme.lightTheme;
      expect(theme, isNotNull);
      expect(theme.useMaterial3, isTrue);
    });

    test('darkTheme is not null', () {
      final theme = AppTheme.darkTheme;
      expect(theme, isNotNull);
      expect(theme.useMaterial3, isTrue);
    });

    test('light and dark themes differ', () {
      final light = AppTheme.lightTheme;
      final dark = AppTheme.darkTheme;
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
    });
  });
}
