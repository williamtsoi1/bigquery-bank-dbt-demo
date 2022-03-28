
with source as (

    select * from {{ source('raw', 'ext_card') }}

),

renamed as (

    select
        index,
        card_id,
        disp_id,
        type,
        card_number,
        date,
        end_date

    from source

)

select * from renamed
