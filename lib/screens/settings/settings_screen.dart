import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'),
      ),
      body: ListView
      (
children: [
// Notifications
_buildSection('Notifications'),
SwitchListTile(
title: Text('Activer les notifications'),
subtitle: Text('Recevoir des alertes pour vos réservations'),
value: _notificationsEnabled,
onChanged: (value) {
setState(() {
_notificationsEnabled = value;
});
},
activeColor: AppColors.primary,
),
SwitchListTile(
title: Text('Notifications email'),
value: _emailNotifications,
onChanged: _notificationsEnabled
? (value) {
setState(() {
_emailNotifications = value;
});
}
: null,
activeColor: AppColors.primary,
),
SwitchListTile(
title: Text('Notifications SMS'),
value: _smsNotifications,
onChanged: _notificationsEnabled
? (value) {
setState(() {
_smsNotifications = value;
});
}
: null,
activeColor: AppColors.primary,
),
      Divider(),
      
      // Apparence
      _buildSection('Apparence'),
      
      Divider(),
      
      // Langue
      _buildSection('Langue'),
      ListTile(
        leading: Icon(Icons.language, color: AppColors.primary),
        title: Text('Langue de l\'application'),
        subtitle: Text('Français'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showLanguageDialog();
        },
      ),
      
      Divider(),
      
      // Confidentialité
      _buildSection('Confidentialité et Sécurité'),
      ListTile(
        leading: Icon(Icons.lock, color: AppColors.primary),
        title: Text('Changer le mot de passe'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Change password
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fonctionnalité à venir')),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.privacy_tip, color: AppColors.primary),
        title: Text('Politique de confidentialité'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Privacy policy
        },
      ),
      ListTile(
        leading: Icon(Icons.description, color: AppColors.primary),
        title: Text('Conditions d\'utilisation'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Terms
        },
      ),
      
      Divider(),
      
      // Données
      _buildSection('Données'),
      ListTile(
        leading: Icon(Icons.delete_forever, color: AppColors.error),
        title: Text(
          'Supprimer mon compte',
          style: TextStyle(color: AppColors.error),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.error),
        onTap: () {
          _showDeleteAccountDialog();
        },
      ),
      
      SizedBox(height: 32),
      
      // Version
      Center(
        child: Text(
          'Version 1.0.0',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
      
      SizedBox(height: 32),
    ],
  ),
);
}
Widget _buildSection(String title) {
return Padding(
padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
child: Text(
title,
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.bold,
color: AppColors.primary,
),
),
);
}
void _showLanguageDialog() {
showDialog(
context: context,
builder: (context) => AlertDialog(
title: Text('Choisir la langue'),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
RadioListTile(
title: Text('Français'),
value: 'fr',
groupValue: 'fr',
onChanged: (value) {
Navigator.pop(context);
},
activeColor: AppColors.primary,
),
RadioListTile(
title: Text('العربية'),
value: 'ar',
groupValue: 'fr',
onChanged: (value) {
Navigator.pop(context);
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Fonctionnalité à venir')),
);
},
activeColor: AppColors.primary,
),
RadioListTile(
title: Text('English'),
value: 'en',
groupValue: 'fr',
onChanged: (value) {
Navigator.pop(context);
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Fonctionnalité à venir')),
);
},
activeColor: AppColors.primary,
),
],
),
),
);
}
void _showDeleteAccountDialog() {
showDialog(
context: context,
builder: (context) => AlertDialog(
title: Text('Supprimer le compte'),
content: Text(
'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: Text('Annuler'),
),
TextButton(
onPressed: () {
Navigator.pop(context);
// TODO: Delete account
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Fonctionnalité à venir'),
backgroundColor: AppColors.error,
),
);
},
child: Text(
'Supprimer',
style: TextStyle(color: AppColors.error),
),
),
],
),
);
}
}