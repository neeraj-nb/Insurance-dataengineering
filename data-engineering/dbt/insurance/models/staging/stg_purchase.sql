{{ config(materialized='view') }}

with raw_data as (
    select
       id,
       purchase_number,
       purchase_date,
       "customer.id" as customer_id,
       "customer.customer_number" as customer_number,
       "policy.id" as policy_id,
       "policy.policy_code" as policy_code,
       amount,
       currency,
       payment_reference,
       status,
       invoice_number,
       created_at,
       updated_at
    from {{ source('raw_insurance', 'purchase') }}
),

cleaned as (
    select
        id,
        upper(trim(purchase_number)) as purchase_number,
        
        case
            when try_cast(purchase_date as timestamp) is not null then try_cast(purchase_date as timestamp)
            else null
        end as purchase_date,

        customer_id,
        upper(trim(customer_number)) as customer_number,
        policy_id,
        upper(trim(policy_code)) as policy_code,

        case
            when try_cast(amount as decimal(5,2)) is not null then try_cast(amount as numeric)
            else null
        end as amount,

        upper(trim(currency)) as currency,
        trim(payment_reference) as payment_reference,
        lower(trim(status)) as status,
        upper(trim(invoice_number)) as invoice_number,


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