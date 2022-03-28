
with source as (

    select * from {{ source('raw', 'ext_district') }}

),

renamed as (

    select
        district_id,
        pop,
        nmu500,
        nmu2k,
        nmu10k,
        nmuinf,
        ncit,
        rurba,
        avgsal,
        urat95,
        urat96,
        ent_ppt,
        ncri95,
        ncri96,
        city,
        state,
        zipcode

    from source

)

select * from renamed
