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
