SELECT
    c.type AS card_type,
    FORMAT_DATE('%Y-%m', trans_date) as revenue_date,
    SUM(amount) as revenue
FROM 
    {{ref('stg_card_transactions')}} ct
    JOIN {{ref('stg_card')}} c ON ct.cc_number = c.card_number
WHERE 
    trans_date > DATE_ADD(CURRENT_DATE, INTERVAL -1 YEAR)
GROUP BY 
    card_type, revenue_date