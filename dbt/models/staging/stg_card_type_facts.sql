
with source as (

    select * from {{ source('raw', 'ext_card_type_facts') }}

),

renamed as (

    select
        type,
        daily_interest_rate,
        annual_fee

    from source

)

select * from renamed
