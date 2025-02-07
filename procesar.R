library(dplyr)
library(readr)
library(stringr)

# https://datosabiertos.fonasa.cl/dimensiones-beneficiarios/

beneficiarios <- read_csv("datos/datos_originales/Beneficiarios 2023.csv",
                          locale = locale(encoding = "latin1")) |> 
  janitor::clean_names()

# cargar códigos únicos territoriales
cut_comunas <- read_csv2("datos/datos_externos/cut_comuna.csv") |> 
  select(ends_with("region"), ends_with("comuna"), -abreviatura_region) |> 
  mutate(across(starts_with("codigo"), as.numeric))

# cargar clasificación de comunas pndr
clasificacion <- read_csv2("datos/datos_externos/clasificacion_pndr.csv") |> 
  select(codigo_comuna, clasificacion)

# corregir comunas
beneficiarios2 <- beneficiarios |> 
  rename(nombre_comuna = comuna) |> 
  filter(nombre_comuna != "Desconocida") |> 
  mutate(nombre_comuna = str_replace(nombre_comuna, " De ", " de "),
         nombre_comuna = str_replace(nombre_comuna, " Del ", " del "),
         nombre_comuna = str_replace(nombre_comuna, " La ", " la "),
         nombre_comuna = recode(nombre_comuna,
                                "Cabo de Hornos (Ex - Navarino)" = "Cabo de Hornos",
                                "Los Álamos" = "Los Alamos",
                                "Los Ángeles" = "Los Angeles")
         ) |>
  left_join(cut_comunas, by = join_by(nombre_comuna)) |> 
  left_join(clasificacion, by = join_by(codigo_comuna))

# ordenar
beneficiarios3 <- beneficiarios2 |> 
  select(codigo_region, nombre_region, codigo_comuna, nombre_comuna, clasificacion,
         everything())

# tramo, edad, sexo, comuna ----
beneficiarios_a <- beneficiarios3 |> 
  group_by(codigo_region, nombre_region, codigo_comuna, nombre_comuna, clasificacion,
           tramo_fonasa, edad_tramo, sexo) |>
  summarize(beneficiarios = sum(cuenta_beneficiarios)) |> 
  ungroup()

# guardar 
write_csv2(beneficiarios_a, "datos/fonasa_beneficiarios_tramo_edad_sexo.csv")


# tramo, sexo, comuna ----
beneficiarios_b <- beneficiarios3 |> 
  group_by(codigo_region, nombre_region, codigo_comuna, nombre_comuna, clasificacion,
           tramo_fonasa, sexo) |>
  summarize(beneficiarios = sum(cuenta_beneficiarios)) |> 
  ungroup()

# guardar 
write_csv2(beneficiarios_b, "datos/fonasa_beneficiarios_tramo_sexo.csv")


# tramo, comuna ----
beneficiarios_c <- beneficiarios3 |> 
  group_by(codigo_region, nombre_region, codigo_comuna, nombre_comuna, clasificacion,
           tramo_fonasa) |>
  summarize(beneficiarios = sum(cuenta_beneficiarios)) |> 
  ungroup()

# guardar 
write_csv2(beneficiarios_c, "datos/fonasa_beneficiarios_tramo.csv")


# comuna ----
beneficiarios_d <- beneficiarios3 |> 
  group_by(codigo_region, nombre_region, codigo_comuna, nombre_comuna, clasificacion) |>
  summarize(beneficiarios = sum(cuenta_beneficiarios)) |> 
  ungroup()

# guardar 
write_csv2(beneficiarios_d, "datos/fonasa_beneficiarios.csv")