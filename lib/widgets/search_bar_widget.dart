import 'dart:async';
import 'package:flutter/material.dart';
import '../services/farmacia_service.dart';
import '../theme/app_theme.dart';

/// Barra de búsqueda de farmacias con filtros avanzados.
class SearchBarWidget extends StatefulWidget {
  final void Function(BusquedaParams params) onSearch;

  const SearchBarWidget({super.key, required this.onSearch});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _controller = TextEditingController();
  Timer? _debounce;
  bool _showFilters = false;

  String _filterExternalId = '';
  String _filterDireccion = '';
  String _filterPoblacion = '';
  String _filterProvincia = '';

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged(String text) {
    _debounce?.cancel();
    if (text.length >= 3) {
      _debounce = Timer(const Duration(milliseconds: 400), () {
        // Detectar si parece un external_id
        final isId = RegExp(r'^[A-Z]{2,4}-?\d').hasMatch(text.toUpperCase());
        if (isId) {
          widget.onSearch(BusquedaParams(externalId: text));
        } else {
          widget.onSearch(BusquedaParams(nombre: text));
        }
      });
    }
  }

  void _applyFilters() {
    widget.onSearch(BusquedaParams(
      nombre: _controller.text.length >= 3 ? _controller.text : null,
      externalId: _filterExternalId.isNotEmpty ? _filterExternalId : null,
      direccion: _filterDireccion.isNotEmpty ? _filterDireccion : null,
      poblacion: _filterPoblacion.isNotEmpty ? _filterPoblacion : null,
      provincia: _filterProvincia.isNotEmpty ? _filterProvincia : null,
    ));
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _filterExternalId = '';
      _filterDireccion = '';
      _filterPoblacion = '';
      _filterProvincia = '';
    });
    widget.onSearch(const BusquedaParams());
  }

  bool get _hasActiveFilters =>
      _filterExternalId.length >= 3 ||
      _filterDireccion.length >= 3 ||
      _filterPoblacion.length >= 3 ||
      _filterProvincia.length >= 3;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: [
          // Barra principal
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.textDisabled, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: _onTextChanged,
                    onSubmitted: (text) {
                      if (text.length >= 3) {
                        widget.onSearch(BusquedaParams(nombre: text));
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Nombre, dirección, población...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                    textInputAction: TextInputAction.search,
                  ),
                ),
                if (_controller.text.isNotEmpty || _hasActiveFilters)
                  GestureDetector(
                    onTap: _clear,
                    child: const Icon(Icons.cancel, color: AppColors.textDisabled, size: 20),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _showFilters = !_showFilters),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _hasActiveFilters ? AppColors.accentLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.tune,
                      size: 20,
                      color: _hasActiveFilters ? AppColors.accent : AppColors.textDisabled,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Panel de filtros avanzados
          if (_showFilters)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _FilterInput(
                        label: 'External ID',
                        value: _filterExternalId,
                        placeholder: 'EXT-...',
                        onChanged: (v) => setState(() => _filterExternalId = v),
                      ),
                      const SizedBox(height: 8),
                      _FilterInput(
                        label: 'Dirección',
                        value: _filterDireccion,
                        placeholder: 'Calle, número...',
                        onChanged: (v) => setState(() => _filterDireccion = v),
                      ),
                      const SizedBox(height: 8),
                      _FilterInput(
                        label: 'Población',
                        value: _filterPoblacion,
                        placeholder: 'Ciudad...',
                        onChanged: (v) => setState(() => _filterPoblacion = v),
                      ),
                      const SizedBox(height: 8),
                      _FilterInput(
                        label: 'Provincia',
                        value: _filterProvincia,
                        placeholder: 'Provincia...',
                        onChanged: (v) => setState(() => _filterProvincia = v),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 40),
                          ),
                          child: const Text('Aplicar filtros'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterInput extends StatelessWidget {
  final String label;
  final String value;
  final String placeholder;
  final ValueChanged<String> onChanged;

  const _FilterInput({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          onChanged: onChanged,
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
          ),
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
