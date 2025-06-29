from abc import ABC, abstractmethod
from typing import Optional
import logging

from domain.entities.bovino_entity import BovinoEntity

logger = logging.getLogger(__name__)


class TensorFlowDataSource(ABC):
    """Contrato del datasource para TensorFlow"""
    
    @abstractmethod
    async def initialize_model(self) -> None:
        """Inicializar el modelo de TensorFlow"""
        pass
    
    @abstractmethod
    async def analyze_bovino(self, image_data: bytes) -> BovinoEntity:
        """
        Analizar una imagen de bovino
        
        Args:
            image_data: Datos de la imagen en bytes
            
        Returns:
            BovinoEntity con el resultado del análisis
        """
        pass
    
    @abstractmethod
    def is_model_ready(self) -> bool:
        """Verificar si el modelo está listo"""
        pass
    
    @abstractmethod
    async def get_model_info(self) -> dict:
        """Obtener información del modelo"""
        pass 