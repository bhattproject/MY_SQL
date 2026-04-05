Repeated Payments [Stripe SQL Interview Question]
Stripe asked this tricky SQL interview question, about identifying any payments made at the same merchant with the same credit card for the same amount within 10 minutes of each other and reporting the count of such repeated payments.

Input/Output Data
transactions Example Input:

transaction_id	merchant_id	credit_card_id	amount	transaction_timestamp
1	101	1	100	09/25/2022 12:00:00
2	101	1	100	09/25/2022 12:08:00
3	101	1	100	09/25/2022 12:28:00
4	102	2	300	09/25/2022 12:00:00
6	102	2	400	09/25/2022 14:00:00
Example Output:

payment_count
1
Solution:
WITH payments AS (
  SELECT 
    merchant_id, 
    EXTRACT(EPOCH FROM transaction_timestamp - 
      LAG(transaction_timestamp) OVER(
        PARTITION BY merchant_id, credit_card_id, amount 
        ORDER BY transaction_timestamp)
    )/60 AS minute_difference 
  FROM transactions) 

SELECT COUNT(merchant_id) AS payment_count
FROM payments 
WHERE minute_difference <= 10;



---------------------------------------------------------------------------

'''Median Google Search Frequency [Google SQL Interview Question]
Google’s Marketing Team needed to add a simple statistic to their upcoming Superbowl Ad: the median number of searches made per year. You were given a summary table that tells you the number of searches made last year, write a query to report the median searches made per user.

  search_frequency Table:

Column Name	Type
searches	integer
num_users	integer
Input/Output Data:
Example Input:

searches	num_users
1	2
2	2
3	3
4	1
Example Output:

median
2.5
  '''


Solution:
WITH searches_expanded AS (
  SELECT searches
  FROM search_frequency
  GROUP BY 
    searches, 
    GENERATE_SERIES(1, num_users))

SELECT 
  ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (
    ORDER BY searches)::DECIMAL, 1) AS  median
FROM searches_expanded;



