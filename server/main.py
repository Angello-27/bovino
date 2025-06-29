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

from models.api_models import BovinoModel, BovinoAnalysisRequest, BovinoAnalysisResponse
from services.tensorflow_service import TensorFlowService
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

# Inicializar servicios
tensorflow_service = TensorFlowService()

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
    print("🚀 Iniciando servidor Bovino IA...")
    print(f"📍 Servidor en: http://{settings.HOST}:{settings.PORT}")
    print(f"📊 Tamaño de imagen: {settings.IMAGE_SIZE}x{settings.IMAGE_SIZE}")
    print(f"⚖️ Rango de peso: {settings.MIN_WEIGHT}-{settings.MAX_WEIGHT} kg")
    try:
        await tensorflow_service.initialize_model()
        logger.info("✅ Servidor Bovino IA iniciado correctamente")
        logger.info(f"📡 Servidor corriendo en: http://{settings.HOST}:{settings.PORT}")
    except Exception as e:
        logger.error(f"❌ Error al inicializar el modelo: {e}")
        raise

@app.get("/", response_model=dict)
async def root():
    """Información del servidor"""
    return {
        "message": "🐄 Bovino IA Server v2.0",
        "version": "2.0.0",
        "status": "running",
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
            "Identificación de razas"
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
    file: UploadFile = File(...)
):
    """
    Enviar frame para análisis asíncrono
    
    - Genera ID único para el frame
    - Guarda el frame en cola
    - Inicia procesamiento en background
    - Retorna ID para consulta posterior
    """
    try:
        # Validar archivo
        if not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="Archivo debe ser una imagen")
        
        # Generar ID único
        frame_id = str(uuid.uuid4())
        timestamp = datetime.now()
        
        # Leer contenido del archivo
        image_content = await file.read()
        
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
        
        # Iniciar procesamiento en background
        background_tasks.add_task(process_frame_async, frame_id)
        
        print(f"📸 Frame {frame_id} enviado para análisis")
        
        return FrameAnalysisResponse(
            frame_id=frame_id,
            status="pending",
            created_at=timestamp,
            updated_at=timestamp
        )
        
    except Exception as e:
        print(f"❌ Error al enviar frame: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")

@app.get("/check-status/{frame_id}", response_model=FrameAnalysisResponse)
async def check_frame_status(frame_id: str):
    """
    Consultar estado de análisis de frame
    
    - Retorna estado actual del procesamiento
    - Si está completo, incluye resultado
    - Si falló, incluye error
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

async def process_frame_async(frame_id: str):
    """
    Procesar frame de forma asíncrona
    
    - Cambia estado a "processing"
    - Ejecuta análisis con TensorFlow
    - Actualiza resultado o error
    - Cambia estado a "completed" o "failed"
    """
    try:
        if frame_id not in analysis_queue:
            return
        
        # Marcar como procesando
        analysis_queue[frame_id]["status"] = "processing"
        analysis_queue[frame_id]["updated_at"] = datetime.now()
        
        print(f"🔍 Procesando frame {frame_id}...")
        
        # Obtener contenido de imagen
        image_content = analysis_queue[frame_id]["image_content"]
        
        # Crear request para análisis
        request = BovinoAnalysisRequest(
            image_data=image_content,
            timestamp=analysis_queue[frame_id]["created_at"]
        )
        
        # Ejecutar análisis
        result = await tensorflow_service.analyze_bovino(request)
        
        # Actualizar resultado
        analysis_queue[frame_id]["result"] = result
        analysis_queue[frame_id]["status"] = "completed"
        analysis_queue[frame_id]["updated_at"] = datetime.now()
        
        print(f"✅ Frame {frame_id} procesado exitosamente")
        
    except Exception as e:
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
    Endpoint legacy para análisis síncrono (mantener compatibilidad)
    """
    try:
        if not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="Archivo debe ser una imagen")
        
        image_content = await file.read()
        request = BovinoAnalysisRequest(
            image_data=image_content,
            timestamp=datetime.now()
        )
        
        result = await tensorflow_service.analyze_bovino(request)
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
    
    return {
        "total_frames": total_frames,
        "pending": pending_frames,
        "processing": processing_frames,
        "completed": completed_frames,
        "failed": failed_frames,
        "server_uptime": "running",
        "model_loaded": tensorflow_service.is_model_loaded()
    }

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=True,
        log_level="info"
    )
