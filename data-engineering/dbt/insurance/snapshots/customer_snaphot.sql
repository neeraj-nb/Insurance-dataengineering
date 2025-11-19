{% snapshot customer_snapshot %}
{{
  config(
    target_schema='snapshots', 
    unique_key='customer_number',
    strategy='timestamp',
    updated_at='updated_at'
  )
}}

select *
from {{ ref('stg_customer') }}

{% endsnapshot %}
