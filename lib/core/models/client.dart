class Client {
  final String id;
  final String nameOrCompany;
  final String? address;
  final String? phone;

  Client({
    required this.id,
    required this.nameOrCompany,
    this.address,
    this.phone,
  });

  Client copyWith({
    String? id,
    String? nameOrCompany,
    String? address,
    String? phone,
  }) {
    return Client(
      id: id ?? this.id,
      nameOrCompany: nameOrCompany ?? this.nameOrCompany,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name_or_company': nameOrCompany,
      'address': address,
      'phone': phone,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id']?.toString() ?? '',
      nameOrCompany: map['name_or_company'] ?? '',
      address: map['address'],
      phone: map['phone'],
    );
  }
}
