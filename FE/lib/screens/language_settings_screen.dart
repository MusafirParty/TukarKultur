import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String selectedLanguage = 'English';
  String selectedRegion = 'United States';
  bool autoDetectLanguage = true;
  bool translateMessages = false;
  bool showTranslationSuggestions = true;

  final Map<String, String> languages = {
    'English': 'en',
    'Bahasa Indonesia': 'id',
    'Mandarin Chinese': 'zh',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
    'Japanese': 'ja',
    'Korean': 'ko',
    'Arabic': 'ar',
    'Hindi': 'hi',
    'Portuguese': 'pt',
    'Russian': 'ru',
    'Italian': 'it',
    'Dutch': 'nl',
    'Thai': 'th',
    'Vietnamese': 'vi',
  };

  final Map<String, String> regions = {
    'United States': 'US',
    'Indonesia': 'ID',
    'China': 'CN',
    'Spain': 'ES',
    'France': 'FR',
    'Germany': 'DE',
    'Japan': 'JP',
    'South Korea': 'KR',
    'United Kingdom': 'GB',
    'Canada': 'CA',
    'Australia': 'AU',
    'Brazil': 'BR',
    'Mexico': 'MX',
    'India': 'IN',
    'Thailand': 'TH',
    'Vietnam': 'VN',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFAF7),
      appBar: AppBar(
        backgroundColor: Color(0xFFFCFAF7),
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Language Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.27,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF9C854A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Language Section
            Text(
              'App Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffe8e0cf)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildLanguageTile(
                    'Display Language',
                    selectedLanguage,
                    'Choose your preferred language for the app',
                    () => _showLanguagePicker(),
                  ),
                  Divider(height: 1, color: Color(0xffe8e0cf)),
                  _buildLanguageTile(
                    'Region',
                    selectedRegion,
                    'Select your region for local content',
                    () => _showRegionPicker(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Translation Settings
            Text(
              'Translation Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffe8e0cf)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildToggleTile(
                    'Auto-detect Language',
                    'Automatically detect message language',
                    autoDetectLanguage,
                    (value) => setState(() => autoDetectLanguage = value),
                  ),
                  Divider(height: 1, color: Color(0xffe8e0cf)),
                  _buildToggleTile(
                    'Translate Messages',
                    'Automatically translate foreign messages',
                    translateMessages,
                    (value) => setState(() => translateMessages = value),
                  ),
                  Divider(height: 1, color: Color(0xffe8e0cf)),
                  _buildToggleTile(
                    'Translation Suggestions',
                    'Show translation options for messages',
                    showTranslationSuggestions,
                    (value) => setState(() => showTranslationSuggestions = value),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Language Exchange Preferences
            Text(
              'Language Exchange',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffe8e0cf)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Languages You Speak',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Let others know what languages you can help with',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildLanguageChip('English', true),
                      _buildLanguageChip('Bahasa Indonesia', false),
                      _buildLanguageChip('Mandarin Chinese', false),
                    ],
                  ),
                  SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _showLanguageSelectionDialog,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF9C854A)),
                      foregroundColor: Color(0xFF9C854A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Add Languages'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffe8e0cf)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Languages You\'re Learning',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Find people who can help you practice',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildLanguageChip('Spanish', true),
                      _buildLanguageChip('French', false),
                    ],
                  ),
                  SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _showLearningLanguageDialog,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF9C854A)),
                      foregroundColor: Color(0xFF9C854A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Add Learning Languages'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Download Languages
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF8F4E6),
                border: Border.all(color: Color(0xFFE8C4A0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.download, color: Color(0xFF9C854A)),
                      SizedBox(width: 8),
                      Text(
                        'Offline Translation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Download language packs for offline translation',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showDownloadLanguagesDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9C854A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Manage Downloaded Languages'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile(
    String title,
    String value,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9C854A),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFF9C854A),
      ),
    );
  }

  Widget _buildLanguageChip(String language, bool isSelected) {
    return Chip(
      label: Text(language),
      backgroundColor: isSelected ? Color(0xFF9C854A) : Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontSize: 12,
      ),
      deleteIcon: isSelected ? Icon(Icons.close, size: 16, color: Colors.white) : null,
      onDeleted: isSelected ? () {} : null,
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFFFCFAF7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 400,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  String language = languages.keys.elementAt(index);
                  return ListTile(
                    title: Text(language),
                    trailing: selectedLanguage == language
                        ? Icon(Icons.check, color: Color(0xFF9C854A))
                        : null,
                    onTap: () {
                      setState(() => selectedLanguage = language);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRegionPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFFFCFAF7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 400,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Region',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: regions.length,
                itemBuilder: (context, index) {
                  String region = regions.keys.elementAt(index);
                  return ListTile(
                    title: Text(region),
                    trailing: selectedRegion == region
                        ? Icon(Icons.check, color: Color(0xFF9C854A))
                        : null,
                    onTap: () {
                      setState(() => selectedRegion = region);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Languages You Speak'),
        content: Text('Language selection interface coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLearningLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Learning Languages'),
        content: Text('Learning language selection coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDownloadLanguagesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Offline Languages'),
        content: Text('Offline language management coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language settings saved successfully!'),
        backgroundColor: Color(0xFF9C854A),
      ),
    );
    Navigator.pop(context);
  }
}
