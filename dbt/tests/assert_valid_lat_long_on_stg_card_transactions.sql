select trans_id, merchant_lat, merchant_lon
FROM {{ ref('stg_card_transactions') }}
WHERE (merchant_lat > 90) or (merchant_lat < -90) or (merchant_lon < -180) or (merchant_lon > 180)