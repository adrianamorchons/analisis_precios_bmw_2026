-- =========================================================================
-- PROYECTO: Análisis Estratégico de Pricing de BMW (Europa 2026)
-- MÓDULO: Consultas SQL Analíticas Avanzadas - Impacto Normativa Euro 7
-- =========================================================================

-- 1. ANÁLISIS ESTADÍSTICO DE DISPERSIÓN (Z-SCORE)
-- Propósito: Medir matemáticamente el nivel de 'outlier' del BMW X6 M en Portugal.
-- Una puntuación Z > 3.0 confirma un caso atípico extremo aislado por la carga fiscal lusa.

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


-- 2. FILTRADO DE VENTANAS DE ARBITRAJE COMERCIAL (DESTINO SUIZA)
-- Propósito: Aislar los modelos que conservan un margen neto superior a los 5.000€.
-- Deduce el incremento de la Euro 7 en Suiza y 2.500€ de costes logísticos fijos.

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
