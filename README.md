# 🚗 Análisis Estratégico de Pricing de BMW (Europa 2026) y Proyección Euro 7

Este proyecto analiza el catálogo de precios de BMW en 2026 comparando mercados clave (España, Alemania, Francia, Portugal e Italia) frente a Suiza como referencia neutral. Utiliza técnicas avanzadas de ciencia de datos para identificar oportunidades de arbitraje geográfico, simular modelos de financiación y evaluar el impacto de las nuevas normativas de emisiones.

---

### 📈 Conclusiones Clave e Impacto de Negocio
* **Riesgo por Normativa Euro 7:** El análisis proyecta que los costes fijos de homologación (límites estrictos y tasas de partículas en frenos/neumáticos) impactarán de forma desproporcionada a los modelos de acceso. Esto provocará un incremento porcentual drástico en su precio final, reduciendo el margen comercial de BMW y dificultando gravemente la fidelización y captura de nuevos clientes.
* **Brecha de Arbitraje Geográfico:** Se detectaron diferencias críticas de precios entre países donde el precio máximo llega a duplicar o triplicar el de origen, abriendo ventanas de oportunidad para la importación.
* **Codependencia Global:** Los mapas de calor demuestran una correlación lineal casi perfecta (~1) entre los precios europeos a pesar de las barreras fiscales, confirmando que las estrategias se rigen por factores macroeconómicos globales unificados.

---

### 🛠️ Estructura del Proyecto y Metodología
El proyecto se divide en módulos que cubren desde la ingesta autónoma de datos (datasets creados mediante extracción propia de las webs oficiales por país) hasta la analítica visual y financiera:
* `data/`: Contiene los conjuntos de datos limpios y unificados.
* `notebooks/`: Código analítico (`pandas` para calidad del dato, limpieza de strings y manejo de outliers por método IQR).
* `images/`: Gráficos interactivos generados para el soporte de decisiones.

---

### 📊 Análisis Técnico y Visualizaciones Incluidas
1. **Distribución por Países:** Histogramas para evaluar la concentración de precios base.
2. **Detección de Outliers:** Boxplots para aislar gamas de gran lujo (como las variantes M y XM).
3. **Matrices de Correlación:** Mapas de calor para validar la sincronización de precios transfronterizos.
4. **Impacto Fiscal y Financiero:** Simulaciones lineales de carga de IVA y modelos de crédito indexados a las condiciones de BMW Select (TAE, TIN y cuotas).
