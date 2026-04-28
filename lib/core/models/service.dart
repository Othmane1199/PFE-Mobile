class ServiceTask {
  final String id;
  final String clientId;
  final String type;
  final String? description;
  final String? duration;
  final double totalPrice;
  final DateTime? createdAt;
  final String status; // 'En attente', 'En cours', 'Terminé'

  static const List<String> validStatuses = [
    'En attente',
    'En cours',
    'Terminé',
  ];

  ServiceTask({
    required this.id,
    required this.clientId,
    required this.type,
    this.description,
    this.duration,
    required this.totalPrice,
    this.createdAt,
    this.status = 'En attente',
  });

  ServiceTask copyWith({
    String? id,
    String? clientId,
    String? type,
    String? description,
    String? duration,
    double? totalPrice,
    DateTime? createdAt,
    String? status,
  }) {
    return ServiceTask(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      type: type ?? this.type,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'client_id': clientId,
      'type': type,
      'description': description,
      'duration': duration,
      'total_price': totalPrice,
      'status': status,
    };
  }

  factory ServiceTask.fromMap(Map<String, dynamic> map) {
    return ServiceTask(
      id: map['id']?.toString() ?? '',
      clientId: map['client_id']?.toString() ?? '',
      type: map['type'] ?? 'Autre',
      description: map['description'],
      duration: map['duration']?.toString(),
      totalPrice: (map['total_price'] ?? 0).toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      status: map['status'] ?? 'En attente',
    );
  }
}
