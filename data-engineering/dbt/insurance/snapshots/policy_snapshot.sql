{% snapshot policy_snapshot %}
{{
  config(
    target_schema='snapshots', 
    unique_key='policy_code',
    strategy='timestamp',
    updated_at='updated_at'
  )
}}

select *
from {{ ref('stg_policy') }}

{% endsnapshot %}
