# Bovino IA - Reconocimiento de Ganado Bovino

Una aplicación Flutter moderna que utiliza inteligencia artificial para identificar razas de ganado bovino y estimar su peso a partir de imágenes capturadas con la cámara. Desarrollada siguiendo Clean Architecture y principios SOLID.

## 🚀 Características

- 📸 **Captura en tiempo real** con la cámara del dispositivo
- 🤖 **Análisis de imágenes** usando OpenAI GPT-4 Vision
- 🐄 **Identificación automática** de razas bovinas
- ⚖️ **Estimación de peso** basada en características visuales
- 📊 **Historial de análisis** con persistencia local
- 🎨 **Interfaz moderna** con Material Design 3
- 🌙 **Temas claro y oscuro** con cambio dinámico
- 📱 **Navegación fluida** con transiciones personalizadas
- 🔒 **Manejo robusto de permisos** para Android 13-15
- ⚡ **Análisis en background** con cola de procesamiento
- 🎯 **Arquitectura limpia** siguiendo Clean Architecture

## 🏗️ Arquitectura

El proyecto sigue **Clean Architecture** con separación clara de responsabilidades:

```
lib/
├── core/                    # 🧠 Capa Core
│   ├── architecture/        # Documentación de arquitectura
│   ├── constants/          # Constantes de la aplicación
│   ├── errors/             # Manejo de errores
│   ├── services/           # Servicios core (cámara, permisos)
│   ├── theme/              # Sistema de temas
│   ├── di/                 # Inyección de dependencias
│   └── routes/             # Manejo de rutas
├── data/                   # 📊 Capa de Datos
│   ├── datasources/        # Fuentes de datos (local/remoto)
│   ├── models/             # Modelos de datos
│   └── repositories/       # Implementaciones de repositorios
├── domain/                 # 🎯 Capa de Dominio
│   ├── entities/           # Entidades de negocio
│   ├── repositories/       # Contratos de repositorios
│   └── usecases/           # Casos de uso
└── presentation/           # 🎨 Capa de Presentación
    ├── pages/              # Páginas de la aplicación
    ├── providers/          # Gestión de estado
    └── widgets/            # Widgets organizados por Atomic Design
        ├── atoms/          # Componentes básicos
        ├── molecules/      # Componentes compuestos
        └── organisms/      # Componentes complejos
```

## 🎨 Atomic Design

Los widgets están organizados siguiendo **Atomic Design**:

- **Atoms**: Botones, tarjetas, iconos básicos
- **Molecules**: Tarjetas de resultados, overlays de carga
- **Organisms**: Secciones de cámara, formularios complejos

## 🎯 Principios SOLID Aplicados

- **S** - Responsabilidad única por módulo
- **O** - Extensibilidad sin modificación
- **L** - Sustitución de Liskov
- **I** - Segregación de interfaces
- **D** - Inversión de dependencias

## ⚙️ Configuración

### 1. Instalar Dependencias

```bash
flutter pub get
```

### 2. Configurar API Key de OpenAI

1. Obtén tu API key de OpenAI desde [https://platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Configura la variable de entorno o actualiza el archivo de configuración
3. La aplicación manejará automáticamente la autenticación

### 3. Permisos

La aplicación solicita automáticamente los permisos necesarios:
- **Cámara**: Para captura de imágenes
- **Internet**: Para comunicación con APIs
- **Almacenamiento**: Para guardar historial local

### 4. Ejecutar la Aplicación

```bash
flutter run
```

## 📱 Uso

### Navegación Principal
- **Inicio**: Captura y análisis de imágenes
- **Historial**: Ver análisis anteriores
- **Configuración**: Personalizar la aplicación
- **Acerca de**: Información del proyecto

### Proceso de Análisis
1. **Capturar imagen**: Usa la cámara en tiempo real
2. **Procesamiento**: Análisis automático en background
3. **Resultados**: Visualización detallada con:
   - Raza identificada
   - Peso estimado
   - Nivel de confianza
   - Descripción detallada
   - Características observadas

## 🎨 Sistema de Temas

### Temas Disponibles
- **Claro**: Optimizado para uso diurno
- **Oscuro**: Reducción de fatiga visual nocturna

### Características
- Cambio dinámico de temas
- Colores de estado (éxito, error, advertencia)
- Colores de acento personalizables
- Validación automática de contraste

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter**: Framework de desarrollo móvil
- **Material Design 3**: Sistema de diseño moderno
- **GoRouter**: Navegación declarativa
- **Provider**: Gestión de estado

### Backend & APIs
- **OpenAI GPT-4 Vision**: Análisis de imágenes
- **Dio**: Cliente HTTP avanzado
- **SharedPreferences**: Persistencia local

### Cámara y Permisos
- **Camera Plugin**: Acceso a cámara en tiempo real
- **Permission Handler**: Manejo robusto de permisos
- **Device Info Plus**: Información del dispositivo

### Arquitectura
- **Clean Architecture**: Separación de responsabilidades
- **Dependency Injection**: Inyección de dependencias
- **Repository Pattern**: Patrón de repositorio
- **Use Case Pattern**: Casos de uso

## 📊 Estructura de Datos

### Entidades
```dart
class BovinoEntity {
  final String id;
  final String raza;
  final double pesoEstimado;
  final double confianza;
  final String descripcion;
  final List<String> caracteristicas;
  final DateTime fechaAnalisis;
}
```

### Casos de Uso
- `AnalizarImagenUseCase`: Procesar imágenes
- `ObtenerHistorialUseCase`: Cargar historial
- `EliminarAnalisisUseCase`: Eliminar análisis
- `LimpiarHistorialUseCase`: Limpiar historial

## 🔧 Configuración Avanzada

### Inyección de Dependencias
```dart
// Inicialización automática
await DependencyInjection.initialize();

// Acceso a dependencias
final useCase = DependencyInjection.analizarImagenUseCase;
```

### Navegación
```dart
// Navegación simple
AppRouter.goToHome(context);

// Navegación con parámetros
AppRouter.goToAnalysis(context, 'analysis-id');
```

### Temas
```dart
// Cambio dinámico
final theme = AppTheme.getThemeByString('Oscuro');

// Validación de contraste
bool accessible = AppTheme.hasGoodContrast(textColor, backgroundColor);
```

## 🚀 Características Avanzadas

### Análisis en Tiempo Real
- Captura automática de frames
- Rate limiting para evitar sobrecarga
- Cola de procesamiento en background

### Manejo de Errores
- Errores tipados con `Failure` classes
- Mensajes de error contextuales
- Recuperación automática

### Persistencia
- Almacenamiento local con SharedPreferences
- Historial de análisis persistente
- Configuraciones de usuario

## 📱 Compatibilidad

### Plataformas
- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

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
- Tests unitarios para casos de uso
- Tests de widgets para componentes UI
- Tests de integración para flujos completos

## 📚 Documentación

### Archivos de Documentación
- `docs/REFACTORING_MAIN.md`: Refactorización del main.dart
- `docs/TEMAS_REFACTORIZACION.md`: Sistema de temas
- `docs/ALTERNATIVAS_OPENSOURCE.md`: Alternativas open source
- `docs/EJEMPLO_USO.md`: Ejemplos de uso
- `docs/GUIA_USUARIO.md`: Guía de usuario
- `docs/MIGRACION_ARQUITECTURA.md`: Migración de arquitectura

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

#### Error de API Key
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

#### Error de Red
- Verificar conexión a internet
- Verificar configuración de firewall
- Verificar API key de OpenAI

### Logs y Debugging
```dart
// Logs automáticos de HTTP
🌐 HTTP Request: POST /v1/chat/completions
✅ HTTP Response: 200
❌ HTTP Error: 401 Unauthorized
```

## 🤝 Contribuir

### Guías de Contribución
1. **Fork** el proyecto
2. **Crea** una rama para tu feature
3. **Implementa** siguiendo Clean Architecture
4. **Ejecuta** tests
5. **Documenta** cambios
6. **Crea** Pull Request

### Estándares de Contribución
- Seguir Clean Architecture
- Implementar tests
- Documentar cambios
- Usar Atomic Design
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
- [ ] **Exportación de datos** a CSV/PDF
- [ ] **Sincronización en la nube** de historial
- [ ] **Análisis offline** con modelos locales
- [ ] **Integración con sistemas** de gestión ganadera
- [ ] **Análisis de salud** del ganado
- [ ] **Predicción de peso** por edad
- [ ] **Reconocimiento facial** de animales

### Mejoras Técnicas
- [ ] **Migración a Riverpod** para gestión de estado
- [ ] **Implementación de BLoC** para casos complejos
- [ ] **Tests de integración** completos
- [ ] **CI/CD pipeline** automatizado
- [ ] **Análisis de código** automatizado
- [ ] **Documentación API** automática

---

**Desarrollado con ❤️ siguiendo las mejores prácticas de Clean Architecture y Atomic Design** 