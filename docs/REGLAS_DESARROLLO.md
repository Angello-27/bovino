# 📋 Reglas de Desarrollo - Bovino IA

## 🎯 Objetivo

Este documento define las reglas y convenciones que deben seguir todos los desarrolladores que trabajen en el proyecto Bovino IA, asegurando consistencia, mantenibilidad y calidad del código. **La aplicación está diseñada exclusivamente para Android.**

## 📝 Nomenclatura y Convenciones

### Archivos y Directorios
- **snake_case** para archivos y directorios
- **PascalCase** para clases y enums
- **camelCase** para variables y métodos
- **UPPER_SNAKE_CASE** para constantes

#### Ejemplos:
```
✅ Correcto:
- bovino_entity.dart
- camera_bloc.dart
- tensorflow_server_datasource_impl.dart
- BovinoEntity
- CameraBloc
- API_BASE_URL

❌ Incorrecto:
- BovinoEntity.dart
- cameraBloc.dart
- tensorflowServerDataSourceImpl.dart
- bovino_entity
- camera_bloc
- apiBaseUrl
```

### Clases y Interfaces
```dart
// ✅ Correcto
class BovinoEntity extends Equatable {
  final String raza;
  final List<String> caracteristicas;
  final double confianza;
  final DateTime timestamp;
  final double pesoEstimado; // Nuevo campo
  
  const BovinoEntity({
    required this.raza,
    required this.caracteristicas,
    required this.confianza,
    required this.timestamp,
    required this.pesoEstimado,
  });
}

// ✅ Interfaces
abstract class BovinoRepository {
  Future<Either<Failure, BovinoEntity>> analizarFrame(String framePath);
}
```

### Variables y Métodos
```dart
// ✅ Variables privadas
final String _privateVariable = 'value';
final CameraService _cameraService;

// ✅ Métodos públicos
Future<void> analizarFrame(String framePath) async {
  // Implementación
}

// ✅ Métodos privados
void _privateMethod() {
  // Implementación
}
```

## 📚 Organización de Imports

### Orden de Imports
```dart
// 1. Imports de Flutter/Dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

// 2. Imports de paquetes externos
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:dartz/dartz.dart';

// 3. Imports internos (core primero)
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_messages.dart';
import '../../core/errors/failures.dart';

// 4. Imports de otras capas
import '../../domain/entities/bovino_entity.dart';
import '../widgets/custom_widget.dart';
```

### Reglas de Imports
- **Usar imports relativos** para archivos del mismo proyecto
- **Usar imports de paquete** para dependencias externas
- **Agrupar imports** por tipo y orden alfabético
- **Evitar imports innecesarios**
- **Usar alias para evitar conflictos** cuando sea necesario

## 🏗️ Estructura de Clases

### Orden de Elementos
```dart
class ExampleClass {
  // 1. Constantes estáticas
  static const String constant = 'value';
  
  // 2. Variables de instancia
  final String _privateVariable;
  final Service _service;
  final Logger _logger = Logger();
  
  // 3. Constructor
  ExampleClass({
    required this._service,
  });
  
  // 4. Getters
  String get publicVariable => _privateVariable;
  
  // 5. Métodos públicos
  Future<void> publicMethod() async {
    _logger.i('Iniciando método público');
    await _privateMethod();
  }
  
  // 6. Métodos privados
  Future<void> _privateMethod() async {
    // Implementación
  }
}
```

## 🎨 Manejo de Errores

### Estructura de Failures
```dart
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  
  const Failure({required this.message, this.code});
  
  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}
```

### Uso en BLoCs Mejorados
```dart
Future<void> _onAnalizarFrame(
  AnalizarFrameEvent event,
  Emitter<BovinoState> emit,
) async {
  try {
    emit(BovinoAnalyzing());
    _logger.i('Analizando frame: ${event.imagePath}');
    
    final resultado = await _repository.analizarFrame(event.imagePath);
    
    resultado.fold(
      (failure) {
        _logger.e('Error al analizar frame: ${failure.message}');
        emit(BovinoError(failure));
      },
      (bovino) {
        _logger.i('Análisis exitoso - Raza: ${bovino.raza}, Peso: ${bovino.pesoFormateado}');
        emit(BovinoResult(bovino));
      },
    );
  } catch (e) {
    _logger.e('Error inesperado en BovinoBloc: $e');
    emit(BovinoError(UnknownFailure(message: e.toString())));
  }
}
```

## 🔧 BLoC Pattern Mejorado

### Estructura de BLoCs
```dart
// Events
abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCamera extends CameraEvent {}

class StartCapture extends CameraEvent {}

class StopCapture extends CameraEvent {}

// States
abstract class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object?> get props => [];
}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraReady extends CameraState {}

class CameraCapturing extends CameraState {
  final String lastFramePath;
  
  const CameraCapturing(this.lastFramePath);
  
  @override
  List<Object?> get props => [lastFramePath];
}

class CameraError extends CameraState {
  final Failure failure;
  
  const CameraError(this.failure);
  
  @override
  List<Object?> get props => [failure];
}

// BLoC
class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final CameraService _cameraService;
  final Logger _logger = Logger();
  
  CameraBloc({required CameraService cameraService})
      : _cameraService = cameraService,
        super(CameraInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<StartCapture>(_onStartCapture);
    on<StopCapture>(_onStopCapture);
  }
  
  Future<void> _onInitializeCamera(
    InitializeCamera event,
    Emitter<CameraState> emit,
  ) async {
    try {
      emit(CameraLoading());
      _logger.i('Inicializando cámara...');
      
      await _cameraService.initialize();
      emit(CameraReady());
      _logger.i('Cámara inicializada correctamente');
    } catch (e) {
      _logger.e('Error al inicializar cámara: $e');
      emit(CameraError(UnknownFailure(message: e.toString())));
    }
  }
}
```

## 🎯 Inyección de Dependencias Modular

### Registro de Dependencias
```dart
// ✅ Singleton para servicios
_getIt.registerSingleton<CameraService>(CameraService());
_getIt.registerSingleton<PermissionService>(PermissionService());

// ✅ Singleton para datasources
_getIt.registerSingleton<TensorFlowServerDataSource>(
  TensorFlowServerDataSourceImpl(dio, websocket),
);

// ✅ Factory para BLoCs
_getIt.registerFactory<CameraBloc>(
  () => CameraBloc(cameraService: _getIt<CameraService>()),
);
_getIt.registerFactory<BovinoBloc>(
  () => BovinoBloc(repository: _getIt<BovinoRepository>()),
);
_getIt.registerFactory<ThemeBloc>(() => ThemeBloc());

// ✅ Lazy Singleton
_getIt.registerLazySingleton<Repository>(
  () => RepositoryImpl(datasource: _getIt<DataSource>()),
);
```

### Uso de Dependencias
```dart
// ✅ En widgets
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DependencyInjection.cameraBloc,
      child: const HomeView(),
    );
  }
}

// ✅ En servicios
class SomeService {
  final Repository _repository = DependencyInjection.repository;
  final Logger _logger = Logger();
}
```

## 📱 UI y Widgets

### Estructura de Widgets
```dart
class CustomWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  
  const CustomWidget({
    super.key,
    required this.title,
    this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      // Usar constantes de AppColors y AppUIConfig
      color: AppColors.background,
      padding: const EdgeInsets.all(AppUIConfig.padding),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
```

### Uso de Colores y Mensajes
```dart
// ✅ Usar AppColors
Container(
  color: AppColors.primary,
  child: Text(
    AppMessages.cameraReady,
    style: TextStyle(color: AppColors.textPrimary),
  ),
)

// ✅ Usar AppUIConfig
Container(
  padding: const EdgeInsets.all(AppUIConfig.padding),
  margin: const EdgeInsets.all(AppUIConfig.margin),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
    boxShadow: AppUIConfig.cardShadow,
  ),
)
```

### Mostrar Información de Bovino
```dart
// ✅ Mostrar raza y peso estimado
Column(
  children: [
    Text('Raza: ${bovino.raza}'),
    Text('Peso estimado: ${bovino.pesoFormateado}'),
    Text('Peso en libras: ${bovino.pesoEnLibras}'),
    if (bovino.esPesoNormal)
      Text('Peso normal', style: TextStyle(color: Colors.green)),
  ],
)
```

## 🎨 Sistema de Temas

### Uso de ThemeManager
```dart
// ✅ Obtener tema por brillo
ThemeData theme = ThemeManager.getThemeByBrightness(Brightness.light);

// ✅ Obtener tema por booleano
ThemeData theme = ThemeManager.getThemeByBool(false); // Tema claro

// ✅ Verificar si es tema oscuro
bool isDark = ThemeManager.isDarkTheme(theme);

// ✅ Obtener nombre del tema
String themeName = ThemeManager.getThemeName(theme);
```

### Uso de ThemeFactory
```dart
// ✅ Crear estilos usando la factoría
final buttonStyle = ThemeFactory.createButtonStyle(
  backgroundColor: AppColors.primary,
  textColor: AppColors.onPrimary,
);
```

## 🔐 Sistema de Permisos

### Uso del PermissionService
```dart
// ✅ Verificar permisos
final hasPermission = await permissionService.hasCameraPermission();

// ✅ Solicitar permisos
final granted = await permissionService.requestCameraPermission();

// ✅ Verificar estado
final status = await permissionService.getCameraPermissionStatus();
```

### Manejo de Errores de Permisos
```dart
try {
  final granted = await permissionService.requestCameraPermission();
  if (granted) {
    // Proceder con la funcionalidad
  } else {
    // Mostrar mensaje de error
    _logger.w('Permisos de cámara denegados');
  }
} catch (e) {
  _logger.e('Error al solicitar permisos: $e');
}
```

## 📷 Servicio de Cámara

### Uso del CameraService
```dart
// ✅ Inicializar cámara
await cameraService.initialize();

// ✅ Iniciar captura de frames
cameraService.startFrameCapture();

// ✅ Escuchar frames capturados
cameraService.frameStream.listen((framePath) {
  _logger.i('Frame capturado: $framePath');
  // Procesar frame
});

// ✅ Detener captura
cameraService.stopFrameCapture();

// ✅ Liberar recursos
await cameraService.dispose();
```

### Manejo de Errores de Cámara
```dart
try {
  await cameraService.initialize();
  cameraService.startFrameCapture();
} catch (e) {
  _logger.e('Error en servicio de cámara: $e');
  // Manejar error apropiadamente
}
```

## 📝 Logging Profesional

### Uso de Logger
```dart
class ExampleService {
  final Logger _logger = Logger();
  
  Future<void> someMethod() async {
    _logger.i('Iniciando operación...');
    
    try {
      // Operación
      _logger.d('Detalles de la operación');
      _logger.i('Operación completada exitosamente');
    } catch (e) {
      _logger.e('Error en la operación: $e');
      rethrow;
    }
  }
}
```

### Niveles de Logging
- **Logger.v()**: Verbose - Información muy detallada
- **Logger.d()**: Debug - Información de debugging
- **Logger.i()**: Info - Información general
- **Logger.w()**: Warning - Advertencias
- **Logger.e()**: Error - Errores
- **Logger.wtf()**: What a Terrible Failure - Errores críticos

## 🧪 Testing

### Estructura de Tests
```dart
group('CameraBloc', () {
  late MockCameraService mockCameraService;
  late CameraBloc cameraBloc;
  
  setUp(() {
    mockCameraService = MockCameraService();
    cameraBloc = CameraBloc(cameraService: mockCameraService);
  });
  
  tearDown(() {
    cameraBloc.close();
  });
  
  test('debe emitir CameraReady cuando se inicializa correctamente', () async {
    // Arrange
    when(mockCameraService.initialize()).thenAnswer((_) async {});
    
    // Act
    cameraBloc.add(InitializeCamera());
    
    // Assert
    await expectLater(
      cameraBloc.stream,
      emitsInOrder([CameraLoading(), CameraReady()]),
    );
  });
});
```

### Convenciones de Testing
- **Arrange-Act-Assert** pattern
- **Nombres descriptivos** para tests
- **Mocks** para dependencias externas
- **Cobertura mínima** del 80%

## 📝 Documentación

### Comentarios de Código
```dart
/// Analiza un frame de ganado bovino y retorna información detallada incluyendo peso estimado.
/// 
/// [framePath] - Ruta del frame a analizar
/// 
/// Retorna un [Either<Failure, BovinoEntity>] donde:
/// - [Left] contiene un [Failure] si ocurre un error
/// - [Right] contiene un [BovinoEntity] con el análisis exitoso incluyendo peso estimado
/// 
/// Ejemplo de uso:
/// ```dart
/// final resultado = await repository.analizarFrame('path/to/frame.jpg');
/// resultado.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (bovino) => print('Raza: ${bovino.raza}, Peso: ${bovino.pesoFormateado}'),
/// );
/// ```
Future<Either<Failure, BovinoEntity>> analizarFrame(String framePath);
```

### Documentación de APIs
```dart
/// Datasource para comunicación con servidor TensorFlow.
/// 
/// Proporciona funcionalidades para:
/// - Envío de frames al servidor
/// - Recepción de notificaciones via WebSocket
/// - Manejo de errores de conexión
/// - Verificación de estado del servidor
/// - Análisis de peso estimado del bovino
abstract class TensorFlowServerDataSource {
  /// Envía un frame al servidor para análisis.
  /// 
  /// [framePath] - Ruta del frame a enviar
  /// 
  /// Retorna un [BovinoModel] con la información analizada incluyendo peso estimado.
  /// 
  /// Lanza [NetworkFailure] si hay problemas de conexión.
  Future<BovinoModel> analizarFrame(String framePath);
  
  /// Verifica la conexión con el servidor.
  /// 
  /// Retorna `true` si el servidor está disponible.
  Future<bool> verificarConexion();
  
  /// Stream de notificaciones asíncronas del servidor.
  Stream<BovinoModel> get notificacionesStream;
}
```

## 🔄 Git y Commits

### Convenciones de Commits
```
feat: agregar análisis de frames con peso estimado
fix: corregir error en conexión WebSocket
docs: actualizar documentación de API
refactor: simplificar lógica de cámara
test: agregar tests para CameraBloc
style: formatear código según estándares
perf: optimizar captura de frames
chore: actualizar dependencias
```

### Estructura de Branches
- **main**: Código de producción
- **develop**: Código de desarrollo
- **feature/nombre-funcionalidad**: Nuevas funcionalidades
- **fix/nombre-error**: Correcciones de bugs
- **hotfix/nombre-urgente**: Correcciones urgentes

## 🚀 Flujo de Desarrollo

### 1. **Nuevas Funcionalidades**
1. Crear rama desde `develop`
2. Implementar siguiendo Clean Architecture
3. Agregar tests
4. Documentar cambios
5. Crear Pull Request

### 2. **Code Review**
- Verificar cumplimiento de reglas
- Revisar cobertura de tests
- Validar documentación
- Comprobar manejo de errores
- Verificar accesibilidad
- Revisar logging apropiado

### 3. **Merge**
- Solo merge después de code review aprobado
- Mantener historial limpio
- Actualizar documentación si es necesario

## 🔧 Configuración de Desarrollo

### Dependencias Requeridas
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  get_it: ^7.6.4
  dio: ^5.3.2
  web_socket_channel: ^2.4.0
  camera: ^0.10.5+5
  permission_handler: ^11.0.1
  logger: ^2.0.2+1
  equatable: ^2.0.5
  dartz: ^0.10.1
```

### Configuración de Logger
```dart
// En main.dart
void main() {
  Logger.level = Level.debug; // En desarrollo
  // Logger.level = Level.warning; // En producción
  
  runApp(MyApp());
}
```

## 📱 Compatibilidad Android

### Configuración Específica
- **API mínima**: 21 (Android 5.0)
- **API objetivo**: 34 (Android 14)
- **Permisos**: Cámara, Almacenamiento
- **Características**: Cámara, Internet

### Optimizaciones Android
- **ProGuard/R8** habilitado para release
- **Multidex** habilitado
- **Splash screen** nativo
- **Iconos adaptativos**

---

*Estas reglas deben ser seguidas por todos los desarrolladores para mantener la consistencia y calidad del código, optimizado para Android.* 