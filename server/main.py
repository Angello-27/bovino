import os
import warnings
from fastapi import (
    FastAPI,
    UploadFile,
    File,
    HTTPException,
    BackgroundTasks
)
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
import json
import logging
from typing import List, Dict, Any, Optional
import asyncio
from datetime import datetime, timedelta
import uuid
from pydantic import BaseModel

# Configurar warnings globales
from warnings_config import configure_warnings, configure_openCV_warnings, configure_tensorflow_warnings

# Aplicar configuración de warnings
configure_warnings()
configure_openCV_warnings()
configure_tensorflow_warnings()

# Importaciones de Clean Architecture
from domain.usecases import AnalizarBovinoUseCase
from data.repositories import BovinoRepositoryImpl
from data.datasources import TensorFlowDataSourceImpl
from models.api_models import BovinoModel, BovinoAnalysisRequest, BovinoAnalysisResponse, AnalysisStatus, BovinoDetectionResult
from config.settings import Settings

# Configuración de logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuración de la aplicación
settings = Settings()
app = FastAPI(
    title="🐄 Bovino IA Server",
    description="Servidor para análisis de ganado bovino con estimación de peso",
    version="2.0.0"
)

# Configurar CORS para permitir conexiones desde Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especificar el dominio de Flutter
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Inicializar Clean Architecture
datasource = TensorFlowDataSourceImpl()
# repository = BovinoRepositoryImpl(datasource)  # Comentado por problemas de implementación
# analizar_bovino_usecase = AnalizarBovinoUseCase(repository)  # Comentado por problemas de implementación

# Cola de análisis (en memoria - en producción usar Redis/Celery)
analysis_queue: Dict[str, dict] = {}

class FrameAnalysisRequest(BaseModel):
    """Solicitud de análisis de frame"""
    frame_id: str
    timestamp: datetime

class FrameAnalysisResponse(BaseModel):
    """Respuesta de análisis de frame"""
    frame_id: str
    status: str  # "pending", "processing", "completed", "failed"
    result: Optional[BovinoAnalysisResponse] = None
    error: Optional[str] = None
    created_at: datetime
    updated_at: datetime

class HealthResponse(BaseModel):
    """Respuesta de health check"""
    status: str
    timestamp: datetime
    queue_size: int
    active_analyses: int

@app.on_event("startup")
async def startup_event():
    """Evento de inicio del servidor"""
    print("🚀 Iniciando servidor Bovino IA con Clean Architecture...")
    print(f"📍 Servidor en: http://{settings.HOST}:{settings.PORT}")
    print(f"📊 Tamaño de imagen: {settings.IMAGE_SIZE}x{settings.IMAGE_SIZE}")
    print(f"⚖️ Rango de peso: {settings.MIN_WEIGHT}-{settings.MAX_WEIGHT} kg")
    
    try:
        # Inicializar Clean Architecture
        await datasource.initialize_model()
        logger.info("✅ Clean Architecture inicializada correctamente")
        logger.info("✅ Servidor Bovino IA iniciado correctamente")
        logger.info(f"📡 Servidor corriendo en: http://{settings.HOST}:{settings.PORT}")
    except Exception as e:
        logger.error(f"❌ Error al inicializar Clean Architecture: {e}")
        raise

@app.get("/", response_model=dict)
async def root():
    """Información del servidor"""
    return {
        "message": "🐄 Bovino IA Server v2.0 (Clean Architecture)",
        "version": "2.0.0",
        "status": "running",
        "architecture": "Clean Architecture",
        "endpoints": {
            "submit_frame": "/submit-frame",
            "check_status": "/check-status/{frame_id}",
            "health": "/health",
            "docs": "/docs"
        },
        "features": [
            "Análisis asíncrono de frames",
            "Estimación de peso bovino",
            "Cola de procesamiento",
            "Identificación de razas",
            "Clean Architecture implementada"
        ]
    }

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Verificar estado del servidor y cola"""
    active_analyses = len([item for item in analysis_queue.values() 
                          if item["status"] in ["pending", "processing"]])
    
    return HealthResponse(
        status="healthy",
        timestamp=datetime.now(),
        queue_size=len(analysis_queue),
        active_analyses=active_analyses
    )

@app.post("/submit-frame", response_model=FrameAnalysisResponse)
async def submit_frame(
    background_tasks: BackgroundTasks,
    frame: UploadFile = File(...)
):
    """
    Enviar frame para análisis asíncrono usando Clean Architecture
    """
    try:
        logger.info("📸 Nueva solicitud de análisis de frame recibida")
        logger.info(f"📁 Archivo: {frame.filename}")
        logger.info(f"📏 Tamaño: {frame.size} bytes")
        logger.info(f"🔧 Tipo: {frame.content_type}")
        
        # Validar archivo
        if not frame.content_type or not frame.content_type.startswith('image/'):
            logger.error(f"❌ Tipo de archivo no válido: {frame.content_type}")
            raise HTTPException(status_code=400, detail="Archivo debe ser una imagen")
        
        # Generar ID único
        frame_id = str(uuid.uuid4())
        timestamp = datetime.now()
        
        # Leer contenido del archivo
        image_content = await frame.read()
        logger.info(f"📊 Contenido leído: {len(image_content)} bytes")
        
        # Crear entrada en cola
        analysis_queue[frame_id] = {
            "frame_id": frame_id,
            "status": "pending",
            "image_content": image_content,
            "created_at": timestamp,
            "updated_at": timestamp,
            "result": None,
            "error": None
        }
        
        logger.info(f"📋 Frame agregado a cola: {frame_id}")
        logger.info(f"📊 Tamaño de cola actual: {len(analysis_queue)}")
        
        # Iniciar procesamiento en background usando Clean Architecture
        background_tasks.add_task(process_frame_with_clean_architecture, frame_id)
        logger.info(f"🚀 Procesamiento iniciado para frame: {frame_id}")
        
        print(f"📸 Frame {frame_id} enviado para análisis")
        
        return FrameAnalysisResponse(
            frame_id=frame_id,
            status="pending",
            created_at=timestamp,
            updated_at=timestamp
        )
        
    except Exception as e:
        logger.error(f"❌ Error al enviar frame: {e}")
        print(f"❌ Error al enviar frame: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")

@app.get("/check-status/{frame_id}", response_model=FrameAnalysisResponse)
async def check_frame_status(frame_id: str):
    """
    Consultar estado de análisis de frame
    """
    try:
        if frame_id not in analysis_queue:
            raise HTTPException(status_code=404, detail="Frame no encontrado")
        
        frame_data = analysis_queue[frame_id]
        
        # Limpiar frames antiguos (más de 1 hora)
        cleanup_old_frames()
        
        return FrameAnalysisResponse(
            frame_id=frame_id,
            status=frame_data["status"],
            result=frame_data["result"],
            error=frame_data["error"],
            created_at=frame_data["created_at"],
            updated_at=frame_data["updated_at"]
        )
        
    except Exception as e:
        print(f"❌ Error al consultar estado: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")

async def process_frame_with_clean_architecture(frame_id: str):
    """
    Procesar frame usando Clean Architecture
    """
    try:
        if frame_id not in analysis_queue:
            logger.error(f"❌ Frame {frame_id} no encontrado en cola")
            return
        
        logger.info(f"🔍 Iniciando procesamiento de frame {frame_id} con Clean Architecture...")
        
        # Marcar como procesando
        analysis_queue[frame_id]["status"] = "processing"
        analysis_queue[frame_id]["updated_at"] = datetime.now()
        
        print(f"🔍 Procesando frame {frame_id}...")
        
        # Obtener contenido de imagen
        image_content = analysis_queue[frame_id]["image_content"]
        logger.info(f"📊 Imagen obtenida de cola: {len(image_content)} bytes")
        
        # Usar Clean Architecture: DataSource directamente
        logger.info(f"🎯 Ejecutando análisis con Clean Architecture...")
        bovino_entity = await datasource.analyze_bovino(image_content)
        logger.info(f"✅ Análisis completado usando Clean Architecture para frame {frame_id}")
        
        # Convertir entidad a modelo de API
        result = BovinoAnalysisResponse(
            frame_id=frame_id,
            status=AnalysisStatus.COMPLETED,
            result=BovinoModel(
                raza=bovino_entity.raza,
                caracteristicas=bovino_entity.caracteristicas,
                confianza=bovino_entity.confianza,
                peso_estimado=bovino_entity.peso_estimado,
                timestamp=bovino_entity.timestamp,
                detection_result=BovinoDetectionResult.BOVINO_DETECTED,
                precision_score=bovino_entity.precision_score,
                processing_time_ms=bovino_entity.processing_time_ms
            ),
            created_at=analysis_queue[frame_id]["created_at"],
            updated_at=datetime.now()
        )
        
        # Actualizar resultado
        analysis_queue[frame_id]["result"] = result
        analysis_queue[frame_id]["status"] = "completed"
        analysis_queue[frame_id]["updated_at"] = datetime.now()
        
        logger.info(f"📊 Resultado guardado: {bovino_entity.raza} ({bovino_entity.confianza:.2f}%)")
        print(f"✅ Frame {frame_id} procesado exitosamente con Clean Architecture")
        
    except Exception as e:
        logger.error(f"❌ Error procesando frame {frame_id}: {e}")
        
        # Marcar como fallido
        analysis_queue[frame_id]["error"] = str(e)
        analysis_queue[frame_id]["status"] = "failed"
        analysis_queue[frame_id]["updated_at"] = datetime.now()
        
        print(f"❌ Error procesando frame {frame_id}: {e}")

def cleanup_old_frames():
    """Limpiar frames antiguos de la cola"""
    cutoff_time = datetime.now() - timedelta(hours=1)
    frames_to_remove = []
    
    for frame_id, frame_data in analysis_queue.items():
        if frame_data["created_at"] < cutoff_time:
            frames_to_remove.append(frame_id)
    
    for frame_id in frames_to_remove:
        del analysis_queue[frame_id]
        print(f"🗑️ Frame {frame_id} eliminado por antigüedad")

@app.post("/analyze-frame")
async def analyze_frame_legacy(file: UploadFile = File(...)):
    """
    Endpoint legacy para análisis síncrono usando Clean Architecture
    """
    try:
        if not file.content_type or not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="Archivo debe ser una imagen")
        
        image_content = await file.read()
        
        # Usar Clean Architecture
        logger.info("🎯 Ejecutando análisis síncrono con Clean Architecture...")
        bovino_entity = await datasource.analyze_bovino(image_content)
        
        # Convertir a modelo de API
        result = BovinoModel(
            raza=bovino_entity.raza,
            caracteristicas=bovino_entity.caracteristicas,
            confianza=bovino_entity.confianza,
            peso_estimado=bovino_entity.peso_estimado,
            timestamp=bovino_entity.timestamp,
            detection_result=BovinoDetectionResult.BOVINO_DETECTED,
            precision_score=bovino_entity.precision_score,
            processing_time_ms=bovino_entity.processing_time_ms
        )
        
        return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en análisis: {str(e)}")

@app.get("/stats")
async def get_stats():
    """Obtener estadísticas del servidor"""
    total_frames = len(analysis_queue)
    pending_frames = len([item for item in analysis_queue.values() 
                         if item["status"] == "pending"])
    processing_frames = len([item for item in analysis_queue.values() 
                           if item["status"] == "processing"])
    completed_frames = len([item for item in analysis_queue.values() 
                          if item["status"] == "completed"])
    failed_frames = len([item for item in analysis_queue.values() 
                        if item["status"] == "failed"])
    
    # Obtener estadísticas del datasource
    model_info = await datasource.get_model_info()
    
    return {
        "total_frames": total_frames,
        "pending": pending_frames,
        "processing": processing_frames,
        "completed": completed_frames,
        "failed": failed_frames,
        "server_uptime": "running",
        "model_loaded": datasource.is_model_ready(),
        "model_info": model_info
    }

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=True,
        log_level="info"
    )
