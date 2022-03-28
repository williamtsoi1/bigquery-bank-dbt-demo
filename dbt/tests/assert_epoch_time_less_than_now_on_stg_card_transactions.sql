select trans_id, TIMESTAMP_SECONDS(epoch_time), CURRENT_TIMESTAMP()
from {{ ref('stg_card_transactions') }}
WHERE TIMESTAMP_SECONDS(epoch_time) > CURRENT_TIMESTAMP()