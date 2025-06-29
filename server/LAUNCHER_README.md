# 🚀 Lanzador del Servidor Bovino IA

## 📋 Descripción

El **lanzador** es una herramienta interactiva que te guía paso a paso para configurar y ejecutar el servidor Bovino IA correctamente, especialmente útil cuando tienes múltiples versiones de Python instaladas.

## 🎯 ¿Por qué necesitas el lanzador?

- **Múltiples versiones de Python** (3.11 y 3.13)
- **Configuración compleja** con entorno virtual
- **Dependencias específicas** de TensorFlow
- **Arquitectura limpia** con múltiples capas
- **Guía paso a paso** para evitar errores

## 🚀 Cómo usar el lanzador

### Opción 1: Lanzador interactivo (Recomendado)
```bash
python launch_server.py
```

### Opción 2: Scripts directos
```bash
# PowerShell
.\activate_python311.ps1

# Command Prompt
activate_python311.bat
```

## 📁 Archivos del lanzador

### `launch_server.py`
- **Propósito:** Lanzador interactivo principal
- **Funciones:**
  - ✅ Verifica versión de Python
  - ✅ Verifica entorno virtual
  - ✅ Verifica dependencias
  - ✅ Guía de configuración
  - ✅ Información de arquitectura
  - ✅ Solución de problemas
  - ✅ Ejecución del servidor

### `activate_python311.ps1`
- **Propósito:** Configuración para PowerShell
- **Funciones:**
  - ✅ Verifica Python 3.11
  - ✅ Crea entorno virtual
  - ✅ Instala dependencias
  - ✅ Activa entorno virtual

### `activate_python311.bat`
- **Propósito:** Configuración para Command Prompt
- **Funciones:**
  - ✅ Verifica Python 3.11
  - ✅ Crea entorno virtual
  - ✅ Instala dependencias
  - ✅ Activa entorno virtual

### `.python-version`
- **Propósito:** Especifica versión de Python
- **Contenido:** `3.11.9`
- **Uso:** Para herramientas como pyenv

## 🔄 Flujo de uso

### Primera vez (Configuración inicial)
```bash
# 1. Ejecutar lanzador
python launch_server.py

# 2. Seleccionar opción 2 (Ver instrucciones)
# 3. Seguir las instrucciones mostradas
```

### Uso diario
```bash
# 1. Activar entorno virtual
.\venv\Scripts\Activate.ps1  # PowerShell
# o
venv\Scripts\activate.bat    # Command Prompt

# 2. Ejecutar servidor
python main.py
```

## 🎯 Opciones del lanzador

### 1. 🚀 Ejecutar servidor
- Ejecuta `main.py` directamente
- Solo si todo está configurado correctamente

### 2. 📋 Ver instrucciones de configuración
- Muestra paso a paso cómo configurar
- Incluye comandos para PowerShell y Command Prompt

### 3. 📁 Explicación de archivos
- Explica el propósito de cada archivo
- Cuándo y cómo usar cada uno

### 4. 🏗️ Información de arquitectura
- Explica la estructura Clean Architecture
- Describe cada capa del proyecto

### 5. 📡 Ver endpoints disponibles
- Lista todos los endpoints de la API
- Incluye documentación automática

### 6. 🔧 Solución de problemas
- Problemas comunes y soluciones
- Guía de troubleshooting

### 7. ❌ Salir
- Cierra el lanzador

## 🔍 Verificaciones automáticas

El lanzador verifica automáticamente:

- ✅ **Python 3.11** instalado y disponible
- ✅ **Entorno virtual** activo
- ✅ **requirements.txt** presente
- ✅ **Dependencias** instaladas

## 🚨 Problemas comunes

### Error: Python 3.13 no compatible
```bash
# Solución: Usar Python 3.11
.\activate_python311.ps1
```

### Error: Módulo no encontrado
```bash
# Solución: Activar entorno virtual
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### Error: Puerto 8000 ocupado
```bash
# Solución: Cambiar puerto en .env
HOST=0.0.0.0
PORT=8001
```

### Error: Permisos en Windows
```bash
# Solución: Ejecutar como administrador
# PowerShell como administrador
```

## 📊 Dependencias verificadas

El lanzador verifica estas dependencias críticas:

- **fastapi** - Framework web
- **uvicorn** - Servidor ASGI
- **tensorflow** - IA y machine learning
- **numpy** - Computación numérica
- **pillow** - Procesamiento de imágenes
- **python-multipart** - Subida de archivos

## 🎯 Beneficios del lanzador

### Para desarrolladores nuevos
- ✅ **Guía paso a paso** clara
- ✅ **Verificaciones automáticas**
- ✅ **Solución de problemas** integrada
- ✅ **Documentación** contextual

### Para desarrollo diario
- ✅ **Configuración rápida**
- ✅ **Detección de problemas**
- ✅ **Información de arquitectura**
- ✅ **Acceso a endpoints**

### Para troubleshooting
- ✅ **Diagnóstico automático**
- ✅ **Soluciones específicas**
- ✅ **Verificaciones de estado**
- ✅ **Guía de configuración**

## 🔗 Integración con el proyecto

El lanzador está diseñado para trabajar con:

- **Clean Architecture** implementada
- **Inyección de dependencias** con GetIt
- **FastAPI** para la API REST
- **TensorFlow** para análisis de IA
- **Entorno virtual** Python 3.11

## 📝 Notas importantes

1. **Siempre usar Python 3.11** para este proyecto
2. **Activar entorno virtual** antes de ejecutar
3. **Verificar dependencias** si hay problemas
4. **Usar el lanzador** para configuración inicial
5. **Consultar troubleshooting** si hay errores

---

*El lanzador hace que la configuración y ejecución del servidor sea simple y confiable, especialmente cuando tienes múltiples versiones de Python.* 