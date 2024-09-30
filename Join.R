#### Environment ####
library("RSQLite")
library("ggplot2")
setwd("/Users/mac/Documents/Introduction_to_R/(R)SQLite")
getwd()

conn <- dbConnect(RSQLite::SQLite(), "rexon_metals.db")
dbListTables(conn)
dbGetQuery(conn, "SELECT * FROM customer LIMIT 10")
dbGetQuery(conn, "SELECT * FROM product LIMIT 10")
#####

# For this note, we only used one-to-many join, 
# which is most common in business 

# Joins allow us to take data scattered across multiple tables 
# and stitch it together into something more meaningful and descriptive

#### Inner Join ####
# merge two tables together for only common terms. 
# any records that do not have a common joined value will be excluded
dbGetQuery(conn, 
           "SELECT order_id, customer.customer_id, 
           order_date, name, 
           street_address, city, state, zip, product_id, order_qty
           
           FROM customer INNER JOIN customer_order 
           ON customer.customer_id = customer_order.customer_id")
# Note
# Customer_id exists in both table, we need explicitly choose one, 
# although exactly which one does not matter.
# Remark
# We store data efficiently through normal‐ ization, 
# but can use joins to merge tables together on common fields 
# to create more descriptive views of the data.
#####


#### Left Join ####
# Very similar to inner join, except that all records are included
dbGetQuery(conn,
           "SELECT customer.customer_id,
           name, street_address, city, state, zip, order_date,
           ship_date, order_id, product_id, order_qty
           
           FROM customer LEFT JOIN customer_order
           ON customer.customer_id = customer_order.customer_id")
# Remark
# customers with no order have null for columns from customer_order 
# Note
# column排序来自最开始select的顺序，与inner join同

# Can further check parent table with no children, 
# or children table with no parent
dbGetQuery(conn, 
           "SELECT customer.customer_id,
           name AS customer_name
           
           FROM customer LEFT JOIN customer_order
           ON customer.customer_id = customer_order.customer_id
           
           WHERE order_id IS NULL")
#####


# Other join type: Right Join and Outer Join
# Rarely used, should be avoided for simplicity and convention 


#### Multiple Tables ####
dbGetQuery(conn, 
           "SELECT order_id, customer.customer_id, name AS customer_name, 
           street_address, city, state, zip, order_date,
           description, order_qty, 
           order_qty * price as revenue
           
           FROM customer
           
           INNER JOIN customer_order
           ON customer_order.customer_id = customer.customer_id
           
           INNER JOIN product
           ON customer_order.product_id = product.product_id")
# Remark: 
# Here we can even multiply order_qty and price to get a new column
# even though they come from different tables


dbGetQuery(conn,
           "SELECT customer.customer_id,
           name as customer_name, 
           sum (order_qty * price) as total_revenue
           
           FROM customer
           
           INNER JOIN customer_order
           ON customer.customer_id = customer_order.customer_id
           
           INNER JOIN product
           ON customer_order.product_id = product.product_id
           
           GROUP BY customer.customer_id, customer_name
           
           ORDER BY total_revenue DESC")
# compute total revenue for each customer 

dbGetQuery(conn,
           "SELECT customer.customer_id,
           name as customer_name, 
           coalesce(sum(order_qty * price), 0) as total_revenue
           
           FROM customer
           
           LEFT JOIN customer_order
           ON customer.customer_id = customer_order.customer_id
           
           LEFT JOIN product
           ON customer_order.product_id = product.product_id
           
           GROUP BY customer.customer_id, customer_name
           
           ORDER BY total_revenue DESC")
# version including customer with no orders
# coalesce() A function turning nulls into a specified value, if 
# not null, then leave the value as it is.

#####

