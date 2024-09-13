CREATE TABLE countries (
   
	country_code varchar(3),
	country_name varchar(50)
);

ALTER TABLE countries
rename  TO continents;

CREATE TABLE per_capita (
   	country_code varchar(3),
	year date,
	gdp_per_capita numeric(10,2)
	
);

select* from countries;
select* from per_capita;
select* from continents;
select* from continent_map;
truncate table  continent_map;

-- ALTER TABLE employees
-- RENAME COLUMN first_name TO given_name;

-- ALTER TABLE table_name
-- ALTER COLUMN column_name
-- SET DATA TYPE new_data_type;

-- Drop the Existing Check Constraint:
-- ALTER TABLE employees
-- DROP CONSTRAINT employees_salary_check;

-- Add a New Check Constraint:
-- ALTER TABLE employees
-- ADD CONSTRAINT check_salary_positive CHECK (salary > 0);

--Add New Primary Key:
-- ALTER TABLE table_name
-- ADD CONSTRAINT new_constraint_name PRIMARY KEY (column_name);


ALTER TABLE continent_map
ALTER COLUMN country_code
SET DATA TYPE varchar(3);

ALTER TABLE continent_map
ALTER COLUMN continent_code
SET DATA TYPE varchar(3);

select* from countries;
select* from per_capita;
select* from continents;
select* from continent_map;

ALTER TABLE per_capita
ALTER COLUMN year TYPE integer USING EXTRACT(YEAR FROM year)::integer;



ALTER TABLE continent_map
ALTER COLUMN country_code TYPE VARCHAR(10);

ALTER TABLE continent_map
ALTER COLUMN continent_code TYPE VARCHAR(10);

ALTER TABLE countries
ALTER COLUMN country_name TYPE VARCHAR(70);

ALTER TABLE continents
rename COLUMN continent_code to continent_name;
ALTER TABLE continents
rename COLUMN country_code to continent_code;

ALTER TABLE continents
ALTER COLUMN continent_name TYPE VARCHAR(70);

UPDATE continent_map
    SET
    country_code = CASE country_code WHEN '' THEN NULL ELSE country_code END,
    continent_code = CASE continent_code WHEN '' THEN NULL ELSE continent_code END;

/* Select Statement To Pull Up Duplicate Country Codes, FOO on top*/
with cte as(
SELECT 
    COALESCE(country_code, 'FOO') AS country_code,
    CASE 
        WHEN COALESCE(country_code, 'FOO') = 'FOO' THEN 0
        ELSE 1
    END AS sort_order
FROM
    continent_map
GROUP BY 
    country_code
HAVING 
    COUNT(*) > 1

UNION 

SELECT 
    'FOO' AS country_code,
    0 AS sort_order
WHERE 
    EXISTS (
        SELECT 1
        FROM continent_map
        WHERE country_code IS NULL
    )

ORDER BY 
    sort_order,
    country_code)
	select country_code 
	from cte;

-- -------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
 -- BY DEFAULT SCHEMA IS PUBLIC
------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
/* Replace '' empty strings with NULL*/
 -- not used in postgre sql
-- VERIFY
UPDATE continent_map
    
SET
    country_code = CASE country_code WHEN '' THEN NULL ELSE country_code END,
    continent_code = CASE continent_code WHEN '' THEN NULL ELSE continent_code END;
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
---------------------------------------START---------------------------------------------------------

/*                                     PART2 - Q1                 */


/*A temporary table with a new column ID as a row_number on the table after order by contry_code, continent_code*/
    CREATE TABLE t1 AS
    SELECT row_number() over (order by country_code, continent_code asc) as ID,country_code
      ,continent_code
   	FROM continent_map ;
	 SELECT * FROM T1
     CREATE TABLE t2 AS Select MIN(ID) as ID from t1 group by country_code ;
 
/*Delete the rows that dont have a min ID number after group by country_code*/
    Delete From t1 where ID NOT IN(select ID from t2) ;

/*Reset continent_map table*/
	Delete From continent_map;

/*Refill continent_map from temp_table*/
	insert into continent_map
  	select country_code, continent_code from t1;
 
/*drop temporary tables*/
 	DROP TABLE t1;
 	DROP TABLE t2;
       SELECT * FROM continent_map

/*                                   Another method            */
-- Defining  CTE to identify duplicates
WITH cte AS (
    SELECT
        ctid,  -- Here ROW_NUMBER() is unique row identifier 
        ROW_NUMBER() OVER (PARTITION BY country_code ORDER BY country_code,continent_code) AS rn
    FROM
        continent_map
)

-- Delete rows that are duplicates
DELETE FROM continent_map
WHERE country_code IN (
    SELECT country_code
    FROM cte
    WHERE rn > 1
);


