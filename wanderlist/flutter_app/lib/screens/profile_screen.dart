import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../services/sync_service.dart';
import '../theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _serverCtrl = TextEditingController();
  bool _loadingUrl = true;

  @override
  void initState() {
    super.initState();
    ref.read(syncServiceProvider).getServerUrl().then((url) {
      if (mounted) {
        _serverCtrl.text = url;
        setState(() => _loadingUrl = false);
      }
    });
  }

  @override
  void dispose() {
    _serverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;
    final syncStatus = ref.watch(syncStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profilo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── User card ───────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: user == null
                  ? Column(children: [
                      const Icon(Icons.person_outline, size: 48, color: AppTheme.inkLight),
                      const SizedBox(height: 12),
                      const Text('Non sei loggato', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/login'),
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text('Accedi'),
                      ),
                    ])
                  : Row(children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.terra.withOpacity(0.12),
                        child: Text(user.displayName.split(' ').last[0], style: const TextStyle(fontSize: 20, color: AppTheme.terra)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          Text('Editor', style: TextStyle(fontSize: 13, color: AppTheme.inkColor.withOpacity(0.5))),
                        ],
                      )),
                      TextButton(
                        onPressed: () async {
                          await ref.read(authProvider.notifier).logout();
                        },
                        child: const Text('Esci', style: TextStyle(color: Colors.red)),
                      ),
                    ]),
            ),
          ),

          const SizedBox(height: 16),

          // ── Sync section ────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.sync, size: 18, color: AppTheme.terra),
                    const SizedBox(width: 8),
                    const Text('Sincronizzazione', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    if (syncStatus == SyncStatus.success)
                      const Icon(Icons.check_circle, size: 18, color: Colors.green),
                    if (syncStatus == SyncStatus.error)
                      const Icon(Icons.error_outline, size: 18, color: Colors.red),
                  ]),
                  const SizedBox(height: 8),
                  Text('Sincronizza i dati con il server per condividerli tra Luchino e Alix.',
                    style: TextStyle(fontSize: 13, color: AppTheme.inkColor.withOpacity(0.6))),
                  const SizedBox(height: 14),
                  // Server URL input
                  _loadingUrl
                      ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
                      : TextField(
                          controller: _serverCtrl,
                          decoration: InputDecoration(
                            labelText: 'URL server (es. http://192.168.1.100:8000)',
                            prefixIcon: const Icon(Icons.dns_outlined, size: 18),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.save_outlined, size: 18),
                              tooltip: 'Salva URL',
                              onPressed: () async {
                                await ref.read(syncServiceProvider).setServerUrl(_serverCtrl.text);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('URL server salvato')),
                                  );
                                }
                              },
                            ),
                          ),
                          keyboardType: TextInputType.url,
                        ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (user == null || syncStatus == SyncStatus.syncing) ? null : _sync,
                      icon: syncStatus == SyncStatus.syncing
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.sync, size: 18),
                      label: Text(switch (syncStatus) {
                        SyncStatus.syncing => 'Sincronizzazione…',
                        SyncStatus.success => '✓ Sincronizzato',
                        SyncStatus.error   => 'Riprova sync',
                        _                  => 'Sincronizza ora',
                      }),
                    ),
                  ),
                  if (user == null) ...[
                    const SizedBox(height: 8),
                    const Text('Devi essere loggato per sincronizzare.',
                      style: TextStyle(fontSize: 12, color: AppTheme.inkLight), textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Info ────────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.info_outline, size: 18, color: AppTheme.inkLight),
                    SizedBox(width: 8),
                    Text('Come funziona il sync', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 10),
                  _InfoRow(icon: Icons.wifi_off, text: 'L\'app funziona sempre offline con dati locali'),
                  _InfoRow(icon: Icons.cloud_sync, text: 'Il sync carica i tuoi dati sul server e scarica quelli dell\'altro utente'),
                  _InfoRow(icon: Icons.merge, text: 'I rating di ciascuno rimangono separati; i posti e le città sono condivisi'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sync() async {
    final error = await ref.read(syncStatusProvider.notifier).sync();
    if (error != null && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Errore di sincronizzazione'),
          content: Text(error),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
        ),
      );
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: AppTheme.terra),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.inkLight))),
      ]),
    );
  }
}
