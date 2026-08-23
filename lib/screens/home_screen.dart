import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/farmacia.dart';
import '../providers/auth_provider.dart';
import '../services/farmacia_service.dart';
import '../theme/app_theme.dart';
import '../widgets/farmacia_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/sync_indicator.dart';
import 'cuestionario_screen.dart';

/// Pantalla Principal - Búsqueda de Farmacias.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Farmacia> _farmacias = [];
  bool _isLoading = false;
  String? _error;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _buscar(const BusquedaParams());
  }

  Future<void> _buscar(BusquedaParams params) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      final results = await FarmaciaService.buscar(params);
      setState(() => _farmacias = results);
    } catch (e) {
      debugPrint('[HomeScreen] Error buscando farmacias: $e');
      setState(() {
        _error = 'No se pudieron cargar las farmacias. Comprueba tu conexión.';
        _farmacias = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    await _buscar(const BusquedaParams());
  }

  void _openCuestionario(Farmacia farmacia) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CuestionarioScreen(peticionId: farmacia.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Column(
      children: [
        // Barra de búsqueda
        SearchBarWidget(onSearch: _buscar),

        // Contenido
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    // Loading
    if (_isLoading && _farmacias.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    // Error
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 32, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onRefresh,
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Lista
    if (_farmacias.isEmpty && _hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_outlined, size: 48, color: AppColors.border),
            const SizedBox(height: 12),
            const Text(
              'Sin resultados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDisabled,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'No se encontraron farmacias con los filtros aplicados',
              style: TextStyle(fontSize: 14, color: AppColors.textPlaceholder),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.accent,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
        itemCount: _farmacias.length + 1, // +1 para el footer
        itemBuilder: (context, index) {
          if (index == _farmacias.length) {
            return _farmacias.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      '${_farmacias.length} farmacia${_farmacias.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textDisabled,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : const SizedBox.shrink();
          }
          final farmacia = _farmacias[index];
          return FarmaciaCard(
            farmacia: farmacia,
            onTap: () => _openCuestionario(farmacia),
          );
        },
      ),
    );
  }
}
