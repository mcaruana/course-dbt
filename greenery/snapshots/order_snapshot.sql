{% snapshot order_snapshot %}
    {{
        config(
            unique_key='order_id',
            strategy='check',
            check_cols=['status']
        )  
    }}
select * from {{ source('postgres', 'orders') }}
{% endsnapshot %}