#!/usr/bin/env python3
"""
Script de pruebas para el servidor Bovino IA
"""

import requests
import json
import time
import logging
from pathlib import Path
import asyncio
import websockets
from PIL import Image
import numpy as np
import io

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class BovinoServerTester:
    """Clase para probar el servidor Bovino IA"""

    def __init__(self, base_url="http://192.168.0.8:8000"):
        self.base_url = base_url
        self.websocket_url = base_url.replace("http", "ws") + "/ws"

    def test_server_info(self):
        """Probar endpoint de información del servidor"""
        logger.info("🔍 Probando información del servidor...")

        try:
            response = requests.get(f"{self.base_url}/")
            response.raise_for_status()

            data = response.json()
            logger.info(f"✅ Servidor respondió: {data['message']}")
            logger.info(f"📋 Versión: {data['version']}")
            logger.info(f"🟢 Estado: {data['status']}")

            return True

        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Error conectando al servidor: {e}")
            return False

    def test_health_check(self):
        """Probar endpoint de salud"""
        logger.info("🏥 Probando health check...")

        try:
            response = requests.get(f"{self.base_url}/health")
            response.raise_for_status()

            data = response.json()
            logger.info(f"✅ Estado: {data['status']}")
            logger.info(f"🤖 Modelo listo: {data['model_ready']}")
            logger.info(f"🔌 Conexiones activas: {data['active_connections']}")

            return data["status"] == "healthy"

        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Error en health check: {e}")
            return False

    def create_test_image(self, size=(224, 224)):
        """Crear imagen de prueba"""
        # Crear imagen aleatoria que simule un bovino
        image_array = np.random.randint(0, 255, (size[0], size[1], 3), dtype=np.uint8)

        # Convertir a imagen PIL
        image = Image.fromarray(image_array)

        # Guardar en buffer
        buffer = io.BytesIO()
        image.save(buffer, format="JPEG")
        buffer.seek(0)

        return buffer

    def test_analyze_frame(self):
        """Probar análisis de frame"""
        logger.info("📸 Probando análisis de frame...")

        try:
            # Crear imagen de prueba
            test_image = self.create_test_image()

            # Preparar archivo para envío
            files = {"file": ("test_bovino.jpg", test_image, "image/jpeg")}

            # Enviar request
            response = requests.post(f"{self.base_url}/analyze-frame", files=files)
            response.raise_for_status()

            data = response.json()
            logger.info(f"✅ Análisis completado")
            logger.info(f"🐄 Raza identificada: {data['raza']}")
            logger.info(f"🎯 Confianza: {data['confianza']:.2f}")
            logger.info(f"⚖️ Peso estimado: {data['peso_estimado']} kg")
            logger.info(f"📝 Características: {', '.join(data['caracteristicas'])}")

            return True

        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Error en análisis de frame: {e}")
            return False

    def test_stats(self):
        """Probar endpoint de estadísticas"""
        logger.info("📊 Probando estadísticas...")

        try:
            response = requests.get(f"{self.base_url}/stats")
            response.raise_for_status()

            data = response.json()
            logger.info(f"✅ Estadísticas obtenidas")
            logger.info(f"🔌 Conexiones activas: {data['active_connections']}")
            logger.info(f"📈 Total de análisis: {data['total_analyses']}")
            logger.info(f"🎯 Precisión del modelo: {data['model_accuracy']:.2f}")
            logger.info(f"⏱️ Tiempo de funcionamiento: {data['uptime']}")

            return True

        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Error obteniendo estadísticas: {e}")
            return False

    async def test_websocket(self):
        """Probar conexión WebSocket"""
        logger.info("🔌 Probando WebSocket...")

        try:
            async with websockets.connect(self.websocket_url) as websocket:
                logger.info("✅ Conexión WebSocket establecida")

                # Enviar mensaje de prueba
                test_message = {"type": "ping", "message": "test"}
                await websocket.send(json.dumps(test_message))
                logger.info("📤 Mensaje enviado")

                # Esperar respuesta
                response = await asyncio.wait_for(websocket.recv(), timeout=5.0)
                data = json.loads(response)

                logger.info(f"📥 Respuesta recibida: {data}")

                return True

        except Exception as e:
            logger.error(f"❌ Error en WebSocket: {e}")
            return False

    def run_all_tests(self):
        """Ejecutar todas las pruebas"""
        logger.info("🧪 Iniciando pruebas del servidor Bovino IA")
        logger.info("=" * 50)

        tests = [
            ("Información del servidor", self.test_server_info),
            ("Health check", self.test_health_check),
            ("Análisis de frame", self.test_analyze_frame),
            ("Estadísticas", self.test_stats),
        ]

        results = []

        for test_name, test_func in tests:
            logger.info(f"\n🔍 {test_name}")
            logger.info("-" * 30)

            try:
                result = test_func()
                results.append((test_name, result))

                if result:
                    logger.info(f"✅ {test_name}: PASÓ")
                else:
                    logger.info(f"❌ {test_name}: FALLÓ")

            except Exception as e:
                logger.error(f"❌ {test_name}: ERROR - {e}")
                results.append((test_name, False))

        # Probar WebSocket
        logger.info(f"\n🔍 WebSocket")
        logger.info("-" * 30)

        try:
            websocket_result = asyncio.run(self.test_websocket())
            results.append(("WebSocket", websocket_result))

            if websocket_result:
                logger.info("✅ WebSocket: PASÓ")
            else:
                logger.info("❌ WebSocket: FALLÓ")

        except Exception as e:
            logger.error(f"❌ WebSocket: ERROR - {e}")
            results.append(("WebSocket", False))

        # Resumen
        logger.info("\n" + "=" * 50)
        logger.info("📋 RESUMEN DE PRUEBAS")
        logger.info("=" * 50)

        passed = sum(1 for _, result in results if result)
        total = len(results)

        for test_name, result in results:
            status = "✅ PASÓ" if result else "❌ FALLÓ"
            logger.info(f"{test_name}: {status}")

        logger.info(f"\n🎯 Resultado: {passed}/{total} pruebas pasaron")

        if passed == total:
            logger.info(
                "🎉 ¡Todas las pruebas pasaron! El servidor está funcionando correctamente."
            )
        else:
            logger.warning(
                "⚠️ Algunas pruebas fallaron. Revisa la configuración del servidor."
            )

        return passed == total


def main():
    """Función principal"""
    logger.info("🐄 Probador del Servidor Bovino IA")
    logger.info("=" * 50)

    # Crear tester
    tester = BovinoServerTester()

    # Ejecutar pruebas
    success = tester.run_all_tests()

    if success:
        logger.info("\n🚀 El servidor está listo para usar con Flutter!")
        logger.info("📱 Configura tu app Flutter para conectarse a:")
        logger.info(f"   HTTP: {tester.base_url}")
        logger.info(f"   WebSocket: {tester.websocket_url}")
    else:
        logger.error("\n❌ Hay problemas con el servidor. Revisa los logs.")

    return success


if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
