"""
Capa de Dominio - Clean Architecture

Esta capa contiene:
- Entities: Entidades de negocio inmutables
- Repositories: Contratos de repositorios (interfaces)
- UseCases: Casos de uso de la aplicación
"""

from .entities import BovinoEntity, AnalysisEntity
from .repositories import BovinoRepository
from .usecases import AnalizarBovinoUseCase

__all__ = [
    # Entities
    'BovinoEntity',
    'AnalysisEntity',
    
    # Repositories
    'BovinoRepository',
    
    # Use Cases
    'AnalizarBovinoUseCase'
] 