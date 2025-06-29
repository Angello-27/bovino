from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from enum import Enum

class AnalysisStatus(str, Enum):
    """Estados de análisis de frame"""
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"

class BovinoDetectionResult(str, Enum):
    """Resultados de detección de bovino"""
    BOVINO_DETECTED = "bovino_detected"
    NO_BOVINO = "no_bovino"
    UNCERTAIN = "uncertain"

class BovinoModel(BaseModel):
    """Modelo de datos para análisis de bovino"""
    raza: str = Field(..., description="Raza del bovino identificada")
    caracteristicas: List[str] = Field(..., description="Características del bovino")
    confianza: float = Field(..., ge=0.0, le=1.0, description="Nivel de confianza del análisis")
    timestamp: datetime = Field(default_factory=datetime.now, description="Timestamp del análisis")
    peso_estimado: float = Field(..., ge=0.0, description="Peso estimado en kg")
    
    # Nuevos campos para análisis mejorado
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

class BovinoAnalysisRequest(BaseModel):
    """Solicitud de análisis de bovino"""
    frame_id: str = Field(..., description="ID único del frame")
    timestamp: datetime = Field(default_factory=datetime.now)

class BovinoAnalysisResponse(BaseModel):
    """Respuesta de análisis de bovino"""
    frame_id: str = Field(..., description="ID único del frame")
    status: AnalysisStatus = Field(..., description="Estado del análisis")
    result: Optional[BovinoModel] = Field(default=None, description="Resultado del análisis")
    error: Optional[str] = Field(default=None, description="Mensaje de error si falló")
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)
    
    # Métodos de utilidad
    def is_completed(self) -> bool:
        """Verificar si el análisis está completado"""
        return self.status == AnalysisStatus.COMPLETED
    
    def is_failed(self) -> bool:
        """Verificar si el análisis falló"""
        return self.status == AnalysisStatus.FAILED
    
    def is_pending(self) -> bool:
        """Verificar si el análisis está pendiente"""
        return self.status in [AnalysisStatus.PENDING, AnalysisStatus.PROCESSING]
    
    def has_bovino(self) -> bool:
        """Verificar si se detectó un bovino"""
        return (self.result is not None and 
                self.result.detection_result == BovinoDetectionResult.BOVINO_DETECTED)

class FrameSubmissionResponse(BaseModel):
    """Respuesta al enviar un frame"""
    frame_id: str = Field(..., description="ID único del frame")
    status: AnalysisStatus = Field(default=AnalysisStatus.PENDING)
    message: str = Field(default="Frame enviado para análisis")
    created_at: datetime = Field(default_factory=datetime.now)

class HealthCheckResponse(BaseModel):
    """Respuesta de health check del servidor"""
    status: str = Field(..., description="Estado del servidor")
    timestamp: datetime = Field(default_factory=datetime.now)
    queue_size: int = Field(..., description="Tamaño de la cola de análisis")
    active_analyses: int = Field(..., description="Análisis activos")
    model_ready: bool = Field(..., description="Estado del modelo TensorFlow")

class ServerStats(BaseModel):
    """Estadísticas del servidor"""
    total_frames_processed: int = Field(..., description="Total de frames procesados")
    successful_analyses: int = Field(..., description="Análisis exitosos")
    failed_analyses: int = Field(..., description="Análisis fallidos")
    average_processing_time_ms: float = Field(..., description="Tiempo promedio de procesamiento")
    uptime_seconds: int = Field(..., description="Tiempo de actividad del servidor")
    memory_usage_mb: float = Field(..., description="Uso de memoria en MB")
