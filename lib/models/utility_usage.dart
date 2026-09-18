class MonthlyUtilityRecord {
  final String monthLabel; // e.g. 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'
  final String fullBillingMonth; // e.g. '2026-09'
  final double electricityUnits; // kWh
  final double electricityCost; // THB
  final double waterUnits; // m³ (Cubic meters)
  final double waterCost; // THB

  const MonthlyUtilityRecord({
    required this.monthLabel,
    required this.fullBillingMonth,
    required this.electricityUnits,
    required this.electricityCost,
    required this.waterUnits,
    required this.waterCost,
  });
}

class UtilityAnalyticsData {
  final List<MonthlyUtilityRecord> historicalRecords;

  const UtilityAnalyticsData({required this.historicalRecords});

  MonthlyUtilityRecord get currentMonth => historicalRecords.isNotEmpty
      ? historicalRecords.last
      : const MonthlyUtilityRecord(
          monthLabel: 'Sep',
          fullBillingMonth: '2026-09',
          electricityUnits: 215,
          electricityCost: 860,
          waterUnits: 8.5,
          waterCost: 170,
        );

  MonthlyUtilityRecord? get previousMonth =>
      historicalRecords.length >= 2 ? historicalRecords[historicalRecords.length - 2] : null;

  // Electricity calculations
  double get electricityDeltaPercent {
    if (previousMonth == null || previousMonth!.electricityUnits == 0) return 0.0;
    return ((currentMonth.electricityUnits - previousMonth!.electricityUnits) /
            previousMonth!.electricityUnits) *
        100;
  }

  double get averageElectricityUnits {
    if (historicalRecords.isEmpty) return 0.0;
    final total = historicalRecords.fold<double>(0.0, (s, r) => s + r.electricityUnits);
    return total / historicalRecords.length;
  }

  // Water calculations
  double get waterDeltaPercent {
    if (previousMonth == null || previousMonth!.waterUnits == 0) return 0.0;
    return ((currentMonth.waterUnits - previousMonth!.waterUnits) /
            previousMonth!.waterUnits) *
        100;
  }

  double get averageWaterUnits {
    if (historicalRecords.isEmpty) return 0.0;
    final total = historicalRecords.fold<double>(0.0, (s, r) => s + r.waterUnits);
    return total / historicalRecords.length;
  }

  // Contextual Insights
  String get electricityInsight {
    final delta = electricityDeltaPercent;
    if (delta > 10) {
      return '⚡ ข้อควรระวัง: การใช้ไฟเพิ่มขึ้น ${delta.toStringAsFixed(1)}% จากเดือนก่อนหน้า แนะนำตั้งเวลาปิดแอร์ล่วงหน้า 30 นาที และเปิดพัดลมควบคู่ที่ 25°C เพื่อลดค่าไฟ';
    } else if (delta < -5) {
      return '🌿 ยอดเยี่ยม: คุณใช้ไฟลดลง ${delta.abs().toStringAsFixed(1)}% ประหยัดค่าไฟได้ดีมาก รักษาพฤติกรรมนี้ต่อไป!';
    } else {
      return '💡 ปกติ: การใช้ไฟฟ้าอยู่ในเกณฑ์สม่ำเสมอใกล้เคียงกับค่าเฉลี่ยรายเดือนของคุณ';
    }
  }

  String get waterInsight {
    final delta = waterDeltaPercent;
    if (delta > 12) {
      return '💧 ข้อควรระวัง: ใช้น้ำเพิ่มขึ้น ${delta.toStringAsFixed(1)}% โปรดตรวจสอบจุดรั่วซึมของสุขภัณฑ์ หรือปิดน้ำระหว่างแปรงฟัน';
    } else if (delta < -5) {
      return '💧 ดีเยี่ยม: การใช้น้ำลดลง ${delta.abs().toStringAsFixed(1)}% ช่วยประหยัดค่าน้ำได้ดี';
    } else {
      return '💧 การใช้น้ำประปาอยู่ในเกณฑ์ปกติและคงที่';
    }
  }

  static UtilityAnalyticsData mockDefault() {
    return const UtilityAnalyticsData(
      historicalRecords: [
        MonthlyUtilityRecord(
          monthLabel: 'Apr',
          fullBillingMonth: '2026-04',
          electricityUnits: 155,
          electricityCost: 620,
          waterUnits: 7.2,
          waterCost: 144,
        ),
        MonthlyUtilityRecord(
          monthLabel: 'May',
          fullBillingMonth: '2026-05',
          electricityUnits: 170,
          electricityCost: 680,
          waterUnits: 8.0,
          waterCost: 160,
        ),
        MonthlyUtilityRecord(
          monthLabel: 'Jun',
          fullBillingMonth: '2026-06',
          electricityUnits: 195,
          electricityCost: 780,
          waterUnits: 8.5,
          waterCost: 170,
        ),
        MonthlyUtilityRecord(
          monthLabel: 'Jul',
          fullBillingMonth: '2026-07',
          electricityUnits: 180,
          electricityCost: 720,
          waterUnits: 8.1,
          waterCost: 162,
        ),
        MonthlyUtilityRecord(
          monthLabel: 'Aug',
          fullBillingMonth: '2026-08',
          electricityUnits: 190,
          electricityCost: 760,
          waterUnits: 8.4,
          waterCost: 168,
        ),
        MonthlyUtilityRecord(
          monthLabel: 'Sep',
          fullBillingMonth: '2026-09',
          electricityUnits: 215,
          electricityCost: 860,
          waterUnits: 7.8,
          waterCost: 156,
        ),
      ],
    );
  }
}
