##### Rascunho o oficial é o 2_Script e não 2_Script_II

# Carregando bibliotecas necessárias
library(gamlss)
library(gamlss.add)
library(gamlss.dist)
library(dplyr)

# Verificando e preparando os dados
# Assumindo que df_junto é o seu dataset (ajuste se necessário)
df_junto <- df_castahao  # ou use seu dataset real

# Visualizando a estrutura dos dados
str(df_junto)
summary(df_junto)

# Preparação dos dados - TRATAMENTO DE NAs
# Primeiro, vamos verificar o padrão de NAs
print("=== ANÁLISE DE DADOS FALTANTES ===")
print("Contagem de NAs por variável:")
sapply(df_junto, function(x) sum(is.na(x)))

print("Proporção de NAs por variável:")
sapply(df_junto, function(x) round(mean(is.na(x)), 3))

# Estratégia 1: Dataset completo (remove todos os NAs)
df_completo <- df_junto %>%
  filter(!is.na(chl), chl > 0) %>%  # Gamma requer valores positivos
  filter(!is.na(nt), !is.na(pt), !is.na(turb), !is.na(Precipitação)) %>%
  mutate(
    mes = as.factor(mes),
    ano = as.factor(ano),
    CAMPANHA = as.factor(CAMPANHA),
    PONTO = as.factor(PONTO),
    periodo = paste(ano, mes, sep = "_")
  )

# Estratégia 2: Imputação simples para turbidez
df_imputado <- df_junto %>%
  filter(!is.na(chl), chl > 0) %>%
  filter(!is.na(nt), !is.na(pt)) %>%
  mutate(
    # Imputação por mediana, agrupada por mês/ano se possível
    turb_imp = ifelse(is.na(turb),
                      ave(turb, mes, ano, FUN = function(x) median(x, na.rm = TRUE)),
                      turb),
    # Se ainda há NA, usar mediana geral
    turb_imp = ifelse(is.na(turb_imp), median(turb, na.rm = TRUE), turb_imp),
    mes = as.factor(mes),
    ano = as.factor(ano),
    CAMPANHA = as.factor(CAMPANHA),
    PONTO = as.factor(PONTO),
    periodo = paste(ano, mes, sep = "_")
  )

# Estratégia 3: Modelo sem turbidez
df_sem_turb <- df_junto %>%
  filter(!is.na(chl), chl > 0) %>%
  filter(!is.na(nt), !is.na(pt)) %>%
  mutate(
    mes = as.factor(mes),
    ano = as.factor(ano),
    CAMPANHA = as.factor(CAMPANHA),
    PONTO = as.factor(PONTO),
    periodo = paste(ano, mes, sep = "_")
  )

print(paste("Observações no dataset completo:", nrow(df_completo)))
print(paste("Observações no dataset imputado:", nrow(df_imputado)))
print(paste("Observações no dataset sem turbidez:", nrow(df_sem_turb)))

# Vamos usar o dataset imputado como principal
df_clean <- df_imputado

# Explorando a distribuição da clorofila
hist(df_clean$chl, breaks = 30, main = "Distribuição da Clorofila",
     xlab = "Clorofila (µg/L)")

# Boxplot por mês
boxplot(chl ~ mes, data = df_clean,
        main = "Clorofila por Mês",
        xlab = "Mês", ylab = "Clorofila (µg/L)")

# Verificando correlações (usando variável imputada)
cor_matrix <- cor(df_clean[c("chl", "nt", "pt", "turb_imp", "Precipitação", "PROF")],
                  use = "complete.obs")
print("Matriz de correlações:")
print(round(cor_matrix, 3))

# MODELOS COM DIFERENTES ESTRATÉGIAS PARA TRATAR NAs

# Modelo A: Dataset completo (sem NAs)
if(nrow(df_completo) > 20) {  # Só ajusta se tiver dados suficientes
  modelo_completo <- gamlss(chl ~ pb(nt) + pb(pt) + pb(turb) + pb(Precipitação) +
                              pb(PROF) + mes + ano,
                            sigma.formula = ~ pb(nt) + pb(pt) + mes,
                            family = GA(),
                            data = df_completo,
                            control = gamlss.control(n.cyc = 200))
  print(paste("Modelo completo ajustado com", nrow(df_completo), "observações"))
}

# Modelo B: Com imputação
modelo_imputado <- gamlss(chl ~ pb(nt) + pb(pt) + pb(turb_imp) + pb(Precipitação) +
                            pb(PROF) + mes + ano,
                          sigma.formula = ~ pb(nt) + pb(pt) + mes,
                          family = GA(),
                          data = df_imputado,
                          control = gamlss.control(n.cyc = 200))

# Modelo C: Sem turbidez
modelo_sem_turb <- gamlss(chl ~ pb(nt) + pb(pt) + pb(Precipitação) +
                            pb(PROF) + mes + ano,
                          sigma.formula = ~ pb(nt) + pb(pt) + mes,
                          family = GA(),
                          data = df_sem_turb,
                          control = gamlss.control(n.cyc = 200))

# Modelo D: Usando turbidez como categórica (alta/média/baixa/NA)
df_turb_cat <- df_sem_turb %>%
  mutate(
    turb_cat = case_when(
      is.na(df_junto$turb[match(rownames(.), rownames(df_junto))]) ~ "NA",
      df_junto$turb[match(rownames(.), rownames(df_junto))] <= quantile(df_junto$turb, 0.33, na.rm = TRUE) ~ "Baixa",
      df_junto$turb[match(rownames(.), rownames(df_junto))] <= quantile(df_junto$turb, 0.67, na.rm = TRUE) ~ "Media",
      TRUE ~ "Alta"
    ),
    turb_cat = as.factor(turb_cat)
  )

modelo_turb_cat <- gamlss(chl ~ pb(nt) + pb(pt) + turb_cat + pb(Precipitação) +
                            pb(PROF) + mes + ano,
                          sigma.formula = ~ pb(nt) + pb(pt) + mes,
                          family = GA(),
                          data = df_turb_cat,
                          control = gamlss.control(n.cyc = 200))

# Resumo dos modelos
print("=== COMPARAÇÃO DOS MODELOS ===")

modelos_list <- list()
aic_values <- c()

if(exists("modelo_completo")) {
  modelos_list[["Completo"]] <- modelo_completo
  aic_values["Completo"] <- AIC(modelo_completo)
  print("=== MODELO COMPLETO (sem NAs) ===")
  summary(modelo_completo)
}

modelos_list[["Imputado"]] <- modelo_imputado
aic_values["Imputado"] <- AIC(modelo_imputado)
print("=== MODELO COM IMPUTAÇÃO ===")
summary(modelo_imputado)

modelos_list[["Sem_Turb"]] <- modelo_sem_turb
aic_values["Sem_Turb"] <- AIC(modelo_sem_turb)
print("=== MODELO SEM TURBIDEZ ===")
summary(modelo_sem_turb)

modelos_list[["Turb_Cat"]] <- modelo_turb_cat
aic_values["Turb_Cat"] <- AIC(modelo_turb_cat)
print("=== MODELO COM TURBIDEZ CATEGÓRICA ===")
summary(modelo_turb_cat)

# Comparação de AICs
print("=== COMPARAÇÃO AIC ===")
print(sort(aic_values))

# Selecionando melhor modelo
melhor_modelo_nome <- names(which.min(aic_values))
melhor_modelo <- modelos_list[[melhor_modelo_nome]]

print(paste("Melhor modelo:", melhor_modelo_nome))

# Gráficos de diagnóstico
par(mfrow = c(2, 2))
plot(melhor_modelo)

# Resíduos quantile normalizados
wp(melhor_modelo, ylim.all = 2)

# Histograma dos resíduos
hist(residuals(melhor_modelo), breaks = 20,
     main = "Histograma dos Resíduos",
     xlab = "Resíduos")

# Q-Q plot dos resíduos
qqnorm(residuals(melhor_modelo))
qqline(residuals(melhor_modelo))

# Gráficos dos efeitos suavizados
term.plot(melhor_modelo, pages = 1, ask = FALSE)

# Predições e intervalos de confiança
predicoes <- predict(melhor_modelo,
                     what = "mu",  # Predição da média
                     type = "response")

# Adicionando predições ao dataset
df_clean$predicoes <- predicoes

# Gráfico de valores observados vs preditos
plot(df_clean$chl, df_clean$predicoes,
     xlab = "Clorofila Observada",
     ylab = "Clorofila Predita",
     main = "Observado vs Predito")
abline(0, 1, col = "red", lty = 2)

# Calculando R² aproximado
cor_obs_pred <- cor(df_clean$chl, df_clean$predicoes)^2
cat("R² aproximado:", round(cor_obs_pred, 3), "\n")

# Extraindo coeficientes importantes
coef_mu <- coef(melhor_modelo, what = "mu")
coef_sigma <- coef(melhor_modelo, what = "sigma")

print("Coeficientes para µ (média):")
print(coef_mu)

print("Coeficientes para σ (escala):")
print(coef_sigma)

# Modelo alternativo com distribuição Gamma inversa (se necessário)
modelo_alt <- gamlss(chl ~ pb(nt) + pb(pt) + pb(turb) + pb(Precipitação) +
                       pb(PROF) + mes + ano,
                     sigma.formula = ~ pb(nt) + pb(pt) + mes,
                     family = IG(),  # Gamma Inversa
                     data = df_clean,
                     control = gamlss.control(n.cyc = 200))

# Comparando Gamma vs Gamma Inversa
print("Comparação AIC - Gamma vs Gamma Inversa:")
print(paste("Gamma:", AIC(modelo2)))
print(paste("Gamma Inversa:", AIC(modelo_alt)))

# Salvando resultados
save(modelo_imputado, modelo_sem_turb, modelo_turb_cat, melhor_modelo,
     file = "modelos_gamlss_clorofila.RData")

# ANÁLISE ESPECÍFICA DOS NAs NA TURBIDEZ
print("=== ANÁLISE DETALHADA DOS NAs ===")

# Verificando padrão temporal dos NAs
na_pattern <- df_junto %>%
  mutate(tem_turb = !is.na(turb)) %>%
  group_by(mes, ano) %>%
  summarise(
    total_obs = n(),
    com_turb = sum(tem_turb),
    prop_com_turb = round(com_turb/total_obs, 2),
    .groups = 'drop'
  )
print(na_pattern)

# Verificando se NAs têm padrão espacial
na_espacial <- df_junto %>%
  mutate(tem_turb = !is.na(turb)) %>%
  group_by(PONTO) %>%
  summarise(
    total_obs = n(),
    com_turb = sum(tem_turb),
    prop_com_turb = round(com_turb/total_obs, 2),
    .groups = 'drop'
  )
print("Padrão espacial dos NAs:")
print(na_espacial)

# Criando tabela de resultados
resultado_tabela <- data.frame(
  Variavel = names(coef_mu),
  Coeficiente_Media = coef_mu,
  row.names = NULL
)

print("Tabela de Coeficientes:")
print(resultado_tabela)
