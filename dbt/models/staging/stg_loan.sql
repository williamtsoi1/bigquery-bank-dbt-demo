
with source as (

    select * from {{ source('raw', 'ext_loan') }}

),

renamed as (

    select
        loan_id,
        account_id,
        duration,
        payments,
        status,
        amount,
        date

    from source

)

select * from renamed
