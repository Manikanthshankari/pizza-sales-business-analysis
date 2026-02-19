USE pizza_hut;

/*KPI SUMMARY*/
/*Total Orders*/
SELECT COUNT(*) AS total_orders
FROM orders;

/*Total Revenue*/
SELECT ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

/*Average Order Value (AOV)*/
SELECT ROUND(SUM(od.quantity * p.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON p.pizza_id = od.pizza_id;

/*Avg Pizzas Per Order*/
SELECT ROUND(SUM(od.quantity) / COUNT(DISTINCT od.order_id), 2) AS avg_pizzas_per_order
FROM order_details od;

/* Revenue Breakdown -Business Insights*/
/*Revenue by Category*/
SELECT pt.category,
ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_revenue DESC;

/*% Contribution by Category (window function)*/
SELECT pt.category,
ROUND(SUM(od.quantity * p.price), 2) AS total_revenue,
ROUND(
100 * SUM(od.quantity * p.price) / SUM(SUM(od.quantity * p.price)) OVER (),
2
) AS pct_of_total
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_revenue DESC;

/*Revenue by Size*/
SELECT p.size,
ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY revenue DESC;

/* Product Performance*/
/*Top 10 Pizzas by Quantity*/
SELECT pt.name,
SUM(od.quantity) AS total_qty
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_qty DESC
LIMIT 10;

/*Top 10 Pizzas by Revenue*/
SELECT pt.name,
ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 10;

/*Top 3 Pizzas within each Category by Revenue (window function)*/
SELECT *
FROM (
SELECT pt.category,
pt.name,
ROUND(SUM(od.quantity * p.price), 2) AS revenue,
DENSE_RANK() OVER (
PARTITION BY pt.category
ORDER BY SUM(od.quantity * p.price) DESC
) AS rnk
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category, pt.name
) x
WHERE rnk <= 3
ORDER BY category, rnk, revenue DESC;

/*Time Analysis (operations + trends)*/
/*Peak Demand: Orders by Hour*/
SELECT HOUR(order_time) AS hr,
COUNT(*) AS total_orders
FROM orders
GROUP BY hr
ORDER BY total_orders DESC;

/*Revenue between 11 AM and 2 PM */
SELECT COUNT(DISTINCT o.order_id) AS orders_11_to_14,
ROUND(SUM(od.quantity * p.price), 2) AS revenue_11_to_14
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON p.pizza_id = od.pizza_id
WHERE o.order_time >= '11:00:00'
AND o.order_time <  '14:00:00';

/*Daily Revenue Trend*/
SELECT o.order_date,
ROUND(SUM(od.quantity * p.price), 2) AS daily_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.order_date
ORDER BY o.order_date;

/*Monthly Revenue Trend*/
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
COUNT(DISTINCT o.order_id) AS orders,
ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON p.pizza_id = od.pizza_id
GROUP BY month
ORDER BY month;

/*Cumulative Revenue (running total – window function*/
SELECT order_date,
daily_revenue,
ROUND(SUM(daily_revenue) OVER (ORDER BY order_date), 2) AS running_revenue
FROM (
SELECT o.order_date,
SUM(od.quantity * p.price) AS daily_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.order_date
) t
ORDER BY order_date;

/* ================================
   END OF ANALYSIS
   Objective: Evaluate sales performance,
   identify revenue drivers, peak demand
   periods, and product trends to support
   pricing and operational decisions.
================================ */



