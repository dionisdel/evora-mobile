/// Modelo de usuario autenticado.
/// En Evora, los "instaladores" tienen rol 'coach' o 'colaborador'.
class User {
  final int id;
  final String nombre;
  final String perfil; // 'coach' | 'colaborador'
  final String merchan;

  const User({
    required this.id,
    required this.nombre,
    required this.perfil,
    required this.merchan,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      perfil: json['perfil'] as String,
      merchan: json['merchan'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'perfil': perfil,
        'merchan': merchan,
      };

  bool get isInstalador => perfil == 'coach' || perfil == 'colaborador';
}
