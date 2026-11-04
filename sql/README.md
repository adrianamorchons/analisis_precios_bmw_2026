# 🗄️ Módulo de Modelado Relacional y SQL Analítico (Euro 7 & Arbitraje)

Este módulo contiene el desarrollo analítico basado en **SQL** para evaluar el impacto financiero de la normativa Euro 7 sobre el catálogo de BMW Europa para el 2026 y modelar las ventanas de arbitraje transfronterizo.

## 🎯 Objetivos Estratégicos del Módulo
*   **Validación e Ingesta:** Asegurar el control de calidad estructural de los datos extraídos de los catálogos oficiales.
*   **Segmentación del Impacto:** Identificar la sensibilidad de precios por tipo de carrocería y motorización.
*   **Análisis Estadístico Extremo:** Aislar y medir desviaciones típicas (*Outliers*) provocadas por presiones fiscales locales.
*   **Algoritmo de Arbitraje Neto:** Calcular la rentabilidad real de importación deduciendo variables de homologación y costes logísticos.

---

## 💻 Estructura del Script Principal (`sensibilidad_precios_euro7.sql`)

El script está unificado y estructurado cronológicamente en **7 secciones operativas**:

| Sección | Componentes Técnicos SQL | Propósito Comercial |
| :--- | :--- | :--- |
| **1. Calidad de Datos** | `COUNT(*)`, `information_schema.columns` | Validación estructural de las 38 columnas de la tabla. |
| **2. Impacto Diésel (ES)** | `CAST()`, `ROUND()`, `ORDER BY DESC` | Análisis de la presión de precios en gamas de acceso en España. |
| **3. Análisis BEV/PHEV** | `LIKE '%Puro%'`, `AVG()`, `HAVING` | Agregación del coste técnico medio en tecnologías eficientes. |
| **4. Análisis Gama Touring** | `CASE WHEN`, `GROUP BY` | Comparativa de rendimiento comercial Diésel vs Gasolina Familiar. |
| **5. Arbitraje Global** | `REPLACE()`, `CAST( AS NUMERIC)` | Conversión de strings locales para clasificar brechas brutas. |
| **6. Caso de Estudio: PT** | `WITH (CTE)`, `STDDEV_POP()`, Puntuación Z | Aislamiento matemático del BMW X6 M como outlier extremo. |
| **7. Caso de Estudio: CH** | Filtros lógicos booleanos y ROI porcentual | Identificación de la ventana de viabilidad diésel España ➡️ Suiza con ROI > 5%. |

---

## 📈 Hallazgos Clave Extraídos mediante Consultas

### A. Aislamiento de Outliers (Z-Score en Portugal)
A través de funciones de dispersión poblacional (`STDDEV_POP`), se determinó que la combinación de la normativa Euro 7 y la tasa impositiva máxima ISV en Portugal desplaza a los modelos de combustión pura de altas prestaciones a escenarios de exclusión comercial:
*   **BMW X6 M (Post-Euro 7):** **291.264 €**
*   **Distancia matemática:** Situado a **+3.57 desviaciones estándar ($\sigma$)** respecto a la media del mercado luso ($\mu$: 105.748 €), confirmando su estatus de anomalía estadística extrema.

### B. Ventana de Arbitraje de Alta Eficiencia (Caso de Éxito: Suiza)
Mediante la ejecución de un algoritmo de filtrado en la cláusula `WHERE` que deduce el coste normativo variable de la Euro 7 en destino y **2.500 € de costes logísticos fijos**, se aisló el comportamiento real de la importación desde España a Suiza en motores diésel, arrojando una matriz de viabilidad neta:

1.  **Líder Absoluto en Eficiencia de Capital:** El **BMW Serie 4 Coupé 420d** se consolida como la operación maestra del ecosistema. Presenta un **Retorno de Inversión (ROI) neto del 42,97%** y un **margen neto absoluto de 25.246 € líquidos** por unidad comercializada, impulsado por una gigantesca brecha de precio bruto inicial (95.531 € en Suiza vs 58.750 € en España) que absorbe sin dificultad los 9.035 € de castigo normativo Euro 7.
2.  **Consistencia en Volumen Medio:** Las variantes de acceso de la Serie 3 (*318d* y *318d Touring*) demuestran una solidez financiera sobresaliente con rendimientos que superan el **22% de ROI neto** y beneficios limpios de **~11.800 €** por coche, requiriendo inversiones iniciales contenidas en origen.
3.  **Veto Comercial y Umbral de Riesgo:** Los modelos *Serie 5 Touring 520d* (ROI: 6,07% / Margen: 4.007 €) y *Serie 2 Gran Coupé 220d* (ROI: 5,16% / Margen: 2.257 €) cierran el límite de viabilidad. Quedan catalogados como operaciones de alto riesgo, ya que el peso del coste fijo logístico y el impacto de la Euro 7 comprometen peligrosamente el beneficio ante variaciones imprevistas en la aduana helvética.

---

## 🛠️ Stack Tecnológico y Entorno de Ejecución

Para garantizar la integridad del análisis relacional y la correcta ejecución de las consultas avanzadas, se ha utilizado el siguiente entorno técnico:

*   **Motor de Base de Datos:** `PostgreSQL` (Enfoque corporativo ideal para el procesamiento de funciones analíticas, agregaciones poblacionales y manejo de datos estructurados complejos).
*   **Cliente de Gestión / IDE:** `DBeaver Community Edition` (Configurado para la administración del esquema público, ejecución de scripts secuenciales y validación de tipos de datos en la cuadrícula de resultados).
*   **Compatibilidad de Sintaxis:** El script hace uso de comillas dobles (`"Columna"`) para respetar estrictamente el *case-sensitivity* (mayúsculas y minúsculas) de la estructura del dataset original importado desde Excel/CSV y resolver de forma estricta las agregaciones en bloques condicionales mediante agrupaciones robustas en el `GROUP BY`.
