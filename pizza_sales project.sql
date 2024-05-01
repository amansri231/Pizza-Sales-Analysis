
-- BASIC
/* Retrieve the total number of orders placed. */
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
/* The total number of pizza orders placed is 21350. */

/* Calculate the total revenue generated from pizza sales. */
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
/* Total revenue generated from the pizza sales is 817860.05 */

/* Identify the highest-priced pizza. */
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;
/* The highest-priced pizza is "The Greek Pizza" having a price of 35.95 */

/* Identify the most common pizza size ordered. */
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS Order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY Order_count DESC;
/* The most common pizza size ordered is of "L" size having an order quantity of 18526. */

/* List the top 5 most ordered pizza types along with their quantities. */
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;
/* The top 5 most ordered pizza types are "The Classic Deluxe Pizza, The Barbecue Chicken Pizza,
The Hawaiian Pizza, The Pepperoni Pizza, and The Thai Chicken Pizza in their quantities
2453, 2432, 2422, 2418, and 2371 respectively. Since the maximum quantity ordered pizza is "The
Classic Deluxe Pizza" with quantity 2453.*/

-- INTERMEDIATE
/* Join the necessary tables to find the total quantity of each pizza category ordered. */
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;
/* The total quantity of the pizza categories i.e., Classic, Supreme, Veggie, and Chicken ordered
is 14888, 11987, 11649, and 11050 respectively. Since we can understand that people are referring
to classic over other pizza categories. */

/* Determine the distribution of orders by hour of the day. */
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);
/* The maximum orders being placed in the afternoon i.e. around 12 to 1 PM and in the evening i.e.
5 to 7 PM time. Hence, we can say that these are the busiest hours when the maximum number of orders
are sent. */

/* Join relevant tables to find the category-wise distribution of pizzas. */
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;
/* The distribution of Chicken, Classic, Supreme, and Veggie pizzas are 6,8,9, and 9 respectively. */

/* Group the orders by date and calculate the average number of pizzas ordered per day. */
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity
/* The average number of pizzas ordered per day is 138 */

/* Determine the top 3 most ordered pizza types based on revenue. */
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;
/* The top 3 most ordered pizzas based on revenue are The Thai Chicken Pizza, The Barbecue Chicken Pizza,
The California Chicken Pizza has revenues of 43434.25, 42768, and 41409.5 respectively.

- From here, we can conclude that the most ordered pizza is Classic Pizza but the pizza generating the maximum
revenue is The Thai Chicken Pizza. */

-- ADVANCED
/* Calculate the percentage contribution of each pizza type to total revenue. */
SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id)) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;
/* The percentage contribution of Classic, Supreme, Chicken, and Veggie pizzas
to total revenue are 26.91, 25.46, 23.96, and 23.68 respectively. */

/* Analyze the cumulative revenue generated over time. */
select order_date,
sum(revenue) over (order by order_date) as cum_revenue
from 
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas on
 order_details.pizza_id=pizzas.pizza_id
join orders on
 orders.order_id=order_details.order_id
 group by orders.order_date) as sales;
/* The cumulative revenue generated over time increases along with order date. */

/* Determine the top 3 most ordered pizza types based on revenue for each pizza category. */
select name, revenue from 
(select category, name, revenue, rank() over (partition by category order by revenue
desc) as rn from 
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn<=3
;



