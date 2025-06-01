import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_recommendations_client.dart';
import '../models/nutrient_status.dart';
import '../theme/nutriwave_theme.dart';

class AIRecommendationsDialog extends StatefulWidget {
  final List<NutrientStatus> nutritionData;

  const AIRecommendationsDialog({
    super.key,
    required this.nutritionData,
  });

  @override
  State<AIRecommendationsDialog> createState() => _AIRecommendationsDialogState();
}

class _AIRecommendationsDialogState extends State<AIRecommendationsDialog> {
  final AIRecommendationsClient _aiClient = AIRecommendationsClient();
  
  bool _isLoading = true;
  String? _recommendations;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getRecommendations();
  }

  Future<void> _getRecommendations() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _recommendations = null;
    });

    final result = await _aiClient.getRecommendations(
      nutritionData: widget.nutritionData,
      userPreferences: null, // No preferences field needed
    );

    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _recommendations = result.recommendations;
      } else {
        _error = result.error;
      }
    });
  }

  Widget _buildFormattedRecommendations(String text) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) {
          return const SizedBox(height: 8);
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildFormattedLine(line),
        );
      }).toList(),
    );
  }

  Widget _buildFormattedLine(String line) {
    final parts = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;
    
    for (final match in regex.allMatches(line)) {
      // Add text before the bold part
      if (match.start > lastIndex) {
        parts.add(TextSpan(
          text: line.substring(lastIndex, match.start),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.6,
          ),
        ));
      }
      
      // Add the bold part
      parts.add(TextSpan(
        text: match.group(1),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          height: 1.6,
        ),
      ));
      
      lastIndex = match.end;
    }
    
    // Add remaining text
    if (lastIndex < line.length) {
      parts.add(TextSpan(
        text: line.substring(lastIndex),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          height: 1.6,
        ),
      ));
    }
    
    return SelectableText.rich(
      TextSpan(children: parts),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: isTablet ? 600 : screenSize.width * 0.9,
        height: screenSize.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [context.primaryGreen, context.darkTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Nutrition Coach',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Personalized recommendations for your goals',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Content Area
            Expanded(
              child: Container(
                width: double.infinity,
                child: _buildContentArea(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(context.primaryGreen),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              '🤖 AI is analyzing your nutrition...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Preparing personalized recommendations',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Colors.orange.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'AI service temporarily unavailable',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Don\'t worry! We\'ve provided smart recommendations based on nutrition science.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _getRecommendations,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_recommendations != null) {
      return Column(
        children: [
          // Recommendations content (no header bar)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildFormattedRecommendations(_recommendations!),
            ),
          ),
        ],
      );
    }

    // This shouldn't happen, but just in case
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.restaurant,
                size: 48,
                color: context.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ready to optimize your nutrition?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading your personalized recommendations...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}