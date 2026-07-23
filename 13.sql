You have a table named transactions with columns source, target, and messages. Two users can message each other in any direction (e.g., User A to User B, or User B to User A). Write a SQL query to find the total number of messages exchanged between any unique pair of users, regardless of who initiated the message.


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


