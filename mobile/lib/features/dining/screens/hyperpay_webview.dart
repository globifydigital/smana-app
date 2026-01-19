import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HyperPayWebView extends StatefulWidget {
  final String checkoutId;
  final String integrity;
  final String shopperResultUrl;
  final Function(String resourcePath) onPaymentSuccess;
  final Function(String error) onPaymentError;
  final String mode; // 'test' or 'live'

  const HyperPayWebView({
    super.key,
    required this.checkoutId,
    required this.integrity,
    required this.shopperResultUrl,
    required this.onPaymentSuccess,
    required this.onPaymentError,
    this.mode = 'test',
  });

  @override
  State<HyperPayWebView> createState() => _HyperPayWebViewState();
}

class _HyperPayWebViewState extends State<HyperPayWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    final String baseUrl = widget.mode == 'live'
        ? 'https://eu-prod.oppwa.com'
        : 'https://eu-test.oppwa.com';

    final String htmlContent =
        '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>
      var wpwlOptions = {
        style: "card",
        paymentTarget: "_top",
        iframeStyles: {
          'card-number-placeholder': {
            'color': '#ff0000',
            'font-size': '16px',
            'font-family': 'monospace'
          },
          'cvv-placeholder': {
            'color': '#0000ff',
            'font-size': '16px',
            'font-family': 'Arial'
          }
        }
      }
    </script>
    <script src="$baseUrl/v1/paymentWidgets.js?checkoutId=${widget.checkoutId}" 
            crossorigin="anonymous">
    </script>
    <style>
        body { margin: 0; padding: 20px; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
        .paymentWidgets { width: 100%; border: 0; }
    </style>
</head>
<body>
    <form action="${widget.shopperResultUrl}" class="paymentWidgets" data-brands="VISA MASTER AMEX"></form>
</body>
</html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('HyperPay WebView: Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('HyperPay WebView: Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('HyperPay WebView Error code: \${error.errorCode}');
            debugPrint(
              'HyperPay WebView Error description: \${error.description}',
            );
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            debugPrint('HyperPay WebView Navigation: $url');

            // Check for shopperResultUrl interception
            if (url.startsWith(widget.shopperResultUrl)) {
              final uri = Uri.parse(url);
              final resourcePath = uri.queryParameters['resourcePath'];

              if (resourcePath != null) {
                widget.onPaymentSuccess(resourcePath);
              } else {
                widget.onPaymentError(
                  'Payment completed but no resource path found.',
                );
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(htmlContent, baseUrl: baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
