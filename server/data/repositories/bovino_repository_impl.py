import logging
from typing import Optional
from datetime import datetime, timedelta

from domain.entities.bovino_entity import BovinoEntity
from domain.entities.analysis_entity import AnalysisEntity, AnalysisStatus
from domain.repositories.bovino_repository import BovinoRepository
from data.datasources.tensorflow_datasource_impl import TensorFlowDataSourceImpl

logger = logging.getLogger(__name__)


class BovinoRepositoryImpl(BovinoRepository):
    """Implementación del repositorio de bovino"""
    
    def __init__(self, datasource: TensorFlowDataSourceImpl):
        self.datasource = datasource
        self.analysis_history = []
        self.analysis_storage = {}  # Almacenamiento en memoria para análisis
        logger.info("🔧 BovinoRepositoryImpl inicializado")
    
    async def initialize(self) -> None:
        """Inicializar el repositorio"""
        try:
            await self.datasource.initialize_model()
            logger.info("✅ Repositorio de bovino inicializado correctamente")
        except Exception as e:
            logger.error(f"❌ Error al inicializar repositorio: {e}")
            raise
    
    async def analizar_frame(self, frame_id: str, image_data: bytes) -> BovinoEntity:
        """Analizar un frame de bovino"""
        try:
            logger.info(f"🔍 Iniciando análisis de frame: {frame_id}")
            
            # Delegar el análisis al datasource
            result = await self.datasource.analyze_bovino(image_data)
            
            # Guardar en historial
            self.analysis_history.append({
                'timestamp': datetime.now(),
                'result': result,
                'image_size': len(image_data),
                'frame_id': frame_id
            })
            
            logger.info(f"✅ Análisis completado: {result.raza} ({result.confianza:.2f}%)")
            return result
            
        except Exception as e:
            logger.error(f"❌ Error en análisis de frame {frame_id}: {e}")
            raise
    
    async def obtener_analisis(self, frame_id: str) -> Optional[AnalysisEntity]:
        """Obtener el estado de un análisis"""
        try:
            return self.analysis_storage.get(frame_id)
        except Exception as e:
            logger.error(f"❌ Error obteniendo análisis {frame_id}: {e}")
            return None
    
    async def guardar_analisis(self, analysis: AnalysisEntity) -> None:
        """Guardar un análisis en el repositorio"""
        try:
            self.analysis_storage[analysis.frame_id] = analysis
            logger.info(f"💾 Análisis guardado: {analysis.frame_id}")
        except Exception as e:
            logger.error(f"❌ Error guardando análisis: {e}")
            raise
    
    async def actualizar_analisis(self, analysis: AnalysisEntity) -> None:
        """Actualizar un análisis existente"""
        try:
            self.analysis_storage[analysis.frame_id] = analysis
            logger.info(f"🔄 Análisis actualizado: {analysis.frame_id}")
        except Exception as e:
            logger.error(f"❌ Error actualizando análisis: {e}")
            raise
    
    async def limpiar_analisis_antiguos(self, horas: int = 1) -> int:
        """Limpiar análisis más antiguos que las horas especificadas"""
        try:
            cutoff_time = datetime.now() - timedelta(hours=horas)
            frames_to_remove = []
            
            for frame_id, analysis in self.analysis_storage.items():
                if analysis.created_at < cutoff_time:
                    frames_to_remove.append(frame_id)
            
            for frame_id in frames_to_remove:
                del self.analysis_storage[frame_id]
            
            logger.info(f"🧹 Eliminados {len(frames_to_remove)} análisis antiguos")
            return len(frames_to_remove)
            
        except Exception as e:
            logger.error(f"❌ Error limpiando análisis antiguos: {e}")
            return 0
    
    async def obtener_estadisticas(self) -> dict:
        """Obtener estadísticas del repositorio"""
        try:
            total_analyses = len(self.analysis_history)
            successful_analyses = len([a for a in self.analysis_history if a['result'].confianza > 0.5])
            
            return {
                "total_analyses": total_analyses,
                "successful_analyses": successful_analyses,
                "success_rate": (successful_analyses / total_analyses * 100) if total_analyses > 0 else 0,
                "last_analysis": self.analysis_history[-1]['timestamp'] if self.analysis_history else None,
                "active_analyses": len(self.analysis_storage)
            }
        except Exception as e:
            logger.error(f"❌ Error obteniendo estadísticas: {e}")
            return {"error": str(e)}
    
    # Métodos adicionales para compatibilidad
    async def analyze_bovino(self, image_data: bytes) -> BovinoEntity:
        """Analizar una imagen de bovino (método de compatibilidad)"""
        return await self.analizar_frame("temp_frame", image_data)
    
    async def get_analysis_history(self, limit: int = 10) -> list:
        """Obtener historial de análisis"""
        try:
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
        """Obtener estadísticas del repositorio (método de compatibilidad)"""
        return await self.obtener_estadisticas() 