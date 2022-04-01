with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items')}}
),

products as (
    select * from {{ ref('stg_products')}}
)

select
  order_items.order_id,
  orders.created_at,
  order_items.product_id,
  products.product_name,
  sum(order_items.num_items) as num_items
from {{ ref('stg_orders') }} orders
left join {{ ref('stg_order_items') }} order_items
  on orders.order_id = order_items.order_id
left join {{ ref('stg_products') }} products
  on order_items.product_id = products.product_id
group by 1,2,3,4