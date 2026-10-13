# 🛒 Análise de Vendas e Satisfação do Cliente

Projeto de análise de dados do e-commerce brasileiro da **Olist**, usando SQL (MySQL) para validar, cruzar e responder perguntas de negócio sobre vendas e entregas.

> 🚧 **Status:** análise em SQL concluída. Pipeline em Python (Pandas) e dashboard em Power BI em desenvolvimento.

---

## 📌 Visão Geral

O dataset reúne cerca de 100 mil pedidos feitos entre 2016 e 2018 em marketplaces brasileiros, distribuídos em várias tabelas (pedidos, itens, produtos, clientes, avaliações, entre outras). O projeto responde a três perguntas:

1. **Quais categorias e estados geram mais receita?**
2. **O atraso na entrega está associado a notas menores dos clientes?**
3. **Os estados que mais vendem são os que mais atrasam?**

**Fonte dos dados:** [Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/olistbr/brazilian-ecommerce)

---

## 🛠️ Tecnologias

* **SQL (MySQL):** validação da qualidade dos dados, JOINs entre várias tabelas, CTEs, funções de janela (`ROW_NUMBER`, `SUM() OVER`) e agregações.
* **Python / Pandas:** *(em desenvolvimento)* preparação da tabela final para o dashboard.
* **Power BI:** *(em desenvolvimento)* modelo relacional, medidas DAX e dashboard de duas páginas.

---

## 📂 Estrutura do Repositório

```
├── SQL/
│   ├── 01_validacao.sql        # Qualidade dos dados e decisões de tratamento
│   ├── 02_receita.sql          # Receita por categoria e por estado
│   └── 03_atraso_e_notas.sql   # Atraso, nota do cliente e atraso por estado
├── powerbi/                    # Dashboard (em breve)
├── imagens/                    # Prints do dashboard (em breve)
└── README.md
```

---

## 🧹 Tratamento e Validação dos Dados

Antes das análises, cada tabela passou por uma etapa de validação (`01_validacao.sql`). As decisões tomadas:

| Achado | Decisão |
|---|---|
| 96.478 de 99.441 pedidos (97%) estão como `delivered` | Apenas pedidos entregues entram nas análises |
| 8 pedidos `delivered` sem data de entrega ao cliente | Excluídos da análise de atraso; mantidos na de receita |
| 547 pedidos com mais de uma avaliação | Mantida apenas a mais recente por pedido |
| 646 pedidos entregues sem avaliação | Fora da análise de nota; mantidos na de receita |
| 610 produtos sem categoria | Agrupados como `sem_categoria` |
| 13 produtos sem tradução (2 categorias ausentes da tabela de tradução) | Mantido o nome original em português |

A receita considera apenas o valor dos produtos (`price`), **sem frete**.

---

## 📊 Principais Resultados

### 💰 Receita

* A receita total dos pedidos entregues foi de **R$ 13.221.498,11**.
* **São Paulo** lidera com **R$ 5,07 mi (cerca de 38% do total)**, mas tem o **menor ticket médio** entre os estados (R$ 125,12): a receita vem do volume de pedidos, não do valor de cada compra.
* Os cinco maiores estados (SP, RJ, MG, RS e PR) concentram cerca de **74% da receita**.
* O maior ticket médio é o da **Paraíba** (R$ 217,77), mas com apenas 517 pedidos, então a média é mais sensível a poucas compras caras.

### 🚚 Entrega e satisfação

* **93,3% dos pedidos chegam no prazo ou antes**; 6,77% (6.534 de 96.470) chegam atrasados.
* O atraso está fortemente associado a notas menores:

| Faixa de atraso | Nota média |
|---|---|
| No prazo | 4,29 |
| 1 a 3 dias | 3,29 |
| 4 a 7 dias | 2,10 |
| Mais de 7 dias | 1,70 |

* Um atraso de apenas 1 a 3 dias já reduz a nota média em **1 ponto**. (Análise feita sobre 95.824 pedidos entregues com avaliação.)

### 🗺️ Atraso por estado

* **Os estados que mais vendem não são os que mais atrasam.** SP (4,49%), MG (4,57%) e PR (4,04%) ficam abaixo da média nacional. O **Rio de Janeiro** é a exceção entre os grandes, com **12,11%** de pedidos atrasados.
* O atraso se concentra no **Nordeste**: os nove estados da região estão acima da média nacional, com destaque para **Alagoas (21,41%)**, **Maranhão (17,43%)** e **Sergipe (15,22%)**.
* Estados de baixo volume (como RR, AP, AC e AM) têm percentuais instáveis e devem ser interpretados com cautela.

> ⚠️ **Observação:** os resultados mostram que atraso e nota andam juntos, mas não provam que o atraso é a única causa da insatisfação.

---

## 🚀 Como Reproduzir

1. Baixe o dataset no [Kaggle](https://www.kaggle.com/olistbr/brazilian-ecommerce) (os CSVs não estão neste repositório por causa do tamanho).
2. Importe as tabelas para um banco MySQL chamado `olist`, com os nomes: `orders`, `order_items`, `products`, `customers`, `order_reviews` e `product_category_name_translation`.
3. Execute os arquivos da pasta `SQL/` na ordem numérica.

---

## ✉️ Contato

Desenvolvido por Danilo

* **LinkedIn:** [Danilo Guerreiro](https://www.linkedin.com/in/danilo-guerreiro-66a35737a)
* **GitHub:** [Danilo Guerreiro](https://github.com/TreferDG)
