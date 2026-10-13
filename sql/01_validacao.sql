-- =====================================================
-- 01_validacao.sql
-- Validação da qualidade dos dados da Olist antes das análises.
-- Cada bloco traz o objetivo, a consulta, o resultado e a decisão de tratamento.
-- =====================================================

-- 1. TIPOS DE COLUNAS
describe orders;
-- Colunas de data de orders estão como datetime (importação correta)

-- 2. VERIFICAÇÃO DE STATUS
select 
	order_status,
    count(*) as qtd_ordens,
    round(count(*) * 100 / sum(count(*)) over(), 2) as pct
from orders
group by order_status
order by qtd_ordens desc;
-- Resultado: 8 status: 97% dos pedidos estão como delivered (entregues)

-- 3. PEDIDOS SEM DATA DE ENTREGA
select 
    order_status as status_entrega,
    sum(order_delivered_customer_date is null) as sem_data_entrega,
    count(*) as total_pedidos
from orders
group by status_entrega
order by sem_data_entrega desc;
-- Datas de entrega vazias ocorrem nos pedidos não entregues (esperado).
-- Inconsistência: 8 pedidos 'delivered' sem data de entrega (0,008%).
-- Serão excluídos da análise de atraso

-- 4. PEDIDOS 'DELIVERED' SEM DATA DE ENTREGA
select 
	*
from orders
where order_status = 'delivered' and order_delivered_customer_date is null;
-- Inconsistência: 8 pedidos 'delivered' sem data de entrega ao cliente.
-- 7 têm as demais datas preenchidas (provável falha de registro);
-- 1 também não tem data de envio à transportadora.
-- Decisão: excluídos da análise de atraso (sem data real não há cálculo), mantidos na análise de receita.

-- 5. AVALIAÇÕES DUPLICADAS
select 
	order_id,
    count(*) as total_avaliacao
from order_reviews
group by order_id
having count(*) > 1
order by count(*) desc;
-- 547 pedidos têm mais de uma avaliação.
-- Decisão: manter apenas a mais recente por pedido, para que cada pedido conte uma vez na nota média.

-- 6. PEDIDOS ENTREGUES SEM AVALIAÇÃO
select 
	count(*) as pedido_sem_avaliacao
from orders
left join order_reviews as avaliacoes
	on orders.order_id = avaliacoes.order_id
where orders.order_status = 'delivered' and avaliacoes.review_score is null;
-- 646 pedidos 'delivered' sem nenhuma avaliação (0,67% dos entregues).
-- Decisão: ficam fora da análise de atraso x nota (sem nota não há o que comparar),
-- mas permanecem na análise de receita.

-- 7. PRODUTOS SEM CATEGORIA OU SEM TRADUÇÃO
select 
	count(*) as total_produtos,
    sum(p.product_category_name is null) as sem_categoria,
    sum(p.product_category_name is not null 
    and t.product_category_name is null) as sem_traducao
from products as p
left join product_category_name_translation as t
	on p.product_category_name = t.product_category_name;
-- 610 produtos sem categoria (1,85% do catálogo): ficam como 'sem categoria'.
-- 13 produtos com categoria sem tradução (0,04%): mantido o nome original em português.

-- =====================================================
-- RESUMO DOS ACHADOS
-- 1. 96.478 de 99.441 pedidos (97%) estão como 'delivered' e entram nas análises.
-- 2. 8 pedidos 'delivered' sem data de entrega (0,008%): fora da análise de atraso.
-- 3. 547 pedidos com mais de uma avaliação: mantida a mais recente por pedido.
-- 4. 646 pedidos entregues sem avaliação (0,67%): fora da análise de nota.
-- 5. 610 produtos sem categoria (1,85%) e 13 sem tradução (0,04%).
-- =====================================================