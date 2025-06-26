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

from config.settings import Settings
from models.bovino_model import BovinoModel

logger = logging.getLogger(__name__)


class TensorFlowService:
    """Servicio para análisis de bovinos usando TensorFlow"""

    def __init__(self):
        self.settings = Settings()
        self.model = None
        self.class_labels = []
        self.model_ready = False
        self.total_analyses = 0
        self.start_time = datetime.now()

    async def initialize_model(self):
        """Inicializar el modelo de TensorFlow"""
        try:
            logger.info("🤖 Inicializando modelo de TensorFlow...")

            # En un entorno real, cargarías un modelo pre-entrenado
            # Por ahora, creamos un modelo simple para demostración
            self.model = self._create_demo_model()

            # Cargar etiquetas de clases
            self.class_labels = self.settings.BOVINE_BREEDS

            self.model_ready = True
            logger.info(f"✅ Modelo inicializado con {len(self.class_labels)} clases")

        except Exception as e:
            logger.error(f"❌ Error al inicializar modelo: {e}")
            raise

    def _create_demo_model(self):
        """Crear un modelo de demostración simple"""
        # Modelo básico de CNN para clasificación
        model = tf.keras.Sequential(
            [
                tf.keras.layers.Conv2D(
                    32,
                    3,
                    activation="relu",
                    input_shape=(self.settings.IMAGE_SIZE, self.settings.IMAGE_SIZE, 3),
                ),
                tf.keras.layers.MaxPooling2D(),
                tf.keras.layers.Conv2D(64, 3, activation="relu"),
                tf.keras.layers.MaxPooling2D(),
                tf.keras.layers.Conv2D(64, 3, activation="relu"),
                tf.keras.layers.Flatten(),
                tf.keras.layers.Dense(64, activation="relu"),
                tf.keras.layers.Dense(
                    len(self.settings.BOVINE_BREEDS), activation="softmax"
                ),
            ]
        )

        model.compile(
            optimizer="adam",
            loss="sparse_categorical_crossentropy",
            metrics=["accuracy"],
        )

        return model

    def is_model_ready(self) -> bool:
        """Verificar si el modelo está listo"""
        return self.model_ready

    async def analyze_bovino(self, image_data: bytes) -> BovinoModel:
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
            breed = self.class_labels[breed_index]

            # Obtener características de la raza
            characteristics = self.settings.BREED_CHARACTERISTICS.get(breed, [])

            # Estimar peso basado en la raza y características de la imagen
            estimated_weight = self._estimate_weight(breed, confidence, image)

            # Crear resultado
            result = BovinoModel(
                raza=breed,
                caracteristicas=characteristics,
                confianza=confidence,
                peso_estimado=estimated_weight,
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
            # En un entorno real, usarías el modelo entrenado
            # Por ahora, simulamos una predicción
            prediction = self._simulate_prediction()
            return prediction

        except Exception as e:
            logger.error(f"Error en predicción: {e}")
            raise

    def _simulate_prediction(self) -> np.ndarray:
        """Simular predicción para demostración"""
        # Crear predicción aleatoria pero realista
        num_classes = len(self.class_labels)
        prediction = np.random.dirichlet(np.ones(num_classes) * 0.1)

        # Hacer que una clase sea dominante
        dominant_class = np.random.randint(0, num_classes)
        prediction[dominant_class] = np.random.uniform(0.7, 0.95)

        # Normalizar
        prediction = prediction / np.sum(prediction)

        return prediction

    def _estimate_weight(
        self, breed: str, confidence: float, image: np.ndarray
    ) -> float:
        """Estimar peso basado en raza, confianza y características de la imagen"""
        try:
            # Peso base de la raza
            base_weight = self.settings.BREED_AVERAGE_WEIGHTS.get(breed, 600.0)

            # Variación basada en confianza
            confidence_factor = 0.8 + (confidence * 0.4)  # 0.8 - 1.2

            # Variación aleatoria para simular diferencias individuales
            random_factor = np.random.uniform(0.85, 1.15)

            # Calcular peso estimado
            estimated_weight = base_weight * confidence_factor * random_factor

            # Asegurar que esté en el rango válido
            estimated_weight = max(
                self.settings.MIN_WEIGHT,
                min(self.settings.MAX_WEIGHT, estimated_weight),
            )

            return round(estimated_weight, 1)

        except Exception as e:
            logger.error(f"Error en estimación de peso: {e}")
            return 600.0  # Peso por defecto

    def get_total_analyses(self) -> int:
        """Obtener número total de análisis realizados"""
        return self.total_analyses

    def get_model_accuracy(self) -> float:
        """Obtener precisión del modelo (simulada)"""
        return 0.87  # Simulado

    def get_uptime(self) -> str:
        """Obtener tiempo de funcionamiento"""
        uptime = datetime.now() - self.start_time
        return str(uptime).split(".")[0]  # Sin microsegundos
