cat("\014")
'*********************************************************************************
# BASE DE DATOS:	ENA
# PROYECTO: 		  IMPACTO DE LA NO CONCLUSIÓN DE OBRAS EN LA AGRICULTURA
# TÍTULO:         CARACTERISTICAS DEL PRODUCTOR/A AGROPECUARIO/A Y SU FAMILIA
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
      1.2.4. Relación de parentesco - Productor/a
    1.3. Crear variables
      1.3.1. UBIGEO
      1.3.2. CODIGO DE IDENTIFICACION
      1.3.3. NIVEL_EDUCATIVO
      1.3.4. DISCAPACIDAD
    1.4. Renombrar variables
      1.4.1. P1102 a PRODUCTOR
      1.4.2. P1103 a SEXO
      1.4.3. P1104_A a EDAD
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
    carpeta <- paste0(codigo_inei[[year]][1], "-Modulo-", codigo_inei[[year]][20])
  } else if (year == "2019") {
    carpeta <- paste0(codigo_inei[[year]][1], "-Modulo", codigo_inei[[year]][20])
  } else {
    carpeta <- paste0(codigo_inei[[year]][1], "-Modulo", codigo_inei[[year]][19])
  }
  
## 1.1.4. Importar archivo -------------------------------------------------------
  
  if(year != "2018" && year != "2019") {
    data <- setDT(read_sav(paste(raw_data, "ENA", year, carpeta, "18_Cap1100.sav", 
                                 sep = "/")))
  } else {
    data <- setDT(read_sav(paste(raw_data, "ENA", year, carpeta, "19_Cap1100.sav", 
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

## 1.2.4. Relación de parentesco - Productor/a -----------------------------------
  data <- data[P1102 == 1]
  
## 1.3. Crear variables ----------------------------------------------------------
  
## 1.3.1. UBIGEO -----------------------------------------------------------------
  data[, UBIGEO := paste0(CCDD, CCPP, CCDI)]
  
## 1.3.2. CODIGO DE IDENTIFICACION -----------------------------------------------    
  data[, ID := paste0(CONGLOMERADO, NSELUA, UA)]

## 1.3.3. NIVEL_EDUCATIVO --------------------------------------------------------
  data[, PRIMARIA_COMPLETA := ifelse(P1105 >= 4, 1, 0)]
  
## 1.3.4. DISCAPACIDAD -----------------------------------------------------------
  data[, DISCAPACIDAD := ifelse(P1108_1 == 1 | P1108_2 == 1 | P1108_3 == 1 |
                                  P1108_4 == 1 | P1108_5 == 1 | P1108_6 == 1,
                                1, 0)]
    
## 1.4. Renombrar variables ------------------------------------------------------
  
## 1.4.1. P1102 a PRODUCTOR ------------------------------------------------------
  setnames(data, "P1102", "PRODUCTOR")

## 1.4.2. P1103 a SEXO -----------------------------------------------------------
  setnames(data, "P1103", "SEXO")
  
## 1.4.3. P1104_A a EDAD ---------------------------------------------------------
  setnames(data, "P1104_A", "EDAD")
  
## 1.5. Seleccionar variables ----------------------------------------------------
  data <- data[, .(ID, ANIO, UBIGEO, PRIMARIA_COMPLETA, DISCAPACIDAD, PRODUCTOR,
                   SEXO, EDAD)]
  
## 1.6. Cambiar tipo de dato -----------------------------------------------------
  data <- data[, .(
    ID = as.character(ID),
    ANIO = as.character(ANIO),
    UBIGEO = as.character(UBIGEO),
    PRIMARIA_COMPLETA = as.character(PRIMARIA_COMPLETA),
    DISCAPACIDAD = as.character(DISCAPACIDAD),
    PRODUCTOR = as.character(PRODUCTOR),
    SEXO = as.character(SEXO),
    EDAD = as.numeric(EDAD)
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
          path = paste0(clean_data, "/", "caracteristicas_productos.dta"))

dataset[, .N, by = .(ANIO)]
