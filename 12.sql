"""Problem Statement:You are given a login log table tracking daily user activity.
  Write a query to find all users who have logged in on 3 or more consecutive days.
  Input Table: user_loginsuser_id (integer)login_date (date)Expected OutputStructure:
  user_id (unique list of users who hit the streak)
  """


WITH RankedLogins AS (
    -- Step 1: Remove duplicates per day
    SELECT DISTINCT 
        user_id, 
        login_date
    FROM user_logins
),
StreakGroups AS (
    -- Step 2 & 3: Assign row numbers and subtract them from dates to find anchors
    SELECT 
        user_id,
        login_date,
        login_date - CAST(ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY login_date) AS INT) AS streak_anchor
    FROM RankedLogins
)
-- Step 4: Group by the anchor and filter streaks >= 3 days
SELECT DISTINCT 
    user_id
FROM StreakGroups
GROUP BY 
    user_id, 
    streak_anchor
HAVING 
    COUNT(*) >= 3;







WITH LaggedData AS (
    -- Step 1: Find the maximum end time seen so far up to the PREVIOUS row
    SELECT 
        user_id,
        start_time,
        end_time,
        MAX(end_time) OVER (
            PARTITION BY user_id 
            ORDER BY start_time, end_time
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS max_prev_end_time
    FROM user_sessions
),
GroupFlags AS (
    -- Step 2: If start_time is greater than the previous max end_time, flag a new group (1)
    SELECT 
        user_id,
        start_time,
        end_time,
        CASE 
            WHEN max_prev_end_time IS NULL THEN 1  -- First row starts group 1
            WHEN start_time > max_prev_end_time THEN 1 -- Gap found! Starts a new group
            ELSE 0 
        END AS is_new_group
    FROM LaggedData
),
