cat("\014")
'*********************************************************************************
# BASE DE DATOS:	ENA
# PROYECTO: 		  IMPACTO DE LA NO CONCLUSIÓN DE OBRAS EN LA AGRICULTURA
# TÍTULO:         LIMPIEZA DE DATOS DE INFOBRAS
# AÑOS:				    2015-2019
# AUTOR: 			    RENZO NICOLAS MARROQUIN RUBIO
*********************************************************************************'

# Outline: -----------------------------------------------------------------------

{'
  1. Procesamiento de datos
    1.1. Importar base de datos
    1.2. Seleccionar variables
    1.3. Renombrar variables
    1.4. Cambiar tipo de datos
    1.5. Filtrar datos
      1.5.1. TIPO DE OBRA - CLASIFICADOR NIVEL 1
      1.5.2. TIPO DE OBRA - CLASIFICADOR NIVEL 2
      1.5.3. Fecha de inicio de obras
    1.6. Crear columnas
      1.6.1. ANIO
      1.6.2. DURACION
      1.6.3. Estado de obra
  2. Info obras
    
'}

# ********************************************************************************
# PART 1: Procesamiento de datos -------------------------------------------------
# ********************************************************************************

## 1.1. Importar base de datos ---------------------------------------------------
dataset <- setDT(read_excel(paste0(raw_data, "/Infobras/",
                                   "DataSet-Obras-Publicas 28-10-2024.xlsx"),
                            sheet = 1, skip = 3))
setnames(dataset, toupper(names(dataset)))

## 1.2. Seleccionar variables ----------------------------------------------------  
dataset <- dataset[, c("NATURALEZA DE LA OBRA", "TIPO DE OBRA - CLASIFICADOR NIVEL 1",
                       "TIPO DE OBRA - CLASIFICADOR NIVEL 2",
                       "TIPO DE OBRA - CLASIFICADOR NIVEL 3", "ESTADO DE EJECUCIÓN",
                       "NIVEL DE GOBIERNO", "SECTOR DE LA ENTIDAD", "NOMBRE PROYECTO",
                       "DEPARTAMENTO", "PROVINCIA", "DISTRITO",
                       "FECHA DE INICIO DE OBRA", "FECHA DE PARALIZACIÓN",
                       "FECHA FINALIZACIÓN REPROGRAMADA DE OBRA", 
                       "FECHA DE FINALIZACIÓN REAL")]

## 1.3. Renombrar variables ------------------------------------------------------
setnames(dataset, "NATURALEZA DE LA OBRA", "NATURALEZA_OBRA", 
         skip_absent=TRUE)
setnames(dataset, "TIPO DE OBRA - CLASIFICADOR NIVEL 1", "TIPO_OBRA_CLASIFICADOR_1", 
         skip_absent=TRUE)
setnames(dataset, "TIPO DE OBRA - CLASIFICADOR NIVEL 2", "TIPO_OBRA_CLASIFICADOR_2", 
         skip_absent=TRUE)
setnames(dataset, "TIPO DE OBRA - CLASIFICADOR NIVEL 3", "TIPO_OBRA_CLASIFICADOR_3", 
         skip_absent=TRUE)
setnames(dataset, "ESTADO DE EJECUCIÓN", "ESTADO_EJECUCION", 
         skip_absent=TRUE)
setnames(dataset, "NIVEL DE GOBIERNO", "NIVEL_DE_GOBIERNO", 
         skip_absent=TRUE)
setnames(dataset, "SECTOR DE LA ENTIDAD", "SECTOR_ENTIDAD", 
         skip_absent=TRUE)
setnames(dataset, "NOMBRE PROYECTO", "NOMBRE_PROYECTO", 
         skip_absent=TRUE)
setnames(dataset, "FECHA DE INICIO DE OBRA", "FECHA_INICIO_OBRA", 
         skip_absent=TRUE)
setnames(dataset, "FECHA DE PARALIZACIÓN", "FECHA_PARALIZACION", 
         skip_absent=TRUE)
setnames(dataset, "FECHA FINALIZACIÓN REPROGRAMADA DE OBRA", "FECHA_FINALIZACION_REPROGRAMADA", 
         skip_absent=TRUE)
setnames(dataset, "FECHA DE FINALIZACIÓN REAL", "FECHA_FINALIZACION_OBRA", 
         skip_absent=TRUE)

## 1.4. Cambiar tipo de datos ----------------------------------------------------
dataset[, FECHA_INICIO_OBRA := as.Date(FECHA_INICIO_OBRA, 
                                       format = "%d/%m/%Y")]
dataset[, FECHA_PARALIZACION := as.Date(FECHA_PARALIZACION, 
                                        format = "%d/%m/%Y")]
dataset[, FECHA_FINALIZACION_REPROGRAMADA := as.Date(FECHA_FINALIZACION_REPROGRAMADA, 
                                                     format = "%d/%m/%Y")]
dataset[, FECHA_FINALIZACION_OBRA := as.Date(FECHA_FINALIZACION_OBRA, 
                                             format = "%d/%m/%Y")]

## 1.5. Filtrar datos ------------------------------------------------------------

## 1.5.1. TIPO DE OBRA - CLASIFICADOR NIVEL 1 ------------------------------------
dataset <- dataset[TIPO_OBRA_CLASIFICADOR_1 == "Agricultura"]

## 1.5.2. TIPO DE OBRA - CLASIFICADOR NIVEL 2 ------------------------------------
dataset <- dataset[TIPO_OBRA_CLASIFICADOR_2 %in% c("Riego", "Agrario")]

## 1.5.3. Fecha de inicio de obras -----------------------------------------------
dataset <- dataset[FECHA_INICIO_OBRA >= as.Date("2015-01-01") & 
                     FECHA_INICIO_OBRA < as.Date("2019-01-01")][order(FECHA_INICIO_OBRA)]

## 1.6. Crear columnas -----------------------------------------------------------

## 1.6.1. ANIO -------------------------------------------------------------------
dataset[, ANIO := year(FECHA_INICIO_OBRA)]

## 1.6.2. DURACION ---------------------------------------------------------------
dataset[, DURACION_ANIOS_PROYECTO := fcase(
  ESTADO_EJECUCION == "En Ejecución", as.numeric(difftime(as.Date("2023-12-31"), FECHA_INICIO_OBRA, units = "days")) / 365.25,
  ESTADO_EJECUCION == "Finalizado", as.numeric(difftime(FECHA_FINALIZACION_OBRA, FECHA_INICIO_OBRA, units = "days")) / 365.25,
  ESTADO_EJECUCION == "Paralizada", as.numeric(difftime(FECHA_PARALIZACION, FECHA_INICIO_OBRA, units = "days")) / 365.25
)]

dataset[, DURACION_ANIOS_PROYECTO := round(DURACION_ANIOS_PROYECTO, 2)]

## 1.6.3. Estado de obra ---------------------------------------------------------
dataset[, ESTADO_OBRA := fcase(
  ESTADO_EJECUCION == "En Ejecución", 1,
  ESTADO_EJECUCION == "Finalizado" | ESTADO_EJECUCION == "Paralizada", 0
)]

# ********************************************************************************
# PART 2: Exportar datos ---------------------------------------------------------
# ********************************************************************************

write_dta(data = dataset, 
          path = paste0(clean_data, "/", "data_proyectos.dta"))
