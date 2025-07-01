#!/usr/bin/env python3
"""
🔍 Verificación Completa del Modelo Bovino
"""

import os
import json
import logging
import numpy as np
import tensorflow as tf
from pathlib import Path
import time

# Configurar logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def verify_model_files():
    """Verificar que existen los archivos del modelo"""
    print("🔍 VERIFICACIÓN DE ARCHIVOS DEL MODELO")
    print("=" * 50)
    
    model_path = Path("models/bovino_model.h5")
    labels_path = Path("models/class_labels.json")
    
    # Verificar archivos
    files_status = {
        "Modelo (.h5)": model_path.exists(),
        "Etiquetas (.json)": labels_path.exists(),
    }
    
    all_exist = True
    for file_name, exists in files_status.items():
        status = "✅" if exists else "❌"
        print(f"{status} {file_name}")
        if not exists:
            all_exist = False
    
    if not all_exist:
        print("\n❌ Faltan archivos del modelo")
        print("💡 Ejecuta: python train_model.py para entrenar el modelo")
        return False
    
    # Mostrar información de archivos
    print(f"\n📊 Información de archivos:")
    model_size = model_path.stat().st_size / (1024 * 1024)  # MB
    print(f"   Modelo: {model_size:.1f} MB")
    
    with open(labels_path, 'r', encoding='utf-8') as f:
        labels = json.load(f)
    print(f"   Etiquetas: {len(labels)} razas")
    
    return True

def test_model_loading():
    """Probar carga del modelo"""
    print("\n📥 PRUEBA DE CARGA DEL MODELO")
    print("=" * 50)
    
    try:
        model_path = Path("models/bovino_model.h5")
        
        # Medir tiempo de carga
        start_time = time.time()
        model = tf.keras.models.load_model(str(model_path))
        load_time = time.time() - start_time
        
        # Verificar que el modelo se cargó correctamente
        if model is None:
            raise Exception("El modelo se cargó como None")
        
        print(f"✅ Modelo cargado exitosamente")
        print(f"⏱️ Tiempo de carga: {load_time:.2f} segundos")
        print(f"📊 Parámetros: {model.count_params():,}")
        print(f"🏗️ Arquitectura:")
        print(f"   Entrada: {model.input_shape}")
        print(f"   Salida: {model.output_shape}")
        print(f"   Capas: {len(model.layers)}")
        
        return model
        
    except Exception as e:
        print(f"❌ Error cargando modelo: {e}")
        return None

def test_labels_loading():
    """Probar carga de etiquetas"""
    print("\n📋 PRUEBA DE CARGA DE ETIQUETAS")
    print("=" * 50)
    
    try:
        labels_path = Path("models/class_labels.json")
        
        with open(labels_path, 'r', encoding='utf-8') as f:
            labels = json.load(f)
        
        print(f"✅ Etiquetas cargadas exitosamente")
        print(f"📊 Total de razas: {len(labels)}")
        
        print(f"\n🐄 Razas disponibles:")
        for breed, idx in labels.items():
            print(f"   {idx}: {breed}")
        
        return labels
        
    except Exception as e:
        print(f"❌ Error cargando etiquetas: {e}")
        return None

def test_prediction(model, labels):
    """Probar predicción del modelo"""
    print("\n🧪 PRUEBA DE PREDICCIÓN")
    print("=" * 50)
    
    try:
        # Crear imagen dummy
        dummy_image = tf.random.normal((1, 224, 224, 3))
        
        # Medir tiempo de predicción
        start_time = time.time()
        predictions = model.predict(dummy_image, verbose="silent")
        prediction_time = time.time() - start_time
        
        # Obtener resultado
        predicted_class = np.argmax(predictions[0])
        confidence = float(predictions[0][predicted_class])
        
        # Encontrar raza predicha
        predicted_breed = None
        for breed, idx in labels.items():
            if idx == predicted_class:
                predicted_breed = breed
                break
        
        print(f"✅ Predicción exitosa")
        print(f"⏱️ Tiempo de predicción: {prediction_time:.3f} segundos")
        print(f"🎯 Raza predicha: {predicted_breed}")
        print(f"📊 Confianza: {confidence:.2%}")
        
        # Mostrar todas las predicciones
        print(f"\n📈 Predicciones por raza:")
        for breed, idx in labels.items():
            prob = float(predictions[0][idx])
            print(f"   {breed}: {prob:.2%}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error en predicción: {e}")
        return False

def test_server_integration():
    """Probar integración con el servidor"""
    print("\n🌐 PRUEBA DE INTEGRACIÓN CON SERVIDOR")
    print("=" * 50)
    
    try:
        # Importar componentes del servidor
        from config.settings import Settings
        from data.datasources import TensorFlowDataSourceImpl
        
        # Cargar configuración
        settings = Settings()
        print(f"✅ Configuración cargada")
        print(f"   Modelo: {settings.MODEL_PATH}")
        print(f"   Etiquetas: {settings.LABELS_PATH}")
        print(f"   Tamaño imagen: {settings.IMAGE_SIZE}x{settings.IMAGE_SIZE}")
        print(f"   Razas configuradas: {len(settings.BOVINE_BREEDS)}")
        
        # Probar datasource
        datasource = TensorFlowDataSourceImpl()
        print(f"✅ Datasource creado")
        
        return True
        
    except Exception as e:
        print(f"❌ Error en integración: {e}")
        return False

def run_complete_verification():
    """Ejecutar verificación completa"""
    print("🔍 VERIFICACIÓN COMPLETA DEL MODELO BOVINO")
    print("=" * 60)
    
    results = {}
    
    # 1. Verificar archivos
    results['files'] = verify_model_files()
    if not results['files']:
        return False
    
    # 2. Probar carga del modelo
    model = test_model_loading()
    results['model_loading'] = model is not None
    
    # 3. Probar carga de etiquetas
    labels = test_labels_loading()
    results['labels_loading'] = labels is not None
    
    # 4. Probar predicción
    if model and labels:
        results['prediction'] = test_prediction(model, labels)
    else:
        results['prediction'] = False
    
    # 5. Probar integración con servidor
    results['server_integration'] = test_server_integration()
    
    # Resumen final
    print("\n" + "=" * 60)
    print("📊 RESUMEN DE VERIFICACIÓN")
    print("=" * 60)
    
    all_passed = True
    for test_name, passed in results.items():
        status = "✅" if passed else "❌"
        print(f"{status} {test_name.replace('_', ' ').title()}")
        if not passed:
            all_passed = False
    
    if all_passed:
        print(f"\n🎉 ¡VERIFICACIÓN COMPLETADA EXITOSAMENTE!")
        print(f"🚀 Tu modelo está listo para usar en la aplicación Flutter")
        print(f"💡 Puedes ejecutar: python main.py para iniciar el servidor")
    else:
        print(f"\n❌ Algunas verificaciones fallaron")
        print(f"🔧 Revisa los errores anteriores para solucionarlos")
    
    return all_passed

if __name__ == "__main__":
    success = run_complete_verification()
    exit(0 if success else 1) 