-- ============================================================
--  B2B SALES PERFORMANCE DATABASE
--  Project: Sales & Performance Analysis
--  Author : Mohammad Danish
--  Tools  : SQL, Power BI
-- ============================================================

-- --------------------------------------------------------
-- 1. TABLE DEFINITIONS
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS regions (
    region_id   INTEGER PRIMARY KEY,
    region_name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS customers (
    customer_id   INTEGER PRIMARY KEY,
    company_name  VARCHAR(100) NOT NULL,
    industry      VARCHAR(50),
    region_id     INTEGER REFERENCES regions(region_id),
    account_tier  VARCHAR(20) CHECK (account_tier IN ('Gold', 'Silver', 'Bronze')),
    created_date  DATE
);

CREATE TABLE IF NOT EXISTS sales_reps (
    rep_id      INTEGER PRIMARY KEY,
    rep_name    VARCHAR(100) NOT NULL,
    region_id   INTEGER REFERENCES regions(region_id),
    team        VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS products (
    product_id    INTEGER PRIMARY KEY,
    product_name  VARCHAR(100) NOT NULL,
    category      VARCHAR(50),
    unit_price    DECIMAL(10,2),
    cost_price    DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS orders (
    order_id      INTEGER PRIMARY KEY,
    customer_id   INTEGER REFERENCES customers(customer_id),
    rep_id        INTEGER REFERENCES sales_reps(rep_id),
    order_date    DATE NOT NULL,
    delivery_date DATE,
    status        VARCHAR(20) CHECK (status IN ('Delivered', 'Pending', 'Cancelled'))
);

CREATE TABLE IF NOT EXISTS order_items (
    item_id     INTEGER PRIMARY KEY,
    order_id    INTEGER REFERENCES orders(order_id),
    product_id  INTEGER REFERENCES products(product_id),
    quantity    INTEGER NOT NULL,
    unit_price  DECIMAL(10,2) NOT NULL,   -- price at time of sale
    discount    DECIMAL(5,2) DEFAULT 0    -- percentage discount
);

-- --------------------------------------------------------
-- 2. SEED DATA
-- --------------------------------------------------------

INSERT INTO regions VALUES
(1, 'North'),
(2, 'South'),
(3, 'East'),
(4, 'West');

INSERT INTO sales_reps VALUES
(1, 'Ayesha Khan',    1, 'Enterprise'),
(2, 'Rohit Sharma',   2, 'SMB'),
(3, 'Priya Nair',     3, 'Enterprise'),
(4, 'Danish M.',      4, 'SMB'),
(5, 'Neha Gupta',     1, 'Enterprise'),
(6, 'Arjun Mehta',    3, 'SMB');

INSERT INTO customers VALUES
(1,  'TechNova Solutions',    'IT Services',      1, 'Gold',   '2022-03-15'),
(2,  'Pinnacle Logistics',    'Logistics',        2, 'Silver', '2021-07-20'),
(3,  'CoreBuild Infra',       'Construction',     3, 'Gold',   '2020-11-01'),
(4,  'NexGen Pharma',         'Pharma',           4, 'Bronze', '2023-01-10'),
(5,  'Vertex Manufacturing',  'Manufacturing',    1, 'Gold',   '2021-05-22'),
(6,  'Orbit Retail Group',    'Retail',           2, 'Silver', '2022-09-14'),
(7,  'SkyBridge Telecom',     'Telecom',          3, 'Gold',   '2020-08-30'),
(8,  'Meridian Finance',      'Finance',          4, 'Silver', '2023-03-05'),
(9,  'GreenLeaf Agro',        'Agriculture',      1, 'Bronze', '2022-12-18'),
(10, 'BlueStar Energy',       'Energy',           2, 'Gold',   '2021-02-27');

INSERT INTO products VALUES
(1, 'Enterprise CRM License',    'Software',  45000.00, 18000.00),
(2, 'Data Analytics Suite',      'Software',  62000.00, 22000.00),
(3, 'Cloud Storage Plan (1TB)',   'Cloud',     12000.00,  3500.00),
(4, 'Cybersecurity Package',      'Security',  38000.00, 14000.00),
(5, 'ERP Implementation',         'Services',  95000.00, 55000.00),
(6, 'IT Support Contract',        'Services',  28000.00, 10000.00),
(7, 'Network Infrastructure Kit', 'Hardware',  55000.00, 32000.00),
(8, 'BI Dashboard Setup',         'Services',  42000.00, 18000.00),
(9, 'API Integration Module',     'Software',  33000.00, 12000.00),
(10,'Managed Cloud Services',     'Cloud',     75000.00, 35000.00);

INSERT INTO orders VALUES
(1,  1,  1, '2024-01-10', '2024-01-18', 'Delivered'),
(2,  2,  2, '2024-01-15', '2024-01-25', 'Delivered'),
(3,  3,  3, '2024-01-22', '2024-02-01', 'Delivered'),
(4,  4,  4, '2024-02-03', '2024-02-12', 'Delivered'),
(5,  5,  5, '2024-02-14', '2024-02-22', 'Delivered'),
(6,  6,  6, '2024-02-20', NULL,         'Cancelled'),
(7,  7,  1, '2024-03-05', '2024-03-14', 'Delivered'),
(8,  8,  2, '2024-03-12', '2024-03-22', 'Delivered'),
(9,  9,  3, '2024-03-18', NULL,         'Pending'),
(10, 10, 4, '2024-03-25', '2024-04-03', 'Delivered'),
(11, 1,  5, '2024-04-02', '2024-04-11', 'Delivered'),
(12, 2,  6, '2024-04-09', '2024-04-19', 'Delivered'),
(13, 3,  1, '2024-04-16', '2024-04-26', 'Delivered'),
(14, 4,  2, '2024-04-23', NULL,         'Pending'),
(15, 5,  3, '2024-05-01', '2024-05-10', 'Delivered'),
(16, 6,  4, '2024-05-08', '2024-05-17', 'Delivered'),
(17, 7,  5, '2024-05-15', '2024-05-24', 'Delivered'),
(18, 8,  6, '2024-05-22', '2024-05-31', 'Delivered'),
(19, 9,  1, '2024-06-01', '2024-06-10', 'Delivered'),
(20, 10, 2, '2024-06-08', '2024-06-17', 'Delivered'),
(21, 1,  3, '2024-06-15', '2024-06-24', 'Delivered'),
(22, 2,  4, '2024-06-22', NULL,         'Cancelled'),
(23, 3,  5, '2024-07-03', '2024-07-12', 'Delivered'),
(24, 4,  6, '2024-07-10', '2024-07-19', 'Delivered'),
(25, 5,  1, '2024-07-18', '2024-07-27', 'Delivered'),
(26, 6,  2, '2024-07-25', '2024-08-03', 'Delivered'),
(27, 7,  3, '2024-08-02', '2024-08-11', 'Delivered'),
(28, 8,  4, '2024-08-09', '2024-08-18', 'Delivered'),
(29, 9,  5, '2024-08-16', NULL,         'Pending'),
(30, 10, 6, '2024-08-23', '2024-09-01', 'Delivered'),
(31, 1,  1, '2024-09-05', '2024-09-14', 'Delivered'),
(32, 2,  2, '2024-09-12', '2024-09-21', 'Delivered'),
(33, 3,  3, '2024-09-19', '2024-09-28', 'Delivered'),
(34, 4,  4, '2024-09-26', '2024-10-05', 'Delivered'),
(35, 5,  5, '2024-10-03', '2024-10-12', 'Delivered'),
(36, 6,  6, '2024-10-10', '2024-10-19', 'Delivered'),
(37, 7,  1, '2024-10-17', '2024-10-26', 'Delivered'),
(38, 8,  2, '2024-10-24', NULL,         'Cancelled'),
(39, 9,  3, '2024-11-01', '2024-11-10', 'Delivered'),
(40, 10, 4, '2024-11-08', '2024-11-17', 'Delivered'),
(41, 1,  5, '2024-11-15', '2024-11-24', 'Delivered'),
(42, 2,  6, '2024-11-22', '2024-12-01', 'Delivered'),
(43, 3,  1, '2024-12-03', '2024-12-12', 'Delivered'),
(44, 4,  2, '2024-12-10', '2024-12-19', 'Delivered'),
(45, 5,  3, '2024-12-17', '2024-12-26', 'Delivered');

INSERT INTO order_items VALUES
(1,  1,  1, 2, 45000.00, 5.0),
(2,  1,  3, 5, 12000.00, 0.0),
(3,  2,  6, 1, 28000.00, 10.0),
(4,  3,  5, 1, 95000.00, 5.0),
(5,  3,  8, 2, 42000.00, 0.0),
(6,  4,  4, 1, 38000.00, 0.0),
(7,  5,  2, 1, 62000.00, 8.0),
(8,  5,  9, 3, 33000.00, 5.0),
(9,  6,  7, 1, 55000.00, 0.0),
(10, 7,  10,1, 75000.00, 10.0),
(11, 7,  3, 3, 12000.00, 0.0),
(12, 8,  1, 1, 45000.00, 5.0),
(13, 9,  6, 2, 28000.00, 0.0),
(14, 10, 2, 1, 62000.00, 0.0),
(15, 10, 4, 1, 38000.00, 5.0),
(16, 11, 5, 1, 95000.00, 0.0),
(17, 11, 8, 1, 42000.00, 5.0),
(18, 12, 9, 2, 33000.00, 0.0),
(19, 13, 7, 1, 55000.00, 8.0),
(20, 13, 3, 4, 12000.00, 0.0),
(21, 14, 1, 1, 45000.00, 0.0),
(22, 15, 10,1, 75000.00, 5.0),
(23, 15, 6, 1, 28000.00, 0.0),
(24, 16, 2, 1, 62000.00, 10.0),
(25, 17, 4, 2, 38000.00, 5.0),
(26, 18, 5, 1, 95000.00, 0.0),
(27, 19, 8, 2, 42000.00, 0.0),
(28, 20, 9, 1, 33000.00, 5.0),
(29, 20, 3, 6, 12000.00, 0.0),
(30, 21, 1, 2, 45000.00, 8.0),
(31, 21, 7, 1, 55000.00, 0.0),
(32, 22, 6, 1, 28000.00, 0.0),
(33, 23, 10,1, 75000.00, 5.0),
(34, 23, 2, 1, 62000.00, 0.0),
(35, 24, 4, 1, 38000.00, 5.0),
(36, 24, 9, 2, 33000.00, 0.0),
(37, 25, 5, 1, 95000.00, 8.0),
(38, 26, 8, 1, 42000.00, 5.0),
(39, 26, 3, 3, 12000.00, 0.0),
(40, 27, 1, 1, 45000.00, 0.0),
(41, 27, 7, 1, 55000.00, 5.0),
(42, 28, 2, 1, 62000.00, 0.0),
(43, 29, 6, 2, 28000.00, 0.0),
(44, 30, 10,1, 75000.00, 10.0),
(45, 30, 4, 1, 38000.00, 0.0),
(46, 31, 5, 1, 95000.00, 5.0),
(47, 31, 9, 2, 33000.00, 5.0),
(48, 32, 8, 1, 42000.00, 0.0),
(49, 32, 3, 5, 12000.00, 0.0),
(50, 33, 1, 2, 45000.00, 8.0),
(51, 34, 7, 1, 55000.00, 0.0),
(52, 34, 2, 1, 62000.00, 5.0),
(53, 35, 10,1, 75000.00, 0.0),
(54, 35, 6, 1, 28000.00, 0.0),
(55, 36, 4, 2, 38000.00, 5.0),
(56, 36, 9, 1, 33000.00, 0.0),
(57, 37, 5, 1, 95000.00, 8.0),
(58, 37, 3, 4, 12000.00, 0.0),
(59, 38, 8, 1, 42000.00, 0.0),
(60, 39, 1, 1, 45000.00, 5.0),
(61, 39, 7, 1, 55000.00, 0.0),
(62, 40, 2, 1, 62000.00, 10.0),
(63, 40, 10,1, 75000.00, 5.0),
(64, 41, 4, 1, 38000.00, 0.0),
(65, 41, 6, 2, 28000.00, 5.0),
(66, 42, 5, 1, 95000.00, 0.0),
(67, 42, 9, 2, 33000.00, 5.0),
(68, 43, 8, 1, 42000.00, 8.0),
(69, 43, 3, 6, 12000.00, 0.0),
(70, 44, 1, 2, 45000.00, 5.0),
(71, 44, 7, 1, 55000.00, 0.0),
(72, 45, 10,1, 75000.00, 5.0),
(73, 45, 2, 1, 62000.00, 0.0);
