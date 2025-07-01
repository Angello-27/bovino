# 🏗️ Arquitectura del Proyecto Bovino IA

## 🎯 Objetivo Principal

**Bovino IA** es una aplicación móvil **Android** que captura frames de la cámara en tiempo real y los envía a un servidor Python con TensorFlow para el reconocimiento automático de razas bovinas y estimación de peso, recibiendo notificaciones asíncronas con los resultados.

## 🔄 Flujo Asíncrono del Sistema Completo

### Arquitectura General
```
📱 App Flutter (Android) ←→ 🌐 Servidor Python (TensorFlow)
```

### Flujo de Análisis Asíncrono
1. **Captura de Frame**: La app Flutter captura frames de la cámara en tiempo real
2. **Envío Asíncrono**: Frame se envía al servidor Python via `POST /submit-frame`
3. **Procesamiento**: Servidor procesa la imagen con TensorFlow en background
4. **Consulta de Estado**: App consulta estado via `GET /check-status/{frame_id}` cada 2 segundos
5. **Resultado**: Cuando el análisis está completo, se evalúa con restricciones de precisión
6. **Limpieza**: Ambos lados eliminan los datos del frame procesado

### Estados del Frame
- **pending**: Frame recibido, esperando procesamiento
- **processing**: Frame siendo analizado por TensorFlow
- **completed**: Análisis completado con resultado
- **failed**: Error en el procesamiento

### Comunicación HTTP
- **Envío**: `POST /submit-frame` con archivo de imagen
- **Consulta**: `GET /check-status/{frame_id}` cada 2 segundos
- **Health Check**: `GET /health` para verificación de conexión
- **Estadísticas**: `GET /stats` para métricas del servidor

### 🎯 Sistema de Restricciones de Precisión

El sistema implementa un algoritmo inteligente para mostrar solo los mejores resultados:

#### **Reglas de Precisión Simplificadas**
1. **NUNCA mostrar resultados** con precisión < 70%
2. **Primer Resultado**: Mínimo 70% de precisión para ser mostrado
3. **Resultado Final**: Si la precisión ≥ 0.95%, no se cambia más
4. **Otros casos**: Solo cambiar si la nueva precisión es mayor

#### **Comportamiento de la UI**
- ✅ **Mantiene el último resultado exitoso** visible
- ✅ **No muestra "procesando frames"** después del primer resultado
- ✅ **Solo actualiza** si hay mejor precisión
- ✅ **Limpia el estado** solo cuando se sale al home
- ✅ **Evita resultados de baja calidad** (< 70%)

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

### 5. **Atomic Design**
- **Atoms**: Componentes básicos reutilizables
- **Molecules**: Componentes compuestos
- **Organisms**: Componentes complejos
- **Screens**: Pantallas reutilizables
- **Separación clara** de responsabilidades

## 📁 Estructura del Proyecto

```
lib/
├── core/                    # 🧠 Capa Core
│   ├── constants/          # Constantes globales
│   │   ├── app_constants.dart      # Configuración general y endpoints
│   │   ├── app_colors.dart         # Colores del sistema de diseño
│   │   └── app_messages.dart       # Mensajes centralizados de la aplicación
│   ├── di/                 # Inyección de dependencias modular
│   │   ├── dependency_injection.dart    # Coordinador principal
│   │   ├── http_injection.dart          # Configuración HTTP
│   │   ├── services_injection.dart      # Servicios core
│   │   ├── data_injection.dart          # Capa de datos
│   │   └── presentation_injection.dart  # Capa de presentación
│   ├── errors/             # Manejo de errores
│   │   └── failures.dart
│   ├── routes/             # Navegación
│   │   └── app_router.dart
│   ├── services/           # Servicios core
│   │   ├── camera_service.dart     # Servicio de cámara optimizado
│   │   ├── permission_service.dart # Sistema de permisos
│   │   └── splash_service.dart     # Servicio de splash screen
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
│   │   └── bovino_model.dart       # Incluye peso estimado
│   └── repositories/       # Implementaciones
│       └── bovino_repository_impl.dart
├── domain/                 # 🎯 Capa de Dominio
│   ├── entities/           # Entidades de negocio
│   │   └── bovino_entity.dart      # Incluye peso estimado y getters útiles
│   └── repositories/       # Contratos
│       └── bovino_repository.dart
└── presentation/           # 🎨 Capa de Presentación
    ├── blocs/              # Gestión de estado mejorada
    │   ├── camera_bloc.dart        # BLoC para cámara con lógica real
    │   ├── bovino_bloc.dart        # BLoC para análisis bovino con Either
    │   ├── frame_analysis_bloc.dart # BLoC para análisis de frames con restricciones
    │   ├── theme_bloc.dart         # BLoC para temas dinámicos
    │   └── splash_bloc.dart        # BLoC para splash screen
    ├── pages/              # Páginas principales
    │   ├── splash_page.dart        # Página de splash con animaciones
    │   ├── home_page.dart          # Página principal
    │   ├── camera_page.dart        # Página de cámara
    │   ├── settings_page.dart      # Página de configuración
    │   └── not_found_page.dart     # Página 404
    └── widgets/            # Componentes UI siguiendo Atomic Design
        ├── atoms/          # Componentes básicos
        │   ├── custom_text.dart           # Textos personalizados
        │   ├── custom_button.dart         # Botones personalizados
        │   ├── custom_icon.dart           # Iconos personalizados
        │   └── bovino_breed_card.dart     # Tarjetas de razas
        ├── molecules/      # Componentes compuestos
        │   ├── home_header.dart           # Encabezado principal
        │   ├── stats_card.dart            # Tarjetas de estadísticas
        │   ├── breeds_list.dart           # Lista de razas
        │   ├── theme_toggle_button.dart   # Botón de cambio de tema
        │   ├── theme_indicator.dart       # Indicador de tema
        │   └── theme_error_widget.dart    # Widget de error de tema
        ├── organisms/      # Componentes complejos
        │   ├── app_bar_organism.dart      # Barra superior
        │   ├── bottom_navigation_organism.dart # Navegación inferior
        │   ├── home_content_organism.dart # Contenido principal
        │   ├── camera_capture_organism.dart # Captura de cámara
        │   ├── camera_view_organism.dart  # Vista de cámara
        │   ├── settings_view_organism.dart # Vista de configuración
        │   └── error_display.dart         # Organismo de errores
        └── screens/        # Pantallas reutilizables
            ├── screen_home.dart           # Screen para página principal
            └── screen_camera.dart         # Screen para página de cámara
```

## 🔄 Flujo de Datos

### 1. **Splash Screen**
```
Inicio → SplashService → SplashBloc → SplashPage → HomePage
```

### 2. **Captura de Frames**
```
Cámara → CameraService → CameraBloc → UI
```

### 3. **Análisis de Frames con Peso Estimado**
```
Frame → TensorFlowServerDataSourceImpl → BovinoRepository → BovinoBloc → UI
```

### 4. **Análisis de Frames con Restricciones**
```
Frame → BovinoBloc → FrameAnalysisBloc → Evaluación de Precisión → UI
```

### 5. **Consulta de Estado Asíncrona**
```
Servidor → HTTP Polling → BovinoBloc → FrameAnalysisBloc → UI
```

## 🤖 Modelo de Aprendizaje (Servidor Python)

### Arquitectura del Modelo
- **Base Model**: MobileNetV2 pre-entrenado con ImageNet
- **Transfer Learning**: Fine-tuning para clasificación de razas bovinas
- **Input**: Imágenes 224x224 píxeles RGB
- **Output**: Probabilidades para 5 razas bovinas principales

### Razas Soportadas
- **Ayrshire**: Rojo y blanco, mediana, lechera, resistente
- **Brown Swiss**: Marrón, grande, lechera, gentil
- **Holstein**: Blanco y negro, grande, lechera, alta producción
- **Jersey**: Marrón claro, pequeña, lechera, alta grasa
- **Red Dane**: Rojo, grande, lechera, europeo

### Estimación de Peso
El modelo estima el peso basado en:
- **Raza identificada**: Peso promedio de la raza
- **Confianza del modelo**: Ajuste basado en la certeza
- **Características visuales**: Análisis de tamaño y proporciones
- **Rango válido**: 200-1200 kg

## 🎨 Patrones de Diseño

### 1. **Repository Pattern**
- **Abstracción** de fuentes de datos
- **Independencia** de implementaciones específicas
- **Testabilidad** mediante mocks

### 2. **BLoC Pattern Mejorado**
- **Gestión de estado** centralizada con Equatable
- **Eventos** para acciones del usuario
- **Estados** para representar la UI
- **Logging profesional** integrado
- **Manejo de errores** con Failure objects

### 3. **Dependency Injection Modular**
- **GetIt** para gestión de dependencias
- **Módulos separados** por responsabilidad
- **Inversión de control**
- **Testabilidad** mejorada

### 4. **Observer Pattern**
- **HTTP Polling** para consulta de estado
- **Streams** para comunicación reactiva

### 5. **Factory Pattern**
- **ThemeFactory** para creación de estilos
- **DependencyInjection** para creación de servicios

### 6. **Atomic Design**
- **Atoms**: Componentes básicos reutilizables
- **Molecules**: Componentes compuestos
- **Organisms**: Componentes complejos
- **Screens**: Pantallas reutilizables

## 🔧 Tecnologías y Dependencias

### Core
- **Flutter**: Framework de desarrollo
- **Dart**: Lenguaje de programación
- **GetIt**: Inyección de dependencias modular
- **Logger**: Sistema de logging profesional

### Estado y Navegación
- **flutter_bloc**: Gestión de estado reactiva
- **go_router**: Navegación declarativa
- **equatable**: Comparación eficiente de objetos

### Comunicación
- **Dio**: Cliente HTTP con interceptores
- **HTTP Polling**: Consulta periódica de estado cada 2 segundos

### Cámara y Permisos
- **camera**: Acceso a cámara optimizado
- **permission_handler**: Sistema de permisos robusto

### Utilidades
- **dartz**: Programación funcional (Either/Left/Right)
- **equatable**: Comparación de objetos

## 📊 Estructura de Datos

### Entidades de Dominio
```dart
class BovinoEntity {
  final String raza;
  final List<String> caracteristicas;
  final double confianza;
  final DateTime timestamp;
  final double pesoEstimado; // Nuevo campo
  
  // Getters útiles
  String get pesoFormateado => '${pesoEstimado.toStringAsFixed(1)} kg';
  String get pesoEnLibras => '${(pesoEstimado * 2.20462).toStringAsFixed(1)} lbs';
  bool get esPesoNormal => pesoEstimado >= 300 && pesoEstimado <= 800;
}
```

### Estados de BLoC Mejorados
```dart
// CameraBloc States
abstract class CameraState extends Equatable {}
class CameraInitial extends CameraState {}
class CameraLoading extends CameraState {}
class CameraReady extends CameraState {}
class CameraCapturing extends CameraState {}
class CameraError extends CameraState {}

// BovinoBloc States
abstract class BovinoState extends Equatable {}
class BovinoInitial extends BovinoState {}
class BovinoAnalyzing extends BovinoState {}
class BovinoResult extends BovinoState {}
class BovinoError extends BovinoState {}

// SplashBloc States
abstract class SplashState extends Equatable {}
class SplashInitial extends SplashState {}
class SplashLoading extends SplashState {}
class SplashCheckingServer extends SplashState {}
class SplashReady extends SplashState {}
class SplashError extends SplashState {}
```

## 🎯 Responsabilidades por Capa

### Core
- **Constantes**: Configuración global centralizada con AppMessages
- **DI**: Gestión modular de dependencias con GetIt
- **Errores**: Manejo centralizado con Failures tipados
- **Servicios**: Funcionalidades core optimizadas
- **Temas**: Sistema de diseño avanzado

### Data
- **Datasources**: Comunicación con APIs HTTP
- **Models**: Representación de datos con validaciones
- **Repositories**: Implementación de contratos

### Domain
- **Entities**: Entidades de negocio inmutables con getters útiles
- **Repositories**: Contratos de datos

### Presentation
- **BLoCs**: Gestión de estado reactiva con logging profesional
- **Pages**: Páginas principales con lógica de negocio
- **Widgets**: Componentes UI organizados por Atomic Design
  - **Atoms**: Componentes básicos reutilizables
  - **Molecules**: Componentes compuestos
  - **Organisms**: Componentes complejos
  - **Screens**: Pantallas reutilizables

## 🔄 Ciclo de Vida de la Aplicación

### 1. **Inicialización**
```
main() → DependencyInjection.initialize() → App
```

### 2. **Flujo Principal**
```
SplashPage → SplashBloc → SplashService → Verificación de servidor
HomePage → ScreenHome → Organisms → Molecules → Atoms
CameraPage → ScreenCamera → CameraBloc → CameraService → Frame Capture
Frame → BovinoBloc → Repository → TensorFlowServerDataSourceImpl
Server → HTTP Polling → BovinoBloc → UI Update (incluyendo peso estimado)
```

### 3. **Manejo de Errores**
```
Error → Failure → BLoC → UI Error State
```

## 🚀 Splash Screen Nativo

### Características
- **Configuración nativa** en Android (`launch_background.xml`)
- **Animaciones fluidas** con AnimationController
- **Estados reactivos** con BLoC
- **Verificación automática** de servidor
- **Transición suave** a la aplicación principal

### Arquitectura del Splash
```
SplashPage → SplashBloc → SplashService → Verificación → Navegación
```

### Estados del Splash
- **SplashInitial**: Estado inicial
- **SplashLoading**: Cargando recursos
- **SplashCheckingServer**: Verificando servidor
- **SplashReady**: Listo para navegar
- **SplashError**: Error en el proceso

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

## 🔌 Inyección de Dependencias Modular

### Características
- **GetIt** como contenedor IoC
- **Módulos separados** por responsabilidad
- **Logger** para debugging profesional
- **Interceptores HTTP** para logging
- **HTTP Polling** con manejo de errores
- **Registro de dependencias** organizado

### Estructura Modular
```dart
// Servicios core
_getIt.registerSingleton<CameraService>(CameraService());
_getIt.registerSingleton<PermissionService>(PermissionService());
_getIt.registerSingleton<SplashService>(SplashService());

// Datasources
_getIt.registerSingleton<TensorFlowServerDataSource>(
  TensorFlowServerDataSourceImpl(dio),
);

// BLoCs con Factory pattern
_getIt.registerFactory<CameraBloc>(
  () => CameraBloc(cameraService: cameraService),
);
_getIt.registerFactory<BovinoBloc>(
  () => BovinoBloc(repository: repository),
);
_getIt.registerFactory<ThemeBloc>(() => ThemeBloc());
_getIt.registerFactory<SplashBloc>(
  () => SplashBloc(splashService: splashService),
);
```

## 📱 Compatibilidad

### Plataformas Soportadas
- ✅ **Android (API 21+)**

### Configuración del Servidor
- **URL**: `http://192.168.0.8:8000`
- **HTTP Polling**: Consulta periódica cada 2 segundos
- **Endpoints**: `/submit-frame`, `/check-status/{frame_id}`, `/health`
- **Respuesta**: Incluye `peso_estimado` en kg

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

## 🔄 Mejoras Recientes

### Sistema de Restricciones de Precisión
- ✅ **Algoritmo inteligente** para mostrar solo mejores resultados
- ✅ **Primer resultado** con mínimo 70% de precisión
- ✅ **Resultado final** cuando precisión ≥ 0.95%
- ✅ **Reemplazo basado solo en precisión** (sin importar raza)
- ✅ **Eliminación de resultados de baja calidad** (< 70%)
- ✅ **Logs detallados** con razones de cambio/rechazo

### FrameAnalysisBloc
- ✅ **Gestión de estado** para análisis de frames
- ✅ **Evaluación de precisión** con restricciones
- ✅ **Mantenimiento de resultados** en memoria
- ✅ **Limpieza automática** al salir al home
- ✅ **Verificación de estado** del BLoC antes de eventos

### Comportamiento de UI Mejorado
- ✅ **Mantiene resultado visible** después del primer éxito
- ✅ **No muestra "procesando frames"** después del primer resultado
- ✅ **Solo actualiza** si hay mejor precisión o cambio válido
- ✅ **Limpia estado** solo cuando se sale al home
- ✅ **Variable de estado local** para último resultado exitoso

### Flujo Asíncrono
- ✅ **Análisis asíncrono** con cola en memoria
- ✅ **HTTP polling** cada 2 segundos
- ✅ **Limpieza automática** de frames antiguos
- ✅ **Estados de frame** bien definidos

### Splash Screen Nativo
- ✅ **Configuración nativa** en Android
- ✅ **Animaciones fluidas** con AnimationController
- ✅ **Estados reactivos** con BLoC
- ✅ **Verificación de servidor** automática
- ✅ **Transición suave** a la aplicación

### Atomic Design Completo
- ✅ **Atoms** implementados completamente
- ✅ **Molecules** organizados por funcionalidad
- ✅ **Organisms** para componentes complejos
- ✅ **Screens** para pantallas reutilizables
- ✅ **Separación clara** de responsabilidades

### BLoCs Mejorados
- ✅ **Equatable** para comparaciones eficientes
- ✅ **Logging profesional** integrado
- ✅ **Manejo de errores** con Failure objects
- ✅ **Either/Left/Right** para programación funcional
- ✅ **Métodos privados** para cada evento
- ✅ **Verificación de estado** antes de emitir eventos

### Peso Estimado
- ✅ **Campo agregado** a BovinoEntity y BovinoModel
- ✅ **Getters útiles** para formateo
- ✅ **Validaciones** en fromJson
- ✅ **Soporte completo** en toda la arquitectura

### Inyección de Dependencias
- ✅ **Módulos separados** por responsabilidad
- ✅ **Factory pattern** para BLoCs
- ✅ **Singleton** para servicios
- ✅ **Lazy loading** donde corresponde

### Estructura de Screens
- ✅ **Screens** en lugar de templates
- ✅ **Prefijo screen_** para archivos
- ✅ **Sin conflictos** con IDE
- ✅ **Mejor análisis** de código

## 📄 Documentación Relacionada

- [README Principal](../README.md) - Documentación completa del proyecto
- [Servidor Python](../server/README.md) - Documentación del servidor TensorFlow
- [Reglas de Desarrollo](REGLAS_DESARROLLO.md) - Convenciones del proyecto

---

*Esta arquitectura está diseñada para ser escalable, mantenible y testeable, siguiendo las mejores prácticas de Clean Architecture, BLoC Pattern, Atomic Design y SOLID Principles, optimizada para Android con flujo asíncrono completo.* 