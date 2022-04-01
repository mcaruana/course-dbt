with order_events as (
    select
        session_id,
        order_id,
        count(case when event_type = 'checkout' then order_id else null end) as order_placed,
        count(case when event_type = 'package_shipped' then order_id else null end) as order_shipped
    from {{ ref('stg_events') }} 
    where order_id is not null
    {{ dbt_utils.group_by(2)}}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
)

select
    order_events.session_id,
    order_events.order_id,
    case when order_events.order_placed = 1 then true else false end as order_placed,
    case when order_events.order_shipped = 1 then true else false end as order_shipped,
    order_items.product_id,
    sum(order_items.num_items) as num_items --in case an item was rung up as qty 1 twice
from order_events
inner join order_items
on order_events.order_id = order_items.order_id
{{ dbt_utils.group_by(5)}}