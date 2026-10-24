// Shared helpers for the widget tests.
//
// The app keeps its state in two singletons, so every test starts by
// putting them back to their starting state.

import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Puts the app back to the state a fresh install is in.
void resetAppState() {
  appStore.reset();
  appRepository.reset();
}

/// Gives the test a viewport tall enough to show a whole screen.
///
/// The prototype was designed for a 390 × 844 phone. A taller viewport
/// means the content does not have to be scrolled to be found, which
/// keeps the tests about behaviour rather than about scrolling.
///
/// The width is wider than a phone on purpose. Widget tests draw every
/// character as a fixed-size box, so the text is much wider than it is on
/// a device and long labels would otherwise overflow. The layout itself is
/// the same.
void useTallScreen(WidgetTester tester, {Size size = const Size(560, 2400)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Waits for the screen to settle, but gives up after a few seconds.
///
/// `pumpAndSettle` waits for ten minutes by default, which is a long
/// time to hang when a text field keeps blinking its cursor.
Future<void> settle(WidgetTester tester) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 50),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 5),
  );
}

/// Types into a field and lets the screen redraw.
///
/// The cursor of a focused field keeps scheduling frames, so this uses
/// `pump` rather than waiting for everything to settle.
Future<void> typeInto(
  WidgetTester tester,
  String hint,
  String text,
) async {
  await tester.enterText(find.widgetWithText(TextField, hint), text);
  await tester.pump();
}
