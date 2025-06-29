# 🖼️ Imágenes para Bovino IA

## 📋 Imágenes Necesarias

### **1. Logo Principal**
- **Archivo**: `logo.png`
- **Tamaño**: 512x512px
- **Formato**: PNG con transparencia
- **Uso**: Logo de la aplicación en splash y header

### **2. Imagen de Ganado Bovino**
- **Archivo**: `bovino_main.png`
- **Tamaño**: 800x600px
- **Formato**: PNG o JPG
- **Uso**: Imagen principal en la página de inicio

### **3. Iconos de la Aplicación**
- **Archivo**: `camera_icon.png`
- **Tamaño**: 256x256px
- **Formato**: PNG con transparencia
- **Uso**: Icono de cámara en botones

## 🔗 Enlaces Útiles

### **Imágenes de Ganado Gratuitas:**
- [Unsplash - Cattle](https://unsplash.com/s/photos/cattle)
- [Pexels - Cattle](https://www.pexels.com/search/cattle/)
- [Pixabay - Cattle](https://pixabay.com/images/search/cattle/)

### **Iconos Gratuitos:**
- [Flaticon](https://www.flaticon.com/search?word=camera)
- [Icons8](https://icons8.com/icons/set/camera)
- [Feather Icons](https://feathericons.com/)

## 📏 Especificaciones Técnicas

### **Formatos Soportados:**
- **PNG**: Para imágenes con transparencia
- **JPG/JPEG**: Para fotografías
- **SVG**: Para iconos vectoriales
- **WebP**: Para optimización web

### **Tamaños Recomendados:**
- **Logo**: 512x512px
- **Imágenes principales**: 800x600px
- **Iconos**: 256x256px
- **Thumbnails**: 150x150px

### **Optimización:**
- Comprimir imágenes antes de usar
- Usar formatos apropiados
- Considerar diferentes densidades de pantalla

## 🎯 Ejemplos de Uso

### **En el código:**
```dart
Image.asset(
  'assets/images/bovino_main.png',
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.pets, size: 80);
  },
)
```

### **En pubspec.yaml:**
```yaml
flutter:
  assets:
    - assets/images/
```

---

*Coloca aquí las imágenes que descargues de los enlaces proporcionados.* 