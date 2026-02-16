import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'login_screen.dart';
import 'reviews_screen.dart';
import 'package:supermarket_rag_mobile/widgets/custom_widgets.dart';
import 'package:supermarket_rag_mobile/widgets/voice_search_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final String? initialQuery;
  const ChatScreen({super.key, this.initialQuery});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // Welcome message
    _messages.add({
      "role": "assistant",
      "content": "Hello! I'm your Supermarket Assistant. Ask me about product prices or deals (e.g., 'price of milk in coles').",
      "metadata": []
    });

    // Handle initial query from navigation (e.g. from Dashboard)
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.text = widget.initialQuery!;
          _sendMessage();
        }
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final decoded = jsonDecode(userStr);
        if (decoded is Map && mounted) {
          setState(() {
            _userData = Map<String, dynamic>.from(decoded);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data in Chat: $e');
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showUserInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.person_rounded, 'Name', _userData?['name'] ?? 'N/A'),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.email_rounded, 'Email', _userData?['email'] ?? 'N/A'),
            if (_userData?['role'] != null) ...[
              const SizedBox(height: 16),
              _buildInfoRow(Icons.badge_rounded, 'Role', _userData!['role'].toString().toUpperCase()),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text;
    setState(() {
      _messages.add({"role": "user", "content": userText, "metadata": []});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final result = await _apiService.sendMessage(userText);
      if (mounted) {
        setState(() {
          _messages.add({
            "role": "assistant", 
            "content": result['response'],
            "metadata": result['metadata']
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            "role": "assistant", 
            "content": "⚠️ ${e.toString().replaceAll('Exception: ', '')}",
            "metadata": []
          });
          _isLoading = false;
        });
      }
    } finally {
      if (mounted) {
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(
          widget.initialQuery != null && widget.initialQuery!.isNotEmpty
              ? widget.initialQuery!
              : 'Price Search',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1B1B25)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black, size: 20),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.black),
            onSelected: (value) {
              if (value == 'user_info') {
                _showUserInfoDialog();
              } else if (value == 'reviews') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReviewsScreen()),
                );
              } else if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'user_info',
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded),
                    SizedBox(width: 12),
                    Text('User Info'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reviews',
                child: Row(
                  children: [
                    Icon(Icons.star_outline_rounded),
                    SizedBox(width: 12),
                    Text('Reviews & Ratings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return const _BotTypingIndicator();
                }
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return _ChatBubble(
                  content: msg['content']!,
                  isUser: isUser,
                  metadata: msg['metadata'],
                );
              },
            ),
          ),
          
          // Input Area
          _buildInputArea(),
          
          // Powered By
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: GestureDetector(
              onTap: () async {
                 final Uri url = Uri.parse('https://www.niyogen.com/');
                 if (await canLaunchUrl(url)) {
                   await launchUrl(url);
                 }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Powered by ",
                    style: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  Text(
                    "NiyoGen",
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF4A6CF7), 
                      fontSize: 12, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFF),
      ),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: "Ask me anything...",
                  hintStyle: GoogleFonts.outfit(color: const Color(0xFFAFAFAF), fontSize: 16),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.mic_rounded, color: const Color(0xFF4A6CF7).withValues(alpha: 0.8)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.transparent,
                        builder: (context) => VoiceSearchOverlay(
                          onResult: (text) {
                            setState(() {
                              _controller.text = text;
                            });
                            _sendMessage();
                          },
                        ),
                      );
                    },
                  ),
                ),
                style: GoogleFonts.outfit(fontSize: 16, color: const Color(0xFF1B1B25)),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A6CF7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatefulWidget {
  final String content;
  final bool isUser;
  final List<dynamic>? metadata;

  const _ChatBubble({required this.content, required this.isUser, this.metadata});

  @override
  State<_ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<_ChatBubble> {
  List<dynamic> _currentProducts = [];
  String _activeSort = 'Default'; // Default, Cheapest
  String _activeFilter = 'All'; // All, Coles, Woolworths

  @override
  void initState() {
    super.initState();
    if (widget.metadata != null) {
      _currentProducts = List.from(widget.metadata!);
    }
  }

  @override
  void didUpdateWidget(_ChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.metadata != oldWidget.metadata) {
      setState(() {
         _currentProducts = List.from(widget.metadata!);
         _activeSort = 'Default';
         _activeFilter = 'All';
      });
    }
  }

  double _parsePrice(String priceStr) {
    try {
      // Remove '$', whitespace, and non-numeric chars except dot
      String clean = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
      return double.parse(clean);
    } catch (e) {
      return 999999.0; // Push to bottom if invalid
    }
  }

  void _sortCheapestFirst() {
    setState(() {
      _activeSort = 'Cheapest';
      _currentProducts.sort((a, b) {
        final double pA = _parsePrice(a['price'] ?? a['Price'] ?? '');
        final double pB = _parsePrice(b['price'] ?? b['Price'] ?? '');
        return pA.compareTo(pB);
      });
    });
  }

  void _filterByStore(String storeName) {
    setState(() {
      _activeFilter = storeName;
      if (storeName == 'All') {
        _currentProducts = List.from(widget.metadata!);
      } else {
        _currentProducts = widget.metadata!.where((p) {
          final s = (p['store'] ?? p['shop_name'] ?? '').toString().toLowerCase();
          return s.contains(storeName.toLowerCase());
        }).toList();
      }
      // Re-apply sort if active
      if (_activeSort == 'Cheapest') {
        _currentProducts.sort((a, b) {
          final double pA = _parsePrice(a['price'] ?? a['Price'] ?? '');
          final double pB = _parsePrice(b['price'] ?? b['Price'] ?? '');
          return pA.compareTo(pB);
        });
      }
    });
  }

  void _showStoreFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Filter by Store',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildFilterOption('All Stores', 'All'),
            const Divider(height: 1),
            _buildFilterOption('Coles', 'Coles'),
            const Divider(height: 1),
            _buildFilterOption('Woolworths', 'Woolworths'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String value) {
    final isSelected = _activeFilter == value;
    return InkWell(
      onTap: () {
        _filterByStore(value);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFF4A6CF7) : Colors.black87,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF4A6CF7)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5D7DF5), Color(0xFF4A68D6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  widget.content,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE0E7FF),
              child: const Icon(Icons.person, size: 20, color: Color(0xFF4A6CF7)),
            ),
          ],
        ),
      );
    }

    // Assistant bubble
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Color(0xFF5D7DF5), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildContentWithTables(context, widget.content),
                  ),
                ),
                if (widget.metadata != null && widget.metadata!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _ProductCarousel(products: _currentProducts), // Use filtered list
                  const SizedBox(height: 16),
                  const Text(
                    "Do you want to see only the cheapest options, or filter by store?",
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFilterButton("Cheapest first", onTap: _sortCheapestFirst, isActive: _activeSort == 'Cheapest'),
                      const SizedBox(width: 8),
                      _buildFilterButton("Filter by store", onTap: _showStoreFilterDialog, isActive: _activeFilter != 'All'),
                      const SizedBox(width: 8),
                      if (_activeSort != 'Default' || _activeFilter != 'All')
                        _buildFilterButton("Reset", onTap: _resetFilters, isReset: true),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _activeSort = 'Default';
      _activeFilter = 'All';
      _currentProducts = List.from(widget.metadata!);
    });
  }

  Widget _buildFilterButton(String label, {required VoidCallback onTap, bool isActive = false, bool isReset = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isReset ? const Color(0xFFFEE2E2) : (isActive ? const Color(0xFFEFF6FF) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isReset ? const Color(0xFFFECACA) : (isActive ? const Color(0xFF4A6CF7) : const Color(0xFFE5E7EB))
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isReset ? const Color(0xFFDC2626) : (isActive ? const Color(0xFF4A6CF7) : const Color(0xFF1B1B25)), 
                fontSize: 13, 
                fontWeight: FontWeight.w600
              ),
            ),
             if (isActive) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check, size: 14, color: Color(0xFF4A6CF7)),
            ],
            if (isReset) ...[
              const SizedBox(width: 4),
              const Icon(Icons.close, size: 14, color: Color(0xFFDC2626)),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContentWithTables(BuildContext context, String data) {
    List<Widget> widgets = [];
    final lines = data.split('\n');
    List<String> currentTableLines = [];
    String currentTextBuffer = "";

    void flushTextBuffer() {
      if (currentTextBuffer.trim().isNotEmpty) {
        widgets.add(MarkdownBody(
          data: currentTextBuffer.trim(),
          styleSheet: MarkdownStyleSheet(
            p: GoogleFonts.outfit(color: const Color(0xFF1B1B25), fontSize: 15, height: 1.6),
            listBullet: GoogleFonts.outfit(color: const Color(0xFF1B1B25), fontSize: 15),
          ),
        ));
        currentTextBuffer = "";
      }
    }

    void flushTable() {
      if (currentTableLines.isEmpty) return;
      
      List<String> headers = [];
      List<List<String>> rows = [];
      
      // Parse table lines
      if (currentTableLines.length >= 2) {
        // Line 0: Header
        headers = currentTableLines[0]
            .split('|')
            .where((s) => s.trim().isNotEmpty)
            .map((s) => s.trim())
            .toList();
            
        // Skip Line 1 (separator) and parse the rest
        for (int i = 2; i < currentTableLines.length; i++) {
          final row = currentTableLines[i]
              .split('|')
              .where((s) => s.trim().isNotEmpty)
              .map((s) => s.trim())
              .toList();
          if (row.isNotEmpty) rows.add(row);
        }
      }

      if (headers.isNotEmpty || rows.isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: PremiumTable(headers: headers, rows: rows),
        ));
      } else {
        // If not a valid table, add as text
        currentTextBuffer += currentTableLines.join('\n') + '\n';
        flushTextBuffer();
      }
      currentTableLines = [];
    }

    for (var line in lines) {
      final trimmed = line.trim();
      final hasPipes = trimmed.contains('|') && trimmed.split('|').length > 2;
      
      if (hasPipes) {
        flushTextBuffer();
        currentTableLines.add(line); // Keep original for parsing
      } else if (currentTableLines.isNotEmpty) {
        // End of table block
        flushTable();
        if (trimmed.isNotEmpty) currentTextBuffer += line + '\n';
      } else {
        currentTextBuffer += line + '\n';
      }
    }
    
    flushTable();
    flushTextBuffer();

    if (widgets.isEmpty && data.isNotEmpty) {
      widgets.add(MarkdownBody(
        data: data,
        styleSheet: MarkdownStyleSheet(
          p: GoogleFonts.outfit(color: const Color(0xFF1B1B25), fontSize: 15, height: 1.6),
        ),
      ));
    }
    
    return widgets;
  }
}

class _ProductCarousel extends StatelessWidget {
  final List<dynamic> products;

  const _ProductCarousel({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
       return Container(
        height: 100,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list_off, color: Colors.grey.shade400, size: 30),
            const SizedBox(height: 8),
            Text(
              "No products match your filter",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _ProductCard(product: products[index]);
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final dynamic product;

  const _ProductCard({required this.product});

  void _showLargeImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String storeName = product['store'] ?? product['Store'] ?? 'Coles';
    final String productName = product['product'] ?? product['Product'] ?? 'Product';
    final String? itemName = product['item_name'] ?? product['ItemName'];
    final String price = product['price'] ?? product['Price'] ?? '';
    final String? deal = product['deal'] ?? product['Deal'];
    final String? imageUrl = product['image_url'] ?? product['Image'] ?? product['image'];

    return PremiumCard(
      padding: EdgeInsets.zero,
      color: Colors.white,
      width: 210,
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and Badge
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (imageUrl != null && imageUrl.isNotEmpty) {
                    _showLargeImage(context, imageUrl);
                  }
                },
                child: Container(
                  height: 160,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                      )
                    : const Center(child: Icon(Icons.fastfood, size: 40, color: Color(0xFFEEEEEE))),
                ),
              ),
              if (deal != null && deal.isNotEmpty)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      deal,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1B1B25), height: 1.3),
                ),
                itemName != null && itemName.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        itemName,
                        style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF4A6CF7), fontWeight: FontWeight.w600),
                      ),
                    )
                  : const SizedBox.shrink(),
                const SizedBox(height: 4),
                Text(
                  storeName,
                  style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF717171), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Text(
                  price,
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1B1B25)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BotTypingIndicator extends StatelessWidget {
  const _BotTypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFECF1F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(context),
            const SizedBox(width: 4),
            _dot(context),
            const SizedBox(width: 4),
            _dot(context),
          ],
        ),
      ),
    );
  }

  Widget _dot(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
    );
  }
}


