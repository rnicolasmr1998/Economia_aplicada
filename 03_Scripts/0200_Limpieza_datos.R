cat("\014")
'*********************************************************************************
# BASE DE DATOS:	ENA
# PROYECTO: 		  IMPACTO DE LA NO CONCLUSIÓN DE OBRAS EN LA AGRICULTURA
# TÍTULO:         LIMPIEZA DE DATOS DEL INEI
# AÑOS:				    2015-2019
# AUTOR: 			    RENZO NICOLAS MARROQUIN RUBIO
*********************************************************************************'

# Outline: -----------------------------------------------------------------------

{'
  1. Encuesta Nacional Agropecuaria - ENA
    1.1. Caracteristicas agropecuarias
    1.2. Cultivos cosechados en la unidad agropecuaria
    1.3. Costos de la producción de la actividad agropecuaria
    1.4. Caracteristicas del productor/a agropecuario/a y su familia
    1.5. Servicios financieros
  2. Info obras
    
'}

# ********************************************************************************
# PART 1: Encuesta Nacional Agropecuaria - ENA -----------------------------------
# ********************************************************************************

## 1.1. Caracteristicas agropecuarias --------------------------------------------
source(paste0(scripts, "/","0201_Caracteristicas_agropecuarias.R"))

## 1.2. Cultivos cosechados en la unidad agropecuaria ----------------------------
source(paste0(scripts, "/","0202_Superficie_produccion_destino_cultivos.R"))

## 1.3. Costos de la producción de la actividad agropecuaria ---------------------
source(paste0(scripts, "/","0203_Costos_produccion.R"))

## 1.4. Caracteristicas del productor/a agropecuario/a y su familia --------------
source(paste0(scripts, "/","0204_Caracteristicas_productor_familia.R"))

## 1.5. Servicios financieros  ---------------------------------------------------
source(paste0(scripts, "/","0205_Servicios_financieros.R"))

# ********************************************************************************
# PART 2: Info obras -------------------------------------------------------------
# ********************************************************************************

source(paste0(scripts, "/","0206_Infobras.R"))

# ********************************************************************************
# PART 3: Unión de base de datos -------------------------------------------------
# ********************************************************************************

# source(paste0(scripts, "/", "0207_Union_base_datos.R"))