{{ config(materialized='view') }}

with stg_policy_cte as (
    select
        id,
        policy_code,
        name as policy_name,
        description,
        category,
        base_premium,
        currency,
        is_active,
        effective_from,
        effective_to,
        created_at,
        updated_at
    from {{ source('raw_insurance', 'policy') }}
)

select * from stg_policy_cte
