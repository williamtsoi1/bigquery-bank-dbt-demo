
with source as (

    select * from {{ source('raw', 'ext_disp') }}

),

renamed as (

    select
        disp_id,
        client_id,
        account_id,
        type

    from source

)

select * from renamed
