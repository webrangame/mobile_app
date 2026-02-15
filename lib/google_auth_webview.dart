import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart'; // Navigate to ChatScreen

class GoogleAuthWebView extends StatefulWidget {
  const GoogleAuthWebView({super.key});

  @override
  State<GoogleAuthWebView> createState() => _GoogleAuthWebViewState();
}

class _GoogleAuthWebViewState extends State<GoogleAuthWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            _checkUrl(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _checkUrl(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (_checkUrl(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://market.niyogen.com/api/auth/google'));
  }

  bool _checkUrl(String url) {
    // Check if we have been redirected to the callback with tokens
    // The backend redirects to /auth/callback?accessToken=...&refreshToken=...
    if (url.contains('/auth/callback') && url.contains('accessToken=')) {
      _handleAuthCallback(url);
      return true;
    }
    return false;
  }

  Future<void> _handleAuthCallback(String url) async {
    final uri = Uri.parse(url);
    final accessToken = uri.queryParameters['accessToken'];
    final refreshToken = uri.queryParameters['refreshToken'];
    final email = uri.queryParameters['email'];
    final name = uri.queryParameters['name'];
    final userId = uri.queryParameters['userId'];

    if (accessToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', accessToken);
      if (refreshToken != null) {
        await prefs.setString('refreshToken', refreshToken);
      }
      
      final user = {
        'id': userId,
        'email': email,
        'name': name,
      };
      await prefs.setString('user', jsonEncode(user));

      if (mounted) {
         Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ChatScreen()),
          (route) => false,
        );
      }
    } else {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-In failed. No token received.')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign-In'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
