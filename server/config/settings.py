import os
from dotenv import load_dotenv

load_dotenv()


class Settings:
    """Configuración del servidor Bovino IA"""

    # Configuración del servidor
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))
    DEBUG: bool = os.getenv("DEBUG", "True").lower() == "true"

    # Configuración del modelo
    MODEL_PATH: str = os.getenv("MODEL_PATH", "models/bovino_model.h5")
    LABELS_PATH: str = os.getenv("LABELS_PATH", "models/class_labels.json")

    # Configuración de imágenes
    IMAGE_SIZE: int = int(os.getenv("IMAGE_SIZE", "224"))
    BATCH_SIZE: int = int(os.getenv("BATCH_SIZE", "32"))

    # Configuración de peso estimado
    MIN_WEIGHT: float = float(os.getenv("MIN_WEIGHT", "200.0"))
    MAX_WEIGHT: float = float(os.getenv("MAX_WEIGHT", "1200.0"))

    # Configuración de logging
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    LOG_FORMAT: str = os.getenv(
        "LOG_FORMAT", 
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )

    # Configuración de CORS
    ALLOWED_ORIGINS: list = os.getenv("ALLOWED_ORIGINS", "*").split(",")

    # Configuración de cola de análisis
    MAX_QUEUE_SIZE: int = int(os.getenv("MAX_QUEUE_SIZE", "100"))
    FRAME_TIMEOUT_HOURS: int = int(os.getenv("FRAME_TIMEOUT_HOURS", "1"))

    # Configuración de razas bovinas (datos estáticos del dominio)
    BOVINE_BREEDS = [
        "Ayrshire",
        "Brown Swiss",
        "Holstein",
        "Jersey",
        "Red Dane",
    ]

    # Características por raza (datos estáticos del dominio)
    BREED_CHARACTERISTICS = {
        "Ayrshire": ['Rojo y blanco', 'Mediana', 'Lechera', 'Resistente'],
        "Brown Swiss": ['Marrón', 'Grande', 'Lechera', 'Gentil'],
        "Holstein": ['Blanco y negro', 'Grande', 'Lechera', 'Alta producción'],
        "Jersey": ['Marrón claro', 'Pequeña', 'Lechera', 'Alta grasa'],
        "Red Dane": ['Rojo', 'Grande', 'Lechera', 'Europeo'],
    }

    # Pesos promedio por raza (datos estáticos del dominio)
    BREED_AVERAGE_WEIGHTS = {
        "Ayrshire": 550.0,
        "Brown Swiss": 650.0,
        "Holstein": 750.0,
        "Jersey": 450.0,
        "Red Dane": 700.0,
    }
