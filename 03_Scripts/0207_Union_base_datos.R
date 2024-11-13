cat("\014")
'*********************************************************************************
# BASE DE DATOS:	ENA
# PROYECTO: 		  IMPACTO DE LA NO CONCLUSIÓN DE OBRAS EN LA AGRICULTURA
# TÍTULO:         UNIÓN DE BASES DE DATOS
# AÑOS:				    2015-2019
# AUTOR: 			    RENZO NICOLAS MARROQUIN RUBIO
*********************************************************************************'

# Outline: -----------------------------------------------------------------------

{'
  1. Importar base de datos
'}

# ********************************************************************************
# PART 1: Importar base de datos -------------------------------------------------
# ********************************************************************************

## 1.1. Características agropecuarias --------------------------------------------
caracteristicas_agropecuarias <- setDT(read_dta(paste(clean_data, 
                                                      "caracteristicas_agropecuarias.dta", 
                                                      sep = "/")))

## 1.2. Características de los cultivos ------------------------------------------
caracteristicas_cultivos <- setDT(read_dta(paste(clean_data,
                                                 "caracteristicas_productos.dta",
                                                 sep = "/")))

## 1.3. Costos agrícolas ---------------------------------------------------------
costos_agricolas <- setDT(read_dta(paste(clean_data,
                                         "costos_agricolas.dta",
                                         sep = "/")))

## 1.4. Superficie ingresos ------------------------------------------------------
superficie_ingresos <- setDT(read_dta(paste(clean_data,
                                            "superficie_ingresos.dta",
                                            sep = "/")))

## 1.5. Servicios financieros ----------------------------------------------------
servicios_financieros <- setDT(read_dta(paste(clean_data,
                                              "servicios_financieros.dta",
                                              sep = "/")))

## 1.6. Datos de proyectos -------------------------------------------------------
data_proyectos <- setDT(read_dta(paste(clean_data,
                                       "data_proyectos.dta",
                                       sep = "/")))

data_proyectos <- data_proyectos[, DEPARTAMENTO := ifelse(DEPARTAMENTO == "P C DEL CALLAO",
                                                          "CALLAO",
                                                          DEPARTAMENTO)
                                 ]

data_proyectos <- data_proyectos[, PROVINCIA := ifelse(PROVINCIA == "PROV CONST DEL CALLAO",
                                                        "CALLAO",
                                                        PROVINCIA)
                                 ]

data_proyectos <- data_proyectos[, DISTRITO := ifelse(DISTRITO == "CARMEN DE LA LEGUA REYNOSO",
                                                       "CARMEN DE LA LEGUA",
                                                       PROVINCIA)
                                 ]
data_proyectos <- setDT(read_dta(paste(clean_data,
                                       "data_proyectos.dta",
                                       sep = "/")))

setorder(data_proyectos, DEPARTAMENTO, PROVINCIA, DISTRITO)

## 1.7. Unión de base de datos ENA -----------------------------------------------

## 1.7.1. Lista de datasets a fusionar -------------------------------------------
datasets <- list(superficie_ingresos, 
                 caracteristicas_agropecuarias, 
                 caracteristicas_cultivos, 
                 costos_agricolas, 
                 servicios_financieros)

## 1.7.2. Fusionar todos los datasets --------------------------------------------
data_set <- Reduce(function(x, y) merge(x, y, by = c("ID", "ANIO", "UBIGEO"), all.x = TRUE), datasets)

na_counts <- data_set[, lapply(.SD, function(x) sum(is.na(x)))]
print(na_counts)

## 1.8. Unión de base de datos tratamiento ---------------------------------------

input_ubigeo <- setDT(read_excel(paste(input, "ubigeo_inei.xlsx", sep = "/")))
input_ubigeo <- input_ubigeo[,.(UBIGEO, DEPARTAMENTO, PROVINCIA, DISTRITO)]
setorder(input_ubigeo, DEPARTAMENTO, PROVINCIA, DISTRITO)
data_project <- merge(data_proyectos,
                        input_ubigeo,
                        by = c("DEPARTAMENTO", "PROVINCIA", "DISTRITO"))
setorder(data_project, DEPARTAMENTO, PROVINCIA, DISTRITO)
data_project[, NUM_REP_UBIGEO := .N, by = .(DEPARTAMENTO, PROVINCIA, DISTRITO, ANIO)]
numero_proyecto <- data_project[, .(UBIGEO, ANIO, NUM_REP_UBIGEO)]
numero_proyecto <- unique(data_project[, .(UBIGEO, ANIO, NUM_REP_UBIGEO)])
numero_proyecto[, ANIO := as.character(ANIO)]
data_ena_infobra <- merge(data_set,
                          numero_proyecto,
                          by = c("ANIO", "UBIGEO"),
                          all.x = TRUE)


data_ena_infobra[, OBRA := ifelse(!is.na(NUM_REP_UBIGEO),
                                  1,
                                  0)]
write_dta(data = data_ena_infobra, 
          path = paste0(clean_data, "/", "data_ena_infobra_primer_modelo.dta"))
