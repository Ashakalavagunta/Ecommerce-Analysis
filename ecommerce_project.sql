SELECT current_database();

/*
Check existing tables in the database.
Only shows tables in the 'public' schema,
which is where our ecommerce tables are.
*/
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';


--CREATE TABLES --

-- 1️) Customers --
CREATE TABLE IF NOT EXISTS customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50),
    signup_date DATE
);

-- 2️) Products --
CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price NUMERIC(10,2)
);

-- 3️) Orders (depends on customers) --
CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE,
    status VARCHAR(20)
);

-- 4️) Payments (depends on orders) --
CREATE TABLE IF NOT EXISTS payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    payment_method VARCHAR(30),
    amount NUMERIC(10,2),
    payment_date DATE
);



-- INSERT VALUES INTO TABLES --


-- Customers --
INSERT INTO customers (customer_name, email, city, country, signup_date) VALUES
('Asha K', 'asha@gmail.com', 'New York', 'USA', '2023-01-10'),
('Rahul P', 'rahul@gmail.com', 'Chicago', 'USA', '2023-02-15'),
('Neha S', 'neha@gmail.com', 'San Jose', 'USA', '2023-03-20'),
('John D', 'john@gmail.com', 'Dallas', 'USA', '2023-04-05'),
('Priya M', 'priya@gmail.com', 'Seattle', 'USA', '2023-05-12');

-- Products --
INSERT INTO products (product_name, category, price) VALUES
('Laptop', 'Electronics', 1200),
('Headphones', 'Electronics', 150),
('Office Chair', 'Furniture', 300),
('Smart Watch', 'Electronics', 250),
('Desk Lamp', 'Furniture', 80);

-- Orders --
INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2024-01-05', 'Completed'),
(2, '2024-01-15', 'Completed'),
(1, '2024-02-10', 'Completed'),
(3, '2024-02-20', 'Completed'),
(4, '2024-03-12', 'Completed'),
(5, '2024-03-25', 'Completed'),
(2, '2024-04-05', 'Completed'),
(1, '2024-04-18', 'Completed');

-- Payments --
INSERT INTO payments (order_id, payment_method, amount, payment_date) VALUES
(1, 'Credit Card', 1200, '2024-01-05'),
(2, 'PayPal', 150, '2024-01-15'),
(3, 'Credit Card', 300, '2024-02-10'),
(4, 'Debit Card', 250, '2024-02-20'),
(5, 'Credit Card', 80, '2024-03-12'),
(6, 'PayPal', 1200, '2024-03-25'),
(7, 'Credit Card', 150, '2024-04-05'),
(8, 'Debit Card', 250, '2024-04-18');


--VERIFY THE INSERTED DATA--


-- Customers table --
SELECT * FROM customers;

-- Products table --
SELECT * FROM products;

-- Orders table --
SELECT * FROM orders;

-- Payments table --
SELECT * FROM payments;


-- Find how much money e-commerce store made in total --

SELECT SUM(amount) AS total_revenue
FROM payments;


-- Find which products sold the most --
SELECT 
    p.product_name,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN payments pay ON o.order_id = pay.order_id
JOIN products p ON pay.amount = p.price
GROUP BY p.product_name
ORDER BY total_orders DESC;


-- FIND customers who bought more than once --
SELECT 
    c.customer_name,
    COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
HAVING COUNT(o.order_id) > 1;


-- Track revenue month by month --
SELECT 
    TO_CHAR(payment_date, 'YYYY-MM') AS month,
    SUM(amount) AS monthly_revenue
FROM payments
GROUP BY month
ORDER BY month;


-- See which cities generate the most revenue --
SELECT 
    c.city,
    SUM(p.amount) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.city
ORDER BY total_revenue DESC;


-- Find how much money each product category made --

SELECT 
    p.category,
    SUM(pay.amount) AS total_revenue
FROM payments pay
JOIN orders o ON pay.order_id = o.order_id
JOIN products p ON pay.amount = p.price
GROUP BY p.category
ORDER BY total_revenue DESC;


-- AOV = average amount spent per order --
SELECT 
    c.customer_name,
    SUM(pay.amount) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments pay ON o.order_id = pay.order_id
GROUP BY c.customer_name
ORDER BY lifetime_value DESC;


-- AOV = average amount spent per order --
SELECT 
    AVG(amount) AS average_order_value
FROM payments;


-- Rank products by total sales using a window function --
SELECT 
    p.product_name,
    SUM(pay.amount) AS total_revenue,
    RANK() OVER (ORDER BY SUM(pay.amount) DESC) AS revenue_rank
FROM payments pay
JOIN orders o ON pay.order_id = o.order_id
JOIN products p ON pay.amount = p.price
GROUP BY p.product_name
ORDER BY revenue_rank;


-- how each category performs month by month --
SELECT 
    TO_CHAR(pay.payment_date, 'YYYY-MM') AS month,
    p.category,
    SUM(pay.amount) AS monthly_revenue
FROM payments pay
JOIN orders o ON pay.order_id = o.order_id
JOIN products p ON pay.amount = p.price
GROUP BY month, p.category
ORDER BY month, monthly_revenue DESC;

-- Total sales per customer --
SELECT c.customer_name, SUM(pay.amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments pay ON o.order_id = pay.order_id
GROUP BY c.customer_name
ORDER BY total_spent DESC;

-- Top selling products --
SELECT p.product_name, COUNT(pay.payment_id) AS total_sold
FROM products p
JOIN payments pay ON pay.amount = p.price
GROUP BY p.product_name
ORDER BY total_sold DESC;

