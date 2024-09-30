#### Environment ####
library("RSQLite")
library("ggplot2")
setwd("/Users/mac/Documents/Introduction_to_R/RSQLite")

conn <- dbConnect(RSQLite::SQLite(), "weather_stations.db")
dbListTables(conn)
dbGetQuery(conn, "SELECT * FROM STATION_DATA LIMIT 10")

#####

# Note:
# GROUP 和 CASE 两章都没有对原始database做修改

#### Group & Order ####
# Record Count
dbGetQuery(conn, "SELECT COUNT(*) AS
           record_count FROM station_data")
dbGetQuery(conn, "SELECT COUNT(*) AS
           record_count FROM station_data
           WHERE tornado = 1")
dbGetQuery(conn, "SELECT year, COUNT(*) AS
           record_count FROM station_data
           WHERE tornado = 1
           GROUP BY year")
# Further slice our data
dbGetQuery(conn, "SELECT year, month, COUNT(*) AS
           record_count FROM station_data
           WHERE tornado = 1
           GROUP BY year, month")
# Order Records
dbGetQuery(conn, "SELECT year, month, 
           COUNT(*) AS record_count 
           FROM station_data
           WHERE tornado = 1
           GROUP BY year, month
           ORDER BY year DESC, month DESC") #DESC: from latest to earlier

# Aggregate Functions
# count: count non-null value number in a column
dbGetQuery(conn, "select count(snow_depth)
           as recorded_snow_depth_count
           from station_data")
# side note: cap does not matter really. But for convetion, maybe still 
# use them. 
# avg (average)
dbGetQuery(conn, "SELECT month, 
           round(AVG(temperature), 2) AS avg_temp
           FROM station_data
           WHERE year >= 2000
           GROUP BY month") # take average and round them
# more than one 
dbGetQuery(conn, "SELECT year, 
           SUM(precipitation) AS tornado_precipitation 
           FROM station_data
           WHERE tornado = 1 AND year >= 2000
           GROUP BY year
           ORDER BY year DESC")

# HAVING statement
# filter aggregated fields (the aggregated equivalent to WHERE)
dbGetQuery(conn, 
           "SELECT year, 
           SUM (precipitation) AS total_precipitation 
           FROM station_data
           GROUP BY year
           HAVING total_precipitation > 30")

# Get Distinct records
dbGetQuery(conn, 
           "SELECT DISTINCT station_number, year
           FROM station_data
           ORDER BY year DESC
           LIMIT 100
           ")
#####


#### CASE ####
# swap a column value for another value based on conditions
dbGetQuery(conn, 
           "SELECT report_code, year, month, day, wind_speed,
           
           CASE
           WHEN wind_speed >= 40 THEN 'high'
           WHEN wind_speed >= 30 THEN 'moderate'
           ELSE 'low'
           END AS wind_severity
           
           FROM station_data
           ORDER BY year DESC, month DESC, day DESC")
# Note: CASE is read from top to bottom, so >= 40 are already picked
# away when reading for >= 30

# group CASE statement
dbGetQuery(conn, 
           "SELECT year, 
           
           CASE 
           WHEN wind_speed >= 40 THEN 'high'
           WHEN wind_speed >= 30 THEN 'moderate'
           ELSE 'low'
           END AS wind_severity,
           
           COUNT(*) AS record_count
           
           FROM station_data
           GROUP BY year, wind_severity
           ORDER BY year DESC")

# Trick: apply different "filters" for different aggregate values
# in a single SELECT query 
dbGetQuery(conn,
           "SELECT year, month, 
           
           SUM(CASE WHEN tornado = 1 THEN precipitation ELSE 0 END)
           AS tornado_precipitation,
           
           SUM(CASE WHEN tornado = 0 THEN precipitation ELSE 0 END)
           AS non_tornado_precipitation
           
           FROM station_data
           WHERE year >= 2000
           GROUP BY year, month
           ORDER BY year DESC, month DESC") #龙卷风降水和非龙降水

dbGetQuery(conn, 
           "SELECT month, 
           
           AVG(CASE WHEN rain OR hail THEN temperature ELSE null END)
           AS avg_precipitation_temp,
           
           AVG(CASE WHEN NOT (rain OR hail) THEN temperature ELSE null END)
           AS avg_non_precipitation_temp
           
           FROM station_data
           WHERE year >= 2000
           GROUP BY month
           ORDER BY month") #降雨平均气温与不降雨平均气温

#####


dbDisconnect(conn)


