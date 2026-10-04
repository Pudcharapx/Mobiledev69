import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_service.dart';

/// Extension on BuildContext providing instant localized string lookups and language reactivity.
extension TranslationExtension on BuildContext {
  LanguageService? get languageService {
    try {
      return Provider.of<LanguageService>(this, listen: true);
    } catch (_) {
      return null;
    }
  }

  bool get isThai => languageService?.isThai ?? false;

  /// Returns [th] if Thai is active, otherwise [en].
  String tr(String en, String th) => isThai ? th : en;
}

/// Common app-wide translations for UI components.
class AppTranslations {
  AppTranslations._();

  // Bottom Navigation
  static String navHome(bool isThai) => isThai ? 'หน้าแรก' : 'Home';
  static String navExpenses(bool isThai) => isThai ? 'ค่าใช้จ่าย' : 'Expenses';
  static String navMaintenance(bool isThai) => isThai ? 'แจ้งซ่อม' : 'Maintenance';
  static String navAnnounce(bool isThai) => isThai ? 'ประกาศ' : 'Announce';
  static String navProfile(bool isThai) => isThai ? 'โปรไฟล์' : 'Profile';

  // Common Actions
  static String save(bool isThai) => isThai ? 'บันทึก' : 'Save';
  static String cancel(bool isThai) => isThai ? 'ยกเลิก' : 'Cancel';
  static String confirm(bool isThai) => isThai ? 'ยืนยัน' : 'Confirm';
  static String close(bool isThai) => isThai ? 'ปิด' : 'Close';
  static String done(bool isThai) => isThai ? 'เสร็จสิ้น' : 'Done';
  static String search(bool isThai) => isThai ? 'ค้นหา' : 'Search';
  static String all(bool isThai) => isThai ? 'ทั้งหมด' : 'All';
  static String active(bool isThai) => isThai ? 'ดำเนินการ' : 'Active';
  static String pending(bool isThai) => isThai ? 'รอดำเนินการ' : 'Pending';

  // Greeting
  static String greetingMorning(bool isThai) => isThai ? 'สวัสดีตอนเช้า' : 'Good morning';
  static String greetingAfternoon(bool isThai) => isThai ? 'สวัสดีตอนบ่าย' : 'Good afternoon';
  static String greetingEvening(bool isThai) => isThai ? 'สวัสดีตอนเย็น' : 'Good evening';
}
