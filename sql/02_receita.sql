-- =====================================================
-- 02_receita.sql
-- Receita dos pedidos 'delivered' por categoria e por estado.
-- Receita considera apenas o valor dos produtos (price), sem frete.
-- =====================================================

-- 1. Receita por categoria (apenas pedidos 'delivered')
select 
    round(sum(oi.price), 2) as faturamento,
    count(distinct o.order_id) as total_pedidos,
    coalesce(p.product_category_name, 'sem_categoria') as categoria_pt,
    coalesce(pt.product_category_name_english, p.product_category_name, 'sem_categoria') as categoria_en
from orders as o
inner join order_items as oi
	on o.order_id = oi.order_id
inner join products p 
	on oi.product_id = p.product_id
left join product_category_name_translation pt
	on p.product_category_name = pt.product_category_name
where o.order_status = 'delivered'
group by categoria_pt, categoria_en
order by faturamento desc;
-- 1.392 pedidos contêm produtos sem categoria (agrupados como 'sem_categoria').
-- 13 produtos sem tradução, concentrados em 2 categorias ausentes da tabela de tradução:
-- 'portateis_cozinha_e_preparadores_de_alimentos' (10) e 'pc_gamer' (3).
-- Decisão: mantido o nome original em português em categoria_en.
-- Atenção: total_pedidos conta pedidos por categoria; não somar a coluna (um pedido pode ter várias categorias)

-- 2. Conferência do faturamento total
select
    round(sum(oi.price), 2) as faturamento_total
from orders o
inner join order_items oi
    on o.order_id = oi.order_id
where o.order_status = 'delivered';

select
    round(sum(faturamento), 2) as faturamento_categorias
from (
    select
        round(sum(oi.price), 2) as faturamento,
        count(distinct o.order_id) as total_pedidos,
        coalesce(p.product_category_name, 'sem_categoria') as categoria_pt,
        coalesce(pt.product_category_name_english, p.product_category_name, 'sem_categoria') as categoria_en
    from orders as o
    inner join order_items as oi
        on o.order_id = oi.order_id
    inner join products p
        on oi.product_id = p.product_id
    left join product_category_name_translation pt
        on p.product_category_name = pt.product_category_name
    where o.order_status = 'delivered'
    group by categoria_pt, categoria_en
) as receita_categoria;
-- Resultado: os dois totais deram R$ 13.221.498,11. JOINs validados:
-- nenhuma linha perdida ou duplicada.

-- 3. Receita por estado (apenas pedidos 'delivered')
-- Conferência: soma do faturamento = R$ 13.221.498,11 e soma de pedidos = 96.478,
select 
	c.customer_state,
	round(sum(oi.price), 2) as faturamento,
    count(distinct o.order_id) as total_pedidos,
    round(sum(oi.price) / count(distinct o.order_id), 2) as ticket_medio
from orders o 
inner join order_items oi
	on o.order_id = oi.order_id
inner join customers c
	on o.customer_id = c.customer_id
where o.order_status = 'delivered'
group by c.customer_state
order by faturamento desc;

select 
	round(sum(oi.price), 2) as faturamento,
    count(distinct o.order_id) as total_pedidos
from order_items oi 
inner join orders o 
	on oi.order_id = o.order_id
where o.order_status = 'delivered';
-- iguais aos totais da categoria e da validação.
-- Estado líder: SP, com R$ 5.067.633,16 e ticket médio de R$ 125,12.
-- Maior ticket médio: PB (R$ 217,77, em 517 pedidos, ~0,5% do total); menor: SP (R$ 125,12).
-- SP concentra ~38% da receita pelo volume de pedidos, não pelo valor por pedido.
-- Atenção: PB tem baixo volume, então o ticket médio é mais sensível a poucas compras caras.