# Ejemplos de Uso - Bovino IA

## Ejemplo 1: Identificación de Holstein

### Escenario
Un ganadero quiere identificar y pesar una vaca Holstein en su granja.

### Pasos
1. **Preparación**
   - Abrir la aplicación Bovino IA
   - Asegurar buena iluminación (día soleado)
   - Posicionar la cámara a 3-5 metros del animal

2. **Captura**
   - Encuadrar la vaca completa en la pantalla
   - Mantener la cámara estable
   - Presionar "Capturar"

3. **Resultado Esperado**
   ```json
   {
     "raza": "Holstein",
     "peso_estimado": 650.0,
     "confianza": 0.92,
     "descripcion": "Vaca Holstein adulta con patrón característico blanco y negro. El animal muestra buena condición corporal con musculatura desarrollada típica de la raza lechera.",
     "caracteristicas": [
       "Patrón blanco y negro distintivo",
       "Cabeza blanca con manchas negras",
       "Cuerpo bien proporcionado",
       "Ubres desarrolladas",
       "Patas negras"
     ]
   }
   ```

## Ejemplo 2: Análisis de Angus

### Escenario
Identificación de un toro Angus para estimación de peso de venta.

### Pasos
1. **Preparación**
   - Buscar ángulo lateral del animal
   - Asegurar que el animal esté de pie
   - Evitar sombras que oculten características

2. **Captura**
   - Capturar desde un ángulo de 45 grados
   - Incluir todo el cuerpo del animal
   - Presionar "Capturar"

3. **Resultado Esperado**
   ```json
   {
     "raza": "Angus",
     "peso_estimado": 850.0,
     "confianza": 0.89,
     "descripcion": "Toro Angus negro de excelente conformación. Animal musculoso con características típicas de la raza: sin cuernos, pelaje negro uniforme y estructura corporal robusta.",
     "caracteristicas": [
       "Pelaje negro uniforme",
       "Sin cuernos (polled)",
       "Cabeza ancha",
       "Musculatura desarrollada",
       "Patas fuertes"
     ]
   }
   ```

## Ejemplo 3: Identificación de Brahman

### Escenario
Análisis de un ejemplar Brahman en clima tropical.

### Pasos
1. **Preparación**
   - Capturar en horas de buena luz
   - Enfocar en la joroba característica
   - Incluir las orejas largas

2. **Captura**
   - Encuadrar destacando la joroba
   - Mostrar el perfil completo
   - Presionar "Capturar"

3. **Resultado Esperado**
   ```json
   {
     "raza": "Brahman",
     "peso_estimado": 750.0,
     "confianza": 0.94,
     "descripcion": "Ejemplar Brahman con joroba prominente característica de la raza. Orejas largas y caídas, pelaje gris claro. Animal adaptado a clima tropical con piel suelta.",
     "caracteristicas": [
       "Joroba prominente en el cuello",
       "Orejas largas y caídas",
       "Pelaje gris claro",
       "Piel suelta y arrugada",
       "Adaptado a clima cálido"
     ]
   }
   ```

## Ejemplo 4: Análisis de Hereford

### Escenario
Identificación de una vaca Hereford en pastoreo.

### Pasos
1. **Preparación**
   - Buscar el patrón de color característico
   - Capturar la cara blanca distintiva
   - Incluir el cuerpo rojo

2. **Captura**
   - Enfocar en la cara blanca
   - Mostrar el patrón de color completo
   - Presionar "Capturar"

3. **Resultado Esperado**
   ```json
   {
     "raza": "Hereford",
     "peso_estimado": 600.0,
     "confianza": 0.91,
     "descripcion": "Vaca Hereford con patrón de color característico: cara blanca y cuerpo rojo. Animal de tamaño mediano con buena conformación para producción de carne.",
     "caracteristicas": [
       "Cara blanca distintiva",
       "Cuerpo rojo",
       "Patas blancas",
       "Tamaño mediano",
       "Conformación para carne"
     ]
   }
   ```

## Ejemplo 5: Análisis de Simmental

### Escenario
Identificación de un toro Simmental de doble propósito.

### Pasos
1. **Preparación**
   - Buscar el patrón de manchas rojas y blancas
   - Capturar el tamaño grande característico
   - Mostrar la musculatura desarrollada

2. **Captura**
   - Encuadrar el animal completo
   - Destacar el patrón de color
   - Presionar "Capturar"

3. **Resultado Esperado**
   ```json
   {
     "raza": "Simmental",
     "peso_estimado": 950.0,
     "confianza": 0.88,
     "descripcion": "Toro Simmental de gran tamaño con patrón de manchas rojas y blancas. Animal musculoso de doble propósito, excelente para producción de carne y leche.",
     "caracteristicas": [
       "Patrón rojo y blanco",
       "Tamaño grande",
       "Musculatura desarrollada",
       "Cabeza ancha",
       "Doble propósito"
     ]
   }
   ```

## Consejos para Diferentes Situaciones

### Condiciones de Luz
- **Luz natural**: Mejor opción, especialmente en días nublados
- **Luz artificial**: Usar iluminación uniforme, evitar sombras duras
- **Luz baja**: Evitar capturas en condiciones de poca luz

### Ángulos de Captura
- **Lateral**: Mejor para identificación de raza
- **3/4**: Bueno para estimación de peso
- **Frontal**: Útil para ver características faciales
- **Posterior**: Evitar, dificulta la identificación

### Distancia Óptima
- **3-5 metros**: Distancia ideal para la mayoría de razas
- **2-3 metros**: Para animales pequeños o terneros
- **5-7 metros**: Para animales muy grandes

### Fondo Recomendado
- **Pastos verdes**: Fondo natural y claro
- **Cielo azul**: Bueno para contraste
- **Estructuras simples**: Evitar fondos complejos
- **Evitar**: Fondos con muchos objetos o personas

## Interpretación de Resultados

### Nivel de Confianza
- **0.9-1.0**: Identificación muy segura
- **0.7-0.9**: Identificación probable
- **0.5-0.7**: Identificación incierta
- **<0.5**: Considerar nueva captura

### Estimación de Peso
- **Variación esperada**: ±10-15%
- **Factores que afectan**: Edad, condición, ángulo de captura
- **Validación**: Comparar con pesaje real cuando sea posible

### Características Observadas
- **Rasgos físicos**: Color, patrón, tamaño
- **Conformación**: Estructura corporal
- **Edad aparente**: Basado en desarrollo
- **Condición**: Estado de salud y nutrición 