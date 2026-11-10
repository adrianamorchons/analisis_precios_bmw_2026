-- Comprobación rápida. Ver los primeros cinco registros de la tabla
select *
from analisis_precios_bmw_euro7
limit 5; 

-- Validar volumen: debe devolver un total de 38 columnas 
select count(*) as numero_de_columnas
from information_schema.columns 
where table_schema = 'public'
	and table_name = 'analisis_precios_bmw_euro7';

-- Análisis de impacto: 10 vehículos diésel (excluyendo SUV) con mayor incremento porcentual en España
SELECT 
    "Modelo", 
    "categoria_carroceria", 
    "España" AS precio_base, 
    "PVP_Euro7_España" AS precio_con_euro7,
    ("PVP_Euro7_España" - "España") AS coste_extra_euro7,
    ROUND(
        (CAST(("PVP_Euro7_España" - "España") AS NUMERIC) / "España") * 100, 
        2
    ) AS porcentaje_aumento
FROM "analisis_precios_bmw_euro7"
WHERE ("Modelo" LIKE '%d %' OR "Modelo" LIKE '%d')
  AND "Modelo" NOT LIKE '%eDrive%'
  AND "categoria_carroceria" <> 'SUV'
ORDER BY porcentaje_aumento DESC
LIMIT 10;

-- Calcular diferencia de precio original vs precio aplicando euro7
-- Se utilizará 'apbe' como alias para 'analisis_precios_bmw_euro7'
-- Aquí seguimos excluyendo los SUV
SELECT 
    apbe."Modelo",
    apbe."categoria_carroceria",
    apbe."España" AS precio_original,
    apbe."PVP_Euro7_España" AS precio_con_euro7,
    -- Operación para calcular la diferencia en euros:
    (apbe."PVP_Euro7_España" - apbe."España") AS diferencia_euros
FROM "analisis_precios_bmw_euro7" apbe
WHERE apbe."España" IS NOT null
	and apbe."categoria_carroceria" <> 'SUV'
ORDER BY diferencia_euros DESC;

-- Mostrar solamente los modelos eléctricos puros
-- Revisar columna "Tecnología" en el csv y la etiqueta "Eléctrico Puro (BEV)"
-- Se busca solamente la palabra clave "Puro" para evitar conflictos con palabras que lleven acento en el excel 
SELECT 
    apbe."Modelo",
    apbe."categoria_carroceria",
    apbe."Tecnologia",
    apbe."España" AS precio_original,
    apbe."PVP_Euro7_España" AS precio_con_euro7,
    (apbe."PVP_Euro7_España" - apbe."España") AS diferencia_euros
FROM "analisis_precios_bmw_euro7" apbe
WHERE apbe."Tecnologia" LIKE '%Puro%' -- Busca cualquier celda que contenga la palabra Puro
ORDER BY diferencia_euros DESC;

-- Aprovechando el punto anterior: impacto de Euro7 en los modelos eléctricos puros (bev)
-- Coste extra medio y porentaje de aumento promedio 

SELECT 
    COUNT(*) AS total_electricos,
    -- Calcula el coste extra medio en euros
    ROUND(AVG(apbe."PVP_Euro7_España" - apbe."España"), 2) AS coste_extra_medio_eur,
    -- Calcula el impacto porcentual medio
    ROUND(
        AVG(CAST((apbe."PVP_Euro7_España" - apbe."España") AS NUMERIC) / apbe."España" * 100), 
        2
    ) AS porcentaje_aumento_medio
FROM "analisis_precios_bmw_euro7" apbe
WHERE apbe."Tecnologia" LIKE '%Puro%';

-- Cláusula HAVING: 
-- Mostrar coste extra por la normativa Euro7, pero sólo si dicho coste supera los 1000€

SELECT categoria_carroceria, round(AVG("PVP_Euro7_España" - "España"),2) AS coste_medio
FROM analisis_precios_bmw_euro7
GROUP BY categoria_carroceria
HAVING AVG("PVP_Euro7_España" - "España") > 1000; -- Filtra el grupo promediado

-- ¿Los de carrocería familiar están por debajo de los 1000€ de coste extra?
-- Respuesta: NO
-- Palabra clave: Touring 
SELECT 
    'Familiar (Touring)' AS tipo,
    ROUND(AVG("PVP_Euro7_España" - "España"), 2) AS coste_medio_familiar
FROM analisis_precios_bmw_euro7
WHERE "Modelo" LIKE '%Touring%';

-- Comparación carrocería familiar: diesel vs gasolina 
SELECT 
    CASE 
        WHEN apbe."Modelo" LIKE '%d %' OR apbe."Modelo" LIKE '%d' THEN 'Familiar Diésel'
        ELSE 'Familiar Gasolina'
    END AS combustible,
    COUNT(*) AS total_modelos,
    ROUND(AVG(CAST(apbe."España" AS NUMERIC)), 2) AS precio_base_medio,
    ROUND(AVG(CAST(apbe."PVP_Euro7_España" AS NUMERIC) - CAST(apbe."España" AS NUMERIC)), 2) AS coste_extra_medio_eur,
    ROUND(
        AVG(
            (CAST(apbe."PVP_Euro7_España" AS NUMERIC) - CAST(apbe."España" AS NUMERIC)) 
            / CAST(apbe."España" AS NUMERIC) * 100
        ), 
        2
    ) AS porcentaje_aumento_medio
FROM "analisis_precios_bmw_euro7" apbe
WHERE apbe."Modelo" LIKE '%Touring%'               
  AND apbe."Tecnologia" NOT LIKE '%Puro%'          
  AND apbe."Tecnologia" NOT LIKE '%Enchufable%'    
GROUP BY 1;
    

-- Análisis de impacto de la normativa Euro 7 en vehículos Híbridos (PHEV)
SELECT 
    "Modelo",
    "Segmento_Espacio" AS segmento,
    "España" AS precio_base_original,
    "PVP_Euro7_España" AS precio_final_euro7,
    -- Cálculo del coste extra absoluto en euros
    ("PVP_Euro7_España" - "España") AS coste_extra_hibrido_eur,
    -- Cálculo del impacto porcentual relativo sobre el precio base
    ROUND(
        (CAST(("PVP_Euro7_España" - "España") AS NUMERIC) / "España") * 100, 
        2
    ) AS porcentaje_aumento_hibrido
FROM "analisis_precios_bmw_euro7"
WHERE "Tecnologia" LIKE '%Híbrido%' -- Filtra explícitamente la tecnología PHEV
ORDER BY coste_extra_hibrido_eur DESC;

-- Comparativa precios e impacto de Euro7 España vs Suiza

-- Análisis de impacto de la normativa Euro 7 en vehículos Híbridos (PHEV)
SELECT 
    "Modelo",
    "Segmento_Espacio" AS segmento,
    "España" AS precio_base_original,
    "PVP_Euro7_España" AS precio_final_euro7,
    -- Cálculo del coste extra absoluto en euros
    ("PVP_Euro7_España" - "España") AS coste_extra_hibrido_eur,
    -- Cálculo del impacto porcentual relativo sobre el precio base
    ROUND(
        (CAST(("PVP_Euro7_España" - "España") AS NUMERIC) / "España") * 100, 
        2
    ) AS porcentaje_aumento_hibrido
FROM "analisis_precios_bmw_euro7"
WHERE "Tecnologia" LIKE '%Híbrido%' -- Filtra explícitamente la tecnología PHEV
ORDER BY coste_extra_hibrido_eur DESC;

-- Modelo iX: Comparativa precio orignal vs precio con euro7 por países 

SELECT 
    "Modelo",
    "Tecnologia",
    -- ESPAÑA
    "España" AS precio_orig_es,
    "PVP_Euro7_España" AS precio_euro7_es,
    ("PVP_Euro7_España" - "España") AS coste_extra_es,
    -- ALEMANIA
    "Alemania" AS precio_orig_de,
    "PVP_Euro7_Alemania" AS precio_euro7_de,
    ("PVP_Euro7_Alemania" - "Alemania") AS coste_extra_de,
    -- FRANCIA
    "Francia" AS precio_orig_fr,
    "PVP_Euro7_Francia" AS precio_euro7_fr,
    ("PVP_Euro7_Francia" - "Francia") AS coste_extra_fr,
    -- PORTUGAL
    "Portugal" AS precio_orig_pt,
    "PVP_Euro7_Portugal" AS precio_euro7_pt,
    ("PVP_Euro7_Portugal" - "Portugal") AS coste_extra_pt,
    -- ITALIA
    "Italia" AS precio_orig_it,
    "PVP_Euro7_Italia" AS precio_euro7_it,
    ("PVP_Euro7_Italia" - "Italia") AS coste_extra_it,
    -- SUIZA
    "Suiza_Euro" AS precio_orig_ch,
    "PVP_Euro7_Suiza" AS precio_euro7_ch,
    ("PVP_Euro7_Suiza" - "Suiza_Euro") AS coste_extra_ch
FROM "analisis_precios_bmw_euro7"
WHERE "Modelo" LIKE 'iX %';

 
-- Brecha de arbitraje
-- Qué modelos presentan mejor oportunidad de compra en función del país 

SELECT 
    "Modelo",
    "Tecnologia",
    "Pais_Min" AS mercado_mas_barato,
    "Min_Precio_EUR" AS precio_minimo_eur,
    "Pais_Max" AS mercado_mas_caro,
    "Max_Precio_EUR" AS precio_maximo_eur,
    -- Calculamos el beneficio bruto absoluto en euros
    ("Max_Precio_EUR" - "Min_Precio_EUR") AS margen_absoluto_eur,
    -- Reemplazamos la coma por punto antes de aplicar el CAST
    ROUND(CAST(REPLACE("brecha_arbitraje_%", ',', '.') AS NUMERIC), 2) AS porcentaje_brecha
FROM "analisis_precios_bmw_euro7"
WHERE "brecha_arbitraje_%" IS NOT NULL
-- Ordenamos numéricamente usando la misma conversión para evitar orden alfabético incorrecto
ORDER BY CAST(REPLACE("brecha_arbitraje_%", ',', '.') AS NUMERIC) DESC
LIMIT 20;

-- Evaluar el impacto relativo de la normativa Euro7 en el precio final de los modelos diésel 
-- Qué modelos diésel siguen siendo rentables desde el punto de vista de la importación 
-- Qué modelos verán sus márgenes comerciales seriamente afectados 

SELECT 
    "Modelo",
    "categoria_carroceria" AS carroceria,
    "Pais_Min" AS mercado_mas_barato,
    "Min_Precio_EUR" AS precio_minimo_eur,
    "Pais_Max" AS mercado_mas_caro,
    "Max_Precio_EUR" AS precio_maximo_eur,
    -- Margen bruto actual de arbitraje
    ("Max_Precio_EUR" - "Min_Precio_EUR") AS margen_absoluto_eur,
    ROUND(CAST(REPLACE("brecha_arbitraje_%", ',', '.') AS NUMERIC), 2) AS porcentaje_brecha,
    -- Variable Euro 7: Gravedad del impacto sobre el margen comercial
    "Sensibilidad_Euro7" AS sensibilidad_normativa,
    -- Impacto porcentual real de la Euro 7 en el precio final del vehículo
    ROUND(CAST(REPLACE("Impacto_Relativo_%", ',', '.') AS NUMERIC), 2) AS impacto_euro7_porcentaje
FROM "analisis_precios_bmw_euro7"
WHERE "brecha_arbitraje_%" IS NOT NULL
  -- Filtro exclusivo para motores diésel
  AND ("Modelo" LIKE '%d %' OR "Modelo" LIKE '%d')
  AND "Modelo" NOT LIKE '%eDrive%'
-- Ordenamos de mayor a menor impacto de la normativa para identificar los puntos más críticos
ORDER BY CAST(REPLACE("Impacto_Relativo_%", ',', '.') AS NUMERIC) DESC;
 
-- Observaciones: 
-- Los SUV, como X1, X2, X3 sDrive 20d y 18d, aparecen en la parte alta de la consulta con un ALTO impacto relativo de la Euro7
-- (3.6%-3.8%). Al sostener una recha de arbitraje superior al 30%, el negocio de importación absorbe este impacto y retiene margen. 

-- Berlinas y compactos como el Serie 1 118d, Serie 2 Gran Coupe 220d tienen sensbilidad MEDIA
-- El coste absoluto de implantar la tecnología Euro7 (800€) supone un impacto de entre 1.5% y 2% en el precio final. 
-- Al ser modelos con un precio base moderado, el recargo somete al margen comercial a mucha presión, haciendo que 
-- el arbitraje entre países sea más sensibles a cambios logísticos 

-- Inmunidad de la Alta Gama
-- Serie 7 740d: impacto reltivo insignificante (0.66%). Apemas supone diferencia en un modelo
-- cuyo precio base supera los 120000€. 

-- A pesar de las conclusiones anteriores:
-- Suiza y España siguen teniendo un importante mercado de modelos diésel
-- Algunos factores: eficiencia en recorridos largos, y geografía muy montañosa en ambos países 

-- Agrupación de modelos diesel según espacio, calculando precio medio en España
-- coste extra por Euro7 y margen de arrbitraje 

SELECT 
    "Segmento_Espacio" AS segmento_de_espacio,
    COUNT(*) AS total_modelos_diesel,
    -- Precio medio base en el mercado español
    ROUND(AVG("España"), 2) AS precio_medio_es,
    -- Coste extra medio que impondrá la Euro 7 en España
    ROUND(AVG("PVP_Euro7_España" - "España"), 2) AS coste_extra_euro7_medio,
    -- Margen de arbitraje bruto promedio entre países
    ROUND(AVG("Max_Precio_EUR" - "Min_Precio_EUR"), 2) AS margen_arbitraje_medio
FROM "analisis_precios_bmw_euro7"
WHERE ("Modelo" LIKE '%d %' OR "Modelo" LIKE '%d')
  AND "Modelo" NOT LIKE '%eDrive%'
GROUP BY "Segmento_Espacio"
ORDER BY margen_arbitraje_medio DESC;

-- Gama Familiar: Equilibrio. Precio medio de 68250€
-- Berlinas y deportivos: precio medio de 67150

SELECT 
    "Modelo",
    "España" AS precio_base_es,
    "PVP_Euro7_España" AS precio_euro7_es,
    -- Calculamos el coste extra exacto en euros para España
    ("PVP_Euro7_España" - "España") AS coste_extra_euro7_es,
    "Pais_Min" AS mercado_compra,
    "Min_Precio_EUR" AS precio_minimo_eur,
    "Pais_Max" AS mercado_venta,
    "Max_Precio_EUR" AS precio_maximo_eur,
    -- Margen bruto de arbitraje entre el país más barato y el más caro
    ("Max_Precio_EUR" - "Min_Precio_EUR") AS margen_arbitraje_eur,
    ROUND(CAST(REPLACE("brecha_arbitraje_%", ',', '.') AS NUMERIC), 2) AS porcentaje_brecha
FROM "analisis_precios_bmw_euro7"
WHERE ("Modelo" LIKE '%d %' OR "Modelo" LIKE '%d')
  AND "Modelo" NOT LIKE '%eDrive%'
  AND "Segmento_Espacio" = 'Gama Touring (Familiar)'
ORDER BY margen_arbitraje_eur DESC;

-- Serie 3 Touring M340d xDrive (Tope de gama y prestaciones para montaña)
-- Serie 5 Touring 520d (Rutero por excelencia)
-- Serie 3 Touring 318d (La opción de acceso eficiente)

-- Margen neto estimado para los tres modelos anteriores 

SELECT 
    "Modelo",
    "Pais_Min" AS mercado_compra,
    "Min_Precio_EUR" AS precio_compra_eur,
    "Pais_Max" AS mercado_venta,
    "Max_Precio_EUR" AS precio_venta_eur,
    -- 1. Margen Bruto de Arbitraje Actual
    ("Max_Precio_EUR" - "Min_Precio_EUR") AS margen_bruto_arbitraje_eur,
    -- 2. Impacto Económico de la Euro 7 en España
    ("PVP_Euro7_España" - "España") AS coste_extra_euro7_es,
    -- 3. CÁLCULO DEL MARGEN NETO ESTIMADO
    -- Fórmula: Margen Bruto - Coste Euro 7 - 2500€ (Gastos Logísticos Fijos)
    (("Max_Precio_EUR" - "Min_Precio_EUR") - ("PVP_Euro7_España" - "España") - 2500) AS margen_neto_estimado_eur,
    -- Porcentaje de rentabilidad neta sobre el precio de compra original
    ROUND(
        (CAST((("Max_Precio_EUR" - "Min_Precio_EUR") - ("PVP_Euro7_España" - "España") - 2500) AS NUMERIC) / "Min_Precio_EUR") * 100, 
        2
    ) AS porcentaje_rentabilidad_neta
FROM "analisis_precios_bmw_euro7"
WHERE ("Modelo" LIKE '%d %' OR "Modelo" LIKE '%d')
  AND "Modelo" NOT LIKE '%eDrive%'
  AND "Segmento_Espacio" = 'Gama Touring (Familiar)'
ORDER BY margen_neto_estimado_eur DESC;

-- Portugal: presenta el mayor tipo impositivo de la muestra (23% de iva)
-- El comportamiento de los precios finales y el margen de arbitraje se verán significativamente afectado
-- A continuación se muestran los modelos con más sensibilidad, 
-- oportunidades compraventa e impacto por tecnología

-- 1ª consulta: los 10 modelos más caros en Portugal sin aplicar normativa Euro7

-- CONSULTA 1: Top 10 modelos más caros en Portugal SIN la normativa Euro 7
SELECT 
    "Modelo" AS modelo_vehiculo,
    "Tecnologia" AS tipo_motor,
    "Portugal" AS precio_original_pt,
    "PVP_Euro7_Portugal" AS precio_con_euro7_pt,
    ("PVP_Euro7_Portugal" - "Portugal") AS incremento_absoluto
FROM "analisis_precios_bmw_euro7"
WHERE "Portugal" IS NOT NULL
ORDER BY "Portugal" DESC
LIMIT 10;


-- CONSULTA 2: Top 10 modelos más caros en Portugal CON la normativa Euro 7
SELECT 
    "Modelo" AS modelo_vehiculo,
    "Tecnologia" AS tipo_motor,
    "Portugal" AS precio_original_pt,
    "PVP_Euro7_Portugal" AS precio_con_euro7_pt,
    ("PVP_Euro7_Portugal" - "Portugal") AS incremento_absoluto
FROM "analisis_precios_bmw_euro7"
WHERE "PVP_Euro7_Portugal" IS NOT NULL
ORDER BY "PVP_Euro7_Portugal" DESC
LIMIT 10;

-- El X6 M es el modelo más caro en términos absolutos. 
-- Al aplicar la tenología inherente a Euro7, su coste total aumenta en 56.264€, 
-- pasando a costar 291.264€. 
-- Se trata de un outlier o valor atípico 
	-- Supera por más de 95.000€ a modelos de gama muy alta
	-- Supera en casi 100.000€ al XM, a pesar de que este modelo nació bajo la división M. 
-- Fiscalidad lusa: dos factores que hacen que el X6 M suba su precio de forma desorbitada:
	-- Se aplica la tasa máxima del impuesto ISV, al ser un modelo de combustión sin hibridación 
	-- Peso: aumento de costes de homologación por peso y emisiones de partículas de frenos y neumáticos
	-- dados por los nuevos estándares, traducido en más tramos de impuestos.

-- Desviación estándar
-- Puntuación z-score
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
    p."Modelo",
    p."Portugal" AS precio_original,
    ROUND(e.media_original, 2) AS media_mercado_original,
    ROUND(p."Portugal" - e.media_original, 2) AS distancia_a_la_media_orig,
    ROUND(CAST((p."Portugal" - e.media_original) / e.stddev_original AS NUMERIC), 2) AS desviaciones_estandar_orig,
    p."PVP_Euro7_Portugal" AS precio_euro7,
    ROUND(e.media_euro7, 2) AS media_mercado_euro7,
    ROUND(p."PVP_Euro7_Portugal" - e.media_euro7, 2) AS distancia_a_la_media_e7,
    ROUND(CAST((p."PVP_Euro7_Portugal" - e.media_euro7) / e.stddev_euro7 AS NUMERIC), 2) AS desviaciones_estandar_e7
FROM "analisis_precios_bmw_euro7" p, estadisticos e
WHERE p."Modelo" LIKE 'X6 M %' OR p."Modelo" = 'X6 M';

-- COMPARATIVA DE MARGENES NETOS: PORTUGAL VS SUIZA (POST-EURO 7)
-- Aplica costes logísticos fijos (2500€) y evalúa rentabilidad mayor a 5000€ en cualquiera de los destinos
SELECT 
    "Modelo" AS modelo_vehiculo,
    "Tecnologia" AS tipo_motor,
    "Pais_Min" AS mercado_compra,
    "Min_Precio_EUR" AS precio_compra_eur,
    
    -- DATOS PORTUGAL
    "Portugal" AS precio_venta_pt_original,
    (("Portugal" - "Min_Precio_EUR") - ("PVP_Euro7_Portugal" - "Portugal") - 2500) AS margen_neto_pt_eur,
    
    -- DATOS SUIZA
    "Suiza_Euro" AS precio_venta_ch_original,
    (("Suiza_Euro" - "Min_Precio_EUR") - ("PVP_Euro7_Suiza" - "Suiza_Euro") - 2500) AS margen_neto_ch_eur,
    
    -- ANÁLISIS DE DECISIÓN: ¿Cuál mercado deja más margen neto?
    CASE 
        WHEN (("Portugal" - "Min_Precio_EUR") - ("PVP_Euro7_Portugal" - "Portugal") - 2500) > 
             (("Suiza_Euro" - "Min_Precio_EUR") - ("PVP_Euro7_Suiza" - "Suiza_Euro") - 2500) THEN 'Portugal'
        ELSE 'Suiza'
    END AS destino_mas_rentable
FROM "analisis_precios_bmw_euro7"
WHERE "Portugal" IS NOT NULL 
  AND "PVP_Euro7_Portugal" IS NOT NULL
  AND "Suiza_Euro" IS NOT NULL 
  AND "PVP_Euro7_Suiza" IS NOT NULL
  -- Filtramos si al menos uno de los dos países supera el umbral de los 5.000€ de beneficio neto
  AND (
      (("Portugal" - "Min_Precio_EUR") - ("PVP_Euro7_Portugal" - "Portugal") - 2500) > 5000
      OR 
      (("Suiza_Euro" - "Min_Precio_EUR") - ("PVP_Euro7_Suiza" - "Suiza_Euro") - 2500) > 5000
  )
-- En PostgreSQL podemos ordenar directamente usando la operación aritmética del mayor margen estimado
ORDER BY GREATEST(
    (("Portugal" - "Min_Precio_EUR") - ("PVP_Euro7_Portugal" - "Portugal") - 2500),
    (("Suiza_Euro" - "Min_Precio_EUR") - ("PVP_Euro7_Suiza" - "Suiza_Euro") - 2500)
) DESC;

-- Porcentaje neto de rentabilidad
-- Se calcula el margen neto y se divide entre el precio de compra en mercado de origen *100
-- Incluye el rendimiento máximo alcanzable 

-- COMPARATIVA DE MÁRGENES Y PORCENTAJES DE RENTABILIDAD NETAS (POST-EURO 7)
SELECT 
    "Modelo" AS modelo_vehiculo,
    "Tecnologia" AS tipo_motor,
    "Pais_Min" AS mercado_compra,
    "Min_Precio_EUR" AS precio_compra_eur,
    
    -- PORTUGAL: Margen absoluto y Porcentaje de rentabilidad neta
    (("Portugal" - "Min_Precio_EUR") - ("PVP_Euro7_Portugal" - "Portugal") - 2500) AS margen_neto_pt_eur,
    ROUND(
        (CAST((("Portugal" - "Min_Precio_EUR") - ("PVP_Euro7_Portugal" - "Portugal") - 2500) AS NUMERIC) 
        / "Min_Precio_EUR") * 100, 
        2
    ) AS rentabilidad_neta_pt_porc,
    
    -- SUIZA: Margen absoluto y Porcentaje de rentabilidad neta
    (("Suiza_Euro" - "Min_Precio_EUR") - ("PVP_Euro7_Suiza" - "Suiza_Euro") - 2500) AS margen_neto_ch_eur,
    ROUND(
        (CAST((("Suiza_Euro" - "Min_Precio_EUR") - ("PVP_Euro7_Suiza" - "Suiza_Euro") - 2500) AS NUMERIC) 
        / "Min_Precio_EUR") * 100, 
        2
    ) AS rentabilidad_neta_ch_porc,
    
    -- ANÁLISIS DE DECISIÓN: Mercado óptimo y rentabilidad máxima esperada
    CASE 
        WHEN (("Portugal" - "Min_Precio_EUR") - ("PVP_Euro7_Portugal" - "Portugal") - 2500) > 
             (("Suiza_Euro" - "Min_Precio_EUR") - ("PVP_Euro7_Suiza" - "Suiza_Euro") - 2500) THEN 'Portugal'
        ELSE 'Suiza'
    END AS destino_mas_rentable,
    
    GREATEST(
        ROUND((CAST((("Portugal" - "Min_Precio_EUR") - ("PVP_Euro7_Portugal" - "Portugal") - 2500) AS NUMERIC) / "Min_Precio_EUR") * 100, 2),
        ROUND((CAST((("Suiza_Euro" - "Min_Precio_EUR") - ("PVP_Euro7_Suiza" - "Suiza_Euro") - 2500) AS NUMERIC) / "Min_Precio_EUR") * 100, 2)
    ) AS max_rentabilidad_porc

FROM "analisis_precios_bmw_euro7"
WHERE "Portugal" IS NOT NULL 
  AND "PVP_Euro7_Portugal" IS NOT NULL
  AND "Suiza_Euro" IS NOT NULL 
  AND "PVP_Euro7_Suiza" IS NOT NULL
  -- Filtro de viabilidad comercial (mantiene modelos con margen positivo en algún destino)
  AND (
      (("Portugal" - "Min_Precio_EUR") - ("PVP_Euro7_Portugal" - "Portugal") - 2500) > 5000
      OR 
      (("Suiza_Euro" - "Min_Precio_EUR") - ("PVP_Euro7_Suiza" - "Suiza_Euro") - 2500) > 5000
  )
-- Ordenamos de mayor a menor rentabilidad porcentual máxima
ORDER BY max_rentabilidad_porc DESC;

-- Visión de retorno de inversión (ROI). Al calcular el porcentaje sobre el coste "min_precio_eur"
-- vemos que el X5 M (Con casi 14000€ de margen) es más eficiente en términos de capital
-- que otros modelos que requieren menos inversión inicial 

-- Rentabilidad de los modelos de la división M (Independientemente del país)
-- objetivo: evaluar el rendimiento en todos los mercados de destino disponibles
-- Margen promedio en euros y porcentaje de rentabilidad promedio para cada modelo M 

-- COMPARATIVA DE RENDIMIENTO ECONÓMICO PROMEDIO DE LA DIVISIÓN M (POST-EURO 7) - CORREGIDA
SELECT 
    apbe."Modelo" AS modelo_m,
    apbe."Tecnologia" AS tipo_motor,
    apbe."Pais_Min" AS mercado_origen_compra,
    apbe."Min_Precio_EUR" AS coste_capital_compra_eur,
    
    -- 1. Promedio de los márgenes netos estimados en los tres mercados destino principales
    ROUND(AVG(
        (
            ((apbe."España" - apbe."Min_Precio_EUR") - ("PVP_Euro7_España" - apbe."España") - 2500) +
            ((apbe."Portugal" - apbe."Min_Precio_EUR") - ("PVP_Euro7_Portugal" - apbe."Portugal") - 2500) +
            ((apbe."Suiza_Euro" - apbe."Min_Precio_EUR") - ("PVP_Euro7_Suiza" - apbe."Suiza_Euro") - 2500)
        ) / 3
    ), 2) AS margen_neto_promedio_eur,

    -- 2. Rendimiento de Capital Promedio (ROI % medio sobre la inversión inicial de compra)
    ROUND(AVG(
        CAST(
            (
                ((apbe."España" - apbe."Min_Precio_EUR") - ("PVP_Euro7_España" - apbe."España") - 2500) +
                ((apbe."Portugal" - apbe."Min_Precio_EUR") - ("PVP_Euro7_Portugal" - apbe."Portugal") - 2500) +
                ((apbe."Suiza_Euro" - apbe."Min_Precio_EUR") - ("PVP_Euro7_Suiza" - apbe."Suiza_Euro") - 2500)
            ) / 3 AS NUMERIC) 
        / apbe."Min_Precio_EUR" * 100
    ), 2) AS roi_promedio_porcentaje,

    -- 3. Identificación del canal individual más rentable para el modelo
    CASE 
        WHEN (("Portugal" - apbe."Min_Precio_EUR") - ("PVP_Euro7_Portugal" - "Portugal") - 2500) >= 
             (("Suiza_Euro" - apbe."Min_Precio_EUR") - ("PVP_Euro7_Suiza" - "Suiza_Euro") - 2500) 
             AND (("Portugal" - apbe."Min_Precio_EUR") - ("PVP_Euro7_Portugal" - "Portugal") - 2500) >=
                 (("España" - apbe."Min_Precio_EUR") - ("PVP_Euro7_España" - apbe."España") - 2500) THEN 'Portugal'
        WHEN (("Suiza_Euro" - apbe."Min_Precio_EUR") - ("PVP_Euro7_Suiza" - "Suiza_Euro") - 2500) >= 
             (("Portugal" - apbe."Min_Precio_EUR") - ("PVP_Euro7_Portugal" - "Portugal") - 2500) 
             AND (("Suiza_Euro" - apbe."Min_Precio_EUR") - ("PVP_Euro7_Suiza" - "Suiza_Euro") - 2500) >=
                 (("España" - apbe."Min_Precio_EUR") - ("PVP_Euro7_España" - apbe."España") - 2500) THEN 'Suiza'
        ELSE 'España'
    END AS canal_destino_optimo

FROM "analisis_precios_bmw_euro7" apbe
WHERE (apbe."Modelo" LIKE '% M%' OR apbe."Modelo" LIKE 'M%') 
  AND apbe."Portugal" IS NOT NULL 
  AND apbe."Suiza_Euro" IS NOT NULL
GROUP BY 
    apbe."Modelo", 
    apbe."Tecnologia", 
    apbe."Pais_Min", 
    apbe."Min_Precio_EUR",
    apbe."España",
    apbe."Portugal",
    apbe."Suiza_Euro",
    apbe."PVP_Euro7_España",
    apbe."PVP_Euro7_Portugal",
    apbe."PVP_Euro7_Suiza"
ORDER BY roi_promedio_porcentaje DESC;

-- Conclusiones:
-- X6 xDrive 40i MSport no es un "M" puro, pero su coste de compra en Italia (97800€)
-- frente a su precio final lo convierte en el modelo con mejor ROI promedio (2.25%) y un margen de 2197€

-- "M" puros como M3 Touring, M4 Cabrio, M2 o X6 M resisten pero al límite. El arbitraje en estos casos
-- se vuelve muy estrecho. Modelos como el M4 Cabrio y el M3 Touring retienen una rentabilidadd
-- muy baja (1.47% y 0.81% respectivamente). Al aplicar la Euro7, el margen bruto de importación desaparece. 

-- Zona roja: a partir del X5 M se dan pérdidas de margen (hasta 9450€ en un Serie 4 Cabrio M440i).
-- Euro7 destruye completamente el modelo de arbitraje para deportivos medianos y de acceso, 
-- pues el precio final en destino supera la brecha de precios original entre mercados 
-------------------------------------------------------------------------------

-- Escenario: un comprador suizo que busca adquirir un modelo diésel en el mercado español
-- Porcentaje de rentabilidad neta superior al 5% (tras absorber coste de normativa Euro7)
-- para ello se aplica un filtro analítico en la clausula WHERE o HAVING

-- MODELOS DIÉSEL VIABLES PARA IMPORTACIÓN A SUIZA DESDE ESPAÑA (RENTABILIDAD > 5%)
SELECT 
    apbe."Modelo" AS modelo_vehiculo,
    apbe."Segmento_Espacio" AS segmento,
    apbe."España" AS precio_compra_es,
    apbe."Suiza_Euro" AS precio_venta_ch_original,
    
    -- 1. Coste extra que impondrá la Euro 7 en el mercado de destino (Suiza)
    ("PVP_Euro7_Suiza" - "Suiza_Euro") AS coste_extra_euro7_ch,
    
    -- 2. Cálculo del Margen Neto Real en Euros
    -- Fórmula: (Precio Venta Suiza - Precio Compra España) - Coste Euro 7 Suiza - Gastos Logísticos Fijos
    (
        ("Suiza_Euro" - apbe."España") 
        - ("PVP_Euro7_Suiza" - "Suiza_Euro") 
        - 2500
    ) AS margen_neto_real_eur,
    
    -- 3. Porcentaje de Rentabilidad Neta (ROI) sobre el Capital Invertido (Precio de Compra en España)
    ROUND(
        (CAST(
            (
                ("Suiza_Euro" - apbe."España") 
                - ("PVP_Euro7_Suiza" - "Suiza_Euro") 
                - 2500
            ) AS NUMERIC) 
        / apbe."España") * 100, 
        2
    ) AS porcentaje_rentabilidad_neta

FROM "analisis_precios_bmw_euro7" apbe
WHERE 
    -- Filtro exclusivo para motores diésel de combustión
    ("Modelo" LIKE '%d %' OR "Modelo" LIKE '%d')
    AND "Modelo" NOT LIKE '%eDrive%'
    -- Asegurar consistencia de datos en los países analizados
    AND apbe."España" IS NOT NULL 
    AND apbe."Suiza_Euro" IS NOT NULL
    AND "PVP_Euro7_Suiza" IS NOT NULL
    -- FILTRO CLAVE: Solo operaciones con ROI neto superior al 5%
    AND (
        (CAST(
            (
                ("Suiza_Euro" - apbe."España") 
                - ("PVP_Euro7_Suiza" - "Suiza_Euro") 
                - 2500
            ) AS NUMERIC) 
        / apbe."España") * 100
    ) > 5.00
ORDER BY porcentaje_rentabilidad_neta DESC;

-- el Serie 4 Coupe 420d se muestra como líder absoluto de rentabilidad con un 42.97%
-- Le siguen de cerca las berlinas de acceso de la Serie 3
-- ¿Cuál es el margen neto absoluto en euros que deja este 42.97%?

-- ANÁLISIS DE MARGEN ABSOLUTO PARA EL LÍDER DE RENTABILIDAD (SERIE 4 COUPÉ 420d)
SELECT 
    apbe."Modelo" AS modelo_vehiculo,
    apbe."España" AS precio_compra_españa_eur,
    apbe."Suiza_Euro" AS precio_venta_suiza_eur,
    ("PVP_Euro7_Suiza" - "Suiza_Euro") AS coste_extra_euro7_suiza_eur,
    2500 AS gastos_logisticos_fijos_eur,
    
    -- Beneficio Neto Absoluto en Euros líquidos
    (
        ("Suiza_Euro" - apbe."España") 
        - ("PVP_Euro7_Suiza" - "Suiza_Euro") 
        - 2500
    ) AS margen_neto_absoluto_eur,
    
    -- Tu porcentaje ya validado
    ROUND(
        (CAST(
            (
                ("Suiza_Euro" - apbe."España") 
                - ("PVP_Euro7_Suiza" - "Suiza_Euro") 
                - 2500
            ) AS NUMERIC) 
        / apbe."España") * 100, 
        2
    ) AS porcentaje_rentabilidad_neta

FROM "analisis_precios_bmw_euro7" apbe
WHERE apbe."Modelo" LIKE 'Serie 4 coupe 420d%';

-- UNPIVOT / CROSS JOIN LATERAL 
-- Tener una gila por cada combinación de modelo, país y precio base 
SELECT 
    apbe."Modelo",
    apbe."Tecnologia",
    apbe."categoria_carroceria",
    p.pais,
    p.precio_base,
    p.precio_euro7,
    (p.precio_euro7 - p.precio_base) AS coste_extra_euro7
FROM "analisis_precios_bmw_euro7" apbe
CROSS JOIN LATERAL (
    VALUES 
        ('España',    apbe."España",    apbe."PVP_Euro7_España"),
        ('Alemania',  apbe."Alemania",  apbe."PVP_Euro7_Alemania"),
        ('Francia',   apbe."Francia",   apbe."PVP_Euro7_Francia"),
        ('Portugal',  apbe."Portugal",  apbe."PVP_Euro7_Portugal"),
        ('Suiza',     apbe."Suiza_Euro", apbe."PVP_Euro7_Suiza")
) AS p(pais, precio_base, precio_euro7)
WHERE p.precio_base IS NOT NULL;

-- Qué obtenemos con esta consulta:
-- Los países ya no son columnas separadas, y permite introducir toda la consulta en una CTE para calcular promedios 

-- Ejemplo: conocer coste medio extra de la Euro7 y precio base promedio por país 
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
)
SELECT 
    pais,
    ROUND(AVG(precio_base), 2) AS precio_base_promedio,
    ROUND(AVG(precio_euro7 - precio_base), 2) AS impacto_medio_euro7,
    COUNT(*) AS modelos_disponibles
FROM datos_normalizados
GROUP BY pais
ORDER BY precio_base_promedio DESC;

-- Gráfico de barras 
-- texto plano 

-- Ejecuta esto para ver un gráfico de barras textual inmediato
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
        ROUND(AVG(precio_euro7 - precio_base), 2) AS impacto_medio_euro7
    FROM datos_normalizados
    GROUP BY pais
)
SELECT 
    pais,
    impacto_medio_euro7,
    -- Creamos una barra visual repitiendo el caracter '█' 
    -- Dividimos entre 20 para ajustar la escala del gráfico al ancho de la pantalla
    REPEAT('█', CAST(impacto_medio_euro7 / 20 AS INT)) AS grafico_barras
FROM resumen
ORDER BY impacto_medio_euro7 DESC;
 






