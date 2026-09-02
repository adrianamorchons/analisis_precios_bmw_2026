## Estructura del proyecto 
```text
.
├── data/               # Datasets limpios y unificados
├── notebooks/          # Notebook con código analítico
├── images/             # Capturas de los gráficos de Plotly/Seaborn
└── README.md           # Guía de presentación
```




## Intro ##

Este es un análisis del catálogo de precios de la marca automovilística BMW para el año 2026, comparando entre diferentes países del entorno europeo: España, Alemania, Francia, Portugal e Italia (Unión Europea) y tomando como referencia de país neutral Suiza.
El presente proyecto sigue una metodología de ciencia de datos siguiendo varias fases: 
- Manipulación e inspección de dataset: mediante tareas básicas como control de calidad de los datos con la librería **pandas**.
- Chequeo de nulos
- Estructura del DataFrame y su contenido (matriz de filas y columnas)
- **Limpieza de strings** y unificación de Dataframe externos
- Análisis estadístico y detección de valores atípicos: Outliers con IQR o Rango intercuartílico, índices de dispersión, coeficientes de variación (CV), desviación estándar, aplicación de lógica de negocio, segmentación por tipos de carrocería, estrategias de *pricing* de la gama X vs. familiar o Touring.
- Visualización y modelado de negocio: matrices de correlación que reflejan la co dependencia de preciso entre países (incluso con divisas diferentes). Impacto de carga impositiva en función del país e influencia de ésta en los preciso finales.
- Simulación de **financiación a través de BMW Select** mediante el análisis de de las condiciones de obtención de crédito (TAE, TIN, cuotas mensuales, cuota final.
- Índice de arbitraje geográfico: identificar el top 5 de modelos con mayor brecha de precio en Europa, que revelan oportunidades de compra donde el precio máximo duplica o triplica el precio de fábrica, y la posibilidad de comprar a través de importación. 

## 📊 Descripción de Gráficos y Visualizaciones

El proyecto incluye un apartado de analítica visual, que permite asimilar los datos de fijación de precios por medio de diferentes enfoques estadísticos:

1. **Histogramas de Distribución por Países:** Muestran la concentración de los precios base del catálogo. Revelan visualmente cómo se comportan los segmentos de acceso en cada mercado.
2. **Diagramas de Caja (*Boxplots*) para la Detección de *Outliers*:** Utilizados para identificar de manera gráfica los modelos que se separan drásticamente de la tendencia central (como el *BMW X5 M*, *X6 M* y el *XM*), visualizando el sesgo hacia las gamas de gran lujo.
3. **Mapas de Calor (*Heatmaps*) de Correlación:** Exponen la fuerte relación lineal (cercana a 1) entre los precios de los diferentes países. Esto demuestra que, a pesar de las barreras fiscales, las variaciones de precio se rigen por factores macroeconómicos globales unificados.
4. **Gráficos de Barras Horizontales e Interactivos (Plotly):** Utilizados para ordenar el catálogo de mayor a menor precio, facilitando al usuario la exploración interactiva del posicionamiento de cada modelo en el mercado.
5. **Gráficos de Líneas de Impacto Fiscal:** Simulan de forma lineal cómo afecta el tipo impositivo de los diferentes IVA sobre un precio base neutro.

---

## 🚀 Futuras Líneas de Investigación: Impacto de la Normativa Euro 7

Este modelo analítico sienta las bases para futuras expansiones del proyecto, orientadas a evaluar el impacto de la inminente normativa de emisiones **Euro 7** en la estrategia de *pricing* de BMW:

*   **Modelización del Coste por Homologación:** La normativa Euro 7 introduce límites más estrictos de emisiones y, por primera vez, regula las partículas de los frenos y microplásticos de los neumáticos. Se investigará cómo se trasladarán estos costes fijos de desarrollo al precio final de los vehículos pequeños (gama de acceso) frente a los SUV de lujo.
*   **Aceleración de la Brecha de Arbitraje:** Dado que algunos países penalizan las emisiones de manera más agresiva que otros mediante impuestos ecológicos de matriculación, la Euro 7 podría fragmentar aún más el mercado. El objetivo será monitorizar si las brechas de arbitraje geográfico entre países (como la brecha actual entre Italia y Suiza) se ensanchan, abriendo nuevas oportunidades de importación.
*   **Penalización a los SUV de Gran Tamaño:** Se analizará si la rigidez de la normativa Euro 7 respecto al peso y las emisiones de partículas por fricción reduce el margen de beneficio de los SUV de alta gama (gama X), forzando a la marca a cambiar su mix de producto hacia berlinas y carrocerías familiares (*Touring*) más eficientes. 


