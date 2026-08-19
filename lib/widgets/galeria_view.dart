import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/offline_helpers.dart';
import '../models/foto.dart';
import '../models/sync_item.dart';
import '../services/galeria_service.dart';
import '../theme/app_theme.dart';

/// Vista de galería de fotos de una petición.
class GaleriaView extends StatefulWidget {
  final int peticionId;

  const GaleriaView({super.key, required this.peticionId});

  @override
  State<GaleriaView> createState() => _GaleriaViewState();
}

class _GaleriaViewState extends State<GaleriaView> {
  List<Foto> _fotos = [];
  int _total = 0;
  bool _isLoading = true;
  bool _isUploading = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadFotos();
  }

  Future<void> _loadFotos() async {
    setState(() => _isLoading = true);
    try {
      final response = await GaleriaService.listar(widget.peticionId);
      setState(() {
        _fotos = response.fotos;
        _total = response.total;
      });
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _handleAddPhoto() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Añadir foto'),
        content: const Text('Selecciona una opción'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
            child: const Text('Cámara'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
            child: const Text('Galería'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (source == null) return;

    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        await _uploadPhoto(image.path);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la cámara/galería.')),
        );
      }
    }
  }

  Future<void> _uploadPhoto(String path) async {
    setState(() => _isUploading = true);
    try {
      final result = await executeWithOfflineFallback(
        operation: () async {
          await GaleriaService.subir(widget.peticionId, path);
        },
        queueType: SyncItemType.foto,
        queueData: {
          'peticion_id': widget.peticionId,
          'image_uri': path,
          'tipo': 'foto_visita',
        },
      );

      if (mounted) {
        if (result.queued) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Guardado offline. Se subirá cuando haya conexión.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto subida correctamente.')),
          );
          _loadFotos();
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo subir la foto.')),
        );
      }
    }
    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    const numColumns = 3;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_total foto${_total != 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _handleAddPhoto,
                icon: _isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.camera_alt, size: 18),
                label: const Text('Añadir'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
            ],
          ),
        ),
        // Grid de fotos
        Expanded(
          child: _fotos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 48, color: AppColors.border),
                      const SizedBox(height: 12),
                      const Text(
                        'Sin fotos todavía',
                        style: TextStyle(fontSize: 15, color: AppColors.textDisabled),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Pulsa "Añadir" para capturar la primera',
                        style: TextStyle(fontSize: 13, color: AppColors.textPlaceholder),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: numColumns,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    childAspectRatio: 1,
                  ),
                  itemCount: _fotos.length,
                  itemBuilder: (context, index) {
                    final foto = _fotos[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            GaleriaService.getThumbUrl(foto.id),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.border,
                              child: const Icon(Icons.broken_image, color: AppColors.textDisabled),
                            ),
                          ),
                          if (foto.fotoFicha)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
