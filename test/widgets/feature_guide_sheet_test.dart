import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/models/feature_guide.dart';
import 'package:project/widgets/feature_guide_sheet.dart';

void main() {
  testWidgets('FeatureGuideSheet opens and renders all steps and tips', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showFeatureGuideSheet(context, FeatureGuide.parcelGuide),
              child: const Text('Open Guide'),
            ),
          ),
        ),
      ),
    );

    // Tap button to open sheet
    await tester.tap(find.text('Open Guide'));
    await tester.pumpAndSettle();

    // Verify Title & Subtitle
    expect(find.text('ขั้นตอนการรับพัสดุ'), findsOneWidget);
    expect(find.text('Parcel Pickup'), findsOneWidget);

    // Verify Steps
    expect(find.textContaining('นิติรับพัสดุเข้าระบบ'), findsOneWidget);
    expect(find.textContaining('เปิดบัตรรับพัสดุ'), findsOneWidget);
    expect(find.textContaining('ยืนยันรับของ'), findsOneWidget);

    // Verify Pro-tip
    expect(find.textContaining('นิติเปิดจ่ายพัสดุ'), findsOneWidget);

    // Close sheet
    final closeBtn = find.text('เข้าใจแล้ว (Got It)');
    await tester.ensureVisible(closeBtn);
    await tester.pumpAndSettle();
    await tester.tap(closeBtn);
    await tester.pumpAndSettle();

    expect(find.text('ขั้นตอนการรับพัสดุ'), findsNothing);
  });

  testWidgets('FeatureGuideInlineCard renders compact steps and opens full sheet', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FeatureGuideInlineCard(guide: FeatureGuide.laundryGuide),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify inline card content
    expect(find.text('ขั้นตอนการใช้เครื่องซักผ้าส่วนกลาง'), findsOneWidget);
    expect(find.text('4 ขั้นตอนง่ายๆ ในการใช้งาน'), findsOneWidget);
    expect(find.text('ดูขั้นตอนฉบับเต็ม'), findsOneWidget);

    // Tap full guide link
    await tester.tap(find.text('ดูขั้นตอนฉบับเต็ม'));
    await tester.pumpAndSettle();

    // Modal sheet opens
    expect(find.text('Smart Laundry'), findsOneWidget);
    expect(find.text('เข้าใจแล้ว (Got It)'), findsOneWidget);
  });
}
