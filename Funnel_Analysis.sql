-- Step 1: Check available event types in the dataset

SELECT DISTINCT event_type
FROM `bigquery-public-data.thelook_ecommerce.events`
ORDER BY event_type;

-- Step 2: Count number of users at each funnel stage
SELECT
  event_type,
  COUNT(DISTINCT user_id) AS users
FROM `bigquery-public-data.thelook_ecommerce.events`
WHERE event_type IN ('home', 'product', 'cart', 'purchase')
GROUP BY event_type
ORDER BY users DESC;

-- Step 3: Pivot funnel stages into columns
SELECT
  COUNT(DISTINCT CASE WHEN event_type = 'home' THEN user_id END) AS home_users,
  COUNT(DISTINCT CASE WHEN event_type = 'product' THEN user_id END) AS product_users,
  COUNT(DISTINCT CASE WHEN event_type = 'cart' THEN user_id END) AS cart_users,
  COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchase_users
FROM `bigquery-public-data.thelook_ecommerce.events`;

-- Step 4: Create user-level funnel flags
SELECT
  user_id,
  MAX(CASE WHEN event_type = 'home' THEN 1 ELSE 0 END) AS visited_home,
  MAX(CASE WHEN event_type = 'product' THEN 1 ELSE 0 END) AS viewed_product,
  MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS added_to_cart,
  MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
FROM `bigquery-public-data.thelook_ecommerce.events`
GROUP BY user_id;

-- Step 5: Aggregate funnel counts from user-level data
WITH user_funnel AS (
  SELECT
    user_id,
    MAX(CASE WHEN event_type = 'home' THEN 1 ELSE 0 END) AS visited_home,
    MAX(CASE WHEN event_type = 'product' THEN 1 ELSE 0 END) AS viewed_product,
    MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS added_to_cart,
    MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
  FROM `bigquery-public-data.thelook_ecommerce.events`
  GROUP BY user_id
)

SELECT
  COUNTIF(visited_home = 1) AS home_users,
  COUNTIF(viewed_product = 1) AS product_users,
  COUNTIF(added_to_cart = 1) AS cart_users,
  COUNTIF(purchased = 1) AS purchase_users
FROM user_funnel;

-- Step 6: Calculate funnel conversion rates
WITH user_funnel AS (
  SELECT
    user_id,
    MAX(CASE WHEN event_type = 'home' THEN 1 ELSE 0 END) AS visited_home,
    MAX(CASE WHEN event_type = 'product' THEN 1 ELSE 0 END) AS viewed_product,
    MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS added_to_cart,
    MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
  FROM `bigquery-public-data.thelook_ecommerce.events`
  GROUP BY user_id
)

SELECT
  COUNTIF(visited_home = 1) AS home_users,
  COUNTIF(viewed_product = 1) AS product_users,
  COUNTIF(added_to_cart = 1) AS cart_users,
  COUNTIF(purchased = 1) AS purchase_users,

  -- Conversion rates
  SAFE_DIVIDE(COUNTIF(viewed_product = 1), COUNTIF(visited_home = 1)) * 100 AS home_to_product_pct,
  SAFE_DIVIDE(COUNTIF(added_to_cart = 1), COUNTIF(viewed_product = 1)) * 100 AS product_to_cart_pct,
  SAFE_DIVIDE(COUNTIF(purchased = 1), COUNTIF(added_to_cart = 1)) * 100 AS cart_to_purchase_pct

FROM user_funnel;

-- Step 7: Conversion by traffic source
WITH user_funnel AS (
  SELECT
    user_id,
    traffic_source,
    MAX(CASE WHEN event_type = 'home' THEN 1 ELSE 0 END) AS visited_home,
    MAX(CASE WHEN event_type = 'product' THEN 1 ELSE 0 END) AS viewed_product,
    MAX(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) AS added_to_cart,
    MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
  FROM `bigquery-public-data.thelook_ecommerce.events`
  GROUP BY user_id, traffic_source
)

SELECT
  traffic_source,
  COUNTIF(purchased = 1) AS purchasers,
  COUNTIF(viewed_product = 1) AS product_viewers,
  SAFE_DIVIDE(COUNTIF(purchased = 1), COUNTIF(viewed_product = 1)) * 100 AS conversion_pct
FROM user_funnel
GROUP BY traffic_source
ORDER BY conversion_pct DESC;

-- Step 8: Revenue by traffic source using readable aliases
SELECT
  events.traffic_source,
  COUNT(DISTINCT order_items.order_id) AS total_orders,
  SUM(order_items.sale_price) AS total_revenue,
  AVG(order_items.sale_price) AS avg_order_value
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS order_items
JOIN `bigquery-public-data.thelook_ecommerce.orders` AS orders
  ON order_items.order_id = orders.order_id
JOIN `bigquery-public-data.thelook_ecommerce.users` AS users
  ON orders.user_id = users.id
JOIN `bigquery-public-data.thelook_ecommerce.events` AS events
  ON users.id = events.user_id
GROUP BY events.traffic_source
ORDER BY total_revenue DESC;

-- Step 9: Monthly revenue trend
SELECT
  EXTRACT(YEAR FROM created_at) AS order_year,
  EXTRACT(MONTH FROM created_at) AS order_month,
  COUNT(DISTINCT order_id) AS total_orders,
  SUM(sale_price) AS total_revenue
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS order_items
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

-- Step 9B: Monthly revenue trend with a single month field
SELECT
  DATE_TRUNC(DATE(created_at), MONTH) AS order_month,
  COUNT(DISTINCT order_id) AS total_orders,
  SUM(sale_price) AS total_revenue
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS order_items
GROUP BY order_month
ORDER BY order_month;