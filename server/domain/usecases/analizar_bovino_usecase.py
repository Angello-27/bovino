from typing import Optional
import logging
from datetime import datetime

from ..entities.bovino_entity import BovinoEntity
from ..entities.analysis_entity import AnalysisEntity, AnalysisStatus
from ..repositories.bovino_repository import BovinoRepository

logger = logging.getLogger(__name__)


class AnalizarBovinoUseCase:
    """Caso de uso para análisis de bovinos"""
    
    def __init__(self, bovino_repository: BovinoRepository):
        self.bovino_repository = bovino_repository
    
    async def execute(self, frame_id: str, image_data: bytes) -> AnalysisEntity:
        """
        Ejecutar análisis de bovino
        
        Args:
            frame_id: ID único del frame
            image_data: Datos de la imagen
            
        Returns:
            AnalysisEntity con el resultado
        """
        try:
            logger.info(f"🔄 Iniciando análisis de frame: {frame_id}")
            
            # Crear entidad de análisis inicial
            analysis = AnalysisEntity(
                frame_id=frame_id,
                status=AnalysisStatus.PENDING,
                created_at=datetime.now(),
                updated_at=datetime.now()
            )
            
            # Guardar análisis inicial
            await self.bovino_repository.guardar_analisis(analysis)
            
            # Marcar como procesando
            analysis.mark_as_processing()
            await self.bovino_repository.actualizar_analisis(analysis)
            
            # Realizar análisis
            start_time = datetime.now()
            bovino_result = await self.bovino_repository.analizar_frame(frame_id, image_data)
            
            # Calcular tiempo de procesamiento
            processing_time = (datetime.now() - start_time).total_seconds() * 1000
            bovino_result.processing_time_ms = int(processing_time)
            
            # Marcar como completado
            analysis.mark_as_completed(bovino_result)
            await self.bovino_repository.actualizar_analisis(analysis)
            
            logger.info(f"✅ Análisis completado: {frame_id} - Raza: {bovino_result.raza}")
            return analysis
            
        except Exception as e:
            logger.error(f"❌ Error en análisis de frame {frame_id}: {e}")
            
            # Marcar como fallido
            if 'analysis' in locals():
                analysis.mark_as_failed(str(e))
                await self.bovino_repository.actualizar_analisis(analysis)
            else:
                # Crear análisis fallido si no se pudo crear el inicial
                analysis = AnalysisEntity(
                    frame_id=frame_id,
                    status=AnalysisStatus.FAILED,
                    created_at=datetime.now(),
                    updated_at=datetime.now(),
                    error=str(e)
                )
                await self.bovino_repository.guardar_analisis(analysis)
            
            raise


class ObtenerAnalisisUseCase:
    """Caso de uso para obtener estado de análisis"""
    
    def __init__(self, bovino_repository: BovinoRepository):
        self.bovino_repository = bovino_repository
    
    async def execute(self, frame_id: str) -> Optional[AnalysisEntity]:
        """
        Obtener estado de análisis
        
        Args:
            frame_id: ID del frame
            
        Returns:
            AnalysisEntity si existe, None si no existe
        """
        try:
            logger.info(f"🔍 Consultando análisis: {frame_id}")
            return await self.bovino_repository.obtener_analisis(frame_id)
        except Exception as e:
            logger.error(f"❌ Error consultando análisis {frame_id}: {e}")
            raise


class LimpiarAnalisisAntiguosUseCase:
    """Caso de uso para limpiar análisis antiguos"""
    
    def __init__(self, bovino_repository: BovinoRepository):
        self.bovino_repository = bovino_repository
    
    async def execute(self, horas: int = 1) -> int:
        """
        Limpiar análisis antiguos
        
        Args:
            horas: Número de horas para considerar como antiguo
            
        Returns:
            Número de análisis eliminados
        """
        try:
            logger.info(f"🧹 Limpiando análisis más antiguos de {horas} horas")
            eliminados = await self.bovino_repository.limpiar_analisis_antiguos(horas)
            logger.info(f"✅ Eliminados {eliminados} análisis antiguos")
            return eliminados
        except Exception as e:
            logger.error(f"❌ Error limpiando análisis antiguos: {e}")
            raise


class ObtenerEstadisticasUseCase:
    """Caso de uso para obtener estadísticas"""
    
    def __init__(self, bovino_repository: BovinoRepository):
        self.bovino_repository = bovino_repository
    
    async def execute(self) -> dict:
        """
        Obtener estadísticas del sistema
        
        Returns:
            Diccionario con estadísticas
        """
        try:
            logger.info("📊 Obteniendo estadísticas del sistema")
            return await self.bovino_repository.obtener_estadisticas()
        except Exception as e:
            logger.error(f"❌ Error obteniendo estadísticas: {e}")
            raise 