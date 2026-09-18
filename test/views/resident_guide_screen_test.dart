import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/views/profile/resident_guide_screen.dart';

void main() {
  testWidgets('ResidentGuideScreen renders guides list, search and expansion', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: ResidentGuideScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Banner
    expect(find.text('Resident Handbook'), findsOneWidget);
    expect(find.text('คู่มือและขั้นตอนการใช้งานหอพัก'), findsOneWidget);

    // Verify category chips
    expect(find.text('ทั้งหมด'), findsOneWidget);
    expect(find.text('พัสดุ 📦'), findsOneWidget);
    expect(find.text('ซักผ้า 🧺'), findsOneWidget);

    // Verify guide titles present
    expect(find.text('ขั้นตอนการรับพัสดุ'), findsOneWidget);
    expect(find.text('ขั้นตอนการใช้เครื่องซักผ้าส่วนกลาง'), findsOneWidget);
    expect(find.text('ขั้นตอนการจองห้องอ่านหนังสือและพื้นที่ส่วนกลาง'), findsOneWidget);

    // Test Expand first tile
    await tester.tap(find.text('ขั้นตอนการรับพัสดุ'));
    await tester.pumpAndSettle();

    expect(find.textContaining('นิติรับพัสดุเข้าระบบ'), findsOneWidget);
    expect(find.text('เปิดดูแบบเต็ม (Full Screen)'), findsOneWidget);

    // Test Search filter
    await tester.enterText(find.byType(TextField), 'PromptPay');
    await tester.pumpAndSettle();

    expect(find.text('ขั้นตอนการชำระบิลผ่าน PromptPay'), findsOneWidget);
    expect(find.text('ขั้นตอนการรับพัสดุ'), findsNothing);

    // Test Emergency contacts section
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    final contactsFinder = find.textContaining('Emergency & Contacts');
    await tester.ensureVisible(contactsFinder);
    await tester.pumpAndSettle();

    expect(find.textContaining('เคาน์เตอร์นิติบุคคล'), findsOneWidget);
    expect(find.textContaining('081-999-8888'), findsOneWidget);
  });
}
