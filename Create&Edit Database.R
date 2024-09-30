#### Note: ####
# structure: schema (database) > table > 
# field (column of table) > object (cell of table)

# Normalisation:
# Different type of data should be stored in different tables.
# Ideally, in each single table, there should not be repetitive data
# For example, if you record all customer information 
# with every order record, then customer information like address will be 
# repeated unnecessarily. Hence a customer id is enough.

# Think carefully when designing database:
# 1. normalisation of tables
# 2. columns for each table
# 3. update data (sometimes Python scripts maybe needed)
# 4. Security (especially if you are doing websites)

#####

#### Environment ####
library("RSQLite")
library("ggplot2")
setwd("/Users/mac/Documents/Introduction_to_R/(R)SQLite")

conn <- dbConnect(RSQLite::SQLite(), "surgetech_conference.db")
# this function will create a new database if the database you 
# are referring to does not exist

#####


#### Notes on Keys ####

# Primary Key 
# You should always strive to have a primary key on any table. 
# A primary key is a spe‐ cial field (or combination of fields) 
# that provides a unique identity to each record
# 1. More effective query execution 
# 2. No duplicate allowed

# Foreign Key 
# 1. primary key exists in the parent table, 
# but the foreign key exists in the child table
# 2. foreign key in a child table points to 
# the primary key in its parent table
# 3. The primary key and foreign key 
# do not have to share the same field name

#####


#### Create a new database ####
# Create Fileds
{
dbExecute(conn, 
           "CREATE TABLE company (
           company_id INTEGER 
           PRIMARY KEY AUTOINCREMENT,
           
           name VARCHAR(30) NOT NULL,
           description VARCHAR(60),
           primary_contact_attendee_id INTEGER NOT NULL
          )")

dbExecute(conn,
          "CREATE TABLE presentation(
          presentation_id INTEGER 
          PRIMARY KEY AUTOINCREMENT,
          
          booked_company_id INTEGER NOT NULL,
          booked_room_id INTEGER NOT NULL,
          start_time TIME,
          end_time TIME
          
          )")

dbExecute(conn,
          "CREATE TABLE room(
          room_id INTEGER 
          PRIMARY KEY AUTOINCREMENT,
          
          floor_number INTEGER NOT NULL,
          seat_capacity INTEGER NOT NULL
          )")

dbExecute(conn, 
          "CREATE TABLE Attendee (
ATTENDEE_ID INTEGER PRIMARY KEY AUTOINCREMENT, 
FIRST_NAME VARCHAR (30) NOT NULL,
LAST_NAME  VARCHAR (30) NOT NULL,
PHONE INTEGER,
EMAIL VARCHAR (30),
VIP BOOLEAN DEFAULT (0)
          )")
          
dbExecute(conn, "
          CREATE TABLE presentation_attendance (
          ticket_id INTEGER PRIMARY KEY AUTOINCREMENT,
          presentation_id INTEGER,
          attendee_id INTEGER)")
}

# Create table is length, but easy.
# Create foreign key is tedious, so do it with SQLite Studio
# (To start with, you have to create a temporary table as bridge,
# as SQLite only allows foreign key creation when creating new table)

dbGetQuery(conn, "SELECT * FROM company")

dbExecute(conn, "DROP TABLE sqlite_sequence")

dbListTables(conn)

# Create View
# View: a query stored in the database
dbExecute(conn,
          "CREATE VIEW presentation_vw AS
          SELECT company.name as booked_company,
          room.room_id as room_number,
          room.seat_capacity as seats,
          start_time,
          end_time
          
          FROM presentation 
          
          INNER JOIN company 
          ON presentation.booked_company_id = company.company_id
          
          INNER JOIN room
          ON presentation.booked_room_id = room.room_id ")

dbExecute(conn, "DROP VIEW presentation_vw")

# Remark:
# We can query from a view just like it is a table
dbGetQuery(conn,
           "SELECT * FROM presentation_vw
           ")
#####

# Likely we will never create new database manually
# Often, they will be downloaded or created with spider 
# Or using RSQLite "dbWriteTable", we can convert data frame into table


#### Manage Database ####
# Insert
dbExecute(conn,
          "INSERT INTO attendee (first_name, last_name) 
          VALUES ('Thomas', 'Nield')")

dbExecute(conn,
          "INSERT INTO attendee 
          (first_name, last_name, phone, email, vip)
          VALUES
          ('Jon', 'Skeeter',4802185842,'john.skeeter@rex.net', 1),
          ('Sam','Scala',2156783401,'sam.scala@gmail.com', 0),
          ('Brittany','Fisher',5932857296,'brittany.fisher@outlook.com', 0)
          ")

# Delete
dbExecute(conn, "DELETE FROM attendee") 
# delete every record in that table
dbExecute(conn, 
          "DELETE FROM attendee
          WHERE phone IS NULL
          AND email IS NULL")
# delete with conditions

# Update
# used to modify existing records
dbExecute(conn, 
          "UPDATE attendee 
          SET first_name = UPPER(first_name),
          last_name = UPPER(last_name) ")
# 名字改大小写
dbExecute(conn,
          "UPDATE attendee SET vip = 1
          WHERE last_name = 'FISHER'")
# update with conditions
#####

dbDisconnect(conn)