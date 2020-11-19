--  1. Create a database called house_price_regression.
create database if not exists house_price_regression;
use house_price_regression;


-- 2. Create a table house_price_data with the same columns as given in the csv file.
-- Please make sure you use the correct data types for the columns.
drop table if exists house_price_data;

CREATE TABLE house_price_regression.house_price_data (
`id` int(64) UNIQUE NOT NULL,
`date` varchar(10) DEFAULT NULL, -- since the format is not YYYY-MM-DD
`bedrooms` int(64) DEFAULT NULL,
`bathrooms` float DEFAULT NULL,
`sqft_living` int(64) DEFAULT NULL,
`sqft_lot` int(64) DEFAULT NULL,
`floors` float DEFAULT NULL,
`waterfront` boolean DEFAULT NULL,
`view` int(64) DEFAULT NULL,
`condition` int(64) DEFAULT NULL,
`grade` int(64) DEFAULT NULL,
`sqft_above` int(64) DEFAULT NULL,
`sqft_basement` int(64) DEFAULT NULL,
`yr_built` year DEFAULT NULL,
`yr_renovated` int(64) DEFAULT NULL, -- not year format because there are 0 values
`zipcode` int(64) DEFAULT NULL,
`lat` float DEFAULT NULL,
`long` float DEFAULT NULL,
`sqft_living15` int(64) DEFAULT NULL,
`sqft_lot15` int(64) DEFAULT NULL,
`price` int(64) DEFAULT NULL,
CONSTRAINT PRIMARY KEY (id)
);

-- 3. Import the data from the csv file into the table
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '/Users/maria/Mid-project/data_mid_bootcamp_project_regression/regression_data_clean.csv'
INTO TABLE house_price_regression.house_price_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- 4. Select all the data from table house_price_data
-- to check if the data was imported correctly
SELECT * FROM house_price_data
ORDER BY id;

-- 5. Use the alter table command to drop the column date from the database,
-- as we would not use it in the analysis with SQL.
-- Select all the data from the table to verify if the command worked.
-- Limit your returned results to 10.
ALTER TABLE house_price_data
DROP COLUMN date;

SELECT * FROM house_price_data
LIMIT 10;

-- 6. Use sql query to find how many rows of data you have.

SELECT COUNT(*) FROM house_price_data;
-- 5469

-- 7. Now we will try to find the unique values in some of the categorical columns:
-- What are the unique values in the column bedrooms?
SELECT DISTINCT bedrooms
FROM house_price_data
ORDER BY bedrooms;

-- What are the unique values in the column bathrooms?
SELECT DISTINCT bathrooms
FROM house_price_data
ORDER BY bathrooms;

-- What are the unique values in the column floors?
SELECT DISTINCT floors
FROM house_price_data
ORDER BY floors;

-- What are the unique values in the column condition?
SELECT DISTINCT `condition`
FROM house_price_data
ORDER BY `condition`;
-- In this case I have to use the quotes in order to avoid an error because of the name 'condition'

-- What are the unique values in the column grade?
SELECT DISTINCT grade
FROM house_price_data
ORDER BY grade;

-- 8. Arrange the data in a decreasing order by the price of the house.
-- Return only the IDs of the top 10 most expensive houses in your data.
SELECT id
FROM house_price_data
ORDER BY price DESC
LIMIT 10;


-- 9. What is the average price of all the properties in your data?
SELECT ROUND(AVG(price),2) as 'Average price'
FROM house_price_data;
-- 551841.4909


-- 10.a) What is the average price of the houses grouped by bedrooms?
-- The returned result should have only two columns, bedrooms and Average of the prices.
-- Use an alias to change the name of the second column. 

SELECT bedrooms, AVG(price) as 'Average price'
FROM house_price_data
GROUP BY bedrooms
ORDER BY bedrooms;


-- b) What is the average sqft_living of the houses grouped by bedrooms?
-- The returned result should have only two columns, bedrooms and Average of the sqft_living.
-- Use an alias to change the name of the second column.
SELECT bedrooms, AVG(sqft_living) as 'Average sqft Living'
FROM house_price_data
GROUP BY bedrooms
ORDER BY bedrooms;


-- c) What is the average price of the houses with a waterfront and without a waterfront?
-- The returned result should have only two columns, waterfront and Average of the prices.
-- Use an alias to change the name of the second column.
SELECT waterfront, AVG(price) as 'Average price'
FROM house_price_data
GROUP BY waterfront;

-- d) Is there any correlation between the columns condition and grade?
-- You can analyse this by grouping the data by one of the variables and then aggregating
--  the results of the other column.Visually check if there is a positive correlation or
-- negative correlation or no correlation between the variables.

SELECT `condition`, AVG(grade) as 'Average grade'
FROM house_price_data
GROUP BY `condition`
ORDER BY `condition`;
-- It is correlated from condition 1 to 3. AS of condition 4 the correlation goes dowsn.

-- 11. One of the customers is only interested in the following houses:
-- Number of bedrooms either 3 or 4
-- Bathrooms more than 3
-- One Floor
-- No waterfront
-- Condition should be 3 at least
-- Grade should be 5 at least
-- Price less than 300000

SELECT * FROM house_price_data
WHERE (bedrooms = 3 OR bedrooms = 4) AND
bathrooms > 3 AND
floors = 1 AND
waterfront = 0 AND
`condition` >= 3 AND
grade >= 5 AND
price < 300000;

-- If all conditions have to be met, there are no houses with those characteristics

-- 12. Your manager wants to find out the list of properties whose prices are twice more than
-- the average of all the properties in the database. Write a query to show them the list of such properties.
--  You might need to use a sub query for this problem.

SELECT * FROM house_price_data
WHERE price >= 2*(
SELECT ROUND(AVG(price),2) FROM house_price_data);

-- 13. Since this is something that the senior management is regularly interested in, create a view of the same query.

DROP VIEW properties_double_avg_price;

CREATE VIEW properties_double_avg_price AS
SELECT * FROM house_price_data
WHERE price >= 2*(
SELECT ROUND(AVG(price),2) FROM house_price_data);

-- 14. Most customers are interested in properties with three or four bedrooms.
-- What is the difference in average prices of the properties with three and four bedrooms?

SELECT B.Average_price4 - A.Average_price3 AS 'Difference in average prices'
FROM (
SELECT ROUND(AVG(price),2) AS Average_price4
FROM house_price_data
WHERE bedrooms = 4) B
CROSS JOIN
(SELECT ROUND(AVG(price),2) AS Average_price3
FROM house_price_data
WHERE bedrooms = 3) A;

-- 15. What are the different locations where properties are available in your database? (distinct zip codes)
SELECT DISTINCT zipcode FROM house_price_data;

-- 16. Show the list of all the properties that were renovated.
SELECT * FROM house_price_data
WHERE yr_renovated != 0;

-- 17. Provide the details of the property that is the 11th most expensive property in your database.
SELECT * FROM (
SELECT *, 
RANK() OVER (ORDER BY price DESC) AS 'Position'
FROM house_price_data
LIMIT 11) a
WHERE Position = 11;

-- Since there the original file had 177 duplicates that 