import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:booklingua/app.dart';

void main() {
  testWidgets('BookLinguaApp renders without error', (tester) async {
    await tester.pumpWidget(const BookLinguaApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
