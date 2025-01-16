/*
  Query 01: calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)
*/

SELECT 
  FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month, --Find Jan, Feb and March
  SUM(totals.visits) AS visits, --total visits
  SUM(totals.pageviews) AS pageviews, --total pagevies
  SUM(totals.transactions) AS transactions, --total transaction
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE
  _TABLE_SUFFIX BETWEEN '0101' AND '0331' --condition to get month 
GROUP BY 1 
ORDER BY 1; --sorting month


/*
  Query 02: Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit) (order by total_visit DESC)
*/

SELECT
  trafficSource.source
  ,SUM(totals.visits) AS total_visit --total visits
  ,SUM(totals.bounces) AS total_no_of_bounces --total bounces
  ,ROUND(SUM(totals.bounces)/SUM(totals.visits) * 100,3) AS bounce_rate --find bounce rate
FROM 
  `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY
  trafficSource.source
ORDER BY --sorting by total visits
  total_visit DESC;


/*
  Query 03: Revenue by traffic source by week, by month in June 2017
*/



/*
  Query 04: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017.
*/


WITH purchaser_data AS( --find a purchaser
  SELECT
      FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) AS month
      ,(SUM(totals.pageviews)/COUNT(DISTINCT fullvisitorid)) AS avg_pageviews_purchase --avgerate pageview purchase
  FROM 
    `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,UNNEST(hits) hits
    ,UNNEST(product) product
  WHERE 
    _table_suffix BETWEEN '0601' AND '0731'
    AND totals.transactions>=1
    AND product.productRevenue is not null -- must add this condition to ensure revenue
  GROUP BY month
),

non_purchaser_data AS( --find a non purchaser
  SELECT
      FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) AS month
      ,(SUM(totals.pageviews)/COUNT(DISTINCT fullvisitorid)) AS avg_pageviews_non_purchase  --avgerate pageview non purchase
  FROM 
    `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,UNNEST(hits) hits
    ,UNNEST(product) product
  WHERE 
    _table_suffix BETWEEN '0601' AND '0731'
    AND totals.transactions IS NULL
    AND product.productRevenue IS NULL --must add this condition to ensure revenue
  GROUP BY month
)

SELECT
    pd.*
    ,avg_pageviews_non_purchase
FROM 
  purchaser_data pd
FULL JOIN 
  non_purchaser_data
USING(month)
ORDER BY pd.month;

/*
  Query 05: Average number of transactions per user that made a purchase in July 2017
*/
SELECT
  FORMAT_DATE("%Y%m",PARSE_DATE("%Y%m%d",date)) AS month
  ,SUM(totals.transactions)/COUNT(DISTINCT fullvisitorid) AS Avg_total_transactions_per_user
FROM 
  `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,UNNEST (hits) hits
  ,UNNEST(product) product
WHERE
  totals.transactions>=1
  AND product.productRevenue IS NOT NULL -- must add this condition to ensure revenue
GROUP BY 
  month;


/*
  Query 06: Average amount of money spent per session. Only include purchaser data in July 2017
*/

SELECT
  FORMAT_DATE('%Y%m',PARSE_DATE('%Y%m%d',date)) as month
  ,ROUND((SUM(product.productRevenue) /SUM(totals.visits)) /1000000,3) AS avg_revenue_by_user_per_visit --avagerate revenue by user per visit
  from 
  `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
  ,UNNEST(hits) AS hits
  ,UNNEST(hits.product) AS product
WHERE
  totals.transactions IS NOT NULL 
    AND product.productRevenue IS NOT NULL --must add this condition to ensure revenue
GROUP BY
  month;


/*
  Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. Output should show product name and the quantity was ordered.
*/


WITH raw_data AS ( --find customer who purchased product "YouTube Men's Vintage Henley" in July 2017
  SELECT 
    DISTINCT fullVisitorId
    ,(product.v2ProductName) AS product_name1
  FROM 
    `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`,
    UNNEST(hits) AS hits,
    UNNEST(hits.product) AS product
    WHERE
      product.v2ProductName = "YouTube Men's Vintage Henley" AND product.productRevenue IS NOT NULL --Condition for fiding product name and purchasing
)
SELECT --Find the customer who purchased other products
  product.v2ProductName
  ,SUM(product.productQuantity) AS quantity --total_quantity
FROM
  raw_data rd
LEFT JOIN 
  `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
ON  
  rd.fullVisitorId = `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`.fullVisitorId
  ,UNNEST(hits) AS hits
  ,UNNEST(hits.product) AS product
WHERE product.v2ProductName <> "YouTube Men's Vintage Henley" AND product.productRevenue IS NOT NULL --condition for fiding customer who purchased other products
GROUP BY
  product.v2ProductName
ORDER BY  --sorting by quantity
  quantity DESC;



/*
  Query 08: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017. For example, 100% product view then 40% add_to_cart and 10% purchase.Add_to_cart_rate = number product add to cart/number product view. Purchase_rate = number product purchase/number product view. The output should be calculated in product level.
*/


WITH product_view AS( --find product view
  SELECT
    FORMAT_dATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month
    ,COUNT(product.productSKU) AS num_product_view
  FROM 
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`
    ,UNNEST(hits) AS hits
    ,UNNEST(hits.product) AS product
  WHERE 
    _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
    AND hits.eCommerceAction.action_type = '2'
  GROUP BY 
    month
),

add_to_cart AS(-- find add to cart
  SELECT
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month
    ,COUNT(product.productSKU) AS num_addtocart
  FROM 
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`
    ,UNNEST(hits) AS hits
    ,UNNEST(hits.product) AS product
  WHERE 
    _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
    AND hits.eCommerceAction.action_type = '3'
  GROUP BY 
    month
),

purchase as( --find purchase
  SELECT
    FORMAT_DATE("%Y%m", PARSE_DATE("%Y%m%d", date)) AS month
    ,COUNT(product.productSKU) AS num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  ,UNNEST(hits) AS hits
  ,UNNEST(hits.product) as product
  WHERE 
    _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
    AND hits.eCommerceAction.action_type = '6'
    AND product.productRevenue IS NOT NULL   --must add this condition to ensure revenue
  group by 1
)

SELECT
  pv.*
  ,num_addtocart
  ,num_purchase
  ,ROUND(num_addtocart*100/num_product_view,2) AS add_to_cart_rate --rate: add to cart
  ,ROUND(num_purchase*100/num_product_view,2) AS purchase_rate --rate: purchase
FROM 
  product_view pv
LEFT JOIN 
  add_to_cart a
ON 
  pv.month = a.month
LEFT JOIN
  purchase p 
ON 
  pv.month = p.month
ORDER BY --sorting by month
  pv.month;
