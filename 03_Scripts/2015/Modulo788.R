cat("\014")
'*********************************************************************************
# BASE DE DATOS:	ENA
# PROYECTO: 		  IMPACTO DE LA NO CONCLUSIÓN DE OBRAS EN LA AGRICULTURA
# TÍTULO:         CLEAN DATA - ENA
# AÑOS:				    2015-2019
# AUTOR: 			    RENZO NICOLAS MARROQUIN RUBIO
*********************************************************************************'

# Outline: -----------------------------------------------------------------------

{'

'}

# ********************************************************************************
# PART 1: Procesamiento de datos -------------------------------------------------
# ********************************************************************************

## 1.1. Importar base de datos ---------------------------------------------------
archivo_data <- paste(raw_data, "ENA", "2015", "506-Modulo788", "01_Cap100_1.sav", 
                      sep = "/")
base_de_datos <- read_sav(archivo_data)
data_ena_2015 <- setDT(base_de_datos)

## 1.2. Segmentar base de datos --------------------------------------------------

## 1.2.1. Resultado final de la encuesta -----------------------------------------
frecuencia_resfin_2 <- data_ena_2015[, .N, by = RESFIN][RESFIN == 2, N]
print(paste("El número de encuestados que no completaron la encuesta es:", 
            frecuencia_resfin_2))
data_ena_2015 <- data_ena_2015[RESFIN == 1]

## 1.3. Código de identificación -------------------------------------------------
# Crear un objeto de encuesta con el factor de expansión
encuesta <- svydesign(ids = ~1, data = data_ena_2015[!is.na(FACTOR)], weights = ~FACTOR)
svytable(~CODIGO, design = encuesta)


nombres_codigos <- c("Pequeños y medianos productores/as agropecuarios/as", 
                     "Grandes productores/as agropecuarios/as")
resultados <- as.data.frame(round(svytable(~CODIGO, design = encuesta)))
resultados$Categoria <- nombres_codigos
colnames(resultados) <- c("Código", "Sum_of_weights", "Categoría")
total <- sum(resultados$`Sum_of_weights`, na.rm = TRUE)
total_fila <- data.frame(Código = "Total", 
                         `Sum_of_weights` = total, 
                         Categoría = "Total")
colnames(total_fila) <- colnames(resultados)
tabla_final <- rbind(resultados, total_fila)[, c("Código", "Categoría", "Sum_of_weights")]
print(tabla_final)

frecuencia_codigo_2 <- data_ena_2015[, .N, by = CODIGO][CODIGO == 2, N]
print(paste("El número de encuestados que son grandes productores/as agropecuarios/as:", 
            frecuencia_codigo_2))

data_ena_2015 <- data_ena_2015[CODIGO == 1]
dim(data_ena_2015)

## 1.4. EN LOS ÚLTIMOS 12 MESES, DE…..A…….., LA EMPRESA/UD, REALIZÓ ACTIVIDAD: ¿Agrícola?
frecuencia_P102_1_0 <- data_ena_2015[, .N, by = P102_1][P102_1 == 0, N]
print(paste("El número de encuestados que no han realizado actividad agricola:", 
            frecuencia_P102_1_0))
data_ena_2015 <- data_ena_2015[P102_1 == 1]

data_ena_2015[, rango_15_anios := cut(P101, breaks = seq(0, max(P101, na.rm = TRUE) + 15, by = 15), 
                                      labels = c("0-14", "15-29", "30-44", "45-59", "60-74", "75+"), 
                                      right = FALSE)]
data_ena_2015[, .N, by = rango_15_anios][order(rango_15_anios)]
data_ena_2015[, .N, by = P102_1]

data_ena_2015 <- data_ena_2015[,.(ANIO, CCDD, NOMBREDD, CCPP, NOMBREPV, CCDI, 
                                  NOMBREDI, CCCP,NOMBRECP, CONGLOMERADO, NSELUA, 
                                  UA, ESTRATO, REGION, Dominio, FACTOR)]
write_dta(data_ena_2015, paste(clean_data, "2015", "01_Cap100_1_clean.dta", sep="/"))
str(data_ena_2015)
