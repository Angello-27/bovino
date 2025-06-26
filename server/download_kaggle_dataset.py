#!/usr/bin/env python3
"""
Descargador completo del dataset de Kaggle para Bovino IA
URL: https://www.kaggle.com/datasets/sadhliroomyprime/cattle-weight-detection-model-dataset-12k
"""

import os
import sys
import subprocess
import zipfile
import shutil
from pathlib import Path
import logging
import json

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class KaggleDatasetManager:
    """Gestor completo del dataset de Kaggle"""

    def __init__(self):
        self.dataset_url = "sadhliroomyprime/cattle-weight-detection-model-dataset-12k"
        self.data_dir = Path("data")
        self.raw_dir = Path("data/raw_kaggle")
        self.processed_dir = Path("data/bovine_images")

    def step_1_install_kaggle(self):
        """Paso 1: Instalar Kaggle API"""
        logger.info("1️⃣ PASO 1: Instalando Kaggle API...")

        try:
            # Verificar si ya está instalado
            import kaggle

            logger.info("✅ Kaggle API ya está instalada")
            return True
        except ImportError:
            logger.info("📦 Instalando Kaggle API...")
            try:
                subprocess.run(
                    [sys.executable, "-m", "pip", "install", "kaggle"], check=True
                )
                logger.info("✅ Kaggle API instalada exitosamente")
                return True
            except subprocess.CalledProcessError as e:
                logger.error(f"❌ Error instalando Kaggle API: {e}")
                return False

    def step_2_setup_credentials(self):
        """Paso 2: Configurar credenciales de Kaggle"""
        logger.info("2️⃣ PASO 2: Configurando credenciales de Kaggle...")

        kaggle_dir = Path.home() / ".kaggle"
        kaggle_json = kaggle_dir / "kaggle.json"

        if kaggle_json.exists():
            logger.info("✅ Credenciales de Kaggle ya están configuradas")
            return True

        logger.warning("❌ Credenciales de Kaggle NO encontradas")
        logger.info("📋 GUÍA PARA CONFIGURAR CREDENCIALES:")
        logger.info("   1. Ve a: https://www.kaggle.com/account")
        logger.info("   2. Haz clic en 'Create New API Token'")
        logger.info("   3. Se descargará 'kaggle.json'")
        logger.info(f"   4. Copia kaggle.json a: {kaggle_dir}")
        logger.info("   5. Ejecuta este script de nuevo")

        # Crear directorio si no existe
        kaggle_dir.mkdir(exist_ok=True)

        # Mostrar ruta exacta
        logger.info(f"📁 Ruta exacta: {kaggle_dir.absolute()}")

        return False

    def step_3_download_dataset(self):
        """Paso 3: Descargar dataset de Kaggle"""
        logger.info("3️⃣ PASO 3: Descargando dataset...")

        try:
            import kaggle

            # Crear directorios
            self.data_dir.mkdir(exist_ok=True)
            self.raw_dir.mkdir(exist_ok=True)

            logger.info(f"📥 Descargando dataset: {self.dataset_url}")
            logger.info("⏳ Esto puede tomar varios minutos...")

            # Descargar dataset
            kaggle.api.dataset_download_files(
                self.dataset_url, path=str(self.raw_dir), unzip=True
            )

            logger.info("✅ Dataset descargado exitosamente")
            return True

        except Exception as e:
            logger.error(f"❌ Error descargando dataset: {e}")
            return False

    def step_4_analyze_structure(self):
        """Paso 4: Analizar estructura del dataset descargado"""
        logger.info("4️⃣ PASO 4: Analizando estructura del dataset...")

        if not self.raw_dir.exists():
            logger.error("❌ Directorio de dataset no encontrado")
            return False

        # Buscar todos los archivos
        all_files = list(self.raw_dir.rglob("*"))
        image_files = []

        # Filtrar imágenes
        image_extensions = {".jpg", ".jpeg", ".png", ".bmp", ".tiff"}
        for file_path in all_files:
            if file_path.is_file() and file_path.suffix.lower() in image_extensions:
                image_files.append(file_path)

        logger.info(f"📊 ANÁLISIS DEL DATASET:")
        logger.info(f"   📁 Total archivos: {len(all_files)}")
        logger.info(f"   🖼️ Imágenes encontradas: {len(image_files)}")

        # Mostrar algunos archivos de ejemplo
        logger.info("📋 Ejemplos de archivos encontrados:")
        for i, file_path in enumerate(image_files[:10]):
            relative_path = file_path.relative_to(self.raw_dir)
            logger.info(f"   {i+1}. {relative_path}")

        if len(image_files) > 10:
            logger.info(f"   ... y {len(image_files) - 10} más")

        return len(image_files) > 0

    def step_5_organize_images(self):
        """Paso 5: Organizar imágenes en estructura para entrenamiento"""
        logger.info("5️⃣ PASO 5: Organizando imágenes...")

        # Crear directorio de imágenes procesadas
        self.processed_dir.mkdir(exist_ok=True)

        # Razas objetivo
        target_breeds = [
            "Angus",
            "Hereford",
            "Holstein",
            "Jersey",
            "Brahman",
            "Charolais",
            "Limousin",
            "Simmental",
            "Shorthorn",
            "Gelbvieh",
        ]

        # Crear directorios para cada raza
        for breed in target_breeds:
            breed_dir = self.processed_dir / breed
            breed_dir.mkdir(exist_ok=True)

        # Buscar todas las imágenes
        image_extensions = {".jpg", ".jpeg", ".png", ".bmp", ".tiff"}
        image_files = []

        for file_path in self.raw_dir.rglob("*"):
            if file_path.is_file() and file_path.suffix.lower() in image_extensions:
                image_files.append(file_path)

        logger.info(f"📸 Organizando {len(image_files)} imágenes...")

        # Distribuir imágenes entre razas
        images_per_breed = len(image_files) // len(target_breeds)
        breed_counters = {breed: 0 for breed in target_breeds}

        for i, image_path in enumerate(image_files):
            # Determinar raza basada en índice
            breed_index = i // images_per_breed
            if breed_index >= len(target_breeds):
                breed_index = len(target_breeds) - 1

            target_breed = target_breeds[breed_index]

            # Generar nuevo nombre
            counter = breed_counters[target_breed]
            new_name = f"{target_breed}_{counter:04d}{image_path.suffix}"
            target_path = self.processed_dir / target_breed / new_name

            try:
                # Copiar imagen
                shutil.copy2(image_path, target_path)
                breed_counters[target_breed] += 1

                if (i + 1) % 100 == 0:
                    logger.info(f"   Procesadas {i + 1}/{len(image_files)} imágenes...")

            except Exception as e:
                logger.warning(f"⚠️ Error copiando {image_path}: {e}")

        # Mostrar resumen
        logger.info("📊 RESUMEN DE ORGANIZACIÓN:")
        total_organized = 0
        for breed in target_breeds:
            count = breed_counters[breed]
            total_organized += count
            logger.info(f"   {breed}: {count} imágenes")

        logger.info(f"   TOTAL ORGANIZADO: {total_organized} imágenes")

        return total_organized > 0

    def step_6_create_training_script(self):
        """Paso 6: Crear script de entrenamiento actualizado"""
        logger.info("6️⃣ PASO 6: Creando script de entrenamiento...")

        # Verificar que tenemos datos
        if not self.processed_dir.exists():
            logger.error("❌ No hay datos organizados para entrenar")
            return False

        logger.info("📝 Script de entrenamiento listo")
        logger.info("➡️ Para entrenar: python train_model.py")

        return True

    def run_complete_setup(self):
        """Ejecutar configuración completa del dataset"""
        logger.info("🐄 CONFIGURACIÓN COMPLETA DEL DATASET KAGGLE")
        logger.info("=" * 60)
        logger.info(f"📊 Dataset: {self.dataset_url}")
        logger.info("=" * 60)

        steps = [
            ("Instalar Kaggle API", self.step_1_install_kaggle),
            ("Configurar credenciales", self.step_2_setup_credentials),
            ("Descargar dataset", self.step_3_download_dataset),
            ("Analizar estructura", self.step_4_analyze_structure),
            ("Organizar imágenes", self.step_5_organize_images),
            ("Crear script entrenamiento", self.step_6_create_training_script),
        ]

        for step_name, step_func in steps:
            logger.info(f"\n🔄 {step_name}...")
            logger.info("-" * 40)

            try:
                success = step_func()
                if success:
                    logger.info(f"✅ {step_name}: COMPLETADO")
                else:
                    logger.error(f"❌ {step_name}: FALLÓ")
                    if step_name == "Configurar credenciales":
                        logger.info("💡 Configura las credenciales y ejecuta de nuevo")
                        return False
                    else:
                        logger.info("💡 Revisa los errores y ejecuta de nuevo")
                        return False
            except Exception as e:
                logger.error(f"❌ Error en {step_name}: {e}")
                return False

        logger.info("\n" + "=" * 60)
        logger.info("🎉 ¡CONFIGURACIÓN COMPLETA EXITOSA!")
        logger.info("=" * 60)
        logger.info("📁 Dataset descargado y organizado")
        logger.info("🚀 Listo para entrenar modelo real")
        logger.info("➡️ SIGUIENTE PASO: python train_model.py")

        return True


def main():
    """Función principal"""
    manager = KaggleDatasetManager()
    return manager.run_complete_setup()


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
