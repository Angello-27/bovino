#!/usr/bin/env python3
"""
Ejemplo práctico de uso del servidor Bovino IA
Para principiantes que quieren entender cómo funciona
"""

import requests
import json
import time
from PIL import Image
import numpy as np
import io


class BovinoIAExample:
    """Ejemplo de uso del servidor Bovino IA"""

    def __init__(self, server_url="http://192.168.0.8:8000"):
        self.server_url = server_url
        self.session = requests.Session()

    def check_server_status(self):
        """Verificar si el servidor está funcionando"""
        print("🔍 Verificando estado del servidor...")

        try:
            response = self.session.get(f"{self.server_url}/")
            response.raise_for_status()

            data = response.json()
            print(f"✅ Servidor: {data['message']}")
            print(f"📋 Versión: {data['version']}")
            print(f"🟢 Estado: {data['status']}")

            return True

        except requests.exceptions.RequestException as e:
            print(f"❌ Error conectando al servidor: {e}")
            print(
                "💡 Asegúrate de que el servidor esté ejecutándose con: python main.py"
            )
            return False

    def check_health(self):
        """Verificar salud del servidor y modelo"""
        print("\n🏥 Verificando salud del servidor...")

        try:
            response = self.session.get(f"{self.server_url}/health")
            response.raise_for_status()

            data = response.json()
            print(f"✅ Estado: {data['status']}")
            print(f"🤖 Modelo listo: {data['model_ready']}")
            print(f"🔌 Conexiones activas: {data['active_connections']}")

            return data["model_ready"]

        except requests.exceptions.RequestException as e:
            print(f"❌ Error en health check: {e}")
            return False

    def create_sample_image(self, breed="Angus"):
        """Crear imagen de ejemplo que simule un bovino"""
        print(f"\n🖼️ Creando imagen de ejemplo para raza: {breed}")

        # Crear imagen con colores que simulen un bovino
        if breed == "Angus":
            # Negro para Angus
            color = (50, 50, 50)
        elif breed == "Hereford":
            # Rojo y blanco para Hereford
            color = (150, 100, 100)
        elif breed == "Holstein":
            # Blanco y negro para Holstein
            color = (200, 200, 200)
        else:
            # Marrón genérico
            color = (139, 69, 19)

        # Crear imagen 224x224
        image_array = np.full((224, 224, 3), color, dtype=np.uint8)

        # Agregar algo de variación para simular textura
        noise = np.random.randint(-20, 20, (224, 224, 3), dtype=np.int16)
        image_array = np.clip(image_array.astype(np.int16) + noise, 0, 255).astype(
            np.uint8
        )

        # Convertir a imagen PIL
        image = Image.fromarray(image_array)

        # Guardar en buffer
        buffer = io.BytesIO()
        image.save(buffer, format="JPEG", quality=85)
        buffer.seek(0)

        print(f"✅ Imagen creada: {image_array.shape}")
        return buffer

    def analyze_bovino(self, image_buffer, description="bovino de ejemplo"):
        """Analizar imagen de bovino"""
        print(f"\n📸 Analizando {description}...")

        try:
            # Preparar archivo para envío
            files = {"file": ("bovino.jpg", image_buffer, "image/jpeg")}

            # Enviar request
            response = self.session.post(
                f"{self.server_url}/analyze-frame", files=files
            )
            response.raise_for_status()

            data = response.json()

            print("✅ Análisis completado!")
            print(f"🐄 Raza identificada: {data['raza']}")
            print(
                f"🎯 Confianza: {data['confianza']:.2f} ({data['confianza']*100:.1f}%)"
            )
            print(f"⚖️ Peso estimado: {data['peso_estimado']} kg")
            print(f"📝 Características: {', '.join(data['caracteristicas'])}")
            print(f"🕐 Timestamp: {data['timestamp']}")

            return data

        except requests.exceptions.RequestException as e:
            print(f"❌ Error en análisis: {e}")
            return None

    def get_server_stats(self):
        """Obtener estadísticas del servidor"""
        print("\n📊 Obteniendo estadísticas del servidor...")

        try:
            response = self.session.get(f"{self.server_url}/stats")
            response.raise_for_status()

            data = response.json()
            print("✅ Estadísticas obtenidas:")
            print(f"   🔌 Conexiones activas: {data['active_connections']}")
            print(f"   📈 Total de análisis: {data['total_analyses']}")
            print(f"   🎯 Precisión del modelo: {data['model_accuracy']:.2f}")
            print(f"   ⏱️ Tiempo de funcionamiento: {data['uptime']}")

            return data

        except requests.exceptions.RequestException as e:
            print(f"❌ Error obteniendo estadísticas: {e}")
            return None

    def run_demo(self):
        """Ejecutar demostración completa"""
        print("🐄 DEMOSTRACIÓN: Servidor Bovino IA")
        print("=" * 50)

        # 1. Verificar servidor
        if not self.check_server_status():
            return False

        # 2. Verificar salud
        if not self.check_health():
            print("⚠️ El modelo no está listo. Espera un momento...")
            time.sleep(2)

        # 3. Analizar diferentes razas
        breeds_to_test = ["Angus", "Hereford", "Holstein", "Jersey"]

        for breed in breeds_to_test:
            # Crear imagen de ejemplo
            image_buffer = self.create_sample_image(breed)

            # Analizar
            result = self.analyze_bovino(image_buffer, f"bovino {breed}")

            if result:
                # Verificar si la predicción es correcta
                predicted_breed = result["raza"]
                if predicted_breed == breed:
                    print(f"🎯 ¡Predicción correcta! ({breed})")
                else:
                    print(f"⚠️ Predicción: {predicted_breed} (esperado: {breed})")

            # Pausa entre análisis
            time.sleep(1)

        # 4. Obtener estadísticas finales
        self.get_server_stats()

        print("\n" + "=" * 50)
        print("🎉 ¡Demostración completada!")
        print("💡 Ahora puedes usar tu app Flutter para conectarte al servidor")

        return True


def main():
    """Función principal"""
    print("🐄 Ejemplo de uso del servidor Bovino IA")
    print("=" * 50)

    # Crear instancia del ejemplo
    example = BovinoIAExample()

    # Ejecutar demostración
    success = example.run_demo()

    if success:
        print("\n🚀 ¡Todo funcionando correctamente!")
        print("📱 Tu servidor está listo para conectar con Flutter")
    else:
        print("\n❌ Hay problemas con el servidor")
        print("💡 Verifica que el servidor esté ejecutándose")

    return success


if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
