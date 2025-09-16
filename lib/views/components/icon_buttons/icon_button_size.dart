enum AppIconButtonSize { small, medium, large }

class IconButtonSizeConf {
  final double dimension;
  final double iconSize;
  final double spinnerSize;

  const IconButtonSizeConf({
    required this.dimension,
    required this.iconSize,
    required this.spinnerSize,
  });

  factory IconButtonSizeConf.forSize(AppIconButtonSize size) {
    switch (size) {
      case AppIconButtonSize.small:
        return const IconButtonSizeConf(dimension: 32, iconSize: 18, spinnerSize: 16);
      case AppIconButtonSize.large:
        return const IconButtonSizeConf(dimension: 48, iconSize: 26, spinnerSize: 20);
      case AppIconButtonSize.medium:
      return const IconButtonSizeConf(dimension: 40, iconSize: 22, spinnerSize: 18);
    }
  }
}
