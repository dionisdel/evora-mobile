import 'package:flutter/material.dart';
import '../core/navigation_utils.dart';
import '../models/farmacia.dart';
import '../theme/app_theme.dart';

/// Tarjeta de farmacia en lista de resultados.
class FarmaciaCard extends StatelessWidget {
  final Farmacia farmacia;
  final VoidCallback onTap;

  const FarmaciaCard({
    super.key,
    required this.farmacia,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final estado = _estadoConfig(farmacia.estadoCuestionario);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Info principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmacia.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Dirección tocable para navegación
                    GestureDetector(
                      onTap: farmacia.direccion.isNotEmpty
                          ? () => navegarADireccion(farmacia.direccionCompleta)
                          : null,
                      child: Text(
                        farmacia.direccion.isNotEmpty
                            ? '${farmacia.direccion}, ${farmacia.poblacion}'
                            : 'Sin dirección',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: farmacia.direccion.isNotEmpty
                              ? AppColors.textSecondary
                              : AppColors.textMuted,
                          decoration: farmacia.direccion.isNotEmpty
                              ? TextDecoration.underline
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      farmacia.externalId,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Iconos de acción
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (farmacia.tienePostIt)
                    Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: AppColors.postIt,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: Color(0xFFd69e2e),
                      ),
                    ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFfafafa),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: estado.color, width: 1.5),
                    ),
                    child: Icon(estado.icon, size: 18, color: estado.color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _EstadoConfig _estadoConfig(EstadoCuestionario estado) {
    switch (estado) {
      case EstadoCuestionario.pendiente:
        return const _EstadoConfig(
          icon: Icons.check_box_outlined,
          color: AppColors.textDisabled,
          label: 'Pendiente',
        );
      case EstadoCuestionario.enCurso:
        return const _EstadoConfig(
          icon: Icons.edit_outlined,
          color: AppColors.warning,
          label: 'En curso',
        );
      case EstadoCuestionario.completado:
        return const _EstadoConfig(
          icon: Icons.check_circle,
          color: AppColors.success,
          label: 'Completado',
        );
    }
  }
}

class _EstadoConfig {
  final IconData icon;
  final Color color;
  final String label;

  const _EstadoConfig({
    required this.icon,
    required this.color,
    required this.label,
  });
}
