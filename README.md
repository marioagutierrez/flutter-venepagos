# Venepagos Flutter SDK

SDK oficial de Venepagos para Flutter. Integra fácilmente pagos en tus aplicaciones Flutter mediante una ventana emergente que maneja todo el flujo de pago de forma segura.

![Venepagos](https://venepagos.com.ve/logo_hor.png)

## Características

✅ **Fácil integración** - Solo unas líneas de código  
✅ **Ventana emergente** - WebView modal nativo  
✅ **Detección automática** - Callbacks de éxito/error automáticos  
✅ **API completa** - Crear payment links programáticamente  
✅ **Tipo seguro** - Modelos Dart con tipado fuerte  
✅ **Responsive** - Funciona en móvil y tablet  

## Instalación

Agrega esta dependencia a tu archivo `pubspec.yaml`:

```yaml
dependencies:
  venepagos: ^1.0.0
```

Luego ejecuta:

```bash
flutter pub get
```

## Configuración

### 1. Obtén tu API Key

Visita tu [dashboard de Venepagos](https://venepagos.com.ve/dashboard/perfil/api-keys) para generar tu API key.

### 2. Configura el SDK

```dart
import 'package:venepagos/venepagos.dart';

void main() {
  // Configurar Venepagos antes de usar
  Venepagos.instance.configure(
    apiKey: 'vp_tu_api_key_aqui',
    sandboxMode: true, // Solo para desarrollo
  );
  
  runApp(MyApp());
}
```

## Uso Básico

### Opción 1: Flujo Completo (Recomendado)

Crea el payment link y abre el pago en una sola llamada:

```dart
class MyPaymentButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _iniciarPago(context),
      child: Text('Pagar \$29.99'),
    );
  }
  
  Future<void> _iniciarPago(BuildContext context) async {
    try {
      final resultado = await Venepagos.instance.createAndOpenPayment(
        context: context,
        title: 'Suscripción Premium',
        description: 'Plan mensual premium con todas las funciones',
        amount: 29.99,
        currency: 'USD',
        metadata: {
          'user_id': '12345',
          'plan': 'premium',
          'source': 'mobile_app',
        },
        onSuccess: (referencia) {
          print('¡Pago exitoso! Referencia: $referencia');
          // Aquí puedes actualizar la UI, navegar, etc.
        },
        onError: (error) {
          print('Error en el pago: $error');
          // Mostrar mensaje de error al usuario
        },
        onCancelled: () {
          print('Pago cancelado por el usuario');
        },
      );
      
      // El resultado también está disponible aquí
      if (resultado?.isSuccess == true) {
        // Pago exitoso
        Navigator.pushNamed(context, '/success');
      }
    } catch (e) {
      print('Error creando payment link: $e');
    }
  }
}
```

### Opción 2: Dos Pasos

Para mayor control, puedes separar la creación del payment link de la apertura del pago:

```dart
Future<void> _pagoEnDosPasos(BuildContext context) async {
  try {
    // Paso 1: Crear payment link
    final paymentLink = await Venepagos.instance.createPaymentLink(
      title: 'Mi Producto',
      amount: 50.0,
      currency: 'USD',
      expiresAt: DateTime.now().add(Duration(hours: 24)),
      metadata: {'order_id': 'ORD-001'},
    );
    
    // Paso 2: Abrir pago
    final resultado = await Venepagos.instance.openPayment(
      context: context,
      paymentLink: paymentLink,
      onSuccess: (referencia) {
        // Lógica de éxito
      },
    );
  } catch (e) {
    print('Error: $e');
  }
}
```

### Opción 3: Payment Link Existente

Si ya tienes un payment link URL, puedes abrirlo directamente:

```dart
Future<void> _abrirPaymentLinkExistente(BuildContext context) async {
  final resultado = await Venepagos.instance.openPaymentFromUrl(
    context: context,
    paymentUrl: 'https://venepagos.com.ve/pagar/pl_abc123',
    onSuccess: (referencia) {
      print('Pago completado: $referencia');
    },
  );
}
```

## Ejemplos Avanzados

### Manejo de Estados

```dart
class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  String? _error;
  String? _successReference;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: Column(
        children: [
          if (_error != null)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.red[100],
              child: Text('Error: $_error'),
            ),
          
          if (_successReference != null)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.green[100],
              child: Text('¡Pago exitoso! Ref: $_successReference'),
            ),
          
          ElevatedButton(
            onPressed: _isLoading ? null : () => _procesarPago(),
            child: _isLoading 
              ? CircularProgressIndicator() 
              : Text('Procesar Pago'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _procesarPago() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _successReference = null;
    });
    
    try {
      await Venepagos.instance.createAndOpenPayment(
        context: context,
        title: 'Compra en App',
        amount: 99.99,
        currency: 'USD',
        onSuccess: (referencia) {
          setState(() {
            _successReference = referencia;
            _isLoading = false;
          });
          _enviarWebhookConfirmacion(referencia);
        },
        onError: (error) {
          setState(() {
            _error = error;
            _isLoading = false;
          });
        },
        onCancelled: () {
          setState(() {
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  void _enviarWebhookConfirmacion(String referencia) {
    // Aquí puedes enviar la confirmación a tu backend
    print('Enviando confirmación para: $referencia');
  }
}
```

### Validación de API Key

```dart
class ConfigScreen extends StatefulWidget {
  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _apiKeyController = TextEditingController();
  bool _isValidating = false;
  bool? _isValid;
  
  Future<void> _validarApiKey() async {
    final apiKey = _apiKeyController.text.trim();
    
    if (apiKey.isEmpty) return;
    
    setState(() {
      _isValidating = true;
      _isValid = null;
    });
    
    try {
      Venepagos.instance.configure(apiKey: apiKey);
      final isValid = await Venepagos.instance.testApiKey();
      
      setState(() {
        _isValid = isValid;
        _isValidating = false;
      });
      
      if (isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API Key válida ✅')),
        );
      }
    } catch (e) {
      setState(() {
        _isValid = false;
        _isValidating = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configuración')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: 'API Key de Venepagos',
                hintText: 'vp_...',
                suffixIcon: _isValid == null 
                  ? null 
                  : Icon(
                      _isValid! ? Icons.check_circle : Icons.error,
                      color: _isValid! ? Colors.green : Colors.red,
                    ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isValidating ? null : _validarApiKey,
              child: _isValidating 
                ? CircularProgressIndicator() 
                : Text('Validar API Key'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Metadata y Webhooks

```dart
Future<void> _pagoConMetadata(BuildContext context) async {
  final usuario = getCurrentUser(); // Tu función para obtener el usuario
  
  final resultado = await Venepagos.instance.createAndOpenPayment(
    context: context,
    title: 'Suscripción Pro',
    amount: 49.99,
    currency: 'USD',
    metadata: {
      // Información del usuario
      'user_id': usuario.id,
      'user_email': usuario.email,
      'user_tier': 'premium',
      
      // Información del pedido
      'order_id': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      'plan_type': 'pro_monthly',
      'billing_cycle': 'monthly',
      
      // Información de tracking
      'source': 'mobile_app',
      'platform': Platform.isIOS ? 'ios' : 'android',
      'app_version': '1.2.3',
      
      // Datos personalizados
      'campaign_id': 'summer_2024',
      'referral_code': usuario.referralCode,
    },
    onSuccess: (referencia) {
      // Los webhooks incluirán automáticamente toda la metadata
      _actualizarSuscripcionUsuario(usuario.id, 'pro');
    },
  );
}
```

## API Reference

### Venepagos.instance

#### configure()
```dart
void configure({
  required String apiKey,
  bool sandboxMode = false,
  String? baseUrl,
})
```

#### createPaymentLink()
```dart
Future<PaymentLink> createPaymentLink({
  required String title,
  String? description,
  double? amount,
  String currency = 'USD',
  DateTime? expiresAt,
  Map<String, dynamic>? metadata,
})
```

#### openPayment()
```dart
Future<PaymentResult?> openPayment({
  required BuildContext context,
  required PaymentLink paymentLink,
  Function(String reference)? onSuccess,
  Function(String error)? onError,
  VoidCallback? onCancelled,
})
```

#### createAndOpenPayment()
```dart
Future<PaymentResult?> createAndOpenPayment({
  required BuildContext context,
  required String title,
  // ... mismos parámetros que createPaymentLink + callbacks
})
```

#### testApiKey()
```dart
Future<bool> testApiKey()
```

### Modelos

#### PaymentLink
```dart
class PaymentLink {
  final String id;
  final String title;
  final String? description;
  final double? amount;
  final String currency;
  final String url;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
}
```

#### PaymentResult
```dart
class PaymentResult {
  final PaymentResultType type; // success, error, cancelled
  final String? reference;
  final String? errorMessage;
  final Map<String, dynamic>? data;
  
  bool get isSuccess;
  bool get isError;
  bool get isCancelled;
}
```

## Configuración para Producción

### iOS (ios/Runner/Info.plist)
```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <false/>
  <key>NSExceptionDomains</key>
  <dict>
    <key>venepagos.com.ve</key>
    <dict>
      <key>NSExceptionAllowsInsecureHTTPLoads</key>
      <false/>
      <key>NSExceptionMinimumTLSVersion</key>
      <string>TLSv1.2</string>
    </dict>
  </dict>
</dict>
```

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## Solución de Problemas

### Error: "API key no válida"
- Verifica que tu API key comience con `vp_`
- Asegúrate de estar usando la API key correcta (producción vs sandbox)
- Verifica que la API key no haya expirado

### WebView no carga
- Verifica tu conexión a internet
- Asegúrate de que los permisos de red estén configurados
- En iOS, verifica la configuración de App Transport Security

### Callbacks no se ejecutan
- Verifica que estés usando la URL correcta de Venepagos
- El SDK detecta automáticamente las páginas de confirmación y error

## Soporte

- 📧 Email: soporte@venepagos.com.ve
- 🌐 Documentación: https://docs.venepagos.com.ve
- 💬 Discord: https://discord.gg/venepagos

## Licencia

Este SDK está licenciado bajo la licencia MIT. Consulta el archivo LICENSE para más detalles.

---

Desarrollado con ❤️ por el equipo de [Venepagos](https://venepagos.com.ve)
