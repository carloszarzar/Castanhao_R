#### Projeto Castanhão - Paulo - Modelo Clorofila
# Data: 10/08/2025
# Autor: Carlos Antônio Zarzar
#-------------------------------------------------------------------------------
# Objetivo:
# Juntar os dados de clorofila, Nitrogênio total, Posforo total, Turbidez, profundidade, Precipitação

#-------------------------------------------------------------------------------
# Pacotes
library(readxl)


# Limpando áre ade trabalho
rm(list = ls())
# Para favilitar importação dos dados
# Renomea o banco de dados Dados Modelo Castanhão.xlsx por Dados Castanhão.xlsx para facilitar importação no R.
# E renomeie "Precipitação Castanhão teste.xlsx" para Precipitação.xlsx

# Importando dados
df_chl <- read_xlsx("Dados Castanhão.xlsx", sheet = "Clorofila a ")
df_nt <- read_xlsx("Dados Castanhão.xlsx", sheet = "Nitrogênio Total")
df_pt <- read_xlsx("Dados Castanhão.xlsx", sheet = "Fósforo Total")
df_turb <- read_xlsx("Dados Castanhão.xlsx", sheet = "Turbidez")
df_precip <- read_xlsx("Precipitação.xlsx", sheet = "Precipitação")
df_precip$Precipitação <- as.numeric(df_precip$Precipitação)
#---------------------#---------------------#---------------------#-------------

#------ Limpando as colunas -------#
# Colunas desejadas
colunas_desejadas <- c("CAMPANHA","PONTO","PROF","DATA_COLETA","HORARIO","RESULTADO","DESCR_PONTO")

# Lista com os data frames originais
lista_df <- list(
  df_chl = df_chl,
  df_nt = df_nt,
  df_pt = df_pt,
  df_turb = df_turb
)

# Função para selecionar as colunas (mantém só as que existem no DF)
selecionar_colunas <- function(df) {
  df[, intersect(colunas_desejadas, colnames(df)), drop = FALSE]
}

# Aplica a função a todos os data frames
lista_df <- lapply(lista_df, selecionar_colunas)

# Reatribui os data frames às variáveis originais
df_chl    <- lista_df$df_chl
df_nt     <- lista_df$df_nt
df_pt     <- lista_df$df_pt
df_turb   <- lista_df$df_turb

#-------------------------------------------------------------------------------
#------ Renomeando as Colunas RESULTADO para cada Data Frame -------#
# Lista original com os data frames e seus nomes (apelidos)
lista_df <- list(
  chl  = df_chl,
  nt   = df_nt,
  pt   = df_pt,
  turb = df_turb
)

# Criar uma lista vazia para armazenar os data frames processados
lista_df_processada <- list()

# Loop sobre cada data frame da lista original
for (nome_df in names(lista_df)) {

  # Extrai o data frame atual da lista
  df_atual <- lista_df[[nome_df]]

  # Seleciona somente as colunas que existem tanto na lista desejada quanto no data frame atual
  colunas_presentes <- intersect(colunas_desejadas, names(df_atual))
  df_selecionado <- df_atual[, colunas_presentes, drop = FALSE]

  # Verifica se a coluna "RESULTADO" está presente para renomeá-la
  if ("RESULTADO" %in% names(df_selecionado)) {
    # Renomeia "RESULTADO" para o nome do data frame atual (ex: "chl", "nt", "pt", "turb")
    names(df_selecionado)[names(df_selecionado) == "RESULTADO"] <- nome_df
  }

  # Salva o data frame processado na lista nova
  lista_df_processada[[nome_df]] <- df_selecionado
}

# Reatribui os data frames processados para as variáveis originais
df_chl  <- lista_df_processada$chl
df_nt   <- lista_df_processada$nt
df_pt   <- lista_df_processada$pt
df_turb <- lista_df_processada$turb

names(df_chl)
names(df_nt)
names(df_pt)
names(df_turb)

# OBS: há alguns horários que está como 0:00:00 em todos os data frames
# Isso leva dúvidas no horário que foi coletado as observações

#===============================================================================

# Análise comparação (match)
# Dados correspondente
dados_match <- merge(
  df_chl,
  df_nt,
  by = c("CAMPANHA", "PONTO", "PROF", "DATA_COLETA")
)

# Visualizando o resultado
print(dados_match)
dim(dados_match)

# Conferindo se nas linhas que deu match a profundidades são iguais
setequal(dados_match$PROF, dados_match$PROF) # Sim, são iguais.

#---------------------#---------------------#---------------------#-------------
# Reunindo todos os datas frames em um único df com join_full
library(dplyr)

# Lista com todos os data frames
lista_df <- list(df_chl, df_nt, df_pt, df_turb)

# Faz o full join de todos de uma vez
dados_full <- Reduce(function(x, y) {
  full_join(x, y, by = c("CAMPANHA", "PONTO", "PROF", "DATA_COLETA"))
}, lista_df)

print(dados_full)
dim(dados_full)

#---------------------
# Listando os dados duplicado pelas colunas chaves para estudo e compreensão
library(dplyr)

# Lista com os data frames e seus nomes
lista_df <- list(
  df_chl = df_chl,
  df_nt = df_nt,
  df_pt = df_pt,
  df_turb = df_turb
)

# Função para detectar duplicatas
checar_duplicatas <- function(df, nome_df) {
  df %>%
    count(CAMPANHA, PONTO, PROF, DATA_COLETA) %>%
    filter(n > 1) %>%
    arrange(desc(n)) %>%
    mutate(dataframe = nome_df)
}

# Aplicar a função a todos os data frames
duplicatas <- bind_rows(
  lapply(names(lista_df), function(nome) {
    checar_duplicatas(lista_df[[nome]], nome)
  })
)

# Mostrar resultado
if (nrow(duplicatas) == 0) {
  message("✅ Nenhuma chave duplicada encontrada.")
} else {
  print(duplicatas)
}

# View(duplicatas)
#=================================================================
#### Excluindo algumas linhas que não têm informações ####
dados_full
# View(dados_full)

# Excluindo linhas que não têm dados de clorofila
is.na(dados_full$chl)
# TREU - número de linhas de clorofila com NA
num_NA <- table(is.na(dados_full$chl))
cat("Número de linhas excluídas:",num_NA["TRUE"])
df <- dados_full[!is.na(dados_full$chl), ]
dim(df)

# Excluindo linhas que não têm dados de nitrogênio total, f´sforo total e trubidez
# Remove linhas onde nt, pt e turb são todos NA ao mesmo tempo
df_limpo <- df[!(is.na(df$nt) & is.na(df$pt) & is.na(df$turb)), ]
num_NA <- table((is.na(df$nt) & is.na(df$pt) & is.na(df$turb)))
cat("Número de linhas excluídas:",num_NA["TRUE"])
dim(df_limpo)

# View(df_limpo)

#===============================================================================
#### Temos um problema paar ser definido
# Temos poucas informações de turbidez
tam_linhas <- dim(df_limpo)[1]
nao_tem_turb <- table((is.na(df_limpo$turb)))

cat("Tamanho do conjunto de dados após processamento (df_limpo):",tam_linhas)
cat("Excluindo linhas que não tem informação da Turbidez:",nao_tem_turb["TRUE"])
cat("Dimensão dos dados se excluir NA da Turbidez:",tam_linhas-nao_tem_turb["TRUE"]) # Tamanho dos dados que o paulo mostrou

#### A proposta aqui é tentar criar uma interpolação com os dados de Turbidez para inserir no data frame
# Ainda não sei como fazer isso mas vou refletir.
# Talvez seja possível estimar a turbidez com a precipitação (estudar isso)
#------------------------------------
# Relação da Turbidez com outras variáveis
plot(df_limpo$turb,df_limpo$chl)
plot(df_limpo$turb,df_limpo$nt)
plot(df_limpo$turb,df_limpo$pt)


#======================== Rascunho =================================
# Conferindo o data frame
df_limpo
# View(df_limpo)

all.equal(df_limpo$HORARIO.x,df_limpo$HORARIO.y)
all.equal(df_limpo$HORARIO.x,df_limpo$HORARIO.x.x)
all.equal(df_limpo$HORARIO.x,df_limpo$HORARIO.y.y)

all.equal(df_limpo$HORARIO.y,df_limpo$HORARIO.x.x)
all.equal(df_limpo$HORARIO.y,df_limpo$HORARIO.y.y)

teste <- df_limpo[,c("HORARIO.x","HORARIO.y","HORARIO.x.x","HORARIO.y.y","DATA_COLETA","chl","nt","pt","turb")]
# View(teste)
#===============================================================================
# Juntando o data frame df_limpo com a df_precip
df_precip
names(df_precip)
str(df_precip)
str(df_limpo)
df_precip <- df_precip[,c(1,4)]
# Juntando os data frames (join) apenas pelo mês e ano correspondente (ignorando o dia)
## precisamos criar colunas auxiliares com mês e ano em ambos os data frames e depois fazer o join
library(dplyr)
library(lubridate) # facilita extrair mês e ano

# Garantir que ambas são Date
df_limpo$DATA_COLETA <- as.Date(df_limpo$DATA_COLETA)
df_precip$Data <- as.Date(df_precip$Data)

# Criar colunas auxiliares de ano e mês
df_limpo <- df_limpo %>%
  mutate(ano = year(DATA_COLETA),
         mes = month(DATA_COLETA))

df_precip <- df_precip %>%
  mutate(ano = year(Data),
         mes = month(Data))

# Fazer o join pelo ano e mês
df_junto <- df_limpo %>%
  left_join(df_precip, by = c("ano", "mes"))


# View(df_junto)
str(df_junto)

### Dados oficial para fazer a modelagem : df_junto
names(df_junto)
df_castahao <- df_junto[,c("CAMPANHA","PONTO","PROF",
                           "DATA_COLETA","HORARIO.x","chl",
                           "nt", "pt", "turb", "Precipitação",
                           "DESCR_PONTO.x","mes","ano")]
# View(df_castahao)
#===============================================================================

# Relação Turbidez e Precipitação
plot(df_castahao$turb,df_castahao$Precipitação)

head(as.data.frame(df_castahao))

# Dados após processamento principal
df_castahao
