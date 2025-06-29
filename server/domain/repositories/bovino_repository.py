from abc import ABC, abstractmethod
from typing import Optional
from datetime import datetime

from ..entities.bovino_entity import BovinoEntity
from ..entities.analysis_entity import AnalysisEntity


class BovinoRepository(ABC):
    """Contrato del repositorio para análisis de bovinos"""
    
    @abstractmethod
    async def analizar_frame(self, frame_id: str, image_data: bytes) -> BovinoEntity:
        """
        Analizar un frame de bovino
        
        Args:
            frame_id: ID único del frame
            image_data: Datos de la imagen en bytes
            
        Returns:
            BovinoEntity con el resultado del análisis
            
        Raises:
            ValueError: Si los datos son inválidos
            Exception: Si hay error en el análisis
        """
        pass
    
    @abstractmethod
    async def obtener_analisis(self, frame_id: str) -> Optional[AnalysisEntity]:
        """
        Obtener el estado de un análisis
        
        Args:
            frame_id: ID del frame a consultar
            
        Returns:
            AnalysisEntity si existe, None si no existe
        """
        pass
    
    @abstractmethod
    async def guardar_analisis(self, analysis: AnalysisEntity) -> None:
        """
        Guardar un análisis en el repositorio
        
        Args:
            analysis: Entidad de análisis a guardar
        """
        pass
    
    @abstractmethod
    async def actualizar_analisis(self, analysis: AnalysisEntity) -> None:
        """
        Actualizar un análisis existente
        
        Args:
            analysis: Entidad de análisis actualizada
        """
        pass
    
    @abstractmethod
    async def limpiar_analisis_antiguos(self, horas: int = 1) -> int:
        """
        Limpiar análisis más antiguos que las horas especificadas
        
        Args:
            horas: Número de horas para considerar como antiguo
            
        Returns:
            Número de análisis eliminados
        """
        pass
    
    @abstractmethod
    async def obtener_estadisticas(self) -> dict:
        """
        Obtener estadísticas del repositorio
        
        Returns:
            Diccionario con estadísticas
        """
        pass 