# Bovino IA - Reconocimiento de Ganado Bovino en Tiempo Real

Una aplicación Flutter moderna que utiliza **cámara en vivo** para capturar frames y enviarlos a un servidor Python con TensorFlow para identificar razas de ganado bovino y estimar su peso. Desarrollada siguiendo Clean Architecture, SOLID Principles y BLoC Pattern, **optimizada exclusivamente para Android**.

## 🎯 Objetivo Principal

**Bovino IA** es una aplicación móvil **Android** que captura frames de la cámara en tiempo real y los envía a un servidor Python con TensorFlow para el reconocimiento automático de razas bovinas y estimación de peso, recibiendo notificaciones asíncronas con los resultados.

## 🚀 Características

- 📸 **Cámara en vivo** con captura automática de frames
- 🤖 **Análisis remoto** usando TensorFlow en servidor Python
- 🐄 **Identificación automática** de razas bovinas
- ⚖️ **Estimación de peso** del animal según la raza
- ⚡ **Notificaciones asíncronas** via WebSocket
- 🎨 **Interfaz moderna** con Material Design 3
- 🌙 **Temas claro y oscuro** con cambio dinámico
- 🔒 **Manejo robusto de permisos** para Android 10-15
- 🎯 **Arquitectura limpia** siguiendo Clean Architecture + BLoC
- 📊 **Logging profesional** para debugging
- 🔧 **Inyección de dependencias modular**

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
│   │   ├── websocket_injection.dart     # Configuración WebSocket
│   │   ├── services_injection.dart      # Servicios core
│   │   ├── data_injection.dart          # Capa de datos
│   │   └── presentation_injection.dart  # Capa de presentación
│   ├── errors/             # Manejo de errores tipados
│   ├── services/           # Servicios core (cámara, permisos)
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
    │   └── theme_bloc.dart         # BLoC para temas dinámicos
    ├── pages/              # Páginas de la aplicación
    └── widgets/            # Widgets organizados por Atomic Design
        ├── atoms/          # Componentes básicos
        ├── molecules/      # Componentes compuestos
        └── organisms/      # Componentes complejos
```

## 🎨 Atomic Design

Los widgets están organizados siguiendo **Atomic Design**:

- **Atoms**: Botones, textos, iconos básicos
- **Molecules**: Diálogos de permisos, displays de resultados
- **Organisms**: Widget de cámara en vivo, secciones complejas

## 🎯 Principios Aplicados

- **Clean Architecture**: Separación clara de responsabilidades
- **SOLID Principles**: Principios de diseño orientado a objetos
- **BLoC Pattern Mejorado**: Gestión de estado reactiva con Equatable
- **Domain-Driven Design**: Entidades de dominio bien definidas
- **Programación Funcional**: Uso de Either/Left/Right para manejo de errores

## ⚙️ Configuración

### 1. Instalar Dependencias

```bash
flutter pub get
```

### 2. Configurar Servidor TensorFlow

1. Configura la URL del servidor en `lib/core/constants/app_constants.dart`
2. Asegúrate de que el servidor Python esté ejecutándose en `192.168.0.8`
3. El servidor debe tener endpoints para:
   - Envío de frames: `POST /analyze-frame`
   - WebSocket para notificaciones: `ws://192.168.0.8/ws`
   - Respuesta incluye `peso_estimado` en kg

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
1. **Iniciar cámara**: La aplicación abre la cámara en tiempo real
2. **Captura automática**: Se capturan frames cada X segundos
3. **Envío al servidor**: Los frames se envían al servidor TensorFlow
4. **Análisis remoto**: El servidor procesa la imagen con TensorFlow
5. **Notificación**: El servidor envía el resultado via WebSocket
6. **Visualización**: Se muestra la raza identificada, peso estimado y características

### Interfaz
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
- **WebSocket**: Notificaciones asíncronas

### Cámara y Permisos
- **Camera Plugin**: Acceso a cámara en tiempo real
- **Permission Handler**: Manejo robusto de permisos
- **Device Info Plus**: Información del dispositivo

### Arquitectura
- **Clean Architecture**: Separación de responsabilidades
- **Dependency Injection Modular**: Inyección de dependencias con GetIt
- **Repository Pattern**: Patrón de repositorio
- **BLoC Pattern Mejorado**: Gestión de estado con logging profesional

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

## 🔧 Configuración Avanzada

### Inyección de Dependencias Modular
```dart
// Inicialización automática
await DependencyInjection.initialize();

// Acceso a dependencias
final cameraService = DependencyInjection.cameraService;
final bovinoBloc = DependencyInjection.bovinoBloc;
```

### Navegación
```dart
// Navegación simple
AppRouter.goToHome(context);
```

### Temas
```dart
// Cambio dinámico
final theme = ThemeManager.getThemeByBool(false); // Tema claro
```

## 🚀 Características Técnicas

### Cámara en Tiempo Real
- Captura automática de frames
- Rate limiting configurable
- Optimización de memoria
- Logging detallado

### Comunicación con Servidor
- Envío de frames via HTTP
- Notificaciones via WebSocket
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

## 📄 Documentación

- [Arquitectura](docs/ARQUITECTURA.md) - Documentación detallada de la arquitectura
- [Reglas de Desarrollo](docs/REGLAS_DESARROLLO.md) - Convenciones y mejores prácticas

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

---

*Desarrollado con ❤️ siguiendo las mejores prácticas de Clean Architecture, BLoC Pattern y SOLID Principles, optimizado para Android.* 