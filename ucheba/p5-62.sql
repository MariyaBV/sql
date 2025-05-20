from 
on 
join 
where 
group by 
having 
over 
select 
order by

функция(арг1, арг2...) over (partition by арг1, арг2... order by арг1, арг2...)

() со всеми данными глобально в хаотичном порядке
(partition by) в разрезе каждой группы в хаотичном порядке
(order by) со всеми данными глобально, но данные передеаете поэтапно в определенной последовательности
(partition by order by) в разрезе каждой группы, данные передеаете поэтапно в определенной последовательности

cust_id	amount
1		5
1		7
1		2
2		3
2		4

group by cust_id
cust_id	sum(amount)
1		14
2		7

cust_id	amount sum(amount) over (partition by cust_id)
1		5		14	
1		7		14
1		2		14
2		3		7
2		4		7

1		5		
1		7
1		2
14

2		3
2		4
7

============= оконные функции =============

1. Вывести ФИО пользователя и название пятого фильма, который он брал в аренду.
* В подзапросе получите порядковые номера для каждого пользователя по дате аренды
* Задайте окно с использованием предложений over, partition by и order by
* Соедините с customer
* Соедините с inventory
* Соедините с film
* В условии укажите 3 фильм по порядку

explain analyze --1799.19 / 10
select concat(c.last_name, ' ', c.first_name), f.title
from (
	select customer_id, array_agg(inventory_id order by rental_date)
	from rental 
	group by customer_id) r
join inventory i on i.inventory_id = r.array_agg[5]
join film f on f.film_id = i.film_id
join customer c on c.customer_id = r.customer_id

explain analyze --2148.35 / 11
select concat(c.last_name, ' ', c.first_name), f.title
from (
	select *, row_number() over (partition by customer_id order by rental_date)
	from rental) r
join inventory i on i.inventory_id = r.inventory_id and row_number = 5
join film f on f.film_id = i.film_id
join customer c on c.customer_id = r.customer_id


1.1. Выведите таблицу, содержащую имена покупателей, арендованные ими фильмы и средний платеж 
каждого покупателя
* используйте таблицу customer
* соедините с paymen
* соедините с rental
* соедините с inventory
* соедините с film
* avg - функция, вычисляющая среднее значение
* Задайте окно с использованием предложений over и partition by

select concat(c.last_name, ' ', c.first_name), f.title, amount, date_trunc('month', p.payment_date),
	avg(amount) over (partition by c.customer_id),
	sum(amount) over (partition by c.customer_id),
	count(amount) over (partition by c.customer_id),
	avg(amount) over (partition by c.customer_id, date_trunc('month', p.payment_date)),
	sum(amount) over (partition by c.customer_id, date_trunc('month', p.payment_date)),
	count(amount) over (partition by c.customer_id, date_trunc('month', p.payment_date)),
	avg(amount) over (partition by p.staff_id),
	sum(amount) over (partition by p.staff_id),
	count(amount) over (partition by p.staff_id),
	avg(amount) over (),
	sum(amount) over (),
	count(amount) over ()
from customer c
join payment p on c.customer_id = p.customer_id
join rental r on p.rental_id = r.rental_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
--group by c.customer_id, f.film_id

explain analyze --689.84 / 7.3
select customer_id, sum(amount) * 100. / (select sum(amount) from payment p)
from payment 
group by customer_id

explain analyze --377.71 / 4.6
select customer_id, sum(amount), sum(sum(amount)) over (), sum(amount) * 100. / sum(sum(amount)) over ()
from payment 
group by customer_id

-- формирование накопительного итога
НАКОПИТЕЛЬНЫЙ ИТОГ ФОРМИРУЕТСЯ ТОЛЬКО ЧЕРЕЗ ORDER by

2	2
4	2+4=6
8	2+4+8=14
1	2+4+8+1=15


select customer_id, amount, payment_date, sum(amount) over (partition by customer_id order by payment_date)
from payment 
order by customer_id

1	0.99	2005-05-28 10:35:23	sum(0.99) - 0.99
1	3.99	2005-06-21 06:24:45 sum(0.99+3.99) - 4.98
1	2.99	2005-07-27 11:31:22 sum(0.99+3.99+2.99) - 7.97


2	4.99	2005-05-27 00:09:24 sum(4.99) - 4.99
2	6.99	2005-08-02 10:43:48 sum(4.99+6.99) - 11.98
2	4.99	2005-08-22 13:53:04 sum(4.99+6.99+4.99) - 16.97

3	3.99	2005-07-30 21:45:46
3	2.99	2005-07-29 11:07:04
3	4.99	2005-07-08 12:47:11

4	5.99	2005-07-30 08:46:09
4	3.99	2005-07-29 18:44:57
4	2.99	2005-07-28 04:37:59

select customer_id, amount, payment_date, sum(amount) over (order by payment_date)
from payment 
order by customer_id

select customer_id, amount, payment_date::date, sum(amount) over (partition by customer_id order by payment_date::date)
from payment 
order by customer_id

select customer_id, amount, payment_date::date, avg(amount) over (partition by customer_id order by payment_date::date)
from payment 
order by customer_id

-- работа функций lag и lead

дата_убытия_1 | дата_прибытия_1
дата_убытия_2 | дата_прибытия_2

получить время простоя транспорта

дата_убытия_2 - lag(дата_прибытия_1)

--ложный запрос
select date_trunc('month', payment_date), sum(amount), lag(sum(amount)) over (order by date_trunc('month', payment_date)),
	sum(amount) - lag(sum(amount)) over (order by date_trunc('month', payment_date))
from payment p
group by 1

select customer_id, payment_date,
	lag(amount) over (partition by customer_id order by payment_date),
	amount,
	lead(amount) over (partition by customer_id order by payment_date)
from payment

select customer_id, payment_date::date,
	lag(amount) over (partition by customer_id order by payment_date::date),
	amount,
	lead(amount) over (partition by customer_id order by payment_date::date)
from payment

select date_trunc('month', created_at), sum(amount),
	lag(sum(amount), 12) over (order by date_trunc('month', created_at))
from projects 
group by date_trunc('month', created_at)
order by 1

select customer_id, payment_date,
	lag(amount, 5) over (partition by customer_id order by payment_date),
	amount,
	lead(amount, 3) over (partition by customer_id order by payment_date)
from payment

--плохая практика 
select customer_id, payment_date,
	lag(amount, -3) over (partition by customer_id order by payment_date),
	amount,
	lead(amount, -5) over (partition by customer_id order by payment_date),
	lead(amount, 0) over (partition by customer_id order by payment_date)
from payment

select customer_id, payment_date,
	lag(amount, 5, 0.) over (partition by customer_id order by payment_date),
	amount,
	lead(amount, 3, 0.) over (partition by customer_id order by payment_date)
from payment

select customer_id, payment_date,
	lag(amount, 1, 0.) over (partition by customer_id order by payment_date),
	amount,
	lead(amount, 1, 0.) over (partition by customer_id order by payment_date)
from payment

-- работа с рангами и порядковыми номерами
row_number - сквозная нумерация
dense_rank - одинаковый ранг по общему знаменателю, увеличение предыдущий ранг + 1
rank - одинаковый ранг по общему знаменателю, увеличение предыдущий ранг + кол-во значений в предыдущем ранге

1	1:00
2,3	1:01
4	1:02

dense_rank
1	1
2	2,3
3	4

rank
1	1
2	2,3
4	4

select customer_id, payment_date::date,
	row_number() over (order by payment_date::date),
	dense_rank() over (order by payment_date::date),
	rank() over (order by payment_date::date)
from payment

-- first_value / last_value / nth_value
ПРЕЖДЕ ЧЕМ ИСПОЛЬЗОВАТЬ last_value ИЛИ nth_value ИДЕТЕ В ДОКУМЕНТАЦИЮ, А В ДОКУМЕНТАЦИИ НАПИСАНО, ЧТО ИХ ЛУЧШЕ НЕ ИСПОЛЬЗОВАТЬ

--найти первую аренду по каждому пользователю

explain analyze  --1511.31 / 7
select distinct on (customer_id) *
from rental r
order by customer_id, rental_date

explain analyze  --800.31 / 5.5
select *
from rental r
where (customer_id, rental_date) in (
	select customer_id, min(rental_date)
	from rental r
	group by 1)
	
explain analyze  --1952.52 / 8.5
select *
from (
	select *, row_number() over (partition by customer_id order by rental_date)
	from rental) r
where row_number = 1

explain analyze  --2313.51 / 23
select distinct customer_id, 
	first_value(rental_id) over (partition by customer_id order by rental_date),
	first_value(rental_date) over (partition by customer_id order by rental_date),
	first_value(inventory_id) over (partition by customer_id order by rental_date),
	first_value(rental_date) over (partition by customer_id order by rental_date),
	first_value(staff_id) over (partition by customer_id order by rental_date),
	first_value(last_update) over (partition by customer_id order by rental_date)
from rental

explain analyze --1952.52 / 14
select *
from (
	select *, 
		first_value(rental_id) over (partition by customer_id order by rental_date)
	from rental) 
where rental_id = first_value

--ложный запрос
select *
from (
	select *, 
		last_value(rental_id) over (partition by customer_id order by rental_date desc)
	from rental) 
where rental_id = last_value

--верный запрос
explain analyze --1912.41 / 14
select *
from (
	select  *, 
		last_value(rental_id) over (partition by customer_id)
	from (
		select *
		from rental
		order by customer_id, rental_date desc))
where rental_id = last_value

explain analyze --1952.52 / 14
select *
from (
	select *, 
		last_value(rental_id) over (partition by customer_id order by rental_date desc
			rows between unbounded preceding and unbounded following)
	from rental) 
where rental_id = last_value

rows 
range
groups

select customer_id, amount, payment_date::date, 
	sum(amount) over (order by payment_date::date rows between 2 preceding and current row),
	avg(amount) over (order by payment_date::date rows between 2 preceding and 2 following)
from payment 

select customer_id, amount, payment_date::date, 
	sum(amount) over (order by payment_date::date rows between 2 preceding and current row),
	sum(amount) over (order by payment_date::date range between '1 day 12 hours' preceding and '1 day 12 hours' following),
	sum(amount) over (order by payment_date::date groups between 1 preceding and 1 following)
from payment 

--алиасы
select amount, date_trunc('month', p.payment_date),
	avg(amount) over w_1,
	sum(amount) over w_1,
	count(amount) over w_1,
	avg(amount) over w_2,
	sum(amount) over w_2,
	count(amount) over w_2,
	avg(amount) over w_3,
	sum(amount) over w_3,
	count(amount) over w_3,
	avg(amount) over w_4,
	sum(amount) over w_4,
	count(amount) over w_4
from payment p
window w_1 as (partition by customer_id),
	w_2 as (partition by customer_id, date_trunc('month', p.payment_date)),
	w_3 as (partition by p.staff_id),
	w_4 as ()
order by 1

--фильтрация
select customer_id, amount, payment_date::date, 
	sum(amount) filter (where amount < 5) over (order by payment_date::date rows between 2 preceding and current row),
	sum(amount) filter (where amount >= 5) over (order by payment_date::date rows between 2 preceding and current row)
from payment 

============= общие табличные выражения =============

2.  При помощи CTE выведите таблицу со следующим содержанием:
Название фильма продолжительностью более 3 часов и к какой категории относится фильм
* Создайте CTE:
 - Используйте таблицу film
 - отфильтруйте данные по длительности
 * напишите запрос к полученной CTE:
 - соедините с film_category
 - соедините с category

with cte as (
	логика
)
select 
from cte
join cte

select 
from (логика_1)
join (логика_1)

explain analyze --45135.47 / 300
with cte as (
	select customer_id, staff_id, payment_date::date, sum(amount)
	from payment p
	group by cube (1,2,3))
select customer_id, staff_id, t1.payment_date, t1.sum
from (
	select customer_id, payment_date, sum
	from cte
	where sum < 10) t1
join (
	select staff_id, payment_date, sum
	from cte
	where sum > 10) t2 on t1.payment_date = t2.payment_date
	
explain analyze --47517.12  / 320
select customer_id, staff_id, t1.payment_date, t1.sum
from (
	select customer_id, payment_date, sum
	from (
		select customer_id, staff_id, payment_date::date, sum(amount)
		from payment p
		group by cube (1,2,3))
	where sum < 10) t1 
join (
	select staff_id, payment_date, sum
	from (
		select customer_id, staff_id, payment_date::date, sum(amount)
		from payment p
		group by cube (1,2,3))
	where sum > 10) t2 on t1.payment_date = t2.payment_date 

select version()	--PostgreSQL 16.0, compiled by Visual C++ build 1935, 64-bit

select version()	--PostgreSQL 10.9 (Ubuntu 10.9-0ubuntu0.18.04.1) on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 7.4.0-1ubuntu1~18.04.1) 7.4.0, 64-bit

explain analyze --45551.84 / 300
with cte as (
	select customer_id, staff_id, payment_date::date, sum(amount)
	from payment p
	group by cube (1,2,3))
select customer_id, staff_id, t1.payment_date, t1.sum
from (
	select customer_id, payment_date, sum
	from cte
	where sum < 10) t1
join (
	select staff_id, payment_date, sum
	from cte
	where sum > 10) t2 on t1.payment_date = t2.payment_date
	
2.1. Выведите фильмы, с категорией начинающейся с буквы "C"
* Создайте CTE:
 - Используйте таблицу category
 - Отфильтруйте строки с помощью оператора like 
* Соедините полученное табличное выражение с таблицей film_category
* Соедините с таблицей film
* Выведите информацию о фильмах:
title, category."name"

explain analyze --53.79 / 90.43
with cte1 as (
	select * 
	from film 
	where length > 180),
cte2 as (
	select *
	from category
	where lower(left(name, 1)) = 'c'),
cte3 as (
	select *
	from cte1
	join film_category fc on fc.film_id = cte1.film_id
	join cte2 on cte2.category_id = fc.category_id)
select *
from cte3

============= общие табличные выражения (рекурсивные) =============
 
 3.Вычислите факториал
 + Создайте CTE
 * стартовая часть рекурсии (т.н. "anchor") должна позволять вычислять начальное значение
 *  рекурсивная часть опираться на данные с предыдущей итерации и иметь условие остановки
 + Напишите запрос к CTE

with recursive r as (
	--стартовая часть
	select 1 as x, 1 as factorial
	union 
	--рекурсивная часть
	select x + 1 as x, factorial * (x + 1) as factorial
	from r 
	where x < 12)
select *
from r

with recursive r as (
	--стартовая часть
	select *, 0 as level
	from "structure" s
	where unit_id = 59
	union 
	--рекурсивная часть
	select s.*, level + 1 as level
	from r 
	join "structure" s on r.unit_id = s.parent_id)
select count(*)
from r
join position p on p.unit_id = r.unit_id
join employee e on e.pos_id = p.pos_id

with recursive r as (
	--стартовая часть
	select *, 0 as level
	from "structure" s
	where unit_id = 59
	union 
	--рекурсивная часть
	select s.*, level + 1 as level
	from r 
	join "structure" s on r.parent_id = s.unit_id)
select *
from r

3.2 Работа с рядами.

with recursive r as (
	--стартовая часть
	select 1 as x
	union 
	--рекурсивная часть
	select x + 3 as x
	from r 
	where x < 100)
select *
from r

select x 
from generate_series(1, 100, 3) x

with recursive r as (
	--стартовая часть
	select '01.01.2024'::date as x
	union 
	--рекурсивная часть
	select x + 1 as x
	from r 
	where x < '31.12.2024')
select *
from r

select x::date
from generate_series('01.01.2024'::date, '31.12.2024'::date, interval '1 day') x

--ложный запрос
select date_trunc('month', payment_date), sum(amount), lag(sum(amount)) over (order by date_trunc('month', payment_date)),
	sum(amount) - lag(sum(amount)) over (order by date_trunc('month', payment_date))
from payment p
group by 1

explain analyze --5039.36 / 12
with recursive r as (
	--стартовая часть
	select min(date_trunc('month', payment_date)) x
	from payment 
	union 
	--рекурсивная часть
	select x + interval '1 month' as x
	from r 
	where x < (select max(date_trunc('month', payment_date)) x from payment ))
select x::date, coalesce(p.sum, 0.),
	lag(coalesce(p.sum, 0.), 1, 0.) over (order by x::date),
	coalesce(p.sum, 0.) - lag(coalesce(p.sum, 0.), 1, 0.) over (order by x::date)
from r
left join (
	select date_trunc('month', payment_date), sum(amount)
	from payment 
	group by 1) p on p.date_trunc = r.x
order by 1

select 1 + null

select coalesce(null, null, null, 8,null, null, null, 10)

explain analyze --12300.51 / 12
select x::date, coalesce(p.sum, 0.),
	lag(coalesce(p.sum, 0.), 1, 0.) over (order by x::date),
	coalesce(p.sum, 0.) - lag(coalesce(p.sum, 0.), 1, 0.) over (order by x::date)
from generate_series(
	(select min(date_trunc('month', payment_date)) from payment),
	(select max(date_trunc('month', payment_date)) x from payment),
	interval '1 month') x
left join (
	select date_trunc('month', payment_date), sum(amount)
	from payment 
	group by 1) p on p.date_trunc = x
order by 1