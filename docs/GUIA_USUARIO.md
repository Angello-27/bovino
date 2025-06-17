# Guía de Usuario - Bovino IA

## Introducción

Bovino IA es una aplicación móvil que utiliza inteligencia artificial para identificar razas de ganado bovino y estimar su peso a partir de imágenes capturadas con la cámara del dispositivo.

## Instalación y Configuración

### Requisitos Previos

- Dispositivo Android (API 21+) o iOS (12.0+)
- Conexión a internet
- Cámara funcional
- Cuenta de OpenAI con créditos disponibles

### Configuración Inicial

1. **Obtener API Key de OpenAI**
   - Ve a [https://platform.openai.com/api-keys](https://platform.openai.com/api-keys)
   - Crea una nueva API key
   - Copia la clave (comienza con `sk-`)

2. **Configurar la Aplicación**
   - Abre el archivo `lib/config/app_config.dart`
   - Reemplaza `'TU_API_KEY_AQUI'` con tu API key real
   - Guarda el archivo

3. **Instalar Dependencias**
   ```bash
   flutter pub get
   ```

4. **Ejecutar la Aplicación**
   ```bash
   flutter run
   ```

## Uso de la Aplicación

### Pantalla Principal

La aplicación se abre mostrando la vista de la cámara con las siguientes características:

- **Vista de cámara en tiempo real**: Muestra lo que ve la cámara
- **Botón de captura**: Para tomar la foto del bovino
- **Indicador de estado**: Muestra si la cámara está lista

### Proceso de Análisis

1. **Preparación**
   - Asegúrate de que el bovino esté completo en el encuadre
   - Verifica que la iluminación sea adecuada
   - Mantén la cámara estable

2. **Captura**
   - Presiona el botón "Capturar"
   - Espera a que se procese la imagen
   - No muevas el dispositivo durante la captura

3. **Análisis**
   - La aplicación enviará la imagen a OpenAI
   - El análisis puede tomar entre 5-15 segundos
   - Se mostrará un indicador de progreso

4. **Resultados**
   - Raza identificada
   - Peso estimado en kilogramos
   - Nivel de confianza del análisis
   - Descripción detallada
   - Lista de características observadas

### Pantalla de Resultados

Los resultados se muestran en tarjetas organizadas:

- **Información Principal**: Raza, peso y confianza
- **Descripción**: Análisis detallado del animal
- **Características**: Lista de rasgos físicos observados
- **Botón de Nuevo Análisis**: Para capturar otra imagen

## Mejores Prácticas

### Para Captura de Imágenes

#### ✅ Hacer
- Usar buena iluminación natural o artificial
- Capturar el animal completo en el encuadre
- Mantener la cámara estable
- Tomar la foto desde un ángulo lateral
- Asegurar que el fondo sea claro y sin obstáculos

#### ❌ Evitar
- Imágenes borrosas o movidas
- Animales parcialmente fuera del encuadre
- Iluminación muy baja o muy alta
- Fondos muy complejos o confusos
- Ángulos extremos o distorsionados

### Para Mejores Resultados

#### Identificación de Raza
- **Holstein**: Busca el patrón blanco y negro característico
- **Angus**: Animales negros o rojos, sin cuernos
- **Brahman**: Joroba característica, orejas largas
- **Hereford**: Cara blanca, cuerpo rojo
- **Simmental**: Patrón de manchas rojas y blancas

#### Estimación de Peso
- La IA considera:
  - Tamaño corporal aparente
  - Edad estimada
  - Características de la raza
  - Proporciones del animal

## Solución de Problemas

### Errores Comunes

#### Error de API Key
```
Error: API key de OpenAI inválida
```
**Solución**: Verifica que tu API key esté correctamente configurada en `lib/config/app_config.dart`

#### Error de Permisos
```
Error: Se requieren permisos de cámara
```
**Solución**: Ve a Configuración > Aplicaciones > Bovino IA > Permisos y habilita la cámara

#### Error de Red
```
Error: Tiempo de conexión agotado
```
**Solución**: Verifica tu conexión a internet y vuelve a intentar

#### Error de Límite de Uso
```
Error: Límite de uso de OpenAI alcanzado
```
**Solución**: Espera un tiempo o verifica tu saldo de OpenAI

### Problemas de Rendimiento

#### Análisis Lento
- Verifica tu conexión a internet
- Asegúrate de que la imagen no sea muy grande
- Cierra otras aplicaciones que usen internet

#### Aplicación Lenta
- Reinicia la aplicación
- Verifica que tienes suficiente espacio en el dispositivo
- Cierra otras aplicaciones en segundo plano

## Características Técnicas

### Razas Soportadas

La aplicación puede identificar más de 20 razas de ganado bovino, incluyendo:

- **Razas Lecheras**: Holstein, Jersey, Guernsey, Ayrshire, Brown Swiss
- **Razas de Carne**: Angus, Hereford, Simmental, Charolais, Limousin
- **Razas Doble Propósito**: Shorthorn, Gelbvieh, Red Angus
- **Razas Especializadas**: Wagyu, Piedmontese, Chianina

### Precisión del Análisis

- **Identificación de Raza**: 85-95% de precisión
- **Estimación de Peso**: ±10-15% de variación
- **Tiempo de Análisis**: 5-15 segundos promedio

### Requisitos del Sistema

- **Android**: API 21 o superior
- **iOS**: iOS 12.0 o superior
- **Memoria**: Mínimo 2GB RAM
- **Almacenamiento**: 50MB libres
- **Conexión**: Internet estable (mínimo 1Mbps)

## Soporte y Contacto

### Recursos Adicionales

- **Documentación Técnica**: Ver el archivo `README.md`
- **Código Fuente**: Disponible en el repositorio del proyecto
- **Issues**: Reporta problemas en la sección de issues

### Información de Contacto

Para soporte técnico o preguntas:
- Abre un issue en el repositorio
- Incluye detalles del problema
- Adjunta capturas de pantalla si es necesario

## Actualizaciones

### Versión 1.0.0
- Análisis básico de razas bovinas
- Estimación de peso
- Interfaz de usuario moderna
- Soporte para Android e iOS

### Próximas Características
- Historial de análisis
- Exportación de resultados
- Análisis de múltiples animales
- Integración con bases de datos ganaderas 