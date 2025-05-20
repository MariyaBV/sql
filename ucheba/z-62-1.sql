Задание 1.Выведите информацию о фильмах, у которых рейтинг “R” и стоимость аренды указана от 0.00 включительно до 3.00 включительно, 
а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00.
Ожидаемый результат запроса: letsdocode.ru...in/2-7.png

explain analyze --77.50
select title, rating, rental_rate
from film 
where (rating = 'R' and rental_rate between 0. and 3.)
	or (rating = 'PG-13' and rental_rate >= 4.)
	
--так плохо
explain analyze --87.50	
select title, rating, rental_rate
from film 
where (rating::text like 'R' and rental_rate between 0. and 3.)
	or (rating::text like 'PG-13' and rental_rate >= 4.)
	
--так плохо
explain analyze --152.53
select title, rating, rental_rate
from film 
where (rating::text like 'R' and rental_rate between 0. and 3.)
union all
select title, rating, rental_rate
from film 
where (rating::text like 'PG-13' and rental_rate >= 4.)

Задание 2. Получите информацию о трёх фильмах с самым длинным описанием фильма.
Ожидаемый результат запроса: letsdocode.ru...in/2-8.png

select title, description, char_length(description)
from film 
order by char_length(description)

select title, description, char_length(description)
from film 
order by 3 desc
limit 3

--начиная с 13 версии постгри
select title, description, char_length(description)
from film 
order by 3 desc
fetch first 3 rows with ties

Задание 3. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
в первой колонке должно быть значение, указанное до @,
во второй колонке должно быть значение, указанное после @.
Ожидаемый результат запроса: letsdocode.ru...in/2-9.png

select last_name, first_name, email,
	split_part(email, '@', 1),
	split_part(email, '@', 2)
from customer 

select last_name, first_name, email,
	substring(email, 1, strpos(email, '@') - 1),
	substring(email, strpos(email, '@') + 1)
from customer 

select last_name, first_name, email,
	substring(email, 1, strpos(email, '@') - 1),
	substring(email, strpos(email, '@'))
from customer 

Задание 4. Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: первая буква строки должна быть заглавной, остальные строчными.
Ожидаемый результат запроса: letsdocode.ru...n/2-10

--ЛОЖНЫЙ ЗАПРОС
select last_name, first_name, email,
	concat(left(split_part(email, '@', 1), 1), lower(right(split_part(email, '@', 1), - 1))),
	concat(upper(left(split_part(email, '@', 2), 1)), right(split_part(email, '@', 2), - 1))
from customer
order by customer_id

pA.tRI.cia.JOHNSON777@mail.ru

select last_name, first_name, email,
	concat(upper(left(split_part(email, '@', 1), 1)), lower(right(split_part(email, '@', 1), - 1))),
	concat(upper(left(split_part(email, '@', 2), 1)), lower(right(split_part(email, '@', 2), - 1)))
from customer
order by customer_id

select last_name, first_name, email,
	concat(upper(left(email, 1)), lower(right(split_part(email, '@', 1), - 1))),
	concat(upper(left(split_part(email, '@', 2), 1)), lower(right(split_part(email, '@', 2), - 1)))
from customer
order by customer_id

select last_name, first_name, email,
	overlay(lower(split_part(email, '@', 1)) placing upper(left(email, 1)) from 1 for 1),
	overlay(lower(split_part(email, '@', 2)) placing upper(left(split_part(email, '@', 2), 1)) from 1 for 1)
from customer 
order by customer_id

первый симврол строки привести к верхнему регистру, все символы справа кроме одного слева привести к нижнему
left												right

нужно в строке сделать замену первого символа

select title, rating, rental_rate
from film 
where 1 = 1
	and rating = 'R' 
	and rental_rate between 0. and 3.
	or rating = 'PG-13' 
	and rental_rate >= 4.
	
Вывести ФИО сотрудников в виде Фамилия инициалы.
	
select last_name, first_name, middle_name,
	concat_ws(' ', last_name, concat(left(first_name, 1), '.'), concat(left(middle_name, 1), '.')),
	concat(last_name, ' ', left(first_name, 1), '.', left(middle_name, 1), '.')
from person

concat(arg1, arg2, arg3, arg4 ... argN)

concat_ws(разделитель, arg1, arg2, arg3, arg4 ... argN)

select 1111
select 2222