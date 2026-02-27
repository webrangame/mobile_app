import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api_service.dart';
import 'widgets/custom_widgets.dart';
import 'chat_screen.dart';

class StoreItemsScreen extends StatefulWidget {
  final String shopName;
  const StoreItemsScreen({super.key, required this.shopName});

  @override
  State<StoreItemsScreen> createState() => _StoreItemsScreenState();
}

class _StoreItemsScreenState extends State<StoreItemsScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isMoreLoading = false;
  List<dynamic> _items = [];
  String _errorMessage = '';
  int _offset = 0;
  final int _limit = 20;
  bool _hasMore = true;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isMoreLoading &&
        _hasMore) {
      _fetchMoreItems();
    }
  }

  Future<void> _fetchItems() async {
    try {
      _offset = 0;
      final items = await _apiService.getItemsByShop(
        widget.shopName, 
        search: _searchQuery,
        limit: _limit, 
        offset: _offset
      );
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
          _hasMore = items.length >= _limit;
          _offset += items.length;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchMoreItems() async {
    setState(() => _isMoreLoading = true);
    try {
      final items = await _apiService.getItemsByShop(
        widget.shopName, 
        search: _searchQuery,
        limit: _limit, 
        offset: _offset
      );
      if (mounted) {
        setState(() {
          _items.addAll(items);
          _isMoreLoading = false;
          _hasMore = items.length >= _limit;
          _offset += items.length;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isMoreLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B1B25), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.shopName,
          style: GoogleFonts.outfit(
            color: const Color(0xFF1B1B25),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  setState(() {
                    _searchQuery = value;
                    _isLoading = true;
                  });
                  _fetchItems();
                });
              },
              decoration: InputDecoration(
                hintText: "Search in ${widget.shopName}...",
                hintStyle: GoogleFonts.outfit(color: const Color(0xFFBDBDBD), fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4A6CF7), size: 20),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A6CF7)))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          "Failed to load items",
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(color: const Color(0xFF717171)),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = '';
                            });
                            _fetchItems();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A6CF7),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Retry", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : _items.isEmpty
                  ? Center(
                      child: Text(
                        "No items found for ${widget.shopName}",
                        style: GoogleFonts.outfit(color: const Color(0xFF717171)),
                      ),
                    )
                    : RefreshIndicator(
                        onRefresh: _fetchItems,
                        color: const Color(0xFF4A6CF7),
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: _items.length + (_isMoreLoading ? 2 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _items.length) {
                              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                            }
                            final item = _items[index];
                            return _buildItemCard(item);
                          },
                        ),
                      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    final String productName = item['product'] ?? 'Product';
    final String itemName = item['item_name'] ?? '';
    final String price = item['price'] ?? '';
    final String deal = item['deal'] ?? '';
    final String? imageUrl = item['thumbnail_url'] ?? item['image_url'];

    return PremiumCard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              initialQuery: "Tell me more about $productName $itemName at ${widget.shopName}",
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        cacheWidth: 300, // Optimize memory for thumbnails
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: Color(0xFFBDBDBD),
                          size: 32,
                        ),
                      )
                    : const Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xFFBDBDBD),
                        size: 32,
                      ),
              ),
            ),
          ),
          // Info Section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B1B25),
                    ),
                  ),
                  if (itemName.isNotEmpty)
                    Text(
                      itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: const Color(0xFF717171),
                      ),
                    ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4A6CF7),
                        ),
                      ),
                      if (deal.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8FFF3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            deal,
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ),
                    ],
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
