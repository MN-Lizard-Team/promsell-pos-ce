import 'package:equatable/equatable.dart';

class ImageConfig extends Equatable {
  const ImageConfig({this.maxWidth = 800, this.quality = 80});

  final int maxWidth;
  final int quality;

  ImageConfig copyWith({int? maxWidth, int? quality}) {
    return ImageConfig(
      maxWidth: maxWidth ?? this.maxWidth,
      quality: quality ?? this.quality,
    );
  }

  @override
  List<Object?> get props => [maxWidth, quality];
}
