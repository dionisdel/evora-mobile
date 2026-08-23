import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/documento.dart';
import '../services/actividad_service.dart';
import '../theme/app_theme.dart';

/// Menú Secundario "Más" - Documentos de actividad.
class MasScreen extends StatefulWidget {
  const MasScreen({super.key});

  @override
  State<MasScreen> createState() => _MasScreenState();
}

class _MasScreenState extends State<MasScreen> {
  bool _showActividad = false;

  @override
  Widget build(BuildContext context) {
    if (_showActividad) {
      return _ActividadView(onBack: () => setState(() => _showActividad = false));
    }

    return Column(
      children: [
        // Menú principal
        _MenuItem(
          icon: Icons.description_outlined,
          iconColor: AppColors.accent,
          title: 'Actividad',
          subtitle: 'Documentos e instrucciones de campaña',
          onTap: () => setState(() => _showActividad = true),
        ),
        _MenuItem(
          icon: Icons.photo_library_outlined,
          iconColor: AppColors.textDisabled,
          title: 'Galería',
          subtitle: 'Accede desde el detalle de cada farmacia',
          onTap: null,
        ),

        // Info
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.borderLight,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.textMuted),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'La galería de fotos está disponible desde el detalle de cada farmacia en la pantalla de búsqueda.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: onTap != null ? AppColors.textPrimary : AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, size: 20, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}

class _ActividadView extends StatefulWidget {
  final VoidCallback onBack;

  const _ActividadView({required this.onBack});

  @override
  State<_ActividadView> createState() => _ActividadViewState();
}

class _ActividadViewState extends State<_ActividadView> {
  List<Documento> _documentos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocumentos();
  }

  Future<void> _loadDocumentos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final docs = await ActividadService.listar();
      setState(() => _documentos = docs);
    } catch (_) {
      setState(() => _error = 'No se pudieron cargar los documentos.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDownload(Documento doc) async {
    try {
      final url = await ActividadService.getDownloadUrl(doc.id, fuente: doc.fuente);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  IconData _getDocIcon(String tipo) {
    switch (tipo) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
        return Icons.description;
      case 'imagen':
        return Icons.image;
      case 'video':
        return Icons.videocam;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '';
    try {
      final d = DateTime.parse(date);
      const months = [
        'ene', 'feb', 'mar', 'abr', 'may', 'jun',
        'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
      ];
      return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onBack,
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.arrow_back, size: 22, color: AppColors.textPrimary),
                ),
              ),
              const Text(
                'Documentos de Actividad',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // Content
        if (_isLoading)
          const Expanded(
            child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
          )
        else if (_error != null)
          Expanded(
            child: Center(
              child: Text(_error!, style: const TextStyle(color: AppColors.error)),
            ),
          )
        else if (_documentos.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 48, color: AppColors.border),
                  const SizedBox(height: 12),
                  const Text(
                    'No hay documentos disponibles',
                    style: TextStyle(fontSize: 14, color: AppColors.textDisabled),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _documentos.length,
              itemBuilder: (context, index) {
                final doc = _documentos[index];
                return Card(
                  child: InkWell(
                    onTap: () => _handleDownload(doc),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.accentLight,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(_getDocIcon(doc.tipo), size: 24, color: AppColors.accent),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.nombre,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${doc.categoria.isNotEmpty ? doc.categoria : doc.tipo} · ${_formatDate(doc.fecha)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textDisabled,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.download_outlined, size: 20, color: AppColors.textDisabled),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
