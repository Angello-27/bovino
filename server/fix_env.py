#!/usr/bin/env python3
"""
Script para recrear el archivo .env con codificación UTF-8 correcta
"""

import os
from pathlib import Path


def create_env_file():
    """Crear archivo .env con codificación UTF-8"""

    env_content = """# Configuracion del servidor Bovino IA
HOST=192.168.0.8
PORT=8000
DEBUG=True

# Configuracion del modelo
MODEL_PATH=models/bovino_model.h5
LABELS_PATH=models/class_labels.json
IMAGE_SIZE=224
BATCH_SIZE=32

# Configuracion de peso estimado
MIN_WEIGHT=200.0
MAX_WEIGHT=1200.0
"""

    # Eliminar archivo existente si hay problema
    env_file = Path(".env")
    if env_file.exists():
        try:
            env_file.unlink()
            print("🗑️ Archivo .env anterior eliminado")
        except Exception as e:
            print(f"⚠️ Error eliminando .env: {e}")

    # Crear nuevo archivo con codificación UTF-8 explícita
    try:
        with open(".env", "w", encoding="utf-8") as f:
            f.write(env_content)
        print("✅ Archivo .env creado correctamente con UTF-8")
        return True
    except Exception as e:
        print(f"❌ Error creando .env: {e}")
        return False


def verify_env_file():
    """Verificar que el archivo .env se puede leer correctamente"""
    try:
        with open(".env", "r", encoding="utf-8") as f:
            content = f.read()
        print("✅ Archivo .env se puede leer correctamente")
        print("📋 Contenido:")
        for line in content.split("\n")[:5]:  # Mostrar primeras 5 líneas
            if line.strip():
                print(f"   {line}")
        return True
    except Exception as e:
        print(f"❌ Error leyendo .env: {e}")
        return False


def main():
    print("🔧 Reparando archivo .env...")

    if create_env_file():
        if verify_env_file():
            print("\n🎉 ¡Archivo .env reparado exitosamente!")
            print("➡️ Ahora ejecuta: python main.py")
            return True

    print("\n❌ No se pudo reparar el archivo .env")
    return False


if __name__ == "__main__":
    main()
