###
### Proyecto:
### PELA Comportamiento
###
### Curso Introduccion a Bases de Datos Relacionales 
### y al Lenguaje SQL
###
### Rodrigo Rodrigues-Silveira
### 
### 9 de Febrero de 2024
###

# Carga los mismos datos ya organizados
# bajo una estructura relacional
load("Cursos/Intro_SQL/Markdown/segunda_republica.RData")


###
### Creacion del modelo de datos
###


library(dm)
library(stringi)

segunda_republica <- dm(legislatura, diputado, profesion, fraccion, distrito, diputado_profesion, diputado_legislatura)

segunda_republica <- segunda_republica |> 
  dm_add_pk(table = legislatura, id_leg) |> 
  dm_add_pk(table = diputado, id_dip) |> 
  dm_add_pk(table = profesion, id_prof) |> 
  dm_add_pk(table = fraccion, id_frac) |> 
  dm_add_pk(table = distrito, id_dist) |> 
  dm_add_pk(table = diputado_profesion, c(id_dip,id_prof)) |> 
  dm_add_pk(table = diputado_legislatura, c(id_leg,id_dip)) |> 
  dm_add_fk(table = diputado_profesion, id_dip, ref_table = diputado) |> 
  dm_add_fk(table = diputado_profesion, id_prof, ref_table = profesion) |> 
  dm_add_fk(table = diputado_legislatura, id_dip, ref_table = diputado) |> 
  dm_add_fk(table = diputado_legislatura, id_leg, ref_table = legislatura) |> 
  dm_add_fk(table = diputado_legislatura, id_dist, ref_table = distrito) |>
  dm_add_fk(table = diputado_legislatura, id_frac, ref_table = fraccion)


# Visualiza el modelo
dm_draw(segunda_republica, rankdir = "TB", view_type = "all")

# Verifica si el modelo es valido
# (consistencia en los datos)
segunda_republica |> dm_examine_constraints()



###
###
### Pasamos al PostgreSQL
###
###


# Antes de nada, crear la base de datos en PgAdmin



# Carga la libreria RPostgreSQL
# que permite conectar con la base de datos
library(RPostgreSQL)

# Inicializa la conexion con la base de datos
drv <- dbDriver("PostgreSQL")

# Conecta con la base
con <- dbConnect(drv, 
                 dbname="Curso_SQL_PELA", 
                 host="localhost", 
                 port="5432", 
                 user="rodrigo", 
                 password="123456")

# Crea las tablas en la base de datos
dbWriteTable(con, "legislatura", legislatura, row.names = F)
dbWriteTable(con, "diputado", diputado, row.names = F)
dbWriteTable(con, "profesion", profesion, row.names = F)
dbWriteTable(con, "fraccion", fraccion, row.names = F)
dbWriteTable(con, "distrito", distrito, row.names = F)
dbWriteTable(con, "diputado_profesion", diputado_profesion, row.names = F)
dbWriteTable(con, "diputado_legislatura", diputado_legislatura, row.names = F)

# Averigua si la blase de datos tiene las tablas
dbGetQuery(con, "SELECT * FROM profesion")

# Desconecta de la base de datos
dbDisconnect(con)


### 
### Base ya lista (con pk, fk, etc.)
### 

# Conecta con la base utilizando el usuario llamado
# usuario_teste (solo accede a la vista
# diputados_republica)
con <- dbConnect(drv, 
                 dbname="Curso_SQL_Lista", 
                 host="localhost", 
                 port="5432", 
                 user="usuario_teste", 
                 password="123456")

# Busca las informaciones de los diputados
d <- dbGetQuery(con, "SELECT * FROM diputados_republica")

# Busca las informaciones de los diputados constituyentes
# (otra vista, pero a la que usuario_teste no tiene acceso)
d <- dbGetQuery(con, "SELECT * FROM dip_constituyentes")

# Desconecta de la base de datos
dbDisconnect(con)


con <- dbConnect(drv, dbname="Curso_SQL_Lista", host="localhost", port="5432", user="usr_const", password="123456")

# Busca las informaciones de los diputados
# (vista a la que usr_const no tiene acceso)
d <- dbGetQuery(con, "SELECT * FROM diputados_republica")

# Busca las informaciones de los diputados constituyentes
d <- dbGetQuery(con, "SELECT * FROM dip_constituyentes")

# Desconecta de la base de datos
dbDisconnect(con)



