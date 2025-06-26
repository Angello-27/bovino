from fastapi import WebSocket
from typing import List
import json
import logging
from datetime import datetime

from models.bovino_model import BovinoModel

logger = logging.getLogger(__name__)


class WebSocketManager:
    """Gestor de conexiones WebSocket para notificaciones en tiempo real"""

    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        """Conectar un nuevo cliente WebSocket"""
        await websocket.accept()
        self.active_connections.append(websocket)
        logger.info(
            f"🔌 Cliente WebSocket conectado. Total: {len(self.active_connections)}"
        )

    def disconnect(self, websocket: WebSocket):
        """Desconectar un cliente WebSocket"""
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
            logger.info(
                f"🔌 Cliente WebSocket desconectado. Total: {len(self.active_connections)}"
            )

    async def broadcast_analysis_result(self, bovino_result: BovinoModel):
        """Enviar resultado de análisis a todos los clientes conectados"""
        if not self.active_connections:
            return

        message = {
            "type": "analysis_result",
            "data": bovino_result.dict(),
            "timestamp": datetime.now().isoformat(),
        }

        message_json = json.dumps(message)

        # Enviar a todos los clientes conectados
        disconnected_clients = []

        for connection in self.active_connections:
            try:
                await connection.send_text(message_json)
                logger.debug(f"📤 Resultado enviado a cliente WebSocket")
            except Exception as e:
                logger.error(f"Error enviando mensaje WebSocket: {e}")
                disconnected_clients.append(connection)

        # Limpiar conexiones desconectadas
        for client in disconnected_clients:
            self.disconnect(client)

    async def broadcast_message(self, message_type: str, data: dict):
        """Enviar mensaje personalizado a todos los clientes"""
        if not self.active_connections:
            return

        message = {
            "type": message_type,
            "data": data,
            "timestamp": datetime.now().isoformat(),
        }

        message_json = json.dumps(message)

        disconnected_clients = []

        for connection in self.active_connections:
            try:
                await connection.send_text(message_json)
            except Exception as e:
                logger.error(f"Error enviando mensaje WebSocket: {e}")
                disconnected_clients.append(connection)

        # Limpiar conexiones desconectadas
        for client in disconnected_clients:
            self.disconnect(client)

    async def send_personal_message(self, message: str, websocket: WebSocket):
        """Enviar mensaje personalizado a un cliente específico"""
        try:
            await websocket.send_text(message)
        except Exception as e:
            logger.error(f"Error enviando mensaje personalizado: {e}")
            self.disconnect(websocket)

    def get_connection_count(self) -> int:
        """Obtener número de conexiones activas"""
        return len(self.active_connections)
