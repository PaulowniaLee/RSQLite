#### Environment ####
install.packages("mosaic")
install.packages("nycflights13")
install.packages("RSQLite")
require("mosaic")
require("nycflights13")
library(RSQLite)
require(xtable)
require(ggplot2)
#####


#### Import ####
len <- nchar(flights$dep_time)
# substring extract or replace substrings in a character vector
hour <- as.numeric(substring(flights$dep_time, 1, len-2))
min <- as.numeric(substring(flights$dep_time, len-1, len))
# mutate adds new variables to a data frame and preserves existing ones
flights <- mutate(flights, deptime = hour+min/60)
flights <- mutate(flights, realdelay = 
                    ifelse(is.na(arr_delay), 240, arr_delay))
# ifelse(test, yes(return if test is T), no(return if test is F))

# Use database
conn <- dbConnect(RSQLite::SQLite(), "Flights_depart.db")
dbWriteTable(conn, "flights", flights)
dbGetQuery(conn, "SELECT * FROM flights LIMIT 10")
#####

class(flights$time_hour)

#### some tables ####
xtab <- xtable(filter(airports, faa %in% c('SFO', 'OAK', 'SJC')))
# filter: choose rows satisfying certain conditons from a data frame
# Note here we used logic wordings: %in%. faa is column name. 
airportcounts <- flights %>%
  filter(dest %in% c("SFO", "OAK", "SJC")) %>%
  group_by(year, month, dest) %>%
  summarise(count = n())
airportcounts_table <- xtable(filter(airportcounts, month == 1))
remove(airportcounts)
#####


#####
AA_situation <- dbGetQuery(conn, 
          "SELECT dep_delay, arr_delay, realdelay, distance
           FROM flights
           WHERE carrier = 'AA' AND month = 1 AND dep_delay > 60
          ORDER BY distance")

ggplot(data = AA_situation,
    aes(x = distance)) + 
    geom_line(aes(y = realdelay), color = "darkblue")


