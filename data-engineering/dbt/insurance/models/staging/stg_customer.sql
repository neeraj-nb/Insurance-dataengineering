{{ config(materialized='view') }}

with raw_data as (
    select
        id,
        customer_number,
        first_name,
        last_name,
        date_of_birth,
        gender,
        email,
        phone,
        address_line1,
        address_line2,
        city,
        state,
        postal_code,
        country,
        created_at,
        updated_at
    from {{ source('raw_insurance', 'customer') }}
),

cleaned as (
    select
        id,
        nullif(trim(customer_number),'') as customer_number,
        trim(first_name) as first_name,
        trim(last_name) as last_name,

        case
            when try_cast(date_of_birth as date) is not null then try_cast(date_of_birth as date)
            else null
        end as date_of_birth,

        lower(trim(gender)) as gender,
        lower(trim(email)) as email,
        cast(trim(phone) as varchar(32)) as phone,
        trim(address_line1) as address_line1,
        trim(address_line2) as address_line2,
        trim(city) as city,
        trim(state) as state,

        case
            when try_cast(postal_code as numeric) is not null then try_cast(postal_code as numeric)
            else null
        end as postal_code,

        trim(country) as country,

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