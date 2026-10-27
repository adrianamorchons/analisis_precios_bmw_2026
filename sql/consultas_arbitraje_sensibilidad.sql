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
    
 -- Impacto de la normativa Euro7 en híbridos 

FROM "analisis_precios_bmw_euro7" apbe
WHERE apbe."Modelo" LIKE '%Touring%'               -- Aseguramos que solo examine la gama familiar
  AND apbe."Tecnologia" NOT LIKE '%Puro%'          -- Excluimos los eléctricos puros (gama i5 Touring)
  AND apbe."Tecnologia" NOT LIKE '%Enchufable%'    -- Excluimos los híbridos (gama 330e/530e) para aislar combustión pura
GROUP BY 1; -- Agrupa basándose en la primera columna calculada (el CASE WHEN)

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

-- Filtrar aquellos modelos que conserven un margen neto superior a 5000€
SELECT 
    "Modelo" AS modelo_vehiculo,
    "Tecnologia" AS tipo_motor,
    "Pais_Min" AS mercado_compra,
    "Min_Precio_EUR" AS precio_compra_eur,
    "Portugal" AS precio_venta_pt_original,
    "PVP_Euro7_Portugal" AS precio_venta_pt_euro7,
    -- 1. Margen Bruto de Arbitraje original hacia Portugal
    ("Portugal" - "Min_Precio_EUR") AS margen_bruto_eur,
    -- 2. Incremento real del precio por la Euro 7 en Portugal
    ("PVP_Euro7_Portugal" - "Portugal") AS sobrecoste_euro7_pt,
    -- 3. CÁLCULO DEL MARGEN NETO POST-EURO 7 
    -- Fórmula: Margen Bruto - Coste Euro 7 - 2500€ de Gastos Logísticos Fijos
    (("Portugal" - "Min_Precio_EUR") - ("PVP_Euro7_Portugal" - "Portugal") - 2500) AS margen_neto_pt_eur
FROM "analisis_precios_bmw_euro7"
WHERE "Portugal" IS NOT NULL 
  AND "PVP_Euro7_Portugal" IS NOT NULL
  -- Filtramos estrictamente los modelos que conservan más de 5.000€ de margen neto
  AND (("Portugal" - "Min_Precio_EUR") - ("PVP_Euro7_Portugal" - "Portugal") - 2500) > 5000
ORDER BY margen_neto_pt_eur DESC;

-- Al cruzarlo con el mercado suizo:
-- Modelos que son rentables comprando en el mercado más barato de Europa e importando hacia Suiza
-- Margen neto: >5000€
-- Coste fijo de logística: 2500€ 

SELECT 
    "Modelo" AS modelo_vehiculo,
    "Tecnologia" AS tipo_motor,
    "Pais_Min" AS mercado_compra,
    "Min_Precio_EUR" AS precio_compra_eur,
    "Suiza_Euro" AS precio_venta_ch_original,
    "PVP_Euro7_Suiza" AS precio_venta_ch_euro7,
    -- 1. Margen Bruto de Arbitraje original hacia Suiza
    ("Suiza_Euro" - "Min_Precio_EUR") AS margen_bruto_eur,
    -- 2. Incremento real del precio por la Euro 7 en Suiza
    ("PVP_Euro7_Suiza" - "Suiza_Euro") AS sobrecoste_euro7_ch,
    -- 3. CÁLCULO DEL MARGEN NETO POST-EURO 7 EN SUIZA
    -- Fórmula: Margen Bruto - Coste Euro 7 - 2500€ de Gastos Logísticos Fijos
    (("Suiza_Euro" - "Min_Precio_EUR") - ("PVP_Euro7_Suiza" - "Suiza_Euro") - 2500) AS margen_neto_ch_eur
FROM "analisis_precios_bmw_euro7"
WHERE "Suiza_Euro" IS NOT NULL 
  AND "PVP_Euro7_Suiza" IS NOT NULL
  -- Filtramos estrictamente los modelos que conservan más de 5.000€ de margen neto en Suiza
  AND (("Suiza_Euro" - "Min_Precio_EUR") - ("PVP_Euro7_Suiza" - "Suiza_Euro") - 2500) > 5000
ORDER BY margen_neto_ch_eur DESC;



 




 
