# E-commerce Website Performance Analysis | Python, Google Colab
## I. Introduction
This project contains an eCommerce dataset that i will explore by using SQL on Google BigQuery. The dataset is based on the Google Analytics public dataset and contains data from an eCommerce website.
## II. Requirements
- Google Cloud Platform account
- Project on Google Cloud Platform
- Google BigQuery API enabled
- SQL query editor or IDE
## III. Dataset Access
1. The eCommerce dataset is stored in a public Google BigQuery dataset. To access the dataset, follow these steps:
  - Log in to your Google Cloud Platform account and create a new project.
  - Navigate to the BigQuery console and select your newly created project.
  - In the navigation panel, select "Add Data" and then "Search a project".
  - Enter the project ID "bigquery-public-data.google_analytics_sample.ga_sessions" and click "Enter".
  - Click on the "ga_sessions_" table to open it.
### DATASET
https://support.google.com/analytics/answer/3437719?hl=en <br>
Table Schema in this project:
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

2. The goal of creating this project
  - Overview of website activity
  - Bounce rate analysis
  - Revenue analysis
  - Transactions analysis
  - Products analysis


## IV. Exploring the Dataset
### **Query 01: calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)**
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
|month|visits|pageviews|transactions|
|-----|------|---------|------------|
|01   |64694 |257708   |713         |
|02   |62192 |233373   |733         |
|03   |69931 |259522   |993         |

### **Query 02: Bounce rate per traffic source in July 2017 (Bounce_rate = num_bounce/total_visit) (order by total_visit DESC)**
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
|reddit.com                 |189        |54                 |28.571     |
|qiita.com                  |146        |72                 |49.315     |
|quora.com                  |140        |70                 |50.0       |
|baidu                      |140        |84                 |60.0       |
|bing                       |111        |54                 |48.649     |
|mail.google.com            |101        |25                 |24.752     |
|yahoo                      |100        |41                 |41.0       |
|blog.golang.org            |65         |19                 |29.231     |
|l.facebook.com             |51         |45                 |88.235     |
|groups.google.com          |50         |22                 |44.0       |
|t.co                       |38         |27                 |71.053     |
|google.co.jp               |36         |25                 |69.444     |
|m.youtube.com              |34         |22                 |64.706     |
|dealspotr.com              |26         |12                 |46.154     |
|productforums.google.com   |25         |21                 |84.0       |
|support.google.com         |24         |16                 |66.667     |
|ask                        |24         |16                 |66.667     |
|int.search.tb.ask.com      |23         |17                 |73.913     |
|optimize.google.com        |21         |10                 |47.619     |
|docs.google.com            |20         |8                  |40.0       |
|lm.facebook.com            |18         |9                  |50.0       |
|l.messenger.com            |17         |6                  |35.294     |
|duckduckgo.com             |16         |14                 |87.5       |
|adwords.google.com         |16         |7                  |43.75      |
|google.co.uk               |15         |7                  |46.667     |
|sashihara.jp               |14         |8                  |57.143     |
|lunametrics.com            |13         |8                  |61.538     |
|search.mysearch.com        |12         |11                 |91.667     |
|tw.search.yahoo.com        |10         |8                  |80.0       |
|outlook.live.com           |10         |7                  |70.0       |
|phandroid.com              |9          |7                  |77.778     |
|plus.google.com            |8          |2                  |25.0       |
|connect.googleforwork.com  |8          |5                  |62.5       |
|m.yz.sm.cn                 |7          |5                  |71.429     |
|google.co.in               |6          |3                  |50.0       |
|search.xfinity.com         |6          |6                  |100.0      |
|online-metrics.com         |5          |2                  |40.0       |
|hangouts.google.com        |5          |1                  |20.0       |
|s0.2mdn.net                |5          |3                  |60.0       |
|google.ru                  |5          |1                  |20.0       |
|in.search.yahoo.com        |4          |2                  |50.0       |
|googleads.g.doubleclick.net|4          |1                  |25.0       |
|away.vk.com                |4          |3                  |75.0       |
|m.sogou.com                |4          |3                  |75.0       |
|m.baidu.com                |3          |2                  |66.667     |
|siliconvalley.about.com    |3          |2                  |66.667     |
|getpocket.com              |3          |                   |           |
|centrum.cz                 |2          |2                  |100.0      |
|plus.url.google.com        |2          |                   |           |
|github.com                 |2          |2                  |100.0      |
|myactivity.google.com      |2          |1                  |50.0       |
|uk.search.yahoo.com        |2          |1                  |50.0       |
|au.search.yahoo.com        |2          |2                  |100.0      |
|m.sp.sm.cn                 |2          |2                  |100.0      |
|search.1and1.com           |2          |2                  |100.0      |
|moodle.aurora.edu          |2          |2                  |100.0      |
|google.cl                  |2          |1                  |50.0       |
|amp.reddit.com             |2          |1                  |50.0       |
|calendar.google.com        |2          |1                  |50.0       |
|google.it                  |2          |1                  |50.0       |
|msn.com                    |2          |1                  |50.0       |
|wap.sogou.com              |2          |2                  |100.0      |
|google.co.th               |2          |1                  |50.0       |
|images.google.com.au       |1          |1                  |100.0      |
|it.pinterest.com           |1          |1                  |100.0      |
|web.facebook.com           |1          |1                  |100.0      |
|ph.search.yahoo.com        |1          |                   |           |
|web.mail.comcast.net       |1          |1                  |100.0      |
|es.search.yahoo.com        |1          |1                  |100.0      |
|google.bg                  |1          |1                  |100.0      |
|news.ycombinator.com       |1          |1                  |100.0      |
|arstechnica.com            |1          |                   |           |
|search.tb.ask.com          |1          |                   |           |
|online.fullsail.edu        |1          |1                  |100.0      |
|mx.search.yahoo.com        |1          |1                  |100.0      |
|suche.t-online.de          |1          |1                  |100.0      |
|google.com.br              |1          |                   |           |
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

### **Query 03: Revenue by traffic source by week, by month in June 2017**  
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


### **Query 04: Average number of pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017.**
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


### **Query 05: Average number of transactions per user that made a purchase in July 2017**
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



### **Query 06: Average amount of money spent per session. Only include purchaser data in July 2017**
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

### **Query 07: Other products purchased by customers who purchased product "YouTube Men's Vintage Henley" in July 2017. Output should show product name and the quantity was ordered.**
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
|Android Women's Fleece Hoodie|2       |
|Google Doodle Decal|2       |
|Recycled Mouse Pad|2       |
|Red Shine 15 oz Mug|2       |
|Android Wool Heather Cap Heather/Black|2       |
|Crunch Noise Dog Toy|2       |
|Google Slim Utility Travel Bag|1       |
|Google Men's Vintage Badge Tee White|1       |
|Google Men's  Zip Hoodie|1       |
|Google Men's 100% Cotton Short Sleeve Hero Tee Red|1       |
|Android Men's Vintage Tank|1       |
|Android Men's Short Sleeve Hero Tee White|1       |
|Android Men's Pep Rally Short Sleeve Tee Navy|1       |
|YouTube Men's Short Sleeve Hero Tee Black|1       |
|YouTube Women's Short Sleeve Hero Tee Charcoal|1       |
|Google Men's Performance Full Zip Jacket Black|1       |
|26 oz Double Wall Insulated Bottle|1       |
|Google Men's Pullover Hoodie Grey|1       |
|YouTube Men's Short Sleeve Hero Tee White|1       |
|Google Men's Long Sleeve Raglan Ocean Blue|1       |
|Google Twill Cap|1       |
|Google Men's Long & Lean Tee Grey|1       |
|Google Men's Bike Short Sleeve Tee Charcoal|1       |
|Google 5-Panel Cap|1       |
|Google Toddler Short Sleeve T-shirt Grey|1       |
|Android Sticker Sheet Ultra Removable|1       |
|Google Men's Long & Lean Tee Charcoal|1       |
|Google Men's Vintage Badge Tee Black|1       |
|YouTube Custom Decals|1       |
|Four Color Retractable Pen|1       |
|Google Laptop and Cell Phone Stickers|1       |
|Google Men's Performance 1/4 Zip Pullover Heather/Black|1       |
|YouTube Men's Long & Lean Tee Charcoal|1       |
|8 pc Android Sticker Sheet|1       |
|Android Men's Short Sleeve Hero Tee Heather|1       |
|YouTube Women's Short Sleeve Tri-blend Badge Tee Charcoal|1       |
|Google Women's Long Sleeve Tee Lavender|1       |
|YouTube Hard Cover Journal|1       |
|Android BTTF Moonshot Graphic Tee|1       |
|Google Men's Airflow 1/4 Zip Pullover Black|1       |


### **Query 08: Calculate cohort map from product view to addtocart to purchase in Jan, Feb and March 2017. For example, 100% product view then 40% add_to_cart and 10% purchase.Add_to_cart_rate = number product  add to cart/number product view. Purchase_rate = number product purchase/number product view. The output should be calculated in product level.**
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
