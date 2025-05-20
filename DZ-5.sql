--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
/*--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате платежа
--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате платежа
--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по размеру платежа от наименьшей к большей
--Пронумеруйте платежи для каждого покупателя по размеру платежа от наибольшего к
--меньшему так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.*/

select customer_id, payment_id , payment_date , amount ,
	row_number() over (order by payment_date),
	dense_rank() over (partition by customer_id order by payment_date)
from payment p 

select customer_id, payment_id , payment_date::date , amount ,
	sum(amount) over (partition by customer_id order by payment_date::date, amount)
from payment p

select customer_id, payment_id , payment_date , amount ,
	dense_rank() over (partition by customer_id order by amount desc)
from payment p


--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате платежа.

select customer_id, payment_id , payment_date, amount ,
	lag(amount, 1 , 0.00) over (partition by customer_id order by payment_date)
from payment p 

--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.

select customer_id, payment_id , payment_date, amount ,
	lead(amount, 1 , 0.00) over (partition by customer_id order by payment_date),
	amount - lead(amount, 1 , 0.00) over (partition by customer_id order by payment_date) as difference
from payment p 

--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.

--explain analyze --1505.75/22
select customer_id, payment_id , payment_date , amount
from (select customer_id, payment_id , payment_date , amount ,
	dense_rank() over (partition by customer_id order by payment_date desc)
from payment p)
where dense_rank = 1


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
 /*С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года
 с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате.*/

--explain analyze --440.12 / 19.791
select staff_id, payment_date::date, sum_amount,
	sum(sum_amount) over (partition by staff_id order by payment_date::date) 
from (select distinct staff_id, payment_date::date,
		sum(amount) over (partition by staff_id, date_part('day', payment_date) order by payment_date::date) as sum_amount
	from (select staff_id , payment_date , amount
		from payment p 
		where date_part('month', payment_date) = '8' and date_part('year', payment_date) = '2005')
	order by staff_id, payment_date)
	
--explain analyze --366.06 / 16.903
select p.staff_id , p.payment_date::date, sum(amount),
	sum(sum(amount)) over (partition by staff_id order by payment_date::date) 
from payment p 
where date_trunc('month', payment_date) = '2005.08.01'
group by p.staff_id , p.payment_date::date

--ЗАДАНИЕ №2
/*20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал дополнительную скидку на следующую аренду. 
С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.*/

select customer_id , payment_date, row_number
from (select customer_id , payment_date, row_number() over (order by payment_date::date)
	from (select customer_id , payment_date
		from payment p 
		where payment_date::date = '2005-08-20'
		order by payment_date))
where row_number % 100 = 0

select customer_id , payment_date, row_number
from (select customer_id , payment_date, row_number() over (order by payment_date::date)
	from payment p 
	where payment_date::date = '2005-08-20')
where row_number % 100 = 0

--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм

/* по пункту  3. покупатель, который последним арендовал фильм
подходят оба - при сортировке по имени от A до Z получается первый CHEATHAM MARIO 
если не делать эту сортировку то может выпасть GRAY JUDY
Algeria	MARIO CHEATHAM	4.99	2006-02-14 15:16:03.000
Algeria	JUDY GRAY	0.99	2006-02-14 15:16:03.000 */

explain analyze --614855.36 / 3278.448
with cte as (select c.country_id, c.country , concat(c3.first_name , ' ',  c3.last_name) as last_first_name , amount, p.payment_date,
				sum(amount) over (partition by c3.customer_id) as sum_a,
				count(amount) over (partition by c3.customer_id) as count_a,
				row_number() over (partition by c.country_id order by payment_date desc, c3.last_name asc) as rank_a
			from country c 
			left join city c2 on c.country_id = c2.country_id 
			left join address a on a.city_id = c2.city_id 
			left join customer c3 on c3.address_id = a.address_id 
			left join rental r on r.customer_id  = c3.customer_id 
			left join inventory i on i.inventory_id = r.inventory_id 
			left join payment p on p.customer_id = c3.customer_id)		
select t1.country, t3.customer_max_count, t2.customer_max_sum, t1.customer_max_last_pay
from (select country_id, country, last_first_name as customer_max_last_pay
	from (select distinct cte.country_id,cte.country, cte.last_first_name, cte.rank_a, 
			first_value(cte.rank_a) over (partition by cte.country_id  order by cte.rank_a)
		from cte) ct
	where ct.rank_a = first_value) as t1 
 left join (select country_id, country, last_first_name as customer_max_sum
	from (select distinct cte.country_id,cte.country, cte.last_first_name, cte.sum_a, 
			first_value(cte.sum_a) over (partition by cte.country_id  order by cte.sum_a desc)
		from cte) ct
	where ct.sum_a = first_value) as t2 on t2.country_id = t1.country_id
 left join (select country_id, country, last_first_name as customer_max_count
	from (select distinct cte.country_id, cte.country, cte.last_first_name, cte.count_a, 
			first_value(cte.count_a) over (partition by cte.country_id  order by cte.count_a desc)
		from cte) ct
	where ct.count_a = first_value ) as t3 on t3.country_id = t2.country_id
order by t1.country


explain analyze --73006.16 / 249.387
select distinct  c.country , --concat(c3.first_name , ' ',  c3.last_name) as last_first_name ,
	--sum(p.amount), count(i.film_id), max(r.rental_date),
	first_value(concat(c3.first_name , ' ',  c3.last_name)) over (partition by c.country_id order by sum(p.amount) desc),
	first_value(concat(c3.first_name , ' ',  c3.last_name)) over (partition by c.country_id order by count(i.film_id) desc),
	first_value(concat(c3.first_name , ' ',  c3.last_name)) over (partition by c.country_id order by max(r.rental_date) desc)
from country c 
left join city c2 on c.country_id = c2.country_id 
left join address a on a.city_id = c2.city_id 
left join customer c3 on c3.address_id = a.address_id 
left join rental r on r.customer_id  = c3.customer_id 
left join inventory i on i.inventory_id = r.inventory_id 
left join payment p on p.customer_id = c3.customer_id
group by c.country_id, c3.customer_id 
order by c.country

explain analyze --1262.85 / 62.865
with cte1 as (
	select r.customer_id, count, sum, max
	from (
		select r.customer_id, count(i.film_id), max(r.rental_date)
		from rental r
		join inventory i on i.inventory_id = r.inventory_id
		group by 1) r
	join (
		select customer_id, sum(amount)
		from payment 
		group by 1) p on r.customer_id = p.customer_id),
cte2 as (
	select c2.country_id, concat(c.last_name, ' ', c.first_name), cte1.count, cte1.sum, cte1.max,
		case when max(cte1.count) over (partition by c2.country_id) = cte1.count then concat(c.last_name, ' ', c.first_name) end cc,
		case when max(cte1.sum) over (partition by c2.country_id) = cte1.sum then concat(c.last_name, ' ', c.first_name) end cs,
		case when max(cte1.max) over (partition by c2.country_id) = cte1.max then concat(c.last_name, ' ', c.first_name) end cm
	from cte1
	join customer c on c.customer_id = cte1.customer_id
	join address a on c.address_id = a.address_id
	join city c2 on a.city_id = c2.city_id)
select c.country, string_agg(cc, ', ') fio_count, string_agg(cs, ', ') fio_sum, string_agg(cm, ', ') fio_max
from country c
left join cte2 on c.country_id = cte2.country_id
group by c.country_id
order by 1

