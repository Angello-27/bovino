# 🐄 Guía Completa: TensorFlow para Principiantes - Bovino IA

## 📋 Requisitos del Sistema

### **Sistema Operativo**
- ✅ **Windows 10/11** (Recomendado)
- ✅ **Ubuntu 18.04+** 
- ✅ **macOS 10.14+**

### **Hardware Mínimo**
- **RAM**: 8 GB (16 GB recomendado)
- **Almacenamiento**: 10 GB libres
- **CPU**: Intel i5 o AMD equivalente
- **GPU**: Opcional (acelera el entrenamiento)

### **Software Requerido**
- **Python**: 3.8, 3.9, 3.10 o 3.11
- **pip**: Gestor de paquetes de Python
- **Git**: Para clonar repositorios (opcional)

## 🔧 Paso 1: Instalar Python

### **Windows**
1. Ve a [python.org](https://www.python.org/downloads/)
2. Descarga Python 3.11 (última versión estable)
3. **IMPORTANTE**: Marca "Add Python to PATH" durante la instalación
4. Instala con permisos de administrador

### **Verificar Instalación**
```bash
# Abrir Command Prompt (cmd) o PowerShell
python --version
# Debe mostrar: Python 3.11.x

pip --version
# Debe mostrar: pip 23.x.x
```

### **Linux (Ubuntu)**
```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv
```

### **macOS**
```bash
# Instalar Homebrew primero
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar Python
brew install python
```

## 📦 Paso 2: Configurar el Entorno de Desarrollo

### **1. Crear Directorio del Proyecto**
```bash
# Crear carpeta para el proyecto
mkdir bovino-ia-server
cd bovino-ia-server

# Clonar o copiar archivos del servidor
# (Si tienes los archivos, cópialos aquí)
```

### **2. Crear Entorno Virtual**
```bash
# Crear entorno virtual
python -m venv venv

# Activar entorno virtual
# Windows:
venv\Scripts\activate
# Linux/macOS:
source venv/bin/activate

# Verificar que está activado
# Debe aparecer (venv) al inicio de la línea de comando
```

### **3. Actualizar pip**
```bash
pip install --upgrade pip
```

## 🤖 Paso 3: Instalar TensorFlow

### **Opción A: TensorFlow CPU (Más Fácil)**
```bash
# Instalar TensorFlow para CPU
pip install tensorflow==2.15.0

# Verificar instalación
python -c "import tensorflow as tf; print('TensorFlow version:', tf.__version__)"
```

### **Opción B: TensorFlow GPU (Más Rápido)**
```bash
# Solo si tienes GPU NVIDIA
pip install tensorflow[gpu]==2.15.0

# Verificar GPU
python -c "import tensorflow as tf; print('GPU disponible:', tf.config.list_physical_devices('GPU'))"
```

### **4. Instalar Dependencias del Proyecto**
```bash
# Instalar todas las dependencias
pip install -r requirements.txt
```

## 🧪 Paso 4: Verificar Instalación

### **Crear Script de Verificación**
```python
# Crear archivo: test_tensorflow.py
import tensorflow as tf
import numpy as np
import cv2
from PIL import Image

print("🔍 Verificando instalación de TensorFlow...")

# Verificar versión
print(f"✅ TensorFlow version: {tf.__version__}")

# Verificar dispositivos
print(f"✅ CPU disponible: {len(tf.config.list_physical_devices('CPU'))}")
print(f"✅ GPU disponible: {len(tf.config.list_physical_devices('GPU'))}")

# Crear modelo simple
model = tf.keras.Sequential([
    tf.keras.layers.Dense(10, activation='relu', input_shape=(5,)),
    tf.keras.layers.Dense(1)
])

# Compilar modelo
model.compile(optimizer='adam', loss='mse')

# Crear datos de prueba
X = np.random.random((100, 5))
y = np.random.random((100, 1))

# Entrenar modelo
model.fit(X, y, epochs=1, verbose=0)

print("✅ TensorFlow funciona correctamente!")
print("✅ Modelo entrenado exitosamente!")
```

### **Ejecutar Verificación**
```bash
python test_tensorflow.py
```

## 🚀 Paso 5: Ejecutar el Servidor

### **1. Usar Script Automático (Recomendado)**
```bash
# El script hace todo automáticamente
python start_server.py
```

### **2. Configuración Manual**
```bash
# Activar entorno virtual
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/macOS

# Ejecutar servidor
python main.py
```

### **3. Verificar que el Servidor Funciona**
```bash
# En otra terminal
python test_server.py
```

## 📊 Paso 6: Entrenar el Modelo (Opcional)

### **1. Preparar Datos de Entrenamiento**
```bash
# Crear estructura de directorios
mkdir -p data/bovine_images

# Crear carpetas para cada raza
mkdir data/bovine_images/Angus
mkdir data/bovine_images/Hereford
mkdir data/bovine_images/Holstein
mkdir data/bovine_images/Jersey
mkdir data/bovine_images/Brahman
mkdir data/bovine_images/Charolais
mkdir data/bovine_images/Limousin
mkdir data/bovine_images/Simmental
mkdir data/bovine_images/Shorthorn
mkdir data/bovine_images/Gelbvieh
```

### **2. Agregar Imágenes**
- Coloca imágenes de bovinos en las carpetas correspondientes
- Formatos soportados: .jpg, .jpeg, .png
- Tamaño recomendado: 224x224 píxeles o más grande
- Mínimo 10 imágenes por raza

### **3. Entrenar Modelo**
```bash
python train_model.py
```

## 🔍 Paso 7: Solución de Problemas Comunes

### **Error: "tensorflow not found"**
```bash
# Verificar que el entorno virtual está activado
# Debe aparecer (venv) al inicio

# Reinstalar TensorFlow
pip uninstall tensorflow
pip install tensorflow==2.15.0
```

### **Error: "Microsoft Visual C++ 14.0 is required" (Windows)**
```bash
# Instalar Visual Studio Build Tools
# Descargar desde: https://visualstudio.microsoft.com/visual-cpp-build-tools/
# O usar versión precompilada
pip install tensorflow-cpu==2.15.0
```

### **Error: "Permission denied" (Linux/macOS)**
```bash
# Usar sudo o cambiar permisos
sudo pip install tensorflow==2.15.0
# O mejor: usar entorno virtual
```

### **Error: "CUDA not found" (GPU)**
```bash
# Usar versión CPU
pip uninstall tensorflow
pip install tensorflow-cpu==2.15.0
```

### **Error: "Port already in use"**
```bash
# Cambiar puerto en .env
PORT=8001

# O matar proceso
# Windows:
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Linux/macOS:
lsof -ti:8000 | xargs kill -9
```

## 📱 Paso 8: Conectar con Flutter

### **1. Verificar IP del Servidor**
```bash
# Windows
ipconfig

# Linux/macOS
ifconfig
# o
ip addr show
```

### **2. Actualizar Configuración en Flutter**
```dart
// En lib/core/constants/app_constants.dart
class AppConstants {
  // Cambiar por tu IP local
  static const String API_BASE_URL = 'http://TU_IP:8000';
  static const String WEBSOCKET_URL = 'ws://TU_IP:8000/ws';
}
```

### **3. Probar Conexión**
```bash
# Desde Flutter, ejecutar
flutter run

# Verificar logs de conexión
```

## 🎯 Paso 9: Verificar Funcionamiento Completo

### **1. Servidor Funcionando**
```bash
# Debe mostrar:
# ✅ Servidor Bovino IA iniciado correctamente
# 📡 Servidor corriendo en: http://192.168.0.8:8000
# 🔌 WebSocket disponible en: ws://192.168.0.8:8000/ws
```

### **2. Pruebas Exitosas**
```bash
python test_server.py

# Debe mostrar:
# 🎉 ¡Todas las pruebas pasaron!
```

### **3. Flutter Conectado**
- App Flutter se conecta al servidor
- Cámara captura imágenes
- Análisis de bovinos funciona
- Peso estimado se muestra

## 📚 Recursos Adicionales

### **Documentación Oficial**
- [TensorFlow Tutorials](https://www.tensorflow.org/tutorials)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Flutter Documentation](https://docs.flutter.dev/)

### **Videos Tutoriales**
- [TensorFlow para Principiantes](https://www.youtube.com/watch?v=6_2hzRopPbQ)
- [FastAPI Crash Course](https://www.youtube.com/watch?v=0hGrH7qoq0U)

### **Comunidad**
- [Stack Overflow](https://stackoverflow.com/questions/tagged/tensorflow)
- [Reddit r/tensorflow](https://www.reddit.com/r/tensorflow/)

## 🎉 ¡Felicidades!

Si llegaste hasta aquí, tienes:
- ✅ TensorFlow instalado y funcionando
- ✅ Servidor Bovino IA ejecutándose
- ✅ Modelo de IA listo para análisis
- ✅ Integración con Flutter configurada

**¡Tu proyecto de reconocimiento de bovinos está listo para usar!** 🐄🚀 