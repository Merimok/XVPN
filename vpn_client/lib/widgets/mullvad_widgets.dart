import 'package:flutter/material.dart';
import '../models/server.dart';

/// Mullvad-style карточка с современным дизайном
class MullvadCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const MullvadCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Mullvad-style кнопка действия
class MullvadActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final ColorScheme colorScheme;

  const MullvadActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isEnabled 
            ? colorScheme.primaryContainer.withOpacity(0.7)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled 
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isEnabled 
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isEnabled 
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Карточка статуса в стиле Mullvad
class StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Элемент сервера в выпадающем списке
class ServerTile extends StatelessWidget {
  final Server server;

  const ServerTile({
    super.key,
    required this.server,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: server.isBuiltIn 
                  ? const Color(0xFF10B981)
                  : colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          
          // Server info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        server.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (server.isBuiltIn)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ВСТРОЕННЫЙ',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${server.address}:${server.port}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Анимированная иконка подключения
class ConnectionStatusIcon extends StatefulWidget {
  final bool isConnected;
  final bool isConnecting;

  const ConnectionStatusIcon({
    super.key,
    required this.isConnected,
    required this.isConnecting,
  });

  @override
  State<ConnectionStatusIcon> createState() => _ConnectionStatusIconState();
}

class _ConnectionStatusIconState extends State<ConnectionStatusIcon>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotationController);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _updateAnimations();
  }

  @override
  void didUpdateWidget(ConnectionStatusIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isConnecting != widget.isConnecting ||
        oldWidget.isConnected != widget.isConnected) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    if (widget.isConnecting) {
      _rotationController.repeat();
      _pulseController.repeat(reverse: true);
    } else {
      _rotationController.stop();
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isConnecting ? _pulseAnimation.value : 1.0,
          child: Transform.rotate(
            angle: widget.isConnecting ? _rotationAnimation.value * 2 * 3.14159 : 0,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: widget.isConnected
                    ? const Color(0xFF10B981)
                    : widget.isConnecting
                        ? const Color(0xFFF59E0B)
                        : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(28),
                boxShadow: widget.isConnected || widget.isConnecting
                    ? [
                        BoxShadow(
                          color: (widget.isConnected 
                              ? const Color(0xFF10B981) 
                              : const Color(0xFFF59E0B)).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.isConnected
                    ? Icons.shield
                    : widget.isConnecting
                        ? Icons.sync
                        : Icons.shield_outlined,
                size: 28,
                color: widget.isConnected || widget.isConnecting
                    ? Colors.white
                    : colorScheme.onSurface,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Переключатель VPN в стиле Mullvad
class MullvadVpnToggle extends StatelessWidget {
  final bool isConnected;
  final bool isConnecting;
  final VoidCallback? onToggle;

  const MullvadVpnToggle({
    super.key,
    required this.isConnected,
    required this.isConnecting,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: ConnectionStatusIcon(
          isConnected: isConnected,
          isConnecting: isConnecting,
        ),
      ),
    );
  }
}

/// Индикатор подключения
class ConnectionIndicator extends StatelessWidget {
  final bool isConnected;
  final double size;

  const ConnectionIndicator({
    super.key,
    required this.isConnected,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isConnected 
            ? const Color(0xFF10B981)
            : const Color(0xFF6B7280),
      ),
    );
  }
}
