
{%
  set event_types = dbt_utils.get_query_results_as_dict(
    "select distinct quote_literal(event_type) as event_type, event_type as column_name from"
    ~ ref('stg_events')
  )
%}

with product_events as (
  select * from {{ ref('stg_events') }} where product_id is not null
),

products as (
    select * from {{ ref('stg_products') }}
)

select
    product_events.session_id,
    products.product_id,
    products.product_name
    {%- for event_type in event_types['event_type'] -%},
    sum(case when event_type = {{event_type}} then 1 else 0 end) as {{ event_types['column_name'][loop.index0] }}
    {%- endfor %}
from product_events
left join products
    on product_events.product_id = products.product_id
{{ dbt_utils.group_by(3)}}