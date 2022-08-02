---
title: |
  ![](www/logo-UnB.png){width=75%}  <br>
  Lista 1: Computação eficiente
subtitle: "Computação em Estatística para dados e cálculos massivos"
author: "<b>Autor:</b> Lucas Loureiro Lino da Costa"
affiliation: "Universidade de Brasília"
date: "02 de agosto de 2022"
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
# instalação dos pacotes casso necessário via pacman e carregamentos destes
if (!require("pacman")) install.packages("pacman")
pacman::p_load(vroom, tidyverse, kableExtra)

# carregando o arquivo previamente baixado (primeiro arquivo - AC parte 0)
if ('data_1' %in% ls() == TRUE){
    invisible()
  }else{
    # use locale apenas caso tenha problemas de econding
    data_1 = vroom(list.files(dir_name, full.names = TRUE)[1],
                   #locale = locale("br", encoding = "latin1"),
                   num_threads = 3, delim = ";")
}

# head do df
knitr::kable(head(data_1)) %>%
  kable_styling(bootstrap_options = c("striped", "condensed"),
                full_width = TRUE,
                protect_latex = TRUE,
                position = 'center')
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


O arquivo contendo o dicionário das variáveis pode ser encontrado no link abaixo [Dicionário](https://opendatasus.saude.gov.br/dataset/8e0c325d-2586-4b11-8925-4ba51acd6e6d/resource/a8308b58-8898-4c6d-8119-400c722c71b5/download/dicionario-de-dados-vacinacao.pdf)

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
# Dimensão dos arquivos separados no HD (bytes para MB)
for (file in list.files(dir_name, full.names = TRUE)){
  print(paste(file, file.info(file)$size*(9.537*10^-7), 'MB'))
}
```

```
## [1] "dados/file_1.csv 249.9311415843 MB"
## [1] "dados/file_10.csv 198.4682202096 MB"
## [1] "dados/file_11.csv 199.1800390008 MB"
## [1] "dados/file_12.csv 199.522318116 MB"
## [1] "dados/file_2.csv 249.1863467082 MB"
## [1] "dados/file_3.csv 250.0449361146 MB"
## [1] "dados/file_4.csv 987.5625061335 MB"
## [1] "dados/file_5.csv 985.7884553286 MB"
## [1] "dados/file_6.csv 989.6171803023 MB"
## [1] "dados/file_7.csv 1138.2955445565 MB"
## [1] "dados/file_8.csv 1139.6318518299 MB"
## [1] "dados/file_9.csv 1141.4629605984 MB"
```

```r
# Dimensão dos arquivos unificados no HD (em MB)
print(paste("Total folder dados unificado",
            sum(sapply(map(list.files(dir_name, full.names = TRUE), file.info), function(x) x[[1]]))*(9.537*10^-7),
            'MB'))
```

```
## [1] "Total folder dados unificado 7728.6915004827 MB"
```

```r
# usando file.size do pacote fs
# Dimensão dos arquivos separados no HD (bytes para MB)
unlist(paste(list.files(dir_name, full.names = TRUE), map(.f = utils:::format.object_size, .x = file.size(list.files(dir_name, full.names = TRUE)), units = 'Mb')))
```

```
##  [1] "dados/file_1.csv 249.9 Mb"  "dados/file_10.csv 198.5 Mb"
##  [3] "dados/file_11.csv 199.2 Mb" "dados/file_12.csv 199.5 Mb"
##  [5] "dados/file_2.csv 249.2 Mb"  "dados/file_3.csv 250 Mb"   
##  [7] "dados/file_4.csv 987.5 Mb"  "dados/file_5.csv 985.8 Mb" 
##  [9] "dados/file_6.csv 989.6 Mb"  "dados/file_7.csv 1138.3 Mb"
## [11] "dados/file_8.csv 1139.6 Mb" "dados/file_9.csv 1141.4 Mb"
```

```r
# usando file.size do pacote fs
# Dimensão dos arquivos unificados no HD (em MB)
utils:::format.object_size(sum(file.size(list.files(dir_name, full.names = TRUE))), units = 'Mb')
```

```
## [1] "7728.5 Mb"
```

```r
# usando object.size do pacote fs
# Dimensão do primeiro arquivo na RAM (bytes para MB)
print(paste(list.files(dir_name)[1], utils:::format.object_size(object.size(data_1), units = 'Mb')))
```

```
## [1] "file_1.csv 238.2 Mb"
```

```r
# diferença HD e RAM
utils:::format.object_size(file.size(list.files(dir_name, full.names = TRUE)[1])-object.size(data_1), units = 'Mb')
```

```
## [1] "11.7 Mb"
```

### Resolução 1.d)

```r
# usando o arquivo previamente baixado (primeiro arquivo)
# pegando para todas as entradas que contenha a palavra Janssen em todas as suas formas (case sensitive)
# use locale apenas caso tenha problemas de econdingng

if ('data_1_slice' %in% ls() == TRUE){
    invisible()
  }else{
    # use locale apenas caso tenha problemas de econding
    data_1_slice = vroom(pipe(paste0('grep -wi Janssen ', list.files(dir_name, full.names = TRUE)[1])),
                   col_names = names(data_1),
                   #locale = locale("br", encoding = "latin1"),
                   num_threads = 3, delim = ";")
}

# head do df
knitr::kable(head(data_1_slice)) %>%
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
   <td style="text-align:left;"> d87a46a4-080a-4fb3-be87-055144ee9801-i0b0 </td>
   <td style="text-align:left;"> 33c2a9897aea990e8ec6f13798e155f30db17407ab8fe56c4032b60fdf47d45f </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:left;"> 1999-06-08 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:left;"> 03 </td>
   <td style="text-align:left;"> PARDA </td>
   <td style="text-align:right;"> 120040 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> RIO BRANCO </td>
   <td style="text-align:left;"> BRASIL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 69920 </td>
   <td style="text-align:left;"> B </td>
   <td style="text-align:left;"> 6917291 </td>
   <td style="text-align:left;"> PREFEITURA MUNICIPAL DE RIO BRANCO </td>
   <td style="text-align:left;"> DEPARTAMENTO DE VIGILANCIA EPIDEMIOLOGICA E AMBIENTAL </td>
   <td style="text-align:right;"> 120040 </td>
   <td style="text-align:left;"> RIO BRANCO </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 000201 </td>
   <td style="text-align:left;"> Pessoas de 18 a 64 anos </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Faixa Etária </td>
   <td style="text-align:left;"> 212J21A </td>
   <td style="text-align:left;"> JANSSEN </td>
   <td style="text-align:left;"> Organization/30587 </td>
   <td style="text-align:left;"> 2022-06-15 </td>
   <td style="text-align:left;"> Dose Adicional </td>
   <td style="text-align:right;"> 88 </td>
   <td style="text-align:left;"> COVID-19 JANSSEN - Ad26.COV2.S </td>
   <td style="text-align:left;"> Novo PNI </td>
  </tr>
  <tr>
   <td style="text-align:left;"> d5e90f13-03ed-477a-b6e1-5603ac043e93-i0b0 </td>
   <td style="text-align:left;"> 6993563504bcecb37e788e1e1a1626ef26b4affbe9eed45628a007149c727320 </td>
   <td style="text-align:right;"> 68 </td>
   <td style="text-align:left;"> 1954-01-03 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:left;"> 04 </td>
   <td style="text-align:left;"> AMARELA </td>
   <td style="text-align:right;"> 120040 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> RIO BRANCO </td>
   <td style="text-align:left;"> BRASIL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 69902 </td>
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
   <td style="text-align:left;"> 1855836 </td>
   <td style="text-align:left;"> JANSSEN </td>
   <td style="text-align:left;"> Organization/30587 </td>
   <td style="text-align:left;"> 2022-05-23 </td>
   <td style="text-align:left;"> 2º Reforço </td>
   <td style="text-align:right;"> 88 </td>
   <td style="text-align:left;"> COVID-19 JANSSEN - Ad26.COV2.S </td>
   <td style="text-align:left;"> Novo PNI </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 02c9ee38-5ad3-42bc-b520-8c2d95a46e1e-i0b0 </td>
   <td style="text-align:left;"> 56a9fda404368c16c27913b33ef1861f08acaf99ad48e8747c9f6462485ece58 </td>
   <td style="text-align:right;"> 47 </td>
   <td style="text-align:left;"> 1975-02-18 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:left;"> 04 </td>
   <td style="text-align:left;"> AMARELA </td>
   <td style="text-align:right;"> 120040 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> RIO BRANCO </td>
   <td style="text-align:left;"> BRASIL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 69918 </td>
   <td style="text-align:left;"> B </td>
   <td style="text-align:left;"> 6917291 </td>
   <td style="text-align:left;"> PREFEITURA MUNICIPAL DE RIO BRANCO </td>
   <td style="text-align:left;"> DEPARTAMENTO DE VIGILANCIA EPIDEMIOLOGICA E AMBIENTAL </td>
   <td style="text-align:right;"> 120040 </td>
   <td style="text-align:left;"> RIO BRANCO </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 000926 </td>
   <td style="text-align:left;"> Outros </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> Trabalhadores de Saúde </td>
   <td style="text-align:left;"> 212J21A </td>
   <td style="text-align:left;"> JANSSEN </td>
   <td style="text-align:left;"> Organization/30587 </td>
   <td style="text-align:left;"> 2022-06-07 </td>
   <td style="text-align:left;"> 2º Reforço </td>
   <td style="text-align:right;"> 88 </td>
   <td style="text-align:left;"> COVID-19 JANSSEN - Ad26.COV2.S </td>
   <td style="text-align:left;"> Novo PNI </td>
  </tr>
  <tr>
   <td style="text-align:left;"> a4748591-a3b0-43c2-803d-c64095441c9f-i0b0 </td>
   <td style="text-align:left;"> bd4a0068b5aff0512e50b691e2784c46bb665ff8c697fc7a9acf1fcc4a46deee </td>
   <td style="text-align:right;"> 29 </td>
   <td style="text-align:left;"> 1992-05-13 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:left;"> 04 </td>
   <td style="text-align:left;"> AMARELA </td>
   <td style="text-align:right;"> 120040 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> RIO BRANCO </td>
   <td style="text-align:left;"> BRASIL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 69914 </td>
   <td style="text-align:left;"> B </td>
   <td style="text-align:left;"> 6917291 </td>
   <td style="text-align:left;"> PREFEITURA MUNICIPAL DE RIO BRANCO </td>
   <td style="text-align:left;"> DEPARTAMENTO DE VIGILANCIA EPIDEMIOLOGICA E AMBIENTAL </td>
   <td style="text-align:right;"> 120040 </td>
   <td style="text-align:left;"> RIO BRANCO </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 000201 </td>
   <td style="text-align:left;"> Pessoas de 18 a 64 anos </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Faixa Etária </td>
   <td style="text-align:left;"> 1855836 </td>
   <td style="text-align:left;"> JANSSEN </td>
   <td style="text-align:left;"> Organization/30587 </td>
   <td style="text-align:left;"> 2022-01-25 </td>
   <td style="text-align:left;"> Reforço </td>
   <td style="text-align:right;"> 88 </td>
   <td style="text-align:left;"> COVID-19 JANSSEN - Ad26.COV2.S </td>
   <td style="text-align:left;"> Novo PNI </td>
  </tr>
  <tr>
   <td style="text-align:left;"> e324584a-0c53-4888-977d-78671bf39041-i0b0 </td>
   <td style="text-align:left;"> f2ab8bafa327d4242c75d21dfb45c5864d6b4b350290f17ccdf5b08439099bed </td>
   <td style="text-align:right;"> 46 </td>
   <td style="text-align:left;"> 1976-03-20 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:left;"> 03 </td>
   <td style="text-align:left;"> PARDA </td>
   <td style="text-align:right;"> 120035 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> MARECHAL THAUMATURGO </td>
   <td style="text-align:left;"> BRASIL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 69983 </td>
   <td style="text-align:left;"> B </td>
   <td style="text-align:left;"> 2002132 </td>
   <td style="text-align:left;"> PREFEITURA MUN DE MAL THAUMATURGO </td>
   <td style="text-align:left;"> ESF RIBEIRINHA DR NALDIR MARIANO </td>
   <td style="text-align:right;"> 120035 </td>
   <td style="text-align:left;"> MARECHAL THAUMATURGO </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 000602 </td>
   <td style="text-align:left;"> Ribeirinha </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> Povos e Comunidades Tradicionais </td>
   <td style="text-align:left;"> 205F21A </td>
   <td style="text-align:left;"> JANSSEN </td>
   <td style="text-align:left;"> Organization/30587 </td>
   <td style="text-align:left;"> 2022-05-09 </td>
   <td style="text-align:left;"> Reforço </td>
   <td style="text-align:right;"> 88 </td>
   <td style="text-align:left;"> COVID-19 JANSSEN - Ad26.COV2.S </td>
   <td style="text-align:left;"> Novo PNI </td>
  </tr>
</tbody>
</table>

```r
# entradas únicas de vacina_fabricante_nome e vacina_nome
unique(data_1_slice$vacina_fabricante_nome)
```

```
## [1] "JANSSEN"                     "Organization/30587"         
## [3] "Organization/00394544000851"
```

```r
unique(data_1_slice$vacina_nome)
```

```
## [1] "COVID-19 JANSSEN - Ad26.COV2.S" "Novo PNI"
```

```r
# diferença HD e RAM
utils:::format.object_size(file.size(list.files(dir_name, full.names = TRUE)[1])-object.size(data_1_slice), units = 'Mb')
```

```
## [1] "242.1 Mb"
```

### Resolução 1.e)

```r
# Carregando todos os arquivos de uma única vez (vroom)
files = list.files(dir_name, full.names = TRUE)

if ('data_complete' %in% ls() == TRUE){
    invisible()
  }else{
    # use locale apenas caso tenha problemas de econding
    data_complete = vroom(pipe(paste0('grep -wi Janssen ', gsub(pattern = ',', replacement = ' ', toString(files)))),
                      col_names = names(data_1),
                      #locale = locale("br",encoding = "latin1"),
                      num_threads = 3, delim = ";")
}

# head do df
knitr::kable(head(data_complete)) %>%
  kable_styling(bootstrap_options = c("striped", "condensed"),
                full_width = TRUE,
                protect_latex = TRUE,
                position = 'center')
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
   <td style="text-align:left;"> dados/file_1.csv:"4e992b56-494a-43a6-b093-9f3450338bda-i0b0" </td>
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
   <td style="text-align:left;"> dados/file_1.csv:"d87a46a4-080a-4fb3-be87-055144ee9801-i0b0" </td>
   <td style="text-align:left;"> 33c2a9897aea990e8ec6f13798e155f30db17407ab8fe56c4032b60fdf47d45f </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:left;"> 1999-06-08 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:left;"> 03 </td>
   <td style="text-align:left;"> PARDA </td>
   <td style="text-align:right;"> 120040 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> RIO BRANCO </td>
   <td style="text-align:left;"> BRASIL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 69920 </td>
   <td style="text-align:left;"> B </td>
   <td style="text-align:left;"> 6917291 </td>
   <td style="text-align:left;"> PREFEITURA MUNICIPAL DE RIO BRANCO </td>
   <td style="text-align:left;"> DEPARTAMENTO DE VIGILANCIA EPIDEMIOLOGICA E AMBIENTAL </td>
   <td style="text-align:right;"> 120040 </td>
   <td style="text-align:left;"> RIO BRANCO </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 000201 </td>
   <td style="text-align:left;"> Pessoas de 18 a 64 anos </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Faixa Etária </td>
   <td style="text-align:left;"> 212J21A </td>
   <td style="text-align:left;"> JANSSEN </td>
   <td style="text-align:left;"> Organization/30587 </td>
   <td style="text-align:left;"> 2022-06-15 </td>
   <td style="text-align:left;"> Dose Adicional </td>
   <td style="text-align:right;"> 88 </td>
   <td style="text-align:left;"> COVID-19 JANSSEN - Ad26.COV2.S </td>
   <td style="text-align:left;"> Novo PNI </td>
  </tr>
  <tr>
   <td style="text-align:left;"> dados/file_1.csv:"d5e90f13-03ed-477a-b6e1-5603ac043e93-i0b0" </td>
   <td style="text-align:left;"> 6993563504bcecb37e788e1e1a1626ef26b4affbe9eed45628a007149c727320 </td>
   <td style="text-align:right;"> 68 </td>
   <td style="text-align:left;"> 1954-01-03 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:left;"> 04 </td>
   <td style="text-align:left;"> AMARELA </td>
   <td style="text-align:right;"> 120040 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> RIO BRANCO </td>
   <td style="text-align:left;"> BRASIL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 69902 </td>
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
   <td style="text-align:left;"> 1855836 </td>
   <td style="text-align:left;"> JANSSEN </td>
   <td style="text-align:left;"> Organization/30587 </td>
   <td style="text-align:left;"> 2022-05-23 </td>
   <td style="text-align:left;"> 2º Reforço </td>
   <td style="text-align:right;"> 88 </td>
   <td style="text-align:left;"> COVID-19 JANSSEN - Ad26.COV2.S </td>
   <td style="text-align:left;"> Novo PNI </td>
  </tr>
  <tr>
   <td style="text-align:left;"> dados/file_1.csv:"02c9ee38-5ad3-42bc-b520-8c2d95a46e1e-i0b0" </td>
   <td style="text-align:left;"> 56a9fda404368c16c27913b33ef1861f08acaf99ad48e8747c9f6462485ece58 </td>
   <td style="text-align:right;"> 47 </td>
   <td style="text-align:left;"> 1975-02-18 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:left;"> 04 </td>
   <td style="text-align:left;"> AMARELA </td>
   <td style="text-align:right;"> 120040 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> RIO BRANCO </td>
   <td style="text-align:left;"> BRASIL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 69918 </td>
   <td style="text-align:left;"> B </td>
   <td style="text-align:left;"> 6917291 </td>
   <td style="text-align:left;"> PREFEITURA MUNICIPAL DE RIO BRANCO </td>
   <td style="text-align:left;"> DEPARTAMENTO DE VIGILANCIA EPIDEMIOLOGICA E AMBIENTAL </td>
   <td style="text-align:right;"> 120040 </td>
   <td style="text-align:left;"> RIO BRANCO </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 000926 </td>
   <td style="text-align:left;"> Outros </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> Trabalhadores de Saúde </td>
   <td style="text-align:left;"> 212J21A </td>
   <td style="text-align:left;"> JANSSEN </td>
   <td style="text-align:left;"> Organization/30587 </td>
   <td style="text-align:left;"> 2022-06-07 </td>
   <td style="text-align:left;"> 2º Reforço </td>
   <td style="text-align:right;"> 88 </td>
   <td style="text-align:left;"> COVID-19 JANSSEN - Ad26.COV2.S </td>
   <td style="text-align:left;"> Novo PNI </td>
  </tr>
  <tr>
   <td style="text-align:left;"> dados/file_1.csv:"a4748591-a3b0-43c2-803d-c64095441c9f-i0b0" </td>
   <td style="text-align:left;"> bd4a0068b5aff0512e50b691e2784c46bb665ff8c697fc7a9acf1fcc4a46deee </td>
   <td style="text-align:right;"> 29 </td>
   <td style="text-align:left;"> 1992-05-13 </td>
   <td style="text-align:left;"> F </td>
   <td style="text-align:left;"> 04 </td>
   <td style="text-align:left;"> AMARELA </td>
   <td style="text-align:right;"> 120040 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> RIO BRANCO </td>
   <td style="text-align:left;"> BRASIL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 69914 </td>
   <td style="text-align:left;"> B </td>
   <td style="text-align:left;"> 6917291 </td>
   <td style="text-align:left;"> PREFEITURA MUNICIPAL DE RIO BRANCO </td>
   <td style="text-align:left;"> DEPARTAMENTO DE VIGILANCIA EPIDEMIOLOGICA E AMBIENTAL </td>
   <td style="text-align:right;"> 120040 </td>
   <td style="text-align:left;"> RIO BRANCO </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 000201 </td>
   <td style="text-align:left;"> Pessoas de 18 a 64 anos </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Faixa Etária </td>
   <td style="text-align:left;"> 1855836 </td>
   <td style="text-align:left;"> JANSSEN </td>
   <td style="text-align:left;"> Organization/30587 </td>
   <td style="text-align:left;"> 2022-01-25 </td>
   <td style="text-align:left;"> Reforço </td>
   <td style="text-align:right;"> 88 </td>
   <td style="text-align:left;"> COVID-19 JANSSEN - Ad26.COV2.S </td>
   <td style="text-align:left;"> Novo PNI </td>
  </tr>
  <tr>
   <td style="text-align:left;"> dados/file_1.csv:"e324584a-0c53-4888-977d-78671bf39041-i0b0" </td>
   <td style="text-align:left;"> f2ab8bafa327d4242c75d21dfb45c5864d6b4b350290f17ccdf5b08439099bed </td>
   <td style="text-align:right;"> 46 </td>
   <td style="text-align:left;"> 1976-03-20 </td>
   <td style="text-align:left;"> M </td>
   <td style="text-align:left;"> 03 </td>
   <td style="text-align:left;"> PARDA </td>
   <td style="text-align:right;"> 120035 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> MARECHAL THAUMATURGO </td>
   <td style="text-align:left;"> BRASIL </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 69983 </td>
   <td style="text-align:left;"> B </td>
   <td style="text-align:left;"> 2002132 </td>
   <td style="text-align:left;"> PREFEITURA MUN DE MAL THAUMATURGO </td>
   <td style="text-align:left;"> ESF RIBEIRINHA DR NALDIR MARIANO </td>
   <td style="text-align:right;"> 120035 </td>
   <td style="text-align:left;"> MARECHAL THAUMATURGO </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 000602 </td>
   <td style="text-align:left;"> Ribeirinha </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> Povos e Comunidades Tradicionais </td>
   <td style="text-align:left;"> 205F21A </td>
   <td style="text-align:left;"> JANSSEN </td>
   <td style="text-align:left;"> Organization/30587 </td>
   <td style="text-align:left;"> 2022-05-09 </td>
   <td style="text-align:left;"> Reforço </td>
   <td style="text-align:right;"> 88 </td>
   <td style="text-align:left;"> COVID-19 JANSSEN - Ad26.COV2.S </td>
   <td style="text-align:left;"> Novo PNI </td>
  </tr>
</tbody>
</table>

## Questão 2: manipulação de dados {.tabset .tabset-fade .tabset-pills}

### Resolução 2.a)

```r
# instalação dos pacotes casso necessário via pacman e carregamentos destes
pacman::p_load(data.table, geobr)

# Carregando todos os arquivos de uma única vez (data.table)
# usando invisible() para não gerar echo
l = invisible(lapply(files, fread, 
           select = c('estabelecimento_uf', 'vacina_descricao_dose', 'estabelecimento_municipio_codigo'),
           encoding = 'UTF-8',
           sep = ';'))
data_1_dt = invisible(rbindlist(l))

# arquivo contendo a relação entre município e região de saúde (tableExport.csv)
# baixado de https://sage.saude.gov.br/paineis/regiaoSaude/lista.php?output=html&
# merge intermediário
data_1_dt = merge(data_1_dt,
                  fread('tableExport.csv',
                    select = 4:5,
                    encoding = 'UTF-8',
                    col.names = c('ibge', 'saude')),
                  by.x = 'estabelecimento_municipio_codigo',
                  by.y = 'ibge')
data_1_dt = data_1_dt[, saude := as.character(saude)]
# merge final
data_1_dt = merge(data_1_dt,
                  geobr::read_health_region(year = 2013, simplified = FALSE),
                  by.x = 'saude',
                  by.y = 'code_health_region') %>%
            select(c(1:8))
```

```
## 
Downloading: 780 B     
Downloading: 780 B     
Downloading: 1.2 kB     
Downloading: 1.2 kB     
Downloading: 1.8 kB     
Downloading: 1.8 kB     
Downloading: 1.8 kB     
Downloading: 1.8 kB     
Downloading: 1.8 kB     
Downloading: 1.8 kB     
Downloading: 1.9 kB     
Downloading: 1.9 kB     
Downloading: 2 kB     
Downloading: 2 kB     
Downloading: 2 kB     
Downloading: 2 kB     
Downloading: 2 kB     
Downloading: 2 kB     
Downloading: 2.1 kB     
Downloading: 2.1 kB     
Downloading: 2.1 kB     
Downloading: 2.1 kB     
Downloading: 2.1 kB     
Downloading: 2.1 kB     
Downloading: 2.2 kB     
Downloading: 2.2 kB     
Downloading: 3.5 kB     
Downloading: 3.5 kB     
Downloading: 4 kB     
Downloading: 4 kB     
Downloading: 5.7 kB     
Downloading: 5.7 kB     
Downloading: 5.7 kB     
Downloading: 5.7 kB     
Downloading: 5.7 kB     
Downloading: 5.7 kB     
Downloading: 12 kB     
Downloading: 12 kB     
Downloading: 12 kB     
Downloading: 12 kB     
Downloading: 12 kB     
Downloading: 12 kB     
Downloading: 19 kB     
Downloading: 19 kB     
Downloading: 19 kB     
Downloading: 19 kB     
Downloading: 19 kB     
Downloading: 19 kB     
Downloading: 27 kB     
Downloading: 27 kB     
Downloading: 35 kB     
Downloading: 35 kB     
Downloading: 43 kB     
Downloading: 43 kB     
Downloading: 51 kB     
Downloading: 51 kB     
Downloading: 59 kB     
Downloading: 59 kB     
Downloading: 66 kB     
Downloading: 66 kB     
Downloading: 66 kB     
Downloading: 66 kB     
Downloading: 66 kB     
Downloading: 66 kB     
Downloading: 74 kB     
Downloading: 74 kB     
Downloading: 83 kB     
Downloading: 83 kB     
Downloading: 91 kB     
Downloading: 91 kB     
Downloading: 96 kB     
Downloading: 96 kB     
Downloading: 96 kB     
Downloading: 96 kB     
Downloading: 96 kB     
Downloading: 96 kB     
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
Downloading: 190 kB     
Downloading: 190 kB     
Downloading: 190 kB     
Downloading: 190 kB     
Downloading: 190 kB     
Downloading: 190 kB     
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
Downloading: 230 kB     
Downloading: 230 kB     
Downloading: 230 kB     
Downloading: 230 kB     
Downloading: 230 kB     
Downloading: 230 kB     
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
Downloading: 360 kB     
Downloading: 360 kB     
Downloading: 360 kB     
Downloading: 360 kB     
Downloading: 360 kB     
Downloading: 360 kB     
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
Downloading: 400 kB     
Downloading: 400 kB     
Downloading: 400 kB     
Downloading: 400 kB     
Downloading: 400 kB     
Downloading: 400 kB     
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
Downloading: 530 kB     
Downloading: 530 kB     
Downloading: 530 kB     
Downloading: 530 kB     
Downloading: 530 kB     
Downloading: 530 kB     
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
Downloading: 570 kB     
Downloading: 570 kB     
Downloading: 570 kB     
Downloading: 570 kB     
Downloading: 570 kB     
Downloading: 570 kB     
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
Downloading: 700 kB     
Downloading: 700 kB     
Downloading: 700 kB     
Downloading: 700 kB     
Downloading: 700 kB     
Downloading: 700 kB     
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
Downloading: 740 kB     
Downloading: 740 kB     
Downloading: 740 kB     
Downloading: 740 kB     
Downloading: 740 kB     
Downloading: 740 kB     
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
Downloading: 870 kB     
Downloading: 870 kB     
Downloading: 870 kB     
Downloading: 870 kB     
Downloading: 870 kB     
Downloading: 870 kB     
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
Downloading: 910 kB     
Downloading: 910 kB     
Downloading: 910 kB     
Downloading: 910 kB     
Downloading: 910 kB     
Downloading: 910 kB     
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
# head do df
knitr::kable(head(data_1_dt)) %>%
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
   <th style="text-align:left;"> saude </th>
   <th style="text-align:right;"> estabelecimento_municipio_codigo </th>
   <th style="text-align:left;"> estabelecimento_uf </th>
   <th style="text-align:left;"> vacina_descricao_dose </th>
   <th style="text-align:left;"> name_health_region </th>
   <th style="text-align:right;"> code_state </th>
   <th style="text-align:left;"> abbrev_state </th>
   <th style="text-align:left;"> name_state </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 12001 </td>
   <td style="text-align:right;"> 120005 </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 1ª Dose </td>
   <td style="text-align:left;"> Alto Acre </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> Acre </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 12001 </td>
   <td style="text-align:right;"> 120005 </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 2ª Dose </td>
   <td style="text-align:left;"> Alto Acre </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> Acre </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 12001 </td>
   <td style="text-align:right;"> 120005 </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 1ª Dose </td>
   <td style="text-align:left;"> Alto Acre </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> Acre </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 12001 </td>
   <td style="text-align:right;"> 120005 </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 2ª Dose </td>
   <td style="text-align:left;"> Alto Acre </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> Acre </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 12001 </td>
   <td style="text-align:right;"> 120005 </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 1ª Dose </td>
   <td style="text-align:left;"> Alto Acre </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> Acre </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 12001 </td>
   <td style="text-align:right;"> 120005 </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> 1ª Dose </td>
   <td style="text-align:left;"> Alto Acre </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> AC </td>
   <td style="text-align:left;"> Acre </td>
  </tr>
</tbody>
</table>

### Resolução 2.b)

```r
# Quantidade de vacinados por região de saúde, segunda dose
# Condicionalmente, a faixa de vacinação por região de saúde (alta ou baixa, em relação à mediana da distribuição de vacinações)
data_1_dt_cut = data_1_dt[grepl('2', vacina_descricao_dose), .N , by = .(name_health_region)][N>=median(N), faixa := 'alta'][N<=median(N), faixa := 'baixa']

knitr::kable(data_1_dt_cut[order(N), .SD[1:5], by = faixa]) %>%
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
   <th style="text-align:left;"> faixa </th>
   <th style="text-align:left;"> name_health_region </th>
   <th style="text-align:right;"> N </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> baixa </td>
   <td style="text-align:left;"> Área Norte </td>
   <td style="text-align:right;"> 37194 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> baixa </td>
   <td style="text-align:left;"> Alto Acre </td>
   <td style="text-align:right;"> 44032 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> baixa </td>
   <td style="text-align:left;"> Regional Purus </td>
   <td style="text-align:right;"> 63155 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> baixa </td>
   <td style="text-align:left;"> Regional Juruá </td>
   <td style="text-align:right;"> 71604 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> baixa </td>
   <td style="text-align:left;"> Triângulo </td>
   <td style="text-align:right;"> 90975 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> alta </td>
   <td style="text-align:left;"> 3ª Região de Saúde </td>
   <td style="text-align:right;"> 133762 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> alta </td>
   <td style="text-align:left;"> Juruá e Tarauacá/Envira </td>
   <td style="text-align:right;"> 148229 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> alta </td>
   <td style="text-align:left;"> 5ª Região de Saúde </td>
   <td style="text-align:right;"> 148814 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> alta </td>
   <td style="text-align:left;"> 6ª Região de Saúde </td>
   <td style="text-align:right;"> 150511 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> alta </td>
   <td style="text-align:left;"> Rio Negro e Solimões </td>
   <td style="text-align:right;"> 157187 </td>
  </tr>
</tbody>
</table>

### Resolução 2.c)


### Resolução 2.d)




