import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/server.dart';
import '../state/vpn_provider.dart';
import '../widgets/mullvad_widgets.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vpn = Provider.of<VpnProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Mullvad-style App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'XVPN',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ),
                icon: Icon(
                  Icons.settings_outlined,
                  color: colorScheme.onSurface,
                ),
                tooltip: 'Настройки',
              ),
            ],
          ),
          
          // Main Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Connection Status Hero
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildConnectionHero(vpn, colorScheme),
                ),
                
                const SizedBox(height: 24),
                
                // Server Selection
                _buildServerSelection(vpn, colorScheme),
                
                const SizedBox(height: 20),
                
                // Quick Actions
                _buildQuickActions(vpn, colorScheme),
                
                const SizedBox(height: 20),
                
                // Status Cards
                _buildStatusCards(vpn, colorScheme),
                
                const SizedBox(height: 20),
                
                // Logs Section (collapsed by default)
                _buildLogsSection(vpn, colorScheme),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionHero(VpnProvider vpn, ColorScheme colorScheme) {
    final isConnected = vpn.status == 'Подключено';
    final isConnecting = vpn.status == 'Подключение...';
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isConnected
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : isConnecting
                  ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                  : [colorScheme.surfaceVariant, colorScheme.outline],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isConnected ? const Color(0xFF10B981) : colorScheme.primary).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status Icon with pulse animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isConnecting ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isConnected
                        ? Icons.shield
                        : isConnecting
                            ? Icons.sync
                            : Icons.shield_outlined,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Status Text
          Text(
            vpn.status,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          
          if (isConnected && vpn.selected != null) ...[
            const SizedBox(height: 8),
            Text(
              vpn.selected!.name,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Main Connect Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: vpn.status == 'Подключено'
                  ? vpn.disconnect
                  : (vpn.filesReady && vpn.selected != null && vpn.status != 'Подключение...')
                      ? vpn.connect
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: isConnected 
                    ? const Color(0xFFDC2626) 
                    : colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    vpn.status == 'Подключено' 
                        ? Icons.stop_circle_outlined 
                        : Icons.play_circle_outlined,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    vpn.status == 'Подключено' ? 'Отключиться' : 'Подключиться',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerSelection(VpnProvider vpn, ColorScheme colorScheme) {
    return MullvadCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.dns_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Сервер',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Server Dropdown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Server>(
                isExpanded: true,
                value: vpn.selected,
                icon: Icon(Icons.expand_more, color: colorScheme.primary),
                items: vpn.servers.map((server) => DropdownMenuItem(
                  value: server,
                  child: ServerTile(server: server),
                )).toList(),
                onChanged: (server) => vpn.selectServer(server),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(VpnProvider vpn, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: MullvadActionButton(
            icon: Icons.add_circle_outlined,
            label: 'Добавить',
            onPressed: () => _showAddServerDialog(context, vpn),
            colorScheme: colorScheme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MullvadActionButton(
            icon: Icons.delete_outline,
            label: 'Удалить',
            onPressed: vpn.selected != null && !vpn.selected!.isBuiltIn
                ? () => _showDeleteConfirmation(context, vpn)
                : null,
            colorScheme: colorScheme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MullvadActionButton(
            icon: Icons.network_ping_outlined,
            label: 'Пинг',
            onPressed: vpn.selected != null ? vpn.measurePing : null,
            colorScheme: colorScheme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MullvadActionButton(
            icon: Icons.medical_services_outlined,
            label: 'Тест',
            onPressed: () => vpn.runDiagnostics(),
            colorScheme: colorScheme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCards(VpnProvider vpn, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: StatusCard(
            title: 'Пинг',
            value: vpn.ping.isEmpty ? 'N/A' : vpn.ping,
            icon: Icons.speed_outlined,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatusCard(
            title: 'Серверов',
            value: '${vpn.servers.length}',
            icon: Icons.dns_outlined,
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatusCard(
            title: 'Статус',
            value: vpn.filesReady ? 'Готов' : 'Не готов',
            icon: Icons.check_circle_outlined,
            color: vpn.filesReady ? const Color(0xFF10B981) : const Color(0xFFDC2626),
          ),
        ),
      ],
    );
  }

  Widget _buildLogsSection(VpnProvider vpn, ColorScheme colorScheme) {
    return MullvadCard(
      child: ExpansionTile(
        leading: Icon(Icons.terminal, color: colorScheme.primary),
        title: const Text(
          'Логи подключения',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: vpn.logOutput.isNotEmpty
            ? IconButton(
                onPressed: () => _copyLogs(context, vpn.logOutput),
                icon: const Icon(Icons.copy_outlined, size: 20),
                tooltip: 'Копировать',
              )
            : null,
        children: [
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                vpn.logOutput.isEmpty ? 'Логи появятся здесь...' : vpn.logOutput,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: vpn.logOutput.isEmpty
                      ? colorScheme.onSurface.withOpacity(0.5)
                      : colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog methods remain the same...
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

  void _showSnackBar(BuildContext context, String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
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
