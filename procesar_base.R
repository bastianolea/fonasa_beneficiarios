library(dplyr)
library(arrow)

# https://datosabiertos.fonasa.cl/dimensiones-beneficiarios/
# para cargar la base de datos completa (2,52 GB, 16 millones de filas por 12 colummnas)

# cargar archivo grande usando arrow
fonasa <- arrow::read_delim_arrow("~/Downloads/Beneficiarios Fonasa 2023.csv",
                                  parse_options = csv_parse_options(ignore_empty_lines = FALSE,
                                                                    delimiter = ",",
                                                                    newlines_in_values = TRUE),
                                  read_options = csv_read_options(encoding = "latin1")
)


fonasa |> 
  count(TIPO_ASEGURADO)

fonasa |> 
  count(CARACTERIZACIÓN) |> 
  print(n=Inf)

fonasa |> 
  count(TRAMO_RENTA) |> 
  print(n=Inf)


fonasa |> 
  print(n=40)
