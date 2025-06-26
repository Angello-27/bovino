#!/usr/bin/env python3
"""
Script de verificación de TensorFlow para principiantes
"""

import sys
import subprocess
import importlib


def check_python_version():
    """Verificar versión de Python"""
    print("🔍 Verificando versión de Python...")

    version = sys.version_info
    print(f"   Python {version.major}.{version.minor}.{version.micro}")

    if version.major < 3 or (version.major == 3 and version.minor < 8):
        print("❌ Se requiere Python 3.8 o superior")
        return False

    print("✅ Versión de Python compatible")
    return True


def check_package(package_name, import_name=None):
    """Verificar si un paquete está instalado"""
    if import_name is None:
        import_name = package_name

    try:
        importlib.import_module(import_name)
        print(f"✅ {package_name} instalado")
        return True
    except ImportError:
        print(f"❌ {package_name} no encontrado")
        return False


def test_tensorflow_basic():
    """Probar funcionalidad básica de TensorFlow"""
    print("\n🤖 Probando TensorFlow básico...")

    try:
        import tensorflow as tf

        # Verificar versión
        print(f"   Versión: {tf.__version__}")

        # Verificar dispositivos
        cpu_devices = tf.config.list_physical_devices("CPU")
        gpu_devices = tf.config.list_physical_devices("GPU")

        print(f"   CPU disponible: {len(cpu_devices)}")
        print(f"   GPU disponible: {len(gpu_devices)}")

        if gpu_devices:
            print("   🚀 GPU detectada - Entrenamiento será más rápido!")
        else:
            print("   💻 Solo CPU disponible - Entrenamiento será más lento")

        # Crear tensor simple
        tensor = tf.constant([[1, 2], [3, 4]])
        print(f"   Tensor creado: {tensor.shape}")

        # Operación simple
        result = tf.reduce_sum(tensor)
        print(f"   Suma del tensor: {result.numpy()}")

        print("✅ TensorFlow funciona correctamente")
        return True

    except Exception as e:
        print(f"❌ Error en TensorFlow: {e}")
        return False


def test_tensorflow_model():
    """Probar creación y entrenamiento de modelo"""
    print("\n🧠 Probando creación de modelo...")

    try:
        import tensorflow as tf
        import numpy as np

        # Crear modelo simple
        model = tf.keras.Sequential(
            [
                tf.keras.layers.Dense(10, activation="relu", input_shape=(5,)),
                tf.keras.layers.Dense(5, activation="relu"),
                tf.keras.layers.Dense(1),
            ]
        )

        # Compilar modelo
        model.compile(optimizer="adam", loss="mse", metrics=["mae"])

        print(f"   Modelo creado con {model.count_params()} parámetros")

        # Crear datos de prueba
        X = np.random.random((100, 5))
        y = np.random.random((100, 1))

        # Entrenar modelo (1 época para prueba rápida)
        history = model.fit(X, y, epochs=1, verbose=0)

        # Hacer predicción
        prediction = model.predict(X[:1], verbose=0)
        print(f"   Predicción de prueba: {prediction[0][0]:.4f}")

        print("✅ Modelo creado y entrenado exitosamente")
        return True

    except Exception as e:
        print(f"❌ Error en modelo: {e}")
        return False


def test_image_processing():
    """Probar procesamiento de imágenes"""
    print("\n🖼️ Probando procesamiento de imágenes...")

    try:
        import numpy as np
        from PIL import Image

        # Crear imagen de prueba
        image_array = np.random.randint(0, 255, (224, 224, 3), dtype=np.uint8)
        image = Image.fromarray(image_array)

        # Redimensionar
        resized_image = image.resize((224, 224))

        # Convertir a array y normalizar
        normalized_array = np.array(resized_image) / 255.0

        print(f"   Imagen creada: {normalized_array.shape}")
        print(
            f"   Rango de valores: {normalized_array.min():.2f} - {normalized_array.max():.2f}"
        )

        print("✅ Procesamiento de imágenes funciona")
        return True

    except Exception as e:
        print(f"❌ Error en procesamiento de imágenes: {e}")
        return False


def test_fastapi():
    """Probar FastAPI"""
    print("\n⚡ Probando FastAPI...")

    try:
        import fastapi
        from fastapi import FastAPI

        app = FastAPI()
        print(f"   Versión FastAPI: {fastapi.__version__}")
        print("✅ FastAPI disponible")
        return True

    except Exception as e:
        print(f"❌ Error en FastAPI: {e}")
        return False


def test_websockets():
    """Probar WebSockets"""
    print("\n🔌 Probando WebSockets...")

    try:
        import websockets

        print(f"   Versión websockets: {websockets.__version__}")
        print("✅ WebSockets disponible")
        return True

    except Exception as e:
        print(f"❌ Error en WebSockets: {e}")
        return False


def main():
    """Función principal"""
    print("🐄 Verificación de TensorFlow para Bovino IA")
    print("=" * 50)

    # Lista de verificaciones
    checks = [
        ("Python", check_python_version),
        ("TensorFlow básico", test_tensorflow_basic),
        ("Modelo TensorFlow", test_tensorflow_model),
        ("Procesamiento de imágenes", test_image_processing),
        ("FastAPI", test_fastapi),
        ("WebSockets", test_websockets),
    ]

    results = []

    for check_name, check_func in checks:
        try:
            result = check_func()
            results.append((check_name, result))
        except Exception as e:
            print(f"❌ Error en {check_name}: {e}")
            results.append((check_name, False))

    # Resumen
    print("\n" + "=" * 50)
    print("📋 RESUMEN DE VERIFICACIÓN")
    print("=" * 50)

    passed = sum(1 for _, result in results if result)
    total = len(results)

    for check_name, result in results:
        status = "✅ PASÓ" if result else "❌ FALLÓ"
        print(f"{check_name}: {status}")

    print(f"\n🎯 Resultado: {passed}/{total} verificaciones pasaron")

    if passed == total:
        print("\n🎉 ¡Todo está listo!")
        print("✅ Puedes ejecutar el servidor con: python start_server.py")
        print("✅ O probar el servidor con: python test_server.py")
    else:
        print("\n⚠️ Algunas verificaciones fallaron")
        print("💡 Revisa la guía de instalación: guia_instalacion.md")

        if not any(name == "TensorFlow básico" and result for name, result in results):
            print("\n🔧 Para instalar TensorFlow:")
            print("   pip install tensorflow==2.15.0")

        if not any(name == "FastAPI" and result for name, result in results):
            print("\n🔧 Para instalar FastAPI:")
            print("   pip install fastapi uvicorn")

    return passed == total


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
