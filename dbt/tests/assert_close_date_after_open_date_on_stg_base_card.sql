select card_id, date, end_date
from {{ ref('stg_base_card') }}
where end_date IS NOT NULL AND end_date < date