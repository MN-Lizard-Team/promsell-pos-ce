enum PermissionType { camera, storage }

class ImagePermissionException implements Exception {
  const ImagePermissionException({required this.type});

  final PermissionType type;

  @override
  String toString() => 'ImagePermissionException: ${type.name}';
}
