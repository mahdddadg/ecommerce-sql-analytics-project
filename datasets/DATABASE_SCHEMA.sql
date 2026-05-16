-- ==========================================
-- E-COMMERCE SQL ANALYTICS PROJECT
-- DATABASE SCHEMA
-- ==========================================

-- ==========================================
-- 1. CUSTOMERS TABLE
-- ==========================================

CREATE TABLE customers (

    customer_id INT PRIMARY KEY,

    first_name VARCHAR(50),

    last_name VARCHAR(50),

    gender VARCHAR(20),

    country VARCHAR(50),

    city VARCHAR(50),

    signup_date DATE

);



-- ==========================================
-- 2. PRODUCTS TABLE
-- ==========================================

CREATE TABLE products (

    product_id INT PRIMARY KEY,

    category VARCHAR(50),

    sub_category VARCHAR(50),

    product_name VARCHAR(100),

    price DECIMAL(10,2)

);



-- ==========================================
-- 3. ORDERS TABLE
-- ==========================================

CREATE TABLE orders (

    order_id INT PRIMARY KEY,

    customer_id INT,

    order_date DATE,

    order_status VARCHAR(50),

    payment_method VARCHAR(50),

    sales DECIMAL(10,2),

    quantity INT,

    discount DECIMAL(10,2),

    profit DECIMAL(10,2),

    shipping_cost DECIMAL(10,2),

    CONSTRAINT fk_orders_customers
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)

);



-- ==========================================
-- 4. ORDER_ITEMS TABLE
-- ==========================================

CREATE TABLE order_items (

    order_item_id INT PRIMARY KEY,

    order_id INT,

    product_id INT,

    quantity INT,

    sales DECIMAL(10,2),

    profit DECIMAL(10,2),

    CONSTRAINT fk_orderitems_orders
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id),

    CONSTRAINT fk_orderitems_products
    FOREIGN KEY (product_id)
    REFERENCES products(product_id)

);



-- ==========================================
-- 5. SHIPPING TABLE
-- ==========================================

CREATE TABLE shipping (

    shipping_id INT PRIMARY KEY,

    order_id INT,

    ship_date DATE,

    delivery_date DATE,

    ship_mode VARCHAR(50),

    warehouse_region VARCHAR(50),

    CONSTRAINT fk_shipping_orders
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id)

);



-- ==========================================
-- DATABASE RELATIONSHIPS
-- ==========================================



orders 1 ---> 1 shipping

*/
