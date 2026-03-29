'''Median from Frequency Table
searches(search_count INT, num_users INT)

+---------------+-----------+
| search_count  | num_users |
+---------------+-----------+
|      1        |     2     |
|      2        |     3     |
|      3        |     1     |
+---------------+-----------+

'''
WITH expanded AS (
    SELECT 
        search_count,
        num_users,
        SUM(num_users) OVER (ORDER BY search_count) AS cum_users,
        SUM(num_users) OVER () AS total_users
    FROM searches
),
median_pos AS (
    SELECT *,
           (total_users + 1) / 2 AS m1,
           (total_users + 2) / 2 AS m2
    FROM expanded
)
SELECT AVG(search_count) AS median
FROM median_pos
WHERE cum_users >= m1 AND cum_users - num_users < m2;
