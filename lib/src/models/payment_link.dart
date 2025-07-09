/// Modelo que representa un enlace de pago de Venepagos
class PaymentLink {
  /// ID único del payment link
  final String id;
  
  /// Título del pago
  final String title;
  
  /// Descripción opcional del pago
  final String? description;
  
  /// Monto del pago (puede ser null para montos variables)
  final double? amount;
  
  /// Moneda del pago (USD, VES, etc.)
  final String currency;
  
  /// URL completa del payment link
  final String url;
  
  /// Si el enlace está activo
  final bool isActive;
  
  /// Fecha de expiración (opcional)
  final DateTime? expiresAt;
  
  /// Fecha de creación
  final DateTime createdAt;
  
  /// Metadata adicional para webhooks
  final Map<String, dynamic>? metadata;
  
  const PaymentLink({
    required this.id,
    required this.title,
    this.description,
    this.amount,
    required this.currency,
    required this.url,
    required this.isActive,
    this.expiresAt,
    required this.createdAt,
    this.metadata,
  });
  
  /// Crea un PaymentLink desde JSON
  factory PaymentLink.fromJson(Map<String, dynamic> json) {
    return PaymentLink(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: json['amount']?.toDouble(),
      currency: json['currency'] as String,
      url: json['url'] as String,
      isActive: json['isActive'] as bool,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
  
  /// Convierte el PaymentLink a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'currency': currency,
      'url': url,
      'isActive': isActive,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
  
  @override
  String toString() {
    return 'PaymentLink(id: $id, title: $title, amount: $amount $currency, active: $isActive)';
  }
} 