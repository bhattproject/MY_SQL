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





The E-Commerce "Cart-to-Checkout" Sessionization
  ScenarioAn e-commerce company tracks user clickstream events. Due to a system glitch, individual session IDs were not recorded, but the timestamp of each action was saved.Table Schema (clickstream):user_id (INT)event_timestamp (TIMESTAMP)event_type (VARCHAR) — e.g., 'browse', 'add_to_cart', 'checkout' The ChallengeA single session for a user is defined as a series of consecutive actions where the time gap between any two sequential actions is less than 30 minutes. If a user is inactive for 30 minutes or more, the next action starts a new session
