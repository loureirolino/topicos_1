---
title: |
  ![](www/logo-UnB.png){width=75%}  <br>
  Lista 2: Computação eficiente
subtitle: "Computação em Estatística para dados e cálculos massivos"
author: "<b>Autor:</b> Lucas Loureiro Lino da Costa"
affiliation: "Universidade de Brasília"
date: "16 de agosto de 2022"
tags: [estatística, computação]
output:
  rmdformats::readthedown:
    theme: 
      version: 3
    code_folding: hide
    highlight: tango
    css: "www/style.css"
    #number_sections: true
    toc_float:
      collapsed: false
      smooth_scroll: false
    df_print: kable
    fig_width: 7
    fig_height: 6
    self_contained: true
    lightbox: true
    keep_md: true
    github_document:
link-citations: yes
always_allow_html: true
---

<!-- YAML acima!!!-->


<!-- knitr config-->


# Informações Gerais

**1.** Caso os códigos se encontram "escondidos", eles podem ser acessados ao apertar o botão **Code** na página.  
**2.** Os códigos foram escritos usando a linguagem [R](https://www.r-project.org);  
**3.** O comando original das questões pode ser encontradas no [github](https://github.com/loureirolino/topicos_1/blob/main/assignments/Lista_2.pdf) do autor desse HTML.  
**4.** As pastas com arquivos baixados foram configuradas para não serem integradas ao github, para evitar subir um volume desnecessário de arquivos, assim como os bancos.



```r
#### Funções Customizadas ####

# função para popular o DB
db_populate = function(table_name, append_func){
  # checando se o diretório existe e se necessário criá-lo para o SQLite
  dir_name = 'list_2/dados'
  if (file.exists(dir_name) == FALSE) {
      dir.create(dir_name)
    } else {
      invisible()
    }
  # conexão com o 'banco' SQLite
  if (c('conn') %in% ls() == TRUE && is.null(conn) == FALSE){
      invisible()
    } else {
      source('list_2/conn/conn_sqlite.R')
    }
  # checagem table
  if (table_name %in% dbListTables(conn)){
      invisible()
    } else {
      append_func()
    }
}

# implementação do slice para DB (https://stackoverflow.com/questions/59217666/dbplyr-dplyr-and-functions-with-no-sql-equivalents-eg-slice)
slice.tbl_sql <- function(.data, ...) {
  rows <- c(...)

  .data %>%
    mutate(...row_id = row_number()) %>%
    filter(...row_id %in% !!rows) %>%
    select(-...row_id)
}
```


# Questões

## Questão 1: Criando bancos de dados. {.tabset .tabset-fade .tabset-pills}

### Resolução 1.a)

```r
# instalação dos pacotes casso necessário via pacman e carregamentos destes
if (!require('pacman')) install.packages('pacman')
p_load(dplyr, tidyverse, rmdformats, stringr, 
       vroom, mongolite, RSQLite, DBI, dbplyr,
       data.table, geobr, sf, glue)

# populando o banco
# criando as tables e suas respectivas colunas
# primeira table
saude = function(){
  dbSendStatement(
  conn,
  'CREATE TABLE saude(
                      "estabelecimento_uf",
                      "vacina_descricao_dose",
                      "estabelecimento_municipio_codigo"
                      )'
  )
  
  files = list.files('list_1/dados', full.names = TRUE)
  data_saude = vroom(pipe(paste0('grep -wi Janssen ', gsub(pattern = ',', replacement = ' ', toString(files)))),
                     col_names = c('document_id', 'paciente_id', 'paciente_idade', 'paciente_dataNascimento',
                                 'paciente_enumSexoBiologico', 'paciente_racaCor_codigo', 'paciente_racaCor_valor',
                                 'paciente_endereco_coIbgeMunicipio', 'paciente_endereco_coPais', 'paciente_endereco_nmMunicipio',
                                 'paciente_endereco_nmPais', 'paciente_endereco_uf', 'paciente_endereco_cep',
                                 'paciente_nacionalidade_enumNacionalidade', 'estabelecimento_valor',
                                 'estabelecimento_razaoSocial', 'estalecimento_noFantasia',
                                 'estabelecimento_municipio_codigo', 'estabelecimento_municipio_nome',
                                 'estabelecimento_uf', 'vacina_grupoAtendimento_codigo',
                                 'vacina_grupoAtendimento_nome', 'vacina_categoria_codigo', 'vacina_categoria_nome', 'vacina_lote',
                                 'vacina_fabricante_nome', 'vacina_fabricante_referencia', 'vacina_dataAplicacao',
                                 'vacina_descricao_dose', 'vacina_codigo', 'vacina_nome', 'sistema_origem'),
                      col_select = c('estabelecimento_uf', 'vacina_descricao_dose', 'estabelecimento_municipio_codigo'),
                      #locale = locale("br",encoding = "latin1"),
                      num_threads = 3, delim = ";")
  dbAppendTable(conn, 'saude', data_saude)
  
}

db_populate('saude', saude)

# populando o banco
# criando as tables e suas respectivas colunas
# segunda table
geobr = function(){
  data_health = invisible(geobr::read_health_region(year = 2013, simplified = FALSE))
  data_health = st_set_geometry(data_health, NULL) #removendo os dados geo-espaciais (erro ao dar append.....)
  dbCreateTable(conn, 'geobr', data_health)
  dbAppendTable(conn, 'geobr', data_health)
}

db_populate('geobr', geobr)

# # populando o banco
# # criando as tables e suas respectivas colunas
# # terceira table
ibge = function(){
  df = fread('list_1/tableExport.csv',
             select = 2:6,
            encoding = 'UTF-8',
            col.names = c('uf', 'municipio',  'ibge', 'cod_saude', 'nome_saude'))
  dbCreateTable(conn, 'ibge', df)
  dbAppendTable(conn, 'ibge', df)
}

db_populate('ibge', ibge)

# checando tables e suas colunas
for (item in dbListTables(conn)){
  print(paste('Nome da tabela:', item))
  print(paste('Nrows:', nrow(dbReadTable(conn, item))))
  print(dbListFields(conn, item))
}
```

```
## [1] "Nome da tabela: geobr"
## [1] "Nrows: 438"
## [1] "code_health_region" "name_health_region" "code_state"        
## [4] "abbrev_state"       "name_state"        
## [1] "Nome da tabela: ibge"
## [1] "Nrows: 5571"
## [1] "uf"         "municipio"  "ibge"       "cod_saude"  "nome_saude"
## [1] "Nome da tabela: saude"
## [1] "Nrows: 335924"
## [1] "estabelecimento_uf"               "vacina_descricao_dose"           
## [3] "estabelecimento_municipio_codigo"
```

### Resolução 1.b)

```r
# Criando as referências (no R)
geobr = tbl(conn, "geobr")
ibge = tbl(conn, "ibge")
saude = tbl(conn, "saude")

# query
queries = glue('SELECT g.name_health_region,
                       i.cod_saude,
                       i.ibge,
                       i.nome_saude
               FROM ibge i
               INNER JOIN geobr g ON g.code_health_region = i.cod_saude
               INNER JOIN saude s ON i.ibge = s.estabelecimento_municipio_codigo
               ')

dados = dbGetQuery(conn, paste(queries, collapse = "UNION ALL\n"))


# inner_join(geobr, ibge, by = c('code_health_region' = 'cod_saude')) %>%
#    inner_join(saude, by = c('ibge' = 'estabelecimento_municipio_codigo')) %>%
#   group_by(name_health_region) %>%
#   mutate(N = n()) %>%
#   summarize( faixa = ifelse(N>=median(N), 'alta', 'baixa')) %>%
#   mutate(N = n()) %>%
#   group_by(faixa) %>%
#   arrange(N) %>%
#   slice(1:5) %>%
#   select(faixa, name_health_region, N) %>%
#   as_tibble()
#   show_query()

# desconectar
dbDisconnect(conn)
```

### Resolução 1.c)

```r
# # populando o banco
# # criando as tables e suas respectivas colunas

files = list.files('list_1/dados', full.names = TRUE)
data_saude = vroom(pipe(paste0('grep -wi Janssen ', gsub(pattern = ',', replacement = ' ', toString(files)))),
                     col_names = c('document_id', 'paciente_id', 'paciente_idade', 'paciente_dataNascimento',
                                 'paciente_enumSexoBiologico', 'paciente_racaCor_codigo', 'paciente_racaCor_valor',
                                 'paciente_endereco_coIbgeMunicipio', 'paciente_endereco_coPais', 'paciente_endereco_nmMunicipio',
                                 'paciente_endereco_nmPais', 'paciente_endereco_uf', 'paciente_endereco_cep',
                                 'paciente_nacionalidade_enumNacionalidade', 'estabelecimento_valor',
                                 'estabelecimento_razaoSocial', 'estalecimento_noFantasia',
                                 'estabelecimento_municipio_codigo', 'estabelecimento_municipio_nome',
                                 'estabelecimento_uf', 'vacina_grupoAtendimento_codigo',
                                 'vacina_grupoAtendimento_nome', 'vacina_categoria_codigo', 'vacina_categoria_nome', 'vacina_lote',
                                 'vacina_fabricante_nome', 'vacina_fabricante_referencia', 'vacina_dataAplicacao',
                                 'vacina_descricao_dose', 'vacina_codigo', 'vacina_nome', 'sistema_origem'),
                      col_select = c('estabelecimento_uf', 'vacina_descricao_dose', 'estabelecimento_municipio_codigo'),
                      #locale = locale("br",encoding = "latin1"),
                      num_threads = 3, delim = ";")

data_collection_saude = mongo(collection = "saude", db = "data", url = 'mongodb://admin:password@10.68.14.110:27017')
data_collection_saude$insert(data_saude)
```

```
## List of 5
##  $ nInserted  : num 335924
##  $ nMatched   : num 0
##  $ nRemoved   : num 0
##  $ nUpserted  : num 0
##  $ writeErrors: list()
```

```r
data_health = invisible(geobr::read_health_region(year = 2013, simplified = FALSE))
```

```
## 
Downloading: 780 B     
Downloading: 780 B     
Downloading: 1.2 kB     
Downloading: 1.2 kB     
Downloading: 1.7 kB     
Downloading: 1.7 kB     
Downloading: 1.7 kB     
Downloading: 1.7 kB     
Downloading: 1.8 kB     
Downloading: 1.8 kB     
Downloading: 1.8 kB     
Downloading: 1.8 kB     
Downloading: 1.9 kB     
Downloading: 1.9 kB     
Downloading: 1.9 kB     
Downloading: 1.9 kB     
Downloading: 1.9 kB     
Downloading: 1.9 kB     
Downloading: 2 kB     
Downloading: 2 kB     
Downloading: 2.1 kB     
Downloading: 2.1 kB     
Downloading: 2.1 kB     
Downloading: 2.1 kB     
Downloading: 2.1 kB     
Downloading: 2.1 kB     
Downloading: 3.5 kB     
Downloading: 3.5 kB     
Downloading: 3.5 kB     
Downloading: 3.5 kB     
Downloading: 5.8 kB     
Downloading: 5.8 kB     
Downloading: 5.8 kB     
Downloading: 5.8 kB     
Downloading: 6.3 kB     
Downloading: 6.3 kB     
Downloading: 6.3 kB     
Downloading: 6.3 kB     
Downloading: 14 kB     
Downloading: 14 kB     
Downloading: 14 kB     
Downloading: 14 kB     
Downloading: 14 kB     
Downloading: 14 kB     
Downloading: 22 kB     
Downloading: 22 kB     
Downloading: 22 kB     
Downloading: 22 kB     
Downloading: 22 kB     
Downloading: 22 kB     
Downloading: 31 kB     
Downloading: 31 kB     
Downloading: 31 kB     
Downloading: 31 kB     
Downloading: 31 kB     
Downloading: 31 kB     
Downloading: 39 kB     
Downloading: 39 kB     
Downloading: 39 kB     
Downloading: 39 kB     
Downloading: 39 kB     
Downloading: 39 kB     
Downloading: 47 kB     
Downloading: 47 kB     
Downloading: 47 kB     
Downloading: 47 kB     
Downloading: 47 kB     
Downloading: 47 kB     
Downloading: 55 kB     
Downloading: 55 kB     
Downloading: 55 kB     
Downloading: 55 kB     
Downloading: 55 kB     
Downloading: 55 kB     
Downloading: 63 kB     
Downloading: 63 kB     
Downloading: 63 kB     
Downloading: 63 kB     
Downloading: 63 kB     
Downloading: 63 kB     
Downloading: 71 kB     
Downloading: 71 kB     
Downloading: 71 kB     
Downloading: 71 kB     
Downloading: 71 kB     
Downloading: 71 kB     
Downloading: 79 kB     
Downloading: 79 kB     
Downloading: 79 kB     
Downloading: 79 kB     
Downloading: 79 kB     
Downloading: 79 kB     
Downloading: 87 kB     
Downloading: 87 kB     
Downloading: 87 kB     
Downloading: 87 kB     
Downloading: 87 kB     
Downloading: 87 kB     
Downloading: 95 kB     
Downloading: 95 kB     
Downloading: 95 kB     
Downloading: 95 kB     
Downloading: 95 kB     
Downloading: 95 kB     
Downloading: 100 kB     
Downloading: 100 kB     
Downloading: 100 kB     
Downloading: 100 kB     
Downloading: 100 kB     
Downloading: 100 kB     
Downloading: 110 kB     
Downloading: 110 kB     
Downloading: 110 kB     
Downloading: 110 kB     
Downloading: 110 kB     
Downloading: 110 kB     
Downloading: 120 kB     
Downloading: 120 kB     
Downloading: 120 kB     
Downloading: 120 kB     
Downloading: 120 kB     
Downloading: 120 kB     
Downloading: 130 kB     
Downloading: 130 kB     
Downloading: 130 kB     
Downloading: 130 kB     
Downloading: 130 kB     
Downloading: 130 kB     
Downloading: 140 kB     
Downloading: 140 kB     
Downloading: 140 kB     
Downloading: 140 kB     
Downloading: 140 kB     
Downloading: 140 kB     
Downloading: 140 kB     
Downloading: 140 kB     
Downloading: 140 kB     
Downloading: 140 kB     
Downloading: 140 kB     
Downloading: 140 kB     
Downloading: 150 kB     
Downloading: 150 kB     
Downloading: 150 kB     
Downloading: 150 kB     
Downloading: 150 kB     
Downloading: 150 kB     
Downloading: 160 kB     
Downloading: 160 kB     
Downloading: 160 kB     
Downloading: 160 kB     
Downloading: 160 kB     
Downloading: 160 kB     
Downloading: 170 kB     
Downloading: 170 kB     
Downloading: 170 kB     
Downloading: 170 kB     
Downloading: 170 kB     
Downloading: 170 kB     
Downloading: 180 kB     
Downloading: 180 kB     
Downloading: 180 kB     
Downloading: 180 kB     
Downloading: 180 kB     
Downloading: 180 kB     
Downloading: 180 kB     
Downloading: 180 kB     
Downloading: 180 kB     
Downloading: 180 kB     
Downloading: 180 kB     
Downloading: 180 kB     
Downloading: 190 kB     
Downloading: 190 kB     
Downloading: 190 kB     
Downloading: 190 kB     
Downloading: 190 kB     
Downloading: 190 kB     
Downloading: 200 kB     
Downloading: 200 kB     
Downloading: 200 kB     
Downloading: 200 kB     
Downloading: 200 kB     
Downloading: 200 kB     
Downloading: 210 kB     
Downloading: 210 kB     
Downloading: 210 kB     
Downloading: 210 kB     
Downloading: 210 kB     
Downloading: 210 kB     
Downloading: 220 kB     
Downloading: 220 kB     
Downloading: 220 kB     
Downloading: 220 kB     
Downloading: 220 kB     
Downloading: 220 kB     
Downloading: 220 kB     
Downloading: 220 kB     
Downloading: 220 kB     
Downloading: 220 kB     
Downloading: 220 kB     
Downloading: 220 kB     
Downloading: 230 kB     
Downloading: 230 kB     
Downloading: 230 kB     
Downloading: 230 kB     
Downloading: 230 kB     
Downloading: 230 kB     
Downloading: 240 kB     
Downloading: 240 kB     
Downloading: 240 kB     
Downloading: 240 kB     
Downloading: 240 kB     
Downloading: 240 kB     
Downloading: 250 kB     
Downloading: 250 kB     
Downloading: 250 kB     
Downloading: 250 kB     
Downloading: 250 kB     
Downloading: 250 kB     
Downloading: 260 kB     
Downloading: 260 kB     
Downloading: 260 kB     
Downloading: 260 kB     
Downloading: 260 kB     
Downloading: 260 kB     
Downloading: 270 kB     
Downloading: 270 kB     
Downloading: 270 kB     
Downloading: 270 kB     
Downloading: 270 kB     
Downloading: 270 kB     
Downloading: 270 kB     
Downloading: 270 kB     
Downloading: 270 kB     
Downloading: 270 kB     
Downloading: 270 kB     
Downloading: 270 kB     
Downloading: 280 kB     
Downloading: 280 kB     
Downloading: 280 kB     
Downloading: 280 kB     
Downloading: 280 kB     
Downloading: 280 kB     
Downloading: 290 kB     
Downloading: 290 kB     
Downloading: 290 kB     
Downloading: 290 kB     
Downloading: 290 kB     
Downloading: 290 kB     
Downloading: 300 kB     
Downloading: 300 kB     
Downloading: 300 kB     
Downloading: 300 kB     
Downloading: 300 kB     
Downloading: 300 kB     
Downloading: 310 kB     
Downloading: 310 kB     
Downloading: 310 kB     
Downloading: 310 kB     
Downloading: 310 kB     
Downloading: 310 kB     
Downloading: 310 kB     
Downloading: 310 kB     
Downloading: 310 kB     
Downloading: 310 kB     
Downloading: 310 kB     
Downloading: 310 kB     
Downloading: 320 kB     
Downloading: 320 kB     
Downloading: 320 kB     
Downloading: 320 kB     
Downloading: 320 kB     
Downloading: 320 kB     
Downloading: 330 kB     
Downloading: 330 kB     
Downloading: 330 kB     
Downloading: 330 kB     
Downloading: 330 kB     
Downloading: 330 kB     
Downloading: 340 kB     
Downloading: 340 kB     
Downloading: 340 kB     
Downloading: 340 kB     
Downloading: 340 kB     
Downloading: 340 kB     
Downloading: 350 kB     
Downloading: 350 kB     
Downloading: 350 kB     
Downloading: 350 kB     
Downloading: 350 kB     
Downloading: 350 kB     
Downloading: 350 kB     
Downloading: 350 kB     
Downloading: 350 kB     
Downloading: 350 kB     
Downloading: 350 kB     
Downloading: 350 kB     
Downloading: 360 kB     
Downloading: 360 kB     
Downloading: 360 kB     
Downloading: 360 kB     
Downloading: 360 kB     
Downloading: 360 kB     
Downloading: 370 kB     
Downloading: 370 kB     
Downloading: 370 kB     
Downloading: 370 kB     
Downloading: 370 kB     
Downloading: 370 kB     
Downloading: 380 kB     
Downloading: 380 kB     
Downloading: 380 kB     
Downloading: 380 kB     
Downloading: 380 kB     
Downloading: 380 kB     
Downloading: 390 kB     
Downloading: 390 kB     
Downloading: 390 kB     
Downloading: 390 kB     
Downloading: 390 kB     
Downloading: 390 kB     
Downloading: 390 kB     
Downloading: 390 kB     
Downloading: 390 kB     
Downloading: 390 kB     
Downloading: 390 kB     
Downloading: 390 kB     
Downloading: 400 kB     
Downloading: 400 kB     
Downloading: 400 kB     
Downloading: 400 kB     
Downloading: 400 kB     
Downloading: 400 kB     
Downloading: 410 kB     
Downloading: 410 kB     
Downloading: 410 kB     
Downloading: 410 kB     
Downloading: 410 kB     
Downloading: 410 kB     
Downloading: 420 kB     
Downloading: 420 kB     
Downloading: 420 kB     
Downloading: 420 kB     
Downloading: 420 kB     
Downloading: 420 kB     
Downloading: 430 kB     
Downloading: 430 kB     
Downloading: 430 kB     
Downloading: 430 kB     
Downloading: 430 kB     
Downloading: 430 kB     
Downloading: 440 kB     
Downloading: 440 kB     
Downloading: 440 kB     
Downloading: 440 kB     
Downloading: 440 kB     
Downloading: 440 kB     
Downloading: 440 kB     
Downloading: 440 kB     
Downloading: 440 kB     
Downloading: 440 kB     
Downloading: 440 kB     
Downloading: 440 kB     
Downloading: 450 kB     
Downloading: 450 kB     
Downloading: 450 kB     
Downloading: 450 kB     
Downloading: 450 kB     
Downloading: 450 kB     
Downloading: 460 kB     
Downloading: 460 kB     
Downloading: 460 kB     
Downloading: 460 kB     
Downloading: 460 kB     
Downloading: 460 kB     
Downloading: 470 kB     
Downloading: 470 kB     
Downloading: 470 kB     
Downloading: 470 kB     
Downloading: 470 kB     
Downloading: 470 kB     
Downloading: 480 kB     
Downloading: 480 kB     
Downloading: 480 kB     
Downloading: 480 kB     
Downloading: 480 kB     
Downloading: 480 kB     
Downloading: 480 kB     
Downloading: 480 kB     
Downloading: 480 kB     
Downloading: 480 kB     
Downloading: 480 kB     
Downloading: 480 kB     
Downloading: 490 kB     
Downloading: 490 kB     
Downloading: 490 kB     
Downloading: 490 kB     
Downloading: 490 kB     
Downloading: 490 kB     
Downloading: 500 kB     
Downloading: 500 kB     
Downloading: 500 kB     
Downloading: 500 kB     
Downloading: 500 kB     
Downloading: 500 kB     
Downloading: 510 kB     
Downloading: 510 kB     
Downloading: 510 kB     
Downloading: 510 kB     
Downloading: 510 kB     
Downloading: 510 kB     
Downloading: 520 kB     
Downloading: 520 kB     
Downloading: 520 kB     
Downloading: 520 kB     
Downloading: 520 kB     
Downloading: 520 kB     
Downloading: 520 kB     
Downloading: 520 kB     
Downloading: 520 kB     
Downloading: 520 kB     
Downloading: 520 kB     
Downloading: 520 kB     
Downloading: 530 kB     
Downloading: 530 kB     
Downloading: 530 kB     
Downloading: 530 kB     
Downloading: 530 kB     
Downloading: 530 kB     
Downloading: 540 kB     
Downloading: 540 kB     
Downloading: 540 kB     
Downloading: 540 kB     
Downloading: 540 kB     
Downloading: 540 kB     
Downloading: 550 kB     
Downloading: 550 kB     
Downloading: 550 kB     
Downloading: 550 kB     
Downloading: 550 kB     
Downloading: 550 kB     
Downloading: 560 kB     
Downloading: 560 kB     
Downloading: 560 kB     
Downloading: 560 kB     
Downloading: 560 kB     
Downloading: 560 kB     
Downloading: 560 kB     
Downloading: 560 kB     
Downloading: 560 kB     
Downloading: 560 kB     
Downloading: 560 kB     
Downloading: 560 kB     
Downloading: 570 kB     
Downloading: 570 kB     
Downloading: 570 kB     
Downloading: 570 kB     
Downloading: 570 kB     
Downloading: 570 kB     
Downloading: 580 kB     
Downloading: 580 kB     
Downloading: 580 kB     
Downloading: 580 kB     
Downloading: 580 kB     
Downloading: 580 kB     
Downloading: 590 kB     
Downloading: 590 kB     
Downloading: 590 kB     
Downloading: 590 kB     
Downloading: 590 kB     
Downloading: 590 kB     
Downloading: 600 kB     
Downloading: 600 kB     
Downloading: 600 kB     
Downloading: 600 kB     
Downloading: 600 kB     
Downloading: 600 kB     
Downloading: 610 kB     
Downloading: 610 kB     
Downloading: 610 kB     
Downloading: 610 kB     
Downloading: 610 kB     
Downloading: 610 kB     
Downloading: 610 kB     
Downloading: 610 kB     
Downloading: 610 kB     
Downloading: 610 kB     
Downloading: 610 kB     
Downloading: 610 kB     
Downloading: 620 kB     
Downloading: 620 kB     
Downloading: 620 kB     
Downloading: 620 kB     
Downloading: 620 kB     
Downloading: 620 kB     
Downloading: 630 kB     
Downloading: 630 kB     
Downloading: 630 kB     
Downloading: 630 kB     
Downloading: 630 kB     
Downloading: 630 kB     
Downloading: 640 kB     
Downloading: 640 kB     
Downloading: 640 kB     
Downloading: 640 kB     
Downloading: 640 kB     
Downloading: 640 kB     
Downloading: 650 kB     
Downloading: 650 kB     
Downloading: 650 kB     
Downloading: 650 kB     
Downloading: 650 kB     
Downloading: 650 kB     
Downloading: 650 kB     
Downloading: 650 kB     
Downloading: 650 kB     
Downloading: 650 kB     
Downloading: 650 kB     
Downloading: 650 kB     
Downloading: 660 kB     
Downloading: 660 kB     
Downloading: 660 kB     
Downloading: 660 kB     
Downloading: 660 kB     
Downloading: 660 kB     
Downloading: 670 kB     
Downloading: 670 kB     
Downloading: 670 kB     
Downloading: 670 kB     
Downloading: 670 kB     
Downloading: 670 kB     
Downloading: 680 kB     
Downloading: 680 kB     
Downloading: 680 kB     
Downloading: 680 kB     
Downloading: 680 kB     
Downloading: 680 kB     
Downloading: 690 kB     
Downloading: 690 kB     
Downloading: 690 kB     
Downloading: 690 kB     
Downloading: 690 kB     
Downloading: 690 kB     
Downloading: 690 kB     
Downloading: 690 kB     
Downloading: 690 kB     
Downloading: 690 kB     
Downloading: 690 kB     
Downloading: 690 kB     
Downloading: 700 kB     
Downloading: 700 kB     
Downloading: 700 kB     
Downloading: 700 kB     
Downloading: 700 kB     
Downloading: 700 kB     
Downloading: 710 kB     
Downloading: 710 kB     
Downloading: 710 kB     
Downloading: 710 kB     
Downloading: 710 kB     
Downloading: 710 kB     
Downloading: 720 kB     
Downloading: 720 kB     
Downloading: 720 kB     
Downloading: 720 kB     
Downloading: 720 kB     
Downloading: 720 kB     
Downloading: 730 kB     
Downloading: 730 kB     
Downloading: 730 kB     
Downloading: 730 kB     
Downloading: 730 kB     
Downloading: 730 kB     
Downloading: 730 kB     
Downloading: 730 kB     
Downloading: 730 kB     
Downloading: 730 kB     
Downloading: 730 kB     
Downloading: 730 kB     
Downloading: 740 kB     
Downloading: 740 kB     
Downloading: 740 kB     
Downloading: 740 kB     
Downloading: 740 kB     
Downloading: 740 kB     
Downloading: 750 kB     
Downloading: 750 kB     
Downloading: 750 kB     
Downloading: 750 kB     
Downloading: 750 kB     
Downloading: 750 kB     
Downloading: 760 kB     
Downloading: 760 kB     
Downloading: 760 kB     
Downloading: 760 kB     
Downloading: 760 kB     
Downloading: 760 kB     
Downloading: 770 kB     
Downloading: 770 kB     
Downloading: 770 kB     
Downloading: 770 kB     
Downloading: 770 kB     
Downloading: 770 kB     
Downloading: 780 kB     
Downloading: 780 kB     
Downloading: 780 kB     
Downloading: 780 kB     
Downloading: 780 kB     
Downloading: 780 kB     
Downloading: 780 kB     
Downloading: 780 kB     
Downloading: 780 kB     
Downloading: 780 kB     
Downloading: 780 kB     
Downloading: 780 kB     
Downloading: 790 kB     
Downloading: 790 kB     
Downloading: 790 kB     
Downloading: 790 kB     
Downloading: 790 kB     
Downloading: 790 kB     
Downloading: 800 kB     
Downloading: 800 kB     
Downloading: 800 kB     
Downloading: 800 kB     
Downloading: 800 kB     
Downloading: 800 kB     
Downloading: 810 kB     
Downloading: 810 kB     
Downloading: 810 kB     
Downloading: 810 kB     
Downloading: 810 kB     
Downloading: 810 kB     
Downloading: 820 kB     
Downloading: 820 kB     
Downloading: 820 kB     
Downloading: 820 kB     
Downloading: 820 kB     
Downloading: 820 kB     
Downloading: 820 kB     
Downloading: 820 kB     
Downloading: 820 kB     
Downloading: 820 kB     
Downloading: 820 kB     
Downloading: 820 kB     
Downloading: 830 kB     
Downloading: 830 kB     
Downloading: 830 kB     
Downloading: 830 kB     
Downloading: 830 kB     
Downloading: 830 kB     
Downloading: 840 kB     
Downloading: 840 kB     
Downloading: 840 kB     
Downloading: 840 kB     
Downloading: 840 kB     
Downloading: 840 kB     
Downloading: 850 kB     
Downloading: 850 kB     
Downloading: 850 kB     
Downloading: 850 kB     
Downloading: 850 kB     
Downloading: 850 kB     
Downloading: 860 kB     
Downloading: 860 kB     
Downloading: 860 kB     
Downloading: 860 kB     
Downloading: 860 kB     
Downloading: 860 kB     
Downloading: 860 kB     
Downloading: 860 kB     
Downloading: 860 kB     
Downloading: 860 kB     
Downloading: 860 kB     
Downloading: 860 kB     
Downloading: 870 kB     
Downloading: 870 kB     
Downloading: 870 kB     
Downloading: 870 kB     
Downloading: 870 kB     
Downloading: 870 kB     
Downloading: 880 kB     
Downloading: 880 kB     
Downloading: 880 kB     
Downloading: 880 kB     
Downloading: 880 kB     
Downloading: 880 kB     
Downloading: 890 kB     
Downloading: 890 kB     
Downloading: 890 kB     
Downloading: 890 kB     
Downloading: 890 kB     
Downloading: 890 kB     
Downloading: 900 kB     
Downloading: 900 kB     
Downloading: 900 kB     
Downloading: 900 kB     
Downloading: 900 kB     
Downloading: 900 kB     
Downloading: 900 kB     
Downloading: 900 kB     
Downloading: 900 kB     
Downloading: 900 kB     
Downloading: 900 kB     
Downloading: 900 kB     
Downloading: 910 kB     
Downloading: 910 kB     
Downloading: 910 kB     
Downloading: 910 kB     
Downloading: 910 kB     
Downloading: 910 kB     
Downloading: 920 kB     
Downloading: 920 kB     
Downloading: 920 kB     
Downloading: 920 kB     
Downloading: 920 kB     
Downloading: 920 kB     
Downloading: 930 kB     
Downloading: 930 kB     
Downloading: 930 kB     
Downloading: 930 kB     
Downloading: 930 kB     
Downloading: 930 kB     
Downloading: 940 kB     
Downloading: 940 kB     
Downloading: 940 kB     
Downloading: 940 kB     
Downloading: 940 kB     
Downloading: 940 kB     
Downloading: 950 kB     
Downloading: 950 kB     
Downloading: 950 kB     
Downloading: 950 kB     
Downloading: 950 kB     
Downloading: 950 kB     
Downloading: 950 kB     
Downloading: 950 kB     
Downloading: 950 kB     
Downloading: 950 kB     
Downloading: 950 kB     
Downloading: 950 kB     
Downloading: 960 kB     
Downloading: 960 kB     
Downloading: 960 kB     
Downloading: 960 kB     
Downloading: 960 kB     
Downloading: 960 kB     
Downloading: 970 kB     
Downloading: 970 kB     
Downloading: 970 kB     
Downloading: 970 kB     
Downloading: 970 kB     
Downloading: 970 kB     
Downloading: 980 kB     
Downloading: 980 kB     
Downloading: 980 kB     
Downloading: 980 kB     
Downloading: 980 kB     
Downloading: 980 kB     
Downloading: 990 kB     
Downloading: 990 kB     
Downloading: 990 kB     
Downloading: 990 kB     
Downloading: 990 kB     
Downloading: 990 kB     
Downloading: 990 kB     
Downloading: 990 kB     
Downloading: 990 kB     
Downloading: 990 kB     
Downloading: 990 kB     
Downloading: 990 kB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.1 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.2 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.3 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.4 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.5 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.6 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.7 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.8 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB     
Downloading: 1.9 MB
```

```r
data_health = st_set_geometry(data_health, NULL) #removendo os dados geo-espaciais (erro ao dar append.....)

data_collection_geobr = mongo(collection = "geobr", db = "data", url = 'mongodb://admin:password@10.68.14.110:27017')
data_collection_geobr$insert(data_health)
```

```
## List of 5
##  $ nInserted  : num 438
##  $ nMatched   : num 0
##  $ nRemoved   : num 0
##  $ nUpserted  : num 0
##  $ writeErrors: list()
```

```r
df = fread('list_1/tableExport.csv',
             select = 2:6,
            encoding = 'UTF-8',
            col.names = c('uf', 'municipio',  'ibge', 'cod_saude', 'nome_saude'))

data_collection_ibge = mongo(collection = "ibge", db = "data", url = 'mongodb://admin:password@10.68.14.110:27017')
data_collection_ibge$insert(df)
```

```
## List of 5
##  $ nInserted  : num 5571
##  $ nMatched   : num 0
##  $ nRemoved   : num 0
##  $ nUpserted  : num 0
##  $ writeErrors: list()
```

### Resolução 1.d)

```r
 # conexão com o Spark
source('list_2/conn/conn_spark.R')

# # populando o banco
# # criando as tables e suas respectivas colunas
data_saude = copy_to(sc, data_saude, "spark_data_saude")
data_health = copy_to(sc, data_health, "spark_data_health")
df = copy_to(sc, df, "spark_df")
```

### Resolução 1.e)



