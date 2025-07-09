library venepagos;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

// Importar modelos locales
import 'src/models/payment_link.dart';
import 'src/models/payment_result.dart';
import 'src/venepagos_payment_widget.dart';

// Exportar para uso público
export 'src/venepagos_payment_widget.dart';
export 'src/models/payment_link.dart';
export 'src/models/payment_result.dart';

/// SDK oficial de Venepagos para Flutter
/// 
/// Permite integrar fácilmente pagos de Venepagos en aplicaciones Flutter
/// mediante una ventana emergente que maneja todo el flujo de pago.
class Venepagos {
  static Venepagos? _instance;
  
  String? _apiKey;
  String _baseUrl = 'https://www.venepagos.com.ve';
  bool _sandboxMode = false;
  
  /// Constructor privado para singleton
  Venepagos._();
  
  /// Obtiene la instancia singleton de Venepagos
  static Venepagos get instance {
    _instance ??= Venepagos._();
    return _instance!;
  }
  
  /// Configura el SDK con la API key y opciones
  /// 
  /// [apiKey] Tu API key de Venepagos (formato: vp_...)
  /// [sandboxMode] Habilita el modo de prueba/sandbox
  /// [baseUrl] URL base personalizada (opcional)
  void configure({
    required String apiKey,
    bool sandboxMode = false,
    String? baseUrl,
  }) {
    if (!apiKey.startsWith('vp_')) {
      throw ArgumentError('La API key debe comenzar con "vp_"');
    }
    
    _apiKey = apiKey;
    _sandboxMode = sandboxMode;
    if (baseUrl != null) {
      _baseUrl = baseUrl;
    }
    
    debugPrint('Venepagos configurado: sandbox=$sandboxMode, baseUrl=$_baseUrl');
  }
  
  /// Verifica si el SDK está configurado correctamente
  bool get isConfigured => _apiKey != null;
  
  /// Obtiene el modo sandbox actual
  bool get isSandboxMode => _sandboxMode;
  
  /// Verifica que el SDK esté configurado
  void _ensureConfigured() {
    if (!isConfigured) {
      throw StateError(
        'Venepagos no está configurado. Llama a Venepagos.instance.configure() primero.'
      );
    }
  }
  
  /// Verifica la validez de la API key
  /// 
  /// Retorna `true` si la API key es válida, `false` en caso contrario
  Future<bool> testApiKey() async {
    _ensureConfigured();
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/public/test-api-key'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error verificando API key: $e');
      return false;
    }
  }
  
  /// Crea un nuevo payment link
  /// 
  /// [title] Título del pago
  /// [description] Descripción opcional del pago
  /// [amount] Monto del pago (opcional para montos variables)
  /// [currency] Moneda (USD o VES)
  /// [expiresAt] Fecha de expiración opcional
  /// [metadata] Datos adicionales para incluir en webhooks
  Future<PaymentLink> createPaymentLink({
    required String title,
    String? description,
    double? amount,
    String currency = 'USD',
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) async {
    _ensureConfigured();
    
    final body = {
      'title': title,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      'currency': currency,
      if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/public/payment-links/create'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      
      final responseData = json.decode(response.body);
      
      if (response.statusCode == 201 && responseData['success'] == true) {
        return PaymentLink.fromJson(responseData['data']);
      } else {
        throw VenepagosException(
          'Error creando payment link: ${responseData['error'] ?? 'Error desconocido'}',
          responseData['details'],
        );
      }
    } catch (e) {
      if (e is VenepagosException) rethrow;
      throw VenepagosException('Error de conexión al crear payment link: $e');
    }
  }
  
  /// Abre la ventana de pago para un payment link
  /// 
  /// [context] BuildContext de la aplicación
  /// [paymentLink] El payment link a mostrar
  /// [onSuccess] Callback cuando el pago es exitoso
  /// [onError] Callback cuando hay un error
  /// [onCancelled] Callback cuando el usuario cancela
  Future<PaymentResult?> openPayment({
    required BuildContext context,
    required PaymentLink paymentLink,
    Function(String reference)? onSuccess,
    Function(String error)? onError,
    VoidCallback? onCancelled,
  }) async {
    return showDialog<PaymentResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VenepagosPaymentWidget(
        paymentUrl: paymentLink.url,
        onSuccess: onSuccess,
        onError: onError,
        onCancelled: onCancelled,
      ),
    );
  }
  
  /// Abre la ventana de pago directamente con una URL
  /// 
  /// [context] BuildContext de la aplicación
  /// [paymentUrl] URL del payment link
  /// [onSuccess] Callback cuando el pago es exitoso
  /// [onError] Callback cuando hay un error
  /// [onCancelled] Callback cuando el usuario cancela
  Future<PaymentResult?> openPaymentFromUrl({
    required BuildContext context,
    required String paymentUrl,
    Function(String reference)? onSuccess,
    Function(String error)? onError,
    VoidCallback? onCancelled,
  }) async {
    return showDialog<PaymentResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VenepagosPaymentWidget(
        paymentUrl: paymentUrl,
        onSuccess: onSuccess,
        onError: onError,
        onCancelled: onCancelled,
      ),
    );
  }
  
  /// Flujo completo: crear payment link y abrir ventana de pago
  /// 
  /// Combina [createPaymentLink] y [openPayment] en una sola llamada
  Future<PaymentResult?> createAndOpenPayment({
    required BuildContext context,
    required String title,
    String? description,
    double? amount,
    String currency = 'USD',
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
    Function(String reference)? onSuccess,
    Function(String error)? onError,
    VoidCallback? onCancelled,
  }) async {
    try {
      final paymentLink = await createPaymentLink(
        title: title,
        description: description,
        amount: amount,
        currency: currency,
        expiresAt: expiresAt,
        metadata: metadata,
      );
      
      return await openPayment(
        context: context,
        paymentLink: paymentLink,
        onSuccess: onSuccess,
        onError: onError,
        onCancelled: onCancelled,
      );
    } catch (e) {
      onError?.call(e.toString());
      return PaymentResult.error(e.toString());
    }
  }
}

/// Excepción personalizada para errores de Venepagos
class VenepagosException implements Exception {
  final String message;
  final dynamic details;
  
  const VenepagosException(this.message, [this.details]);
  
  @override
  String toString() => 'VenepagosException: $message${details != null ? ' ($details)' : ''}';
}
