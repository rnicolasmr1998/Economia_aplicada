
# Importar datos ---------------------------------------------------------------------------
datos <- setDT(read_dta(paste(clean_data, "data_ena_infobra_primer_modelo.dta", sep = "/")))
datos[, LOG_GASTO := log(GASTO_TOTAL_AGRICOLA + 1)]
datos[, INGRESOS := INGRESO_VENTAS + INGRESO_CONSUMO_HOGAR +
        INGRESO_SEMILLA_AUTO_INSUMO + INGRESO_SEMILLA_VENTA]
datos[, LOG_INGRESOS := log(INGRESOS)]
datos[]

DATA_FINAL <- datos[INGRESOS > 0,.(INGRESOS = mean(INGRESOS)), by = c("ANIO", "OBRA")]

# GRAFICO --------------------------------------------------------------------------------
ggplot(DATA_FINAL, aes(x = ANIO, y = INGRESOS, color = factor(OBRA), group = OBRA)) +
  geom_line(linewidth = 1) +          
  geom_point(size = 2) +                 
  labs(
    title = "Ingresos promedio por año y por obra",
    subtitle = "(Nuevo soles S/.)",
    x = "Año",
    y = "Ingresos promedio",
    color = "Tratamiento"
  ) +
  theme_minimal() +                      # Tema minimalista
  scale_color_grey(start = 0.4, end = 0.8, 
                     labels = c("Sin_obra", "Con_obra")) +
  scale_y_continuous(breaks = seq(1000, 14000, by = 500)) +
  theme(
    plot.title = element_text(hjust = 0, face = "bold", size = 14),
    plot.subtitle = element_text(hjust = 0, size = 12),
    legend.position = "right",                # Leyenda al costado derech   # Color del eje Y
    axis.line.x = element_line(color = "grey", size = 0.5),  # Línea del eje X
    axis.line.y = element_line(color = "grey", size = 0.5)
  )

ggplot(datos, aes(x = LOG_GASTO)) +
  geom_density(fill = "grey", alpha = 0.5) +
  labs(
    title = "Densidad del logaritmo del ingreso",
    x = "Logaritmo del ingreso agricola",
    y = "Densidad"
  ) +
  theme_minimal()

# SEGMENTAR DATOS QUE INGRESOS ES CERO -----------------------------------------------
datos <- datos[INGRESOS != 0,]
datos[GASTO_TOTAL_AGRICOLA == 0]

# DISEÑO MUESTRAL -------------------------------------------------------------------
survey_design <- svydesign(id = ~1, weights = ~FACTOR_EXPANSION, data = datos)

# MODELO DE REGRESION CON EFECTOS TEMPORALES ----------------------------------------
# VARAIBLE DEPENDIENTE: LOG_INGRESOS
# VARIABLE INDEPENDIENTE: OBRA Y ANIO
modelo2 <- svyglm(
  formula = LOG_INGRESOS ~ OBRA + factor(ANIO),
  design = survey_design
)

# MODELO DE REGRESION SIN EFECTOS TEMPORALES ----------------------------------------
# VARAIBLE DEPENDIENTE: LOG_INGRESOS
# VARIABLE INDEPENDIENTE: OBRA
modelo1 <- svyglm(
  formula = LOG_INGRESOS ~ OBRA,
  design = survey_design
)

# RESUMEN DE MODELOS ---------------------------------------------------------------
stargazer(modelo1, modelo2, type = "text", title = "Resumen del Modelo", 
          align = TRUE, digits = 3)

capture.output(
  stargazer(modelo1, modelo2, type = "text", title = "Resumen del Modelo", 
            align = TRUE, digits = 3),
  file = paste(output, "resumen_modelos.txt", sep = "/")  # Nombre del archivo de salida
)
