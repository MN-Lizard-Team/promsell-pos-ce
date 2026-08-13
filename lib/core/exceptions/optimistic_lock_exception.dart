/// Thrown when an update is attempted on a stale entity version.
///
/// The caller should reload the entity and retry or surface a conflict
/// resolution dialog to the user.
class OptimisticLockException implements Exception {
  const OptimisticLockException({
    required this.entityId,
    required this.expectedVersion,
    required this.actualVersion,
  });

  final String entityId;
  final int expectedVersion;
  final int actualVersion;

  @override
  String toString() =>
      'OptimisticLockException: entity $entityId expected version '
      '$expectedVersion but found $actualVersion (concurrent modification).';
}
