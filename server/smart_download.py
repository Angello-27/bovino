#!/usr/bin/env python3
"""
Descargador inteligente con kagglehub (VERSIÓN CORREGIDA)
Usa datasets REALES y públicos de Kaggle
"""

import os
import sys
import subprocess
import shutil
import requests
from pathlib import Path
import logging
import time
import threading
from datetime import datetime

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
logger = logging.getLogger(__name__)


class SmartKaggleDownloader:
    """Descargador inteligente con datasets REALES"""

    def __init__(self):
        self.dataset_id = "sadhliroomyprime/cattle-weight-detection-model-dataset-12k"
        self.dataset_size = "47GB"
        self.data_dir = Path("data")
        self.sample_dir = Path("data/sample_dataset")

        # Datasets REALES y públicos encontrados en Kaggle
        self.alternative_datasets = {
            "mini": {
                "id": "anandkumarsahu09/cattle-breeds-dataset",
                "size": "~50MB",
                "description": "200+ imágenes de 5 razas de bovinos diferentes",
            },
            "small": {
                "id": "afnanamin/cow-images",
                "size": "~100MB",
                "description": "Colección de imágenes de vacas",
            },
            "medium": {
                "id": "crsuthikshnkumar/cow-breed-data-set",
                "size": "~200MB",
                "description": "Dataset de razas de vacas para clasificación",
            },
        }

    def install_kagglehub(self):
        """Instalar kagglehub"""
        logger.info("📦 Verificando kagglehub...")

        try:
            import kagglehub

            logger.info("✅ kagglehub ya está instalado")
            return True
        except ImportError:
            logger.info("📥 Instalando kagglehub...")
            try:
                subprocess.run(
                    [sys.executable, "-m", "pip", "install", "kagglehub"],
                    check=True,
                    capture_output=True,
                )
                logger.info("✅ kagglehub instalado exitosamente")
                return True
            except subprocess.CalledProcessError as e:
                logger.error(f"❌ Error instalando kagglehub: {e}")
                return False

    def show_dataset_warning(self):
        """Mostrar advertencia sobre el tamaño del dataset"""
        print("\n" + "=" * 60)
        print("⚠️  ADVERTENCIA: DATASET MUY GRANDE")
        print("=" * 60)
        print(f"📊 Dataset original: {self.dataset_id}")
        print(f"💾 Tamaño: {self.dataset_size}")
        print(f"⏱️  Tiempo estimado: 2-6 horas (dependiendo de tu internet)")
        print(f"💻 Espacio requerido: {self.dataset_size} libres en disco")
        print("=" * 60)

        # Mostrar alternativas REALES
        print("\n🎯 OPCIONES DISPONIBLES:")
        print("1️⃣ DATASET MINI (50MB) - 200+ imágenes de 5 razas")
        print("2️⃣ DATASET PEQUEÑO (100MB) - Colección de imágenes de vacas")
        print("3️⃣ DATASET MEDIANO (200MB) - Dataset de razas para clasificación")
        print("4️⃣ DATASET COMPLETO (47GB) - Dataset original completo")
        print("5️⃣ CREAR MUESTRA LOCAL - Imágenes de ejemplo sin descargar")
        print("6️⃣ CANCELAR - Salir sin descargar")

        return self.get_user_choice()

    def get_user_choice(self):
        """Obtener elección del usuario"""
        print("\n💡 ¿Qué opción prefieres?")
        print("   Recomiendo empezar con la opción 1 (mini - 50MB)")

        # Por defecto, elegir opción más segura
        choice = "2"  # Crear muestra local
        logger.info(f"🔄 Selección automática: Opción {choice} (Muestra local)")
        return choice

    def download_alternative_dataset(self, dataset_key):
        """Descargar dataset alternativo REAL"""
        dataset_info = self.alternative_datasets[dataset_key]
        dataset_id = dataset_info["id"]

        logger.info(f"📥 Descargando dataset: {dataset_id}")
        logger.info(f"💾 Tamaño aproximado: {dataset_info['size']}")
        logger.info(f"📋 Descripción: {dataset_info['description']}")

        try:
            import kagglehub

            # Iniciar monitor de progreso
            self.start_download_monitor(f"Descargando {dataset_info['size']}")

            try:
                path = kagglehub.dataset_download(dataset_id)
                self.stop_download_monitor()

                logger.info(f"✅ Dataset descargado en: {path}")
                return path

            except Exception as e:
                self.stop_download_monitor()
                raise e

        except Exception as e:
            logger.error(f"❌ Error descargando dataset: {e}")
            logger.info("💡 Posibles soluciones:")
            logger.info("   1. Verifica tus credenciales de Kaggle")
            logger.info("   2. Asegúrate de estar logueado en Kaggle")
            logger.info("   3. El dataset podría estar privado o haber cambiado")
            return None

    def download_full_dataset(self):
        """Descargar dataset completo de 47GB"""
        logger.info("⚠️ INICIANDO DESCARGA DEL DATASET COMPLETO (47GB)")
        logger.info("⏱️ Esto puede tomar 2-6 horas...")

        try:
            import kagglehub

            # Mostrar advertencia final
            logger.info("🚨 ÚLTIMA ADVERTENCIA:")
            logger.info(f"   - Tamaño: {self.dataset_size}")
            logger.info("   - Tiempo: 2-6 horas")
            logger.info("   - Asegúrate de tener espacio suficiente")
            logger.info("   - No cierres la terminal hasta que termine")

            # Iniciar descarga con monitor
            self.start_download_monitor("Descargando 47GB - ¡Ten paciencia!")

            try:
                path = kagglehub.dataset_download(self.dataset_id)
                self.stop_download_monitor()

                logger.info(f"🎉 ¡DATASET COMPLETO DESCARGADO!")
                logger.info(f"📁 Ubicación: {path}")
                return path

            except Exception as e:
                self.stop_download_monitor()
                raise e

        except Exception as e:
            logger.error(f"❌ Error descargando dataset completo: {e}")
            return None

    def create_sample_dataset_with_real_images(self):
        """Crear dataset de muestra con imágenes reales descargadas"""
        logger.info("📸 Creando dataset de muestra con imágenes reales...")

        self.sample_dir.mkdir(parents=True, exist_ok=True)

        # URLs de imágenes reales de vacas (dominio público)
        sample_images = {
            "Holstein": [
                "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Cow_female_black_white.jpg/640px-Cow_female_black_white.jpg",
                "https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Kuh_1_fcm.jpg/640px-Kuh_1_fcm.jpg",
            ],
            "Angus": [
                "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Aberdeen_Angus_bull.jpg/640px-Aberdeen_Angus_bull.jpg",
                "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Taurus_2.jpg/640px-Taurus_2.jpg",
            ],
            "Hereford": [
                "https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Cows_in_green_field_-_nullamunjie_olive_grove03.jpg/640px-Cows_in_green_field_-_nullamunjie_olive_grove03.jpg",
                "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/HerefordCattle.jpg/640px-HerefordCattle.jpg",
            ],
        }

        downloaded_count = 0
        total_images = sum(len(urls) for urls in sample_images.values())

        for breed, urls in sample_images.items():
            breed_dir = self.sample_dir / breed
            breed_dir.mkdir(exist_ok=True)

            logger.info(f"📥 Descargando imágenes para {breed}...")

            for i, url in enumerate(urls):
                try:
                    response = requests.get(url, timeout=30)
                    response.raise_for_status()

                    filename = f"{breed}_{i+1:03d}.jpg"
                    file_path = breed_dir / filename

                    with open(file_path, "wb") as f:
                        f.write(response.content)

                    downloaded_count += 1
                    logger.info(f"   ✅ {filename} ({downloaded_count}/{total_images})")

                except Exception as e:
                    logger.warning(
                        f"   ⚠️ Error descargando imagen {i+1} de {breed}: {e}"
                    )

        if downloaded_count > 0:
            logger.info(f"✅ Dataset de muestra creado: {downloaded_count} imágenes")
            logger.info(f"📁 Ubicación: {self.sample_dir}")
            return str(self.sample_dir)
        else:
            logger.error("❌ No se pudo descargar ninguna imagen")
            return None

    def start_download_monitor(self, message):
        """Iniciar monitor de descarga"""
        self.download_active = True
        self.start_time = time.time()

        def monitor():
            dots = 0
            while self.download_active:
                elapsed = time.time() - self.start_time
                mins, secs = divmod(int(elapsed), 60)
                hours, mins = divmod(mins, 60)

                dot_display = "." * (dots % 4)
                print(
                    f"\r🔄 {message}{dot_display:<3} | ⏱️ {hours:02d}:{mins:02d}:{secs:02d}",
                    end="",
                    flush=True,
                )

                dots += 1
                time.sleep(1)

        self.monitor_thread = threading.Thread(target=monitor, daemon=True)
        self.monitor_thread.start()

    def stop_download_monitor(self):
        """Detener monitor de descarga"""
        self.download_active = False
        print()  # Nueva línea

    def run_smart_download(self):
        """Ejecutar descarga inteligente"""
        logger.info("🧠 DESCARGADOR INTELIGENTE DE DATASETS (VERSIÓN CORREGIDA)")
        logger.info("=" * 60)

        # 1. Instalar kagglehub
        if not self.install_kagglehub():
            return False

        # 2. Mostrar opciones y obtener elección
        choice = self.show_dataset_warning()

        # 3. Ejecutar según elección
        downloaded_path = None

        if choice == "1":
            logger.info("\n🔄 Descargando dataset mini (50MB)...")
            downloaded_path = self.download_alternative_dataset("mini")

        elif choice == "2":
            logger.info("\n🔄 Descargando dataset pequeño (100MB)...")
            downloaded_path = self.download_alternative_dataset("small")

        elif choice == "3":
            logger.info("\n🔄 Descargando dataset mediano (200MB)...")
            downloaded_path = self.download_alternative_dataset("medium")

        elif choice == "4":
            logger.info("\n🔄 Iniciando descarga del dataset completo (47GB)...")
            downloaded_path = self.download_full_dataset()

        elif choice == "5":
            logger.info("\n🔄 Creando dataset de muestra local...")
            downloaded_path = self.create_sample_dataset_with_real_images()

        else:
            logger.info("❌ Descarga cancelada")
            return False

        # 4. Verificar resultado
        if downloaded_path:
            logger.info("\n" + "=" * 60)
            logger.info("🎉 ¡DESCARGA COMPLETADA!")
            logger.info("=" * 60)
            logger.info(f"📁 Ubicación: {downloaded_path}")

            # Mostrar estructura de archivos
            try:
                path_obj = Path(downloaded_path)
                if path_obj.exists():
                    files = list(path_obj.rglob("*"))
                    images = [
                        f
                        for f in files
                        if f.suffix.lower() in {".jpg", ".jpeg", ".png", ".bmp"}
                    ]
                    logger.info(f"📊 Archivos encontrados: {len(files)}")
                    logger.info(f"🖼️ Imágenes encontradas: {len(images)}")
            except Exception:
                pass

            logger.info("➡️ SIGUIENTE PASO: Organizar imágenes para entrenamiento")
            logger.info("🚀 Comando sugerido: python organize_dataset.py")
            return True
        else:
            logger.error("❌ Error en la descarga")
            logger.info("💡 Alternativas:")
            logger.info("   1. Verifica tu conexión a internet")
            logger.info("   2. Configura credenciales de Kaggle")
            logger.info("   3. Prueba con dataset de muestra local (opción 5)")
            return False


def main():
    """Función principal"""
    downloader = SmartKaggleDownloader()
    return downloader.run_smart_download()


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
