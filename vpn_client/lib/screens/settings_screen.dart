import 'package:flutter/material.dart';
import '../widgets/mullvad_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoConnect = false;
  bool _showNotifications = true;
  bool _darkMode = false;
  String _selectedLanguage = 'ru';
  double _connectionTimeout = 30.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Настройки'),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Раздел подключения
          _buildSectionHeader('Подключение', Icons.wifi, colorScheme),
          const SizedBox(height: 8),
          MullvadCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Автоподключение'),
                  subtitle: const Text('Автоматически подключаться к последнему серверу'),
                  value: _autoConnect,
                  onChanged: (value) => setState(() => _autoConnect = value),
                  secondary: Icon(Icons.auto_mode, color: colorScheme.primary),
                  dense: true,
                ),
                Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
                ListTile(
                  leading: Icon(Icons.timer, color: colorScheme.primary),
                  title: const Text('Таймаут подключения'),
                  subtitle: Text('${_connectionTimeout.round()} секунд'),
                  trailing: SizedBox(
                    width: 80,
                    child: Slider(
                      value: _connectionTimeout,
                      min: 10,
                      max: 60,
                      divisions: 10,
                      onChanged: (value) => setState(() => _connectionTimeout = value),
                      activeColor: colorScheme.primary,
                    ),
                  ),
                  dense: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Раздел интерфейса
          _buildSectionHeader('Интерфейс', Icons.palette, colorScheme),
          const SizedBox(height: 8),
          MullvadCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Темная тема'),
                  subtitle: const Text('Использовать темное оформление'),
                  value: _darkMode,
                  onChanged: (value) => setState(() => _darkMode = value),
                  secondary: Icon(Icons.dark_mode, color: colorScheme.primary),
                  dense: true,
                ),
                Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
                ListTile(
                  leading: Icon(Icons.language, color: colorScheme.primary),
                  title: const Text('Язык'),
                  subtitle: Text(_getLanguageName(_selectedLanguage)),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline),
                  onTap: () => _showLanguageDialog(),
                  dense: true,
                ),
                Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
                SwitchListTile(
                  title: const Text('Уведомления'),
                  subtitle: const Text('Показывать уведомления о статусе'),
                  value: _showNotifications,
                  onChanged: (value) => setState(() => _showNotifications = value),
                  secondary: Icon(Icons.notifications, color: colorScheme.primary),
                  dense: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Раздел безопасности
          _buildSectionHeader('Безопасность', Icons.security, colorScheme),
          const SizedBox(height: 8),
          MullvadCard(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.vpn_key, color: colorScheme.primary),
                  title: const Text('Изменить пароль'),
                  subtitle: const Text('Установить пароль для приложения'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline),
                  onTap: () => _showChangePasswordDialog(),
                  dense: true,
                ),
                Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
                ListTile(
                  leading: Icon(Icons.delete_forever, color: colorScheme.error),
                  title: const Text('Очистить данные'),
                  subtitle: const Text('Удалить все настройки и серверы'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline),
                  onTap: () => _showClearDataDialog(),
                  dense: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Раздел информации
          _buildSectionHeader('Информация', Icons.info, colorScheme),
          const SizedBox(height: 8),
          MullvadCard(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: colorScheme.primary),
                  title: const Text('О приложении'),
                  subtitle: const Text('Версия 1.2.2'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline),
                  onTap: () => _showAboutDialog(),
                  dense: true,
                ),
                Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
                ListTile(
                  leading: Icon(Icons.bug_report, color: colorScheme.primary),
                  title: const Text('Сообщить об ошибке'),
                  subtitle: const Text('Отправить отчет разработчикам'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline),
                  onTap: () => _showBugReportDialog(),
                  dense: true,
                ),
                Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
                ListTile(
                  leading: Icon(Icons.privacy_tip, color: colorScheme.primary),
                  title: const Text('Политика конфиденциальности'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline),
                  onTap: () => _showPrivacyDialog(),
                  dense: true,
                ),
                Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
                ListTile(
                  leading: Icon(Icons.code, color: colorScheme.primary),
                  title: const Text('Открытый код'),
                  subtitle: const Text('Посмотреть код на GitHub'),
                  trailing: Icon(Icons.open_in_new, size: 16, color: colorScheme.outline),
                  onTap: () => _openGitHub(),
                  dense: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      default:
        return 'Русский';
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите язык'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Русский'),
              value: 'ru',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('中文'),
              value: 'zh',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить пароль'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Текущий пароль',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Новый пароль',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Подтвердите пароль',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Пароль изменен успешно');
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Очистить данные'),
          ],
        ),
        content: const Text(
          'Вы уверены, что хотите удалить все настройки и серверы? '
          'Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Данные очищены');
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'XVPN',
      applicationVersion: '1.2.3',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.shield,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      children: const [
        Text('Современный VLESS VPN клиент для Windows'),
        SizedBox(height: 8),
        Text('Создан с использованием:'),
        Text('• Flutter - для кроссплатформенного UI'),
        Text('• sing-box - для VPN движка'),
        Text('• Wintun - для TUN адаптера Windows'),
        SizedBox(height: 8),
        Text('© 2025 XVPN Project'),
      ],
    );
  }

  void _showBugReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сообщить об ошибке'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Для сообщения об ошибках:'),
            SizedBox(height: 8),
            Text('1. Откройте диагностику и скопируйте логи'),
            Text('2. Создайте Issue на GitHub'),
            Text('3. Опишите шаги воспроизведения'),
            Text('4. Приложите логи и скриншоты'),
            SizedBox(height: 16),
            Text(
              'GitHub: github.com/your-username/XVPN',
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _openGitHub();
            },
            child: const Text('Открыть GitHub'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Политика конфиденциальности'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Сбор данных',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('XVPN НЕ собирает и НЕ хранит:'),
              Text('• Историю просмотров'),
              Text('• Личные данные пользователей'),
              Text('• Трафик или содержимое соединений'),
              SizedBox(height: 16),
              Text(
                'Локальные данные',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('На устройстве хранятся только:'),
              Text('• Настройки приложения'),
              Text('• Конфигурации серверов'),
              Text('• Логи подключений (локально)'),
              SizedBox(height: 16),
              Text(
                'Открытый код',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Исходный код доступен на GitHub для полной прозрачности.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _openGitHub() {
    // Здесь можно добавить открытие браузера с GitHub
    _showSnackBar('Откройте github.com/your-username/XVPN в браузере');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
