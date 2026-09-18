class Expense {
  final int id;
  final String billingMonth; // YYYY-MM
  final double electricity;
  final double water;
  final double internet;
  final double other;
  final double total;
  final String? dueDate;
  final String paymentStatus; // 'Paid' | 'Unpaid'
  final String createdAt;

  const Expense({
    required this.id,
    required this.billingMonth,
    required this.electricity,
    required this.water,
    required this.internet,
    required this.other,
    required this.total,
    this.dueDate,
    required this.paymentStatus,
    required this.createdAt,
  });

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  String get displayMonth {
    final parts = billingMonth.split('-');
    if (parts.length != 2) return billingMonth;
    const months = ['', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    final m = int.tryParse(parts[1]) ?? 0;
    if (m >= 1 && m <= 12) {
      return '${months[m]} ${parts[0]}';
    }
    return billingMonth;
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    double parseD(dynamic v) => double.tryParse(v?.toString() ?? '0') ?? 0;
    return Expense(
      id: json['id'] as int? ?? 0,
      billingMonth: json['billing_month'] as String? ?? '',
      electricity: parseD(json['electricity']),
      water: parseD(json['water']),
      internet: parseD(json['internet']),
      other: parseD(json['other']),
      total: parseD(json['total']),
      dueDate: json['due_date'] as String?,
      paymentStatus: json['payment_status'] as String? ?? 'Unpaid',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'billing_month': billingMonth,
    'electricity': electricity,
    'water': water,
    'internet': internet,
    'other': other,
    'total': total,
    'due_date': dueDate,
    'payment_status': paymentStatus,
    'created_at': createdAt,
  };
}
