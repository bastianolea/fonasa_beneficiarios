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
) |> 
  janitor::clean_names()


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

fonasa_genero <- fonasa |> 
  group_by(sexo, tramo_renta) |> 
  summarize(n = n()) |> 
  ungroup() |> 
  mutate(
    tramo_renta_2 = str_extract(tramo_renta, "(?<=- ).*"),
    tramo_renta_2 = str_remove_all(tramo_renta_2, "\\."),
    tramo_renta_2 = as.numeric(tramo_renta_2),
    tramo_renta_2 = ifelse(str_detect(tramo_renta, "mayor"), 1650000, tramo_renta_2)
  )

library(ggplot2)



fonasa_genero |> 
  ggplot() +
  aes(x = tramo_renta, fill = sexo,
      y = n) +
  geom_col()

fonasa_genero |> 
  filter(sexo != "Sin información") |> 
  ggplot() +
  aes(fill = sexo, color = sexo) +
  geom_density(aes(x = tramo_renta_2, weight = n),
               alpha = .4) +
  # coord_cartesian(expand = F) +
  scale_y_continuous(labels = NULL, expand = expansion(c(0, 0.1))) +
  scale_x_continuous(labels = scales::label_comma(prefix = "$", big.mark = "."),
                     expand = expansion(c(0, 0)),
                     n.breaks = 8) +
  theme_minimal() +
  guides(fill = guide_legend(reverse = T),
         color = guide_legend(reverse = T)) +
  labs(y = "", x = "tramo de renta")

# fonasa_genero |> 
#   tidyr::uncount(

library(stringr)

fonasa_genero |> 
  distinct(tramo_renta) |> 
  mutate(
    tramo_renta_2 = str_extract(tramo_renta, "(?<=- ).*"),
    tramo_renta_2 = str_remove_all(tramo_renta_2, "\\."),
    tramo_renta_2 = as.numeric(tramo_renta_2),
    tramo_renta_2 = ifelse(str_detect(tramo_renta, "mayor"), 1650000, tramo_renta_2)
  ) |> 
  print(n=Inf)
