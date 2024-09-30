#### Load the RSQLite Library ####
install.packages("RSQLite")
library(RSQLite)

# Load the mtcars as an R data frame put the row names as a column, 
# and print the data("mtcars")
mtcars$car_name <- rownames(mtcars)
rownames(mtcars) <- c()
head(mtcars)

# Create a connection to our new database, CarsDB.db
# you can check that the .db file has 
# been created on your working directory
conn <- dbConnect(RSQLite::SQLite(), "CarsDB.db")
#####


#### Create a table inside our database ####
dbWriteTable(conn, "cars_data", mtcars)
# 三个参：
# connection to database; name of our table; data inserted in the table

# List all tables in the database 
dbListTables(conn)
#####


#### Append data with loop ####
# Data frame 1
car <- c('Camaro', 'California', 'Mustang', 'Explorer')
make <- c('Chevrolet','Ferrari','Ford','Ford')
df1 <- data.frame(car,make)
# Data frame 2
car <- c('Corolla', 'Lancer', 'Sportage', 'XE')
make <- c('Toyota','Mitsubishi','Kia','Jaguar')
df2 <- data.frame(car,make)
# Append these two
dfList <- list(df1, df2)
for (k in 1:length(dfList)){
  dbWriteTable(conn, "Cars_and_Makes", dfList[[k]], append = T)
}
dbListTables(conn)

# Check data in table
dbGetQuery(conn, "SELECT * FROM Cars_and_Makes")
#####


#### Executing SQL Queries ####
# With RSQLite, we can execute almost any query that is valid for SQLite
# Example: Get first 10 rows
dbGetQuery(conn, "SELECT * FROM cars_data LIMIT 10")
# Example: Select items satisfying certain conditions
dbGetQuery(conn, "SELECT car_name, hp, cyl FROM cars_data
           WHERE cyl = 8")
# Example: "Or" condtion 以及 模糊搜索
dbGetQuery(conn, "SELECT car_name, hp, cyl FROM cars_data
           WHERE car_name LIKE 'M%' AND cyl IN (6,8)")
# Example: 
# Get the average horsepower and mpg by number of cylinder groups
dbGetQuery(conn, "SELECT cyl, AVG(hp) AS 'average_hp', 
           AVG(mpg) AS 'average_mpg' FROM cars_data
           GROUP BY cyl
           ORDER BY average_hp")


# Store query result 
avg_HpCyl <- dbGetQuery(conn, "SELECT cyl, AVG(hp) AS 'average_hp', 
           AVG(mpg) AS 'average_mpg' FROM cars_data
           GROUP BY cyl
           ORDER BY average_hp")
avg_HpCyl
class(avg_HpCyl) # Note: stored as data.frame
#####


#### Parameterised Queries ####
# The ability to gather variables in R workspace and use them to 
# query our SQLite database

# Example: want to find cars satisfying certain conditions
mpg <- 18
cyl <- 6
Result <- dbGetQuery(conn, 
                     "SELECT car_name, mpg, cyl 
                     FROM cars_data
                     WHERE mpg >= ? AND cyl >= ?",
                     params = c(mpg, cyl))
Result
# Can even define a function for this query
mpg_cyl_check <- function(mpg, cyl){
  # function finding cars with mpg and cyl larger than certain amount
  Result <- dbGetQuery(conn, 
                       "SELECT car_name, mpg, cyl 
                     FROM cars_data
                     WHERE mpg >= ? AND cyl >= ?",
                       params = c(mpg, cyl))
  Result
}
mpg_cyl_check(mpg = 16, cyl = 8)
# We can check the usage of our function by calling its name
mpg_cyl_check


# More mature example of SQLite function 
assembleQuery <- function(conn, base, search_parameters){
  # Note:
  {
  # search_parameters are left for filling in numbers
  # base is for original wordings of the query 
  parameter_names <- names(search_parameters)
  partial_queries <- ""
  }
  
  # Iterate over all the parameters to assemble the query 
  {
  for (k in 1: length(parameter_names)){
    filter_k <- paste(parameter_names[k], " >= ? ")
    # If there is more than 1 parameter, add an AND statement before
    # the parameter name and placeholder 
    if (k > 1){
      filter_k <- paste("AND ", parameter_names[k], " >= ?")
    }
    partial_queries <- paste(partial_queries, filter_k)
  }
  }
  
  # Paste all together into a single query using a WHERE statement
  final_paste <- paste(base, " WHERE", partial_queries)
  
  # Print the assembled query to show how it looks like
  print(final_paste)
  
  # Run the final query. 
  {
  # I unlist the values from the search_parameters list 
  # into a vector since it is needed
  # when using various anonymous placeholders (i.e. >= ?)
  values <- unlist(search_parameters, use.names = F)
  result <- dbGetQuery(conn, final_paste, params = values)
  return(result)
  }
}

assembleQuery

words <- "SELECT car_name, mpg, hp, wt FROM cars_data"
para <- list("mpg" = 16, 
            "hp" = 150,
            "wt" = 2.1)
result <- assembleQuery(conn = conn,
                        base = words,
                        search_parameters = para)
#####


#### Editing Queries (which do not return data) ####
# Delete
# first show first ten rows of table
dbGetQuery(conn, "SELECT * FROM cars_data LIMIT 10")
# delete column for Mazda RX4.
dbExecute(conn, "DELETE FROM cars_data WHERE
          car_name = 'Mazda RX4'")
# check first ten rows again: delete succeeded 
dbGetQuery(conn, "SELECT * FROM cars_data LIMIT 10")

# Insert
dbExecute(conn, 
"INSERT INTO cars_data VALUES 
(21.0,6,160.0,110,3.90,2.620,16.46,0,1,4,4,'Mazda RX4')")
# Check again 
dbGetQuery(conn, "SELECT * FROM cars_data") # appears at the tail 
#####


#### Close database ####
# Close the database connection to CarsDB
dbDisconnect(conn)
#####
