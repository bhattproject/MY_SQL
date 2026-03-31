Consecutive Login Days (Streak Problem) Logins(user_id, login_date) 
  Find users with at least 5 consecutive login days.

  
==================================================
user_id | login_date | grp
--------|------------|------------
1       | 2024-01-01 | 2023-12-31
1       | 2024-01-02 | 2023-12-31
1       | 2024-01-03 | 2023-12-31
1       | 2024-01-04 | 2023-12-31
1       | 2024-01-05 | 2023-12-31   ← SAME GROUP ✅

1       | 2024-01-07 | 2024-01-01   ← NEW GROUP ❌

2       | 2024-01-01 | 2023-12-31
2       | 2024-01-03 | 2024-01-01
2       | 2024-01-04 | 2024-01-01
2       | 2024-01-05 | 2024-01-01
2       | 2024-01-06 | 2024-01-01
2       | 2024-01-07 | 2024-01-01   ← SAME GROUP ✅




WITH numbered AS (
    SELECT 
        user_id,
        login_date,
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY login_date
        ) AS rn
    FROM Logins
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

Instead of:

REMOVE duplicates first


We do:

👉 Assign row number per (user_id, login_date)
👉 Keep only first occurrence

WITH dedup AS (
    SELECT 
        user_id,
        login_date,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, login_date
            ORDER BY login_date
        ) AS dup_rn
    FROM Logins
),
filtered AS (
    SELECT user_id, login_date
    FROM dedup
    WHERE dup_rn = 1
),
numbered AS (
    SELECT 
        user_id,
        login_date,
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY login_date
        ) AS rn
    FROM filtered
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








==================================================================
👉 Return:

user_id | start_date | end_date | streak_length


👉 And only longest streak per user 😈

