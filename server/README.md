# 🐄 Servidor Bovino IA - Python + TensorFlow

Servidor backend para el reconocimiento automático de razas bovinas y estimación de peso usando TensorFlow y FastAPI.

## 🎯 Características

- **Reconocimiento de Razas**: Clasificación automática de 10 razas bovinas principales
- **Estimación de Peso**: Cálculo de peso estimado basado en características visuales
- **API REST**: Endpoints para análisis de imágenes
- **WebSocket**: Comunicación en tiempo real con Flutter
- **Modelo CNN**: Red neuronal convolucional optimizada
- **Logging Profesional**: Sistema de logs detallado

## 🏗️ Arquitectura

```
server/
├── main.py                 # Servidor FastAPI principal
├── requirements.txt        # Dependencias Python
├── config/
│   └── settings.py        # Configuración del servidor
├── models/
│   └── bovino_model.py    # Modelo de datos Pydantic
├── services/
│   ├── tensorflow_service.py  # Servicio de IA
│   └── websocket_manager.py   # Gestor WebSocket
├── train_model.py         # Script de entrenamiento
└── README.md              # Documentación
```

## 🚀 Instalación

### 1. Requisitos Previos

```bash
# Python 3.8+
python --version

# pip actualizado
pip install --upgrade pip
```

### 2. Clonar y Configurar

```bash
# Navegar al directorio del servidor
cd server

# Crear entorno virtual
python -m venv venv

# Activar entorno virtual
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt
```

### 3. Configuración

Crear archivo `.env` en el directorio `server/`:

```env
HOST=192.168.0.8
PORT=8000
DEBUG=True
MODEL_PATH=models/bovino_model.h5
LABELS_PATH=models/class_labels.json
IMAGE_SIZE=224
BATCH_SIZE=32
MIN_WEIGHT=200.0
MAX_WEIGHT=1200.0
```

## 🎯 Uso

### 1. Iniciar Servidor

```bash
# Activar entorno virtual
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Ejecutar servidor
python main.py
```

El servidor estará disponible en:
- **HTTP**: http://192.168.0.8:8000
- **WebSocket**: ws://192.168.0.8:8000/ws
- **Documentación API**: http://192.168.0.8:8000/docs

### 2. Endpoints Disponibles

#### GET `/`
Información del servidor
```json
{
  "message": "🐄 Bovino IA Server",
  "version": "1.0.0",
  "status": "running",
  "endpoints": {
    "analyze_frame": "/analyze-frame",
    "health": "/health",
    "websocket": "/ws"
  }
}
```

#### GET `/health`
Estado del servidor y modelo
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00",
  "model_ready": true,
  "active_connections": 1
}
```

#### POST `/analyze-frame`
Analizar imagen de bovino
```bash
curl -X POST "http://192.168.0.8:8000/analyze-frame" \
     -H "Content-Type: multipart/form-data" \
     -F "file=@imagen_bovino.jpg"
```

Respuesta:
```json
{
  "raza": "Angus",
  "caracteristicas": ["Negro", "Sin cuernos", "Musculoso", "Adaptable"],
  "confianza": 0.87,
  "timestamp": "2024-01-15T10:30:00",
  "peso_estimado": 650.5
}
```

#### WebSocket `/ws`
Conexión en tiempo real para notificaciones

## 🤖 Entrenamiento del Modelo

### 1. Preparar Datos

Crear estructura de directorios:
```
data/
└── bovine_images/
    ├── Angus/
    │   ├── angus_001.jpg
    │   ├── angus_002.jpg
    │   └── ...
    ├── Hereford/
    │   ├── hereford_001.jpg
    │   └── ...
    ├── Holstein/
    └── ...
```

### 2. Entrenar Modelo

```bash
# Activar entorno virtual
source venv/bin/activate

# Ejecutar entrenamiento
python train_model.py
```

### 3. Modelo Entrenado

El script generará:
- `models/bovino_model.h5` - Modelo TensorFlow
- `models/class_labels.json` - Etiquetas de clases
- `models/training_history.png` - Gráficas de entrenamiento

## 📊 Razas Soportadas

| Raza | Características | Peso Promedio |
|------|----------------|---------------|
| Angus | Negro, Sin cuernos, Musculoso | 650 kg |
| Hereford | Rojo y blanco, Cuernos cortos | 680 kg |
| Holstein | Blanco y negro, Grande, Lechera | 750 kg |
| Jersey | Marrón claro, Pequeña, Lechera | 450 kg |
| Brahman | Gris, Joroba, Resistente al calor | 700 kg |
| Charolais | Blanco, Grande, Musculoso | 800 kg |
| Limousin | Dorado, Musculoso, Cárnico | 750 kg |
| Simmental | Rojo y blanco, Grande, Doble propósito | 800 kg |
| Shorthorn | Rojo, Mediano, Doble propósito | 650 kg |
| Gelbvieh | Dorado, Mediano, Cárnico | 700 kg |

## 🔧 Configuración Avanzada

### Variables de Entorno

```env
# Servidor
HOST=192.168.0.8
PORT=8000
DEBUG=True

# Modelo
MODEL_PATH=models/bovino_model.h5
LABELS_PATH=models/class_labels.json
IMAGE_SIZE=224
BATCH_SIZE=32

# Peso
MIN_WEIGHT=200.0
MAX_WEIGHT=1200.0
```

### Personalización de Razas

Editar `config/settings.py`:

```python
BOVINE_BREEDS = [
    "Tu_Raza_1",
    "Tu_Raza_2",
    # ...
]

BREED_CHARACTERISTICS = {
    "Tu_Raza_1": ["Característica 1", "Característica 2"],
    # ...
}

BREED_AVERAGE_WEIGHTS = {
    "Tu_Raza_1": 600.0,
    # ...
}
```

## 📱 Integración con Flutter

### Configuración en Flutter

En `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const String API_BASE_URL = 'http://192.168.0.8:8000';
  static const String WEBSOCKET_URL = 'ws://192.168.0.8:8000/ws';
  static const String ANALYZE_FRAME_ENDPOINT = '/analyze-frame';
  static const String HEALTH_ENDPOINT = '/health';
}
```

### Uso en Flutter

```dart
// Enviar imagen para análisis
final response = await dio.post(
  '${AppConstants.API_BASE_URL}${AppConstants.ANALYZE_FRAME_ENDPOINT}',
  data: FormData.fromMap({
    'file': await MultipartFile.fromFile(imagePath),
  }),
);

// Conectar WebSocket
final channel = WebSocketChannel.connect(
  Uri.parse(AppConstants.WEBSOCKET_URL),
);
```

## 🧪 Testing

### Test Manual

```bash
# Verificar salud del servidor
curl http://192.168.0.8:8000/health

# Probar análisis con imagen
curl -X POST "http://192.168.0.8:8000/analyze-frame" \
     -F "file=@test_image.jpg"
```

### Test WebSocket

```python
import websockets
import asyncio

async def test_websocket():
    uri = "ws://192.168.0.8:8000/ws"
    async with websockets.connect(uri) as websocket:
        # Enviar ping
        await websocket.send('{"type": "ping"}')
        
        # Recibir respuesta
        response = await websocket.recv()
        print(f"Respuesta: {response}")

asyncio.run(test_websocket())
```

## 🔍 Monitoreo

### Logs

El servidor genera logs detallados:
- **INFO**: Operaciones normales
- **WARNING**: Advertencias
- **ERROR**: Errores críticos

### Métricas

```bash
# Estadísticas del servidor
curl http://192.168.0.8:8000/stats
```

Respuesta:
```json
{
  "active_connections": 2,
  "total_analyses": 150,
  "model_accuracy": 0.87,
  "uptime": "2:30:15"
}
```

## 🚨 Solución de Problemas

### Error: Modelo no encontrado
```bash
# Verificar que el modelo existe
ls -la models/bovino_model.h5

# Reentrenar si es necesario
python train_model.py
```

### Error: Puerto ocupado
```bash
# Cambiar puerto en .env
PORT=8001

# O matar proceso
lsof -ti:8000 | xargs kill -9
```

### Error: Dependencias faltantes
```bash
# Reinstalar dependencias
pip install -r requirements.txt --force-reinstall
```

## 📈 Optimización

### Rendimiento

1. **GPU**: Usar GPU para inferencia más rápida
2. **Batch Processing**: Procesar múltiples imágenes
3. **Caching**: Cachear resultados frecuentes
4. **Load Balancing**: Múltiples instancias

### Escalabilidad

1. **Docker**: Containerización
2. **Kubernetes**: Orquestación
3. **Redis**: Cache distribuido
4. **Message Queue**: Procesamiento asíncrono

## 🤝 Contribución

1. Fork el proyecto
2. Crear rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## 📞 Soporte

- **Issues**: Crear issue en GitHub
- **Documentación**: Ver `docs/` para más detalles
- **Email**: contacto@bovino-ia.com

---

**🐄 Bovino IA Server** - Reconocimiento inteligente de ganado bovino 