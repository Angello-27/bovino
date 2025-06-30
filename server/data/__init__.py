"""
Capa de Datos - Clean Architecture

Esta capa contiene:
- Datasources: Fuentes de datos concretas
- Models: Modelos de datos con conversión a entidades
- Repositories: Implementaciones de repositorios
"""

from .repositories import BovinoRepositoryImpl
from .datasources import TensorFlowDataSourceImpl
from .models import BovinoModel

__all__ = [
    'BovinoRepositoryImpl',
    'TensorFlowDataSourceImpl',
    'BovinoModel'
] 