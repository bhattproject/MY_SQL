/*
problem statement 

Find the top 3 customers by total transaction amount in each branch, only for customers whose total balance is above the average balance of all customers.



*/


CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    branch_id INT,
    balance DECIMAL(12,2)
);
CREATE TABLE transactions (
    txn_id INT PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(12,2),
    txn_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
INSERT INTO customers VALUES
(1, 'Amit', 101, 50000),
(2, 'Riya', 101, 70000),
(3, 'John', 102, 30000),
(4, 'Sara', 102, 90000),
(5, 'Ali', 101, 60000);
INSERT INTO transactions VALUES
(1, 1, 1000, '2024-01-01'),
(2, 1, 2000, '2024-01-02'),
(3, 2, 5000, '2024-01-01'),
(4, 3, 700, '2024-01-03'),
(5, 4, 8000, '2024-01-02'),
(6, 5, 3000, '2024-01-01');

WITH customer_totals AS (
    SELECT 
        c.customer_id,
        c.name,
        c.branch_id,
        c.balance,
        SUM(t.amount) AS total_txn
    FROM customers c
    JOIN transactions t 
        ON c.customer_id = t.customer_id
    GROUP BY 
        c.customer_id, c.name, c.branch_id, c.balance
),
avg_balance AS (
    SELECT AVG(balance) AS avg_bal FROM customers
),
ranked_customers AS (
    SELECT 
        ct.*,
        RANK() OVER (
            PARTITION BY branch_id 
            ORDER BY total_txn DESC
        ) AS rnk
    FROM customer_totals ct
    WHERE ct.balance > (SELECT avg_bal FROM avg_balance)
)
SELECT *
FROM ranked_customers
WHERE rnk <= 3;
