import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/server.dart';
import '../state/vpn_provider.dart';
import '../widgets/custom_widgets.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  // ignore: unused_field
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vpn = Provider.of<VpnProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.shield,
                color: colorScheme.onPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'XVPN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings),
            tooltip: 'Настройки',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Connection Status Card
                _buildConnectionStatusCard(vpn, colorScheme),
                const SizedBox(height: 12),
                
                // Server Selection Card
                _buildServerSelectionCard(vpn, colorScheme),
                const SizedBox(height: 12),
                
                // Action Buttons
                _buildActionButtons(vpn, colorScheme),
                const SizedBox(height: 12),
                
                // Statistics Cards Row
                _buildStatisticsRow(vpn, colorScheme),
                const SizedBox(height: 12),
                
                // Logs Card
                _buildLogsCard(vpn, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatusCard(VpnProvider vpn, ColorScheme colorScheme) {
    final isConnected = vpn.status == 'Подключено';
    final isConnecting = vpn.status == 'Подключение...';
    
    return Card(
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isConnected
                ? [Colors.green.shade400, Colors.green.shade600]
                : isConnecting
                    ? [Colors.orange.shade400, Colors.orange.shade600]
                    : [Colors.grey.shade400, Colors.grey.shade600],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            VpnToggleSwitch(
              isConnected: isConnected,
              isConnecting: isConnecting,
              onToggle: isConnected ? vpn.disconnect : vpn.connect,
            ),
            const SizedBox(height: 12),
            Text(
              vpn.status,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (isConnected && vpn.selected != null) ...[
              const SizedBox(height: 6),
              Text(
                'Подключен к ${vpn.selected!.name}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServerSelectionCard(VpnProvider vpn, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dns,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Выбор сервера',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Server>(
                  isExpanded: true,
                  value: vpn.selected,
                  icon: Icon(Icons.expand_more, color: colorScheme.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  items: vpn.servers
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: s.isBuiltIn 
                                        ? Colors.green 
                                        : colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        s.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${s.address}:${s.port}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (s.isBuiltIn)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      'ВСТРОЕННЫЙ',
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (s) => vpn.selectServer(s),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(VpnProvider vpn, ColorScheme colorScheme) {
    return Column(
      children: [
        // Main Connection Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: vpn.status == 'Подключено' 
                ? vpn.disconnect
                : (vpn.filesReady && vpn.selected != null && vpn.status != 'Подключение...')
                    ? vpn.connect 
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: vpn.status == 'Подключено' 
                  ? Colors.red.shade500
                  : colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  vpn.status == 'Подключено' 
                      ? Icons.stop 
                      : Icons.play_arrow,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  vpn.status == 'Подключено' ? 'Отключиться' : 'Подключиться',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Warning message
        if (!vpn.filesReady) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: colorScheme.onErrorContainer,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Не найден файл sing-box.exe. Подключение невозможно.',
                    style: TextStyle(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Secondary Action Buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildActionChip(
              icon: Icons.add,
              label: 'Добавить',
              onPressed: () => _showAddServerDialog(context, vpn),
              colorScheme: colorScheme,
            ),
            _buildActionChip(
              icon: Icons.delete,
              label: 'Удалить',
              onPressed: vpn.selected != null && !vpn.selected!.isBuiltIn 
                  ? () => _showDeleteConfirmation(context, vpn)
                  : null,
              colorScheme: colorScheme,
            ),
            _buildActionChip(
              icon: Icons.network_ping,
              label: 'Пинг',
              onPressed: vpn.selected != null ? vpn.measurePing : null,
              colorScheme: colorScheme,
            ),
            _buildActionChip(
              icon: Icons.medical_services,
              label: 'Диагностика',
              onPressed: () => vpn.runDiagnostics(),
              colorScheme: colorScheme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    required ColorScheme colorScheme,
  }) {
    return ActionChip(
      avatar: Icon(
        icon, 
        size: 16,
        color: onPressed != null 
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurface,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: onPressed != null 
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurface,
          fontSize: 12,
        ),
      ),
      onPressed: onPressed,
      backgroundColor: onPressed != null 
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildStatisticsRow(VpnProvider vpn, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: StatisticCard(
            title: 'Статус',
            value: vpn.status,
            icon: Icons.speed,
            gradientColors: [
              colorScheme.primaryContainer,
              colorScheme.primary,
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatisticCard(
            title: 'Пинг',
            value: vpn.ping.isNotEmpty ? _extractPingTime(vpn.ping) : 'N/A',
            icon: Icons.timer,
            gradientColors: [
              colorScheme.secondaryContainer,
              colorScheme.secondary,
            ],
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsCard(VpnProvider vpn, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.terminal, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Логи подключения',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                if (vpn.logOutput.isNotEmpty)
                  IconButton.filledTonal(
                    onPressed: () => _copyLogs(context, vpn.logOutput),
                    icon: const Icon(Icons.copy, size: 16),
                    tooltip: 'Копировать логи',
                    iconSize: 16,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: SelectableText(
                  vpn.logOutput.isEmpty ? 'Логи появятся здесь...' : vpn.logOutput,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: vpn.logOutput.isEmpty 
                        ? colorScheme.onSurface.withOpacity(0.5)
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyLogs(BuildContext context, String logs) {
    Clipboard.setData(ClipboardData(text: logs));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check, color: Colors.white),
            SizedBox(width: 8),
            Text('Логи скопированы в буфер обмена'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _extractPingTime(String pingOutput) {
    final regex = RegExp(r'время[<>=]\s*(\d+)\s*мс');
    final match = regex.firstMatch(pingOutput);
    return match != null ? '${match.group(1)}ms' : 'N/A';
  }

  void _showAddServerDialog(BuildContext context, VpnProvider vpn) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline),
            SizedBox(width: 8),
            Text('Добавить сервер'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'VLESS URL',
                hintText: 'vless://...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.link),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste),
                  tooltip: 'Вставить из буфера',
                  onPressed: () async {
                    try {
                      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                      if (clipboardData != null && clipboardData.text != null) {
                        controller.text = clipboardData.text!;
                      }
                    } catch (e) {
                      // Игнорируем ошибки доступа к буферу обмена
                    }
                  },
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final srv = parseVless(controller.text.trim());
      if (srv != null) {
        await vpn.addServer(srv);
        final operationResult = vpn.lastOperationResult;
        if (operationResult == 'success') {
          _showSnackBar(context, 'Сервер успешно добавлен!', Icons.check, Colors.green);
        } else if (operationResult != null && operationResult.startsWith('error:')) {
          final errorMessage = operationResult.substring(6);
          _showSnackBar(context, 'Ошибка: $errorMessage', Icons.error, Colors.red);
        }
        vpn.clearLastOperationResult();
      } else {
        _showSnackBar(context, 'Неверный VLESS URL', Icons.error, Colors.red);
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context, VpnProvider vpn) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Удалить сервер'),
          ],
        ),
        content: Text('Вы уверены, что хотите удалить сервер "${vpn.selected?.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      vpn.removeServer(vpn.selected!);
      _showSnackBar(context, 'Сервер удален', Icons.delete, Colors.orange);
    }
  }

  // ignore: unused_element
  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Настройки',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('О приложении'),
              onTap: () => _showAboutDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Сообщить об ошибке'),
              onTap: () => _showReportDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'XVPN',
      applicationVersion: '1.2.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
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
        Text('Создан с использованием Flutter и sing-box'),
      ],
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сообщить об ошибке'),
        content: const Text(
          'Для сообщения об ошибках и предложений:\n\n'
          '• Создайте Issue на GitHub\n'
          '• Приложите логи диагностики\n'
          '• Опишите шаги воспроизведения',
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

  void _showSnackBar(BuildContext context, String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Парсер VLESS URL для извлечения параметров сервера
Server? parseVless(String url) {
  try {
    if (!url.startsWith('vless://')) return null;
    
    final uri = Uri.parse(url);
    final id = uri.userInfo;
    final address = uri.host;
    final port = uri.port;
    
    final queryParams = uri.queryParameters;
    final sni = queryParams['sni'] ?? address;
    final sid = queryParams['sid'] ?? '';
    final fp = queryParams['fp'] ?? 'chrome';
    final pbk = queryParams['pbk'] ?? '';
    
    // Создаем имя сервера из адреса
    final name = 'Server ${address}:${port}';
    
    return Server(
      name: name,
      address: address,
      port: port,
      id: id,
      pbk: pbk,
      sni: sni,
      sid: sid,
      fp: fp,
      isBuiltIn: false,
    );
  } catch (e) {
    return null;
  }
}
