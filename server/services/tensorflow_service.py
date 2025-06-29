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

from config.settings import Settings
from models.api_models import BovinoModel, BovinoDetectionResult

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
            "Hereford": ["Rojo y blanco", "Cuornos cortos", "Rustico", "Buen temperamento"],
            "Holstein": ["Blanco y negro", "Grande", "Lechera", "Alta producción"],
            "Jersey": ["Marrón claro", "Pequeña", "Lechera", "Alta grasa"],
            "Brahman": ["Gris", "Joroba", "Resistente al calor", "Cuernos largos"],
            "Charolais": ["Blanco", "Grande", "Musculoso", "Cárnico"],
            "Limousin": ["Dorado", "Musculoso", "Cárnico", "Eficiente"],
            "Simmental": ["Rojo y blanco", "Grande", "Doble propósito", "Gentil"],
            "Shorthorn": ["Rojo", "Mediano", "Doble propósito", "Histórico"],
            "Gelbvieh": ["Dorado", "Mediano", "Cárnico", "Europeo"]
        }

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

            # Simular carga del modelo (en producción cargarías el modelo real)
            await asyncio.sleep(2)
            
            self.is_initialized = True
            logger.info("✅ Modelo TensorFlow inicializado correctamente")

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

    async def analyze_image_async(self, image_data: bytes) -> BovinoModel:
        """
        Analizar imagen de manera asíncrona
        
        Args:
            image_data: Datos de la imagen en bytes
            
        Returns:
            BovinoModel con el resultado del análisis
        """
        start_time = time.time()
        
        try:
            if not self.is_initialized:
                raise Exception("Modelo no inicializado")
            
            logger.info("🔍 Iniciando análisis de imagen...")
            
            # Convertir bytes a imagen
            image = self._bytes_to_image(image_data)
            
            # Preprocesar imagen
            processed_image = self._preprocess_image(image)
            
            # Detectar si hay bovino en la imagen
            detection_result, confidence = await self._detect_bovino(processed_image)
            
            if detection_result == BovinoDetectionResult.NO_BOVINO:
                # No se detectó bovino
                return BovinoModel(
                    raza="No detectado",
                    caracteristicas=["No se detectó ganado bovino en la imagen"],
                    confianza=confidence,
                    peso_estimado=0.0,
                    detection_result=BovinoDetectionResult.NO_BOVINO,
                    precision_score=confidence,
                    processing_time_ms=int((time.time() - start_time) * 1000)
                )
            
            elif detection_result == BovinoDetectionResult.UNCERTAIN:
                # Detección incierta
                return BovinoModel(
                    raza="Incierto",
                    caracteristicas=["Detección incierta - posible bovino"],
                    confianza=confidence,
                    peso_estimado=0.0,
                    detection_result=BovinoDetectionResult.UNCERTAIN,
                    precision_score=confidence,
                    processing_time_ms=int((time.time() - start_time) * 1000)
                )
            
            else:
                # Bovino detectado - clasificar raza
                breed_result = await self._classify_breed(processed_image)
                
                # Estimar peso basado en características visuales
                estimated_weight = self._estimate_weight(breed_result, processed_image)
                
                processing_time = int((time.time() - start_time) * 1000)
                
                logger.info(f"✅ Análisis completado: {breed_result['breed']} - {estimated_weight:.1f} kg")
                
                return BovinoModel(
                    raza=breed_result['breed'],
                    caracteristicas=self.breed_characteristics.get(breed_result['breed'], []),
                    confianza=breed_result['confidence'],
                    peso_estimado=estimated_weight,
                    detection_result=BovinoDetectionResult.BOVINO_DETECTED,
                    precision_score=breed_result['confidence'],
                    processing_time_ms=processing_time
                )
                
        except Exception as e:
            logger.error(f"❌ Error en análisis de imagen: {e}")
            raise

    def _bytes_to_image(self, image_data: bytes) -> np.ndarray:
        """Convertir bytes a imagen numpy"""
        try:
            # Convertir bytes a PIL Image
            pil_image = Image.open(io.BytesIO(image_data))
            
            # Convertir a numpy array
            image_array = np.array(pil_image)
            
            # Convertir a RGB si es necesario
            if len(image_array.shape) == 3 and image_array.shape[2] == 4:
                image_array = cv2.cvtColor(image_array, cv2.COLOR_RGBA2RGB)
            
            return image_array
            
        except Exception as e:
            logger.error(f"Error al convertir bytes a imagen: {e}")
            raise

    def _preprocess_image(self, image: np.ndarray) -> np.ndarray:
        """Preprocesar imagen para análisis"""
        try:
            # Redimensionar a tamaño estándar
            resized = cv2.resize(image, (224, 224))
            
            # Normalizar valores de píxeles
            normalized = resized.astype(np.float32) / 255.0
            
            # Agregar dimensión de batch
            processed = np.expand_dims(normalized, axis=0)
            
            return processed
            
        except Exception as e:
            logger.error(f"Error en preprocesamiento: {e}")
            raise

    async def _detect_bovino(self, image: np.ndarray) -> Tuple[BovinoDetectionResult, float]:
        """
        Detectar si hay bovino en la imagen
        
        Returns:
            Tuple con resultado de detección y confianza
        """
        try:
            # Simular análisis de detección (en producción usarías un modelo de detección)
            await asyncio.sleep(0.5)
            
            # Análisis simple basado en características de la imagen
            # En producción, esto sería un modelo de detección de objetos
            
            # Calcular características básicas
            mean_color = np.mean(image)
            std_color = np.std(image)
            
            # Heurística simple para detectar bovinos
            # (En producción usarías un modelo entrenado)
            if mean_color > 0.3 and mean_color < 0.8 and std_color > 0.1:
                # Características que sugieren presencia de bovino
                confidence = min(0.9, 0.5 + (std_color * 2))
                return BovinoDetectionResult.BOVINO_DETECTED, confidence
            elif mean_color > 0.2 and mean_color < 0.9:
                # Posible bovino pero incierto
                confidence = 0.3
                return BovinoDetectionResult.UNCERTAIN, confidence
            else:
                # No parece haber bovino
                confidence = 0.8
                return BovinoDetectionResult.NO_BOVINO, confidence
                
        except Exception as e:
            logger.error(f"Error en detección de bovino: {e}")
            return BovinoDetectionResult.NO_BOVINO, 0.0

    async def _classify_breed(self, image: np.ndarray) -> dict:
        """
        Clasificar la raza del bovino
        
        Returns:
            Dict con raza y confianza
        """
        try:
            # Simular clasificación (en producción usarías el modelo TensorFlow)
            await asyncio.sleep(1.0)
            
            # Simular predicciones del modelo
            predictions = np.random.dirichlet(np.ones(len(self.breeds)))
            
            # Obtener la raza con mayor probabilidad
            breed_index = np.argmax(predictions)
            breed = self.breeds[breed_index]
            confidence = float(predictions[breed_index])
            
            return {
                'breed': breed,
                'confidence': confidence,
                'all_predictions': dict(zip(self.breeds, predictions.tolist()))
            }
            
        except Exception as e:
            logger.error(f"Error en clasificación de raza: {e}")
            return {
                'breed': 'Angus',
                'confidence': 0.5,
                'all_predictions': {}
            }

    def _estimate_weight(self, breed_result: dict, image: np.ndarray) -> float:
        """
        Estimar peso basado en raza y características visuales
        
        Args:
            breed_result: Resultado de clasificación de raza
            image: Imagen procesada
            
        Returns:
            Peso estimado en kg
        """
        try:
            base_weight = self.breed_weights.get(breed_result['breed'], 600.0)
            
            # Análisis de características visuales para ajustar peso
            # En producción, esto sería más sofisticado
            
            # Calcular características de la imagen
            image_features = self._extract_weight_features(image)
            
            # Ajustar peso basado en características
            weight_adjustment = self._calculate_weight_adjustment(image_features)
            
            estimated_weight = base_weight + weight_adjustment
            
            # Limitar a rangos razonables
            estimated_weight = max(200.0, min(1200.0, estimated_weight))
            
            return estimated_weight
            
        except Exception as e:
            logger.error(f"Error en estimación de peso: {e}")
            return 600.0

    def _extract_weight_features(self, image: np.ndarray) -> dict:
        """Extraer características de la imagen para estimación de peso"""
        try:
            # Características básicas (en producción serían más sofisticadas)
            features = {
                'brightness': float(np.mean(image)),
                'contrast': float(np.std(image)),
                'edge_density': float(np.mean(cv2.Canny(image[0], 50, 150))),
                'texture_variance': float(np.var(image))
            }
            
            return features
            
        except Exception as e:
            logger.error(f"Error al extraer características: {e}")
            return {}

    def _calculate_weight_adjustment(self, features: dict) -> float:
        """Calcular ajuste de peso basado en características"""
        try:
            adjustment = 0.0
            
            # Ajustes basados en características visuales
            # (En producción, esto sería un modelo entrenado)
            
            if 'brightness' in features:
                # Bovinos más claros tienden a ser más grandes
                if features['brightness'] > 0.6:
                    adjustment += 50.0
                elif features['brightness'] < 0.4:
                    adjustment -= 30.0
            
            if 'contrast' in features:
                # Mayor contraste puede indicar mejor definición muscular
                if features['contrast'] > 0.2:
                    adjustment += 20.0
            
            if 'edge_density' in features:
                # Más bordes pueden indicar más detalles/músculos
                if features['edge_density'] > 0.1:
                    adjustment += 15.0
            
            # Agregar variabilidad aleatoria para simular precisión real
            adjustment += np.random.normal(0, 25.0)
            
            return adjustment
            
        except Exception as e:
            logger.error(f"Error al calcular ajuste de peso: {e}")
            return 0.0

    async def get_model_info(self) -> dict:
        """Obtener información del modelo"""
        return {
            "initialized": self.is_initialized,
            "breeds_supported": len(self.breeds),
            "breeds": self.breeds,
            "weight_range": {
                "min": min(self.breed_weights.values()),
                "max": max(self.breed_weights.values())
            }
        }
