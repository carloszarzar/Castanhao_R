# Carregando bibliotecas necessárias
library(gamlss)
library(gamlss.add)
library(gamlss.dist)
library(dplyr)

# Verificando e preparando os dados
# Assumindo que df_junto é o seu dataset (ajuste se necessário)
df_junto <- df_castahao[,c(-9)]  # removendo turb
df_junto <- df_junto[!is.na(df_junto$Precipitação),] # removendo NA da precipitação
str(df_junto)
any(df_junto)
is.na(df_junto$Precipitação)
# Visualizando a estrutura dos dados
str(df_junto)
summary(df_junto)

# Preparação dos dados
# Removendo NAs e verificando a distribuição da variável resposta
df_clean <- df_junto %>%
  filter(!is.na(chl), chl > 0) %>%  # Gamma requer valores positivos
  filter(!is.na(nt), !is.na(pt)) %>%
  mutate(
    mes = as.factor(mes),
    ano = as.factor(ano),
    CAMPANHA = as.factor(CAMPANHA),
    PONTO = as.factor(PONTO),
    # Criando variável de interação temporal se necessário
    periodo = paste(ano, mes, sep = "_")
  )

# Explorando a distribuição da clorofila
hist(df_clean$chl, breaks = 30, main = "Distribuição da Clorofila",
     xlab = "Clorofila (µg/L)")

# Boxplot por mês
boxplot(chl ~ mes, data = df_clean,
        main = "Clorofila por Mês",
        xlab = "Mês", ylab = "Clorofila (µg/L)")

# Verificando correlações
cor_matrix <- cor(df_clean[c("chl", "nt", "pt", "Precipitação", "PROF")],
                  use = "complete.obs")
print(cor_matrix)

# Modelo GAMLSS com distribuição Gamma
# Modelo 1: Básico - apenas efeitos lineares
modelo1 <- gamlss(chl ~ nt + pt + Precipitação + PROF + mes + ano,
                  sigma.formula = ~ nt + pt + mes,  # Modelo para escala (sigma)
                  family = GA(),  # Distribuição Gamma
                  data = df_clean,
                  control = gamlss.control(n.cyc = 200))

# Modelo 2: Com efeitos suavizados (mais flexível)
modelo2 <- gamlss(chl ~ pb(nt) + pb(pt) + pb(Precipitação) + mes + ano,
                  sigma.formula = ~ pb(nt) + ano,  # Escala com suavização
                  family = GA(),
                  data = df_clean,
                  control = gamlss.control(n.cyc = 200))

# Modelo 3: Incluindo efeitos aleatórios para PONTO
modelo3 <- gamlss(chl ~ pb(nt) + pb(pt) + pb(Precipitação) +
                    pb(PROF) + mes + ano + random(PONTO),
                  sigma.formula = ~ pt + mes,
                  family = GA(),
                  data = df_clean,
                  control = gamlss.control(n.cyc = 200))


# Resumo dos modelos
print("=== MODELO 1 (Linear) ===")
summary(modelo1)

print("=== MODELO 2 (Suavizado) ===")
summary(modelo2)

print("=== MODELO 3 (Com efeitos aleatórios) ===")
summary(modelo3)

# Comparação de modelos usando AIC
AIC(modelo1, modelo2, modelo3)

# Diagnósticos do melhor modelo (assumindo modelo2)
melhor_modelo <- modelo3

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
modelo_alt <- gamlss(chl ~ pb(nt) + pb(pt) + pb(Precipitação) +
                       pb(PROF) + mes + ano,
                     sigma.formula = ~  pb(pt) + mes,
                     family = IG(),  # Gamma Inversa
                     data = df_clean,
                     control = gamlss.control(n.cyc = 200))

# Comparando Gamma vs Gamma Inversa
print("Comparação AIC - Gamma vs Gamma Inversa:")
print(paste("Gamma:", AIC(modelo3)))
print(paste("Gamma Inversa:", AIC(modelo_alt)))

# Salvando resultados
save(modelo1, modelo2, modelo3, melhor_modelo,
     file = "modelos_gamlss_clorofila.RData")

# Criando tabela de resultados
resultado_tabela <- data.frame(
  Variavel = names(coef_mu),
  Coeficiente_Media = coef_mu,
  row.names = NULL
)

print("Tabela de Coeficientes:")
print(resultado_tabela)
