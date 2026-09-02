

## 📌 Resumen del Proyecto

Este proyecto ejecuta un análisis estadístico profundo y estratégico sobre la estructura de precios del catálogo de **BMW (2026)** en seis economías clave de Europa: España, Alemania, Francia, Portugal, Italia y Suiza (como referencia neutral). 

A través de una metodología rigurosa de Ciencia de Datos, el estudio no solo procesa datos técnicos, sino que simula escenarios financieros reales e identifica ineficiencias de mercado explotables en la industria automotriz.
Usa el código con precaución.🔍 Puntos Críticos a Resolver (Checklist de Calidad)Para que tu repositorio pase de ser un "proyecto de clase" a un "portafolio senior", realiza estas correcciones técnicas:⚠️ Corrige la Errata del Texto: En la sección de metodología tienes un error de dedo: "Lipieza de strings". Cámbialo inmediatamente por Limpieza de strings.🖼️ Inserta los Gráficos Reales: En la sección "Descripción de Gráficos" detallas histogramas, diagramas de caja y mapas de calor. ¡Tienes que mostrarlos! Guarda los gráficos generados en tu Jupyter Notebook como imágenes .png dentro de una carpeta llamada /images en tu repositorio y muéstralos bajo cada descripción usando este formato:markdown![Mapa de calor de correlación de precios](images/heatmap_correlacion.png)
Usa el código con precaución.📂 Estructura de Archivos Clara: Un repositorio profesional no es solo un archivo suelto. Asegúrate de añadir al final de la introducción un árbol visual que le diga al reclutador dónde está cada elemento:text├── data/               # Datasets limpios y unificados
├── notebooks/          # Tu Jupyter Notebook con el código analítico
├── images/             # Capturas de los gráficos de Plotly/Seaborn
└── README.md           # Esta guía de presentación
Usa el código con precaución.💡 El Toque Maestro: Añade una Sección de "Conclusiones Clave"Los directores de departamentos de Business Intelligence buscan personas que extraigan respuestas rápidas. Agrega un encabezado justo después de tus gráficos con 3 descubrimientos de negocio matadores que arrojó tu script. Por ejemplo:markdown## 💡 Conclusiones del Análisis de Datos (Business Insights)

* **Brecha de Arbitraje Extrema:** Se identificó que el modelo [Modelo X] presenta una disparidad de precio del X% entre Suiza e Italia, convirtiéndolo en el candidato número uno para importación rentable.
* **Elasticidad Fiscal:** Los impuestos de matriculación fragmentan la oferta en el sur de Europa, ensanchando artificialmente el coste de la gama X (SUVs) en comparación con las versiones Touring de Alemania.
* **Viabilidad BMW Select:** La simulación crediticia indica que la cuota final obligatoria disminuye la barrera de entrada al segmento de lujo en un X%, pero incrementa el coste total del activo a largo plazo.
Usa el código con precaución.¿Qué te parece este enfoque? Si tienes los gráficos a mano o tu cuaderno de código listo, podemos trabajar en redactar esas conclusiones de negocio exactas o estructurar el README de perfil principal para tu cuenta de GitHub.Las respuestas de la IA pueden contener errores. Más información

## Intro ##

Este es un análisis del catálogo de precios de la marca automovilística BMW para el año 2026, comparando entre diferentes países del entorno europeo: España, Alemania, Francia, Portugal e Italia (Unión Europea) y tomando como referencia de país neutral Suiza.
El presente proyecto sigue una metodología de ciencia de datos siguiendo varias fases: 
- Manipulación e inspección de dataset: mediante tareas básicas como control de calidad de los datos con la librería **pandas**.
- Chequeo de nulos
- Estructura del DataFrame y su contenido (matriz de filas y columnas)
- **Lipieza de strings** y unificación de Dataframe externos
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

