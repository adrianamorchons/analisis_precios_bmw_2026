-- =========================================================================
-- PROYECTO: Análisis Estratégico de Pricing de BMW (Europa 2026)
-- MÓDULO: Consultas SQL Analíticas Avanzadas - Impacto Normativa Euro 7
-- =========================================================================

-- -------------------------------------------------------------------------
-- SECCIÓN 1: CONTROLES DE CALIDAD Y EXPLORACIÓN INICIAL
-- -------------------------------------------------------------------------

-- Ver los primeros registros para validar la correcta ingesta de la tabla
SELECT *
FROM "analisis_precios_bmw_euro7"
LIMIT 5; 

-- Validar volumen y estructura de columnas en el esquema público
SELECT COUNT(*) AS numero_de_columnas
FROM information_schema.columns 
WHERE table_schema = 'public'
  AND table_name = 'analisis_precios_bmw_euro7';


-- -------------------------------------------------------------------------
-- SECCIÓN 2: ANÁLISIS DE IMPACTO DE EMISIONES EN EL MERCADO ESPAÑOL
-- -------------------------------------------------------------------------

-- Identificar los 10 vehículos diésel convencionales (excluyendo SUV) con mayor incremento porcentual
SELECT 
    "Modelo", 
    "categoria_carroceria", 
    "España" AS precio_base, 
    "PVP_Euro7_España" AS precio_con_euro7,
    ("PVP_Euro7_España" - "España") AS coste_extra_euro7,
    ROUND((CAST(("PVP_Euro7_España" - "España") AS NUMERIC) / "España") * 100, 2) AS porcentaje_aumento
FROM "analisis_precios_bmw_euro7"
WHERE ("Modelo" LIKE '%d %' OR "Modelo" LIKE '%d')
  AND "Modelo" NOT LIKE '%eDrive%'
  AND "categoria_carroceria" <> 'SUV'
ORDER BY porcentaje_aumento DESC
LIMIT 10;

-- Variación absoluta en euros para el catálogo general (excluyendo SUV)
SELECT 
    "Modelo",
    "categoria_carroceria",
    "España" AS precio_original,
    "PVP_Euro7_España" AS precio_con_euro7,
    ("PVP_Euro7_España" - "España") AS diferencia_euros
FROM "analisis_precios_bmw_euro7"
WHERE "España" IS NOT NULL
  AND "categoria_carroceria" <> 'SUV'
ORDER BY diferencia_euros DESC;


-- -------------------------------------------------------------------------
-- SECCIÓN 3: IMPACTO EN TECNOLOGÍAS EFICIENTES (BEV Y PHEV)
-- -------------------------------------------------------------------------

-- Filtrado y análisis de modelos Eléctricos Puros (BEV)
SELECT 
    "Modelo",
    "categoria_carroceria",
    "Tecnologia",
    "España" AS precio_original,
    "PVP_Euro7_España" AS precio_con_euro7,
    ("PVP_Euro7_España" - "España") AS diferencia_euros
FROM "analisis_precios_bmw_euro7"
WHERE "Tecnologia" LIKE '%Puro%'
ORDER BY diferencia_euros DESC;

-- Métricas agregadas de encarecimiento medio en la gama eléctrica (BEV)
SELECT 
    COUNT(*) AS total_electricos,
    ROUND(AVG("PVP_Euro7_España" - "España"), 2) AS coste_extra_medio_eur,
    ROUND(AVG(CAST(("PVP_Euro7_España" - "España") AS NUMERIC) / "España" * 100), 2) AS porcentaje_aumento_medio
FROM "analisis_precios_bmw_euro7"
WHERE "Tecnologia" LIKE '%Puro%';

-- Evaluación de costes medios por carrocería superiores a 1.000€ (Cláusula HAVING)
SELECT 
    "categoria_carroceria", 
    ROUND(AVG("PVP_Euro7_España" - "España"), 2) AS coste_medio
FROM "analisis_precios_bmw_euro7"
GROUP BY "categoria_carroceria"
HAVING AVG("PVP_Euro7_España" - "España") > 1000;

-- Análisis de impacto en la tecnología Híbrida Enchufable (PHEV)
SELECT 
    "Modelo",
    "Segmento_Espacio" AS segmento,
    "España" AS precio_base_original,
    "PVP_Euro7_España" AS precio_final_euro7,
    ("PVP_Euro7_España" - "España") AS coste_extra_hibrido_eur,
    ROUND((CAST(("PVP_Euro7_España" - "España") AS NUMERIC) / "España") * 100, 2) AS porcentaje_aumento_hibrido
FROM "analisis_precios_bmw_euro7"
WHERE "Tecnologia" LIKE '%Híbrido%'
ORDER BY coste_extra_hibrido_eur DESC;


-- -------------------------------------------------------------------------
-- SECCIÓN 4: RENDIMIENTO Y ANÁLISIS DE LA GAMA TOURING (FAMILIAR)
-- -------------------------------------------------------------------------

-- Coste medio de adaptación Euro 7 en la gama familiar
SELECT 
    'Familiar (Touring)' AS tipo,
    ROUND(AVG("PVP_Euro7_España" - "España"), 2) AS coste_medio_familiar
FROM "analisis_precios_bmw_euro7"
WHERE "Modelo" LIKE '%Touring%';

-- Comparativa técnica en la gama familiar: Diésel vs Gasolina convencional
SELECT 
    CASE 
        WHEN "Modelo" LIKE '%d %' OR "Modelo" LIKE '%d' THEN 'Familiar Diésel'
        ELSE 'Familiar Gasolina'
    END AS combustible,
    COUNT(*) AS total_modelos,
    ROUND(AVG(CAST("España" AS NUMERIC)), 2) AS precio_base_medio,
    ROUND(AVG(CAST("PVP_Euro7_España" AS NUMERIC) - CAST("España" AS NUMERIC)), 2) AS coste_extra_medio_eur,
    ROUND(AVG((CAST("PVP_Euro7_España" AS NUMERIC) - CAST("España" AS NUMERIC)) / CAST("España" AS NUMERIC) * 100), 2) AS porcentaje_aumento_medio
FROM "analisis_precios_bmw_euro7"
WHERE "Modelo" LIKE '%Touring%'               
  AND "Tecnologia" NOT LIKE '%Puro%'          
  AND "Tecnologia" NOT LIKE '%Enchufable%'    
GROUP BY 1;


-- -------------------------------------------------------------------------
-- SECCIÓN 5: COMPARATIVA INTERNACIONAL Y ARBITRAJE GEOGRÁFICO
-- -------------------------------------------------------------------------

-- Análisis comparativo del catálogo eléctrico iX en todos los países de la muestra
SELECT 
    "Modelo", "Tecnologia",
    "España" AS precio_orig_es, "PVP_Euro7_España" AS precio_euro7_es, ("PVP_Euro7_España" - "España") AS coste_extra_es,
    "Alemania" AS precio_orig_de, "PVP_Euro7_Alemania" AS precio_euro7_de, ("PVP_Euro7_Alemania" - "Alemania") AS coste_extra_de,
    "Francia" AS precio_orig_fr, "PVP_Euro7_Francia" AS precio_euro7_fr, ("PVP_Euro7_Francia" - "Francia") AS coste_extra_fr,
    "Portugal" AS precio_orig_pt, "PVP_Euro7_Portugal" AS precio_euro7_pt, ("PVP_Euro7_Portugal" - "Portugal") AS coste_extra_pt,
    "Italia" AS precio_orig_it, "PVP_Euro7_Italia" AS precio_euro7_it, ("PVP_Euro7_Italia" - "Italia") AS coste_extra_it,
    "Suiza_Euro" AS precio_orig_ch, "PVP_Euro7_Suiza" AS precio_euro7_ch, ("PVP_Euro7_Suiza" - "Suiza_Euro") AS coste_extra_ch
FROM "analisis_precios_bmw_euro7"
WHERE "Modelo" LIKE 'iX %';

-- Top 20 de brechas de arbitraje bruto en Europa (Conversión de tipos numéricos locales)
SELECT 
    "Modelo", "Tecnologia",
    "Pais_Min" AS mercado_mas_barato, "Min_Precio_EUR" AS precio_minimo_eur,
    "Pais_Max" AS mercado_mas_caro, "Max_Precio_EUR" AS precio_maximo_eur,
    ("Max_Precio_EUR" - "Min_Precio_EUR") AS margen_absoluto_eur,
    ROUND(CAST(REPLACE("brecha_arbitraje_%", ',', '.') AS NUMERIC), 2) AS porcentaje_brecha
FROM "analisis_precios_bmw_euro7"
WHERE "brecha_arbitraje_%" IS NOT NULL
ORDER BY CAST(REPLACE("brecha_arbitraje_%", ',', '.') AS NUMERIC) DESC
LIMIT 20;


-- -------------------------------------------------------------------------
-- SECCIÓN 6: CASO DE ESTUDIO PORTUGAL (MERCADO DE ALTA PRESIÓN FISCAL)
-- -------------------------------------------------------------------------

-- Análisis de Dispersión Extrema (Z-Score) para validar el estatus de outlier del X6 M
WITH estadisticos AS (
    SELECT 
        AVG("Portugal") AS media_original,
        STDDEV_POP("Portugal") AS stddev_original,
        AVG("PVP_Euro7_Portugal") AS media_euro7,
        STDDEV_POP("PVP_Euro7_Portugal") AS stddev_euro7
    FROM "analisis_precios_bmw_euro7"
    WHERE "Portugal" IS NOT NULL AND "PVP_Euro7_Portugal" IS NOT NULL
)
SELECT 
    p."Modelo" AS modelo_vehiculo,
    p."Portugal" AS precio_original,
    ROUND(e.media_original, 2) AS media_mercado_original,
    ROUND(p."Portugal" - e.media_original, 2) AS distancia_a_la_media_orig,
    ROUND(CAST((p."Portugal" - e.media_original) / e.stddev_original AS NUMERIC), 2) AS desviaciones_estandar_orig,
    p."PVP_Euro7_Portugal" AS precio_euro7,
    ROUND(e.media_euro7, 2) AS media_mercado_euro7,
    ROUND(p."PVP_Euro7_Portugal" - e.media_euro7, 2) AS distancia_a_la_media_e7,
    ROUND(CAST((p."PVP_Euro7_Portugal" - e.media_euro7) / e.stddev_euro7 AS NUMERIC), 2) AS desviaciones_estandar_e7
FROM "analisis_precios_bmw_euro7" p, estadisticos e
WHERE p."Modelo" LIKE 'X6 M%' OR p."Modelo" = 'X6 M';

-- Modelos dirigidos a Portugal que conservan un margen neto superior a los 5.000€
SELECT 
    "Modelo" AS modelo_vehiculo,
    "Tecnologia" AS tipo_motor,
    "Pais_Min" AS mercado_compra,
    "Min_Precio_EUR" AS precio_compra_eur,
    "Portugal" AS precio_venta_pt_original,
    "PVP_Euro7_Portugal" AS precio_venta_pt_euro7,
    ("Portugal" - "Min_Precio_EUR") AS margen_bruto_eur,
    ("PVP_Euro7_Portugal" - "Portugal") AS sobrecoste_euro7_pt,
    (("Portugal" - "Min_Precio_EUR") - ("PVP_Euro7_Portugal" - "Portugal") - 2500) AS margen_neto_pt_eur
FROM "analisis_precios_bmw_euro7"
WHERE "Portugal" IS NOT NULL 
  AND "PVP_Euro7_Portugal" IS NOT NULL
  AND (("Portugal" - "Min_Precio_EUR") - ("PVP_Euro7_Portugal" - "Portugal") - 2500) > 5000
ORDER BY margen_neto_pt_eur DESC;


-- -------------------------------------------------------------------------
-- SECCIÓN 7: CASO DE ESTUDIO SUIZA (VENTANAS OPTIMIZADAS DE NEGOCIO)
-- -------------------------------------------------------------------------

-- Modelos dirigidos a Suiza que conservan un margen neto superior a los 5.000€
SELECT 
    "Modelo" AS modelo_vehiculo,
    "Tecnologia" AS tipo_motor,
    "Pais_Min" AS mercado_compra,
    "Min_Precio_EUR" AS precio_compra_eur,
    "Suiza_Euro" AS precio_venta_ch_original,
    "PVP_Euro7_Suiza" AS precio_venta_ch_euro7,
    ("Suiza_Euro" - "Min_Precio_EUR") AS margen_bruto_eur,
    ("PVP_Euro7_Suiza" - "Suiza_Euro") AS sobrecoste_euro7_ch,
    (("Suiza_Euro" - "Min_Precio_EUR") - ("PVP_Euro7_Suiza" - "Suiza_Euro") - 2500) AS margen_neto_ch_eur
FROM "analisis_precios_bmw_euro7"
WHERE "Suiza_Euro" IS NOT NULL 
  AND "PVP_Euro7_Suiza" IS NOT NULL
  AND (("Suiza_Euro" - "Min_Precio_EUR") - ("PVP_Euro7_Suiza" - "Suiza_Euro") - 2500) > 5000
ORDER BY margen_neto_ch_eur DESC;

