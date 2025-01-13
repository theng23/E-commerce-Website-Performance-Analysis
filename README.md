# Ecommerce-Project
### DATASET
https://support.google.com/analytics/answer/3437719?hl=en
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

### **Query 01: calculate total visit, pageview, transaction for Jan, Feb and March 2017 (order by month)**
```sql

SELECT 
  FORMAT_DATE('%m',PARSE_DATE('%Y%m%d',date)) AS month
  ,COUNT(fullVisitorId) AS visits
  ,SUM(totals.pageviews) AS pageviews
  ,SUM(totals.transactions) AS transactions
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*` 
WHERE _table_suffix between '0101' AND '0331'
GROUP BY
  month
ORDER By
  month ASC;

```
|month|visits|pageviews|transactions|
|-----|------|---------|------------|
|01   |64694 |257708   |713         |
|02   |62192 |233373   |733         |
|03   |69931 |259522   |993         |

### **Query 02:
```sql
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
