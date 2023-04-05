
/*
SQL Exploratory Data Analysis (EDA)
Dataset - Created in script
Skills demonstrated - WINDOW FUNCTIONS ROW_NUMBER(), RANK(), DENSE_RANK(), LEAD(), LAG(),
						FIRST_VALUE(), LAST_VALUE(), NTH_VALUE(), NTILE(), PERCENT_RANK(), 
                        CUME_DIST(), FRAME CLAUSE

*/

-- drop table employee;
create table employee
( emp_ID int
, emp_NAME varchar(50)
, DEPT_NAME varchar(50)
, SALARY int);

insert into employee values(100, 'Rashmi', 'R&D', 8000);
insert into employee values(101, 'John', 'Admin', 4000);
insert into employee values(102, 'Laura', 'HR', 3000);
insert into employee values(103, 'Akbar', 'IT', 4000);
insert into employee values(104, 'Dorvin', 'Finance', 6500);
insert into employee values(105, 'Rohit', 'HR', 3000);
insert into employee values(106, 'Emanual',  'Finance', 5000);
insert into employee values(107, 'Alan', 'HR', 7000);
insert into employee values(108, 'Bill', 'Admin', 4000);
insert into employee values(109, 'Joe', 'IT', 6500);
insert into employee values(110, 'Donald', 'IT', 7000);
insert into employee values(111, 'Melinda', 'IT', 8000);
insert into employee values(112, 'Komal', 'IT', 10000);
insert into employee values(113, 'Raj', 'Admin', 2000);
insert into employee values(114, 'Leonerd', 'HR', 3000);
insert into employee values(115, 'Howard', 'IT', 4500);
insert into employee values(116, 'Penny', 'Finance', 6500);
insert into employee values(117, 'Sheldon', 'HR', 3500);
insert into employee values(118, 'Chandler', 'Finance', 5500);
insert into employee values(119, 'Ross', 'HR', 8000);
insert into employee values(120, 'Monica', 'Admin', 5000);
insert into employee values(121, 'Rosalin', 'IT', 6000);
insert into employee values(122, 'Rachel', 'IT', 8000);
insert into employee values(123, 'Sean', 'IT', 8000);
insert into employee values(124, 'Aife', 'IT', 11000);
COMMIT;

-- DROP TABLE product;
CREATE TABLE product
( 
    product_category varchar(255),
    brand varchar(255),
    product_name varchar(255),
    price int
);

INSERT INTO product VALUES
('Phone', 'Apple', 'iPhone 12 Pro Max', 1300),
('Phone', 'Apple', 'iPhone 12 Pro', 1100),
('Phone', 'Apple', 'iPhone 12', 1000),
('Phone', 'Samsung', 'Galaxy Z Fold 3', 1800),
('Phone', 'Samsung', 'Galaxy Z Flip 3', 1000),
('Phone', 'Samsung', 'Galaxy Note 20', 1200),
('Phone', 'Samsung', 'Galaxy S21', 1000),
('Phone', 'OnePlus', 'OnePlus Nord', 300),
('Phone', 'OnePlus', 'OnePlus 9', 800),
('Phone', 'Google', 'Pixel 5', 600),
('Laptop', 'Apple', 'MacBook Pro 13', 2000),
('Laptop', 'Apple', 'MacBook Air', 1200),
('Laptop', 'Microsoft', 'Surface Laptop 4', 2100),
('Laptop', 'Dell', 'XPS 13', 2000),
('Laptop', 'Dell', 'XPS 15', 2300),
('Laptop', 'Dell', 'XPS 17', 2500),
('Earphone', 'Apple', 'AirPods Pro', 280),
('Earphone', 'Samsung', 'Galaxy Buds Pro', 220),
('Earphone', 'Samsung', 'Galaxy Buds Live', 170),
('Earphone', 'Sony', 'WF-1000XM4', 250),
('Headphone', 'Sony', 'WH-1000XM4', 400),
('Headphone', 'Apple', 'AirPods Max', 550),
('Headphone', 'Microsoft', 'Surface Headphones 2', 250),
('Smartwatch', 'Apple', 'Apple Watch Series 6', 1000),
('Smartwatch', 'Apple', 'Apple Watch SE', 400),
('Smartwatch', 'Samsung', 'Galaxy Watch 4', 600),
('Smartwatch', 'OnePlus', 'OnePlus Watch', 220);
COMMIT;

select * from employee;

 -- Aggregate function over a window

 -- Display max salary of each department along with all employee information

select *, max(salary) over(partition by DEPT_NAME) as max_salary
from employee;

-- Row_number()

-- Fetch the first two employees in each department (assumption - emp_ID is assigned chronologically)

select x.* from (
select e.*, row_number() over(partition by DEPT_NAME order by emp_ID) as rn 
from employee e) x
where x.rn<3;

-- RANK()

-- Fetch all employees in each department earning the max top 3 salaries.

select * from
(select e.*, dense_rank() over(partition by DEPT_NAME order by SALARY desc) as dns_rnk 
from employee e) x
where x.dns_rnk<4;

-- Difference between rank() and dense_rank()
select *,
	rank() over(partition by DEPT_NAME order by SALARY desc) as rnk ,
    dense_rank() over(partition by DEPT_NAME order by SALARY desc) as dns_rnk 
from employee e;

-- LAG()
-- Display if the salary of each employee is higher, lower or equal to the previous employee in their department.

Select e.*, 
	lag(SALARY) over(partition by DEPT_NAME order by emp_ID) as prv_sal,
    case when lag(SALARY) over(partition by DEPT_NAME order by emp_ID) > SALARY then 'Lower than previous'
		when lag(SALARY) over(partition by DEPT_NAME order by emp_ID) < SALARY then 'Higher than previous'
		when lag(SALARY) over(partition by DEPT_NAME order by emp_ID) = SALARY then 'Equal to previous'
		else 'Comparison not possible'
    end as Comparison
from employee e; 

-- LEAD()
-- Display if the salary of each employee is higher, lower or equal to the following employee in their department
select e.* ,
	lead(SALARY) over(partition by DEPT_NAME order by emp_ID) as nxt_sal,
    case when lead(SALARY) over(partition by DEPT_NAME order by emp_ID) > SALARY then 'Lower than next'
		when lead(SALARY) over(partition by DEPT_NAME order by emp_ID) < SALARY then 'Higher than next'
        when lead(SALARY) over(partition by DEPT_NAME order by emp_ID) = SALARY then 'Equal to next'
        else 'Comparison not possible' 
	end as Comparison
from employee e;


select * from product;

-- FIRST_VALUE

-- Write query to display the most expensive product under each category (corresponding to each record)
SELECT *,
	first_value(product_name) OVER(partition by product_category order by price desc) as most_expensive_product
from product;

-- FIRST_VALUE, LAST_VALUE and NTH_VALUE
-- FRAME CLAUSE changed from default "range between unbounded preceding and current row"
-- to "range between unbounded preceding and unbounded following" to get the correct output

-- Write query to display the least, most, and second most expensive product under each category (corresponding to each record)
select	*,
	LAST_VALUE(product_name) over w as least_expensive_product,
	FIRST_VALUE(product_name) over w as most_expensive_product,
	nth_value(product_name,2) over w as second_most_expensive
from product
window w as (partition by product_category order by price desc
            range between unbounded preceding and unbounded following);


-- NTILE
-- Write a query to segregate all the expensive phones, mid range phones and the cheaper phones.

select * ,
	case when x.bckts = 1 then 'Expensive'
		when x.bckts = 2 then 'Mid range'
        when x.bckts = 3 then 'Cheap'
	end as Price_range
from
(select *,
	ntile(3) over(order by price desc) as bckts
from product
where product_category = 'Phone') x;


-- CUME_DIST (cumulative distribution) ; 
/*  Formula = Current Row no (or Row No with value same as current row) / Total no of rows */

-- Query to fetch all products which are constituting the first 30% 
-- of the data in products table based on price.
Select product_name, percent_cd
from (select *,
    cume_dist() over (order by price desc) as cume_distribution,
    round(cume_dist() over (order by price desc) * 100,2) as percent_cd
from product) x
where x.percent_cd<=30;

-- PERCENT_RANK (relative rank of the current row / Percentage Ranking)
/* Formula = Current Row No - 1 / Total no of rows - 1 */

-- Query to identify how much percentage more expensive is "Galaxy Z Fold 3" when compared to 
-- all products.
select product_name, per
from (
    select *,
    percent_rank() over(order by price) ,
    round(percent_rank() over(order by price) * 100, 2) as per
    from product) x
where x.product_name='Galaxy Z Fold 3';

