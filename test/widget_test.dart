import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audiomack/main.dart';

void main() {
  testWidgets('La app se construye sin errores', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
  });
}