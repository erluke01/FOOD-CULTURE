import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../services/sync_service.dart';
import '../theme.dart';

class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);
    final user = ref.watch(authProvider).valueOrNull;

    if (user == null) return const SizedBox.shrink();

    return IconButton(
      tooltip: 'Sincronizza',
      onPressed: syncStatus == SyncStatus.syncing ? null : () => _sync(context, ref),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: switch (syncStatus) {
          SyncStatus.syncing => const SizedBox(
            key: ValueKey('loading'),
            width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
          ),
          SyncStatus.success => const Icon(Icons.cloud_done, key: ValueKey('ok'), color: Colors.greenAccent),
          SyncStatus.error   => const Icon(Icons.cloud_off, key: ValueKey('err'), color: Colors.redAccent),
          _                  => const Icon(Icons.cloud_sync_outlined, key: ValueKey('idle'), color: Colors.white70),
        },
      ),
    );
  }

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    final error = await ref.read(syncStatusProvider.notifier).sync();
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red.shade700),
      );
    } else if (error == null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Sincronizzazione completata'), backgroundColor: Colors.green),
      );
    }
  }
}
