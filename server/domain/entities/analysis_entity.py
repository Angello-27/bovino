from dataclasses import dataclass
from datetime import datetime
from typing import Optional
from enum import Enum

from .bovino_entity import BovinoEntity


class AnalysisStatus(str, Enum):
    """Estados de análisis de frame"""
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"


@dataclass
class AnalysisEntity:
    """Entidad de dominio para análisis de frames"""
    frame_id: str
    status: AnalysisStatus
    created_at: datetime
    updated_at: datetime
    result: Optional[BovinoEntity] = None
    error: Optional[str] = None

    def __post_init__(self):
        """Validaciones de dominio"""
        if not self.frame_id:
            raise ValueError("Frame ID no puede estar vacío")

    @property
    def is_completed(self) -> bool:
        """Verificar si el análisis está completado"""
        return self.status == AnalysisStatus.COMPLETED

    @property
    def is_failed(self) -> bool:
        """Verificar si el análisis falló"""
        return self.status == AnalysisStatus.FAILED

    @property
    def is_pending(self) -> bool:
        """Verificar si el análisis está pendiente"""
        return self.status in [AnalysisStatus.PENDING, AnalysisStatus.PROCESSING]

    @property
    def has_bovino(self) -> bool:
        """Verificar si se detectó un bovino"""
        return (self.result is not None and 
                self.result.es_bovino_detectado)

    @property
    def processing_time_seconds(self) -> float:
        """Tiempo de procesamiento en segundos"""
        if self.result and self.result.processing_time_ms:
            return self.result.processing_time_ms / 1000.0
        return 0.0

    def mark_as_processing(self):
        """Marcar como en procesamiento"""
        self.status = AnalysisStatus.PROCESSING
        self.updated_at = datetime.now()

    def mark_as_completed(self, result: BovinoEntity):
        """Marcar como completado"""
        self.status = AnalysisStatus.COMPLETED
        self.result = result
        self.updated_at = datetime.now()

    def mark_as_failed(self, error: str):
        """Marcar como fallido"""
        self.status = AnalysisStatus.FAILED
        self.error = error
        self.updated_at = datetime.now() 