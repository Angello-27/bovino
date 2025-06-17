# Bovino IA - Reconocimiento de Ganado Bovino

Una aplicación Flutter que utiliza inteligencia artificial para identificar razas de ganado bovino y estimar su peso a partir de imágenes capturadas con la cámara.

## Características

- 📸 Captura de imágenes con la cámara del dispositivo
- 🤖 Análisis de imágenes usando OpenAI GPT-4 Vision
- 🐄 Identificación automática de razas bovinas
- ⚖️ Estimación de peso basada en características visuales
- 📊 Visualización detallada de resultados
- 🎨 Interfaz moderna y fácil de usar

## Configuración

### 1. Instalar Dependencias

```bash
flutter pub get
```

### 2. Configurar API Key de OpenAI

1. Obtén tu API key de OpenAI desde [https://platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Abre el archivo `lib/services/openai_service.dart`
3. Reemplaza `'TU_API_KEY_AQUI'` con tu API key real:

```dart
static const String _apiKey = 'sk-tu-api-key-aqui';
```

### 3. Permisos

La aplicación solicitará automáticamente los permisos necesarios:
- Cámara
- Internet
- Almacenamiento

### 4. Ejecutar la Aplicación

```bash
flutter run
```

## Uso

1. **Abrir la aplicación**: La pantalla principal muestra la vista de la cámara
2. **Capturar imagen**: Apunta la cámara hacia el ganado bovino y presiona "Capturar"
3. **Esperar análisis**: La IA procesará la imagen (puede tomar unos segundos)
4. **Ver resultados**: Se mostrará:
   - Raza identificada
   - Peso estimado
   - Nivel de confianza
   - Descripción detallada
   - Características observadas

## Mejores Prácticas para Captura

- **Iluminación**: Usa buena iluminación natural o artificial
- **Distancia**: Captura el animal completo en el encuadre
- **Ángulo**: Intenta capturar desde un ángulo lateral para mejor identificación
- **Calidad**: Mantén la cámara estable para evitar imágenes borrosas

## Razas Soportadas

La IA puede identificar múltiples razas de ganado bovino, incluyendo:
- Holstein
- Angus
- Brahman
- Hereford
- Simmental
- Charolais
- Limousin
- Y muchas más...

## Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo móvil
- **Camera**: Plugin para acceso a la cámara
- **OpenAI GPT-4 Vision**: Modelo de IA para análisis de imágenes
- **Dio**: Cliente HTTP para comunicación con APIs
- **Permission Handler**: Manejo de permisos del dispositivo

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/
│   └── bovino.dart          # Modelo de datos para ganado bovino
├── services/
│   └── openai_service.dart  # Servicio para comunicación con OpenAI
└── widgets/
    ├── camera_widget.dart    # Widget de cámara
    └── resultado_analisis_widget.dart # Widget de resultados
```

## Solución de Problemas

### Error de API Key
- Verifica que tu API key de OpenAI sea válida
- Asegúrate de tener créditos disponibles en tu cuenta de OpenAI

### Error de Cámara
- Verifica que los permisos de cámara estén habilitados
- Reinicia la aplicación si es necesario

### Error de Red
- Verifica tu conexión a internet
- Asegúrate de que la aplicación tenga permisos de red

## Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## Soporte

Si tienes problemas o preguntas, por favor abre un issue en el repositorio.
