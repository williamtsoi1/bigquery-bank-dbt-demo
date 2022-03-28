
with source as (

    select * from {{ source('raw', 'ext_base_card') }}

),

renamed as (

    select
        card_id,
        disp_id,
        type,
        date,
        end_date,
        card_number

    from source

)

select * from renamed
