cat("\014")
'*********************************************************************************
# BASE DE DATOS:	ENA
# PROYECTO: 		  IMPACTO DE LA NO CONCLUSIÓN DE OBRAS EN LA AGRICULTURA
# TÍTULO:         CARACTERÍSTICAS AGROPECUARIAS
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
    1.3. Crear variables
      1.3.1. UBIGEO
      1.3.2. CODIGO DE IDENTIFICACION
      1.3.3.FACTOR DE EXPANSIÓN A DOS CIFRAS
      1.3.4.SUPERFICIE_TOTAL_HECTAREAS
        1.3.4.1. SUPERFICIE TOTAL
        1.3.4.2. Medida de equivalencia a hectáreas
        1.3.4.3. Total de hectáreas
    1.4. Renombrar variables
      1.4.1. P101 a EXPERIENCIA
      1.4.2. P102_1 a ACTIVIDAD_AGRICOLA
      1.4.3. P102_2 a ACTIVIDAD_PECUARIA
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
    carpeta <- paste0(codigo_inei[[year]][1], "-Modulo-", codigo_inei[[year]][2])
  } else {
    carpeta <- paste0(codigo_inei[[year]][1], "-Modulo", codigo_inei[[year]][2])
  }
  
## 1.1.4. Importar archivo -------------------------------------------------------
  data <- setDT(read_sav(paste(raw_data, "ENA", year, carpeta, "01_Cap100_1.sav", 
                               sep = "/")))
  setnames(data, toupper(names(data)))

## 1.2. Filtrar base de datos ----------------------------------------------------

## 1.2.1. Resultado final de la encuesta -----------------------------------------
  cat("- El número de encuestas incompletas en el año", 
      year, "es:", data[, .N, by = RESFIN][RESFIN == 2, N], "\n")
  data <- data[RESFIN == 1]
  
## 1.2.2. Código de identificación -----------------------------------------------
  encuesta <- svydesign(ids = ~1, data = data[!is.na(FACTOR)], weights = ~FACTOR)
  total <- round(svytable(~CODIGO, design = encuesta)[1] + 
                   svytable(~CODIGO, design = encuesta)[2])
  cat("- El total de agricultores en el año", year, "equivale a:", total, "\n")
  cat("- El número de pequeños y medianos productores/as agropecuarios/as",
      "en el año", year, "equivale a:", 
      round(svytable(~CODIGO, design = encuesta)[1]), "agricultores", "\n")
  cat("- El número de grandes productores/as agropecuarios/as",
      "en el año", year, "equivale a:", 
      round(svytable(~CODIGO, design = encuesta)[2]), "agricultores", "\n")
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
  
## 1.3.3.FACTOR DE EXPANSIÓN A DOS CIFRAS ----------------------------------------  
  data[, FACTOR_EXPANSION := round(FACTOR, digits = 2)]
  
## 1.3.4.SUPERFICIE_TOTAL_HECTAREAS ----------------------------------------------  

## 1.3.4.1. SUPERFICIE TOTAL -----------------------------------------------------  
  data[, SUPERFICIE_TOTAL := P104_SUP_1 + 
         as.numeric(paste0("0.", P104_SUP_2))]

## 1.3.4.2. Medida de equivalencia a hectáreas -----------------------------------
  data[, EQUIVALENCIA_HECTAREAS := P104_EQUIV_1 + 
         as.numeric(paste0("0.", P104_EQUIV_2))]

## 1.3.4.3. Total de hectáreas ---------------------------------------------------
  
  data[, SUPERFICIE_TOTAL_HECTAREAS := SUPERFICIE_TOTAL * EQUIVALENCIA_HECTAREAS]

## 1.4. Renombrar variables ------------------------------------------------------
  
## 1.4.1. P101 a EXPERIENCIA ------------------------------------------------------
  setnames(data, "P101", "EXPERIENCIA")
  
## 1.4.2. P102_1 a ACTIVIDAD_AGRICOLA ---------------------------------------------
  setnames(data, "P102_1", "ACTIVIDAD_AGRICOLA") # Posible sesgo de selección

## 1.4.3. P102_2 a ACTIVIDAD_PECUARIA ---------------------------------------------
  setnames(data, "P102_2", "ACTIVIDAD_PECUARIA")
  
## 1.5. Seleccionar variables ----------------------------------------------------
  data <- data[, .(ID, ANIO, UBIGEO, NOMBREDD, NOMBREPV, NOMBREDI, CONGLOMERADO,
                   NSELUA, UA, RESFIN, REGION, DOMINIO, CODIGO, EXPERIENCIA,
                   ACTIVIDAD_AGRICOLA, ACTIVIDAD_PECUARIA, 
                   SUPERFICIE_TOTAL_HECTAREAS, FACTOR_EXPANSION)]
  
## 1.6. Cambiar tipo de dato -----------------------------------------------------
  data <- data[, .(
    ID = as.character(ID),
    ANIO = as.character(ANIO),
    UBIGEO = as.character(UBIGEO),
    NOMBREDD = as.character(NOMBREDD),
    NOMBREPV = as.character(NOMBREPV),
    NOMBREDI = as.character(NOMBREDI),
    CONGLOMERADO = as.character(CONGLOMERADO),
    NSELUA = as.character(NSELUA),
    UA = as.character(UA),
    RESFIN = as.character(RESFIN),
    REGION = as.character(REGION),
    DOMINIO = as.character(DOMINIO),
    CODIGO = as.character(CODIGO),
    EXPERIENCIA = as.numeric(EXPERIENCIA),
    ACTIVIDAD_AGRICOLA = as.character(ACTIVIDAD_AGRICOLA),
    ACTIVIDAD_PECUARIA = as.character(ACTIVIDAD_PECUARIA),
    SUPERFICIE_TOTAL_HECTAREAS = as.numeric(SUPERFICIE_TOTAL_HECTAREAS),
    FACTOR_EXPANSION = as.numeric(FACTOR_EXPANSION)
  )]
  
## 1.7. Ordenar variables --------------------------------------------------------
  data <- data[order(ID, ANIO, UBIGEO)]
  
## 1.8. Agrupar base de datos ----------------------------------------------------
  dataset <- rbind(dataset, data, use.names = TRUE)
}

dataset[, .N, by = .(ANIO)]

# ********************************************************************************
# PART 2: Exportar datos ---------------------------------------------------------
# ********************************************************************************

write_dta(data = dataset, 
          path = paste0(clean_data, "/", "caracteristicas_agropecuarias.dta"))

