import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'models/payment_result.dart';

/// Widget modal que muestra la sesión de pago de Venepagos en WebView
class VenepagosPaymentWidget extends StatefulWidget {
  /// URL del payment link a mostrar
  final String paymentUrl;
  
  /// Callback cuando el pago es exitoso
  final Function(String reference)? onSuccess;
  
  /// Callback cuando hay un error
  final Function(String error)? onError;
  
  /// Callback cuando el usuario cancela
  final VoidCallback? onCancelled;
  
  const VenepagosPaymentWidget({
    Key? key,
    required this.paymentUrl,
    this.onSuccess,
    this.onError,
    this.onCancelled,
  }) : super(key: key);
  
  @override
  State<VenepagosPaymentWidget> createState() => _VenepagosPaymentWidgetState();
}

class _VenepagosPaymentWidgetState extends State<VenepagosPaymentWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;
  bool _hasNavigatedToConfirmation = false;
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }
  
  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Venepagos WebView: Navegando a $url');
            _handleUrlChange(url);
          },
          onPageFinished: (String url) {
            debugPrint('Venepagos WebView: Página cargada $url');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Venepagos WebView: Error ${error.description}');
            setState(() {
              _error = 'Error cargando la página de pago: ${error.description}';
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Venepagos WebView: Solicitando navegación a ${request.url}');
            
            // Permitir navegación dentro del dominio de Venepagos
            if (request.url.contains('venepagos.com.ve') || 
                request.url.contains('localhost:3000') ||
                request.url.contains('localhost:3001')) {
              return NavigationDecision.navigate;
            }
            
            // Bloquear navegación externa
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }
  
  void _handleUrlChange(String url) {
    // Detectar navegación a página de confirmación (pago exitoso)
    if (url.contains('/pagar/confirmacion') && !_hasNavigatedToConfirmation) {
      _hasNavigatedToConfirmation = true;
      
      // Extraer referencia de la URL
      final uri = Uri.parse(url);
      final reference = uri.queryParameters['ref'] ?? 'success';
      
      debugPrint('Venepagos: Pago exitoso detectado, referencia: $reference');
      
      // Delay para permitir que la página se cargue completamente
      Timer(const Duration(milliseconds: 1500), () {
        _handlePaymentSuccess(reference);
      });
    }
    
    // Detectar errores específicos en la URL
    if (url.contains('error') || url.contains('failed')) {
      final uri = Uri.parse(url);
      final errorMsg = uri.queryParameters['error'] ?? 'Error en el pago';
      _handlePaymentError(errorMsg);
    }
  }
  
  void _handlePaymentSuccess(String reference) {
    widget.onSuccess?.call(reference);
    _closeWithResult(PaymentResult.success(reference));
  }
  
  void _handlePaymentError(String error) {
    widget.onError?.call(error);
    _closeWithResult(PaymentResult.error(error));
  }
  
  void _handlePaymentCancelled() {
    widget.onCancelled?.call();
    _closeWithResult(PaymentResult.cancelled());
  }
  
  void _closeWithResult(PaymentResult result) {
    if (mounted) {
      Navigator.of(context).pop(result);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Venepagos',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF1B365D), // Color corporativo de Venepagos
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _handlePaymentCancelled,
          ),
          elevation: 0,
        ),
        body: Stack(
          children: [
            if (_error != null)
              _buildErrorView()
            else
              _buildWebView(),
            
            if (_isLoading)
              _buildLoadingView(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWebView() {
    return WebViewWidget(controller: _controller);
  }
  
  Widget _buildLoadingView() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF1B365D),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando Venepagos...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1B365D),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorView() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error de conexión',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _handlePaymentCancelled,
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    _initializeWebView();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B365D),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 