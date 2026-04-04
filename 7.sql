
At Least 3 Consecutive Days + Return ALL Streak RANGES
🧾 Table:

Logins(user_id, login_date)

❓ Problem:

Find all streaks (start_date, end_date) where a user logged in ≥ 3 consecutive days.
  

-============================================================================
  
WITH dedup AS (
    SELECT DISTINCT user_id, login_date
    FROM Logins
),
grp AS (
    SELECT 
        user_id,
        login_date,
        DATE_SUB(login_date, INTERVAL ROW_NUMBER() OVER (
            PARTITION BY user_id ORDER BY login_date
        ) DAY) AS grp_key
    FROM dedup
),
streaks AS (
    SELECT 
        user_id,
        MIN(login_date) AS start_date,
        MAX(login_date) AS end_date,
        COUNT(*) AS streak_length
    FROM grp
    GROUP BY user_id, grp_key
)
SELECT *
FROM streaks
WHERE streak_length >= 3;
