# Bovino IA - Reconocimiento de Ganado Bovino en Tiempo Real

Una aplicación Flutter moderna que utiliza **cámara en vivo** para capturar frames y enviarlos a un servidor Python con TensorFlow para identificar razas de ganado bovino y estimar su peso. Desarrollada siguiendo Clean Architecture, SOLID Principles y BLoC Pattern, **optimizada exclusivamente para Android**.

## 🎯 Objetivo Principal

**Bovino IA** es una aplicación móvil **Android** que captura frames de la cámara en tiempo real y los envía a un servidor Python con TensorFlow para el reconocimiento automático de razas bovinas y estimación de peso, recibiendo notificaciones asíncronas con los resultados.

## 🚀 Características

- 📸 **Cámara en vivo** con captura automática de frames
- 🤖 **Análisis remoto** usando TensorFlow en servidor Python
- 🐄 **Identificación automática** de razas bovinas
- ⚖️ **Estimación de peso** del animal según la raza
- 🎯 **Sistema de restricciones de precisión** para mostrar solo mejores resultados
- 🔄 **Flujo asíncrono** con HTTP polling para consulta de estado
- 🎨 **Interfaz moderna** con Material Design 3
- 🌙 **Temas claro y oscuro** con cambio dinámico
- 🔒 **Manejo robusto de permisos** para Android 10-15
- 🎯 **Arquitectura limpia** siguiendo Clean Architecture + BLoC
- 📊 **Logging profesional** para debugging
- 🔧 **Inyección de dependencias modular**
- 🚀 **Splash screen nativo** con animaciones fluidas
- 🏗️ **Atomic Design** implementado completamente

## 🔄 Flujo Asíncrono del Sistema

### Arquitectura General
```
📱 App Flutter (Android) ←→ 🌐 Servidor Python (TensorFlow)
```

### Flujo de Análisis Asíncrono
1. **Captura de Frame**: La app Flutter captura frames de la cámara en tiempo real
2. **Envío Asíncrono**: Frame se envía al servidor Python via `POST /submit-frame`
3. **Procesamiento**: Servidor procesa la imagen con TensorFlow en background
4. **Consulta de Estado**: App consulta estado via `GET /check-status/{frame_id}` cada 2 segundos
5. **Evaluación de Precisión**: Se evalúa el resultado con restricciones de precisión
6. **Resultado**: Solo se muestra si cumple los criterios de calidad
7. **Limpieza**: Ambos lados eliminan los datos del frame procesado

### 🎯 Sistema de Restricciones de Precisión

El sistema implementa un algoritmo inteligente para mostrar solo los mejores resultados:

#### **Reglas de Precisión**
1. **Primer Resultado**: Mínimo 70% de precisión para ser mostrado
2. **Resultado Final**: Si la precisión ≥ 0.95%, no se cambia más
3. **Reemplazo**: Solo cambiar si la nueva precisión es mayor (sin importar raza)

### Estados del Frame
- **pending**: Frame recibido, esperando procesamiento
- **processing**: Frame siendo analizado por TensorFlow
- **completed**: Análisis completado con resultado
- **failed**: Error en el procesamiento

## 🏗️ Arquitectura

El proyecto sigue **Clean Architecture** con **BLoC Pattern mejorado** para gestión de estado:

```
lib/
├── core/                    # 🧠 Capa Core
│   ├── constants/          # Constantes centralizadas
│   │   ├── app_constants.dart      # Configuración y endpoints
│   │   ├── app_colors.dart         # Colores del sistema
│   │   └── app_messages.dart       # Mensajes centralizados
│   ├── di/                 # Inyección de dependencias modular
│   │   ├── dependency_injection.dart    # Coordinador principal
│   │   ├── http_injection.dart          # Configuración HTTP
│   │   ├── services_injection.dart      # Servicios core
│   │   ├── data_injection.dart          # Capa de datos
│   │   └── presentation_injection.dart  # Capa de presentación
│   ├── errors/             # Manejo de errores tipados
│   ├── services/           # Servicios core (cámara, permisos, splash)
│   ├── theme/              # Sistema de temas avanzado
│   └── routes/             # Manejo de rutas
├── data/                   # 📊 Capa de Datos
│   ├── datasources/        # Fuentes de datos (servidor TensorFlow)
│   ├── models/             # Modelos con validaciones
│   └── repositories/       # Implementaciones de repositorios
├── domain/                 # 🎯 Capa de Dominio
│   ├── entities/           # Entidades con getters útiles
│   └── repositories/       # Contratos de repositorios
└── presentation/           # 🎨 Capa de Presentación
    ├── blocs/              # Gestión de estado mejorada
    │   ├── camera_bloc.dart        # BLoC para cámara con lógica real
    │   ├── bovino_bloc.dart        # BLoC para análisis con Either
    │   ├── frame_analysis_bloc.dart # BLoC para análisis de frames con restricciones
    │   ├── theme_bloc.dart         # BLoC para temas dinámicos
    │   └── splash_bloc.dart        # BLoC para splash screen
    ├── pages/              # Páginas de la aplicación
    │   ├── splash_page.dart        # Página de splash con animaciones
    │   ├── home_page.dart          # Página principal
    │   ├── camera_page.dart        # Página de cámara
    │   ├── settings_page.dart      # Página de configuración
    │   └── not_found_page.dart     # Página 404
    └── widgets/            # Widgets organizados por Atomic Design
        ├── atoms/          # Componentes básicos
        ├── molecules/      # Componentes compuestos
        ├── organisms/      # Componentes complejos
        └── screens/        # Pantallas reutilizables
            ├── screen_home.dart    # Screen para página principal
            └── screen_camera.dart  # Screen para página de cámara
```

## 🎨 Atomic Design Implementado

Los widgets están organizados siguiendo **Atomic Design** de manera completa:

### **Atoms** (Componentes Básicos)
- `CustomText` - Textos con diferentes estilos (Title, Subtitle, Body, Caption)
- `CustomButton` - Botones con diferentes variantes
- `CustomIcon` - Iconos personalizados
- `BovinoBreedCard` - Tarjetas de razas bovinas

### **Molecules** (Componentes Compuestos)
- `HomeHeader` - Encabezado de la página principal
- `StatsCard` - Tarjetas de estadísticas
- `BreedsList` - Lista de razas bovinas
- `ThemeToggleButton` - Botón de cambio de tema
- `ThemeIndicator` - Indicador de tema actual
- `ThemeErrorWidget` - Widget de error de tema

### **Organisms** (Componentes Complejos)
- `AppBarOrganism` - Barra superior de la aplicación
- `BottomNavigationOrganism` - Navegación inferior
- `HomeContentOrganism` - Contenido principal de la página de inicio
- `CameraCaptureOrganism` - Organismo de captura de cámara
- `CameraViewOrganism` - Vista de cámara
- `SettingsViewOrganism` - Vista de configuración
- `ErrorDisplay` - Organismo para mostrar errores

### **Screens** (Pantallas Reutilizables)
- `ScreenHome` - Pantalla principal con navegación
- `ScreenCamera` - Pantalla de captura de cámara

## 🚀 Splash Screen Nativo

### **Características del Splash:**
- **Nativo Android:** Configuración en `launch_background.xml`
- **Animaciones fluidas:** Fade, scale y transiciones suaves
- **Estados reactivos:** Loading, checking server, ready, error
- **Verificación de servidor:** Conexión automática al servidor TensorFlow
- **Duración mínima:** 2 segundos para experiencia consistente

### **Flujo del Splash:**
1. **Inicio:** Logo animado con fade y scale
2. **Carga:** "Iniciando aplicación..."
3. **Verificación:** "Verificando conexión al servidor..."
4. **Listo:** "Servidor conectado" o "Servidor no disponible"
5. **Navegación:** Transición automática a HomePage

## 🎨 Comportamiento de UI Mejorado

### **Gestión Inteligente de Resultados**
- ✅ **Mantiene el último resultado exitoso** visible en pantalla
- ✅ **No muestra "procesando frames"** después del primer resultado exitoso
- ✅ **Solo actualiza** si hay mejor precisión o cambio de raza válido
- ✅ **Limpia el estado** solo cuando se sale al home
- ✅ **Variable de estado local** para mantener el último resultado exitoso

### **Experiencia de Usuario Optimizada**
- 🎯 **Resultados de calidad**: Solo se muestran resultados con precisión ≥ 70%
- 🔄 **Actualizaciones inteligentes**: Cambios solo cuando hay mejor precisión
- 📱 **Persistencia de estado**: Resultados se mantienen aunque se detenga el análisis
- 🧹 **Limpieza automática**: Estado se resetea al salir al home

## 🎯 Principios Aplicados

- **Clean Architecture:** Separación clara de responsabilidades
- **SOLID Principles:** Principios de diseño orientado a objetos
- **BLoC Pattern Mejorado:** Gestión de estado reactiva con Equatable
- **Domain-Driven Design:** Entidades de dominio bien definidas
- **Programación Funcional:** Uso de Either/Left/Right para manejo de errores
- **Atomic Design:** Componentes organizados por complejidad
- **Dependency Injection Modular:** Inyección de dependencias con GetIt

## ⚙️ Configuración

### 1. Instalar Dependencias

```bash
flutter pub get
```

### 2. Configurar Servidor TensorFlow

1. Configura la URL del servidor en `lib/core/constants/app_constants.dart`
2. Asegúrate de que el servidor Python esté ejecutándose en `10.121.154.51`
3. El servidor debe tener endpoints para:
   - Envío de frames: `POST /submit-frame` (análisis asíncrono)
   - Consulta de estado: `GET /check-status/{frame_id}` (HTTP polling)
   - Health check: `GET /health` (verificación de conexión)

### 3. Permisos

La aplicación solicita automáticamente los permisos necesarios:
- **Cámara**: Para captura de frames en tiempo real
- **Internet**: Para comunicación con el servidor

### 4. Ejecutar la Aplicación

```bash
flutter run
```

## 📱 Uso

### Flujo de Funcionamiento
1. **Splash Screen:** Animación de inicio y verificación de servidor
2. **Iniciar cámara**: La aplicación abre la cámara en tiempo real
3. **Captura automática**: Se capturan frames cada X segundos
4. **Envío al servidor**: Los frames se envían al servidor TensorFlow
5. **Análisis remoto**: El servidor procesa la imagen con TensorFlow
6. **Consulta de estado**: La app consulta el estado del frame periódicamente
7. **Visualización**: Se muestra la raza identificada, peso estimado y características

### Interfaz
- **Splash screen**: Animación de inicio con verificación de conexión
- **Pantalla principal**: Cámara en vivo con overlay de resultados
- **Indicadores**: Estado de conexión, análisis en progreso
- **Resultados**: Raza identificada, peso estimado y características del bovino

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter**: Framework de desarrollo móvil
- **Material Design 3**: Sistema de diseño moderno
- **GoRouter**: Navegación declarativa
- **BLoC Mejorado**: Gestión de estado reactiva con Equatable

### Backend & APIs
- **Servidor Python**: Con TensorFlow para análisis y estimación de peso
- **Dio**: Cliente HTTP para envío de frames
- **HTTP Polling**: Consulta periódica de estado cada 2 segundos

### Cámara y Permisos
- **Camera Plugin**: Acceso a cámara en tiempo real
- **Permission Handler**: Manejo robusto de permisos
- **Device Info Plus**: Información del dispositivo

### Arquitectura
- **Clean Architecture**: Separación de responsabilidades
- **Dependency Injection Modular**: Inyección de dependencias con GetIt
- **Repository Pattern**: Patrón de repositorio
- **BLoC Pattern Mejorado**: Gestión de estado con logging profesional
- **Atomic Design**: Componentes organizados por complejidad

## 📊 Estructura de Datos

### Entidades Mejoradas
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

### BLoCs Mejorados
- `CameraBloc`: Gestión de cámara con lógica real y logging
- `BovinoBloc`: Gestión de análisis con Either/Left/Right
- `ThemeBloc`: Gestión de temas dinámicos
- `SplashBloc`: Gestión de splash screen con verificación de servidor

## 🔧 Configuración Avanzada

### Inyección de Dependencias Modular
```dart
// Inicialización automática
await DependencyInjection.initialize();

// Acceso a dependencias
final cameraService = DependencyInjection.cameraService;
final splashService = DependencyInjection.splashService;
final bovinoBloc = DependencyInjection.bovinoBloc;
final splashBloc = DependencyInjection.splashBloc;
```

### Navegación
```dart
// Navegación simple
AppRouter.goToSplash(context);
AppRouter.goToHome(context);
```

### Temas
```dart
// Cambio dinámico
final theme = ThemeManager.getThemeByBool(false); // Tema claro
```

## 🚀 Características Técnicas

### Splash Screen Nativo
- Configuración nativa en Android
- Animaciones fluidas con AnimationController
- Estados reactivos con BLoC
- Verificación automática de servidor
- Transición suave a la aplicación principal

### Cámara en Tiempo Real
- Captura automática de frames
- Rate limiting configurable
- Optimización de memoria
- Logging detallado

### Comunicación con Servidor
- Envío de frames via HTTP
- Consulta periódica de estado via HTTP
- Manejo de reconexión automática
- Respuesta con peso estimado

### Manejo de Errores Mejorado
- Errores tipados con `Failure` classes
- Mensajes de error contextuales usando AppMessages
- Recuperación automática
- Logging profesional

### BLoCs Mejorados
- **Equatable** para comparaciones eficientes
- **Logging profesional** integrado
- **Manejo de errores** con Failure objects
- **Either/Left/Right** para programación funcional
- **Métodos privados** para cada evento

### Atomic Design
- **Atoms**: Componentes básicos reutilizables
- **Molecules**: Componentes compuestos
- **Organisms**: Componentes complejos
- **Screens**: Pantallas reutilizables
- **Separación clara** de responsabilidades

## 📱 Compatibilidad

### Plataformas
- ✅ **Android (API 21+)**

### Versiones Android
- **Android 10-15**: Permisos granulares
- **Detección automática** de versión
- **Optimizaciones específicas** para Android

## 🧪 Testing

### Estructura de Tests
```
test/
├── unit/           # Tests unitarios
│   ├── blocs/      # Tests de BLoCs mejorados
│   ├── services/   # Tests de servicios
│   └── repositories/ # Tests de repositorios
├── widget/         # Tests de widgets
└── integration/    # Tests de integración
```

### Cobertura
- **Mínimo 80%** de cobertura
- **Tests críticos** para lógica de negocio
- **Tests de UI** para componentes principales

## 🔄 Mejoras Recientes

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

## 📄 Documentación

- [Arquitectura](docs/ARQUITECTURA.md) - Documentación detallada de la arquitectura
- [Reglas de Desarrollo](docs/REGLAS_DESARROLLO.md) - Convenciones y mejores prácticas
- [Servidor Python](server/README.md) - Documentación del servidor TensorFlow con Clean Architecture

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

---

*Desarrollado con ❤️ siguiendo las mejores prácticas de Clean Architecture, BLoC Pattern, Atomic Design y SOLID Principles, optimizado para Android.* 