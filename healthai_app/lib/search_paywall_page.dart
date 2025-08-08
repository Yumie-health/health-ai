import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'subscription_page.dart';

class SearchPaywallPage extends StatelessWidget {
  final VoidCallback onUpgrade;
  final ValueChanged<BuildContext> onWatchAd;
  final VoidCallback onDiscard;

  const SearchPaywallPage({
    Key? key,
    required this.onUpgrade,
    required this.onWatchAd,
    required this.onDiscard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade900, Colors.purple.shade900],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Icon(Icons.search, color: Colors.amber, size: 80), // Search icon
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.upgradeToPremium,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.getUnlimitedSearches,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: Icon(Icons.workspace_premium, color: Colors.amber, size: 32),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: Text(AppLocalizations.of(context)!.upgradePlan, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    minimumSize: Size(double.infinity, 60),
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.5),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SubscriptionPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDiscard,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(AppLocalizations.of(context)!.discard, style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => onWatchAd(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: Text(AppLocalizations.of(context)!.watchAdForSearch, style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
