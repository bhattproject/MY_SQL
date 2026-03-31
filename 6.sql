




====================================

If data has duplicates:

user_id | login_date
--------|------------
1       | 2024-01-01
1       | 2024-01-01  ← duplicate
1       | 2024-01-02
1       | 2024-01-03
1       | 2024-01-04
1       | 2024-01-05

  2024-01-01 → rn = 1
2024-01-01 → rn = 2  ❌
2024-01-02 → rn = 3
date - rn → breaks grouping



WITH distinct_logins AS (
    SELECT DISTINCT user_id, login_date
    FROM Logins
),
numbered AS (
    SELECT 
        user_id, 
        login_date,
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY login_date
        ) AS rn
    FROM distinct_logins
),
grouped AS (
    SELECT 
        user_id,
        login_date,
        DATE_SUB(login_date, INTERVAL rn DAY) AS grp
    FROM numbered
)
SELECT user_id
FROM grouped
GROUP BY user_id, grp
HAVING COUNT(*) >= 5;
===============================
