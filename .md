# MODELAGEM DA CONCENTRAÇÃO DE CLOROFILA-A
## Barragem Castanhão - A Maior Barragem da América Latina

[![Status](https://img.shields.io/badge/Status-Em%20Andamento-yellow.svg)](https://github.com/carloszarzar/Castanhao_R)
[![R](https://img.shields.io/badge/R-276DC3?style=flat&logo=r&logoColor=white)](https://www.r-project.org/)
[![Data Science](https://img.shields.io/badge/Data%20Science-Analytics-blue.svg)](https://carloszarzar.github.io/Castanhao_R/)

## 📋 Sobre o Projeto

Este projeto desenvolve modelos estatísticos e de machine learning para **monitoramento e análise preditiva** da concentração de clorofila-a na Barragem Castanhão, localizada no estado do Ceará. O estudo tem como objetivo criar ferramentas de **análise preditiva** para avaliação dos impactos ambientais na região da barragem, utilizando técnicas avançadas de ciência de dados.

**🔗 Acesse o relatório completo:** [https://carloszarzar.github.io/Castanhao_R/](https://carloszarzar.github.io/Castanhao_R/)

---

  ## 🎯 Objetivos

- Desenvolver modelos preditivos para concentração de clorofila-a
- Analisar correlações entre variáveis ambientais e qualidade da água
- Implementar pipeline de processamento de dados para monitoramento contínuo
- Fornecer insights para gestão sustentável de recursos hídricos

## 📊 Dataset

O projeto utiliza dados coletados entre **2013-2025**, totalizando **590 observações** com as seguintes variáveis:

  | Variável | Descrição | Cobertura |
  |----------|-----------|-----------|
  | **Clorofila-a** | Concentração (mg/L) | 100% |
  | **Nitrogênio Total** | Concentração (mg/L) | ~87% |
  | **Fósforo Total** | Concentração (mg/L) | ~87% |
  | **Turbidez** | Medida em NTU | ~13% |
  | **Precipitação** | Dados mensais (mm) | 100% |

  ## 🔧 Metodologias e Técnicas

  ### **Data Engineering & ETL**
  - **Data Wrangling** com `dplyr` e `readxl`
- **Data Cleaning**: Tratamento de valores ausentes e duplicatas
- **Feature Engineering**: Criação de variáveis temporais (mês/ano)
- **Data Integration**: Merge de múltiplas fontes de dados

### **Análise Exploratória**
- **Análise de Consistência**: Verificação de correspondência entre datasets
- **Detecção de Outliers**: Identificação de padrões anômalos
- **Análise Temporal**: Investigação de sazonalidade nos dados
- **Correlation Analysis**: Matriz de correlações entre variáveis ambientais

### **Modelagem Estatística**
- **Regression Analysis**: Modelos lineares e não-lineares
- **Time Series Analysis**: Análise de tendências temporais
- **Missing Data Handling**: Técnicas de imputação e interpolação
- **Cross Validation**: Validação robusta dos modelos

### **Visualização de Dados**
- **Scatter Plots**: Análise de relacionamentos bivariados
- **Time Series Plots**: Visualização de tendências temporais
- **Heatmaps**: Matriz de correlações
- **Box Plots**: Análise de distribuições e outliers

## 📈 Principais Resultados Até o Momento

### **Data Processing Pipeline**
✅ **Consolidação de Dados**: Successfully merged 4 diferentes planilhas Excel
✅ **Data Quality**: Identificação e tratamento de 78 chaves duplicadas
✅ **Data Integration**: Integração bem-sucedida com dados de precipitação
✅ **Feature Selection**: Seleção de 13 variáveis relevantes para modelagem

### **Exploratory Data Analysis**
- **Dataset Final**: 590 observações processadas e validadas
- **Missing Data Analysis**: Identificação de limitações nos dados de turbidez (87% missing)
- **Temporal Coverage**: Análise abrangente de 12 anos de dados (2013-2025)
- **Correlation Insights**: Relações preliminares entre clorofila-a e variáveis ambientais

### **Key Statistics**
```
Clorofila-a (mg/L):
  ├── Média: 21.06 mg/L
├── Mediana: 15.93 mg/L
└── Range: 1.00 - 143.47 mg/L

Precipitação (mm/mês):
  ├── Média: 31.57 mm
├── Mediana: 10.20 mm
└── Range: 0.00 - 227.00 mm
```

## ⚠️ Limitações Identificadas

- **Dados de Turbidez**: Apenas 13.2% dos registros possuem medições de turbidez
- **Inconsistências Temporais**: Horários de coleta necessitam padronização
- **Missing Data**: 147 observações sem dados de precipitação

## 🚧 Próximos Passos

- [ ] **Modelo de Regressão**: Desenvolvimento de modelos preditivos para turbidez
- [ ] **Machine Learning**: Implementação de algoritmos de ML (Random Forest, XGBoost)
- [ ] **Time Series Forecasting**: Modelos ARIMA/SARIMA para previsão temporal
- [ ] **Interactive Dashboard**: Desenvolvimento de dashboard em Shiny para visualização
- [ ] **API Development**: Criação de API REST para predições em tempo real

## 🛠️ Tecnologias Utilizadas

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![RStudio](https://img.shields.io/badge/RStudio-75AADB?style=for-the-badge&logo=RStudio&logoColor=white)

**Principais Pacotes R:**
  - `dplyr` - Data manipulation e transformação
- `readxl` - Importação de arquivos Excel
- `lubridate` - Manipulação de datas e tempo
- `ggplot2` - Visualização avançada de dados

## 👨‍💼 Autor

**Carlos Antônio Zarzar**
  *Data Scientist & Environmental Analyst*

  ---

  ## 📄 Status do Projeto

  🟡 **Em Andamento** - Fase de modelagem estatística e desenvolvimento de algoritmos preditivos

*Última atualização: 10/08/2025*
