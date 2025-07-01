#!/usr/bin/env python3
"""
📊 Verificación del Estado del Modelo Bovino
"""

import os
import json
from pathlib import Path

def check_model_status():
    """Verificar el estado actual del modelo"""
    print("📊 ESTADO DEL MODELO BOVINO")
    print("=" * 40)
    
    # Verificar archivos
    model_path = Path("models/bovino_model.h5")
    labels_path = Path("models/class_labels.json")
    
    print("📁 Archivos del modelo:")
    print(f"   Modelo: {'✅' if model_path.exists() else '❌'} {model_path}")
    print(f"   Etiquetas: {'✅' if labels_path.exists() else '❌'} {labels_path}")
    
    if not model_path.exists():
        print("\n❌ Modelo no encontrado")
        print("💡 Ejecuta: python train_model.py")
        return False
    
    if not labels_path.exists():
        print("\n❌ Etiquetas no encontradas")
        print("💡 Ejecuta: python train_model.py")
        return False
    
    # Mostrar información
    model_size = model_path.stat().st_size / (1024 * 1024)  # MB
    print(f"\n📊 Información:")
    print(f"   Tamaño del modelo: {model_size:.1f} MB")
    
    with open(labels_path, 'r', encoding='utf-8') as f:
        labels = json.load(f)
    print(f"   Razas disponibles: {len(labels)}")
    
    print(f"\n🐄 Razas configuradas:")
    for breed, idx in labels.items():
        print(f"   {idx}: {breed}")
    
    print(f"\n✅ Modelo listo para usar")
    print(f"🚀 Ejecuta: python main.py para iniciar el servidor")
    
    return True

if __name__ == "__main__":
    check_model_status() 