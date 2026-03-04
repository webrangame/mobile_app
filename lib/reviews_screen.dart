import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'services/api_service.dart';
import 'widgets/custom_widgets.dart';
import 'utils/user_utils.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _reviews = [];
  bool _isLoading = true;
  String? _error;
  int _selectedFilter = 0; // 0 for All, 1-5 for star counts

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final reviews = await _apiService.fetchReviews();
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredReviews {
    if (_selectedFilter == 0) return _reviews;
    return _reviews.where((r) => r['rating'] == _selectedFilter).toList();
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold<int>(0, (sum, r) => sum + (r['rating'] as int));
    return double.parse((total / _reviews.length).toStringAsFixed(1));
  }

  void _showAddReviewDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddReviewDialog(
        apiService: _apiService,
        onSuccess: () {
          _loadReviews();
          _showSuccessDialog();
        },
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Color(0xFF717171), size: 20),
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Color(0xFF2E7D32),
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Thank you for your review!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B25),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your feedback helps us improve the app and assist shoppers better. Your rating has been added successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF717171),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
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
          'Reviews & Ratings',
          style: GoogleFonts.outfit(
            color: const Color(0xFF1B1B25),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorPlaceholder()
                  : _reviews.isEmpty
                      ? _buildEmptyPlaceholder()
                      : _buildReviewsContent(),
          
          // Fixed Bottom Button
          if (!_isLoading && _error == null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: PremiumButton(
                text: 'Add Review',
                onPressed: _showAddReviewDialog,
                icon: Icons.add_rounded,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewsContent() {
    return Column(
      children: [
        // Overall Rating Section
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            children: [
              Text(
                'Overall Rating',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF717171),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$_averageRating',
                style: GoogleFonts.outfit(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B1B25),
                  letterSpacing: -1,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    index < _averageRating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 28,
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                'Based on ${_reviews.length} reviews',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: const Color(0xFFBDBDBD),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Filter Section
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildFilterChip(0, 'All'),
              const SizedBox(width: 8),
              ...List.generate(5, (index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(5 - index, '${5 - index}', hasStar: true),
              )),
            ],
          ),
        ),

        const SizedBox(height: 16),
        
        // Reviews List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
            itemCount: _filteredReviews.length,
            itemBuilder: (context, index) {
              final review = _filteredReviews[index];
              return _buildReviewCard(review);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(int rating, String label, {bool hasStar = false}) {
    final isSelected = _selectedFilter == rating;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = rating),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A6CF7) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A6CF7) : const Color(0xFFEEEEEE),
          ),
        ),
        child: Row(
          children: [
            if (hasStar) const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
            if (hasStar) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1B1B25),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(dynamic review) {
    DateTime? date;
    try {
      if (review['created_at'] != null) {
        date = DateTime.parse(review['created_at'].toString());
      }
    } catch (_) {}
    
    final formattedDate = date != null ? DateFormat('MMM d, y').format(date) : 'N/A';
    final userName = UserUtils.formatUserName(review['user_name']?.toString());
    final initial = UserUtils.getInitials(userName);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F3F3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFF0F4FF),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Color(0xFF4A6CF7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: const Color(0xFF1B1B25),
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: const Color(0xFFAFAFAF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < (review['rating'] ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'] ?? '',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: const Color(0xFF4B5563),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.reviews_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'No reviews yet',
            style: TextStyle(color: Color(0xFF717171), fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF717171)),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _loadReviews,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddReviewDialog extends StatefulWidget {
  final ApiService apiService;
  final VoidCallback onSuccess;

  const _AddReviewDialog({required this.apiService, required this.onSuccess});

  @override
  State<_AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<_AddReviewDialog> {
  int _localRating = 5;
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Write a Review',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B1B25),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share your experience with Australia Price Comparison',
            style: TextStyle(color: Color(0xFF717171), fontSize: 14),
          ),
          const SizedBox(height: 20),
          // Star Selector
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _localRating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() => _localRating = index + 1);
                  },
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'What did you think of the agent?',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: const Color(0xFFF8FAFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (_controller.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please write a comment')),
                        );
                        return;
                      }
                      setState(() => _isSubmitting = true);
                      try {
                        await widget.apiService.submitReview(
                          rating: _localRating,
                          comment: _controller.text.trim(),
                        );
                        if (mounted) {
                          Navigator.pop(context);
                          widget.onSuccess();
                        }
                      } catch (e) {
                        setState(() => _isSubmitting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6CF7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Submit Review',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
