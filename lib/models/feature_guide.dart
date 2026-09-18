import 'package:flutter/material.dart';

class FeatureGuideStep {
  final int stepNumber;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const FeatureGuideStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class FeatureGuide {
  final String id;
  final String title;
  final String titleTh;
  final String subtitle;
  final IconData headerIcon;
  final Color headerColor;
  final List<FeatureGuideStep> steps;
  final String? tip;

  const FeatureGuide({
    required this.id,
    required this.title,
    required this.titleTh,
    required this.subtitle,
    required this.headerIcon,
    required this.headerColor,
    required this.steps,
    this.tip,
  });

  // 1. Parcel Pickup Guide
  static const FeatureGuide parcelGuide = FeatureGuide(
    id: 'parcel',
    title: 'Parcel Pickup',
    titleTh: 'ขั้นตอนการรับพัสดุ',
    subtitle: 'รับพัสดุได้สะดวกรวดเร็วด้วย QR Code หรือ PIN 4 หลัก',
    headerIcon: Icons.inventory_2_rounded,
    headerColor: Color(0xFF059669),
    tip: 'นิติเปิดจ่ายพัสดุเวลา 08:30 - 20:30 น. ทุกวัน โปรดนำ QR Code หรือ PIN ยื่นเพื่อความรวดเร็ว',
    steps: [
      FeatureGuideStep(
        stepNumber: 1,
        title: 'นิติรับพัสดุเข้าระบบ (Arrived & Logged)',
        description: 'เมื่อบริษัทขนส่งมาส่งพัสดุ เจ้าหน้าที่จะคัดแยก ระบุตำแหน่งล็อกเกอร์/ชั้นวาง และบันทึกเข้าห้องคุณ',
        icon: Icons.local_shipping_rounded,
        color: Color(0xFFF59E0B),
      ),
      FeatureGuideStep(
        stepNumber: 2,
        title: 'รับการแจ้งเตือน & เช็กสถานะ (Check Notification)',
        description: 'แอปจะแจ้งเตือนทันที ตรวจสอบเลข Tracking ผู้ให้บริการ และสถานะ "Ready for Pickup"',
        icon: Icons.notifications_active_rounded,
        color: Color(0xFF2563EB),
      ),
      FeatureGuideStep(
        stepNumber: 3,
        title: 'เปิดบัตรรับพัสดุ (Show Pickup Pass)',
        description: 'กดปุ่ม "Pickup QR" ในแอป เพื่อแสดง QR Code คมชัด หรือรหัส PIN 4 หลัก ยื่นให้นิติหรือสแกนตู้ Locker',
        icon: Icons.qr_code_2_rounded,
        color: Color(0xFF10B981),
      ),
      FeatureGuideStep(
        stepNumber: 4,
        title: 'ยืนยันรับของ (Confirm Claimed)',
        description: 'เมื่อได้รับของแล้ว ให้กดปุ่ม "Mark as Collected" ในแอป เพื่อบันทึกประวัติการรับเรียบร้อย',
        icon: Icons.check_circle_rounded,
        color: Color(0xFF6366F1),
      ),
    ],
  );

  // 2. Smart Laundry Guide
  static const FeatureGuide laundryGuide = FeatureGuide(
    id: 'laundry',
    title: 'Smart Laundry',
    titleTh: 'ขั้นตอนการใช้เครื่องซักผ้าส่วนกลาง',
    subtitle: 'เช็กเครื่องว่างแบบ Real-time และตั้งเตือนเมื่อผ้าเสร็จ',
    headerIcon: Icons.local_laundry_service_rounded,
    headerColor: Color(0xFF2563EB),
    tip: 'เครื่องซักผ้าและเครื่องอบผ้ารองรับทั้งเหรียญ 10 บาท และสแกน QR PromptPay ที่หน้าตู้',
    steps: [
      FeatureGuideStep(
        stepNumber: 1,
        title: 'เช็กเครื่องว่างล่วงหน้า (Check Availability)',
        description: 'เปิดดูสถานะเครื่องซักผ้าและเครื่องอบผ้าในแอป จะเห็นว่าเครื่องไหนว่าง หรือเหลือกี่นาที ไม่ต้องเสียเวลาเดินลงไปดู',
        icon: Icons.phonelink_ring_rounded,
        color: Color(0xFF007AFF),
      ),
      FeatureGuideStep(
        stepNumber: 2,
        title: 'นำผ้าลงไปใส่เครื่อง (Load & Pay)',
        description: 'ไปที่ห้องซักผ้าชั้น 1 ใส่ผ้าและน้ำยาซักผ้า หยอดเหรียญหรือสแกนจ่ายที่หน้าเครื่อง แล้วกดปุ่มเริ่มทำงาน',
        icon: Icons.local_laundry_service_rounded,
        color: Color(0xFF10B981),
      ),
      FeatureGuideStep(
        stepNumber: 3,
        title: 'กดเริ่มรอบในแอป (Start Cycle)',
        description: 'กดปุ่ม "Start Cycle (40 mins)" บนเครื่องที่คุณใช้งานในแอป ระบบจะเริ่มนับเวลาถอยหลังแบบเรียลไทม์',
        icon: Icons.timer_outlined,
        color: Color(0xFFFF9500),
      ),
      FeatureGuideStep(
        stepNumber: 4,
        title: 'รับการแจ้งเตือน & เก็บผ้า (Collect Clothes)',
        description: 'แอปจะแจ้งเตือนเมื่อเหลือเวลา 5 นาที เพื่อให้ลงไปเก็บผ้าตรงเวลา ช่วยรักษาคิวให้เพื่อนร่วมหอ',
        icon: Icons.notifications_active_rounded,
        color: Color(0xFF6366F1),
      ),
    ],
  );

  // 3. Facility Booking Guide
  static const FeatureGuide amenityGuide = FeatureGuide(
    id: 'amenity',
    title: 'Facility Booking',
    titleTh: 'ขั้นตอนการจองห้องอ่านหนังสือและพื้นที่ส่วนกลาง',
    subtitle: 'จองสิทธิ์ใช้งานห้องล่วงหน้าเพื่อความสะดวกและเป็นระเบียบ',
    headerIcon: Icons.meeting_room_rounded,
    headerColor: Color(0xFF6366F1),
    tip: 'จองได้สูงสุด 3 ชั่วโมงต่อวันต่อห้อง โปรดยกเลิกการจองล่วงหน้าอย่างน้อย 30 นาที หากไม่สะดวกใช้งาน',
    steps: [
      FeatureGuideStep(
        stepNumber: 1,
        title: 'เลือกพื้นที่ส่วนกลาง (Select Space)',
        description: 'เลือกห้องที่ต้องการใช้งาน เช่น Silent Study Room (อ่านหนังสือเงียบ) หรือ Group Meeting Pod (คุยงานกลุ่ม)',
        icon: Icons.room_preferences_rounded,
        color: Color(0xFF6366F1),
      ),
      FeatureGuideStep(
        stepNumber: 2,
        title: 'เลือกวันและรอบเวลา (Pick Date & Slot)',
        description: 'เลือกวันที่ (วันนี้ หรือพรุ่งนี้) และเลือกช่วงเวลา (Slot) ที่ต้องการใช้งานจากรอบที่ยังว่างอยู่',
        icon: Icons.calendar_month_rounded,
        color: Color(0xFF007AFF),
      ),
      FeatureGuideStep(
        stepNumber: 3,
        title: 'กดยืนยันการจอง (Confirm Reservation)',
        description: 'ตรวจสอบข้อมูลและกดยืนยัน รายการจองจะปรากฏใน "My Bookings" ทันที',
        icon: Icons.task_alt_rounded,
        color: Color(0xFF10B981),
      ),
      FeatureGuideStep(
        stepNumber: 4,
        title: 'เข้าใช้งานตามเวลา (Check-in & Use)',
        description: 'แตะคีย์การ์ดหรือแสดงหน้าการจองในแอปต่อเจ้าหน้าที่หน้าห้อง รักษาความสะอาดและคืนห้องเมื่อครบเวลา',
        icon: Icons.lock_open_rounded,
        color: Color(0xFFF59E0B),
      ),
    ],
  );

  // 4. Maintenance Guide
  static const FeatureGuide maintenanceGuide = FeatureGuide(
    id: 'maintenance',
    title: 'Maintenance Request',
    titleTh: 'ขั้นตอนการแจ้งซ่อมและนัดหมายช่าง',
    subtitle: 'แจ้งเรื่องซ่อมแซมพร้อมนัดเวลาช่างเข้าห้องได้อย่างแม่นยำ',
    headerIcon: Icons.build_rounded,
    headerColor: Color(0xFFFF9500),
    tip: 'กรณีฉุกเฉินเร่งด่วน (เช่น ท่อประปาแตก ไฟฟ้าลัดวงจร) ให้เลือกระดับความด่วนเป็น Urgent หรือโทรแจ้งนิติโดยตรง',
    steps: [
      FeatureGuideStep(
        stepNumber: 1,
        title: 'สร้างคำขอแจ้งซ่อม (Create Request)',
        description: 'กดปุ่ม "+" ในหน้า Maintenance หรือ Quick Action "Report Issue" ที่หน้าแรก',
        icon: Icons.add_circle_outline_rounded,
        color: Color(0xFF2563EB),
      ),
      FeatureGuideStep(
        stepNumber: 2,
        title: 'ระบุจุดชำรุด & หมวดหมู่ (Detail & Category)',
        description: 'เลือกหมวดหมู่อุปกรณ์ (เช่น เครื่องปรับอากาศ, ไฟฟ้า, ประปา) พร้อมพิมพ์อธิบายอาการเสียให้ชัดเจน',
        icon: Icons.edit_note_rounded,
        color: Color(0xFFFF9500),
      ),
      FeatureGuideStep(
        stepNumber: 3,
        title: 'เลือกระดับความด่วน & เวลาช่างเข้า (Urgency & Time Slot)',
        description: 'เลือกระดับความด่วน (Normal, Medium, Urgent) และเลือกช่วงเวลาที่คุณสะดวกอยู่ห้องให้ช่างเข้าซ่อม',
        icon: Icons.access_time_filled_rounded,
        color: Color(0xFFEF4444),
      ),
      FeatureGuideStep(
        stepNumber: 4,
        title: 'ติดตามสถานะงานซ่อม (Track Status Timeline)',
        description: 'เปิดดูการ์ดแจ้งซ่อมเพื่อดูสถานะ: รอรับเรื่อง ➔ ช่างกำลังเข้าซ่อม ➔ ซ่อมเสร็จสิ้น',
        icon: Icons.timeline_rounded,
        color: Color(0xFF10B981),
      ),
    ],
  );

  // 5. Payment & PromptPay Guide
  static const FeatureGuide paymentGuide = FeatureGuide(
    id: 'payment',
    title: 'Bills & Payment',
    titleTh: 'ขั้นตอนการชำระบิลผ่าน PromptPay',
    subtitle: 'ชำระค่าห้องและค่าน้ำ-ไฟได้ง่าย ปลอดภัย ไม่ต้องพิมพ์เลขบัญชี',
    headerIcon: Icons.qr_code_2_rounded,
    headerColor: Color(0xFF003D6B),
    tip: 'ระบบ PromptPay QR รองรับทุกแอปพลิเคชันธนาคารในไทย จ่ายแล้วระบบปรับสถานะให้ทันที',
    steps: [
      FeatureGuideStep(
        stepNumber: 1,
        title: 'ตรวจสอบยอดค้างชำระ (Check Due Amount)',
        description: 'ดูยอดบิลค่าห้อง ค่าน้ำ และค่าไฟประจำเดือนในหน้า Expenses หรือแบนเนอร์แจ้งเตือนหน้าแรก',
        icon: Icons.receipt_long_rounded,
        color: Color(0xFF2563EB),
      ),
      FeatureGuideStep(
        stepNumber: 2,
        title: 'กดปุ่ม "Pay with PromptPay" (Open QR Code)',
        description: 'แอปจะสร้าง QR Code พร้อมยอดเงินรวมที่ถูกต้องตรงตามบิลขึ้นมาโดยอัตโนมัติ',
        icon: Icons.qr_code_rounded,
        color: Color(0xFF003D6B),
      ),
      FeatureGuideStep(
        stepNumber: 3,
        title: 'สแกนชำระผ่านแอปธนาคาร (Scan & Pay)',
        description: 'เปิดแอปธนาคารใดก็ได้ สแกน QR บนหน้าจอ หรือบันทึกภาพหน้าจอไปสแกนจากอัลบั้มรูป',
        icon: Icons.account_balance_rounded,
        color: Color(0xFF10B981),
      ),
      FeatureGuideStep(
        stepNumber: 4,
        title: 'สถานะอัปเดตอัตโนมัติ (Instant Confirmation)',
        description: 'เมื่อการโอนเงินสำเร็จ สถานะบิลจะเปลี่ยนเป็น "Paid" สีเขียว และสามารถดูกราฟวิเคราะห์การใช้พลังงานได้',
        icon: Icons.verified_rounded,
        color: Color(0xFF059669),
      ),
    ],
  );

  // 6. Dormitory Rules & Community Guidelines
  static const FeatureGuide dormRulesGuide = FeatureGuide(
    id: 'rules',
    title: 'Dormitory Guidelines',
    titleTh: 'ระเบียบและกฎการพักอาศัยของหอพัก',
    subtitle: 'ข้อปฏิบัติเพื่อความปลอดภัยและความสงบสุขของส่วนรวม',
    headerIcon: Icons.policy_rounded,
    headerColor: Color(0xFF475569),
    tip: 'หากพบเหตุฉุกเฉินหรือต้องการความช่วยเหลือเร่งด่วน ติดต่อ รปภ. ได้ตลอด 24 ชั่วโมงที่โทร 081-999-8888',
    steps: [
      FeatureGuideStep(
        stepNumber: 1,
        title: 'เวลาเปิด-ปิดประตูหอพัก (Curfew & Access)',
        description: 'ประตูใหญ่เปิดเวลา 05:00 น. และปิดเวลา 24:00 น. นอกเวลาดังกล่าวต้องแตะบัตรคีย์การ์ดผ่านประตูด้านข้าง',
        icon: Icons.lock_clock_rounded,
        color: Color(0xFF64748B),
      ),
      FeatureGuideStep(
        stepNumber: 2,
        title: 'ช่วงเวลางดส่งเสียงดัง (Quiet Hours)',
        description: 'งดใช้เสียงดังทุกชนิดในห้องพักและทางเดินส่วนกลางระหว่างเวลา 22:00 - 07:00 น. เพื่อให้เพื่อนร่วมหอพักผ่อน',
        icon: Icons.volume_off_rounded,
        color: Color(0xFFEF4444),
      ),
      FeatureGuideStep(
        stepNumber: 3,
        title: 'การคัดแยกขยะ (Waste Sorting)',
        description: 'นำขยะใส่ถุงมัดให้มิดชิด ทิ้งลงในถังขยะแยกประเภท ณ จุดทิ้งขยะชั้น 1 ก่อนเวลา 20:00 น.',
        icon: Icons.delete_outline_rounded,
        color: Color(0xFF10B981),
      ),
      FeatureGuideStep(
        stepNumber: 4,
        title: 'การพาบุคคลภายนอกเข้าพัก (Visitors)',
        description: 'บุคคลภายนอกต้องลงทะเบียนแลกบัตรที่เคาน์เตอร์ รปภ. และไม่อนุญาตให้พักค้างคืนโดยไม่แจ้งนิติล่วงหน้า',
        icon: Icons.groups_rounded,
        color: Color(0xFFF59E0B),
      ),
    ],
  );

  static const List<FeatureGuide> allGuides = [
    parcelGuide,
    laundryGuide,
    amenityGuide,
    maintenanceGuide,
    paymentGuide,
    dormRulesGuide,
  ];
}
