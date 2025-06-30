"""
Entidades de Dominio - Clean Architecture

Entidades inmutables que representan los conceptos de negocio
"""

from .bovino_entity import BovinoEntity
from .analysis_entity import AnalysisEntity

__all__ = [
    'BovinoEntity',
    'AnalysisEntity'
] 