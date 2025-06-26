#!/usr/bin/env python3
"""
Script de inicio simplificado para el servidor Bovino IA
"""

import os
import sys
import subprocess
import logging
from pathlib import Path

# Configurar logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


def check_python_version():
    """Verificar versión de Python"""
    if sys.version_info < (3, 8):
        logger.error("❌ Se requiere Python 3.8 o superior")
        logger.info(f"Versión actual: {sys.version}")
        return False
    logger.info(f"✅ Python {sys.version.split()[0]} detectado")
    return True


def check_requirements():
    """Verificar si requirements.txt existe"""
    requirements_file = Path("requirements.txt")
    if not requirements_file.exists():
        logger.error("❌ requirements.txt no encontrado")
        return False
    logger.info("✅ requirements.txt encontrado")
    return True


def create_venv():
    """Crear entorno virtual si no existe"""
    venv_path = Path("venv")
    if venv_path.exists():
        logger.info("✅ Entorno virtual ya existe")
        return True

    logger.info("🔧 Creando entorno virtual...")
    try:
        subprocess.run([sys.executable, "-m", "venv", "venv"], check=True)
        logger.info("✅ Entorno virtual creado")
        return True
    except subprocess.CalledProcessError as e:
        logger.error(f"❌ Error creando entorno virtual: {e}")
        return False


def install_dependencies():
    """Instalar dependencias"""
    logger.info("📦 Instalando dependencias...")

    # Determinar comando de pip según el sistema
    if os.name == "nt":  # Windows
        pip_cmd = "venv\\Scripts\\pip"
    else:  # Linux/Mac
        pip_cmd = "venv/bin/pip"

    try:
        subprocess.run([pip_cmd, "install", "-r", "requirements.txt"], check=True)
        logger.info("✅ Dependencias instaladas")
        return True
    except subprocess.CalledProcessError as e:
        logger.error(f"❌ Error instalando dependencias: {e}")
        return False


def create_env_file():
    """Crear archivo .env si no existe"""
    env_file = Path(".env")
    if env_file.exists():
        logger.info("✅ Archivo .env ya existe")
        return True

    logger.info("🔧 Creando archivo .env...")

    env_content = """# Configuración del servidor Bovino IA
HOST=192.168.0.8
PORT=8000
DEBUG=True

# Configuración del modelo
MODEL_PATH=models/bovino_model.h5
LABELS_PATH=models/class_labels.json
IMAGE_SIZE=224
BATCH_SIZE=32

# Configuración de peso estimado
MIN_WEIGHT=200.0
MAX_WEIGHT=1200.0
"""

    try:
        with open(env_file, "w") as f:
            f.write(env_content)
        logger.info("✅ Archivo .env creado")
        return True
    except Exception as e:
        logger.error(f"❌ Error creando .env: {e}")
        return False


def create_directories():
    """Crear directorios necesarios"""
    directories = ["models", "data/bovine_images", "logs"]

    for directory in directories:
        dir_path = Path(directory)
        if not dir_path.exists():
            dir_path.mkdir(parents=True, exist_ok=True)
            logger.info(f"📁 Directorio creado: {directory}")


def start_server():
    """Iniciar el servidor"""
    logger.info("🚀 Iniciando servidor Bovino IA...")

    # Determinar comando de Python según el sistema
    if os.name == "nt":  # Windows
        python_cmd = "venv\\Scripts\\python"
    else:  # Linux/Mac
        python_cmd = "venv/bin/python"

    try:
        subprocess.run([python_cmd, "main.py"], check=True)
    except subprocess.CalledProcessError as e:
        logger.error(f"❌ Error iniciando servidor: {e}")
        return False
    except KeyboardInterrupt:
        logger.info("🛑 Servidor detenido por el usuario")
        return True


def main():
    """Función principal"""
    logger.info("🐄 Iniciando configuración del servidor Bovino IA")

    # Verificar requisitos
    if not check_python_version():
        return False

    if not check_requirements():
        return False

    # Crear entorno virtual
    if not create_venv():
        return False

    # Instalar dependencias
    if not install_dependencies():
        return False

    # Crear archivo .env
    if not create_env_file():
        return False

    # Crear directorios
    create_directories()

    logger.info("✅ Configuración completada")
    logger.info("🌐 El servidor estará disponible en: http://192.168.0.8:8000")
    logger.info("📚 Documentación API: http://192.168.0.8:8000/docs")
    logger.info("🔌 WebSocket: ws://192.168.0.8:8000/ws")
    logger.info("")
    logger.info("💡 Para detener el servidor, presiona Ctrl+C")
    logger.info("")

    # Iniciar servidor
    return start_server()


if __name__ == "__main__":
    success = main()
    if not success:
        sys.exit(1)
