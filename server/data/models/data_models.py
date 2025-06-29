from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from enum import Enum

from domain.entities.bovino_entity import BovinoDetectionResult
from domain.entities.analysis_entity import AnalysisStatus


class BovinoModel(BaseModel):
    """Modelo de datos para análisis de bovino (capa de datos)"""
    raza: str = Field(..., description="Raza del bovino identificada")
    caracteristicas: List[str] = Field(..., description="Características del bovino")
    confianza: float = Field(..., ge=0.0, le=1.0, description="Nivel de confianza del análisis")
    timestamp: datetime = Field(default_factory=datetime.now, description="Timestamp del análisis")
    peso_estimado: float = Field(..., ge=0.0, description="Peso estimado en kg")
    detection_result: BovinoDetectionResult = Field(
        default=BovinoDetectionResult.BOVINO_DETECTED,
        description="Resultado de la detección"
    )
    precision_score: float = Field(
        default=0.0, ge=0.0, le=1.0,
        description="Puntuación de precisión del análisis"
    )
    processing_time_ms: Optional[int] = Field(
        default=None,
        description="Tiempo de procesamiento en milisegundos"
    )

    def to_entity(self):
        """Convertir a entidad de dominio"""
        from domain.entities.bovino_entity import BovinoEntity
        return BovinoEntity(
            raza=self.raza,
            caracteristicas=self.caracteristicas,
            confianza=self.confianza,
            peso_estimado=self.peso_estimado,
            timestamp=self.timestamp,
            detection_result=self.detection_result,
            precision_score=self.precision_score,
            processing_time_ms=self.processing_time_ms or 0
        )

    @classmethod
    def from_entity(cls, entity):
        """Crear desde entidad de dominio"""
        return cls(
            raza=entity.raza,
            caracteristicas=entity.caracteristicas,
            confianza=entity.confianza,
            peso_estimado=entity.peso_estimado,
            timestamp=entity.timestamp,
            detection_result=entity.detection_result,
            precision_score=entity.precision_score,
            processing_time_ms=entity.processing_time_ms
        )


class AnalysisModel(BaseModel):
    """Modelo de datos para análisis de frames (capa de datos)"""
    frame_id: str = Field(..., description="ID único del frame")
    status: AnalysisStatus = Field(..., description="Estado del análisis")
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)
    result: Optional[BovinoModel] = Field(default=None, description="Resultado del análisis")
    error: Optional[str] = Field(default=None, description="Mensaje de error si falló")

    def to_entity(self):
        """Convertir a entidad de dominio"""
        from domain.entities.analysis_entity import AnalysisEntity
        return AnalysisEntity(
            frame_id=self.frame_id,
            status=self.status,
            created_at=self.created_at,
            updated_at=self.updated_at,
            result=self.result.to_entity() if self.result else None,
            error=self.error
        )

    @classmethod
    def from_entity(cls, entity):
        """Crear desde entidad de dominio"""
        return cls(
            frame_id=entity.frame_id,
            status=entity.status,
            created_at=entity.created_at,
            updated_at=entity.updated_at,
            result=BovinoModel.from_entity(entity.result) if entity.result else None,
            error=entity.error
        )


class HealthCheckModel(BaseModel):
    """Modelo de datos para health check"""
    status: str = Field(..., description="Estado del servidor")
    timestamp: datetime = Field(default_factory=datetime.now)
    queue_size: int = Field(..., description="Tamaño de la cola de análisis")
    active_analyses: int = Field(..., description="Análisis activos")
    model_ready: bool = Field(..., description="Estado del modelo TensorFlow")


class ServerStatsModel(BaseModel):
    """Modelo de datos para estadísticas del servidor"""
    total_frames_processed: int = Field(..., description="Total de frames procesados")
    successful_analyses: int = Field(..., description="Análisis exitosos")
    failed_analyses: int = Field(..., description="Análisis fallidos")
    average_processing_time_ms: float = Field(..., description="Tiempo promedio de procesamiento")
    uptime_seconds: int = Field(..., description="Tiempo de actividad del servidor")
    memory_usage_mb: float = Field(..., description="Uso de memoria en MB") 