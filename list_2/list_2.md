---
title: |
  ![](www/logo-UnB.png){width=75%}  <br>
  Lista 1: Computação eficiente
subtitle: "Computação em Estatística para dados e cálculos massivos"
author: "<b>Autor:</b> Lucas Loureiro Lino da Costa"
affiliation: "Universidade de Brasília"
date: "15 de agosto de 2022"
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
# funções customizadas

# função para popular o DB
db_populate = function(table_name, append_func){
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
```


# Questões

## Questão 1: Criando bancos de dados. {.tabset .tabset-fade .tabset-pills}

### Resolução 1.a)

```r
# instalação dos pacotes casso necessário via pacman e carregamentos destes
if (!require('pacman')) install.packages('pacman')
p_load(dplyr, tidyverse, rmdformats, stringr, 
       vroom, mongolite, RSQLite, DBI, dbplyr,
       data.table, geobr)

# checando se o diretório existe e se necessário criá-lo para o SQLite
dir_name = 'list_2/dados'
if (file.exists(dir_name) == FALSE) {
  dir.create(dir_name)
  } else {
    invisible()
}

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
  
  l = lapply(list.files('list_1/dados/', full.names = TRUE),
           fread, 
           select = c('estabelecimento_uf', 'vacina_descricao_dose', 'estabelecimento_municipio_codigo'),
           encoding = 'UTF-8',
           sep = ';')
  
  data_saude = rbindlist(l)
  dbAppendTable(conn, 'saude', data_saude)
  
}

db_populate('saude', saude)
# 
# dbListTables(conn)
# dbRemoveTable(conn,"saude")
# dbListFields(conn, "saude")
# # populando o banco
# # criando as tables e suas respectivas colunas
# # segunda table
# dbCreateTable(conn = conn, 'geobr', )
# 
# # populando o banco
# # criando as tables e suas respectivas colunas
# # terceira table
# dbCreateTable(conn = conn, 'ibge', )


# checango tables e colunas
for (item in dbListTables(conn)){
  print(paste('Nome da tabela:', item))
  print(dbListFields(conn, item))
  print('')
}
```

```
## [1] "Nome da tabela: saude"
## [1] "estabelecimento_uf"               "vacina_descricao_dose"           
## [3] "estabelecimento_municipio_codigo"
## [1] ""
```

```r
# desconectar
dbDisconnect(conn)
```

### Resolução 1.b)


### Resolução 1.c)


### Resolução 1.d)


### Resolução 1.e)



