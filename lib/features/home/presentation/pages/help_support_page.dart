import 'package:flutter/material.dart';
import 'package:harvesthub/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          loc.helpAndSupportTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Features Section
            _buildSectionCard(
              context,
              title: loc.appFeaturesTitle,
              icon: Icons.star_rounded,
              children: [
                _buildFeatureItem(
                  context,
                  icon: Icons.wb_sunny_rounded,
                  title: loc.weatherUpdatesFeature,
                  description: loc.weatherUpdatesDesc,
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  context,
                  icon: Icons.smart_toy_rounded,
                  title: loc.aiChatFeature,
                  description: loc.aiChatDesc,
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  context,
                  icon: Icons.pest_control_rounded,
                  title: loc.pestDetectionFeature,
                  description: loc.pestDetectionDesc,
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  context,
                  icon: Icons.people_alt_rounded,
                  title: loc.communityFeature,
                  description: loc.communityDesc,
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  context,
                  icon: Icons.language_rounded,
                  title: loc.multiLanguageFeature,
                  description: loc.multiLanguageDesc,
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  context,
                  icon: Icons.person_rounded,
                  title: loc.profileManagementFeature,
                  description: loc.profileManagementDesc,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Getting Started Section
            _buildSectionCard(
              context,
              title: loc.gettingStartedTitle,
              icon: Icons.play_circle_rounded,
              children: [
                _buildStep(context, loc.gettingStartedStep1),
                _buildStep(context, loc.gettingStartedStep2),
                _buildStep(context, loc.gettingStartedStep3),
                _buildStep(context, loc.gettingStartedStep4),
                _buildStep(context, loc.gettingStartedStep5),
              ],
            ),

            const SizedBox(height: 20),

            // Features & Usage Section
            _buildSectionCard(
              context,
              title: loc.featuresAndUsageTitle,
              icon: Icons.help_rounded,
              children: [
                _buildUsageItem(
                  context,
                  title: loc.weatherUsageTitle,
                  description: loc.weatherUsageDesc,
                ),
                const SizedBox(height: 16),
                _buildUsageItem(
                  context,
                  title: loc.aiChatUsageTitle,
                  description: loc.aiChatUsageDesc,
                ),
                const SizedBox(height: 16),
                _buildUsageItem(
                  context,
                  title: loc.pestDetectionUsageTitle,
                  description: loc.pestDetectionUsageDesc,
                ),
                const SizedBox(height: 16),
                _buildUsageItem(
                  context,
                  title: loc.communityUsageTitle,
                  description: loc.communityUsageDesc,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Troubleshooting Section
            _buildSectionCard(
              context,
              title: loc.troubleshootingTitle,
              icon: Icons.build_rounded,
              children: [
                _buildTroubleshootingItem(
                  context,
                  title: loc.locationIssues,
                  description: loc.locationIssuesDesc,
                ),
                const SizedBox(height: 16),
                _buildTroubleshootingItem(
                  context,
                  title: loc.weatherNotLoading,
                  description: loc.weatherNotLoadingDesc,
                ),
                const SizedBox(height: 16),
                _buildTroubleshootingItem(
                  context,
                  title: loc.aiNotResponding,
                  description: loc.aiNotRespondingDesc,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Contact Support Section
            _buildSectionCard(
              context,
              title: loc.contactSupportTitle,
              icon: Icons.contact_support_rounded,
              children: [
                Text(
                  loc.contactSupportDesc,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildContactItem(
                  context,
                  icon: Icons.email_rounded,
                  text: loc.emailSupport,
                ),
                const SizedBox(height: 12),
                _buildContactItem(
                  context,
                  icon: Icons.bug_report_rounded,
                  text: loc.reportIssue,
                ),
                const SizedBox(height: 12),
                _buildContactItem(
                  context,
                  icon: Icons.web_rounded,
                  text: loc.visitWebsite,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.appVersion,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConstants.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.lastUpdated,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConstants.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppConstants.primaryGreen, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppConstants.primaryGreen, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep(BuildContext context, String step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppConstants.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              step,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildTroubleshootingItem(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.orange.shade700,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppConstants.primaryGreen, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
