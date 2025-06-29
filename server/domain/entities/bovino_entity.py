from dataclasses import dataclass
from datetime import datetime
from typing import List
from enum import Enum


class BovinoDetectionResult(str, Enum):
    """Resultados de detección de bovino"""
    BOVINO_DETECTED = "bovino_detected"
    NO_BOVINO = "no_bovino"
    UNCERTAIN = "uncertain"


@dataclass
class BovinoEntity:
    """Entidad de dominio para análisis de bovino"""
    raza: str
    caracteristicas: List[str]
    confianza: float
    peso_estimado: float
    timestamp: datetime
    detection_result: BovinoDetectionResult = BovinoDetectionResult.BOVINO_DETECTED
    precision_score: float = 0.0
    processing_time_ms: int = 0

    def __post_init__(self):
        """Validaciones de dominio"""
        if not 0.0 <= self.confianza <= 1.0:
            raise ValueError("Confianza debe estar entre 0.0 y 1.0")
        
        if self.peso_estimado < 0:
            raise ValueError("Peso estimado no puede ser negativo")
        
        if not 0.0 <= self.precision_score <= 1.0:
            raise ValueError("Precision score debe estar entre 0.0 y 1.0")

    @property
    def peso_formateado(self) -> str:
        """Peso formateado en kg"""
        return f"{self.peso_estimado:.1f} kg"

    @property
    def peso_en_libras(self) -> str:
        """Peso en libras"""
        libras = self.peso_estimado * 2.20462
        return f"{libras:.1f} lbs"

    @property
    def es_peso_normal(self) -> bool:
        """Verificar si el peso está en rango normal"""
        return 300 <= self.peso_estimado <= 800

    @property
    def es_alta_confianza(self) -> bool:
        """Verificar si la confianza es alta"""
        return self.confianza >= 0.8

    @property
    def es_bovino_detectado(self) -> bool:
        """Verificar si se detectó un bovino"""
        return self.detection_result == BovinoDetectionResult.BOVINO_DETECTED 