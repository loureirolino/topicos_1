---
title: |
  ![](www/logo-UnB.png){width=75%}  <br> </br>
  Lista 1: Computação eficiente
subtitle: "Computação em Estatística para dados e cálculos massivos"
author: "<b>Autor:</b> Lucas Loureiro Lino da Costa"
affiliation: "Universidade de Brasília"
date: "01 de agosto de 2022"
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
**3.** O comando original das questões pode ser encontradas no [github](https://github.com/loureirolino/topicos_1/blob/main/assignments/Lista_1.pdf) do autor desse HTML.  
**4.** As pastas com arquivos baixados foram configuradas para não serem integradas ao github, para evitar subir um volume desnecessário de arquivos.

# Questões

## Questão 1: leitura eficiente de dados {.tabset .tabset-fade .tabset-pills}

### Resolução 1.a)

```r
### CUIDADO AO RODAR ESSE CHUNK, DADOS MASSIVOS!!!!

# checando se o diretório existe e se necessário criá-lo
dir_name = 'dados'
if (file.exists(dir_name) == FALSE) {
  dir.create(dir_name)
  } else {
    invisible()
}

# baixando todos os arquivos dentro da URL base (scrap)
if (!require("pacman")) install.packages("pacman")
pacman::p_load(rvest)

base_url = read_html('https://opendatasus.saude.gov.br/dataset/covid-19-vacinacao/resource/5093679f-12c3-4d6b-b7bd-07694de54173?inner_span=True')

entries = base_url %>%
  html_nodes(xpath = '//*[@id="content"]') %>%
  #html_nodes('ul') %>%
  #html_nodes('a') %>% 
  html_attr('href')
entries = entries[grep(pattern= '.csv', x = entries)]
entries = entries[grep(pattern = ''), x = entries]

options(timeout=999999) # essa linha é um workaround para o timeout do download

for (i in 1:length(entries)) {
  if (file.exists(paste0(dir_name, '/', 'file_', i,'.csv')) == FALSE) {
    download.file(entries[i],
                  destfile = paste0(dir_name, '/', 'file_', i, '.csv'),
                  mode='wb',
                  quiet = TRUE,
                  cacheOK=FALSE,
                  method="libcurl",
                  url.method="libcurl")
  } else {
    invisible()
  }
}
```

### Resolução 1.b)

```r
# instalação dos pacotes casso necessário via pacman e carregamantos destes
if (!require("pacman")) install.packages("pacman")
pacman::p_load(vroom, tidyverse)

# carregando o arquivo previamente baixado (primeiro arquivo)
data_1 = vroom(sort(list.files(dir_name, full.names = TRUE))[1],
               #locale = locale("br", encoding = "latin1"),
               num_threads = 3, delim = ";")

# head do df
data_1[1:10,]

# carregando o arquivo diretamente da internet
# data_1 =vroom(entries[1],
                #locale = locale("br", encoding = "latin1"),
#               num_threads = 3, delim = ";")
```


O arquivo contendo o dicionário das variáveis pode ser encontrado no link abaixo:  
[Dicionário](https://opendatasus.saude.gov.br/dataset/8e0c325d-2586-4b11-8925-4ba51acd6e6d/resource/a8308b58-8898-4c6d-8119-400c722c71b5/download/dicionario-de-dados-vacinacao.pdf):

A mesma informação pode ser visualizada abaixo:

**Descrição do Conjunto de Dados**

Variável | Descrição 
---|------------------------------------------------------------------------------
document_id  | ;
paciente_id  | ;
paciente_dataNascimento  | ;
paciente_enumSexoBiologico  | ;
paciente_racaCor_codigo  | ;
paciente_racaCor_valor  | ;
paciente_endereco_coIbgeMunicipio  | ;
paciente_endereco_coPais  | ;
paciente_endereco_nmMunicipio  | ;
paciente_endereco_nmPais | Gráficos (1);
paciente_endereco_uf | ;
paciente_endereco_cep | ;
paciente_nacionalidade_enumNacionalidade | ;
estabelecimento_valor | ;
estabelecimento_razaoSocial | ;
estalecimento_noFantasia | ;
estabelecimento_municipio_codigo | ;
estabelecimento_municipio_nome | ;
estabelecimento_uf | ;
vacina_grupoAtendimento_codigo | ;
vacina_grupoAtendimento_nome | ;
vacina_categoria_codigo | ;
vacina_categoria_nome | ;
vacina_lote | ;
vacina_fabricante_nome | ;
vacina_fabricante_referencia | ;
vacina_dataAplicacao | ;
vacina_descricao_dose | ;
vacina_codigo | ;
vacina_nome | ;
sistema_origem | ;



### Resolução 1.c)

```r
# Dimensão dos arquivos separados (bytes para MB)
for (file in list.files(dir_name, full.names = TRUE)){
  print(paste(file, file.info(file)$size*(9.537*10^-7), 'MB'))
}


# Dimensão dos arquivos unificados (em MB)
print(paste("Total folder dados unificado",
            sum(sapply(map(list.files(dir_name, full.names = TRUE), file.info), function(x) x[[1]]))*(9.537*10^-7),
            'MB'))
```

### Resolução 1.d)

```r
# usando o arquivo previamente baixado (primeiro arquivo)
# pegando para todas as entradas que contenha a palavra astrazeneca em todas as suas formas (case sensitive)
data_1_slice = vroom(pipe(paste0('grep -wi astrazeneca ', sort(list.files(dir_name, full.names = TRUE))[1])),
               col_names = names(data_1),
               #locale = locale("br", encoding = "latin1"),
               num_threads = 3, delim = ";")

# head do df
data_1_slice[1:10,]

# entradas únicas de vacina_fabricante_nome e vacina_nome
unique(data_1_slice$vacina_fabricante_nome)
unique(data_1_slice$vacina_nome)
```

### Resolução 1.e)

```r
# Carregando todos os arquivos de uma única vez (vroom)
files = list.files(dir_name, full.names = TRUE)
data_complete = vroom(files, locale = locale("br",
                      #encoding = "latin1"),
                      num_threads = 3, delim = ";")
```

## Questão 2: manipulação de dados {.tabset .tabset-fade .tabset-pills}

### Resolução 2.a)


### Resolução 2.b)


### Resolução 2.c)


### Resolução 2.d)




