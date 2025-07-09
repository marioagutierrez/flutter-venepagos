import 'package:flutter/material.dart';
import 'package:venepagos/venepagos.dart';

void main() {
  // Configurar Venepagos antes de iniciar la app
  Venepagos.instance.configure(
    apiKey: 'vp_test_example_key_12345', // Reemplaza con tu API key real
    sandboxMode: true, // Usar sandbox para development
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Venepagos Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: VenepagosExampleScreen(),
    );
  }
}

class VenepagosExampleScreen extends StatefulWidget {
  @override
  _VenepagosExampleScreenState createState() => _VenepagosExampleScreenState();
}

class _VenepagosExampleScreenState extends State<VenepagosExampleScreen> {
  bool _isLoading = false;
  String? _lastReference;
  String? _error;
  bool _apiKeyValid = false;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  Future<void> _checkApiKey() async {
    try {
      final isValid = await Venepagos.instance.testApiKey();
      setState(() {
        _apiKeyValid = isValid;
      });
    } catch (e) {
      setState(() {
        _apiKeyValid = false;
        _error = 'Error validando API key: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venepagos Flutter SDK'),
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Estado del API Key
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado de la API Key',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _apiKeyValid ? Icons.check_circle : Icons.error,
                          color: _apiKeyValid ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _apiKeyValid ? 'API Key válida' : 'API Key inválida',
                          style: TextStyle(
                            color: _apiKeyValid ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (Venepagos.instance.isSandboxMode)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          '🧪 Modo Sandbox activado',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Mensajes de estado
            if (_error != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!)),
                    ],
                  ),
                ),
              ),
            
            if (_lastReference != null)
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Pago Exitoso',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Referencia: $_lastReference'),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Botones de ejemplo
            Text(
              'Ejemplos de Pago',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Pago básico
            ElevatedButton.icon(
              onPressed: _isLoading || !_apiKeyValid ? null : _pagoBasico,
              icon: const Icon(Icons.payment),
              label: const Text('Pago Básico (\$19.99)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B365D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Suscripción
            ElevatedButton.icon(
              onPressed: _isLoading || !_apiKeyValid ? null : _suscripcionPremium,
              icon: const Icon(Icons.star),
              label: const Text('Suscripción Premium (\$49.99)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Donación (monto variable)
            ElevatedButton.icon(
              onPressed: _isLoading || !_apiKeyValid ? null : _donacion,
              icon: const Icon(Icons.favorite),
              label: const Text('Donación (monto variable)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // URL existente
            ElevatedButton.icon(
              onPressed: _isLoading || !_apiKeyValid ? null : _abrirUrlExistente,
              icon: const Icon(Icons.link),
              label: const Text('Abrir URL existente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1B365D),
                  ),
                ),
              ),
            
            const Spacer(),
            
            // Pie de página
            const Text(
              'Este es un ejemplo del SDK de Venepagos para Flutter.\nReemplaza la API key con la tuya para probar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pagoBasico() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _lastReference = null;
    });

    try {
      final resultado = await Venepagos.instance.createAndOpenPayment(
        context: context,
        title: 'Producto Básico',
        description: 'Un producto de ejemplo para demostrar el SDK',
        amount: 19.99,
        currency: 'USD',
        metadata: {
          'product_id': 'prod_basic_001',
          'category': 'example',
          'source': 'flutter_example',
        },
        onSuccess: (referencia) {
          setState(() {
            _lastReference = referencia;
            _isLoading = false;
          });
          _showSnackBar('¡Pago exitoso! Ref: $referencia', Colors.green);
        },
        onError: (error) {
          setState(() {
            _error = error;
            _isLoading = false;
          });
          _showSnackBar('Error: $error', Colors.red);
        },
        onCancelled: () {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar('Pago cancelado', Colors.orange);
        },
      );

      print('Resultado del pago: $resultado');
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _showSnackBar('Error creando pago: $e', Colors.red);
    }
  }

  Future<void> _suscripcionPremium() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _lastReference = null;
    });

    try {
      final resultado = await Venepagos.instance.createAndOpenPayment(
        context: context,
        title: 'Suscripción Premium',
        description: 'Plan mensual premium con todas las funciones incluidas',
        amount: 49.99,
        currency: 'USD',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        metadata: {
          'subscription_type': 'premium',
          'billing_period': 'monthly',
          'features': ['analytics', 'priority_support', 'custom_branding'],
          'trial_period': false,
          'source': 'flutter_example',
        },
        onSuccess: (referencia) {
          setState(() {
            _lastReference = referencia;
            _isLoading = false;
          });
          _showSnackBar('¡Suscripción activada! Ref: $referencia', Colors.green);
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

  Future<void> _donacion() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _lastReference = null;
    });

    try {
      // Crear payment link sin monto (monto variable)
      final resultado = await Venepagos.instance.createAndOpenPayment(
        context: context,
        title: 'Donación',
        description: 'Ayúdanos a seguir desarrollando software increíble',
        // Sin amount para permitir monto variable
        currency: 'USD',
        metadata: {
          'type': 'donation',
          'campaign': 'flutter_sdk_development',
          'source': 'flutter_example',
        },
        onSuccess: (referencia) {
          setState(() {
            _lastReference = referencia;
            _isLoading = false;
          });
          _showSnackBar('¡Gracias por tu donación! Ref: $referencia', Colors.green);
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

  Future<void> _abrirUrlExistente() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _lastReference = null;
    });

    try {
      // Este es un ejemplo con una URL ficticia
      // En un caso real, tendrías una URL válida de Venepagos
      const urlEjemplo = 'https://venepagos.com.ve/pagar/pl_example_123';
      
      final resultado = await Venepagos.instance.openPaymentFromUrl(
        context: context,
        paymentUrl: urlEjemplo,
        onSuccess: (referencia) {
          setState(() {
            _lastReference = referencia;
            _isLoading = false;
          });
          _showSnackBar('¡Pago completado! Ref: $referencia', Colors.green);
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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 