--=============== МОДУЛЬ 2. РАБОТА С БАЗАМИ ДАННЫХ =======================================
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите уникальные названия городов из таблицы городов.
explain analyze --21.49
select distinct lower(c.city) --599 так правильнее тк города могли записать в разном регистре
from city c

explain analyze --18.49
select distinct c.city --599
from city c

--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города,
--названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.

select distinct c.city
from city c
where c.city like 'L%' and c.city like '%a' and c.city not like '% %'


--ЗАДАНИЕ №3
--Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись 
--в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно, 
--и стоимость которых превышает 1.00.
--Платежи нужно отсортировать по дате платежа.

select amount, payment_date
from payment
where (payment_date::date between '2005-06-17' and '2005-06-19') and (amount > 1.00)
order by payment_date


--ЗАДАНИЕ №4
-- Выведите информацию о 10-ти последних платежах за прокат фильмов.


select amount, payment_date
from payment
order by payment_date desc
limit 10


--ЗАДАНИЕ №5
--Выведите следующую информацию по покупателям:
--  1. Фамилия и имя (в одной колонке через пробел)
--  2. Электронная почта
--  3. Длину значения поля email
--  4. Дату последнего обновления записи о покупателе (без времени)
--Каждой колонке задайте наименование на русском языке.

select concat(last_name , ' ', first_name) as "Фамилия и имя", 
		email as "Электронная почта", character_length(email) as "Длина значения поля email", 
		last_update::date as "Дата послед. обновл.записи о покуп."
from customer c

--ЗАДАНИЕ №6
--Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE.
--Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.

select lower(last_name) as "last_name", lower(first_name) as "first_name"
from customer c 
where (first_name = 'WILLIE' or first_name = 'KELLY') and activebool = true 



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите информацию о фильмах, у которых рейтинг “R” и стоимость аренды указана от 
--0.00 до 3.00 включительно, а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00.

select *
from film f 
where (rating = 'R' and (rental_rate between '0.00' and '3.00')) or (rating = 'PG-13' and rental_rate >= '4.00')



--ЗАДАНИЕ №2
--Получите информацию о трёх фильмах с самым длинным описанием фильма.

select *
from film f 
order by length (description) desc
limit 3 --fetch first 3 rows with ties

--ЗАДАНИЕ №3
-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.

select split_part(email, '@', 1) as "email_before_@", 
		trim(both (concat(split_part(email, '@', 1),'@')) from c.email) as "email_after_@"
from customer c 

select split_part(email, '@', 1) as "email_before_@", 
		split_part(email, '@', 2) as "email_after_@"
from customer c 

select substring(email, 1, strpos(email, '@') - 1) as "email_before_@", 
	   substring(email, strpos(email, '@') + 1) as "email_after_@"
from customer c 

select substring(email, 1, strpos(email, '@') - 1) as "email_before_@", 
	   substring(email, strpos(email, '@')) as "email_after_with_@"
from customer c 


--ЗАДАНИЕ №4
--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква строки должна быть заглавной, остальные строчными.
--explain analyze --41.95
select concat(upper((left(split_part(email, '@', 1), 1))), substring(lower(split_part(email, '@', 1)), 2)) as "email_before_@",
	   concat(upper((left(trim(both (concat(split_part(email, '@', 1),'@')) from c.email), 1))), substring(lower(trim(both (concat(split_part(email, '@', 1),'@')) from c.email)), 2)) as "email_after_@"
from customer c 

explain analyze --35.96
select concat(upper(left(split_part(email, '@', 1), 1)), lower(right(split_part(email, '@', 1), -1)))  as "email_before_@",
	   concat(upper(left(split_part(email, '@', 2), 1)), lower(right(split_part(email, '@', 2), -1))) as "email_after_@"
from customer c 

select overlay(lower(split_part(email, '@', 1)) placing upper(left(email, 1)) from 1 for 1) as "email_before_@", 
		overlay(lower(split_part(email, '@', 2)) placing upper(left(split_part(email, '@', 2), 1)) from 1 for 1) as "email_after_@"
from customer c 

