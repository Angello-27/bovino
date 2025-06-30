import logging
from typing import Optional
from datetime import datetime

from domain.entities.bovino_entity import BovinoEntity
from domain.repositories.bovino_repository import BovinoRepository
from data.datasources.tensorflow_datasource_impl import TensorFlowDataSourceImpl

logger = logging.getLogger(__name__)


class BovinoRepositoryImpl(BovinoRepository):
    """Implementación del repositorio de bovino"""
    
    def __init__(self, datasource: TensorFlowDataSourceImpl):
        self.datasource = datasource
        self.analysis_history = []
        logger.info("🔧 BovinoRepositoryImpl inicializado")
    
    async def initialize(self) -> None:
        """Inicializar el repositorio"""
        try:
            await self.datasource.initialize_model()
            logger.info("✅ Repositorio de bovino inicializado correctamente")
        except Exception as e:
            logger.error(f"❌ Error al inicializar repositorio: {e}")
            raise
    
    async def analyze_bovino(self, image_data: bytes) -> BovinoEntity:
        """Analizar una imagen de bovino"""
        try:
            logger.info("🔍 Iniciando análisis de bovino en repositorio...")
            
            # Delegar el análisis al datasource
            result = await self.datasource.analyze_bovino(image_data)
            
            # Guardar en historial
            self.analysis_history.append({
                'timestamp': datetime.now(),
                'result': result,
                'image_size': len(image_data)
            })
            
            logger.info(f"✅ Análisis completado: {result.raza} ({result.confianza:.2f}%)")
            return result
            
        except Exception as e:
            logger.error(f"❌ Error en análisis de bovino: {e}")
            raise
    
    async def get_analysis_history(self, limit: int = 10) -> list:
        """Obtener historial de análisis"""
        try:
            # Retornar los últimos análisis
            return self.analysis_history[-limit:] if self.analysis_history else []
        except Exception as e:
            logger.error(f"❌ Error obteniendo historial: {e}")
            return []
    
    async def get_model_info(self) -> dict:
        """Obtener información del modelo"""
        try:
            return await self.datasource.get_model_info()
        except Exception as e:
            logger.error(f"❌ Error obteniendo información del modelo: {e}")
            return {"error": str(e)}
    
    def is_model_ready(self) -> bool:
        """Verificar si el modelo está listo"""
        return self.datasource.is_model_ready()
    
    async def get_statistics(self) -> dict:
        """Obtener estadísticas del repositorio"""
        try:
            total_analyses = len(self.analysis_history)
            successful_analyses = len([a for a in self.analysis_history if a['result'].confianza > 0.5])
            
            return {
                "total_analyses": total_analyses,
                "successful_analyses": successful_analyses,
                "success_rate": (successful_analyses / total_analyses * 100) if total_analyses > 0 else 0,
                "last_analysis": self.analysis_history[-1]['timestamp'] if self.analysis_history else None
            }
        except Exception as e:
            logger.error(f"❌ Error obteniendo estadísticas: {e}")
            return {"error": str(e)} 