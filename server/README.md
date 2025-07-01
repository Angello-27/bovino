# 🐄 Bovino IA Server - Backend con Clean Architecture

## 📋 Descripción

Servidor Python con FastAPI que implementa **Clean Architecture** para el análisis de ganado bovino en tiempo real. Procesa imágenes enviadas desde la aplicación Flutter y retorna análisis de razas con estimación de peso mediante un **flujo asíncrono** con HTTP polling.

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
5. **Resultado**: Cuando el análisis está completo, se muestra en pantalla
6. **Limpieza**: Ambos lados eliminan los datos del frame procesado

### Estados del Frame
- **pending**: Frame recibido, esperando procesamiento
- **processing**: Frame siendo analizado por TensorFlow
- **completed**: Análisis completado con resultado
- **failed**: Error en el procesamiento

## 🚀 Lanzador Interactivo (Recomendado)

**¿Tienes múltiples versiones de Python (3.11 y 3.13)?** Usa el lanzador interactivo:

```bash
python launch_server.py
```

El lanzador te guía paso a paso para:
- ✅ Verificar versión de Python correcta
- ✅ Configurar entorno virtual
- ✅ Instalar dependencias
- ✅ Ejecutar el servidor
- ✅ Solucionar problemas comunes

**📖 Ver documentación completa del lanzador:** [LAUNCHER_README.md](LAUNCHER_README.md)

## 🏗️ Arquitectura

El servidor sigue **Clean Architecture** con las siguientes capas:

```
server/
├── domain/                    # 🎯 Capa de Dominio
│   ├── entities/             # Entidades de negocio
│   │   ├── bovino_entity.py         # Entidad Bovino
│   │   └── analysis_entity.py       # Entidad Analysis
│   ├── repositories/         # Contratos de repositorios
│   │   └── bovino_repository.py     # Interfaz del repositorio
│   └── usecases/            # Casos de uso
│       ├── analizar_bovino_usecase.py    # Análisis de bovino
│       ├── consultar_analisis_usecase.py # Consulta de análisis
│       ├── limpiar_analisis_usecase.py   # Limpieza de datos
│       └── estadisticas_usecase.py       # Estadísticas
├── data/                     # 📊 Capa de Datos
│   ├── datasources/          # Fuentes de datos
│   │   └── tensorflow_datasource_impl.py # Implementación TensorFlow
│   ├── models/               # Modelos de datos
│   │   └── data_models.py            # Modelos con conversión a entidades
│   └── repositories/         # Implementaciones
│       └── bovino_repository_impl.py    # Implementación del repositorio
├── config/                   # ⚙️ Configuración
│   └── settings.py           # Configuración centralizada
├── models/                   # 🌐 Modelos de API
│   └── api_models.py         # Modelos Pydantic para FastAPI
├── services/                 # 🔧 Servicios de Infraestructura
│   └── tensorflow_service.py # Servicio TensorFlow
└── main.py                   # 🚀 Punto de entrada
```

## 🔄 Flujo de Datos

1. **Cliente Flutter** envía imagen → `main.py`
2. **main.py** → **UseCase** (lógica de negocio)
3. **UseCase** → **Repository** (abstracción de datos)
4. **Repository** → **DataSource** (implementación concreta)
5. **DataSource** → **TensorFlowService** (infraestructura)
6. **Respuesta** fluye de vuelta por las capas

## 🤖 Modelo de Aprendizaje

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

### Entrenamiento
```bash
# Entrenar modelo desde cero
python train_model.py

# Configuración de entrenamiento
- Epochs: 20
- Batch size: 32
- Learning rate: 0.001
- Optimizer: Adam
- Loss: Sparse Categorical Crossentropy
```

## 🚀 Instalación y Configuración

### 1. Activar entorno virtual
```bash
# Windows
activate_python311.bat

# PowerShell
.\activate_python311.ps1
```

### 2. Instalar dependencias
```bash
pip install -r requirements.txt
```

### 3. Configurar variables de entorno
El archivo `.env` se crea automáticamente con valores por defecto. Para personalizar la configuración:

```bash
# Opción 1: Usar el script automático
python create_env.py

# Opción 2: Crear manualmente desde la plantilla
cp env_template.txt .env
```

**Variables disponibles:**
```env
# Configuración del servidor
HOST=0.0.0.0
PORT=8000
DEBUG=True

# Configuración del modelo
MODEL_PATH=models/bovino_model.h5
LABELS_PATH=models/class_labels.json

# Configuración de imágenes
IMAGE_SIZE=224
BATCH_SIZE=32

# Configuración de peso estimado
MIN_WEIGHT=200.0
MAX_WEIGHT=1200.0

# Configuración de logging
LOG_LEVEL=INFO
LOG_FORMAT=%(asctime)s - %(name)s - %(levelname)s - %(message)s

# Configuración de CORS
ALLOWED_ORIGINS=*

# Configuración de cola de análisis
MAX_QUEUE_SIZE=100
FRAME_TIMEOUT_HOURS=1
```

**📝 Nota:** El archivo `.env` está en `.gitignore` por seguridad. Los valores por defecto están en `config/settings.py`.

### 4. Ejecutar servidor
```bash
python main.py
```

## 📡 Endpoints

### POST `/submit-frame`
Envía una imagen para análisis asíncrono.
- **Input**: Archivo de imagen
- **Output**: ID del frame para consulta posterior

### GET `/check-status/{frame_id}`
Consulta el estado de un análisis.
- **Input**: ID del frame
- **Output**: Estado y resultado del análisis

### GET `/health`
Verifica el estado del servidor.
- **Output**: Estado, cola de análisis, modelo

### GET `/stats`
Estadísticas del servidor.
- **Output**: Métricas de rendimiento

## 🎯 Características

### ✅ Implementado
- **Clean Architecture** completa
- **Inyección de dependencias** con GetIt
- **Casos de uso** bien definidos
- **Entidades de dominio** inmutables
- **Repositorios** con contratos
- **Modelos de datos** con conversión
- **Servicios de infraestructura**
- **API REST** con FastAPI
- **Análisis asíncrono** con cola
- **Estimación de peso** por raza
- **Logging** profesional
- **Manejo de errores** tipado

### 🔄 Flujo de Análisis
1. **Recepción** de imagen desde Flutter
2. **Preprocesamiento** de imagen
3. **Detección** de bovino en la imagen
4. **Clasificación** de raza
5. **Estimación** de peso
6. **Respuesta** con resultados

## 🧪 Testing

```bash
# Tests unitarios
python -m pytest tests/unit/

# Tests de integración
python -m pytest tests/integration/

# Cobertura
python -m pytest --cov=.
```

## 📊 Modelo de Datos

### Entidades de Dominio
```python
# BovinoEntity
class BovinoEntity:
    raza: str
    caracteristicas: List[str]
    confianza: float
    peso_estimado: float
    timestamp: datetime
    
    # Getters útiles
    @property
    def peso_formateado(self) -> str
    @property
    def peso_en_libras(self) -> str
    @property
    def es_peso_normal(self) -> bool
```

### Modelos de API
```python
# BovinoModel (Pydantic)
class BovinoModel(BaseModel):
    raza: str
    caracteristicas: List[str]
    confianza: float
    peso_estimado: float
    timestamp: datetime
```

## 🔧 Configuración Avanzada

### Variables de Entorno
```env
# Servidor
HOST=0.0.0.0
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

# Logging
LOG_LEVEL=INFO
LOG_FORMAT=%(asctime)s - %(name)s - %(levelname)s - %(message)s

# CORS
ALLOWED_ORIGINS=*

# Cola
MAX_QUEUE_SIZE=100
FRAME_TIMEOUT_HOURS=1
```

## 🚀 Despliegue

### Desarrollo
```bash
python main.py
```

### Producción
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

### Docker
```bash
docker build -t bovino-server .
docker run -p 8000:8000 bovino-server
```

## 📱 Comunicación con Flutter

### Endpoints Utilizados por Flutter
- `POST /submit-frame`: Envío de frames para análisis
- `GET /check-status/{frame_id}`: Consulta de estado (HTTP polling cada 2 segundos)
- `GET /health`: Verificación de conexión

### Formato de Respuesta
```json
{
  "frame_id": "uuid-string",
  "status": "completed",
  "result": {
    "raza": "Holstein",
    "caracteristicas": ["Blanco y negro", "Grande", "Lechera"],
    "confianza": 0.85,
    "peso_estimado": 750.0,
    "timestamp": "2024-01-01T12:00:00Z"
  }
}
```

### Sistema de Restricciones de Precisión (Cliente)
El cliente Flutter implementa un algoritmo inteligente para mostrar solo los mejores resultados:

#### **Reglas de Precisión**
1. **Primer Resultado**: Mínimo 0.6% de precisión para ser mostrado
2. **Resultado Final**: Si la precisión ≥ 0.95%, no se cambia más
3. **Misma Raza**: Solo cambiar si la nueva precisión es mayor
4. **Diferente Raza**: 
   - Si precisión actual ≤ 0.5%: Cambiar si la nueva es mayor
   - Si precisión actual > 0.5%: Solo cambiar si la nueva ≥ 0.6%

#### **Comportamiento de la UI**
- ✅ **Mantiene el último resultado exitoso** visible
- ✅ **No muestra "procesando frames"** después del primer resultado
- ✅ **Solo actualiza** si hay mejor precisión o cambio de raza válido
- ✅ **Limpia el estado** solo cuando se sale al home

### Manejo de Errores
- **404**: Frame no encontrado
- **400**: Tipo de archivo no válido
- **500**: Error interno del servidor

## 📄 Documentación Relacionada

- [README Principal](../README.md) - Documentación completa del proyecto
- [Arquitectura](../docs/ARQUITECTURA.md) - Documentación de la arquitectura Flutter
- [Reglas de Desarrollo](../docs/REGLAS_DESARROLLO.md) - Convenciones del proyecto

## 🔄 Mejoras Recientes

### Sistema de Restricciones de Precisión (Cliente)
- ✅ **Algoritmo inteligente** para mostrar solo mejores resultados
- ✅ **Primer resultado** con mínimo 0.6% de precisión
- ✅ **Resultado final** cuando precisión ≥ 0.95%
- ✅ **Misma raza** solo cambia si mejor precisión
- ✅ **Diferente raza** con restricciones de precisión
- ✅ **Logs detallados** con razones de cambio/rechazo

### Comportamiento de UI Mejorado (Cliente)
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

### Modelo de Aprendizaje
- ✅ **MobileNetV2** como modelo base
- ✅ **Transfer learning** para razas bovinas
- ✅ **Estimación de peso** basada en raza y características
- ✅ **5 razas principales** soportadas

### Clean Architecture
- ✅ **Separación de capas** clara
- ✅ **Entidades de dominio** inmutables
- ✅ **Casos de uso** bien definidos
- ✅ **Repositorios** con contratos

---

*Servidor desarrollado con ❤️ siguiendo Clean Architecture, optimizado para análisis asíncrono de ganado bovino con TensorFlow.*