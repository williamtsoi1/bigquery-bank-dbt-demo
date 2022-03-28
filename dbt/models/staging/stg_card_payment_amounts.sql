
with source as (

    select * from {{ source('raw', 'ext_card_payment_amounts') }}

),

renamed as (

    select
        index,
        period_transactions_total,
        card_number,
        is_full_payer,
        payment_type,
        balance_percent,
        card_id,
        remaining_balance_last_period,
        total_amount_owed,
        total_amount_paid,
        total_interest_applied,
        remaining_balance_this_period,
        period_start,
        period_end,
        payment_completed_date,
        payment_due_date

    from source

)

select * from renamed
