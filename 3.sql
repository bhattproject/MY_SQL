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


-----------------------------------------------------------------
WITH expanded AS (
    SELECT 
        search_count, 
        num_users, 
        SUM(num_users) OVER (ORDER BY search_count) AS cum_users, 
        SUM(num_users) OVER () AS total_users 
    FROM searches
), 
median_pos AS (
    SELECT 
        *, 
        -- These identify the exact integer ranks needed for the median
        FLOOR((total_users + 1) / 2.0) AS m1, 
        CEIL((total_users + 1) / 2.0) AS m2 
    FROM expanded
)
SELECT AVG(search_count) AS median 
FROM median_pos 
-- Captures any row that contains either the m1-th or m2-th user
WHERE cum_users >= m1 
  AND (cum_users - num_users) < m2;
------------------------------------------------------------------
