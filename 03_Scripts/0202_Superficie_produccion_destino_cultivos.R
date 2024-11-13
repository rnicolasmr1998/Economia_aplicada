cat("\014")
'*********************************************************************************
# BASE DE DATOS:	ENA
# PROYECTO: 		  IMPACTO DE LA NO CONCLUSIÓN DE OBRAS EN LA AGRICULTURA
# TÍTULO:         SUPERFICIE COSECHADA, SEMBRADA, PRODUCCION Y DESTINO DE LOS 
                  CULTIVOS COSECHADOS
# AÑOS:				    2015-2019
# AUTOR: 			    RENZO NICOLAS MARROQUIN RUBIO
*********************************************************************************'

# Outline: -----------------------------------------------------------------------

{'
  1. Procesamiento de datos
    1.1. Importar base de datos
      1.1.1. Crear objeto data.table
      1.1.2. Ejecutar bucle
      1.1.3. Modificar la ruta solo para el año 2018
      1.1.4. Importar archivo
    1.2. Filtrar base de datos
      1.2.1. Resultado final de la encuesta
      1.2.2. Código de identificación
      1.2.3. La empresa/ud realizó actividad agricola
      1.2.4. Tipo de cultivo
      1.2.5. Procedencia del agua para el cultivo
    1.3. Crear variables
      1.3.1. UBIGEO
      1.3.2. CODIGO DE IDENTIFICACION
      1.3.3. SUPERFICIE_TOTAL_SEMBRADA
      1.3.4. SUPERFICIE_TOTAL_CULTIVADA
      1.3.5. INGRESOS
    1.4. Renombrar variables
      1.4.1. P102_1 a ACTIVIDAD_AGRICOLA
      1.4.2. P102_2 a ACTIVIDAD_PECUARIA
      1.4.3 P102_2 a ACTIVIDAD_PECUARIA
    1.5. Agrupar por ID, ANIO y UBIGEO
    1.6. Cambiar tipo de dato
    1.7. Ordenar variables
    1.8. Agrupar base de datos
  2. Exportar datos
'}

# ********************************************************************************
# PART 1: Procesamiento de datos -------------------------------------------------
# ********************************************************************************

## 1.1. Importar base de datos ---------------------------------------------------

## 1.1.1. Crear objeto data.table ------------------------------------------------
dataset <- data.table()

## 1.1.2. Ejecutar bucle ---------------------------------------------------------
for (year in names(codigo_inei)) {
  
## 1.1.3. Modificar la ruta solo para el año 2018 --------------------------------
  if (year == "2018") {
    carpeta <- paste0(codigo_inei[[year]][1], "-Modulo-", codigo_inei[[year]][3])
  } else {
    carpeta <- paste0(codigo_inei[[year]][1], "-Modulo", codigo_inei[[year]][3])
  }
  
## 1.1.4. Importar archivo -------------------------------------------------------
  if(year == "2015") {
    data <- setDT(read_sav(paste(raw_data, "ENA", year, carpeta, "02_Cap200AB.SAV", 
                                 sep = "/")))
  } else {
    data <- setDT(read_sav(paste(raw_data, "ENA", year, carpeta, "02_Cap200ab.sav", 
                                 sep = "/")))  
  }
  setnames(data, toupper(names(data)))
  
## 1.2. Filtrar base de datos ----------------------------------------------------
  
## 1.2.1. Resultado final de la encuesta -----------------------------------------
  cat("- El número de encuestas incompletas en el año", 
      year, "es:", data[, .N, by = RESFIN][RESFIN == 2, N], "\n")
  data <- data[RESFIN == 1]
  
## 1.2.2. Código de identificación -----------------------------------------------
  data <- data[CODIGO == 1]
  
## 1.2.3. La empresa/ud realizó actividad agricola -------------------------------
  cat("- El número de pequeños y medianos productores/as agropecuarios/as",
      "en el año", year, "que no realizaron actividad agricola:", 
      data[, .N, by = P102_1][P102_1 == 0, N], "\n")
  data <- data[P102_1 == 1]
  
## 1.2.4. Tipo de cultivo --------------------------------------------------------
  cat("- Cultivos transitorios:", 
      data[, .N, by = P204_TIPO][P204_TIPO == 1, N], "\n")
  cat("- Cultivos permanente de cosecha estacional:", 
      data[, .N, by = P204_TIPO][P204_TIPO == 2, N], "\n")
  cat("- Cultivos permanentes de cosecha continua:", 
      data[, .N, by = P204_TIPO][P204_TIPO == 3, N], "\n")
  # data <- data[P204_TIPO != 1]
  
## 1.2.5. Procedencia del agua para el cultivo -----------------------------------
  cat("Año:", year, "\n")
  cat("- Lluvia:", data[, .N, by = P212][P212 == 1, N], "\n")
  cat("- Otro:", (nrow(data) - data[, .N, by = P212][P212 == 1, N]), "\n")
  # data <- data[P212 != 1]
  
## 1.3. Crear variables ----------------------------------------------------------

## 1.3.1. UBIGEO -----------------------------------------------------------------    
  data[, UBIGEO := paste0(CCDD, CCPP, CCDI)]
  
## 1.3.2. CODIGO DE IDENTIFICACION -----------------------------------------------    
  data[, ID := paste0(CONGLOMERADO, NSELUA, UA)]
  
## 1.3.3. SUPERFICIE_TOTAL_SEMBRADA ----------------------------------------------
  data[, SUPERFICIE_TOTAL_SEMBRADA := P210_SUP_1 +
         as.numeric(paste0("0.", P210_SUP_2))]
  
## 1.3.4. SUPERFICIE_TOTAL_CULTIVADA ---------------------------------------------
  data[, SUPERFICIE_TOTAL_CULTIVADA := P217_SUP_1 +
         as.numeric(paste0("0.", P217_SUP_2))]
  
## 1.3.5. INGRESOS ---------------------------------------------------------------
  data[, INGRESOS := P220_1_VAL + P220_2_VAL + P220_3A_VAL + P220_3B_VAL]
  
## 1.4. Renombrar variables ------------------------------------------------------

## 1.4.1. P102_1 a ACTIVIDAD_AGRICOLA ---------------------------------------------
  setnames(data, "P102_1", "ACTIVIDAD_AGRICOLA") # Posible sesgo de selección
  
## 1.4.2. P102_2 a ACTIVIDAD_PECUARIA --------------------------------------------
  setnames(data, "P102_2", "ACTIVIDAD_PECUARIA")
  
## 1.5. Agrupar por ID, ANIO y UBIGEO --------------------------------------------
  data <- data[, .(INGRESO_VENTAS = sum(P220_1_VAL, na.rm = TRUE),
                   INGRESO_CONSUMO_HOGAR = sum(P220_2_VAL, na.rm = TRUE),
                   INGRESO_SEMILLA_AUTO_INSUMO = sum(P220_3A_VAL, na.rm = TRUE),
                   INGRESO_SEMILLA_VENTA = sum(P220_3B_VAL, na.rm = TRUE),
                   SUPERFICIE_TOTAL_SEMBRADA = sum(SUPERFICIE_TOTAL_SEMBRADA),
                   SUPERFICIE_TOTAL_CULTIVADA = sum(SUPERFICIE_TOTAL_CULTIVADA)),
               by = .(ID, ANIO, UBIGEO)][order(ID)]
  
## 1.6. Cambiar tipo de dato -----------------------------------------------------
  data <- data[, .(
    ID = as.character(ID),
    ANIO = as.character(ANIO),
    UBIGEO = as.character(UBIGEO),
    INGRESO_VENTAS = as.numeric(INGRESO_VENTAS),
    INGRESO_CONSUMO_HOGAR = as.numeric(INGRESO_CONSUMO_HOGAR),
    INGRESO_SEMILLA_AUTO_INSUMO = as.numeric(INGRESO_SEMILLA_AUTO_INSUMO),
    INGRESO_SEMILLA_VENTA = as.numeric(INGRESO_SEMILLA_VENTA),
    SUPERFICIE_TOTAL_SEMBRADA = as.numeric(SUPERFICIE_TOTAL_SEMBRADA),
    SUPERFICIE_TOTAL_CULTIVADA = as.numeric(SUPERFICIE_TOTAL_CULTIVADA)
  )]
  
## 1.7. Ordenar variables --------------------------------------------------------
  data <- data[order(ID, ANIO)]
  
## 1.8. Agrupar base de datos ----------------------------------------------------
  dataset <- rbind(dataset, data, use.names = TRUE)
}

dataset[, .N, by = .(ANIO)]

# ********************************************************************************
# PART 2: Exportar datos ---------------------------------------------------------
# ********************************************************************************

write_dta(data = dataset, 
          path = paste0(clean_data, "/", "superficie_ingresos.dta"))