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
  #html_nodes(xpath = '//*[@id="content"]') %>%
  #html_nodes('ul') %>%
  html_nodes('a') %>% 
  html_attr('href')
entries = entries[grep(pattern= '.csv', x = entries)]
entries = entries[grep(pattern = paste(c('uf%3DAC', 'uf%3DAL', 'uf%3DAM', 'uf%3DAP'), collapse = '|'), x = entries)]

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
pacman::p_load(vroom, tidyverse, kableExtra)

# carregando o arquivo previamente baixado (primeiro arquivo - AC parte 0)
data_1 = vroom(sort(list.files(dir_name, full.names = TRUE))[1],
               #locale = locale("br", encoding = "latin1"),
               num_threads = 3, delim = ";")

# head do df
knitr::kable(head(data_1)) %>%
  kable_styling(bootstrap_options = c("striped", "condensed"),
                full_width = TRUE,
                protect_latex = TRUE,
                position = 'center',
                #htmltable_class = 'lightable-striped'
                )
```

<table class="table table-striped table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> document_id </th>
   <th style="text-align:left;"> paciente_id </th>
   <th style="text-align:right;"> paciente_idade </th>
   <th style="text-align:left;"> paciente_dataNascimento </th>
   <th style="text-align:left;"> paciente_enumSexoBiologico </th>
   <th style="text-align:left;"> paciente_racaCor_codigo </th>
   <th style="text-align:left;"> paciente_racaCor_valor </th>
   <th style="text-align:right;"> paciente_endereco_coIbgeMunicipio </th>
   <th style="text-align:right;"> paciente_endereco_coPais </th>
   <th style="text-align:left;"> paciente_endereco_nmMunicipio </th>
   <th style="text-align:left;"> paciente_endereco_nmPais </th>
   <th style="text-align:left;"> paciente_endereco_uf </th>
   <th style="text-align:left;"> paciente_endereco_cep </th>
   <th style="text-align:left;"> paciente_nacionalidade_enumNacionalidade </th>
   <th style="text-align:left;"> estabelecimento_valor </th>
   <th style="text-align:left;"> estabelecimento_razaoSocial </th>
   <th style="text-align:left;"> estalecimento_noFantasia </th>
   <th style="text-align:right;"> estabelecimento_municipio_codigo </th>
   <th style="text-align:left;"> estabelecimento_municipio_nome </th>
   <th style="text-align:left;"> estabelecimento_uf </th>
   <th style="text-align:left;"> vacina_grupoAtendimento_codigo </th>
   <th style="text-align:left;"> vacina_grupoAtendimento_nome </th>
   <th style="text-align:right;"> vacina_categoria_codigo </th>
   <th style="text-align:left;"> vacina_categoria_nome </th>
   <th style="text-align:left;"> vacina_lote </th>
   <th style="text-align:left;"> vacina_fabricante_nome </th>
   <th style="text-align:left;"> vacina_fabricante_referencia </th>
   <th style="text-align:left;"> vacina_dataAplicacao </th>
   <th style="text-align:left;"> vacina_descricao_dose </th>
   <th style="text-align:right;"> vacina_codigo </th>
   <th style="text-align:left;"> vacina_nome </th>
   <th style="text-align:left;"> sistema_origem </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 1a44aaf2-0dd6-4289-809e-cb8de255e60d-i0b0 </td>
   <td style="text-align:left;"> 5266947cd5cd2f366f58be8aaad7d380eb9ab63ced4151c666a2ee613e987840 </td>
   <td style="text-align:right;"> 22 </td>
   <td style="text-align:left;"> 2000-02-24 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> SEM INFORMACAO </td>
   <td style="text-align:right;"> 120020 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> CRUZEIRO DO SUL </td>
   <td style="text-align:left;"> BRASIL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 69980 </td>
   <td style="text-align:left;"> B </td>
   <td style="text-align:left;"> 2002914 </td>
   <td style="text-align:left;"> PREFEITURA MUNICIPAL DE CRUZEIRO DO SUL </td>
   <td style="text-align:left;"> UNIDADE SAUDE DA FAMILIA 25 DE AGOSTO </td>
   <td style="text-align:right;"> 120020 </td>
   <td style="text-align:left;"> CRUZEIRO DO SUL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 000201 </td>
   <td style="text-align:left;"> Pessoas de 18 a 64 anos </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Faixa Etária </td>
   <td style="text-align:left;"> FF8848 </td>
   <td style="text-align:left;"> PFIZER </td>
   <td style="text-align:left;"> Organization/28290 </td>
   <td style="text-align:left;"> 2022-03-24 </td>
   <td style="text-align:left;"> 2ª Dose </td>
   <td style="text-align:right;"> 87 </td>
   <td style="text-align:left;"> COVID-19 PFIZER - COMIRNATY </td>
   <td style="text-align:left;"> Novo PNI </td>
  </tr>
  <tr>
   <td style="text-align:left;"> c7e064a2-fe65-4d1d-8fd8-d0a07bc21cf3-i0b0 </td>
   <td style="text-align:left;"> ec605567685d2bc7439395cf8a0d5d7c3e28894b7b6f8839fed454044f298779 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> 2001-09-03 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:left;"> 03 </td>
   <td style="text-align:left;"> PARDA </td>
   <td style="text-align:right;"> 120010 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> BRASILEIA </td>
   <td style="text-align:left;"> BRASIL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 69932 </td>
   <td style="text-align:left;"> B </td>
   <td style="text-align:left;"> 2001349 </td>
   <td style="text-align:left;"> PREFEITURA MUNICIPAL DE BRASILEIA </td>
   <td style="text-align:left;"> ESF TUFIC MIZAEL SAADY </td>
   <td style="text-align:right;"> 120010 </td>
   <td style="text-align:left;"> BRASILEIA </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 000206 </td>
   <td style="text-align:left;"> Pessoas de 12 a 17 anos </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Faixa Etária </td>
   <td style="text-align:left;"> FF8842 </td>
   <td style="text-align:left;"> PFIZER </td>
   <td style="text-align:left;"> Organization/00394544000851 </td>
   <td style="text-align:left;"> 2021-10-08 </td>
   <td style="text-align:left;"> 2ª Dose </td>
   <td style="text-align:right;"> 87 </td>
   <td style="text-align:left;"> COVID-19 PFIZER - COMIRNATY </td>
   <td style="text-align:left;"> Novo PNI </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 4e15de2c-8226-4208-a510-a49398d202e9-i0b0 </td>
   <td style="text-align:left;"> 1cdfdf4bc68e515dcc74fe99bcbc7ee26eef857164df11a5cd65e60e931023f8 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:left;"> 2006-06-22 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> SEM INFORMACAO </td>
   <td style="text-align:right;"> 120050 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> SENA MADUREIRA </td>
   <td style="text-align:left;"> BRASIL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 69940 </td>
   <td style="text-align:left;"> B </td>
   <td style="text-align:left;"> 3541592 </td>
   <td style="text-align:left;"> PREFEITURA MUNICIPAL DE SENA MADUREIRA </td>
   <td style="text-align:left;"> UNIDADE BASICA DE SAUDE MARIA DAS DORES DE PAULA </td>
   <td style="text-align:right;"> 120050 </td>
   <td style="text-align:left;"> SENA MADUREIRA </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 000201 </td>
   <td style="text-align:left;"> Pessoas de 18 a 64 anos </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Faixa Etária </td>
   <td style="text-align:left;"> FA9096 </td>
   <td style="text-align:left;"> PFIZER </td>
   <td style="text-align:left;"> Organization/00394544000851 </td>
   <td style="text-align:left;"> 2021-08-11 </td>
   <td style="text-align:left;"> 1ª Dose </td>
   <td style="text-align:right;"> 87 </td>
   <td style="text-align:left;"> COVID-19 PFIZER - COMIRNATY </td>
   <td style="text-align:left;"> Novo PNI </td>
  </tr>
  <tr>
   <td style="text-align:left;"> c7e305e0-fc4e-4acf-bdcb-56d89a89135a-i0b0 </td>
   <td style="text-align:left;"> e15a40481f92fd76ef35e50cf1e17859cb4ad7e3fde8cc282585fe2a60938135 </td>
   <td style="text-align:right;"> 68 </td>
   <td style="text-align:left;"> 1953-10-16 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:left;"> 03 </td>
   <td style="text-align:left;"> PARDA </td>
   <td style="text-align:right;"> 120040 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> RIO BRANCO </td>
   <td style="text-align:left;"> BRASIL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> B </td>
   <td style="text-align:left;"> 6917291 </td>
   <td style="text-align:left;"> PREFEITURA MUNICIPAL DE RIO BRANCO </td>
   <td style="text-align:left;"> DEPARTAMENTO DE VIGILANCIA EPIDEMIOLOGICA E AMBIENTAL </td>
   <td style="text-align:right;"> 120040 </td>
   <td style="text-align:left;"> RIO BRANCO </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 000202 </td>
   <td style="text-align:left;"> Pessoas de 65 a 69 anos </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Faixa Etária </td>
   <td style="text-align:left;"> FL1939 </td>
   <td style="text-align:left;"> PFIZER </td>
   <td style="text-align:left;"> Organization/28290 </td>
   <td style="text-align:left;"> 2021-12-28 </td>
   <td style="text-align:left;"> Reforço </td>
   <td style="text-align:right;"> 87 </td>
   <td style="text-align:left;"> COVID-19 PFIZER - COMIRNATY </td>
   <td style="text-align:left;"> Novo PNI </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 4e992b56-494a-43a6-b093-9f3450338bda-i0b0 </td>
   <td style="text-align:left;"> 07c37bf70113e321baba138c594fdc8558918fc9ae9ab356953ca7f75e9e2fff </td>
   <td style="text-align:right;"> 30 </td>
   <td style="text-align:left;"> 1991-06-08 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:left;"> 04 </td>
   <td style="text-align:left;"> AMARELA </td>
   <td style="text-align:right;"> 120050 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> SENA MADUREIRA </td>
   <td style="text-align:left;"> BRASIL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 69940 </td>
   <td style="text-align:left;"> B </td>
   <td style="text-align:left;"> 5981891 </td>
   <td style="text-align:left;"> PREFEITURA MUNICIIPAL DE SENA MADUREIRA </td>
   <td style="text-align:left;"> UNIDADE BASICA DE SAUDE MODULO I </td>
   <td style="text-align:right;"> 120050 </td>
   <td style="text-align:left;"> SENA MADUREIRA </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 000201 </td>
   <td style="text-align:left;"> Pessoas de 18 a 64 anos </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Faixa Etária </td>
   <td style="text-align:left;"> 1855836 </td>
   <td style="text-align:left;"> JANSSEN </td>
   <td style="text-align:left;"> Organization/30587 </td>
   <td style="text-align:left;"> 2022-01-24 </td>
   <td style="text-align:left;"> Reforço </td>
   <td style="text-align:right;"> 88 </td>
   <td style="text-align:left;"> COVID-19 JANSSEN - Ad26.COV2.S </td>
   <td style="text-align:left;"> Novo PNI </td>
  </tr>
  <tr>
   <td style="text-align:left;"> c7f3fe19-c5cb-4a0b-9073-7106423d3aaf-i0b0 </td>
   <td style="text-align:left;"> 952597e9f7b92a578ef42088b923ab25d4a67829ad8e7e8962f9f423a2b71aaa </td>
   <td style="text-align:right;"> 63 </td>
   <td style="text-align:left;"> 1957-05-26 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:left;"> 01 </td>
   <td style="text-align:left;"> BRANCA </td>
   <td style="text-align:right;"> 120032 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> JORDAO </td>
   <td style="text-align:left;"> BRASIL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 69975 </td>
   <td style="text-align:left;"> B </td>
   <td style="text-align:left;"> 5354072 </td>
   <td style="text-align:left;"> PREFEITURA MUNICIPAL DE JORDAO </td>
   <td style="text-align:left;"> UNIDADE DE SAUDE DA FAMILIA ANTONIO RODRIGUES DOURADO </td>
   <td style="text-align:right;"> 120032 </td>
   <td style="text-align:left;"> JORDAO </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 000201 </td>
   <td style="text-align:left;"> Pessoas de 18 a 64 anos </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Faixa Etária </td>
   <td style="text-align:left;"> 210038 </td>
   <td style="text-align:left;"> SINOVAC/BUTANTAN </td>
   <td style="text-align:left;"> Organization/61189445000156 </td>
   <td style="text-align:left;"> 2021-03-26 </td>
   <td style="text-align:left;"> 1ª Dose </td>
   <td style="text-align:right;"> 86 </td>
   <td style="text-align:left;"> COVID-19 SINOVAC/BUTANTAN - CORONAVAC </td>
   <td style="text-align:left;"> Novo PNI </td>
  </tr>
</tbody>
</table>

```r
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
document_id  | identificador do documento;
paciente_id  | identificador do paciente;
paciente_idade  | idade do vacinado;
paciente_dataNascimento  | data de nascimento do vacinado;
paciente_enumSexoBiologico  | sexo do vacinado (M = masculino, F = feminino);
paciente_racaCor_codigo  | código da raça/cor do vacinado (1, 2, 3, 4, 99);
paciente_racaCor_valor  | descrição da raça/cor do vacinado (1 = branca, 2 = preta, 3 = parda, 4 = amarela, 99 = sem informação);
paciente_endereco_coIbgeMunicipio  | código IBGE do município de endereço do vacinado;
paciente_endereco_coPais  | código do país de endereço do vacinado;
paciente_endereco_nmMunicipio  | nome do município de endereço do vacinado;
paciente_endereco_nmPais | nome do país de endereço do vacinado;
paciente_endereco_uf | sigla da UF de endereço do vacinado;
paciente_endereco_cep | 5 dígitos para anonimizado e 7 dígitos para identificado;
paciente_nacionalidade_enumNacionalidade | nacionalidade do vacinado;
estabelecimento_valor | código do CNES do estabelecimento que realizou a vacinação;
estabelecimento_razaoSocial | nome/razão social do estabelecimento;
estalecimento_noFantasia | nome fantasia do estabelecimento;
estabelecimento_municipio_codigo | código do município do estabelecimento;
estabelecimento_municipio_nome | nome do município do estabelecimento;
estabelecimento_uf | sigla da UF do estabelecimento;
vacina_grupoAtendimento_codigo | código do grupo de atendimento ao qual pertence o vacinado;
vacina_grupoAtendimento_nome | nome do grupo de atendimento ao qual pertence o vacinado;
vacina_categoria_codigo | código da categoria;
vacina_categoria_nome | descrição da categoria;
vacina_lote | número do lote da vacina;
vacina_fabricante_nome | nome do fabricante/fornecedor;
vacina_fabricante_referencia | CNPJ do fabricante/fornecedor;
vacina_dataAplicacao | data de aplicação da vacina;
vacina_descricao_dose | descrição da dose;
vacina_codigo | código da vacina;
vacina_nome | nome da vacina/produto;
sistema_origem | nome do sistema de origem;



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
knitr::kable(head(data_1_slice)) %>%
  kable_styling(bootstrap_options = c("striped", "condensed"),
                full_width = TRUE,
                protect_latex = TRUE,
                position = 'center',
                #htmltable_class = 'lightable-striped'
                )

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




