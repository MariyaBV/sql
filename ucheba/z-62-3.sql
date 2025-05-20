Задание 1. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года с нарастающим итогом по каждому сотруднику 
и по каждой дате продажи (без учёта времени) с сортировкой по дате.
Ожидаемый результат запроса: letsdocode.ru...in/5-5.png

select staff_id, payment_date::date, sum(amount), 
	sum(sum(amount)) over (partition by staff_id order by payment_date::date)
from payment p
where date_trunc('month', payment_date) = '01.08.2005'
group by staff_id, payment_date::date

where date_part('month', payment_date) = 8 and date_part('year', payment_date) = 2005

where payment_date::date between '01.08.2005' and '31.08.2005'

Задание 2. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал дополнительную скидку на следующую аренду. 
С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.
Ожидаемый результат запроса: letsdocode.ru...in/5-6.png

select customer_id
from (
	select *, row_number() over (order by payment_date)
	from payment 
	where payment_date::date = '20.08.2005')
where row_number % 100 = 0

where mod(row_number, 100) = 0

where row_number::text like '%00' --очень плохо

/*
select customer_id
from (
	select *, count(*) over (order by payment_date)
	from payment 
	where payment_date::date = '20.08.2005')
where count % 100 = 0
*/

Задание 3. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
· покупатель, арендовавший наибольшее количество фильмов;
· покупатель, арендовавший фильмов на самую большую сумму;
· покупатель, который последним арендовал фильм.
Ожидаемый результат запроса: letsdocode.ru...in/5-7.png

explain analyze --6686.03 / 34
select distinct c.country, --concat(c3.last_name, ' ', c3.first_name), count(i.film_id), sum(p.amount), max(r.rental_date),
	first_value(concat(c3.last_name, ' ', c3.first_name)) over (partition by c.country_id order by count(i.film_id) desc),
	first_value(concat(c3.last_name, ' ', c3.first_name)) over (partition by c.country_id order by sum(p.amount) desc),
	first_value(concat(c3.last_name, ' ', c3.first_name)) over (partition by c.country_id order by max(r.rental_date) desc)
from country c
left join city c2 on c.country_id = c2.country_id
left join address a on a.city_id = c2.city_id
left join customer c3 on c3.address_id = a.address_id
left join rental r on r.customer_id = c3.customer_id
left join inventory i on i.inventory_id = r.inventory_id
left join payment p on p.rental_id = r.rental_id
group by c.country_id, c3.customer_id
order by 1

explain analyze --1262.85 / 14
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


Задание 1. Откройте по ссылке SQL-запрос.
Сделайте explain analyze этого запроса.
Основываясь на описании запроса, найдите узкие места и опишите их.
Сравните с вашим запросом из основной части (если ваш запрос изначально укладывается в 15мс — отлично!).
Сделайте построчное описание explain analyze на русском языке оптимизированного запроса. Описание строк в explain можно посмотреть по ссылке.

explain analyze
select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc

explain analyze
select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid)
from customer cu
join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs = 'Behind the Scenes'
group by cu.customer_id
order by count desc

explain analyze --654.22 / 7
select  c.first_name  || ' ' || c.last_name as name, count(*)
from rental r
right join inventory i on r.inventory_id = i.inventory_id
	and i.film_id in (
		select film_id
		from film 
		where special_features && array['Behind the Scenes']) 
join customer c on c.customer_id = r.customer_id
group by c.customer_id
order by 2 desc

Задание 2. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.
Ожидаемый результат запроса: letsdocode.ru...in/6-5.png

select *
from (
	select *, row_number() over (partition by staff_id order by payment_date)
	from payment)
where row_number = 1

Задание 3. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
день, в который арендовали больше всего фильмов (в формате год-месяц-день);
количество фильмов, взятых в аренду в этот день;
день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
сумму продажи в этот день.
Ожидаемый результат запроса: letsdocode.ru...in/6-6.png

Задание не имеет решения, учитывая текущие данные.

аренда			продажа
диск			диск
сотрудник		сотрудник
пользователь	пользователь
диск			сотрудник
диск			пользователь
сотрудник		диск
сотрудник		пользователь
пользователь	диск
пользователь	сотрудник

explain analyze --5020.68 / 16
select *
from (
	select i.store_id, r.rental_date::date, count(i.film_id),
		row_number() over (partition by i.store_id order by count(i.film_id) desc)
	from rental r
	join inventory i on r.inventory_id = i.inventory_id
	group by 1, 2) t1
join (
	select s.store_id, p.payment_date::date, sum(p.amount),
		row_number() over (partition by s.store_id order by sum(p.amount))
	from payment p
	join staff s on s.staff_id = p.staff_id
	group by 1, 2) t2 on t1.store_id = t2.store_id
where t1.row_number = 1 and t2.row_number = 1

select *
from (
	select store_id, rental_date, payment_date, count, sum,
		max(count) over (partition by store_id),
		min(sum) over (partition by store_id)
	from (
		)
where count = max or sum = min

explain analyze --8675.69 / 43
with cte1 as (
	select distinct i.store_id, r.rental_date::date, p.payment_date::date, 
			count(i.film_id) over (partition by i.store_id, r.rental_date::date),
			sum(p.amount) over (partition by i.store_id, p.payment_date::date)
		from rental r
		join inventory i on r.inventory_id = i.inventory_id
		full join payment p on r.rental_id = p.rental_id),
cte2 as (
	select store_id, rental_date, count, max(count) over (partition by store_id)
	from cte1),
cte3 as (
	select store_id, payment_date, sum, min(sum) over (partition by store_id)
	from cte1)
select *
from cte2
join cte3 on cte2.store_id = cte3.store_id
where count = max and sum = min