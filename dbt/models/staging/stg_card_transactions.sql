{{ config(
    partition_by={
      "field": "trans_date",
      "data_type": "date",
      "granularity": "day"
    }
)}}

with source as (

    select * from {{ source('raw', 'ext_card_transactions') }}

),

renamed as (

    select
        cc_number,
        trans_id,
        trans_time,
        epoch_time,
        category,
        merchant,
        merchant_lat,
        merchant_lon,
        amount,
        is_fraud,
        trans_date

    from source

)

select * from renamed

