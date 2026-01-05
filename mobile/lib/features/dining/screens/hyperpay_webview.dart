import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_theme.dart';

class HyperPayWebView extends StatefulWidget {
  final String checkoutId;
  final String shopperResultUrl;
  final Function(String status) onPaymentComplete;

  const HyperPayWebView({
    Key? key,
    required this.checkoutId,
    required this.shopperResultUrl,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  State<HyperPayWebView> createState() => _HyperPayWebViewState();
}

class _HyperPayWebViewState extends State<HyperPayWebView> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _paymentProcessed = false;

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
          onNavigationRequest: (NavigationRequest request) {
            print('Navigation request: ${request.url}');

            // Intercept custom URL schemes and redirects
            if (request.url.contains('smana://') ||
                request.url.contains(widget.shopperResultUrl)) {
              if (!_paymentProcessed) {
                _paymentProcessed = true;
                _handlePaymentComplete('completed');
              }
              // Prevent WebView from trying to load custom schemes
              return NavigationDecision.prevent;
            }

            // Allow all other navigation
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            print('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
          'data:text/html;charset=utf-8,${Uri.encodeComponent(_buildPaymentPageHtml())}',
        ),
      );
  }

  void _handlePaymentComplete(String status) {
    print('Payment completed with status: $status');
    if (mounted && !_paymentProcessed) {
      widget.onPaymentComplete(status);
    }
  }

  String _buildPaymentPageHtml() {
    // Build complete HTML page with HyperPay COPYandPAY widget
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Payment</title>
    <script src="https://eu-test.oppwa.com/v1/paymentWidgets.js?checkoutId=${widget.checkoutId}"></script>
    <script type="text/javascript">
        var wpwlOptions = {
            style: "card",
            locale: "en",
            paymentTarget: "_top",
            brandDetection: true,
            brandDetectionType: "binlist",
            brandDetectionPriority: ["VISA", "MASTER"],
            onReady: function() {
                console.log("Payment form ready");
                var submitBtn = document.querySelector('.wpwl-button-pay');
                if (submitBtn) {
                    submitBtn.style.backgroundColor = '#D4AF37';
                    submitBtn.style.color = '#000000';
                }
            },
            onBeforeSubmitCard: function() {
                console.log("Submitting card payment");
                return true;
            }
        };
    </script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 100%);
            color: #ffffff;
            padding: 20px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 480px;
            margin: 0 auto;
            padding-top: 20px;
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid rgba(212, 175, 55, 0.3);
        }
        
        .header h1 {
            color: #D4AF37;
            font-size: 24px;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        
        .header p {
            color: #aaa;
            font-size: 14px;
        }
        
        .lock-icon {
            font-size: 20px;
        }
        
        .wpwl-form {
            background: rgba(255, 255, 255, 0.05);
            padding: 24px;
            border-radius: 12px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .wpwl-label {
            color: #D4AF37 !important;
            font-weight: 500;
            font-size: 13px;
            margin-bottom: 6px;
        }
        
        .wpwl-control {
            background: rgba(255, 255, 255, 0.1) !important;
            border: 1px solid rgba(212, 175, 55, 0.3) !important;
            border-radius: 8px !important;
            color: #ffffff !important;
            padding: 12px !important;
            font-size: 15px !important;
        }
        
        .wpwl-control:focus {
            border-color: #D4AF37 !important;
            outline: none !important;
            box-shadow: 0 0 0 3px rgba(212, 175, 55, 0.1) !important;
        }
        
        .wpwl-button-pay {
            background: #D4AF37 !important;
            color: #000000 !important;
            border: none !important;
            border-radius: 8px !important;
            padding: 14px 24px !important;
            font-size: 16px !important;
            font-weight: 600 !important;
            cursor: pointer !important;
            width: 100% !important;
            margin-top: 20px !important;
            transition: all 0.3s ease !important;
        }
        
        .wpwl-button-pay:hover {
            background: #c19d2f !important;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(212, 175, 55, 0.3);
        }
        
        .wpwl-brand-card {
            margin-bottom: 16px;
        }
        
        .test-cards {
            margin-top: 24px;
            background: rgba(76, 175, 80, 0.1);
            border: 1px solid rgba(76, 175, 80, 0.3);
            border-radius: 8px;
            padding: 16px;
        }
        
        .test-cards-title {
            color: #4CAF50;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .test-card {
            background: rgba(0, 0, 0, 0.2);
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 10px;
        }
        
        .test-card:last-child {
            margin-bottom: 0;
        }
        
        .test-card-brand {
            color: #4CAF50;
            font-weight: 600;
            font-size: 12px;
            margin-bottom: 4px;
        }
        
        .test-card-details {
            color: #aaa;
            font-size: 11px;
            font-family: monospace;
        }
        
        .security-note {
            text-align: center;
            margin-top: 20px;
            padding: 12px;
            background: rgba(33, 150, 243, 0.1);
            border: 1px solid rgba(33, 150, 243, 0.3);
            border-radius: 8px;
            font-size: 12px;
            color: #64B5F6;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1><span class="lock-icon">🔒</span> Secure Payment</h1>
            <p>Enter your card details securely</p>
        </div>
        
        <!-- HyperPay Payment Form Widget -->
        <form action="${widget.shopperResultUrl}" class="paymentWidgets" data-brands="VISA MASTER AMEX"></form>
        
        <!-- Test Cards Info -->
        <div class="test-cards">
            <div class="test-cards-title">
                🧪 Test Mode - Use Test Cards
            </div>
            <div class="test-card">
                <div class="test-card-brand">✅ VISA (Success)</div>
                <div class="test-card-details">
                    Card: 4440000009900010<br>
                    CVV: 100 | Expiry: 01/39
                </div>
            </div>
            <div class="test-card">
                <div class="test-card-brand">✅ MasterCard (Success)</div>
                <div class="test-card-details">
                    Card: 5123450000000008<br>
                    CVV: 100 | Expiry: 01/39
                </div>
            </div>
        </div>
        
        <div class="security-note">
            🔐 This is a secure, encrypted connection
        </div>
    </div>
</body>
</html>
    ''';
  }

  Future<bool> _showCancelConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2a2a2a),
            title: const Text(
              'Cancel Payment?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to cancel this payment? Your order will not be placed.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Continue Payment',
                  style: TextStyle(color: AppTheme.goldPrimary),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cancel Payment'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Complete Payment'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            final shouldCancel = await _showCancelConfirmation();
            if (shouldCancel && mounted) {
              widget.onPaymentComplete('cancelled');
              Navigator.of(context).pop(false);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: AppTheme.darkBackground,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.goldPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading payment form...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
