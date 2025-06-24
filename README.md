# Bovino IA - Reconocimiento de Ganado Bovino en Tiempo Real

Una aplicación Flutter moderna que utiliza **cámara en vivo** para capturar frames y enviarlos a un servidor Python con TensorFlow para identificar razas de ganado bovino. Desarrollada siguiendo Clean Architecture, SOLID Principles y BLoC Pattern.

## 🎯 Objetivo Principal

**Bovino IA** es una aplicación móvil que captura frames de la cámara en tiempo real y los envía a un servidor Python con TensorFlow para el reconocimiento automático de razas bovinas, recibiendo notificaciones asíncronas con los resultados.

## 🚀 Características

- 📸 **Cámara en vivo** con captura automática de frames
- 🤖 **Análisis remoto** usando TensorFlow en servidor Python
- 🐄 **Identificación automática** de razas bovinas
- ⚡ **Notificaciones asíncronas** via WebSocket
- 🎨 **Interfaz moderna** con Material Design 3
- 🌙 **Temas claro y oscuro** con cambio dinámico
- 🔒 **Manejo robusto de permisos** para Android 13-15
- 🎯 **Arquitectura limpia** siguiendo Clean Architecture + BLoC

## 🏗️ Arquitectura

El proyecto sigue **Clean Architecture** con **BLoC Pattern** para gestión de estado:

```
lib/
├── core/                    # 🧠 Capa Core
│   ├── constants/          # Constantes de la aplicación
│   ├── di/                 # Inyección de dependencias
│   ├── errors/             # Manejo de errores
│   ├── services/           # Servicios core (cámara, permisos)
│   ├── theme/              # Sistema de temas
│   └── routes/             # Manejo de rutas
├── data/                   # 📊 Capa de Datos
│   ├── datasources/        # Fuentes de datos (servidor TensorFlow)
│   ├── models/             # Modelos de datos
│   └── repositories/       # Implementaciones de repositorios
├── domain/                 # 🎯 Capa de Dominio
│   ├── entities/           # Entidades de negocio
│   └── repositories/       # Contratos de repositorios
└── presentation/           # 🎨 Capa de Presentación
    ├── blocs/              # Gestión de estado con BLoC
    ├── pages/              # Páginas de la aplicación
    └── widgets/            # Widgets organizados por Atomic Design
        ├── molecules/      # Componentes compuestos
        └── organisms/      # Componentes complejos
```

## 🎨 Atomic Design

Los widgets están organizados siguiendo **Atomic Design**:

- **Molecules**: Diálogos de permisos, displays de resultados
- **Organisms**: Widget de cámara en vivo, secciones complejas

## 🎯 Principios Aplicados

- **Clean Architecture**: Separación clara de responsabilidades
- **SOLID Principles**: Principios de diseño orientado a objetos
- **BLoC Pattern**: Gestión de estado reactiva
- **Domain-Driven Design**: Entidades de dominio bien definidas

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
6. **Visualización**: Se muestra la raza identificada y características

### Interfaz
- **Pantalla principal**: Cámara en vivo con overlay de resultados
- **Indicadores**: Estado de conexión, análisis en progreso
- **Resultados**: Raza identificada y características del bovino

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter**: Framework de desarrollo móvil
- **Material Design 3**: Sistema de diseño moderno
- **GoRouter**: Navegación declarativa
- **BLoC**: Gestión de estado reactiva

### Backend & APIs
- **Servidor Python**: Con TensorFlow para análisis
- **Dio**: Cliente HTTP para envío de frames
- **WebSocket**: Notificaciones asíncronas

### Cámara y Permisos
- **Camera Plugin**: Acceso a cámara en tiempo real
- **Permission Handler**: Manejo robusto de permisos
- **Device Info Plus**: Información del dispositivo

### Arquitectura
- **Clean Architecture**: Separación de responsabilidades
- **Dependency Injection**: Inyección de dependencias
- **Repository Pattern**: Patrón de repositorio
- **BLoC Pattern**: Gestión de estado

## 📊 Estructura de Datos

### Entidades
```dart
class BovinoEntity {
  final String raza;
  final List<String> caracteristicas;
  final double confianza;
  final DateTime timestamp;
}
```

### BLoCs
- `CameraBloc`: Gestión de cámara en vivo
- `BovinoBloc`: Gestión de análisis y resultados

## 🔧 Configuración Avanzada

### Inyección de Dependencias
```dart
// Inicialización automática
await DependencyInjection.initialize();

// Acceso a dependencias
final cameraService = DependencyInjection.cameraService;
```

### Navegación
```dart
// Navegación simple
AppRouter.goToHome(context);
```

### Temas
```dart
// Cambio dinámico
final theme = AppTheme.getThemeByString('Oscuro');
```

## 🚀 Características Técnicas

### Cámara en Tiempo Real
- Captura automática de frames
- Rate limiting configurable
- Optimización de memoria

### Comunicación con Servidor
- Envío de frames via HTTP
- Notificaciones via WebSocket
- Manejo de reconexión automática

### Manejo de Errores
- Errores tipados con `Failure` classes
- Mensajes de error contextuales
- Recuperación automática

## 📱 Compatibilidad

### Plataformas
- ✅ Android (API 21+)

### Versiones Android
- **Android 13-15**: Permisos granulares
- **Android < 13**: Permisos tradicionales
- **Detección automática** de versión

## 🧪 Testing

### Estructura de Tests
```
test/
├── unit/           # Tests unitarios
├── widget/         # Tests de widgets
└── integration/    # Tests de integración
```

### Cobertura
- Tests unitarios para BLoCs
- Tests de widgets para componentes UI
- Tests de integración para flujos completos

## 🔄 Flujo de Desarrollo

### Git Workflow
1. **Feature Branch**: Crear rama para nueva funcionalidad
2. **Desarrollo**: Implementar siguiendo Clean Architecture
3. **Testing**: Ejecutar tests unitarios y de integración
4. **Code Review**: Revisión de código obligatoria
5. **Merge**: Integración a rama principal

### Estándares de Código
- **Dart Analysis**: Configuración estricta
- **Linting**: Reglas de estilo consistentes
- **Documentación**: Comentarios en código
- **Naming**: Convenciones claras

## 🐛 Solución de Problemas

### Errores Comunes

#### Error de Conexión al Servidor
```bash
# Verificar configuración
flutter doctor
flutter clean
flutter pub get
```

#### Error de Cámara
- Verificar permisos en configuración del dispositivo
- Reiniciar aplicación
- Verificar versión de Android/iOS

#### Error de WebSocket
- Verificar que el servidor esté ejecutándose
- Verificar configuración de firewall
- Verificar URL del servidor

### Logs y Debugging
```dart
// Logs automáticos de HTTP
🌐 HTTP Request: POST /analyze-frame
✅ HTTP Response: 200
❌ HTTP Error: 500 Internal Server Error

// Logs de WebSocket
🔌 WebSocket Connected
📨 Message Received: {"raza": "Holstein", "confianza": 0.95}
🔌 WebSocket Disconnected
```

## 🤝 Contribuir

### Guías de Contribución
1. **Fork** el proyecto
2. **Crea** una rama para tu feature
3. **Implementa** siguiendo Clean Architecture + BLoC
4. **Ejecuta** tests
5. **Documenta** cambios
6. **Crea** Pull Request

### Estándares de Contribución
- Seguir Clean Architecture
- Implementar tests
- Documentar cambios
- Usar BLoC para estado
- Mantener consistencia de código

## 📄 Licencia

Este proyecto está bajo la **Licencia MIT**. Ver el archivo `LICENSE` para más detalles.

## 🆘 Soporte

### Canales de Soporte
- **Issues**: Reportar bugs y solicitar features
- **Discussions**: Preguntas y discusiones
- **Wiki**: Documentación detallada

### Comunidad
- **Contribuidores**: Bienvenidos nuevos contribuidores
- **Feedback**: Apreciamos feedback constructivo
- **Mejoras**: Sugerencias siempre bienvenidas

---

## 🎯 Roadmap

### Próximas Funcionalidades
- [ ] **Análisis de múltiples animales** en una imagen
- [ ] **Configuración de intervalo** de captura
- [ ] **Modo offline** con cache local
- [ ] **Exportación de resultados** a CSV
- [ ] **Análisis de salud** del ganado
- [ ] **Reconocimiento facial** de animales

### Mejoras Técnicas
- [ ] **Tests de integración** completos
- [ ] **CI/CD pipeline** automatizado
- [ ] **Análisis de código** automatizado
- [ ] **Documentación API** automática
- [ ] **Optimización de memoria** para frames
- [ ] **Compresión de imágenes** antes del envío

---

**Desarrollado con ❤️ siguiendo las mejores prácticas de Clean Architecture y BLoC Pattern** 