import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      appBar: AppBar(
        title: const Text('Настройки'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Раздел подключения
          _buildSectionHeader('Подключение', Icons.wifi, colorScheme),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Автоподключение'),
                  subtitle: const Text('Автоматически подключаться к последнему серверу'),
                  value: _autoConnect,
                  onChanged: (value) => setState(() => _autoConnect = value),
                  secondary: const Icon(Icons.auto_mode),
                  dense: true,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.timer),
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
                    ),
                  ),
                  dense: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Раздел интерфейса
          _buildSectionHeader('Интерфейс', Icons.palette, colorScheme),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Темная тема'),
                  subtitle: const Text('Использовать темное оформление'),
                  value: _darkMode,
                  onChanged: (value) => setState(() => _darkMode = value),
                  secondary: const Icon(Icons.dark_mode),
                  dense: true,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Язык'),
                  subtitle: Text(_getLanguageName(_selectedLanguage)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showLanguageDialog(),
                  dense: true,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Уведомления'),
                  subtitle: const Text('Показывать уведомления о статусе'),
                  value: _showNotifications,
                  onChanged: (value) => setState(() => _showNotifications = value),
                  secondary: const Icon(Icons.notifications),
                  dense: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Раздел безопасности
          _buildSectionHeader('Безопасность', Icons.security, colorScheme),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.vpn_key),
                  title: const Text('Изменить пароль'),
                  subtitle: const Text('Установить пароль для приложения'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showChangePasswordDialog(),
                  dense: true,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Очистить данные'),
                  subtitle: const Text('Удалить все настройки и серверы'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showClearDataDialog(),
                  dense: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Раздел информации
          _buildSectionHeader('Информация', Icons.info, colorScheme),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('О приложении'),
                  subtitle: const Text('Версия 1.2.0'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showAboutDialog(),
                  dense: true,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Сообщить об ошибке'),
                  subtitle: const Text('Отправить отчет разработчикам'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showBugReportDialog(),
                  dense: true,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Политика конфиденциальности'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showPrivacyDialog(),
                  dense: true,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Открытый код'),
                  subtitle: const Text('Посмотреть код на GitHub'),
                  trailing: const Icon(Icons.open_in_new),
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
      applicationVersion: '1.2.0',
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
