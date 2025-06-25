import 'package:flutter/material.dart';

/// Configuración de UI centralizada para la aplicación Bovino IA
/// 
/// Este archivo contiene todas las constantes de diseño que se utilizan
/// en toda la aplicación para mantener consistencia visual.
class AppUIConfig {
  // Espaciado y márgenes
  static const double padding = 16.0;
  static const double margin = 8.0;
  static const double paddingSmall = 8.0;
  static const double paddingLarge = 24.0;
  static const double marginSmall = 4.0;
  static const double marginLarge = 16.0;

  // Bordes y radios
  static const double borderRadius = 8.0;
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;
  static const double borderWidth = 1.0;
  static const double borderWidthThick = 2.0;

  // Elevaciones
  static const double cardElevation = 4.0;
  static const double buttonElevation = 2.0;
  static const double appBarElevation = 4.0;
  static const double dialogElevation = 8.0;
  static const double floatingActionButtonElevation = 6.0;

  // Tamaños de iconos
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Tamaños de botones
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );
  static const EdgeInsets textButtonPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 8.0,
  );

  // Tamaños de inputs
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 16.0,
  );

  // Tamaños de list tiles
  static const EdgeInsets listTilePadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 8.0,
  );

  // Tamaños de chips
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 4.0,
  );

  // Sombras
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> appBarShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  // Tamaños de texto
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeadline = 28.0;

  // Tamaños de componentes
  static const double appBarHeight = 56.0;
  static const double bottomNavigationHeight = 56.0;
  static const double cardMinHeight = 80.0;
  static const double buttonMinHeight = 48.0;
  static const double inputMinHeight = 48.0;

  // Animaciones
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // Curvas de animación
  static const Curve animationCurveFast = Curves.easeInOut;
  static const Curve animationCurveNormal = Curves.easeInOut;
  static const Curve animationCurveSlow = Curves.easeInOut;

  // Tamaños de imagen
  static const double imageSizeSmall = 40.0;
  static const double imageSizeMedium = 60.0;
  static const double imageSizeLarge = 80.0;
  static const double imageSizeXLarge = 120.0;

  // Aspect ratios
  static const double aspectRatioCard = 16 / 9;
  static const double aspectRatioImage = 4 / 3;
  static const double aspectRatioVideo = 16 / 9;

  // Tamaños de lista
  static const double listItemHeight = 56.0;
  static const double listItemHeightLarge = 72.0;
  static const double listItemSpacing = 8.0;

  // Tamaños de grid
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 1.0;
  static const double gridCrossAxisSpacing = 8.0;
  static const double gridMainAxisSpacing = 8.0;

  // Tamaños de diálogos
  static const double dialogWidth = 300.0;
  static const double dialogMaxWidth = 400.0;
  static const EdgeInsets dialogPadding = EdgeInsets.all(16.0);

  // Tamaños de snackbar
  static const double snackBarHeight = 48.0;
  static const EdgeInsets snackBarPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );

  // Tamaños de chips
  static const double chipHeight = 32.0;

  // Tamaños de badges
  static const double badgeSize = 16.0;
  static const double badgeSizeLarge = 20.0;

  // Tamaños de avatars
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 40.0;
  static const double avatarSizeLarge = 56.0;
  static const double avatarSizeXLarge = 80.0;

  // Tamaños de progress indicators
  static const double progressIndicatorSize = 24.0;
  static const double progressIndicatorSizeLarge = 48.0;
  static const double progressIndicatorStrokeWidth = 2.0;
  static const double progressIndicatorStrokeWidthLarge = 4.0;

  // Tamaños de switches
  static const double switchWidth = 40.0;
  static const double switchHeight = 24.0;
  static const double switchThumbSize = 20.0;

  // Tamaños de sliders
  static const double sliderHeight = 48.0;
  static const double sliderThumbSize = 20.0;
  static const double sliderTrackHeight = 4.0;

  // Tamaños de checkboxes
  static const double checkboxSize = 24.0;
  static const double checkboxSizeLarge = 32.0;

  // Tamaños de radio buttons
  static const double radioSize = 24.0;
  static const double radioSizeLarge = 32.0;

  // Tamaños de tooltips
  static const double tooltipMaxWidth = 200.0;
  static const EdgeInsets tooltipPadding = EdgeInsets.symmetric(
    horizontal: 8.0,
    vertical: 4.0,
  );

  // Tamaños de dividers
  static const double dividerThickness = 1.0;
  static const double dividerThicknessThick = 2.0;

  // Tamaños de tabs
  static const double tabHeight = 48.0;
  static const double tabIndicatorHeight = 2.0;

  // Tamaños de steppers
  static const double stepperIconSize = 24.0;
  static const double stepperLineHeight = 1.0;

  // Tamaños de expansion tiles
  static const double expansionTileHeight = 56.0;
  static const double expansionTileIconSize = 24.0;

  // Tamaños de data tables
  static const double dataTableRowHeight = 52.0;
  static const double dataTableHeaderHeight = 56.0;
  static const double dataTableColumnSpacing = 16.0;
  static const double dataTableHorizontalMargin = 16.0;

  // Tamaños de bottom sheets
  static const double bottomSheetHandleHeight = 4.0;
  static const double bottomSheetHandleWidth = 32.0;
  static const double bottomSheetMinHeight = 200.0;
  static const double bottomSheetMaxHeight = 600.0;

  // Tamaños de drawers
  static const double drawerWidth = 280.0;
  static const double drawerHeaderHeight = 120.0;

  // Tamaños de floating action buttons
  static const double fabSize = 56.0;
  static const double fabSizeSmall = 40.0;
  static const double fabSizeLarge = 64.0;

  // Tamaños de navigation rails
  static const double navigationRailWidth = 72.0;
  static const double navigationRailExtendedWidth = 256.0;

  // Tamaños de search bars
  static const double searchBarHeight = 48.0;
  static const double searchBarIconSize = 24.0;

  // Tamaños de pagination
  static const double paginationHeight = 48.0;
  static const double paginationButtonSize = 32.0;

  // Tamaños de loading indicators
  static const double loadingIndicatorSize = 24.0;
  static const double loadingIndicatorSizeLarge = 48.0;

  // Tamaños de error widgets
  static const double errorIconSize = 48.0;
  static const double errorIconSizeLarge = 64.0;

  // Tamaños de empty state widgets
  static const double emptyStateIconSize = 64.0;
  static const double emptyStateIconSizeLarge = 96.0;

  // Tamaños de success widgets
  static const double successIconSize = 48.0;
  static const double successIconSizeLarge = 64.0;

  // Tamaños de warning widgets
  static const double warningIconSize = 48.0;
  static const double warningIconSizeLarge = 64.0;

  // Tamaños de info widgets
  static const double infoIconSize = 48.0;
  static const double infoIconSizeLarge = 64.0;

  // Tamaños de help widgets
  static const double helpIconSize = 24.0;
  static const double helpIconSizeLarge = 32.0;

  // Tamaños de settings widgets
  static const double settingsIconSize = 24.0;
  static const double settingsIconSizeLarge = 32.0;

  // Tamaños de camera widgets
  static const double cameraButtonSize = 64.0;
  static const double cameraButtonSizeLarge = 80.0;
  static const double cameraPreviewAspectRatio = 4 / 3;

  // Tamaños de bovino widgets
  static const double bovinoCardHeight = 140.0;
  static const double bovinoCardWidth = 120.0;
  static const double bovinoImageSize = 80.0;
  static const double bovinoConfidenceBarHeight = 8.0;

  // Tamaños de stats widgets
  static const double statsCardHeight = 100.0;
  static const double statsIconSize = 32.0;
  static const double statsValueSize = 24.0;

  // Tamaños de theme widgets
  static const double themeToggleSize = 48.0;
  static const double themeIndicatorSize = 24.0;

  // Tamaños de splash widgets
  static const double splashLogoSize = 120.0;
  static const double splashLogoSizeLarge = 160.0;

  // Tamaños de home widgets
  static const double homeHeaderHeight = 120.0;
  static const double homeContentPadding = 16.0;

  // Tamaños de settings widgets
  static const double settingsItemHeight = 56.0;

  // Tamaños de error display widgets
  static const double errorDisplayIconSize = 64.0;
  static const double errorDisplayIconSizeLarge = 96.0;

  // Tamaños de custom widgets
  static const double customButtonHeight = 48.0;
  static const double customButtonWidth = 120.0;
  static const double customTextSize = 16.0;
  static const double customIconSize = 24.0;
} 