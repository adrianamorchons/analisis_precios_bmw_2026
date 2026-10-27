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
| **7. Caso de Estudio: CH** | Expresiones condicionales y deducción fija | Filtrado de modelos con margen neto real > 5.000€. |

---

## 📈 Hallazgos Clave Extraídos mediante Consultas

### A. Aislamiento de Outliers (Z-Score en Portugal)
A través de funciones de dispersión poblacional (`STDDEV_POP`), se determinó que la combinación de la normativa Euro 7 y la tasa impositiva máxima ISV en Portugal desplaza a los modelos de combustión pura de altas prestaciones a escenarios de exclusión comercial:
*   **BMW X6 M (Post-Euro 7):** **291.264 €**
*   **Distancia matemática:** Situado a **+3.57 desviaciones estándar ($\sigma$)** respecto a la media del mercado luso ($\mu$: 105.748 €), confirmando su estatus de anomalía estadística extrema.

### B. Optimización de Ventanas de Margen Neto (Suiza)
Aplicando un algoritmo de filtrado en el `WHERE` que deduce un sobrecoste técnico variable y **2.500 € de costes logísticos fijos**, el comportamiento relacional detectó asimetrías críticas:
*   **Portugal:** La presión impositiva destruye los márgenes brutos, dejando únicamente **2 modelos** viables para el arbitraje internacional.
*   **Suiza:** La estabilidad fiscal helvética genera **36 modelos** que conservan un **margen neto limpio superior a los 5.000 €** (liderados por el *Serie 4 Coupe 420d* con una brecha bruta de 38.831 €).

---

## ⚙️ Requisitos de Ejecución
*   **Tabla Maestra:** `analisis_precios_bmw_euro7`
*   **Motor de Base de Datos Compatible:** PostgreSQL, MySQL o SQLite (ajustando funciones de agregación de dispersión).
*   **IDE Recomendado:** DBeaver Community Edition.

## 🛠️ Stack Tecnológico y Entorno de Ejecución

Para garantizar la integridad del análisis relacional y la correcta ejecución de las consultas avanzadas, se ha utilizado el siguiente entorno técnico:

*   **Motor de Base de Datos:** `PostgreSQL` (Enfoque corporativo ideal para el procesamiento de funciones analíticas, agregaciones poblacionales y manejo de datos estructurados complejos).
*   **Cliente de Gestión / IDE:** `DBeaver Community Edition` (Configurado para la administración del esquema público, ejecución de scripts secuenciales y validación de tipos de datos en la cuadrícula de resultados).
*   **Compatibilidad de Sintaxis:** El script hace uso de comillas dobles (`"Columna"`) para respetar estrictamente el *case-sensitivity* (mayúsculas y minúsculas) de la estructura del dataset original importado desde Excel/CSV.

