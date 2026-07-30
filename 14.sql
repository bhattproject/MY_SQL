Question 1: Fraudulent Repeated Payments (Stripe)Concept: Window Functions, Time-interval filtering, and Self-joins.Problem StatementA online payment processor wants to
  identify potential fraud or accidental double-clicks. Write a query to identify any payments made at the same merchant with the same credit card for the same amount within
  10 minutes of each other

Schema (transactions)transaction_id (INT)merchant_id (INT)credit_card_id (INT)amount (DECIMAL)transaction_timestamp (TIMESTAMP)

sqlWITH RankedTransactions AS (
    SELECT 
        merchant_id,
        credit_card_id,
        amount,
        transaction_timestamp,
        LAG(transaction_timestamp) OVER(
            PARTITION BY merchant_id, credit_card_id, amount 
            ORDER BY transaction_timestamp
        ) AS previous_transaction_time
    FROM transactions
)
SELECT COUNT(*) AS payment_count
FROM RankedTransactions
WHERE transaction_timestamp <= previous_transaction_time + INTERVAL '10 minutes';


=================================================================================================

Question 2: User Active Streaks / Gaps & Islands (Meta / Uber)Concept: Row Numbers, Gap Detection, and Continuous Sequence Tracking.Problem StatementGiven a table 
  tracking daily user logins, write a query to find the longest consecutive login streak for each user.Schema (user_logins)user_id (INT)login_date (DATE)

sql
  WITH UniqueLogins AS (
    -- Remove duplicate logins on the same day by the same user
    SELECT DISTINCT user_id, login_date 
    FROM user_logins
),
GroupedStreaks AS (
    -- Subtracting row number from the date creates a constant anchor date for consecutive days
    SELECT 
        user_id,
        login_date,
        login_date - CAST(ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY login_date) AS INT) AS streak_group
    FROM UniqueLogins
),
StreakCounts AS (
    -- Count the length of each continuous streak group
    SELECT 
        user_id,
        COUNT(*) AS streak_length
    FROM GroupedStreaks
    GROUP BY user_id, streak_group
)
-- Extract the maximum consecutive streak per user
SELECT 
    user_id,
    MAX(streak_length) AS longest_streak
FROM StreakCounts
GROUP BY user_id;

=========================================================================================================
