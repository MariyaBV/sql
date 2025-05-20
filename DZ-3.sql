--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.

select concat(c.last_name , ' ', c.first_name) as last_first_name_customer , a.address, c2.city , c3.country 
from customer c 
join address a  on c.address_id = a.address_id
join city c2 on c2.city_id  = a.city_id
join country c3 on c3.country_id = c2.country_id 


--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.

select c.store_id , count(c.customer_id) as count_customers
from customer c 
group by c.store_id 

--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.

select c.store_id , count(c.customer_id) as count_customers
from customer c 
group by c.store_id 
having count(c.customer_id) > 300

-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.

explain analyze
select s.store_id , ci.city as city_store, concat(s2.last_name ,'  ', s2.first_name ) as staff_last_first_name
from city ci 
join address a on a.city_id = ci.city_id 
join store s on s.address_id = a.address_id 
join staff s2 on s2.staff_id = s.manager_staff_id 
where s.store_id = (select c.store_id
from customer c 
group by c.store_id 
having count(c.customer_id) > 300)

--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов

select r.customer_id, count(r.rental_id) as count_rental_dvd
from rental r 
group by r.customer_id
order by count(r.rental_id) desc
fetch first 5 rows with ties

--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма

select p.customer_id, count(i.film_id), sum(amount)::numeric(5,0), min(amount), max(amount)
from payment p
join rental r on r.rental_id  = p.rental_id  
join inventory i on i.inventory_id = r.inventory_id 
group by p.customer_id
order by p.customer_id 

--ЗАДАНИЕ №5
--Используя данные из таблицы городов, составьте все возможные пары городов так, чтобы 
--в результате не было пар с одинаковыми названиями городов. Решение должно быть через Декартово произведение.
 
select distinct c1.city, c2.city --179101
from city c1, city c2 
where c1.city < c2.city

--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и 
--дате возврата (поле return_date), вычислите для каждого покупателя среднее количество 
--дней, за которые он возвращает фильмы. В результате должны быть дробные значения, а не интервал.
 
select customer_id , avg(date_part('day', (return_date - rental_date)))
from rental r 
group by customer_id
order by customer_id 

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.

select f.film_id, count(r.rental_id) as count_rent, sum(p.amount) as sum_amount
from film f 
join inventory i on i.film_id = f.film_id 
join rental r on r.inventory_id = i.inventory_id 
join payment p on p.rental_id = r.rental_id 
group by f.film_id 
order by f.film_id 

--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые отсутствуют на dvd дисках.

select f.film_id, f.title , f.description,  count(r.rental_id) as count_rent, sum(p.amount) as sum_amount
from film f 
left join inventory i on i.film_id = f.film_id 
left join rental r on r.inventory_id = i.inventory_id 
left join payment p on p.rental_id = r.rental_id 
where i.inventory_id is null
group by f.film_id 
order by f.film_id

--если ни разу не брали фильмы напрокат то sum, count будут пустые и 0 соот-но можно сделать запрос проще без лишних join
select f.film_id , f.title , f.description 
from film f 
left join inventory i on i.film_id = f.film_id  
where i.inventory_id is null
order by f.film_id 

--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".

select p.staff_id , count(p.amount), 
		(case
			when count(p.amount) > 7300 then 'Да'
			else 'Нет'
		end) as "Премия"
from payment p 
group by p.staff_id 






