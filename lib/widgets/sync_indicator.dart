import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sync_provider.dart';
import '../theme/app_theme.dart';

/// Indicador de sincronización offline.
class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);

    if (syncState.pendingCount == 0 && !syncState.hasErrors && !syncState.isSyncing) {
      return const SizedBox.shrink();
    }

    final config = _getConfig(syncState);

    return GestureDetector(
      onTap: syncState.hasErrors
          ? () => ref.read(syncProvider.notifier).retryFailed()
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: config.bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: config.color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (syncState.isSyncing)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(config.color),
                ),
              )
            else
              Icon(config.icon, size: 14, color: config.color),
            const SizedBox(width: 5),
            Text(
              config.text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: config.color,
              ),
            ),
            if (syncState.hasErrors) ...[
              const SizedBox(width: 4),
              Icon(Icons.refresh, size: 12, color: config.color),
            ],
          ],
        ),
      ),
    );
  }

  _SyncConfig _getConfig(SyncState state) {
    if (state.isSyncing) {
      return _SyncConfig(
        icon: Icons.sync,
        color: AppColors.accent,
        bgColor: AppColors.accentLight,
        text: 'Sincronizando...',
      );
    }
    if (state.hasErrors) {
      return _SyncConfig(
        icon: Icons.error_outline,
        color: AppColors.error,
        bgColor: AppColors.errorLight,
        text: '${state.pendingCount} con error',
      );
    }
    return _SyncConfig(
      icon: Icons.cloud_upload_outlined,
      color: AppColors.warning,
      bgColor: AppColors.warningLight,
      text: '${state.pendingCount} pendiente${state.pendingCount > 1 ? 's' : ''}',
    );
  }
}

class _SyncConfig {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String text;

  const _SyncConfig({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.text,
  });
}
