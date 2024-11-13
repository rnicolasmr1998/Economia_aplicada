cat("\014")
'*********************************************************************************
# BASE DE DATOS:	ENA
# PROYECTO: 		  IMPACTO DE LA NO CONCLUSIÓN DE OBRAS EN LA AGRICULTURA
# TÍTULO:         DESCARGA DE DATOS DEL INEI
# AÑOS:				    2015-2019
# AUTOR: 			    RENZO NICOLAS MARROQUIN RUBIO
*********************************************************************************'

# Outline: -----------------------------------------------------------------------

{'
  1. Variable global
  2. Bucle de ejecución
    2.1. Recorrer cada año y módulo en codigo_inei
    2.2. Crear la ruta para el directorio del año
    2.3. Crear la carpeta principal si no existe
    2.4. Obtener los valores del año actual
    2.5. Descargar cada módulo del año
      2.5.1. Construir la URL
      2.5.2. Crear el nombre de archivo en el directorio correspondiente
      2.5.3. Descargar el archivo
      2.5.4. Descomprimir el archivo con la libreria zip
      2.5.5. Eliminar el archivo .zip después de descomprimir
'}

# ********************************************************************************
# PART 1: Variable global --------------------------------------------------------
# ********************************************************************************

url_base <- "https://proyectos.inei.gob.pe/iinei/srienaho/descarga/SPSS/"

# ********************************************************************************
# PART 2: Bucle de ejecución -----------------------------------------------------
# ********************************************************************************

## 2.1. Recorrer cada año y módulo en codigo_inei
for (year in names(codigo_inei)) {
  
## 2.2. Crear la ruta para el directorio del año
  year_dir <- file.path(paste0(raw_data, "/", "ENA"), year)
  
## 2.3. Crear la carpeta principal si no existe
  if (dir.exists(year_dir)) {
    cat("La carpeta para el año", year, "ya existe. Saltando descarga...\n")
    next
  }
  
  dir.create(year_dir, recursive = TRUE)
  
## 2.4. Obtener los valores del año actual
  values <- codigo_inei[[year]]
  primer_valor <- values[1]
  
## 2.5.Descargar cada módulo del año
  for (modulo in values[-1]) {
    
## 2.5.1. Construir la URL
    url <- paste0(url_base, primer_valor, "-Modulo", modulo, ".zip")
    
## 2.5.2. Crear el nombre de archivo en el directorio correspondiente
    dest_file <- file.path(year_dir, paste0(primer_valor, "-Modulo", modulo, ".zip"))
    
## 2.5.3. Descargar el archivo
    download.file(url, destfile = dest_file, mode = "wb")
    cat("Descargado:", dest_file, "\n")
    
## 2.5.4. Descomprimir el archivo con la libreria zip
    tryCatch({
      zip::unzip(dest_file, exdir = year_dir)
      cat("Descomprimido:", dest_file, "\n")
    }, error = function(e) {
      cat("Error al descomprimir el archivo:", dest_file, "\n")
      if (.Platform$OS.type == "windows") {
        system(paste("tar -xf", shQuote(dest_file), "-C", shQuote(year_dir)))
      }
    })
    
## 2.5.5. Eliminar el archivo .zip después de descomprimir
    file.remove(dest_file)
    cat("Eliminado archivo .zip:", dest_file, "\n")
  }
}


