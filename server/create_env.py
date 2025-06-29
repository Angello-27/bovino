#!/usr/bin/env python3
"""
Script para crear el archivo .env desde la plantilla
"""

import os
import shutil

def create_env_file():
    """Crear archivo .env desde la plantilla"""
    
    template_file = "env_template.txt"
    env_file = ".env"
    
    if os.path.exists(env_file):
        print(f"⚠️ El archivo {env_file} ya existe")
        response = input("¿Deseas sobrescribirlo? (y/N): ")
        if response.lower() != 'y':
            print("❌ Operación cancelada")
            return
    
    try:
        # Copiar plantilla a .env
        shutil.copy2(template_file, env_file)
        print(f"✅ Archivo {env_file} creado exitosamente")
        print(f"📝 Puedes editar {env_file} para personalizar la configuración")
        
    except FileNotFoundError:
        print(f"❌ No se encontró el archivo {template_file}")
        print("📝 Creando archivo .env con valores por defecto...")
        
        # Crear .env con valores por defecto
        default_env_content = """# Configuración del servidor
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
"""
        
        with open(env_file, 'w', encoding='utf-8') as f:
            f.write(default_env_content)
        
        print(f"✅ Archivo {env_file} creado con valores por defecto")

if __name__ == "__main__":
    create_env_file() 