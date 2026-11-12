-------------------------------------------------------------------------------
-- BLOQUE DE VISUALIZACIÓN Y REPORTES EJECUTIVOS CON CONCAT() Y TRIM()
-------------------------------------------------------------------------------

-- 1. Top 10 rutas comerciales de arbitraje bruto (Limpio y formateado)
-- Combina TRIM() y REPLACE() dentro de CONCAT() para eliminar espacios y el sufijo '_Euro'
SELECT 
    TRIM("Modelo") AS modelo,
    CONCAT(
        REPLACE(TRIM("Pais_Min"), '_Euro', ''), 
        ' ➔ ', 
        REPLACE(TRIM("Pais_Max"), '_Euro', '')
    ) AS ruta_arbitraje,
    CONCAT(
        '+', 
        TO_CHAR(("Max_Precio_EUR" - "Min_Precio_EUR"), 'FM999G999'), 
        ' € (', 
        ROUND(CAST(REPLACE("brecha_arbitraje_%", ',', '.') AS NUMERIC), 1), 
        '%)'
    ) AS margen_bruto
FROM "analisis_precios_bmw_euro7"
WHERE "brecha_arbitraje_%" IS NOT NULL
ORDER BY ("Max_Precio_EUR" - "Min_Precio_EUR") DESC
LIMIT 10;


-- 2. Gráfico visual ASCII: Impacto medio Euro 7 por país (Gama Global BMW)
-- Escala ajustada a divisor 500 para visualización óptima en grilla de DBeaver
WITH datos_normalizados AS (
    SELECT 
        apbe."Modelo",
        p.pais,
        p.precio_base,
        p.precio_euro7
    FROM "analisis_precios_bmw_euro7" apbe
    CROSS JOIN LATERAL (
        VALUES 
            ('España',    apbe."España",    apbe."PVP_Euro7_España"),
            ('Alemania',  apbe."Alemania",  apbe."PVP_Euro7_Alemania"),
            ('Francia',   apbe."Francia",   apbe."PVP_Euro7_Francia"),
            ('Portugal',  apbe."Portugal",  apbe."PVP_Euro7_Portugal"),
            ('Suiza',     apbe."Suiza_Euro", apbe."PVP_Euro7_Suiza")
    ) AS p(pais, precio_base, precio_euro7)
    WHERE p.precio_base IS NOT NULL
),
resumen AS (
    SELECT 
        pais,
        COUNT(*) AS total_modelos,
        ROUND(AVG(precio_euro7 - precio_base), 2) AS impacto_medio_euro7
    FROM datos_normalizados
    GROUP BY pais
)
SELECT 
    pais,
    total_modelos AS modelos,
    CONCAT(
        REPEAT('█', GREATEST(1, CAST(impacto_medio_euro7 / 500 AS INT))), 
        ' ', 
        TO_CHAR(impacto_medio_euro7, 'FM999G999D00'), 
        ' €'
    ) AS impacto_visual_global
FROM resumen
ORDER BY impacto_medio_euro7 DESC;


-- 3. Gráfico visual ASCII: Impacto medio Euro 7 en vehículos Diésel (22 modelos)
WITH datos_normalizados AS (
    SELECT 
        apbe."Modelo",
        p.pais,
        p.precio_base,
        p.precio_euro7
    FROM "analisis_precios_bmw_euro7" apbe
    CROSS JOIN LATERAL (
        VALUES 
            ('España',    apbe."España",    apbe."PVP_Euro7_España"),
            ('Alemania',  apbe."Alemania",  apbe."PVP_Euro7_Alemania"),
            ('Francia',   apbe."Francia",   apbe."PVP_Euro7_Francia"),
            ('Portugal',  apbe."Portugal",  apbe."PVP_Euro7_Portugal"),
            ('Suiza',     apbe."Suiza_Euro", apbe."PVP_Euro7_Suiza")
    ) AS p(pais, precio_base, precio_euro7)
    WHERE p.precio_base IS NOT NULL
      AND (apbe."Modelo" LIKE '%d %' OR apbe."Modelo" LIKE '%d')
      AND apbe."Modelo" NOT LIKE '%eDrive%'
),
resumen AS (
    SELECT 
        pais,
        COUNT(*) AS total_diesel,
        ROUND(AVG(precio_euro7 - precio_base), 2) AS impacto_medio_euro7
    FROM datos_normalizados
    GROUP BY pais
)
SELECT 
    pais,
    total_diesel AS modelos,
    CONCAT(
        REPEAT('█', GREATEST(1, CAST(impacto_medio_euro7 / 500 AS INT))), 
        ' ', 
        TO_CHAR(impacto_medio_euro7, 'FM999G999D00'), 
        ' €'
    ) AS impacto_visual_diesel
FROM resumen
ORDER BY impacto_medio_euro7 DESC;


-- 4. Gráfico visual ASCII: Impacto medio Euro 7 en Gama Touring / Familiar (10 modelos)
WITH datos_normalizados AS (
    SELECT 
        apbe."Modelo",
        p.pais,
        p.precio_base,
        p.precio_euro7
    FROM "analisis_precios_bmw_euro7" apbe
    CROSS JOIN LATERAL (
        VALUES 
            ('España',    apbe."España",    apbe."PVP_Euro7_España"),
            ('Alemania',  apbe."Alemania",  apbe."PVP_Euro7_Alemania"),
            ('Francia',   apbe."Francia",   apbe."PVP_Euro7_Francia"),
            ('Portugal',  apbe."Portugal",  apbe."PVP_Euro7_Portugal"),
            ('Suiza',     apbe."Suiza_Euro", apbe."PVP_Euro7_Suiza")
    ) AS p(pais, precio_base, precio_euro7)
    WHERE p.precio_base IS NOT NULL
      AND apbe."Modelo" LIKE '%Touring%'
),
resumen AS (
    SELECT 
        pais,
        COUNT(*) AS total_touring,
        ROUND(AVG(precio_euro7 - precio_base), 2) AS impacto_medio_euro7
    FROM datos_normalizados
    GROUP BY pais
)
SELECT 
    pais,
    total_touring AS modelos,
    CONCAT(
        REPEAT('█', GREATEST(1, CAST(impacto_medio_euro7 / 500 AS INT))), 
        ' ', 
        TO_CHAR(impacto_medio_euro7, 'FM999G999D00'), 
        ' €'
    ) AS impacto_visual_touring
FROM resumen
ORDER BY impacto_medio_euro7 DESC;


-- 5. Gráfico visual ASCII: Impacto medio Euro 7 en Eléctricos Puros - BEV (8 modelos)
WITH datos_normalizados AS (
    SELECT 
        apbe."Modelo",
        p.pais,
        p.precio_base,
        p.precio_euro7
    FROM "analisis_precios_bmw_euro7" apbe
    CROSS JOIN LATERAL (
        VALUES 
            ('España',    apbe."España",    apbe."PVP_Euro7_España"),
            ('Alemania',  apbe."Alemania",  apbe."PVP_Euro7_Alemania"),
            ('Francia',   apbe."Francia",   apbe."PVP_Euro7_Francia"),
            ('Portugal',  apbe."Portugal",  apbe."PVP_Euro7_Portugal"),
            ('Suiza',     apbe."Suiza_Euro", apbe."PVP_Euro7_Suiza")
    ) AS p(pais, precio_base, precio_euro7)
    WHERE p.precio_base IS NOT NULL
      AND apbe."Tecnologia" LIKE '%Puro%'
),
resumen AS (
    SELECT 
        pais,
        COUNT(*) AS total_electricos,
        ROUND(AVG(precio_euro7 - precio_base), 2) AS impacto_medio_euro7
    FROM datos_normalizados
    GROUP BY pais
)
SELECT 
    pais,
    total_electricos AS modelos,
    CONCAT(
        REPEAT('█', GREATEST(1, CAST(impacto_medio_euro7 / 500 AS INT))), 
        ' ', 
        TO_CHAR(impacto_medio_euro7, 'FM999G999D00'), 
        ' €'
    ) AS impacto_visual_bev
FROM resumen
ORDER BY impacto_medio_euro7 DESC;
