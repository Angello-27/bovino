#!/usr/bin/env python3
"""
🔍 Script para verificar la configuración del dataset y modelo
"""

import os
import json
import logging
from pathlib import Path

# Configurar logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def check_dataset_configuration():
    """Verificar la configuración del dataset y modelo"""
    
    print("🔍 Verificando configuración del dataset y modelo...")
    print("=" * 60)
    
    # 1. Verificar directorio actual
    current_dir = os.getcwd()
    print(f"📁 Directorio actual: {current_dir}")
    
    # 2. Verificar nueva ubicación de datasets
    datasets_dir = Path.home() / "Datasets" / "Bovino"
    print(f"\n📂 Verificando datasets en: {datasets_dir}")
    
    if datasets_dir.exists():
        print(f"   ✅ Directorio de datasets existe")
        
        # Listar datasets descargados
        dataset_folders = [f for f in datasets_dir.iterdir() if f.is_dir()]
        if dataset_folders:
            print(f"   📊 Datasets encontrados: {len(dataset_folders)}")
            for folder in dataset_folders:
                # Contar imágenes en cada dataset
                image_files = list(folder.rglob("*.jpg")) + list(folder.rglob("*.jpeg")) + list(folder.rglob("*.png"))
                print(f"      📁 {folder.name}: {len(image_files)} imágenes")
                
                # Mostrar subcarpetas (razas) si existen
                subfolders = [f for f in folder.iterdir() if f.is_dir()]
                if subfolders:
                    for subfolder in subfolders:
                        sub_images = list(subfolder.rglob("*.jpg")) + list(subfolder.rglob("*.jpeg")) + list(subfolder.rglob("*.png"))
                        print(f"         🐄 {subfolder.name}: {len(sub_images)} imágenes")
        else:
            print(f"   ⚠️ No hay datasets descargados aún")
            print(f"   💡 Ejecuta: python smart_download.py")
    else:
        print(f"   ❌ Directorio de datasets no existe")
        print(f"   💡 Ejecuta: python smart_download.py para crear el directorio")
    
    # 3. Verificar archivos de configuración del proyecto
    config_files = [
        "config/settings.py",
        "models/",
        "data/",
        "assets/data/breeds.json"
    ]
    
    print("\n📋 Verificando archivos de configuración del proyecto:")
    for file_path in config_files:
        if os.path.exists(file_path):
            if os.path.isdir(file_path):
                files = os.listdir(file_path)
                print(f"   ✅ {file_path}/ ({len(files)} archivos)")
                for file in files[:5]:  # Mostrar solo los primeros 5
                    print(f"      - {file}")
                if len(files) > 5:
                    print(f"      ... y {len(files) - 5} más")
            else:
                size = os.path.getsize(file_path)
                print(f"   ✅ {file_path} ({size} bytes)")
        else:
            print(f"   ❌ {file_path} (no encontrado)")
    
    # 4. Verificar dataset de razas
    print("\n🐄 Verificando dataset de razas:")
    breeds_file = "assets/data/breeds.json"
    if os.path.exists(breeds_file):
        try:
            with open(breeds_file, 'r', encoding='utf-8') as f:
                breeds_data = json.load(f)
            print(f"   ✅ Dataset encontrado: {len(breeds_data)} razas")
            for breed in breeds_data:
                print(f"      - {breed}")
        except Exception as e:
            print(f"   ❌ Error leyendo dataset: {e}")
    else:
        print(f"   ❌ Dataset no encontrado en: {breeds_file}")
    
    # 5. Verificar modelos de TensorFlow
    print("\n🤖 Verificando modelos de TensorFlow:")
    model_paths = [
        "models/bovino_model.h5",
        "models/bovino_model.pb",
        "models/class_labels.json",
        "models/model.json"
    ]
    
    for model_path in model_paths:
        if os.path.exists(model_path):
            size = os.path.getsize(model_path)
            print(f"   ✅ {model_path} ({size} bytes)")
        else:
            print(f"   ❌ {model_path} (no encontrado)")
    
    # 6. Verificar configuración de settings
    print("\n⚙️ Verificando configuración de settings:")
    try:
        from config.settings import Settings
        settings = Settings()
        
        print(f"   📊 Tamaño de imagen: {settings.IMAGE_SIZE}x{settings.IMAGE_SIZE}")
        print(f"   🏷️ Razas configuradas: {len(settings.BOVINE_BREEDS)}")
        print(f"   ⚖️ Rango de peso: {settings.MIN_WEIGHT}-{settings.MAX_WEIGHT} kg")
        
        # Verificar si hay modelo configurado
        model_path = getattr(settings, 'MODEL_PATH', None)
        if model_path:
            print(f"   🤖 Modelo configurado: {model_path}")
            if os.path.exists(model_path):
                size = os.path.getsize(model_path)
                print(f"      ✅ Modelo existe ({size} bytes)")
            else:
                print(f"      ❌ Modelo no encontrado")
        else:
            print(f"   ⚠️ MODEL_PATH no configurado")
            
    except Exception as e:
        print(f"   ❌ Error cargando settings: {e}")
    
    # 7. Recomendaciones actualizadas
    print("\n💡 Recomendaciones:")
    print("   1. Para descargar datasets:")
    print("      - Ejecuta: python smart_download.py")
    print("      - Selecciona opción 1 (mini - 50MB) para empezar")
    print("      - Los datasets se guardan en: C:\\Users\\Lenovo\\Datasets\\Bovino")
    
    print("\n   2. Para entrenar tu modelo:")
    print("      - Usa los datasets descargados de la carpeta de usuario")
    print("      - Entrena con TensorFlow/Keras usando las 5 razas disponibles")
    print("      - Guarda el modelo como .h5 en models/")
    print("      - Actualiza BOVINE_BREEDS en config/settings.py")
    
    print("\n   3. Para verificar que funciona:")
    print("      - Ejecuta: python main.py")
    print("      - Envía una imagen a /submit-frame")
    print("      - Revisa los logs para ver el análisis")
    
    print("\n   4. Para debugging:")
    print("      - Revisa los logs del servidor")
    print("      - Usa el endpoint /health para verificar estado")
    print("      - Usa el endpoint /stats para ver estadísticas")

if __name__ == "__main__":
    check_dataset_configuration() 