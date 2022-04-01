with events as (
  select * from {{ ref('stg_events') }}
),

session_metrics as (
  {{ agg_session_events()}}
),

session_duration_details as (
  select
      session_id,
      user_id,
      min(created_at) as session_start,
      max(created_at) as session_end,
      age(max(created_at),min(created_at)) as session_length
  from events
  group by 1,2
)

select
  session_metrics.*,
  session_duration_details.user_id,
  session_duration_details.session_start,
  session_duration_details.session_end,
  session_duration_details.session_length
from session_duration_details
left join session_metrics
on session_duration_details.session_id = session_metrics.session_id