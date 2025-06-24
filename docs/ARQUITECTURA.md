# 🏗️ Arquitectura del Proyecto Bovino IA

## 🎯 Objetivo Principal

**Bovino IA** es una aplicación móvil que captura frames de la cámara en tiempo real y los envía a un servidor Python con TensorFlow para el reconocimiento automático de razas bovinas, recibiendo notificaciones asíncronas con los resultados.

## 🏛️ Principios Arquitectónicos

### 1. **Clean Architecture**
- **Separación clara de responsabilidades** entre capas
- **Independencia de frameworks** y tecnologías externas
- **Testabilidad** en todos los niveles
- **Independencia de UI** y base de datos

### 2. **SOLID Principles**
- **S** - Responsabilidad única por módulo
- **O** - Extensibilidad sin modificación
- **L** - Sustitución de Liskov
- **I** - Segregación de interfaces
- **D** - Inversión de dependencias

### 3. **BLoC Pattern**
- **Gestión de estado reactiva** y predecible
- **Separación de lógica de negocio** de la UI
- **Testabilidad** de la lógica de estado
- **Reutilización** de lógica entre widgets

### 4. **Domain-Driven Design (DDD)**
- **Entidades de dominio** bien definidas
- **Repositorios** como abstracción de datos
- **Servicios de dominio** para lógica compleja

## 📁 Estructura del Proyecto

```
lib/
├── core/                    # 🧠 Capa Core
│   ├── constants/          # Constantes globales
│   │   ├── app_constants.dart      # Configuración general y endpoints
│   │   ├── app_colors.dart         # Colores del sistema de diseño
│   │   └── app_messages.dart       # Mensajes de la aplicación
│   ├── di/                 # Inyección de dependencias
│   │   └── dependency_injection.dart
│   ├── errors/             # Manejo de errores
│   │   └── failures.dart
│   ├── routes/             # Navegación
│   │   └── app_router.dart
│   ├── services/           # Servicios core
│   │   ├── camera_service.dart     # Servicio de cámara optimizado
│   │   └── permission_service.dart # Sistema de permisos
│   └── theme/              # Sistema de temas avanzado
│       ├── app_theme.dart          # Fábrica de temas
│       ├── dark_theme.dart         # Tema oscuro
│       ├── light_theme.dart        # Tema claro
│       ├── theme_factory.dart      # Factoría de estilos
│       └── theme_manager.dart      # Gestor de temas
├── data/                   # 📊 Capa de Datos
│   ├── datasources/        # Fuentes de datos
│   │   └── remote/
│   │       ├── tensorflow_server_datasource.dart      # Contrato abstracto
│   │       └── tensorflow_server_datasource_impl.dart # Implementación concreta
│   ├── models/             # Modelos de datos
│   │   └── bovino_model.dart
│   └── repositories/       # Implementaciones
│       └── bovino_repository_impl.dart
├── domain/                 # 🎯 Capa de Dominio
│   ├── entities/           # Entidades de negocio
│   │   └── bovino_entity.dart
│   └── repositories/       # Contratos
│       └── bovino_repository.dart
└── presentation/           # 🎨 Capa de Presentación
    ├── blocs/              # Gestión de estado
    │   ├── camera_bloc.dart        # BLoC para cámara
    │   └── bovino_bloc.dart        # BLoC para análisis bovino
    ├── pages/              # Páginas principales
    │   └── home_page.dart
    └── widgets/            # Componentes UI
        ├── molecules/      # Componentes compuestos
        └── organisms/      # Componentes complejos
```

## 🔄 Flujo de Datos

### 1. **Captura de Frames**
```
Cámara → CameraService → CameraBloc → UI
```

### 2. **Análisis de Frames**
```
Frame → TensorFlowServerDataSourceImpl → BovinoRepository → BovinoBloc → UI
```

### 3. **Notificaciones Asíncronas**
```
Servidor → WebSocket → BovinoBloc → UI
```

## 🎨 Patrones de Diseño

### 1. **Repository Pattern**
- **Abstracción** de fuentes de datos
- **Independencia** de implementaciones específicas
- **Testabilidad** mediante mocks

### 2. **BLoC Pattern**
- **Gestión de estado** centralizada
- **Eventos** para acciones del usuario
- **Estados** para representar la UI

### 3. **Dependency Injection**
- **GetIt** para gestión de dependencias
- **Inversión de control**
- **Testabilidad** mejorada

### 4. **Observer Pattern**
- **WebSocket** para notificaciones
- **Streams** para comunicación reactiva

### 5. **Factory Pattern**
- **ThemeFactory** para creación de estilos
- **DependencyInjection** para creación de servicios

## 🔧 Tecnologías y Dependencias

### Core
- **Flutter**: Framework de desarrollo
- **Dart**: Lenguaje de programación
- **GetIt**: Inyección de dependencias
- **Logger**: Sistema de logging profesional

### Estado y Navegación
- **flutter_bloc**: Gestión de estado
- **go_router**: Navegación declarativa

### Comunicación
- **Dio**: Cliente HTTP con interceptores
- **web_socket_channel**: WebSocket para notificaciones

### Cámara y Permisos
- **camera**: Acceso a cámara optimizado
- **permission_handler**: Sistema de permisos robusto

### Utilidades
- **dartz**: Programación funcional
- **equatable**: Comparación de objetos

## 📊 Estructura de Datos

### Entidades de Dominio
```dart
class BovinoEntity {
  final String raza;
  final List<String> caracteristicas;
  final double confianza;
  final DateTime timestamp;
}
```

### Estados de BLoC
```dart
// CameraBloc States
abstract class CameraState {}
class CameraInitial extends CameraState {}
class CameraLoading extends CameraState {}
class CameraReady extends CameraState {}
class CameraError extends CameraState {}

// BovinoBloc States
abstract class BovinoState {}
class BovinoInitial extends BovinoState {}
class BovinoAnalyzing extends BovinoState {}
class BovinoResult extends BovinoState {}
class BovinoError extends BovinoState {}
```

## 🎯 Responsabilidades por Capa

### Core
- **Constantes**: Configuración global centralizada
- **DI**: Gestión de dependencias con GetIt
- **Errores**: Manejo centralizado con Failures
- **Servicios**: Funcionalidades core optimizadas
- **Temas**: Sistema de diseño avanzado

### Data
- **Datasources**: Comunicación con APIs y WebSocket
- **Models**: Representación de datos
- **Repositories**: Implementación de contratos

### Domain
- **Entities**: Entidades de negocio inmutables
- **Repositories**: Contratos de datos

### Presentation
- **BLoCs**: Gestión de estado reactiva
- **Pages**: Páginas principales
- **Widgets**: Componentes UI reutilizables

## 🔄 Ciclo de Vida de la Aplicación

### 1. **Inicialización**
```
main() → DependencyInjection.initialize() → App
```

### 2. **Flujo Principal**
```
HomePage → CameraBloc → CameraService → Frame Capture
Frame → BovinoBloc → Repository → TensorFlowServerDataSourceImpl
Server → WebSocket → BovinoBloc → UI Update
```

### 3. **Manejo de Errores**
```
Error → Failure → BLoC → UI Error State
```

## 🎨 Sistema de Temas

### Características
- **Tema claro y oscuro** sincronizados
- **Factoría de estilos** centralizada
- **Constantes de diseño** unificadas
- **Gestor de temas** estático
- **Colores con prefijos** para consistencia

### Uso
```dart
// Obtener tema por brillo del sistema
ThemeData theme = ThemeManager.getThemeByBrightness(Brightness.light);

// Obtener tema por valor booleano
ThemeData theme = ThemeManager.getThemeByBool(false); // Tema claro
```

## 🔐 Sistema de Permisos

### Características
- **Soporte Android 10-15** optimizado
- **Manejo de permisos de cámara**
- **Verificación de estado**
- **Solicitud de permisos**
- **Logging profesional**

### Uso
```dart
final permissionService = DependencyInjection.permissionService;
final hasPermission = await permissionService.requestCameraPermission();
```

## 📷 Servicio de Cámara

### Características
- **Captura de frames** periódica
- **Límites de captura** configurables
- **Emisión de rutas** de imágenes
- **Manejo de errores** robusto
- **Logging detallado**

### Uso
```dart
final cameraService = DependencyInjection.cameraService;
await cameraService.initialize();
cameraService.startFrameCapture();
```

## 🔌 Inyección de Dependencias

### Características
- **GetIt** como contenedor IoC
- **Logger** para debugging profesional
- **Interceptores HTTP** para logging
- **WebSocket** con manejo de errores
- **Registro de dependencias** organizado

### Estructura
```dart
// Servicios core
_getIt.registerSingleton<CameraService>(CameraService());
_getIt.registerSingleton<PermissionService>(PermissionService());

// Datasources
_getIt.registerSingleton<TensorFlowServerDataSource>(
  TensorFlowServerDataSourceImpl(dio, websocket),
);

// BLoCs
_getIt.registerFactory<CameraBloc>(
  () => CameraBloc(cameraService: cameraService),
);
```

## 📱 Compatibilidad

### Plataformas Soportadas
- ✅ Android (API 21+)

### Configuración del Servidor
- **URL**: `http://192.168.0.8:8000`
- **WebSocket**: `ws://192.168.0.8:8000/ws`
- **Endpoints**: `/analyze-frame`, `/health`

## 🧪 Testing

### Estrategia
- **Unit Tests** para BLoCs y servicios
- **Widget Tests** para componentes UI
- **Integration Tests** para flujos completos
- **Mocking** con Mockito

### Cobertura
- **Mínimo 80%** de cobertura
- **Tests críticos** para lógica de negocio
- **Tests de UI** para componentes principales

---

*Esta arquitectura está diseñada para ser escalable, mantenible y testeable, siguiendo las mejores prácticas de Clean Architecture, BLoC Pattern y SOLID Principles.* 