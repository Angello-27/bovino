from fastapi import (
    FastAPI,
    WebSocket,
    WebSocketDisconnect,
    UploadFile,
    File,
    HTTPException,
)
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn
import json
import logging
from typing import List, Dict, Any
import asyncio
from datetime import datetime

from models.bovino_model import BovinoModel
from services.tensorflow_service import TensorFlowService
from services.websocket_manager import WebSocketManager
from config.settings import Settings

# Configuración de logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuración de la aplicación
settings = Settings()
app = FastAPI(title="Bovino IA Server", version="1.0.0")

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
websocket_manager = WebSocketManager()


@app.on_event("startup")
async def startup_event():
    """Inicializar el modelo de TensorFlow al arrancar el servidor"""
    try:
        await tensorflow_service.initialize_model()
        logger.info("✅ Servidor Bovino IA iniciado correctamente")
        logger.info(f"📡 Servidor corriendo en: http://{settings.HOST}:{settings.PORT}")
        logger.info(
            f"🔌 WebSocket disponible en: ws://{settings.HOST}:{settings.PORT}/ws"
        )
    except Exception as e:
        logger.error(f"❌ Error al inicializar el modelo: {e}")
        raise


@app.get("/")
async def root():
    """Endpoint de bienvenida"""
    return {
        "message": "🐄 Bovino IA Server",
        "version": "1.0.0",
        "status": "running",
        "endpoints": {
            "analyze_frame": "/analyze-frame",
            "health": "/health",
            "websocket": "/ws",
        },
    }


@app.get("/health")
async def health_check():
    """Verificar el estado del servidor y el modelo"""
    try:
        model_status = tensorflow_service.is_model_ready()
        return {
            "status": "healthy",
            "timestamp": datetime.now().isoformat(),
            "model_ready": model_status,
            "active_connections": len(websocket_manager.active_connections),
        }
    except Exception as e:
        logger.error(f"Error en health check: {e}")
        raise HTTPException(status_code=500, detail="Servidor no saludable")


@app.post("/analyze-frame")
async def analyze_frame(file: UploadFile = File(...)):
    """
    Analizar un frame de ganado bovino y retornar información detallada

    Args:
        file: Imagen del frame a analizar

    Returns:
        JSON con información del bovino incluyendo raza, características y peso estimado
    """
    try:
        logger.info(f"📸 Analizando frame: {file.filename}")

        # Validar tipo de archivo
        if not file.content_type.startswith("image/"):
            raise HTTPException(
                status_code=400, detail="El archivo debe ser una imagen"
            )

        # Leer y procesar la imagen
        image_data = await file.read()

        # Analizar con TensorFlow
        bovino_result = await tensorflow_service.analyze_bovino(image_data)

        logger.info(
            f"✅ Análisis completado - Raza: {bovino_result.raza}, Peso: {bovino_result.peso_estimado} kg"
        )

        # Notificar a todos los clientes WebSocket conectados
        await websocket_manager.broadcast_analysis_result(bovino_result)

        return bovino_result.dict()

    except Exception as e:
        logger.error(f"❌ Error al analizar frame: {e}")
        raise HTTPException(status_code=500, detail=f"Error en el análisis: {str(e)}")


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """Endpoint WebSocket para notificaciones en tiempo real"""
    await websocket_manager.connect(websocket)
    try:
        logger.info("🔌 Nueva conexión WebSocket establecida")

        # Enviar mensaje de bienvenida
        await websocket.send_text(
            json.dumps(
                {
                    "type": "connection",
                    "message": "Conexión establecida con Bovino IA Server",
                    "timestamp": datetime.now().isoformat(),
                }
            )
        )

        # Mantener la conexión activa
        while True:
            try:
                # Esperar mensajes del cliente (opcional)
                data = await websocket.receive_text()
                message = json.loads(data)

                logger.info(f"📨 Mensaje recibido: {message}")

                # Procesar mensajes si es necesario
                if message.get("type") == "ping":
                    await websocket.send_text(
                        json.dumps(
                            {"type": "pong", "timestamp": datetime.now().isoformat()}
                        )
                    )

            except WebSocketDisconnect:
                logger.info("🔌 Cliente WebSocket desconectado")
                break
            except Exception as e:
                logger.error(f"Error en WebSocket: {e}")
                break

    except Exception as e:
        logger.error(f"Error en conexión WebSocket: {e}")
    finally:
        websocket_manager.disconnect(websocket)
        logger.info("🔌 Conexión WebSocket cerrada")


@app.get("/stats")
async def get_stats():
    """Obtener estadísticas del servidor"""
    return {
        "active_connections": len(websocket_manager.active_connections),
        "total_analyses": tensorflow_service.get_total_analyses(),
        "model_accuracy": tensorflow_service.get_model_accuracy(),
        "uptime": tensorflow_service.get_uptime(),
    }


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
        log_level="info",
    )
