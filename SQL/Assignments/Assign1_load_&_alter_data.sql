-- Load the given dataset into snowflake with a primary key to Order Date column.

CREATE OR REPLACE TABLE SALES_DATA (
	ORDER_ID VARCHAR(20),
	ORDER_DATE DATE PRIMARY KEY,
	SHIP_DATE DATE,
	SHIP_MODE VARCHAR(20),
	CUSTOMER_NAME VARCHAR(40),
	SEGMENT VARCHAR(15),
	STATE VARCHAR(40),
	COUNTRY VARCHAR(50),
	MARKET VARCHAR(10),
	REGION VARCHAR(15),
	PRODUCT_ID VARCHAR(20),
	CATEGORY VARCHAR(15),
	SUB_CATEGORY VARCHAR(15),
	PRODUCT_NAME VARCHAR(16777216),
	SALES NUMBER(10),
	QUANTITY NUMBER(38,0),
	DISCOUNT NUMBER(2,2),
	PROFIT NUMBER(10,2),
	SHIPPING_COST NUMBER(10,2),
	ORDER_PRIORITY VARCHAR(10),
	YEAR VARCHAR(5)
);

DESCRIBE TABLE SALES_DATA;

SELECT * FROM SALES_DATA;


-- 1. SET PRIMARY KEY TO ORDER_ID.

ALTER TABLE SALES_DATA
DROP PRIMARY KEY;

ALTER TABLE SALES_DATA
ADD PRIMARY KEY (ORDER_ID);



-- 2. Create a new column called order_extract and extract the number after the last ‘–‘from Order ID column.


------------- I tried to use SUBSTRING_INDEX FUNCTION but that doesn't work on snowflake so its alternative is SPLIT_PART FUNCTION. --------------

SELECT SPLIT_PART(ORDER_ID, '-', -1) AS ORDER_EXTRACT FROM SALES_DATA;



-- 3. FLAG ,IF DISCOUNT IS GREATER THEN 0 THEN  YES ELSE FALSE AND PUT IT IN NEW COLUMN FOR EVERY ORDER ID.

SELECT DISCOUNT,
    CASE
    WHEN DISCOUNT > 0 THEN 'YES'
    ELSE 'FALSE'
    END AS DISCOUNT_FLAG
FROM SALES_DATA;



-- 4. Create a new column called process days and calculate how many days it takes for each order id to process from the order to its shipment.

ALTER TABLE SALES_DATA
ADD PROCESS_DAY INT;

UPDATE SALES_DATA    
SET PROCESS_DAY = DATEDIFF('DAY', ORDER_DATE, SHIP_DATE);



-- 5. Create a new column called Rating and then based on the Process dates give rating like given below.
    -- a. If process days less than or equal to 3days then rating should be 5
    -- b. If process days are greater than 3 and less than or equal to 6 then rating should be 4
    -- c. If process days are greater than 6 and less than or equal to 10 then rating should be 3
    -- d. If process days are greater than 10 then the rating should be 2.

ALTER TABLE SALES_DATA
ADD RATING VARCHAR();

UPDATE SALES_DATA    
SET RATING = (CASE
                WHEN PROCESS_DAY <= 3 THEN '5'
                WHEN PROCESS_DAY <= 6 AND PROCESS_DAY > 3 THEN '4'
                WHEN PROCESS_DAY < 10 AND PROCESS_DAY > 6 THEN '3'
                ELSE '2'
              END);