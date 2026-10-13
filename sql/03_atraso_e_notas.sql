-- 3. Faixas de atraso na entrega (pedidos 'delivered' com data de entrega: 96.470)
with atrasos as (
	select 
		order_id,
		datediff(order_delivered_customer_date, order_estimated_delivery_date) as dias_atraso
    from orders
    where order_status = 'delivered' and order_delivered_customer_date is not null
),
avaliacoes as (
	select 
		order_id,
        review_score,
        row_number() over (
			partition by order_id
            order by review_answer_timestamp desc, review_creation_date desc
            ) as ordem
    from order_reviews
),
avaliacao_final as (
	select 
		order_id,
        review_score
    from avaliacoes
    where ordem = 1
)
select 
	count(*) as total_pedidos,
    round(count(*) * 100 / sum(count(*)) over(), 2) as pct,
    round(avg(f.review_score), 2) as nota_media,
    case 
		when a.dias_atraso <= 0 then '1. No Prazo'
        when a.dias_atraso <= 3 then '2. 1 a 3 dias de atraso'
        when a.dias_atraso <= 7 then '3. 4 a 7 dias de atraso'
        else '4. mais de 7 dias de atraso'
    end as classificacao_atrasos
from atrasos a
inner join avaliacao_final f
	on a.order_id = f.order_id
group by classificacao_atrasos
order by classificacao_atrasos;
-- Amostra: 95.824 pedidos (96.470 entregues com data - 646 sem avaliação).
-- Uma avaliação por pedido (a mais recente, via ROW_NUMBER).
-- 93,34% chegaram no prazo ou antes (inclui entregas adiantadas); 6,66% atrasaram:
-- 1 a 3 dias (1,93%), 4 a 7 dias (1,82%) e mais de 7 dias (2,90%).
-- Nota média: no prazo 4,29 | 1 a 3 dias 3,29 | 4 a 7 dias 2,10 | mais de 7 dias 1,70.
-- Atraso e nota andam juntos: um atraso de 1 a 3 dias já reduz a nota em 1 ponto.

-- 4. Atraso por estado (pedidos 'delivered' com data de entrega: 96.470)
with atrasos as (
	select 
		c.customer_state as estados,
		datediff(order_delivered_customer_date, order_estimated_delivery_date) as dias_atraso
	from orders o
	inner join customers c 
		on o.customer_id = c.customer_id
	where o.order_status = 'delivered' and order_delivered_customer_date is not null
)
select
	estados,
    sum(dias_atraso > 0) as pedidos_atrasados,
    count(*) as total_pedidos,
    round(sum(dias_atraso > 0) * 100 / count(*), 2) as pct_atrasos
from atrasos
group by estados
order by pct_atrasos desc;
-- Conferência: soma dos pedidos = 96.470 e soma dos atrasados = 6.534 (6,77% no Brasil).
-- Os estados que mais vendem não são os que mais atrasam: SP (4,49%), MG (4,57%) e PR (4,04%)
-- ficam abaixo da média nacional; RJ (12,11%) é a exceção entre os grandes.
-- O atraso se concentra no Nordeste: os 9 estados da região estão acima da média,
-- com AL (21,41%), MA (17,43%) e SE (15,22%) no topo.
-- Os 5 maiores estados em receita (SP, RJ, MG, RS, PR; ~74% do total) têm taxas de atraso
-- de 4,49%, 12,11%, 4,57%, 6,08% e 4,04%: só o RJ está bem acima da média nacional (6,77%).
-- Atenção: estados de baixo volume (RR, AP, AC, AM) têm percentual instável.