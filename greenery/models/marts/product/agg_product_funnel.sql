with sessions as (
  select * from {{ ref('int_sessions_agg') }}
),

temp as (
 select
    session_start::date as session_date,
    count(session_id) as total_sessions,
    count(case when add_to_cart > 0 then session_id else null end) as cart_sessions,
    count(case when checkout > 0 then session_id else null end) as checkout_sessions,
    count(case when add_to_cart > 0 then session_id else null end)::float/count(session_id) as add_to_cart_rate,
    count(case when checkout > 0 then session_id else null end)::float/count(session_id) as conversion_rate,
    sum(count(session_id)) over (order by session_start::date asc rows between unbounded preceding and current row) as cumulative_sessions,
    sum(count(case when add_to_cart > 0 then session_id else null end)) over (order by session_start::date asc rows between unbounded preceding and current row) as cumulative_cart_sessions,
    sum(count(case when checkout > 0 then session_id else null end)) over (order by session_start::date asc rows between unbounded preceding and current row) as cumulative_checkout_sessions
from
  sessions
{{ dbt_utils.group_by(1)}}
order by 1
)

select
    session_date,
    total_sessions,
    cart_sessions,
    checkout_sessions,
    add_to_cart_rate,
    conversion_rate,
    cumulative_sessions,
    cumulative_cart_sessions,
    cumulative_checkout_sessions,
    cumulative_cart_sessions::float/cumulative_sessions::float as total_cart_rate,
    cumulative_checkout_sessions::float/cumulative_sessions::float as total_conversion_rate
from temp