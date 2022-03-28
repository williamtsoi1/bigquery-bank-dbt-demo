SELECT
    card_type,
    revenue_date,
    revenue as monthly_revenue,
    revenue - LAG(revenue) OVER (ORDER BY card_type, revenue_date ASC) as monthly_revenue_change
FROM {{ ref('dim_revenue_by_cardtype_month') }}
ORDER BY card_type, revenue_date ASC