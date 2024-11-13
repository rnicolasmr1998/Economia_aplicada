cat("\014")
'*********************************************************************************
# BASE DE DATOS:	ENA
# PROYECTO: 		  IMPACTO DE LA NO CONCLUSIÓN DE OBRAS EN LA AGRICULTURA
# TÍTULO:         MASTER SCRIPT
# AÑOS:				    2015-2019
# AUTOR: 			    RENZO NICOLAS MARROQUIN RUBIO
*********************************************************************************'

# Outline: -----------------------------------------------------------------------

{'
  1. Ruta de trabajo y globals
    1.1. Instalar paquetes requeridos
    1.2. Configurar usuarios
    1.3. Configurar carpetas
      1.3.1. Definir la ruta de la carpeta principal
      1.3.2. Crear la carpeta principal si no existe
      1.3.3. Creación de subcarpetas
    1.4. Configurar variables de entorno
    1.5. Configurar ejecución de scripts
  2. Análisis estadístico - econométrico
    2.1. Descargar las bases de datos del INEI
    2.2. Preprocesamiento de datos
    2.3. Análisis estadístico
    2.4. Análisis econométrico
'}

# ********************************************************************************
# PART 1: Ruta de trabajo y globals ----------------------------------------------
# ********************************************************************************

rm(list = ls())               # Limpiar memoria
options(scipen = 999)         # Deshabilitar la notación científica
options(encoding = "UTF-8")   # Cambiar la configuración de codificación a UTF-8

## 1.1. Instalar librerias requeridas --------------------------------------------

if (!require("pacman")) {install.packages("pacman")}
pacman::p_load(data.table, dplyr, tidyr, magrittr, stringr, stringi, haven, rio, survey, zip, did)
pacman::p_load(ggplot2, RColorBrewer, ggcorrplot, gridExtra, ggthemes, hrbrthemes, extrafont, viridis)
pacman::p_load(summarytools, openxlsx, expss, psych, gtsummary, readxl, lubridate)

## 1.2. Configurar usuarios ------------------------------------------------------

if (Sys.info()[["user"]] == "Administrador")  {setwd("C:/Users/Administrador/Documents")}

## 1.3. Configurar carpetas ------------------------------------------------------

## 1.3.1. Definir la ruta de la carpeta principal
proyecto    <- paste(getwd(),  "Economia_aplicada", sep = "/")

## 1.3.2. Crear la carpeta principal si no existe
if (!file.exists(proyecto)) {
  dir.create(proyecto)
  message("La carpeta 'Economia_aplicada' ha sido creada.")
} else {
  message("La carpeta 'Economia_aplicada' ya existe.")
}

## 1.3.3. Creación de subcarpetas
raw_data    <- paste(proyecto, "00_Raw_data"      , sep = "/")
clean_data  <- paste(proyecto, "01_Clean_data"    , sep = "/")
input       <- paste(proyecto, "02_Input"         , sep = "/")
scripts     <- paste(proyecto, "03_Scripts"       , sep = "/")
output      <- paste(proyecto, "04_Output"        , sep = "/")
report      <- paste(proyecto, "05_Report"        , sep = "/")

## 1.4. Configurar variables de entorno ------------------------------------------
codigo_inei <- list(
  "2015" = c(506, 788:809),
  "2016" = c(579, 1122:1143),
  "2017" = c(615, 1315:1336),
  "2018" = c(650, 1450:1472),
  "2019" = c(701, 1529:1550)
)

## 1.5. Configurar ejecución de scripts ------------------------------------------
descargar_data <- FALSE
limpieza_data  <- TRUE

# ********************************************************************************
# PART 2: Análisis estadístico - econométrico ------------------------------------
# ********************************************************************************

## 2.1. Descargar las bases de datos del INEI ------------------------------------
if (descargar_data) {source(paste0(scripts, "/","0100_Descargar_datos_inei.R"))}

## 2.2. Preprocesamiento de datos ------------------------------------------------
if (limpieza_data) {source(paste0(scripts, "/","0200_Limpieza_datos.R"))}

