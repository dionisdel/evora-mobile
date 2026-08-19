import 'dart:async';
import 'package:flutter/material.dart';
import '../core/offline_helpers.dart';
import '../models/sync_item.dart';
import '../services/cuestionario_service.dart';
import '../services/visita_service.dart';
import '../theme/app_theme.dart';

/// Pantalla de Cuestionario / Ficha de Visita.
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

  @override
  void initState() {
    super.initState();
    _loadFicha();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_hasChanges && _ficha != null) {
        _handleSave(showAlert: false);
      }
    });
  }

  Future<void> _loadFicha() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Abrir visita (crea ficha si no existe)
      await VisitaService.abrir(widget.peticionId);

      // Obtener ficha
      final response = await CuestionarioService.getFicha(widget.peticionId);
      setState(() {
        _ficha = Map<String, dynamic>.from(response.ficha);
        _tipoInstalacion = response.tipoInstalacion;
      });
      _startAutoSave();
    } catch (_) {
      setState(() => _error = 'No se pudo cargar el cuestionario. Comprueba tu conexión.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateField(String field, dynamic value) {
    setState(() {
      _ficha?[field] = value;
      _hasChanges = true;
    });
  }

  Future<void> _handleSave({bool showAlert = true}) async {
    if (_ficha == null) return;
    setState(() => _isSaving = true);

    try {
      final result = await executeWithOfflineFallback(
        operation: () => CuestionarioService.guardarFicha(
          widget.peticionId,
          {..._ficha!, 'validar': false},
        ),
        queueType: SyncItemType.fichaVisita,
        queueData: {
          'peticion_id': widget.peticionId,
          'ficha_data': _ficha,
          'validar': false,
        },
      );

      setState(() => _hasChanges = false);

      if (showAlert && mounted) {
        if (result.queued) {
          _showSnackBar('Guardado offline. Se sincronizará cuando haya conexión.');
        } else {
          _showSnackBar('Ficha guardada correctamente.');
        }
      }
    } catch (_) {
      if (showAlert && mounted) {
        _showSnackBar('No se pudo guardar.', isError: true);
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _handleFinalizar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar visita'),
        content: const Text(
          '¿Estás seguro de que quieres validar y cerrar la ficha? No podrás editarla después.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (confirm != true || _ficha == null) return;

    setState(() => _isSaving = true);
    try {
      // Guardar con validar=true
      final saveResult = await executeWithOfflineFallback(
        operation: () => CuestionarioService.guardarFicha(
          widget.peticionId,
          {..._ficha!, 'validar': true},
        ),
        queueType: SyncItemType.fichaVisita,
        queueData: {
          'peticion_id': widget.peticionId,
          'ficha_data': _ficha,
          'validar': true,
        },
      );

      // Cerrar visita
      await executeWithOfflineFallback(
        operation: () => VisitaService.cerrar(widget.peticionId),
        queueType: SyncItemType.cerrarActividad,
        queueData: {'peticion_id': widget.peticionId},
      );

      if (mounted) {
        final msg = saveResult.queued
            ? 'Guardado offline. La ficha se validará cuando haya conexión.'
            : 'Ficha validada y visita cerrada.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) _showSnackBar('No se pudo finalizar. Inténtalo de nuevo.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.accent),
              const SizedBox(height: 12),
              const Text(
                'Cargando cuestionario...',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadFicha,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_ficha == null) return const SizedBox.shrink();

    final isValidated = _ficha!['validado'] == true;
    final instalacionExitosa = _ficha!['instalacion_exitosa'];
    final canFinalize = !isValidated && instalacionExitosa != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
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
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _ficha!['nombre_cliente'] as String? ?? 'Cuestionario',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _tipoInstalacion ?? 'Ficha de visita',
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (_hasChanges)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),

            // Formulario
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Datos de la visita
                    _Section(
                      title: 'Datos de la visita',
                      children: [
                        _ReadonlyField(label: 'Farmacia', value: _ficha!['nombre_cliente'] as String?),
                        _ReadonlyField(label: 'Dirección', value: _ficha!['direccion'] as String?),
                        _ReadonlyField(label: 'Fecha visita', value: _ficha!['fecha_visita'] as String?),
                        _ReadonlyField(label: 'Tipo', value: _tipoInstalacion ?? '-'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Pregunta principal
                    if (_tipoInstalacion != 'Envío')
                      _Section(
                        title: '¿Se logró la instalación?',
                        children: [
                          _RadioGroup(
                            value: _ficha!['instalacion_exitosa'] as String?,
                            options: const [
                              _RadioOption(label: 'Sí', value: 'si'),
                              _RadioOption(label: 'No', value: 'no'),
                            ],
                            onChanged: isValidated ? null : (v) => _updateField('instalacion_exitosa', v),
                          ),
                        ],
                      ),

                    if (_tipoInstalacion == 'Envío')
                      _Section(
                        title: '¿Se realizó el envío?',
                        children: [
                          _RadioGroup(
                            value: _ficha!['envio_realizado'] as String?,
                            options: const [
                              _RadioOption(label: 'Sí', value: 'si'),
                              _RadioOption(label: 'No', value: 'no'),
                            ],
                            onChanged: isValidated ? null : (v) => _updateField('envio_realizado', v),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),

                    // Observaciones
                    _Section(
                      title: 'Observaciones',
                      children: [
                        TextField(
                          controller: TextEditingController(
                            text: _ficha!['observaciones'] as String? ?? '',
                          ),
                          onChanged: (v) => _updateField('observaciones', v),
                          maxLines: 4,
                          enabled: !isValidated,
                          decoration: InputDecoration(
                            hintText: 'Notas adicionales sobre la visita...',
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                        ),
                      ],
                    ),

                    // Banner validado
                    if (isValidated)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, size: 20, color: AppColors.success),
                            SizedBox(width: 8),
                            Text(
                              'Ficha validada — solo lectura',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 100), // Espacio para el footer
                  ],
                ),
              ),
            ),

            // Footer con acciones
            if (!isValidated)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving || !_hasChanges ? null : () => _handleSave(),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                'Guardar borrador',
                                style: TextStyle(
                                  color: _hasChanges ? AppColors.accent : AppColors.textDisabled,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: canFinalize && !_isSaving ? _handleFinalizar : null,
                        icon: const Icon(Icons.check_circle, size: 20),
                        label: const Text('Finalizar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canFinalize ? AppColors.success : AppColors.textDisabled,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// === Widgets auxiliares ===

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  final String label;
  final String? value;

  const _ReadonlyField({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(
            value ?? '-',
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _RadioOption {
  final String label;
  final String value;
  const _RadioOption({required this.label, required this.value});
}

class _RadioGroup extends StatelessWidget {
  final String? value;
  final List<_RadioOption> options;
  final ValueChanged<String>? onChanged;

  const _RadioGroup({this.value, required this.options, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((opt) {
        final selected = value == opt.value;
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: onChanged != null ? () => onChanged!(opt.value) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: selected ? AppColors.accent : AppColors.border,
                ),
                color: selected ? AppColors.accentLight : Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selected ? Icons.radio_button_on : Icons.radio_button_off,
                    size: 20,
                    color: selected ? AppColors.accent : AppColors.textDisabled,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    opt.label,
                    style: TextStyle(
                      fontSize: 14,
                      color: selected ? AppColors.accent : AppColors.textSecondary,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
