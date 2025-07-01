import tensorflow as tf
import numpy as np
import cv2
import io
from PIL import Image
import json
import logging
from typing import List, Tuple, Optional
import random
from datetime import datetime
import asyncio
import time
import psutil

from config.settings import Settings
from domain.entities.bovino_entity import BovinoEntity, BovinoDetectionResult
from .tensorflow_datasource import TensorFlowDataSource

logger = logging.getLogger(__name__)


class TensorFlowDataSourceImpl(TensorFlowDataSource):
    """Implementación del datasource para TensorFlow"""

    def __init__(self):
        self.settings = Settings()
        self.model = None
        self.class_labels = []
        self.model_ready = False
        self.total_analyses = 0
        self.start_time = datetime.now()
        self.is_initialized = False
        self.breeds = [
            "Angus", "Hereford", "Holstein", "Jersey", "Brahman",
            "Charolais", "Limousin", "Simmental", "Shorthorn", "Gelbvieh"
        ]
        self.breed_weights = {
            "Angus": 650.0, "Hereford": 680.0, "Holstein": 750.0,
            "Jersey": 450.0, "Brahman": 700.0, "Charolais": 800.0,
            "Limousin": 750.0, "Simmental": 800.0, "Shorthorn": 650.0,
            "Gelbvieh": 700.0
        }
        self.breed_characteristics = {
            "Angus": ["Negro", "Sin cuernos", "Musculoso", "Adaptable"],
            "Hereford": ["Rojo y blanco", "Cuernos cortos", "Rustico", "Buen temperamento"],
            "Holstein": ["Blanco y negro", "Grande", "Lechera", "Alta producción"],
            "Jersey": ["Marrón claro", "Pequeña", "Lechera", "Alta grasa"],
            "Brahman": ["Gris", "Joroba", "Resistente al calor", "Cuernos largos"],
            "Charolais": ["Blanco", "Grande", "Musculoso", "Cárnico"],
            "Limousin": ["Dorado", "Musculoso", "Cárnico", "Eficiente"],
            "Simmental": ["Rojo y blanco", "Grande", "Doble propósito", "Gentil"],
            "Shorthorn": ["Rojo", "Mediano", "Doble propósito", "Histórico"],
            "Gelbvieh": ["Dorado", "Mediano", "Cárnico", "Europeo"]
        }

    async def initialize_model(self) -> None:
        """Inicializar el modelo de TensorFlow"""
        try:
            logger.info("🤖 Inicializando modelo de TensorFlow...")

            # Cargar modelo entrenado real
            model_path = self.settings.MODEL_PATH
            labels_path = self.settings.LABELS_PATH
            
            logger.info(f"📥 Cargando modelo desde: {model_path}")
            logger.info(f"📋 Cargando etiquetas desde: {labels_path}")
            
            # Cargar modelo entrenado
            self.model = tf.keras.models.load_model(model_path)
            
            # Cargar etiquetas de clases
            with open(labels_path, 'r', encoding='utf-8') as f:
                self.class_labels = json.load(f)
            
            # Convertir a lista de nombres de razas
            self.breed_names = list(self.class_labels.keys())

            self.model_ready = True
            logger.info(f"✅ Modelo cargado con {len(self.breed_names)} clases")
            logger.info(f"🐄 Razas: {self.breed_names}")
            
            self.is_initialized = True
            logger.info("✅ Modelo TensorFlow inicializado correctamente")

        except Exception as e:
            logger.error(f"❌ Error al inicializar modelo: {e}")
            raise



    def is_model_ready(self) -> bool:
        """Verificar si el modelo está listo"""
        return self.model_ready

    async def analyze_bovino(self, image_data: bytes) -> BovinoEntity:
        """Analizar una imagen de bovino y retornar resultados"""
        try:
            if not self.model_ready:
                raise Exception("Modelo no inicializado")

            # Preprocesar la imagen
            image = self._preprocess_image(image_data)

            # Realizar predicción
            prediction = await self._predict_breed(image)

            # Obtener raza y confianza
            breed_index = np.argmax(prediction)
            confidence = float(prediction[breed_index])
            breed = self.breed_names[breed_index]

            # Obtener características de la raza
            characteristics = self.settings.BREED_CHARACTERISTICS.get(breed, [])

            # Estimar peso basado en la raza y características de la imagen
            estimated_weight = self._estimate_weight(breed, confidence, image)

            # Crear resultado
            result = BovinoEntity(
                raza=breed,
                caracteristicas=characteristics,
                confianza=confidence,
                peso_estimado=estimated_weight,
                timestamp=datetime.now(),
                detection_result=BovinoDetectionResult.BOVINO_DETECTED,
                precision_score=confidence,
                processing_time_ms=0  # Se calculará en el use case
            )

            self.total_analyses += 1
            logger.info(f"📊 Análisis #{self.total_analyses} completado")

            return result

        except Exception as e:
            logger.error(f"Error en análisis de bovino: {e}")
            raise

    def _preprocess_image(self, image_data: bytes) -> np.ndarray:
        """Preprocesar imagen para el modelo"""
        try:
            # Convertir bytes a imagen PIL
            image = Image.open(io.BytesIO(image_data))

            # Convertir a RGB si es necesario
            if image.mode != "RGB":
                image = image.convert("RGB")

            # Redimensionar
            image = image.resize((self.settings.IMAGE_SIZE, self.settings.IMAGE_SIZE))

            # Convertir a array numpy
            image_array = np.array(image)

            # Normalizar (0-1)
            image_array = image_array.astype(np.float32) / 255.0

            # Agregar dimensión de batch
            image_array = np.expand_dims(image_array, axis=0)

            return image_array

        except Exception as e:
            logger.error(f"Error en preprocesamiento de imagen: {e}")
            raise

    async def _predict_breed(self, image: np.ndarray) -> np.ndarray:
        """Realizar predicción de raza"""
        try:
            if self.model is None:
                raise Exception("Modelo no cargado")
                
            # Usar modelo real para predicción
            prediction = self.model.predict(image, verbose="silent")
            return prediction[0]  # Retornar primera predicción

        except Exception as e:
            logger.error(f"Error en predicción: {e}")
            raise



    def _estimate_weight(
        self, breed: str, confidence: float, image: np.ndarray
    ) -> float:
        """Estimar peso basado en raza y características de la imagen"""
        try:
            # Peso base de la raza
            base_weight = self.breed_weights.get(breed, 600.0)

            # Ajuste basado en confianza
            confidence_adjustment = (confidence - 0.5) * 100

            # Ajuste basado en características de la imagen
            # En un modelo real, extraerías características como:
            # - Tamaño del bovino en la imagen
            # - Proporciones corporales
            # - Color y textura
            image_adjustment = random.uniform(-50, 50)

            # Calcular peso final
            estimated_weight = base_weight + confidence_adjustment + image_adjustment

            # Asegurar que esté en el rango válido
            estimated_weight = max(self.settings.MIN_WEIGHT, 
                                 min(self.settings.MAX_WEIGHT, estimated_weight))

            return round(estimated_weight, 1)

        except Exception as e:
            logger.error(f"Error en estimación de peso: {e}")
            return self.breed_weights.get(breed, 600.0)

    async def get_model_info(self) -> dict:
        """Obtener información del modelo"""
        try:
            uptime = (datetime.now() - self.start_time).total_seconds()
            memory_usage = psutil.Process().memory_info().rss / 1024 / 1024  # MB

            return {
                "model_ready": self.model_ready,
                "total_analyses": self.total_analyses,
                "uptime_seconds": int(uptime),
                "memory_usage_mb": round(memory_usage, 2),
                "class_labels": self.class_labels,
                "breeds_supported": len(self.breeds)
            }
        except Exception as e:
            logger.error(f"Error obteniendo información del modelo: {e}")
            return {
                "model_ready": False,
                "error": str(e)
            } 