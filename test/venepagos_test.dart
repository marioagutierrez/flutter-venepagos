import 'package:flutter_test/flutter_test.dart';
import 'package:venepagos/venepagos.dart';

void main() {
  group('Venepagos SDK Tests', () {
    test('debe configurarse correctamente con API key válida', () {
      final venepagos = Venepagos.instance;
      
      expect(venepagos.isConfigured, false);
      
      venepagos.configure(apiKey: 'vp_test_12345');
      
      expect(venepagos.isConfigured, true);
      expect(venepagos.isSandboxMode, false);
    });
    
    test('debe activar modo sandbox cuando se especifica', () {
      final venepagos = Venepagos.instance;
      
      venepagos.configure(
        apiKey: 'vp_test_12345',
        sandboxMode: true,
      );
      
      expect(venepagos.isSandboxMode, true);
    });
    
    test('debe lanzar error con API key inválida', () {
      final venepagos = Venepagos.instance;
      
      expect(
        () => venepagos.configure(apiKey: 'invalid_key'),
        throwsArgumentError,
      );
    });
    

  });
  
  group('PaymentResult Tests', () {
    test('debe crear resultado exitoso correctamente', () {
      final result = PaymentResult.success('REF123');
      
      expect(result.isSuccess, true);
      expect(result.isError, false);
      expect(result.isCancelled, false);
      expect(result.reference, 'REF123');
    });
    
    test('debe crear resultado de error correctamente', () {
      final result = PaymentResult.error('Error de pago');
      
      expect(result.isSuccess, false);
      expect(result.isError, true);
      expect(result.isCancelled, false);
      expect(result.errorMessage, 'Error de pago');
    });
    
    test('debe crear resultado cancelado correctamente', () {
      final result = PaymentResult.cancelled();
      
      expect(result.isSuccess, false);
      expect(result.isError, false);
      expect(result.isCancelled, true);
    });
  });
  
  group('PaymentLink Tests', () {
    test('debe crearse desde JSON correctamente', () {
      final json = {
        'id': 'pl_123',
        'title': 'Test Payment',
        'description': 'Test Description',
        'amount': 100.0,
        'currency': 'USD',
        'url': 'https://venepagos.com.ve/pagar/pl_123',
        'isActive': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
      };
      
      final paymentLink = PaymentLink.fromJson(json);
      
      expect(paymentLink.id, 'pl_123');
      expect(paymentLink.title, 'Test Payment');
      expect(paymentLink.description, 'Test Description');
      expect(paymentLink.amount, 100.0);
      expect(paymentLink.currency, 'USD');
      expect(paymentLink.isActive, true);
    });
  });
}
