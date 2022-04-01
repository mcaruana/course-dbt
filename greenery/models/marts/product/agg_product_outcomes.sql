with product_interaction_agg as (
  select 
    product_id,
    count(case when page_view > 0 then session_id else null end) as product_sessions,
    count(case when add_to_cart > 0 then session_id else null end) as product_adds
  from {{ ref('int_product_session') }}
  {{ dbt_utils.group_by(1)}}
),

product_order_agg as (
  select 
    product_id,
    count(order_id) as product_orders,
    sum(num_items) as product_count
    from {{ ref('int_order_session') }}
  {{ dbt_utils.group_by(1)}}
),

product as (
select * from {{ ref('stg_products')}}
)

select
  product.product_id,
  product.product_name,
  coalesce(product_interaction_agg.product_sessions,0) as product_sessions,
  coalesce(product_interaction_agg.product_adds,0) as product_adds,
  coalesce(product_order_agg.product_orders,0) as product_orders,
  coalesce(product_order_agg.product_count,0) as product_count
from product
left join product_interaction_agg
  on product.product_id = product_interaction_agg.product_id
left join product_order_agg
  on product.product_id = product_order_agg.product_id
  