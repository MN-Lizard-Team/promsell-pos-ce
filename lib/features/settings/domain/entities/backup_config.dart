import 'package:equatable/equatable.dart';

class BackupConfig extends Equatable {
  const BackupConfig({
    this.reminderDays = 7,
    this.lastBackupAt,
    this.encryptionEnabled = false,
  });

  final int reminderDays;
  final String? lastBackupAt;
  final bool encryptionEnabled;

  bool get isOverdue {
    if (reminderDays == 0) return false;
    if (lastBackupAt == null || lastBackupAt!.isEmpty) return true;
    final last = DateTime.tryParse(lastBackupAt!);
    if (last == null) return true;
    return DateTime.now().difference(last).inDays > reminderDays;
  }

  BackupConfig copyWith({
    int? reminderDays,
    String? lastBackupAt,
    bool? encryptionEnabled,
  }) {
    return BackupConfig(
      reminderDays: reminderDays ?? this.reminderDays,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
    );
  }

  @override
  List<Object?> get props => [reminderDays, lastBackupAt, encryptionEnabled];
}
