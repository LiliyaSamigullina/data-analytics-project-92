--count of customers in sales table
select COUNT(customer_id) as customer_count
from sales;


--1st report - top 10 sellers by income
select
    e.first_name || ' ' || e.last_name as seller,
    COUNT(*) as operations,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by 1
order by 3 desc limit 10;

--2nd report - sellers with income lower than avg
select
    e.first_name || ' ' || e.last_name as seller,
    FLOOR(AVG(s.quantity * p.price)) as average_income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id 
group by 1
having AVG(s.quantity * p.price) < (
    select AVG(s.quantity * p.price)
    from sales as s
    inner join products as p
        on s.product_id = p.product_id
    )
order by 2;

--3rd report - sales by days of week
select
    e.first_name || ' ' || e.last_name as seller,
    TO_CHAR(s.sale_date, 'day') as day_of_week,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by 1, 2, extract(isodow from s.sale_date)
order by extract(isodow from s.sale_date), 1;
