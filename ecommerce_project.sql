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


-- 4) Order items table (links orders to products) --
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT DEFAULT 1,
    item_price NUMERIC(10,2)  -- store price at the time of order
);

-- 5) Payments (depends on orders) --
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

INSERT INTO order_items (order_id, product_id, quantity, item_price) VALUES
(1, 1, 1, 1200),  -- Laptop
(2, 2, 1, 150),   -- Headphones
(3, 3, 1, 300),   -- Office Chair
(4, 4, 1, 250),   -- Smart Watch
(5, 5, 1, 80),    -- Desk Lamp
(6, 1, 1, 1200),  -- Laptop
(7, 2, 1, 150),   -- Headphones
(8, 4, 1, 250);   -- Smart Watch


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

-- VERIFY/CHECK DATA INSERTED IN TABLES --

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM payments;


-- QUERIES --

--  Total revenue --
SELECT SUM(item_price * quantity) AS total_revenue
FROM order_items;

-- Top-selling products
SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC;

-- Revenue per product --
SELECT 
    p.product_name,
    SUM(oi.item_price * oi.quantity) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;

-- Customers who bought more than once --
SELECT 
    c.customer_name,
    COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
HAVING COUNT(o.order_id) > 1;

-- Revenue by month --
SELECT 
    TO_CHAR(p.payment_date, 'YYYY-MM') AS month,
    SUM(oi.item_price * oi.quantity) AS monthly_revenue
FROM payments p
JOIN orders o ON p.order_id = o.order_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;

-- Revenue by city --
SELECT 
    c.city,
    SUM(oi.item_price * oi.quantity) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.city
ORDER BY total_revenue DESC;

-- Revenue by product category --
SELECT 
    p.category,
    SUM(oi.item_price * oi.quantity) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Average order value (AOV) --
SELECT 
    AVG(order_total) AS average_order_value
FROM (
    SELECT o.order_id, SUM(oi.item_price * oi.quantity) AS order_total
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id
) AS subquery;

-- Total spent per customer --
SELECT 
    c.customer_name,
    SUM(oi.item_price * oi.quantity) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_name
ORDER BY total_spent DESC;

-- Rank products by revenue --
SELECT 
    p.product_name,
    SUM(oi.item_price * oi.quantity) AS total_revenue,
    RANK() OVER (ORDER BY SUM(oi.item_price * oi.quantity) DESC) AS revenue_rank
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue_rank;

-- Category performance month by month --
SELECT 
    TO_CHAR(pmt.payment_date, 'YYYY-MM') AS month,
    pr.category,
    SUM(oi.item_price * oi.quantity) AS monthly_revenue
FROM payments pmt
JOIN orders o ON pmt.order_id = o.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products pr ON oi.product_id = pr.product_id
GROUP BY month, pr.category
ORDER BY month, monthly_revenue DESC;