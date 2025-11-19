{{ config(materialized='view') }}

with raw_data as (
    select
        id,
        policy_code,
        name as policy_name,
        description,
        category,
        base_premium,
        currency,
        effective_from,
        effective_to,
        created_at,
        updated_at
    from {{ source('raw_insurance', 'policy') }}
),

cleaned as (
    select
        id,
        nullif(trim(policy_code),'') as policy_code,
        nullif(trim(policy_name),'') as policy_name,
        trim(description) as description,
        lower(trim(category)) as category,
        case
            when try_cast(base_premium as decimal(5,2)) is not null then try_cast(base_premium as numeric)
            else null
        end as base_premium,
        upper(trim(currency)) as currency,

        case
            when try_cast(effective_from as date) is not null then try_cast(effective_from as date)
            else null
        end as effective_from,

        case
            when try_cast(effective_to as date) is not null then try_cast(effective_to as date)
            else null
        end as effective_to,

        case
            when try_cast(created_at as timestamp) is not null then try_cast(created_at as timestamp)
            else null
        end as created_at,

        case
            when try_cast(updated_at as timestamp) is not null then try_cast(updated_at as timestamp)
            else null
        end as updated_at
    from raw_data
)

select * from cleaned
