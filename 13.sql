'''You have a table named transactions with columns source, target, and messages. Two users can message each other in any direction (e.g., User A to User B, or User B to User A). Write a SQL query to find the total number of messages exchanged between any unique pair of users, regardless of who initiated the message.
'''

  SELECT 
    user1, 
    user2, 
    SUM(messages) AS total_messages
FROM (
    SELECT 
        CASE WHEN source < target THEN source ELSE target END AS user1,
        CASE WHEN source < target THEN target ELSE source END AS user2,
        messages
    FROM transactions
) t
GROUP BY user1, user2;


The Active User Retention Retention Gap 
Question 1: The Active User Retention Retention Gap (Meta/Google Level)📋 ScenarioYou are given a table named user_actions that logs user interactions on a platform.Table Schema (user_actions):user_id (INT)action_date (DATE)action_type (VARCHAR) — e.g., 'login', 'post', 'like' The ChallengeWrite a SQL query to find "Consecutive Active Users". A consecutive active user is defined as someone who performed at least one action on 3 or more consecutive days.Return a unique list of user_ids who meet this criterion.

===================================
  SELECT DISTINCT user_id
FROM (
    SELECT 
        user_id,
        action_date,
        LEAD(action_date, 1) OVER(PARTITION BY user_id ORDER BY action_date) AS next_day,
        LEAD(action_date, 2) OVER(PARTITION BY user_id ORDER BY action_date) AS day_after_next
    FROM (
        SELECT DISTINCT user_id, CAST(action_date AS DATE) AS action_date
        FROM user_actions
    ) distinct_actions
) date_leads
WHERE next_day = action_date + INTERVAL '1 day'
  AND day_after_next = action_date + INTERVAL '2 days';

=============================


The E-Commerce "Cart-to-Checkout" Sessionization
  ScenarioAn e-commerce company tracks user clickstream events. Due to a system glitch, individual session IDs were not recorded, but the timestamp of each action was saved.Table Schema (clickstream):user_id (INT)event_timestamp (TIMESTAMP)event_type (VARCHAR) — e.g., 'browse', 'add_to_cart', 'checkout' The ChallengeA single session for a user is defined as a series of consecutive actions where the time gap between any two sequential actions is less than 30 minutes. If a user is inactive for 30 minutes or more, the next action starts a new session
o reconstruct the session IDs for this clickstream dataset, you can solve this using SQL window functions. This is a classic "gaps and islands" problem where you detect the "gaps" (inactivity of 30 minutes or more) to define the boundaries of your "islands" (sessions).1. Identify Session Start BoundariesFirst, look at the previous event's timestamp for each user using the LAG() window function. If the difference between the current event's timestamp and the previous timestamp is 30 minutes or more (or if there is no previous event), mark it as the start of a new session (1), otherwise 0.2. Run a Cumulative SumPerform a running total (SUM() OVER) of those flags. Because the flag only increments when a new session starts, the cumulative sum naturally acts as a unique sequential session indicator for that specific user.


WITH flagged_events AS (
    SELECT 
        user_id,
        event_timestamp,
        event_type,
        -- Check if the gap since the last event is >= 30 minutes
        CASE 
            WHEN event_timestamp - LAG(event_timestamp) OVER (
                PARTITION BY user_id 
                ORDER BY event_timestamp
             ) >= INTERVAL '30 minutes' THEN 1
            WHEN LAG(event_timestamp) OVER (
                PARTITION BY user_id 
                ORDER BY event_timestamp
             ) IS NULL THEN 1
            ELSE 0 
        END AS is_new_session
    FROM clickstream
),
session_numbered AS (
    SELECT 
        user_id,
        event_timestamp,
        event_type,
        -- Summing the flags creates a sequential session index per user
        SUM(is_new_session) OVER (
            PARTITION BY user_id 
            ORDER BY event_timestamp
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS user_session_index
    FROM flagged_events
)
SELECT 
    user_id,
    event_timestamp,
    event_type,
    -- Construct a globally unique session ID string
    CONCAT(user_id, '_s', user_session_index) AS session_id
FROM session_numbered
ORDER BY user_id, event_timestamp;
