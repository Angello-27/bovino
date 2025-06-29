# 🎨 Assets de Bovino IA

Esta carpeta contiene todos los recursos estáticos de la aplicación Bovino IA.

## 📁 Estructura

```
assets/
├── images/          # Imágenes de la aplicación
│   ├── bovino_main.png     # Imagen principal de ganado bovino
│   ├── logo.png            # Logo de la aplicación
│   └── icons/              # Iconos personalizados
├── icons/           # Iconos SVG y PNG
│   ├── camera.svg          # Icono de cámara
│   ├── analysis.svg        # Icono de análisis
│   └── settings.svg        # Icono de configuración
├── data/            # Datos estáticos
│   ├── breeds.json         # Lista de razas de ganado
│   └── config.json         # Configuración por defecto
└── fonts/           # Fuentes personalizadas
    ├── Roboto-Regular.ttf  # Fuente regular
    ├── Roboto-Bold.ttf     # Fuente negrita
    └── Roboto-Light.ttf    # Fuente ligera
```

## 🖼️ Imágenes

### Formatos soportados
- **PNG**: Para imágenes con transparencia
- **JPG/JPEG**: Para fotografías
- **SVG**: Para iconos vectoriales
- **WebP**: Para optimización web

### Tamaños recomendados
- **Logo**: 512x512px
- **Iconos**: 64x64px a 256x256px
- **Imágenes de fondo**: 1920x1080px
- **Thumbnails**: 150x150px

## 📊 Datos

Los archivos JSON en la carpeta `data/` contienen información estática que se carga al inicio de la aplicación.

### breeds.json
```json
{
  "breeds": [
    {
      "id": "holstein",
      "name": "Holstein",
      "description": "Raza lechera por excelencia",
      "characteristics": ["Blanco y negro", "Alta producción lechera"]
    }
  ]
}
```

## 🔤 Fuentes

Las fuentes personalizadas se configuran en `pubspec.yaml` y se pueden usar en toda la aplicación.

### Uso en código
```dart
Text(
  'Bovino IA',
  style: TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.bold,
  ),
)
```

## ⚙️ Configuración

Los assets se configuran en `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - assets/data/
  
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
```

## 🚀 Optimización

### Imágenes
- Comprimir imágenes antes de agregarlas
- Usar formatos apropiados (PNG para transparencia, JPG para fotos)
- Considerar diferentes densidades de pantalla

### Iconos
- Preferir SVG para iconos vectoriales
- Usar PNG para iconos complejos
- Mantener consistencia en el estilo

### Datos
- Minimizar archivos JSON
- Usar nombres descriptivos
- Validar estructura de datos

---

*Los assets son parte fundamental de la experiencia de usuario. Manténlos organizados y optimizados.* 