import 'package:equatable/equatable.dart';

class DeviceConfig extends Equatable {
  const DeviceConfig({this.deviceId = '', this.devicePrefix = ''});

  final String deviceId;
  final String devicePrefix;

  bool get isConfigured => deviceId.isNotEmpty && devicePrefix.isNotEmpty;

  DeviceConfig copyWith({String? deviceId, String? devicePrefix}) {
    return DeviceConfig(
      deviceId: deviceId ?? this.deviceId,
      devicePrefix: devicePrefix ?? this.devicePrefix,
    );
  }

  @override
  List<Object?> get props => [deviceId, devicePrefix];
}
