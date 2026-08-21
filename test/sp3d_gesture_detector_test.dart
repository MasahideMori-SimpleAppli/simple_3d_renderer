import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_3d_renderer/simple_3d_renderer.dart';

/// タッチスロップの動作テスト。
/// スロップ未満の移動でパン扱いにならないこと（タップが維持されること）を確認します。
void main() {
  late List<String> log;

  Widget wrap(Widget child, {DeviceGestureSettings? gestureSettings}) {
    final Widget r = MaterialApp(home: Scaffold(body: Center(child: child)));
    if (gestureSettings == null) {
      return r;
    }
    return MediaQuery(
        data: MediaQueryData(gestureSettings: gestureSettings), child: r);
  }

  Sp3dGestureDetector target({double? touchSlop}) {
    return Sp3dGestureDetector(
      onPanDown: (Sp3dGestureDetails d) => log.add("down"),
      onPanCancel: () => log.add("cancel"),
      onPanStart: (Sp3dGestureDetails d) => log.add("start"),
      onPanUpdate: (Sp3dGestureDetails d) => log.add("update"),
      onPanEnd: (Sp3dGestureDetails d) => log.add("end"),
      touchSlop: touchSlop,
      child: const SizedBox(width: 400, height: 400),
    );
  }

  setUp(() {
    log = [];
  });

  testWidgets('A tap without movement is a tap', (WidgetTester tester) async {
    await tester.pumpWidget(wrap(target()));
    final TestGesture g = await tester.startGesture(const Offset(200, 200));
    await g.up();
    expect(log, ["down", "cancel"]);
  });

  testWidgets('A move smaller than the slop keeps the tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrap(target()));
    final TestGesture g = await tester.startGesture(const Offset(200, 200));
    // kTouchSlop is 18.0. Repeat minute movements as a real device does.
    for (int i = 0; i < 5; i++) {
      await g.moveBy(const Offset(1, 0));
    }
    await g.up();
    expect(log, ["down", "cancel"]);
  });

  testWidgets('A move larger than the slop becomes a pan',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrap(target()));
    final TestGesture g = await tester.startGesture(const Offset(200, 200));
    await g.moveBy(const Offset(30, 0));
    await g.moveBy(const Offset(30, 0));
    await g.up();
    expect(log, ["down", "start", "update", "end"]);
  });

  testWidgets('The pan start position is the current pointer position',
      (WidgetTester tester) async {
    late Sp3dGestureDetails startDetails;
    await tester.pumpWidget(wrap(Sp3dGestureDetector(
      onPanStart: (Sp3dGestureDetails d) => startDetails = d,
      child: const SizedBox(width: 400, height: 400),
    )));
    final TestGesture g = await tester.startGesture(const Offset(200, 200));
    // Minute movements must not shift the pan start position.
    await g.moveBy(const Offset(2, 0));
    await g.moveBy(const Offset(30, 0));
    await g.up();
    // These are local positions in the child widget.
    expect(startDetails.nowV.x, 32.0);
    expect(startDetails.startV.x, 0.0);
  });

  testWidgets('touchSlop 0 restores the old behavior',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrap(target(touchSlop: 0)));
    final TestGesture g = await tester.startGesture(const Offset(200, 200));
    await g.moveBy(const Offset(1, 0));
    await g.moveBy(const Offset(1, 0));
    await g.up();
    expect(log, ["down", "start", "update", "end"]);
  });

  testWidgets('The platform value from MediaQuery is used',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrap(target(),
        gestureSettings: const DeviceGestureSettings(touchSlop: 8)));
    final TestGesture g = await tester.startGesture(const Offset(200, 200));
    // Larger than 8 and smaller than kTouchSlop(18).
    await g.moveBy(const Offset(12, 0));
    await g.up();
    expect(log, ["down", "start", "end"]);
  });

  testWidgets('A mouse uses the precise pointer slop',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrap(target()));
    final TestGesture g = await tester.startGesture(const Offset(200, 200),
        kind: PointerDeviceKind.mouse);
    // Larger than kPrecisePointerHitSlop(1.0) and smaller than kTouchSlop(18).
    await g.moveBy(const Offset(3, 0));
    await g.up();
    expect(log, ["down", "start", "end"]);
  });
}
