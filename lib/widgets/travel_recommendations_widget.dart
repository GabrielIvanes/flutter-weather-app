import 'package:flutter/material.dart';

class TravelRecommendationsWidget extends StatelessWidget {
  final String response;

  const TravelRecommendationsWidget({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSection(
            title: 'Suitcase Recommendations',
            icon: Icons.luggage,
            content: _extractSection(response, 'Suitcase Recommendations'),
            context: context,
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Recommended Activities',
            icon: Icons.local_activity,
            content: _extractSection(response, 'Recommended Activities'),
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _extractSection(String response, String sectionTitle) {
    final RegExp regex = RegExp(
      r'\*\*' + sectionTitle + r'\*\*:?\s*(.*?)(?=\*\*|$)',
      dotAll: true,
    );
    final match = regex.firstMatch(response);
    return match?.group(1)?.trim() ?? 'No recommendations available';
  }
}
