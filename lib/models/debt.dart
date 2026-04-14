class Debt {
  final int? id;
  final String name;
  final String phone;
  final double amount;
  final double paidAmount;
  final String type; // 'lend' | 'borrow'
  final String? note;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool isSettled;

  const Debt({
    this.id,
    required this.name,
    required this.phone,
    required this.amount,
    this.paidAmount = 0.0,
    required this.type,
    this.note,
    required this.createdAt,
    this.dueDate,
    this.isSettled = false,
  });

  double get remainingAmount => amount - paidAmount;
  double get progressPercent =>
      amount > 0.0 ? (paidAmount / amount).clamp(0.0, 1.0) : 0.0;
  bool get isOverdue =>
      dueDate != null && dueDate!.isBefore(DateTime.now()) && !isSettled;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'amount': amount,
        'paid_amount': paidAmount,
        'type': type,
        'note': note,
        'created_at': createdAt.toIso8601String(),
        'due_date': dueDate?.toIso8601String(),
        'is_settled': isSettled ? 1 : 0,
      };

  factory Debt.fromMap(Map<String, dynamic> map) => Debt(
        id: map['id'] as int?,
        name: map['name'] as String,
        phone: map['phone'] as String,
        amount: (map['amount'] as num).toDouble(),
        paidAmount: (map['paid_amount'] as num? ?? 0).toDouble(),
        type: map['type'] as String,
        note: map['note'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        dueDate: map['due_date'] != null
            ? DateTime.parse(map['due_date'] as String)
            : null,
        isSettled: (map['is_settled'] as int? ?? 0) == 1,
      );

  Debt copyWith({
    int? id,
    String? name,
    String? phone,
    double? amount,
    double? paidAmount,
    String? type,
    String? note,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isSettled,
  }) =>
      Debt(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        amount: amount ?? this.amount,
        paidAmount: paidAmount ?? this.paidAmount,
        type: type ?? this.type,
        note: note ?? this.note,
        createdAt: createdAt ?? this.createdAt,
        dueDate: dueDate ?? this.dueDate,
        isSettled: isSettled ?? this.isSettled,
      );
}
