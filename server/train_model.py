import tensorflow as tf
import numpy as np
import os
import json
from PIL import Image
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix
import logging

from config.settings import Settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class BovinoModelTrainer:
    """Entrenador del modelo de reconocimiento de bovinos"""

    def __init__(self):
        self.settings = Settings()
        self.model = None
        self.history = None

    def create_model(self):
        """Crear modelo CNN para clasificación de bovinos"""
        logger.info("🏗️ Creando modelo CNN...")

        model = tf.keras.Sequential(
            [
                tf.keras.layers.Conv2D(
                    32,
                    (3, 3),
                    activation="relu",
                    input_shape=(self.settings.IMAGE_SIZE, self.settings.IMAGE_SIZE, 3),
                ),
                tf.keras.layers.BatchNormalization(),
                tf.keras.layers.MaxPooling2D((2, 2)),
                tf.keras.layers.Conv2D(64, (3, 3), activation="relu"),
                tf.keras.layers.BatchNormalization(),
                tf.keras.layers.MaxPooling2D((2, 2)),
                tf.keras.layers.Conv2D(128, (3, 3), activation="relu"),
                tf.keras.layers.BatchNormalization(),
                tf.keras.layers.MaxPooling2D((2, 2)),
                tf.keras.layers.Flatten(),
                tf.keras.layers.Dropout(0.5),
                tf.keras.layers.Dense(512, activation="relu"),
                tf.keras.layers.BatchNormalization(),
                tf.keras.layers.Dropout(0.3),
                tf.keras.layers.Dense(256, activation="relu"),
                tf.keras.layers.Dropout(0.3),
                tf.keras.layers.Dense(
                    len(self.settings.BOVINE_BREEDS), activation="softmax"
                ),
            ]
        )

        model.compile(
            optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
            loss="sparse_categorical_crossentropy",
            metrics=["accuracy"],
        )

        self.model = model
        logger.info(f"✅ Modelo creado con {len(self.settings.BOVINE_BREEDS)} clases")

        return model

    def load_and_preprocess_data(self, data_dir: str):
        """Cargar y preprocesar datos de entrenamiento"""
        logger.info(f"📁 Cargando datos desde: {data_dir}")

        images = []
        labels = []

        for breed_idx, breed in enumerate(self.settings.BOVINE_BREEDS):
            breed_dir = os.path.join(data_dir, breed)

            if not os.path.exists(breed_dir):
                logger.warning(f"⚠️ Directorio no encontrado: {breed_dir}")
                continue

            for filename in os.listdir(breed_dir):
                if filename.lower().endswith((".png", ".jpg", ".jpeg")):
                    image_path = os.path.join(breed_dir, filename)

                    try:
                        image = Image.open(image_path)
                        image = image.convert("RGB")
                        image = image.resize(
                            (self.settings.IMAGE_SIZE, self.settings.IMAGE_SIZE)
                        )

                        image_array = np.array(image) / 255.0

                        images.append(image_array)
                        labels.append(breed_idx)

                    except Exception as e:
                        logger.error(f"Error procesando {image_path}: {e}")

        X = np.array(images)
        y = np.array(labels)

        logger.info(f"✅ Datos cargados: {len(X)} imágenes, {len(np.unique(y))} clases")

        return X, y

    def create_data_augmentation(self):
        """Crear aumentación de datos para mejorar el entrenamiento"""
        data_augmentation = tf.keras.Sequential(
            [
                tf.keras.layers.RandomFlip("horizontal"),
                tf.keras.layers.RandomRotation(0.1),
                tf.keras.layers.RandomZoom(0.1),
                tf.keras.layers.RandomBrightness(0.1),
                tf.keras.layers.RandomContrast(0.1),
            ]
        )

        return data_augmentation

    def train_model(self, X_train, y_train, X_val, y_val, epochs=50, batch_size=32):
        """Entrenar el modelo"""
        logger.info("🚀 Iniciando entrenamiento del modelo...")

        callbacks = [
            tf.keras.callbacks.EarlyStopping(
                monitor="val_loss", patience=10, restore_best_weights=True
            ),
            tf.keras.callbacks.ReduceLROnPlateau(
                monitor="val_loss", factor=0.5, patience=5, min_lr=1e-7
            ),
            tf.keras.callbacks.ModelCheckpoint(
                "models/best_bovino_model.h5",
                monitor="val_accuracy",
                save_best_only=True,
                verbose=1,
            ),
        ]

        self.history = self.model.fit(
            X_train,
            y_train,
            validation_data=(X_val, y_val),
            epochs=epochs,
            batch_size=batch_size,
            callbacks=callbacks,
            verbose=1,
        )

        logger.info("✅ Entrenamiento completado")

        return self.history

    def evaluate_model(self, X_test, y_test):
        """Evaluar el modelo"""
        logger.info("📊 Evaluando modelo...")

        # Predicciones
        y_pred = self.model.predict(X_test)
        y_pred_classes = np.argmax(y_pred, axis=1)

        # Métricas
        test_loss, test_accuracy = self.model.evaluate(X_test, y_test, verbose=0)

        logger.info(f"📈 Precisión de prueba: {test_accuracy:.4f}")

        # Reporte de clasificación
        report = classification_report(
            y_test, y_pred_classes, target_names=self.settings.BOVINE_BREEDS
        )
        logger.info(f"📋 Reporte de clasificación:\n{report}")

        return test_accuracy, report

    def plot_training_history(self):
        """Graficar historial de entrenamiento"""
        if self.history is None:
            logger.warning("No hay historial de entrenamiento para graficar")
            return

        fig, axes = plt.subplots(2, 2, figsize=(15, 10))

        # Precisión
        axes[0, 0].plot(self.history.history["accuracy"], label="Entrenamiento")
        axes[0, 0].plot(self.history.history["val_accuracy"], label="Validación")
        axes[0, 0].set_title("Precisión del Modelo")
        axes[0, 0].set_xlabel("Época")
        axes[0, 0].set_ylabel("Precisión")
        axes[0, 0].legend()
        axes[0, 0].grid(True)

        # Pérdida
        axes[0, 1].plot(self.history.history["loss"], label="Entrenamiento")
        axes[0, 1].plot(self.history.history["val_loss"], label="Validación")
        axes[0, 1].set_title("Pérdida del Modelo")
        axes[0, 1].set_xlabel("Época")
        axes[0, 1].set_ylabel("Pérdida")
        axes[0, 1].legend()
        axes[0, 1].grid(True)

        # Learning Rate
        if "lr" in self.history.history:
            axes[1, 0].plot(self.history.history["lr"])
            axes[1, 0].set_title("Learning Rate")
            axes[1, 0].set_xlabel("Época")
            axes[1, 0].set_ylabel("Learning Rate")
            axes[1, 0].set_yscale("log")
            axes[1, 0].grid(True)

        plt.tight_layout()
        plt.savefig("models/training_history.png", dpi=300, bbox_inches="tight")
        plt.show()

    def save_model(self, model_path: str = None):
        """Guardar modelo entrenado"""
        if model_path is None:
            model_path = self.settings.MODEL_PATH

        # Crear directorio si no existe
        os.makedirs(os.path.dirname(model_path), exist_ok=True)

        # Guardar modelo
        self.model.save(model_path)
        logger.info(f"💾 Modelo guardado en: {model_path}")

        # Guardar etiquetas de clases
        labels_path = self.settings.LABELS_PATH
        with open(labels_path, "w") as f:
            json.dump(self.settings.BOVINE_BREEDS, f, indent=2)
        logger.info(f"💾 Etiquetas guardadas en: {labels_path}")


def main():
    """Función principal para entrenar el modelo"""
    logger.info("🐄 Iniciando entrenamiento del modelo Bovino IA")

    # Crear entrenador
    trainer = BovinoModelTrainer()

    # Crear modelo
    model = trainer.create_model()

    # Mostrar resumen del modelo
    model.summary()

    # Cargar datos (asumiendo estructura de directorios)
    data_dir = "data/bovine_images"  # Ajustar según tu estructura

    try:
        X, y = trainer.load_and_preprocess_data(data_dir)

        # Dividir datos
        X_train, X_temp, y_train, y_temp = train_test_split(
            X, y, test_size=0.3, random_state=42, stratify=y
        )
        X_val, X_test, y_val, y_test = train_test_split(
            X_temp, y_temp, test_size=0.5, random_state=42, stratify=y_temp
        )

        logger.info(
            f"📊 Datos divididos: Train={len(X_train)}, Val={len(X_val)}, Test={len(X_test)}"
        )

        # Entrenar modelo
        history = trainer.train_model(X_train, y_train, X_val, y_val, epochs=50)

        # Evaluar modelo
        accuracy, report = trainer.evaluate_model(X_test, y_test)

        # Graficar historial
        trainer.plot_training_history()

        # Guardar modelo
        trainer.save_model()

        logger.info("🎉 Entrenamiento completado exitosamente!")

    except FileNotFoundError:
        logger.error(f"❌ Directorio de datos no encontrado: {data_dir}")
        logger.info("💡 Crea la estructura de directorios:")
        logger.info("data/bovine_images/")
        for breed in trainer.settings.BOVINE_BREEDS:
            logger.info(f"  └── {breed}/")
            logger.info(f"      └── (imágenes .jpg, .png, .jpeg)")


if __name__ == "__main__":
    main()
