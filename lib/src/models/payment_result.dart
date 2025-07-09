/// Modelo que representa el resultado de un proceso de pago
class PaymentResult {
  /// Tipo de resultado del pago
  final PaymentResultType type;
  
  /// Referencia del pago (si es exitoso)
  final String? reference;
  
  /// Mensaje de error (si hay error)
  final String? errorMessage;
  
  /// Datos adicionales del resultado
  final Map<String, dynamic>? data;
  
  const PaymentResult({
    required this.type,
    this.reference,
    this.errorMessage,
    this.data,
  });
  
  /// Crea un resultado exitoso
  factory PaymentResult.success(String reference, [Map<String, dynamic>? data]) {
    return PaymentResult(
      type: PaymentResultType.success,
      reference: reference,
      data: data,
    );
  }
  
  /// Crea un resultado de error
  factory PaymentResult.error(String errorMessage, [Map<String, dynamic>? data]) {
    return PaymentResult(
      type: PaymentResultType.error,
      errorMessage: errorMessage,
      data: data,
    );
  }
  
  /// Crea un resultado de cancelación
  factory PaymentResult.cancelled([Map<String, dynamic>? data]) {
    return PaymentResult(
      type: PaymentResultType.cancelled,
      data: data,
    );
  }
  
  /// Verdadero si el pago fue exitoso
  bool get isSuccess => type == PaymentResultType.success;
  
  /// Verdadero si hubo un error
  bool get isError => type == PaymentResultType.error;
  
  /// Verdadero si fue cancelado
  bool get isCancelled => type == PaymentResultType.cancelled;
  
  @override
  String toString() {
    switch (type) {
      case PaymentResultType.success:
        return 'PaymentResult.success(reference: $reference)';
      case PaymentResultType.error:
        return 'PaymentResult.error(message: $errorMessage)';
      case PaymentResultType.cancelled:
        return 'PaymentResult.cancelled()';
    }
  }
  
  /// Convierte el resultado a JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'reference': reference,
      'errorMessage': errorMessage,
      'data': data,
    };
  }
  
  /// Crea un PaymentResult desde JSON
  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      type: PaymentResultType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentResultType.error,
      ),
      reference: json['reference'] as String?,
      errorMessage: json['errorMessage'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

/// Tipos de resultado de pago
enum PaymentResultType {
  /// Pago exitoso
  success,
  
  /// Error en el pago
  error,
  
  /// Pago cancelado por el usuario
  cancelled,
} 