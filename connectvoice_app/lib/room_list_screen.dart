import 'package:flutter/material.dart';
import 'api_client.dart';
import 'models.dart';
import 'prefs.dart';
import 'chat_screen.dart';
import 'theme.dart';

class RoomListScreen extends StatefulWidget {
  final Prefs prefs;
  final String serverUrl;
  final VoidCallback onChangeServer;

  const RoomListScreen({
    super.key,
    required this.prefs,
    required this.serverUrl,
    required this.onChangeServer,
  });

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  late final ApiClient _api = ApiClient(widget.serverUrl);
  List<Room> _rooms = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() { _loading = true; _error = null; });
    try {
      final rooms = await _api.getRooms();
      setState(() { _rooms = rooms; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _deleteRoom(Room room) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar sala', style: TextStyle(color: AppColors.tx1)),
        content: Text(
          '¿Eliminar "${room.displayName}"? Esta acción no se puede deshacer.',
          style: const TextStyle(color: AppColors.tx2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.tx2)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _api.deleteRoom(room.slug);
      _refresh();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _openRoom(Room room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          prefs: widget.prefs,
          serverUrl: widget.serverUrl,
          room: room,
        ),
      ),
    ).then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        title: const Text('BIBLIOTECA', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.tx1, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: AppColors.tx1), onPressed: _refresh),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.tx3),
                        const SizedBox(height: 12),
                        Text(
                          'No se pudo conectar al servidor:\n$_error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.tx2),
                        ),
                        const SizedBox(height: 16),
                        GradientButton(label: 'Reintentar', icon: Icons.refresh_rounded, onPressed: _refresh),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: widget.onChangeServer,
                          child: const Text('Cambiar servidor', style: TextStyle(color: AppColors.tx2)),
                        ),
                      ],
                    ),
                  ),
                )
              : _rooms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.forum_outlined, size: 48, color: AppColors.tx3),
                          const SizedBox(height: 12),
                          const Text('No hay salas todavía', style: TextStyle(color: AppColors.tx2)),
                          const SizedBox(height: 4),
                          const Text('Crea una con el botón +', style: TextStyle(color: AppColors.tx3, fontSize: 12)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
                      itemCount: _rooms.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final r = _rooms[i];
                        return _RoomCard(room: r, onTap: () => _openRoom(r), onDelete: () => _deleteRoom(r));
                      },
                    ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _RoomCard({required this.room, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        radius: AppRadius.r3,
        padding: const EdgeInsets.all(16),
        opacity: 0.05,
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.r2),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: const Icon(Icons.chat_bubble_rounded, color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.displayName.toUpperCase(),
                      style: const TextStyle(color: AppColors.tx1, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text('${room.messageCount} MENSAJES · ${room.lastActivity.toUpperCase()}',
                      style: const TextStyle(color: AppColors.tx2, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 22),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}