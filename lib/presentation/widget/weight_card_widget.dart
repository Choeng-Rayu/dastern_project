import 'package:flutter/material.dart';
import '/models/patient.dart';
import 'health_metric_widget.dart';

/// Reusable widget for displaying the weight card with health metrics
class WeightCardWidget extends StatelessWidget {
  final Patient patient;

  const WeightCardWidget({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Weight circle
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: 0.7,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Text(
                  '${patient.weight?.toInt() ?? 0} kg',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Health metrics
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HealthMetricWidget(
                  title: 'ការបង្ការផ្តុំនូវឬសឬស្សីអាចជួយ',
                  subtitle: 'បង្កើតការថែទាំអ្នកជំងឺ',
                  icon: Icons.check_circle,
                ),
                SizedBox(height: 8),
                HealthMetricWidget(
                  title: 'សុខភាពល្អបង្កើតអាហារបែបនេះ',
                  subtitle: 'អាហារ ២ ដងក្នុងមួយថ្ងៃ',
                  icon: Icons.restaurant,
                ),
                SizedBox(height: 8),
                HealthMetricWidget(
                  title: 'ហេតុផលដែលធ្វើឲ្យសុខភាពល្អបើ',
                  subtitle: '',
                  icon: Icons.favorite,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
