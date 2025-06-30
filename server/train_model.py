#!/usr/bin/env python3
"""
🐄 Script de Entrenamiento para Modelo de Clasificación de Razas Bovinas
"""

import os
import json
import logging
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from pathlib import Path
from sklearn.model_selection import train_test_split

# Configurar logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def main():
    """Función principal de entrenamiento"""
    logger.info("🐄 Iniciando entrenamiento del modelo bovino")
    
    # Configuración
    dataset_path = Path.home() / "Datasets" / "Bovino" / "Cattle Breeds"
    models_dir = Path("models")
    models_dir.mkdir(exist_ok=True)
    
    image_size = 224
    batch_size = 32
    epochs = 20  # Reducido para prueba rápida
    
    # Razas disponibles
    breeds = [
        "Ayrshire cattle",
        "Brown Swiss cattle", 
        "Holstein Friesian cattle",
        "Jersey cattle",
        "Red Dane cattle"
    ]
    
    # Mapeo de razas
    breed_mapping = {
        "Ayrshire cattle": "Ayrshire",
        "Brown Swiss cattle": "Brown Swiss",
        "Holstein Friesian cattle": "Holstein",
        "Jersey cattle": "Jersey", 
        "Red Dane cattle": "Red Dane"
    }
    
    logger.info(f"📁 Dataset: {dataset_path}")
    logger.info(f"📊 Razas: {len(breeds)}")
    
    # Verificar dataset
    if not dataset_path.exists():
        logger.error(f"❌ Dataset no encontrado en: {dataset_path}")
        return False
    
    # Cargar datos
    logger.info("📥 Cargando datos...")
    images = []
    labels = []
    
    for breed_folder in dataset_path.iterdir():
        if breed_folder.is_dir():
            breed_name = breed_folder.name
            if breed_name in breeds:
                logger.info(f"📂 Procesando: {breed_name}")
                
                image_files = list(breed_folder.glob("*.jpg")) + list(breed_folder.glob("*.jpeg")) + list(breed_folder.glob("*.png"))
                
                for img_path in image_files[:50]:  # Limitar a 50 imágenes por raza para prueba
                    try:
                        img = tf.keras.preprocessing.image.load_img(
                            img_path, 
                            target_size=(image_size, image_size)
                        )
                        img_array = tf.keras.preprocessing.image.img_to_array(img)
                        img_array = img_array / 255.0
                        
                        images.append(img_array)
                        labels.append(breed_name)
                        
                    except Exception as e:
                        logger.warning(f"⚠️ Error cargando {img_path}: {e}")
    
    if len(images) == 0:
        logger.error("❌ No se pudieron cargar imágenes")
        return False
    
    X = np.array(images)
    y = np.array(labels)
    
    logger.info(f"📈 Total de imágenes: {len(X)}")
    
    # Dividir datos
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    # Convertir etiquetas
    label_to_index = {breed: idx for idx, breed in enumerate(breeds)}
    y_train_encoded = np.array([label_to_index[label] for label in y_train])
    y_test_encoded = np.array([label_to_index[label] for label in y_test])
    
    # Crear modelo
    logger.info("🏗️ Creando modelo...")
    
    base_model = MobileNetV2(
        weights='imagenet',
        include_top=False,
        input_shape=(image_size, image_size, 3)
    )
    base_model.trainable = False
    
    model = keras.Sequential([
        base_model,
        layers.GlobalAveragePooling2D(),
        layers.Dropout(0.2),
        layers.Dense(256, activation='relu'),
        layers.Dropout(0.3),
        layers.Dense(len(breeds), activation='softmax')
    ])
    
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=0.001),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    
    # Entrenar modelo
    logger.info("🚀 Iniciando entrenamiento...")
    
    history = model.fit(
        X_train, y_train_encoded,
        validation_data=(X_test, y_test_encoded),
        epochs=epochs,
        batch_size=batch_size,
        verbose=1
    )
    
    # Evaluar modelo
    logger.info("📊 Evaluando modelo...")
    test_loss, test_accuracy = model.evaluate(X_test, y_test_encoded, verbose=0)
    logger.info(f"✅ Precisión en test: {test_accuracy:.4f}")
    
    # Guardar modelo
    model_path = models_dir / "bovino_model.h5"
    model.save(str(model_path))
    logger.info(f"💾 Modelo guardado en: {model_path}")
    
    # Guardar etiquetas
    labels_path = models_dir / "class_labels.json"
    with open(labels_path, 'w', encoding='utf-8') as f:
        json.dump(label_to_index, f, indent=2, ensure_ascii=False)
    logger.info(f"💾 Etiquetas guardadas en: {labels_path}")
    
    # Actualizar settings.py
    logger.info("⚙️ Actualizando settings.py...")
    update_settings(breed_mapping)
    
    logger.info("🎉 ¡Entrenamiento completado exitosamente!")
    return True

def update_settings(breed_mapping):
    """Actualizar settings.py con las nuevas razas"""
    settings_path = Path("config/settings.py")
    
    if not settings_path.exists():
        logger.error("❌ No se encontró config/settings.py")
        return False
    
    # Leer archivo
    with open(settings_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Nuevas razas
    new_breeds = list(breed_mapping.values())
    breeds_str = '[\n        "' + '",\n        "'.join(new_breeds) + '",\n    ]'
    
    # Características por raza
    characteristics = {
        "Ayrshire": ["Rojo y blanco", "Mediana", "Lechera", "Resistente"],
        "Brown Swiss": ["Marrón", "Grande", "Lechera", "Gentil"],
        "Holstein": ["Blanco y negro", "Grande", "Lechera", "Alta producción"],
        "Jersey": ["Marrón claro", "Pequeña", "Lechera", "Alta grasa"],
        "Red Dane": ["Rojo", "Grande", "Lechera", "Europeo"],
    }
    
    # Pesos por raza
    weights = {
        "Ayrshire": 550.0,
        "Brown Swiss": 650.0,
        "Holstein": 750.0,
        "Jersey": 450.0,
        "Red Dane": 700.0,
    }
    
    # Actualizar BOVINE_BREEDS
    import re
    content = re.sub(
        r'BOVINE_BREEDS = \[.*?\]',
        f'BOVINE_BREEDS = {breeds_str}',
        content,
        flags=re.DOTALL
    )
    
    # Actualizar BREED_CHARACTERISTICS
    characteristics_str = '{\n'
    for breed in new_breeds:
        chars = characteristics.get(breed, ["Característica 1", "Característica 2"])
        characteristics_str += f'        "{breed}": {chars},\n'
    characteristics_str += '    }'
    
    content = re.sub(
        r'BREED_CHARACTERISTICS = \{.*?\}',
        f'BREED_CHARACTERISTICS = {characteristics_str}',
        content,
        flags=re.DOTALL
    )
    
    # Actualizar BREED_AVERAGE_WEIGHTS
    weights_str = '{\n'
    for breed in new_breeds:
        weight = weights.get(breed, 600.0)
        weights_str += f'        "{breed}": {weight}.0,\n'
    weights_str += '    }'
    
    content = re.sub(
        r'BREED_AVERAGE_WEIGHTS = \{.*?\}',
        f'BREED_AVERAGE_WEIGHTS = {weights_str}',
        content,
        flags=re.DOTALL
    )
    
    # Guardar archivo
    with open(settings_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    logger.info("✅ Settings.py actualizado")
    return True

if __name__ == "__main__":
    success = main()
    if success:
        print("\n🎉 ¡Entrenamiento completado!")
        print("📁 Archivos generados:")
        print("   - models/bovino_model.h5")
        print("   - models/class_labels.json")
        print("   - config/settings.py (actualizado)")
    else:
        print("\n❌ Error en el entrenamiento")
    exit(0 if success else 1)
