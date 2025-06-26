import os
from dotenv import load_dotenv

load_dotenv()


class Settings:
    """Configuración del servidor Bovino IA"""

    # Configuración del servidor
    HOST: str = os.getenv("HOST", "192.168.0.8")
    PORT: int = int(os.getenv("PORT", "8000"))
    DEBUG: bool = os.getenv("DEBUG", "True").lower() == "true"

    # Configuración del modelo
    MODEL_PATH: str = os.getenv("MODEL_PATH", "models/bovino_model.h5")
    LABELS_PATH: str = os.getenv("LABELS_PATH", "models/class_labels.json")

    # Configuración de imágenes
    IMAGE_SIZE: int = int(os.getenv("IMAGE_SIZE", "224"))
    BATCH_SIZE: int = int(os.getenv("BATCH_SIZE", "32"))

    # Configuración de peso estimado
    MIN_WEIGHT: float = float(os.getenv("MIN_WEIGHT", "200.0"))  # kg
    MAX_WEIGHT: float = float(os.getenv("MAX_WEIGHT", "1200.0"))  # kg

    # Configuración de razas bovinas
    BOVINE_BREEDS = [
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

    # Características por raza
    BREED_CHARACTERISTICS = {
        "Angus": ["Negro", "Sin cuernos", "Musculoso", "Adaptable"],
        "Hereford": ["Rojo y blanco", "Cuernos cortos", "Rustico", "Buen temperamento"],
        "Holstein": ["Blanco y negro", "Grande", "Lechera", "Alta producción"],
        "Jersey": ["Marrón claro", "Pequeña", "Lechera", "Alta grasa"],
        "Brahman": ["Gris", "Joroba", "Resistente al calor", "Cuernos largos"],
        "Charolais": ["Blanco", "Grande", "Musculoso", "Cárnico"],
        "Limousin": ["Dorado", "Musculoso", "Cárnico", "Eficiente"],
        "Simmental": ["Rojo y blanco", "Grande", "Doble propósito", "Gentil"],
        "Shorthorn": ["Rojo", "Mediano", "Doble propósito", "Histórico"],
        "Gelbvieh": ["Dorado", "Mediano", "Cárnico", "Europeo"],
    }

    # Pesos promedio por raza (kg)
    BREED_AVERAGE_WEIGHTS = {
        "Angus": 650.0,
        "Hereford": 680.0,
        "Holstein": 750.0,
        "Jersey": 450.0,
        "Brahman": 700.0,
        "Charolais": 800.0,
        "Limousin": 750.0,
        "Simmental": 800.0,
        "Shorthorn": 650.0,
        "Gelbvieh": 700.0,
    }
