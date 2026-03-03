class Wallet {
  final String id;
  final String name;
  final String address;
  final String seed; // 12 слов, разделенных пробелами
  final int createdAt;

  Wallet({
    required this.id,
    required this.name,
    required this.address,
    required this.seed,
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  /// Конвертация в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'seed': seed,
      'createdAt': createdAt,
    };
  }

  /// Создание объекта из JSON
  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      seed: json['seed'] ?? '',
      createdAt: json['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Копирование с изменениями
  Wallet copyWith({
    String? id,
    String? name,
    String? address,
    String? seed,
    int? createdAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      seed: seed ?? this.seed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
