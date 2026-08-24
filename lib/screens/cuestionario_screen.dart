import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/api_client.dart';
import '../core/offline_helpers.dart';
import '../models/ficha_visita.dart';
import '../models/sync_item.dart';
import '../services/cuestionario_service.dart';
import '../services/foto_sync_service.dart';
import '../services/visita_service.dart';
import '../theme/app_theme.dart';

/// Pantalla de Cuestionario / Ficha de Visita.
/// Renderiza preguntas dinámicas cuando la API devuelve un cuestionario configurado.
class CuestionarioScreen extends StatefulWidget {
  final int peticionId;

  const CuestionarioScreen({super.key, required this.peticionId});

  @override
  State<CuestionarioScreen> createState() => _CuestionarioScreenState();
}

class _CuestionarioScreenState extends State<CuestionarioScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  Map<String, dynamic>? _ficha;
  String? _tipoInstalacion;
  bool _hasChanges = false;
  Timer? _autoSaveTimer;

  // Cuestionario dinámico
  bool _isDynamic = false;
  List<dynamic> _preguntas = [];
  Map<String, dynamic> _respuestas = {}; // pregunta_id → {valor, valor_json, campo_abierto}

  final Map<String, TextEditingController> _textControllers = {};

  @override
  void initState() {
    super.initState();
    _loadFicha();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_hasChanges) _handleSave(showAlert: false);
    });
  }

  Future<void> _loadFicha() async {
    try {
      setState(() { _isLoading = true; _error = null; });

      await VisitaService.abrir(widget.peticionId);
      final response = await CuestionarioService.getFicha(widget.peticionId);

      setState(() {
        _ficha = Map<String, dynamic>.from(response.ficha);
        _tipoInstalacion = response.tipoInstalacion;
        _isDynamic = response.isDynamic;

        if (_isDynamic && response.cuestionario != null) {
          _preguntas = (response.cuestionario!['preguntas'] as List<dynamic>?) ?? [];
          // Cargar respuestas previas
          if (response.respuestas != null) {
            _respuestas = Map<String, dynamic>.from(response.respuestas!);
          }
        }
      });
      _startAutoSave();
    } catch (e) {
      debugPrint('[CuestionarioScreen] Error: $e');
      setState(() => _error = 'No se pudo cargar el cuestionario. Comprueba tu conexión.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _getRespVal(String preguntaId) {
    final r = _respuestas[preguntaId];
    if (r == null) return null;
    if (r is Map) return r['valor'] as String?;
    return r.toString();
  }

  void _setRespVal(String preguntaId, String? valor) {
    setState(() {
      _respuestas[preguntaId] = {'valor': valor, 'valor_json': null, 'campo_abierto': null};
      _hasChanges = true;
    });
  }

  bool _isVisible(Map<String, dynamic> pregunta) {
    final cond = pregunta['condicion'];
    if (cond == null) return true;
    final depId = cond['pregunta_id'] as String?;
    final depVal = cond['valor'] as String?;
    if (depId == null || depVal == null) return true;
    final actual = _getRespVal(depId);
    return actual != null && actual.toLowerCase() == depVal.toLowerCase();
  }

  Future<void> _handleSave({bool showAlert = true}) async {
    setState(() => _isSaving = true);
    try {
      final body = _buildPostBody(validar: false);
      final result = await executeWithOfflineFallback(
        operation: () => CuestionarioService.guardarFicha(widget.peticionId, body),
        queueType: SyncItemType.fichaVisita,
        queueData: {'peticion_id': widget.peticionId, 'ficha_data': body, 'validar': false},
      );
      setState(() => _hasChanges = false);
      if (showAlert && mounted) {
        _showSnackBar(result.queued ? 'Guardado offline.' : 'Ficha guardada.');
      }
    } catch (_) {
      if (showAlert && mounted) _showSnackBar('No se pudo guardar.', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _handleFinalizar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar visita'),
        content: const Text('¿Validar y cerrar la ficha? No podrás editarla después.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      final body = _buildPostBody(validar: true);
      await executeWithOfflineFallback(
        operation: () => CuestionarioService.guardarFicha(widget.peticionId, body),
        queueType: SyncItemType.fichaVisita,
        queueData: {'peticion_id': widget.peticionId, 'ficha_data': body, 'validar': true},
      );
      await executeWithOfflineFallback(
        operation: () => VisitaService.cerrar(widget.peticionId),
        queueType: SyncItemType.cerrarActividad,
        queueData: {'peticion_id': widget.peticionId},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ficha validada y visita cerrada.')));
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) _showSnackBar('No se pudo finalizar.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Map<String, dynamic> _buildPostBody({required bool validar}) {
    if (_isDynamic) {
      final respList = _respuestas.entries.map((e) => {
        'pregunta_id': e.key,
        'valor': (e.value is Map) ? e.value['valor'] : e.value,
        'valor_json': (e.value is Map) ? e.value['valor_json'] : null,
        'campo_abierto': (e.value is Map) ? e.value['campo_abierto'] : null,
      }).toList();
      return {
        'metadata': {
          'fecha_visita': DateTime.now().toIso8601String().split('T')[0],
          'observaciones': _getRespVal('P008') ?? '',
        },
        'respuestas': respList,
        'validar': validar,
      };
    } else {
      return {...?_ficha, 'validar': validar};
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? AppColors.error : null),
    );
  }

  TextEditingController _getTextController(String id, String initial) {
    if (!_textControllers.containsKey(id)) {
      _textControllers[id] = TextEditingController(text: initial);
    }
    return _textControllers[id]!;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadFicha, child: const Text('Reintentar')),
        ],
      )));
    }
    if (_ficha == null && _preguntas.isEmpty) return const SizedBox.shrink();

    final isValidated = _ficha?['validado'] == true || _ficha?['validado'] == 1;
    final hasAnswer = _isDynamic ? _getRespVal('P001') != null : _ficha?['instalacion_exitosa'] != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Body
            Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: _isDynamic ? _buildDynamicForm(isValidated) : _buildLegacyForm(isValidated),
            )),
            // Footer
            if (!isValidated) _buildFooter(hasAnswer),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.arrow_back, size: 22)),
          ),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _ficha?['nombre_cliente'] as String? ?? 'Cuestionario',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(_tipoInstalacion ?? 'Ficha de visita', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          )),
          if (_hasChanges) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  Widget _buildFooter(bool hasAnswer) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(children: [
        Expanded(child: OutlinedButton(
          onPressed: _isSaving || !_hasChanges ? null : () => _handleSave(),
          child: const Text('Guardar borrador'),
        )),
        const SizedBox(width: 10),
        Expanded(child: ElevatedButton.icon(
          onPressed: hasAnswer && !_isSaving ? _handleFinalizar : null,
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Finalizar'),
          style: ElevatedButton.styleFrom(backgroundColor: hasAnswer ? AppColors.success : AppColors.textDisabled),
        )),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CUESTIONARIO DINÁMICO
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDynamicForm(bool isValidated) {
    final visiblePreguntas = _preguntas.where((p) => _isVisible(p as Map<String, dynamic>)).toList();

    return Column(
      children: [
        // Datos de la visita
        _SectionCard(title: 'Datos de la visita', children: [
          _InfoRow('Farmacia', _ficha?['nombre_cliente'] as String? ?? '-'),
          _InfoRow('Dirección', [_ficha?['direccion'] ?? '', _ficha?['provincia'] ?? ''].where((s) => s.isNotEmpty).join(', ')),
          _InfoRow('Fecha', _ficha?['fecha_visita'] as String? ?? DateTime.now().toIso8601String().split('T')[0]),
          _InfoRow('Tipo', _tipoInstalacion ?? '-'),
        ]),
        const SizedBox(height: 12),
        // Preguntas
        ...visiblePreguntas.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildPregunta(p as Map<String, dynamic>, isValidated),
        )),
      ],
    );
  }

  Widget _buildPregunta(Map<String, dynamic> pregunta, bool isValidated) {
    final id = pregunta['id'] as String;
    final texto = pregunta['texto'] as String? ?? '';
    final tipo = pregunta['tipo_respuesta'] as String? ?? '';
    final opciones = (pregunta['opciones'] as List<dynamic>?) ?? [];
    final obligatoria = pregunta['obligatoria'] == true;

    return _SectionCard(
      title: '$texto${obligatoria ? " *" : ""}',
      children: [
        if (tipo == 'si_no') _buildSiNo(id, isValidated),
        if (tipo == 'seleccion_unica') _buildSeleccionUnica(id, opciones, isValidated),
        if (tipo == 'seleccion_multiple') _buildSeleccionMultiple(id, opciones, isValidated),
        if (tipo == 'texto_largo') _buildTextoLargo(id, isValidated),
        if (tipo == 'tabla_numerica') _buildTablaNumerica(id, opciones, isValidated),
        if (tipo == 'archivo_foto') _buildFoto(id, isValidated),
      ],
    );
  }

  Widget _buildSiNo(String id, bool disabled) {
    final val = _getRespVal(id);
    return Row(children: [
      _radioChip('Sí', 'Si', val, disabled ? null : (v) => _setRespVal(id, v)),
      const SizedBox(width: 10),
      _radioChip('No', 'No', val, disabled ? null : (v) => _setRespVal(id, v)),
    ]);
  }

  Widget _buildSeleccionUnica(String id, List<dynamic> opciones, bool disabled) {
    final val = _getRespVal(id);
    return Wrap(spacing: 8, runSpacing: 8, children: opciones.map((op) {
      final opVal = op['valor'] as String? ?? '';
      return _radioChip(opVal, opVal, val, disabled ? null : (v) => _setRespVal(id, v));
    }).toList());
  }

  Widget _buildSeleccionMultiple(String id, List<dynamic> opciones, bool disabled) {
    final current = _respuestas[id];
    final List<String> selected = current is Map && current['valor_json'] is List
        ? (current['valor_json'] as List).cast<String>()
        : (current is Map && current['valor'] != null ? [current['valor'] as String] : []);

    return Wrap(spacing: 8, runSpacing: 8, children: opciones.map((op) {
      final opVal = op['valor'] as String? ?? '';
      final isSelected = selected.contains(opVal);
      return GestureDetector(
        onTap: disabled ? null : () {
          setState(() {
            final newList = List<String>.from(selected);
            isSelected ? newList.remove(opVal) : newList.add(opVal);
            _respuestas[id] = {'valor': newList.length == 1 ? newList.first : null, 'valor_json': newList, 'campo_abierto': null};
            _hasChanges = true;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AppColors.accent : AppColors.border),
            color: isSelected ? AppColors.accentLight : Colors.transparent,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, size: 18, color: isSelected ? AppColors.accent : AppColors.textDisabled),
            const SizedBox(width: 6),
            Text(opVal, style: TextStyle(fontSize: 13, color: isSelected ? AppColors.accent : AppColors.textSecondary)),
          ]),
        ),
      );
    }).toList());
  }

  Widget _buildTextoLargo(String id, bool disabled) {
    final controller = _getTextController(id, _getRespVal(id) ?? '');
    return TextField(
      controller: controller,
      onChanged: (v) => _setRespVal(id, v),
      maxLines: 3,
      enabled: !disabled,
      decoration: InputDecoration(
        hintText: 'Escribe aquí...',
        filled: true, fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildTablaNumerica(String id, List<dynamic> opciones, bool disabled) {
    // Simplified: show each row as label
    return Column(children: opciones.map((op) {
      final marca = op['valor'] as String? ?? '';
      final sub1 = op['subcampo_1'] as String?;
      final sub2 = op['subcampo_2'] as String?;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          SizedBox(width: 80, child: Text(marca, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          if (sub1 != null) Expanded(child: TextField(
            enabled: !disabled,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: sub1, isDense: true, border: const OutlineInputBorder()),
            style: const TextStyle(fontSize: 13),
          )),
          if (sub2 != null) ...[const SizedBox(width: 8), Expanded(child: TextField(
            enabled: !disabled,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: sub2, isDense: true, border: const OutlineInputBorder()),
            style: const TextStyle(fontSize: 13),
          ))],
        ]),
      );
    }).toList());
  }

  Widget _buildFoto(String id, bool disabled) {
    final val = _getRespVal(id);
    final hasPhoto = val != null && val.isNotEmpty;

    return GestureDetector(
      onTap: disabled ? null : () => _pickAndUploadPhoto(id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasPhoto ? const Color(0xFFf0fdf4) : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: hasPhoto ? AppColors.success : AppColors.border),
        ),
        child: Row(children: [
          Icon(
            hasPhoto ? Icons.check_circle : Icons.camera_alt_outlined,
            color: hasPhoto ? AppColors.success : AppColors.accent,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasPhoto ? 'Foto capturada' : 'Tomar foto',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: hasPhoto ? AppColors.success : AppColors.textPrimary,
                ),
              ),
              if (!hasPhoto)
                const Text('Pulsa para abrir cámara o galería', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          )),
          if (!disabled)
            Icon(Icons.chevron_right, color: AppColors.textDisabled, size: 20),
        ]),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto(String preguntaId) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Cámara'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galería'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, maxWidth: 1920, imageQuality: 80);
      if (picked == null) return;

      // Guardar local + encolar para subida (offline-first)
      final localPath = await FotoSyncService.instance.guardarYEncolar(
        imagePath: picked.path,
        peticionId: widget.peticionId,
        tipo: _getFotoTipo(preguntaId),
        nombre: '${preguntaId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      setState(() {
        _respuestas[preguntaId] = {'valor': localPath, 'valor_json': null, 'campo_abierto': null};
        _hasChanges = true;
      });
      _showSnackBar('Foto capturada. Se subirá automáticamente.');
    } catch (e) {
      debugPrint('[Foto] Error: $e');
      _showSnackBar('Error al capturar la foto', isError: true);
    }
  }

  String _getFotoTipo(String preguntaId) {
    switch (preguntaId) {
      case 'F001': return 'foto_instalacion';
      case 'F002': return 'foto_albaran';
      case 'F003': return 'foto_kit_visibilidad';
      default: return 'foto_visita';
    }
  }

  Widget _radioChip(String label, String value, String? current, ValueChanged<String>? onTap) {
    final selected = current?.toLowerCase() == value.toLowerCase();
    return GestureDetector(
      onTap: onTap != null ? () => onTap(value) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border),
          color: selected ? AppColors.accentLight : Colors.transparent,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(selected ? Icons.radio_button_on : Icons.radio_button_off, size: 18, color: selected ? AppColors.accent : AppColors.textDisabled),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 14, color: selected ? AppColors.accent : AppColors.textSecondary, fontWeight: selected ? FontWeight.w500 : FontWeight.normal)),
        ]),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CUESTIONARIO LEGACY (fallback)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLegacyForm(bool isValidated) {
    return Column(children: [
      _SectionCard(title: 'Datos de la visita', children: [
        _InfoRow('Farmacia', _ficha?['nombre_cliente'] as String? ?? '-'),
        _InfoRow('Dirección', [_ficha?['direccion'] ?? '', _ficha?['provincia'] ?? ''].where((s) => s.isNotEmpty).join(', ')),
        _InfoRow('Fecha', _ficha?['fecha_visita'] as String? ?? '-'),
        _InfoRow('Tipo', _tipoInstalacion ?? '-'),
      ]),
      const SizedBox(height: 12),
      if (_tipoInstalacion != 'Envío')
        _SectionCard(title: '¿Se logró la instalación?', children: [
          Row(children: [
            _radioChip('Sí', 'si', _ficha?['instalacion_exitosa'] as String?, isValidated ? null : (v) { setState(() { _ficha?['instalacion_exitosa'] = v; _hasChanges = true; }); }),
            const SizedBox(width: 10),
            _radioChip('No', 'no', _ficha?['instalacion_exitosa'] as String?, isValidated ? null : (v) { setState(() { _ficha?['instalacion_exitosa'] = v; _hasChanges = true; }); }),
          ]),
        ]),
      if (_tipoInstalacion == 'Envío')
        _SectionCard(title: '¿Se realizó el envío?', children: [
          Row(children: [
            _radioChip('Sí', 'si', _ficha?['envio_realizado'] as String?, isValidated ? null : (v) { setState(() { _ficha?['envio_realizado'] = v; _hasChanges = true; }); }),
            const SizedBox(width: 10),
            _radioChip('No', 'no', _ficha?['envio_realizado'] as String?, isValidated ? null : (v) { setState(() { _ficha?['envio_realizado'] = v; _hasChanges = true; }); }),
          ]),
        ]),
      const SizedBox(height: 12),
      _SectionCard(title: 'Observaciones', children: [
        TextField(
          controller: _getTextController('obs_legacy', _ficha?['observaciones'] as String? ?? ''),
          onChanged: (v) { setState(() { _ficha?['observaciones'] = v; _hasChanges = true; }); },
          maxLines: 3, enabled: !isValidated,
          decoration: InputDecoration(hintText: 'Notas adicionales...', filled: true, fillColor: AppColors.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          style: const TextStyle(fontSize: 14),
        ),
      ]),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Widgets auxiliares
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        ...children,
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
        Expanded(child: Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
      ]),
    );
  }
}
