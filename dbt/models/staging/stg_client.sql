
with source as (

    select * from {{ source('raw', 'ext_client') }}

),

renamed as (

    select
        ssn,
        first_name,
        last_name,
        gender,
        street,
        address,
        job,
        profile,
        client_id,
        district_id,
        disp_id,
        traffice_source,
        dob,
        age

    from source

)

select * from renamed
