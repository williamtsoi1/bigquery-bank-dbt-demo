
with source as (

    select * from {{ source('raw', 'ext_order') }}

),

renamed as (

    select
        order_id,
        account_id,
        bank_to,
        account_to,
        category,
        amount

    from source

)

select * from renamed
