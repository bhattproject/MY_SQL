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



--------------------------------------------------------



Actual dates:     1  2  3  5
Row number:       1  2  3  4
Date - RN:        X  X  X  Y   ← break happens

  
ROW_NUMBER (dup)	remove duplicates
ROW_NUMBER (rn)	create sequence index
DATE - rn	normalize consecutive dates
GROUP BY grp	identify streak
COUNT >= 5	filter valid streak

  Input Table (Logins)
user_id | login_date
--------|------------
1       | 2024-01-01
1       | 2024-01-01  ← duplicate
1       | 2024-01-02
1       | 2024-01-03
1       | 2024-01-04
1       | 2024-01-05
1       | 2024-01-07  ← break

🟡 STEP 1: dedup (Add dup_rn)
user_id | login_date | dup_rn
--------|------------|--------
1       | 2024-01-01 | 1
1       | 2024-01-01 | 2  ← duplicate marked
1       | 2024-01-02 | 1
1       | 2024-01-03 | 1
1       | 2024-01-04 | 1
1       | 2024-01-05 | 1
1       | 2024-01-07 | 1


👉 Visual:

Same (user_id, date) → numbering starts from 1
Only dup_rn = 1 is useful
🟢 STEP 2: filtered (Remove duplicates)
user_id | login_date
--------|------------
1       | 2024-01-01
1       | 2024-01-02
1       | 2024-01-03
1       | 2024-01-04
1       | 2024-01-05
1       | 2024-01-07


👉 Now each row = one day

🔵 STEP 3: numbered (Add rn)
user_id | login_date | rn
--------|------------|----
1       | 2024-01-01 | 1
1       | 2024-01-02 | 2
1       | 2024-01-03 | 3
1       | 2024-01-04 | 4
1       | 2024-01-05 | 5
1       | 2024-01-07 | 6  ← gap but rn continues


👉 Visual:

rn is continuous
Dates may have gaps → mismatch begins here
🔴 STEP 4: grouped (Compute grp)
grp = login_date - rn

user_id | login_date | rn | grp
--------|------------|----|------------
1       | 2024-01-01 | 1  | 2023-12-31
1       | 2024-01-02 | 2  | 2023-12-31
1       | 2024-01-03 | 3  | 2023-12-31
1       | 2024-01-04 | 4  | 2023-12-31
1       | 2024-01-05 | 5  | 2023-12-31
1       | 2024-01-07 | 6  | 2024-01-01  ← NEW GROUP

💥 KEY VISUAL INSIGHT
First 5 rows → SAME grp → ONE STREAK
Last row     → DIFFERENT → NEW STREAK

⚫ STEP 5: Final GROUPING
GROUP BY user_id, grp

user_id | grp        | count
--------|------------|-------
1       | 2023-12-31 | 5  ✅
1       | 2024-01-01 | 1  ❌

✅ FINAL OUTPUT
user_id
--------
1

🧠 FULL VISUAL FLOW (SUPER IMPORTANT)
RAW DATA
   ↓
DEDUP (mark duplicates)
   ↓
FILTER (keep one per day)
   ↓
ROW_NUMBER (create sequence)
   ↓
DATE - RN (normalize)
   ↓
GROUP BY (detect streaks)
   ↓
COUNT >= 5 (filter)

🔥 One Visual Trick to Remember Forever
Dates:        01  02  03  04  05  07
Row Number:   01  02  03  04  05  06
Subtract:     XX  XX  XX  XX  XX  YY
                ↑ SAME → streak
                         ↑ break




==================================================================
👉 Return:

user_id | start_date | end_date | streak_length


👉 And only longest streak per user 😈

----------------------------------------------------------------------


CREATE TABLE Logins (
    login_id   INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    login_date DATE NOT NULL,
    INDEX idx_user_login (user_id, login_date)
);

-- 3. Insert Mixed Test Data
INSERT INTO Logins (user_id, login_date) VALUES
(1, '2024-01-01'), (1, '2024-01-02'), (1, '2024-01-03'), (1, '2024-01-04'),
(2, '2024-01-01'), (2, '2024-01-02'), (2, '2024-01-04'), (2, '2024-01-05'),
(3, '2024-01-01'), (3, '2024-01-02'), (3, '2024-01-03'), 
(3, '2024-01-10'), (3, '2024-01-11'), (3, '2024-01-12'), (3, '2024-01-13'),
(4, '2024-01-01'), (4, '2024-01-01'), (4, '2024-01-02'), (4, '2024-01-03'),
(5, '2024-01-01'), (5, '2024-01-10');


SELECT * FROM Logins;

WITH dedup AS (
    SELECT DISTINCT user_id, login_date 
    FROM Logins
),
grp AS (
    SELECT 
        user_id, 
        login_date, 
        DATE_SUB(login_date, INTERVAL ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY login_date) DAY) AS grp_key
    FROM dedup
),
streaks AS (
    SELECT 
        user_id, 
        MIN(login_date) AS start_date, 
        MAX(login_date) AS end_date, 
        COUNT(*) AS streak_length -- Changed from 'streak length' to 'streak_length'
    FROM grp
    GROUP BY user_id, grp_key
)
SELECT * 
FROM streaks 
WHERE streak_length >= 3;
-- 1. Table Creation
CREATE TABLE Logins (
    login_id   INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    login_date DATE NOT NULL,
    INDEX idx_user_login (user_id, login_date)
);




INSERT INTO Logins (user_id, login_date) VALUES
(1, '2024-01-01'), (1, '2024-01-02'), (1, '2024-01-03'), (1, '2024-01-04'), -- User 1: 4-day streak
(2, '2024-01-01'), (2, '2024-01-02'), (2, '2024-01-04'), (2, '2024-01-05'), -- User 2: Two 2-day streaks
(3, '2024-01-01'), (3, '2024-01-02'), (3, '2024-01-03'),                   -- User 3: 3-day streak...
(3, '2024-01-10'), (3, '2024-01-11'), (3, '2024-01-12'), (3, '2024-01-13'), -- ...and 4-day streak
(4, '2024-01-01'), (4, '2024-01-01'), (4, '2024-01-02'), (4, '2024-01-03'), -- User 4: Duplicates + 3-day streak
(5, '2024-01-01'), (5, '2024-01-10'); -- User 5: Single days

----------------------------=================================================================================================
-- 1. Table Creation
CREATE TABLE Logins (
    login_id   INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    login_date DATE NOT NULL,
    INDEX idx_user_login (user_id, login_date)
);




INSERT INTO Logins (user_id, login_date) VALUES
(1, '2024-01-01'), (1, '2024-01-02'), (1, '2024-01-03'), (1, '2024-01-04'), -- User 1: 4-day streak
(2, '2024-01-01'), (2, '2024-01-02'), (2, '2024-01-04'), (2, '2024-01-05'), -- User 2: Two 2-day streaks
(3, '2024-01-01'), (3, '2024-01-02'), (3, '2024-01-03'),                   -- User 3: 3-day streak...
(3, '2024-01-10'), (3, '2024-01-11'), (3, '2024-01-12'), (3, '2024-01-13'), -- ...and 4-day streak
(4, '2024-01-01'), (4, '2024-01-01'), (4, '2024-01-02'), (4, '2024-01-03'), -- User 4: Duplicates + 3-day streak
(5, '2024-01-01'), (5, '2024-01-10'); -- User 5: Single days


SELECT * FROM Logins;
-- 3. The Multi-Layer Query



WITH dedup AS (
    -- Layer 1: Remove multiple logins on the same day
    SELECT DISTINCT user_id, login_date
    FROM Logins
),
grp AS (
    -- Layer 2: Create a unique 'grp_key' for each consecutive date block
    SELECT 
        user_id,
        login_date,
        DATE_SUB(login_date, INTERVAL ROW_NUMBER() OVER (
            PARTITION BY user_id ORDER BY login_date
        ) DAY) AS grp_key
    FROM dedup
),
streaks AS (
    -- Layer 3: Calculate the length of every individual streak
    SELECT 
        user_id,
        COUNT(*) AS streak_length
    FROM grp
    GROUP BY user_id, grp_key
)
-- Final Output: Find the single highest streak per user
SELECT 
    user_id, 
    MAX(streak_length) AS longest_streak
FROM streaks
GROUP BY user_id;
-================================================================================================
HARD VERSION 3: Streak WITH ALLOWED GAP (1 DAY SKIP ALLOWED)


Find streaks where users can miss 1 day but still count as continuous


Jan 1, Jan 2, Jan 4 → still valid (gap allowed)


WITH dedup AS (
    SELECT DISTINCT user_id, login_date
    FROM Logins
),
grp AS (
    SELECT 
        user_id,
        login_date,
        DATE_SUB(
            login_date,
            INTERVAL FLOOR(
                ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY login_date) / 2
            ) DAY
        ) AS grp_key
    FROM dedup
)
SELECT user_id, COUNT(*) AS streak_length
FROM grp
GROUP BY user_id, grp_key
HAVING COUNT(*) >= 3;

🧠 Why this is HARD:
Custom grouping logic
Requires thinking beyond standard “date - row_number”
=======================================================================================================
HARD VERSION 4: Consecutive Days WITH MINIMUM ACTIVITY


Logins(user_id, login_date, minutes_spent)



Find users who logged in 3 consecutive days AND spent ≥ 30 mins each day


WITH filtered AS (
    SELECT user_id, login_date
    FROM Logins
    WHERE minutes_spent >= 30
),
grp AS (
    SELECT 
        user_id,
        login_date,
        DATE_SUB(login_date, INTERVAL ROW_NUMBER() OVER (
            PARTITION BY user_id ORDER BY login_date
        ) DAY) AS grp_key
    FROM filtered
)
SELECT user_id
FROM grp
GROUP BY user_id, grp_key
HAVING COUNT(*) >= 3;

🧠 Twist:
Filtering BEFORE grouping
Real-world product analytics scenario
======================================================================================================
