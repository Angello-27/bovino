#!/usr/bin/env python3
"""
📊 Monitor de Entrenamiento del Modelo Bovino
"""

import time
import psutil
import os
from pathlib import Path

def monitor_training():
    """Monitorear el proceso de entrenamiento"""
    print("📊 Monitor de Entrenamiento del Modelo Bovino")
    print("=" * 50)
    
    # Verificar si el proceso de Python está ejecutándose
    python_processes = []
    for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
        try:
            if proc.info['name'] == 'python.exe' and proc.info['cmdline']:
                cmdline = ' '.join(proc.info['cmdline'])
                if 'train_model.py' in cmdline:
                    python_processes.append(proc)
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
    
    if python_processes:
        print(f"✅ Proceso de entrenamiento encontrado: {len(python_processes)} proceso(s)")
        for proc in python_processes:
            print(f"   PID: {proc.pid}")
            print(f"   CPU: {proc.cpu_percent()}%")
            print(f"   Memoria: {proc.memory_info().rss / 1024 / 1024:.1f} MB")
    else:
        print("❌ No se encontró proceso de entrenamiento activo")
    
    # Verificar archivos generados
    models_dir = Path("models")
    if models_dir.exists():
        print(f"\n📁 Directorio models: {models_dir}")
        for file in models_dir.iterdir():
            if file.is_file():
                size_mb = file.stat().st_size / 1024 / 1024
                print(f"   📄 {file.name} ({size_mb:.1f} MB)")
    else:
        print(f"\n📁 Directorio models no existe aún")
    
    # Verificar dataset
    dataset_path = Path.home() / "Datasets" / "Bovino" / "Cattle Breeds"
    if dataset_path.exists():
        print(f"\n📁 Dataset: {dataset_path}")
        total_images = 0
        for breed_folder in dataset_path.iterdir():
            if breed_folder.is_dir():
                image_count = len(list(breed_folder.glob("*.jpg"))) + len(list(breed_folder.glob("*.jpeg"))) + len(list(breed_folder.glob("*.png")))
                total_images += image_count
                print(f"   🐄 {breed_folder.name}: {image_count} imágenes")
        print(f"   📊 Total: {total_images} imágenes")
    
    print("\n" + "=" * 50)

if __name__ == "__main__":
    while True:
        monitor_training()
        print("🔄 Actualizando en 10 segundos... (Ctrl+C para salir)")
        try:
            time.sleep(10)
        except KeyboardInterrupt:
            print("\n👋 Monitor detenido")
            break 