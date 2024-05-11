--count of customers in sales table
select COUNT(customer_id) as customers_count
from customers;


--top 10 sellers by income
select
    e.first_name || ' ' || e.last_name as seller,
    COUNT(*) as operations,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by e.first_name || ' ' || e.last_name
order by income desc limit 10;

--sellers with income lower than avg
select
    e.first_name || ' ' || e.last_name as seller,
    FLOOR(AVG(s.quantity * p.price)) as average_income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by e.first_name || ' ' || e.last_name
having
    AVG(s.quantity * p.price) < (
        select AVG(s.quantity * p.price)
        from sales as s
        inner join products as p
            on s.product_id = p.product_id
    )
order by average_income;

--sales by days of week
select
    e.first_name || ' ' || e.last_name as seller,
    TO_CHAR(s.sale_date, 'day') as day_of_week,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as p
    on s.product_id = p.product_id
group by
    e.first_name || ' ' || e.last_name,
    TO_CHAR(s.sale_date, 'day'),
    EXTRACT(isodow from s.sale_date)
order by EXTRACT(isodow from s.sale_date), seller;


--age groups
select
    case
        when c.age between 16 and 25 then '16-25'
        when c.age between 16 and 40 then '26-40'
        when c.age > 40 then '40+'
    end
    as age_category,
    COUNT(c.customer_id) as age_count
from customers as c
group by age_category
order by age_category;

--customers by month
select
    TO_CHAR(s.sale_date, 'YYYY-MM') as selling_month,
    COUNT(distinct s.customer_id) as total_customers,
    FLOOR(SUM(s.quantity * p.price)) as income
from sales as s
inner join products as p
    on s.product_id = p.product_id
group by TO_CHAR(s.sale_date, 'YYYY-MM')
order by selling_month;

--special offer
with rn_sales as (
    select
        sales_id,
        ROW_NUMBER() over (partition by customer_id order by sale_date) as rn
    from sales
)
select
    c.first_name || ' ' || c.last_name as customer,
    s.sale_date,
    e.first_name || ' ' || e.last_name as seller
from sales as s
inner join rn_sales as rn_s
    on s.sales_id = rn_s.sales_id
inner join customers as c
    on s.customer_id = c.customer_id
inner join employees as e
    on s.sales_person_id = e.employee_id
inner join products as pr
    on s.product_id = pr.product_id
where rn_s.rn = 1 and pr.price = 0
order by c.customer_id;
