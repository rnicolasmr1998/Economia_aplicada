cat("\014")
'*********************************************************************************
# BASE DE DATOS:	ENA
# PROYECTO: 		  IMPACTO DE LA NO CONCLUSIÓN DE OBRAS EN LA AGRICULTURA
# TÍTULO:         COSTOS DE LA PRODUCCIÓN DE LA ACTIVIDAD AGROPECUARIA
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
      1.4.1. P1001A_TOTAL a GASTO_TOTAL_AGRICOLA
    1.5. Seleccionar variables
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
    carpeta <- paste0(codigo_inei[[year]][1], "-Modulo-", codigo_inei[[year]][19])
  } else if (year == "2019") {
    carpeta <- paste0(codigo_inei[[year]][1], "-Modulo", codigo_inei[[year]][19])
  } else {
    carpeta <- paste0(codigo_inei[[year]][1], "-Modulo", codigo_inei[[year]][18])
  }
  
## 1.1.4. Importar archivo -------------------------------------------------------
  
  if(year != "2018" && year != "2019") {
    data <- setDT(read_sav(paste(raw_data, "ENA", year, carpeta, "17_Cap1000.SAV", 
                                 sep = "/")))
  } else {
    data <- setDT(read_sav(paste(raw_data, "ENA", year, carpeta, "18_Cap1000.sav", 
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
  
## 1.3. Crear variables ----------------------------------------------------------
  
## 1.3.1. UBIGEO -----------------------------------------------------------------
  data[, UBIGEO := paste0(CCDD, CCPP, CCDI)]

## 1.3.2. CODIGO DE IDENTIFICACION -----------------------------------------------    
  data[, ID := paste0(CONGLOMERADO, NSELUA, UA)]
  
## 1.4. Renombrar variables ------------------------------------------------------
  
## 1.4.1. P1001A_TOTAL a GASTO_TOTAL_AGRICOLA ------------------------------------
  setnames(data, "P1001A_TOTAL", "GASTO_TOTAL_AGRICOLA")
  
## 1.5. Seleccionar variables ----------------------------------------------------
  data <- data[, .(ID, ANIO, UBIGEO, GASTO_TOTAL_AGRICOLA)]

## 1.6. Cambiar tipo de dato -----------------------------------------------------
  data <- data[, .(
    ID = as.character(ID),
    ANIO = as.character(ANIO),
    UBIGEO = as.character(UBIGEO),
    GASTO_TOTAL_AGRICOLA = as.numeric(GASTO_TOTAL_AGRICOLA)
  )]
  
## 1.7. Ordenar variables --------------------------------------------------------
  data <- data[order(ID, ANIO, UBIGEO)]
  
## 1.8. Agrupar base de datos ----------------------------------------------------
  dataset <- rbind(dataset, data, use.names = TRUE)  
}

# ********************************************************************************
# PART 2: Exportar datos ---------------------------------------------------------
# ********************************************************************************

write_dta(data = dataset, 
          path = paste0(clean_data, "/", "costos_agricolas.dta"))

dataset[, .N, by = .(ANIO)]
