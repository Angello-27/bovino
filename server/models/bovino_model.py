from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
import random


class BovinoModel(BaseModel):
    """Modelo de datos para el análisis de bovino"""

    raza: str = Field(..., description="Raza identificada del bovino")
    caracteristicas: List[str] = Field(
        ..., description="Características visuales del bovino"
    )
    confianza: float = Field(
        ..., ge=0.0, le=1.0, description="Nivel de confianza del análisis (0-1)"
    )
    timestamp: datetime = Field(
        default_factory=datetime.now, description="Timestamp del análisis"
    )
    peso_estimado: float = Field(
        ..., ge=200.0, le=1200.0, description="Peso estimado en kilogramos"
    )

    class Config:
        json_encoders = {datetime: lambda v: v.isoformat()}

    def dict(self, *args, **kwargs):
        """Convertir a diccionario con timestamp formateado"""
        data = super().dict(*args, **kwargs)
        data["timestamp"] = self.timestamp.isoformat()
        return data
