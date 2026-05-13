-- ============================================================
--  B2B SALES PERFORMANCE ANALYSIS — QUERY SCRIPTS
--  Project: Sales & Performance Analysis
--  Author : Mohammad Danish
--  Tools  : SQL, Power BI
-- ============================================================


-- --------------------------------------------------------
-- QUERY 1: Total Revenue, Cost & Profit by Month
-- KPI: Monthly revenue trend + profit margin
-- --------------------------------------------------------
SELECT
    strftime('%Y-%m', o.order_date)                          AS month,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) AS total_revenue,
    SUM(oi.quantity * p.cost_price)                          AS total_cost,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100))
        - SUM(oi.quantity * p.cost_price)                    AS gross_profit,
    ROUND(
        (SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100))
         - SUM(oi.quantity * p.cost_price))
        / SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) * 100, 2
    )                                                        AS profit_margin_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
WHERE o.status = 'Delivered'
GROUP BY month
ORDER BY month;


-- --------------------------------------------------------
-- QUERY 2: Revenue by Region
-- KPI: Regional performance comparison
-- --------------------------------------------------------
SELECT
    r.region_name,
    COUNT(DISTINCT o.order_id)                                AS total_orders,
    COUNT(DISTINCT o.customer_id)                             AS unique_customers,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) AS total_revenue,
    ROUND(AVG(oi.quantity * oi.unit_price * (1 - oi.discount/100)), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id  = oi.order_id
JOIN customers  c  ON o.customer_id = c.customer_id
JOIN regions    r  ON c.region_id   = r.region_id
WHERE o.status = 'Delivered'
GROUP BY r.region_name
ORDER BY total_revenue DESC;


-- --------------------------------------------------------
-- QUERY 3: Top Products by Revenue & Profit
-- KPI: Best-performing products
-- --------------------------------------------------------
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity)                                          AS units_sold,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) AS revenue,
    SUM(oi.quantity * p.cost_price)                          AS cost,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100))
        - SUM(oi.quantity * p.cost_price)                    AS profit,
    ROUND(
        (SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100))
         - SUM(oi.quantity * p.cost_price))
        / SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) * 100, 2
    )                                                        AS margin_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders   o ON oi.order_id   = o.order_id
WHERE o.status = 'Delivered'
GROUP BY p.product_name, p.category
ORDER BY revenue DESC;


-- --------------------------------------------------------
-- QUERY 4: Sales Rep Performance
-- KPI: Revenue & deals per rep, win rate
-- --------------------------------------------------------
SELECT
    sr.rep_name,
    sr.team,
    r.region_name,
    COUNT(DISTINCT o.order_id)                                AS total_deals,
    SUM(CASE WHEN o.status = 'Delivered' THEN 1 ELSE 0 END)  AS won_deals,
    ROUND(
        SUM(CASE WHEN o.status = 'Delivered' THEN 1.0 ELSE 0 END)
        / COUNT(DISTINCT o.order_id) * 100, 1
    )                                                        AS win_rate_pct,
    SUM(
        CASE WHEN o.status = 'Delivered'
        THEN oi.quantity * oi.unit_price * (1 - oi.discount/100) ELSE 0 END
    )                                                        AS total_revenue
FROM sales_reps sr
JOIN orders     o  ON sr.rep_id     = o.rep_id
JOIN order_items oi ON o.order_id  = oi.order_id
JOIN regions    r  ON sr.region_id  = r.region_id
GROUP BY sr.rep_name, sr.team, r.region_name
ORDER BY total_revenue DESC;


-- --------------------------------------------------------
-- QUERY 5: Customer Revenue & Account Tier Analysis
-- KPI: Revenue concentration by account tier (Gold/Silver/Bronze)
-- --------------------------------------------------------
SELECT
    c.account_tier,
    c.company_name,
    c.industry,
    COUNT(DISTINCT o.order_id)                                AS orders_placed,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) AS lifetime_revenue,
    ROUND(AVG(oi.quantity * oi.unit_price * (1 - oi.discount/100)), 2) AS avg_order_value
FROM customers  c
JOIN orders     o  ON c.customer_id  = o.customer_id
JOIN order_items oi ON o.order_id   = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.account_tier, c.company_name, c.industry
ORDER BY c.account_tier, lifetime_revenue DESC;


-- --------------------------------------------------------
-- QUERY 6: Quarter-over-Quarter Revenue Growth
-- KPI: QoQ growth trend
-- --------------------------------------------------------
WITH quarterly AS (
    SELECT
        strftime('%Y', o.order_date)   AS yr,
        CASE
            WHEN strftime('%m', o.order_date) BETWEEN '01' AND '03' THEN 'Q1'
            WHEN strftime('%m', o.order_date) BETWEEN '04' AND '06' THEN 'Q2'
            WHEN strftime('%m', o.order_date) BETWEEN '07' AND '09' THEN 'Q3'
            ELSE 'Q4'
        END                            AS quarter,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Delivered'
    GROUP BY yr, quarter
)
SELECT
    yr,
    quarter,
    revenue,
    LAG(revenue) OVER (ORDER BY yr, quarter) AS prev_quarter_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY  yr, quarter))
        / LAG(revenue) OVER (ORDER BY yr, quarter) * 100, 2
    )                                         AS qoq_growth_pct
FROM quarterly
ORDER BY yr, quarter;


-- --------------------------------------------------------
-- QUERY 7: Product Category Revenue Share
-- KPI: Category contribution to total revenue
-- --------------------------------------------------------
WITH category_rev AS (
    SELECT
        p.category,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) AS category_revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN orders   o ON oi.order_id   = o.order_id
    WHERE o.status = 'Delivered'
    GROUP BY p.category
),
total AS (
    SELECT SUM(category_revenue) AS grand_total FROM category_rev
)
SELECT
    cr.category,
    cr.category_revenue,
    ROUND(cr.category_revenue / t.grand_total * 100, 2) AS revenue_share_pct
FROM category_rev cr, total t
ORDER BY cr.category_revenue DESC;


-- --------------------------------------------------------
-- QUERY 8: Order Fulfilment & Cancellation Rate
-- KPI: Operational efficiency
-- --------------------------------------------------------
SELECT
    o.status,
    COUNT(*)                                 AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_of_total,
    SUM(oi.quantity * oi.unit_price)         AS gross_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.status
ORDER BY order_count DESC;


-- --------------------------------------------------------
-- QUERY 9: Average Deal Size by Industry
-- KPI: Which industries bring the biggest deals
-- --------------------------------------------------------
SELECT
    c.industry,
    COUNT(DISTINCT o.order_id)                                AS total_orders,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) AS total_revenue,
    ROUND(
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100))
        / COUNT(DISTINCT o.order_id), 2
    )                                                        AS avg_deal_size
FROM customers  c
JOIN orders     o  ON c.customer_id  = o.customer_id
JOIN order_items oi ON o.order_id   = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY c.industry
ORDER BY avg_deal_size DESC;


-- --------------------------------------------------------
-- QUERY 10: Discount Impact on Profit Margin
-- KPI: Do discounts hurt profitability?
-- --------------------------------------------------------
SELECT
    CASE
        WHEN oi.discount = 0          THEN '0% (No Discount)'
        WHEN oi.discount BETWEEN 1 AND 5  THEN '1-5%'
        WHEN oi.discount BETWEEN 6 AND 10 THEN '6-10%'
        ELSE '10%+'
    END                                                      AS discount_band,
    COUNT(*)                                                 AS line_items,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) AS net_revenue,
    SUM(oi.quantity * p.cost_price)                          AS total_cost,
    ROUND(
        (SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100))
         - SUM(oi.quantity * p.cost_price))
        / SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) * 100, 2
    )                                                        AS margin_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders   o ON oi.order_id   = o.order_id
WHERE o.status = 'Delivered'
GROUP BY discount_band
ORDER BY margin_pct DESC;
