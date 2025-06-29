"""
Configuración global de warnings para el servidor Bovino IA
Suprime warnings innecesarios para una salida más limpia
"""

import os
import warnings
import logging

def configure_warnings():
    """Configurar supresión de warnings globales"""
    
    # Configurar nivel de logging de TensorFlow
    os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'  # Suprimir INFO y WARN
    
    # Suprimir warnings específicos
    warnings.filterwarnings('ignore', category=FutureWarning)
    warnings.filterwarnings('ignore', category=DeprecationWarning)
    warnings.filterwarnings('ignore', category=UserWarning)
    
    # Suprimir warnings de librerías específicas
    warnings.filterwarnings("ignore", message=".*Pydantic.*")
    warnings.filterwarnings("ignore", message=".*uvicorn.*")
    warnings.filterwarnings("ignore", message=".*fastapi.*")
    warnings.filterwarnings("ignore", message=".*tensorflow.*")
    warnings.filterwarnings("ignore", message=".*numpy.*")
    
    # Configurar logging para ser menos verboso
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    logging.getLogger("uvicorn.error").setLevel(logging.WARNING)
    logging.getLogger("fastapi").setLevel(logging.WARNING)
    
    print("🔇 Warnings configurados para salida limpia")

def configure_openCV_warnings():
    """Configurar warnings específicos de OpenCV"""
    try:
        import cv2
        # Manejar diferentes versiones de OpenCV
        if hasattr(cv2, 'setLogLevel'):
            if hasattr(cv2, 'LOG_LEVEL_SILENT'):
                cv2.setLogLevel(cv2.LOG_LEVEL_SILENT)
            elif hasattr(cv2, 'LOG_LEVEL_ERROR'):
                cv2.setLogLevel(cv2.LOG_LEVEL_ERROR)
            else:
                # Para versiones más antiguas, usar logging
                import logging
                logging.getLogger('cv2').setLevel(logging.ERROR)
        print("🔇 Warnings de OpenCV suprimidos")
    except ImportError:
        pass
    except Exception as e:
        print(f"⚠️ No se pudieron suprimir warnings de OpenCV: {e}")

def configure_tensorflow_warnings():
    """Configurar warnings específicos de TensorFlow"""
    try:
        import tensorflow as tf
        # Configurar TensorFlow para ser menos verboso
        tf.get_logger().setLevel(logging.ERROR)
        print("🔇 Warnings de TensorFlow suprimidos")
    except ImportError:
        pass 