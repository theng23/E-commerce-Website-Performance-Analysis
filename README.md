
# 📊 E-commerce Website Performance Analysis | SQL, BigQuery
## 📑 I. Introduction
This project contains an eCommerce dataset that i will explore by using SQL on Google BigQuery. The dataset is based on the Google Analytics public dataset and contains data from an eCommerce website. Using this dataset, queries are executed to analyze website activity in 2017, including calculating the bounce rate, identifying days with the highest revenue, examining user behavior on pages, and performing other forms of analysis.
The goal of creating this project
  - Overview of website activity
  - Bounce rate analysis
  - Revenue analysis
  - Transactions analysis
  - Products analysis
## 📖 II. Requirements
- Google Cloud Platform account
- Project on Google Cloud Platform
- Google BigQuery API enabled
- SQL query editor or IDE
## 📂 III. Dataset Access
1. The eCommerce dataset is stored in a public Google BigQuery dataset. To access the dataset, follow these steps:
  - Log in to your Google Cloud Platform account and create a new project.
  - Navigate to the BigQuery console and select your newly created project.
  - In the navigation panel, select "Add Data" and then "Search a project".
  - Enter the project ID "bigquery-public-data.google_analytics_sample.ga_sessions" and click "Enter".
  - Click on the "ga_sessions_" table to open it.
### 📌DATASET
https://support.google.com/analytics/answer/3437719?hl=en <br>
<details>
<summary>Table Schema in this project:</summary>
  
| Field Name | Data Type | Description |
|-------|-------|-------|
| fullVisitorId | STRING | The unique visitor ID. |
| date | STRING | The date of the session in YYYYMMDD format. |
| totals | RECORD | This section contains aggregate values across the session. |
|totals.bounces|INTEGER|Total bounces (for convenience). For a bounced session, the value is 1, otherwise it is null.|
|totals.hits|INTEGER|Total number of hits within the session.|
|totals.pageviews|INTEGER|Total number of pageviews within the session.|
|totals.visits|INTEGER|The number of sessions (for convenience). This value is 1 for sessions with interaction events. The value is null if there are no interaction events in the session.|
|totals.transactions|INTEGER|Total number of ecommerce transactions within the session.|
|trafficSource.source|STRING|The source of the traffic source. Could be the name of the search engine, the referring hostname, or a value of the utm_source URL parameter.|
|hits|RECORD|This row and nested fields are populated for any and all types of hits.|
|hits.eCommerceAction|RECORD|This section contains all of the ecommerce hits that occurred during the session. This is a repeated field and has an entry for each hit that was collected.|
|hits.eCommerceAction.action_type|STRING|"The action type. Click through of product lists = 1, Product detail views = 2, Add product(s) to cart = 3, Remove product(s) from cart = 4, Check out = 5, Completed purchase = 6, Refund of purchase = 7, Checkout options = 8, Unknown = 0.Usually this action type applies to all the products in a hit, with the following exception: when hits.product.isImpression = TRUE, the corresponding product is a product impression that is seen while the product action is taking place (i.e., a ""product in list view"").Example query to calculate number of products in list views:SELECT COUNT(hits.product.v2ProductName) FROM [foo-160803:123456789.ga_sessions_20170101] WHERE hits.product.isImpression == TRUE Example query to calculate number of products in detailed view: SELECT COUNT(hits.product.v2ProductName), FROM [foo-160803:123456789.ga_sessions_20170101] WHERE hits.ecommerceaction.action_type = '2' AND ( BOOLEAN(hits.product.isImpression) IS NULL OR BOOLEAN(hits.product.isImpression) == FALSE )"|
|hits.product|RECORD|This row and nested fields will be populated for each hit that contains Enhanced Ecommerce PRODUCT data.|
|hits.product.productQuantity|INTEGER|The quantity of the product purchased.|
|hits.product.productRevenue|INTEGER|The revenue of the product, expressed as the value passed to Analytics multiplied by 10^6 (e.g., 2.40 would be given as 2400000).|
|hits.product.productSKU|STRING|Product SKU.|
|hits.product.v2ProductName|STRING|Product Name.|

</details>


## ⚒️ IV. Exploring the Dataset
### **Query 01: calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)**

- SQL Code:
```sql

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

```
- Result:

|month|visits|pageviews|transactions|
|-----|------|---------|------------|
|01   |64694 |257708   |713         |
|02   |62192 |233373   |733         |
|03   |69931 |259522   |993         |

A positive upward trend is observed across all three metrics from February to March. With February showing the lowest site visits, it may be beneficial to explore underlying factors contributing to this dip.
### **Query 02: Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit) (order by total_visit DESC)**
- SQL Code
```sql
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

```
- Top 10 highest visits

|source                     |total_visit|total_no_of_bounces|bounce_rate|
|---------------------------|-----------|-------------------|-----------|
|google                     |38400      |19798              |51.557     |
|(direct)                   |19891      |8606               |43.266     |
|youtube.com                |6351       |4238               |66.73      |
|analytics.google.com       |1972       |1064               |53.955     |
|Partners                   |1788       |936                |52.349     |
|m.facebook.com             |669        |430                |64.275     |
|google.com                 |368        |183                |49.728     |
|dfa                        |302        |124                |41.06      |
|sites.google.com           |230        |97                 |42.174     |
|facebook.com               |191        |102                |53.403     |

- Top 10 lowest visits

|source                     |total_visit|total_no_of_bounces|bounce_rate|
|---------------------------|-----------|-------------------|-----------|
|gophergala.com             |1          |1                  |100.0      |
|google.nl                  |1          |                   |           |
|google.ca                  |1          |                   |           |
|earth.google.com           |1          |                   |           |
|newclasses.nyu.edu         |1          |                   |           |
|kidrex.org                 |1          |1                  |100.0      |
|kik.com                    |1          |1                  |100.0      |
|aol                        |1          |                   |           |
|google.es                  |1          |1                  |100.0      |
|malaysia.search.yahoo.com  |1          |1                  |100.0      |

The result presents a summary of website traffic from different sources and key metrics used to assess user engagement and behaviours. It focuses on four main elements: source, total_visits, total_no_bounces and bounce_rate.

The top source of traffic to the website is Google however significant bounce rate(51.557&).Meanwhile, direct visits show a lower bounce rate (43.266%) and are the second-largest contributor to traffic. Additionally, platforms like YouTube and Facebook have high bounce rates, suggesting potential areas for improvement in user retention strategies.

Some traffic sources, like "gophergala.com," "kik.com," and "malaysia.search.yahoo.com," show a 100% bounce rate, suggesting visitors leave immediately without further interaction. This indicates potential mismatches between user expectations and the content or landing pages for these sources, worth investigating further.

### **Query 03: Revenue by traffic source by week, by month in June 2017**  
- SQL Code
```sql
  
SELECT --find revenue by traffic by week
    'WEEK' AS time_type
    ,FORMAT_DATE('%Y%W',PARSE_DATE('%Y%m%d',date)) AS time
    ,trafficSource.source
    ,SUM(product.productRevenue) / 1000000 AS revenue --calculate revene
FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
    ,UNNEST (hits) hits
    ,UNNEST (hits.product) product
WHERE
    product.productRevenue IS NOT NULL --must add this condition to ensure revenue
GROUP BY
  time
  ,trafficSource.source

UNION ALL --Union traffic by week and month

SELECT --find revenue by traffic by month
    'Month' AS time_type
    ,FORMAT_DATE('%Y%m',PARSE_DATE('%Y%m%d',date)) AS time
    ,trafficSource.source
    ,SUM(product.productRevenue) / 1000000 AS revenue
FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_201706*`
    ,UNNEST (hits) hits
    ,UNNEST (hits.product) product
WHERE
    product.productRevenue is not null --must add this condition to ensure revenue
GROUP BY
  time
  ,trafficSource.source
Order BY
    time_type DESC;

```
<details>
<summary>Results:</summary>

|time_type|time  |source           |revenue     |
|---------|------|-----------------|------------|
|WEEK     |201724|(direct)         |30908.909927|
|WEEK     |201724|google           |9217.169976 |
|WEEK     |201723|(direct)         |17325.679919|
|WEEK     |201723|dfa              |1145.279998 |
|WEEK     |201722|google           |2119.38999  |
|WEEK     |201722|sites.google.com |13.98       |
|WEEK     |201724|dfa              |2341.56     |
|WEEK     |201724|dealspotr.com    |72.95       |
|WEEK     |201725|google.com       |23.99       |
|WEEK     |201723|search.myway.com |105.939998  |
|WEEK     |201725|(direct)         |27295.319924|
|WEEK     |201724|bing             |13.98       |
|WEEK     |201722|(direct)         |6888.899975 |
|WEEK     |201724|mail.google.com  |2486.86     |
|WEEK     |201726|(direct)         |14914.80995 |
|WEEK     |201726|yahoo            |20.39       |
|WEEK     |201725|groups.google.com|38.59       |
|WEEK     |201723|youtube.com      |16.99       |
|WEEK     |201725|sites.google.com |25.19       |
|WEEK     |201725|mail.aol.com     |64.849998   |
|WEEK     |201724|l.facebook.com   |12.48       |
|WEEK     |201725|google           |1006.099991 |
|WEEK     |201726|google           |5330.569964 |
|WEEK     |201726|dfa              |3704.74     |
|WEEK     |201725|mail.google.com  |76.27       |
|WEEK     |201725|phandroid.com    |52.95       |
|WEEK     |201722|dfa              |1670.649998 |
|WEEK     |201726|groups.google.com|63.37       |
|WEEK     |201723|google           |1083.949999 |
|WEEK     |201723|chat.google.com  |74.03       |
|Month    |201706|google           |18757.17992 |
|Month    |201706|mail.google.com  |2563.13     |
|Month    |201706|dealspotr.com    |72.95       |
|Month    |201706|phandroid.com    |52.95       |
|Month    |201706|google.com       |23.99       |
|Month    |201706|search.myway.com |105.939998  |
|Month    |201706|mail.aol.com     |64.849998   |
|Month    |201706|l.facebook.com   |12.48       |
|Month    |201706|sites.google.com |39.17       |
|Month    |201706|groups.google.com|101.96      |
|Month    |201706|youtube.com      |16.99       |
|Month    |201706|(direct)         |97333.619695|
|Month    |201706|bing             |13.98       |
|Month    |201706|dfa              |8862.229996 |
|Month    |201706|yahoo            |20.39       |
|Month    |201706|chat.google.com  |74.03       |
</details>
The table presents revenue data categorized by attributes such as time type, time period, source, and revenue amount. Revenue originates from various channels, including direct website visits, search traffic, and referrals from external websites.


### **Query 04: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017.**
- SQL Code
```sql

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

```
|month|avg_pageviews_purchase|avg_pageviews_non_purchase|
|-----|----------------------|--------------------------|
|201706|94.02050113895217     |316.86558846341671        |
|201707|124.23755186721992    |334.05655979568053        |

Purchasers have lower average pageviews compared to non-purchasers, but from June to July 2017, purchasers' average pageviews increased significantly by 30.22%, while non-purchasers' pageviews rose modestly by 5.42%. This suggests improved engagement for purchasers, while non-purchasers may still struggle with decision-making or navigation.

### **Query 05: Average number of transactions per user that made a purchase in July 2017**
- SQL Code
```sql
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

```
|month|Avg_total_transactions_per_user|
|-----|-------------------------------|
|201707|4.16390041493776               |

Average total transactions per user in July 2017 is 4.1639. This information serves to understand user behavior, monitor platform engagement levels, and assess the effectiveness of marketing efforts or promotions conducted during that period

### **Query 06: Average amount of money spent per session. Only include purchaser data in July 2017**
- SQL Code
```sql
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
```
|month|Avg_revenue_by_user_per_visit|
|-----|-------------------------------|
|201707|4.857            |

In July 2017, the average revenue generated per user per visit amounted to 43.857. This indicates that, on average, users spent around 44 during that time. Such a metric serves as a valuable tool for businesses to gauge user engagement and monitor overall activity levels.

### **Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. Output should show product name and the quantity was ordered.**
- SQL Code
```sql

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


```
|v2ProductName|quantity|
|-------------|--------|
|Google Sunglasses|20      |
|Google Women's Vintage Hero Tee Black|7       |
|SPF-15 Slim & Slender Lip Balm|6       |
|Google Women's Short Sleeve Hero Tee Red Heather|4       |
|YouTube Men's Fleece Hoodie Black|3       |
|Google Men's Short Sleeve Badge Tee Charcoal|3       |
|22 oz YouTube Bottle Infuser|2       |
|Android Men's Vintage Henley|2       |
|Google Men's Short Sleeve Hero Tee Charcoal|2       |
|YouTube Twill Cap|2       |

The table highlights inventory levels, with Google Sunglasses having the highest quantity (20) and several items, like Google Lip Balm and YouTube Hoodies, having the lowest quantity (2). This snapshot is useful for managing stock or planning replenishment strategies.

### **Query 08: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017. For example, 100% product view then 40% add_to_cart and 10% purchase.Add_to_cart_rate = number product  add to cart/number product view. Purchase_rate = number product purchase/number product view. The output should be calculated in product level.**

- Code SQL
```sql

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

```
|month|num_product_view|num_addtocart|num_purchase|add_to_cart_rate|purchase_rate|
|-----|----------------|-------------|------------|----------------|-------------|
|201701|25787           |7342         |2143        |28.47           |8.31         |
|201702|21489           |7360         |2060        |34.25           |9.59         |
|201703|23549           |8782         |2977        |37.29           |12.64        |

In Q1 2017, engagement and conversion rates steadily increased, with March showing the highest rates—37.29% for add-to-cart actions and 12.64% for purchases—indicating enhanced user interest and activity.



