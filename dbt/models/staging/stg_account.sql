
with source as (

    select * from {{ source('raw', 'ext_account') }}

),

renamed as (

    select
        account_id,
        district_id,
        stmt_frq,
        date

    from source

)

select * from renamed
