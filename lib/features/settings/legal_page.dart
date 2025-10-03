import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:brightside/core/theme/app_theme.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: AppTheme.paddingMedium),

          // Info card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Legal Information',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please review our legal documents to understand how we collect, use, and protect your information, as well as the terms governing your use of BrightSide.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppTheme.paddingLarge),

          // Privacy Policy
          _LegalLinkTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'How we collect and use your data',
            url: 'https://brightside.example.com/privacy',
            onTap: () => _openExternalUrl(
              context,
              'https://brightside.example.com/privacy',
            ),
          ),

          const Divider(),

          // Terms of Service
          _LegalLinkTile(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'Rules and guidelines for using BrightSide',
            url: 'https://brightside.example.com/terms',
            onTap: () => _openExternalUrl(
              context,
              'https://brightside.example.com/terms',
            ),
          ),

          const Divider(),

          // Content Policy
          _LegalLinkTile(
            icon: Icons.gavel,
            title: 'Content Policy',
            subtitle: 'Guidelines for submitted stories',
            url: 'https://brightside.example.com/content-policy',
            onTap: () => _openExternalUrl(
              context,
              'https://brightside.example.com/content-policy',
            ),
          ),

          const SizedBox(height: AppTheme.paddingLarge),

          // Footer note
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Text(
              'These links will open in Safari. The documents are currently placeholders and will be updated with final legal content before launch.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: AppTheme.paddingLarge),
        ],
      ),
    );
  }

  Future<void> _openExternalUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);

    try {
      // Launch with Safari View Controller on iOS
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Opens in Safari
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _LegalLinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String url;
  final VoidCallback onTap;

  const _LegalLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new, size: 20),
      onTap: onTap,
    );
  }
}
