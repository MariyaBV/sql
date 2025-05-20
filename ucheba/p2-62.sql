https://www.sqlstyle.guide/ru/

Комментарии

--волдатпилдватп
/*
 * уваувкпв
 * ывапывап
 * ывапывап
 */
select ...

select ... /*dgdfgdfgdfh*/ fgdfg

Отличие ' ' от " "  --` `

' ' - значений

where first_name = 'Николай'

where pay_date = '01.01.2024'

set search_path to "dvd-rental"

from "Таблица на русском"

Зарезервированные слова

select name
from language 

select "select"
from "from"

оператор действие
функция(аргументы)

синтаксический порядок инструкции select;

select - вывести в результат, столбцы, вычисления
from - основная таблиц
join - остальные таблицы
on - условие присоединения
where - условие фильтрации данных
group by - группировка данных
having - фильтрацию результата агрегации
order by - сортировка результата
offset/limit

логический порядок инструкции select;

from
on
join
where
group by
having
select - алиасы
order by 
offset/limit

pg_typeof(), приведение типов

select pg_typeof()

count()

smallint int2
integer int4 int
bigint int8

select pg_typeof(100) --integer

select pg_typeof(100.) --numeric

select pg_typeof('100') --unknown

numeric | text 
100.	 '100'

{"a":"b"} - int - нельзя 

select pg_typeof(cast('100' as float))

double precision = float

select pg_typeof(cast(cast('100' as float) as text))

select pg_typeof('100'::float)

select pg_typeof('100'::float::text)

1. Получите атрибуты id фильма, название, описание, год релиза из таблицы фильмы.
Переименуйте поля так, чтобы все они начинались со слова Film (FilmTitle вместо title и тп)
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- as - для задания синонимов 

select *
from film 

select film_id, title, description, release_year, 2 + 2, power(2, 3)
from film 

select film_id as FilmFilm_id, title as FilmTitle, description as FilmDescription, release_year as FilmRelease_year, 2 + 2 as some_col, power(2, 3)
from film 

select film_id FilmFilm_id, title FilmTitle, description FilmDescription, release_year FilmRelease_year, 2 + 2 some_col, power(2, 3)
from film 

select film_id "FilmFilm_id", title "FilmTitle", description "FilmDescription", release_year "Год выпуска фильма", 2 + 2 some_col, power(2, 3)
from film 

select *
from (
	select 2 + 2 x, 3 + 3 y)
where x = 4

select * 
from (
	select c.first_name cust_fio, s.first_name staff_fio
	from customer c, staff s)
where staff_fio = 'Mike'

select 1 as "ну очень длинный и странный псевдоним на кириллице"

64 байта

2. В одной из таблиц есть два атрибута:
rental_duration - длина периода аренды в днях  
rental_rate - стоимость аренды фильма на этот промежуток времени. 
Для каждого фильма из данной таблицы получите стоимость его аренды в день,
задайте вычисленному столбцу псевдоним cost_per_day
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- стоимость аренды в день - отношение rental_rate к rental_duration
- as - для задания синонимов 

smallint int2 0-65535
integer int4 int
bigint int8

select title, rental_rate / rental_duration
from film 

- арифметические действия
- оператор round

select title, rental_rate / rental_duration,
	rental_rate * rental_duration,
	rental_rate + rental_duration,
	rental_rate - rental_duration,
	power(rental_rate, rental_duration),
	rental_rate % rental_duration,
	mod(rental_rate, rental_duration),
	sqrt(rental_rate),
	sin(rental_duration),
	sind(rental_duration)
from film 

select title, rental_rate / rental_duration
from film 

integer
numeric(8, 2) 999999.99
float

select 99.9::numeric(3,1) * 99.9::numeric(3,1)

round(numeric, int)
round(float)
floor округление до целого в меньшую сторону
ceil округление до целого в большую сторону

select x,
	round(x::numeric) as num,
	round(x::float) as fl
from generate_series(0.5, 7.5, 1) x

2.5 + 2.5 = 249999 + 250001

select round(5. / 9, 2), round(5::float), round(5 / 9, 2)

3.1 Отсортировать список фильмов по убыванию стоимости за день аренды (п.2)
- используйте order by (по умолчанию сортирует по возрастанию)
- desc - сортировка по убыванию

select film_id, title, round(rental_rate / rental_duration, 2)
from film 
order by title --asc

select film_id, title, round(rental_rate / rental_duration, 2)
from film 
order by title desc

select film_id, title, round(rental_rate / rental_duration, 2)
from film 
order by round(rental_rate / rental_duration, 2) desc

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc, title

3.1* Отсортируйте таблицу платежей по возрастанию размера платежа (amount)
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- используйте order by 
- asc - сортировка по возрастанию 

select *
from payment 
order by amount

3.2 Вывести топ-10 самых дорогих фильмов по стоимости за день аренды
-- используйте limit

топ-3

1 - 1000
2,3,4 - 990
5-20 - 980

кто попадет в топ-3?

1,2,3,4 

1 два случайных из 2-4
1-20

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc
limit 10

460	INNOCENT USUAL		1.66
938	VELVET TERMINATOR	1.66
65	BEHAVIOR RUNAWAY	1.66
897	TORQUE BOUND		1.66
904	TRAIN BUNCH			1.66
908	TRAP GUYS			1.66
919	TYCOON GATHERING	1.66
71	BILKO ANONYMOUS		1.66
580	MINE TITANS			1.66
583	MISSION ZOOLANDER	1.66

120	CARIBBEAN LIBERTY	1.66
124	CASPER DRAGONFLY	1.66
46	AUTUMN CROW			1.66
60	BEAST HUNCHBACK		1.66
65	BEHAVIOR RUNAWAY	1.66
71	BILKO ANONYMOUS		1.66
2	ACE GOLDFINGER		1.66
21	AMERICAN CIRCUS		1.66
48	BACKLASH UNDEFEATED	1.66
126	CASUALTIES ENCINO	1.66

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc, 2
limit 10

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc
fetch first 10 rows only

fetch first 10 rows only = limit 10

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc
fetch first 10 rows with ties

3.2.1 Вывести топ-1 самых дорогих фильмов по стоимости за день аренды, то есть вывести все 62 фильма
--начиная с 13 версии

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc
fetch first 63 rows with ties

3.3 Вывести топ-10 самых дорогих фильмов по стоимости аренды за день, начиная с 58-ой позиции
- воспользуйтесь Limit и offset

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc
offset 57
limit 10


3.3* Вывести топ-15 самых низких платежей, начиная с позиции 14000
- воспользуйтесь Limit и offset

select *
from payment 
order by amount
offset 13999
limit 15

4. Вывести все уникальные годы выпуска фильмов
- воспользуйтесь distinct

select distinct release_year
from film 

select release_year
from film 
group by release_year

4* Вывести уникальные имена покупателей
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- воспользуйтесь distinct

select first_name --599
from customer 

select distinct first_name --591
from customer 

select distinct first_name, last_name --599
from customer 

cost 47.12 
time 0.267

explain analyze --47.12
select distinct customer_id, first_name 
from customer 
order by 1

explain analyze --37.26
select customer_id, first_name
from customer 
order by 1

4.1 нужно получить последний платеж каждого пользователя

select distinct on (customer_id) *
from payment 
order by customer_id, payment_date desc

select distinct on (customer_id, amount) *
from payment 
order by customer_id, amount, payment_date desc

5.1. Вывести весь список фильмов, имеющих рейтинг 'PG-13', в виде: "название - год выпуска"
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- "||" - оператор конкатенации, отличие от concat
- where - конструкция фильтрации
- "=" - оператор сравнения

text 
varchar(N) varchar(75) 0-75 varchar(8000)
char(N) char(10) 'xxxxx' -> 'xxxxx     '

select last_name, first_name, middle_name
from person 
where first_name = 'Николай'

select last_name || ' ' || first_name || ' ' || middle_name
from person 
where first_name = 'Николай'

select concat(last_name, ' ', first_name, ' ', middle_name)
from person 
where first_name = 'Николай'

select concat_ws(' ', last_name, first_name, middle_name)
from person 
where first_name = 'Николай'

select 2 + null

select 'Hello' || null

select concat('Hello', null)

номер | серия

номер || серия = null 

select concat(title, ' - ', release_year), rating
from film 
where rating = 'PG-13'

5.2 Вывести весь список фильмов, имеющих рейтинг, начинающийся на 'PG'
- cast(название столбца as тип) - преобразование
- like - поиск по шаблону
- ilike - регистронезависимый поиск
- lower
- upper
- length

like - регистрозависимый
ilike - регистронезависимый

% - от 0 до N символов
_ - один любой символ

select concat(title, ' - ', release_year), rating
from film 
where rating like 'PG%'

select concat(title, ' - ', release_year), pg_typeof(rating)
from film 

SQL Error [42883]: ОШИБКА: оператор не существует: mpaa_rating like unknown

select concat(title, ' - ', release_year), rating
from film 
where rating::text like 'PG%'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like '%7'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like 'P%3'

select concat(title, ' - ', release_year), rating
from film 
where rating::text like '%-%'

select concat(title, ' - ', release_year), rating
from film 
where not rating::text like '%-%'

select concat(title, ' - ', release_year), rating
from film 
where rating::text not like '%-%'

select concat_ws(' ', last_name, first_name, middle_name)
from person 
where last_name ilike 'а__к%в'

select concat_ws(' ', last_name, first_name, middle_name)
from person 
where last_name ilike 'а__________а'

select concat_ws(' ', last_name, first_name, middle_name)
from person 
where last_name ilike 'а%а' and char_length(last_name) = 12

select concat_ws(' ', last_name, first_name, middle_name)
from person 
where lower(last_name) like 'а%а' and char_length(last_name) = 12

select initcap(upper(lower(concat_ws(' ', last_name, first_name, middle_name))))
from person 

select initcap('aaaBBB.cCc7DdD eee!FfF')
				Aaabbb.Ccc7ddd Eee!Fff
				
select *
from film
where title like '%\%%'
order by title

select *
from film
where title like '%7%%' escape '7'
order by title

select ''''

5.2* Получить информацию по покупателям с именем содержашим подстроку'jam' (независимо от регистра написания),
в виде: "имя фамилия" - одной строкой.
- "||" - оператор конкатенации
- where - конструкция фильтрации
- ilike - регистронезависимый поиск
- strpos
- character_length
- overlay
- substring
- split_part

select *
from customer 
where first_name ilike '%jam%'

select strpos('hello world', 'world')

select substring('hello world' from 3 for 5)

select substring('hello world', 3, 5)

select substring('hello world', 3)

select left('hello world', 3)

select left('hello world', -3)

select right('hello world', 3)

select right('hello world', -3)

select split_part(concat_ws(' ', last_name, first_name, middle_name), ' ', 1),
	split_part(concat_ws(' ', last_name, first_name, middle_name), ' ', 2),
	split_part(concat_ws(' ', last_name, first_name, middle_name), ' ', 3)
from person 

Литвинова Амелия Егоровна

Литвинова 1
Амелия 2
Егоровна 3

select split_part('hello world', 'l', 1)

select substring('hello world', 1, strpos('hello world', 'l'))

select concat_ws(' ', last_name, first_name, middle_name), 
	replace(concat_ws(' ', last_name, first_name, middle_name), 'Николай', 'Nikolay')
from person 
where first_name = 'Николай'

select concat_ws(' ', last_name, first_name, middle_name), 
	overlay(concat_ws(' ', last_name, first_name, middle_name)
		placing 'Nikolay'
		from strpos(concat_ws(' ', last_name, first_name, middle_name), 'Николай') + 3
		for char_length('Николай') - 5)
from person 
where first_name = 'Николай'

select character_length('Привет мир'), char_length('Привет мир'), length('Привет мир'), octet_length('Привет мир')

6. Получить id покупателей, арендовавших фильмы в срок с 27-05-2005 включительно по 28-05-2005 включительно
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- between - задает промежуток (аналог ... >= ... and ... <= ...)
- date_part()
- date_trunc()
- interval

select now()

2024-02-29 21:14:15.590164+03

timestamp
time
date
timestamptz
timetz

01.01.2024

show lc_time --Russian_Russia.1251

yyyy.mm.dd
dd.mm.yyyy

select '13.01.2024'::date

select '2024-02-29 21:14:15.590164+09'::timestamptz
		2024-02-29 15:14:15.590164+03	
		2024-02-29 21:14:15.590164+09
		2024-02-29 15:14:15.590164+03
		
set time zone 'utc-9'

set time zone 'utc-3'

--ложный запрос
select rental_id, rental_date
from rental
where rental_date >= '27-05-2005' and rental_date <= '28-05-2005'
order by rental_date desc

--ложный запрос 
select rental_id, rental_date
from rental
where rental_date between '27-05-2005' and '28-05-2005'
order by rental_date desc

 27-05-2005 >= rental_date >= 28-05-2005

--можно, но не нужно
select rental_id, rental_date
from rental
where rental_date between '27-05-2005' and '29-05-2005'
order by rental_date desc

select rental_id, rental_date
from rental
where rental_date between '27-05-2005' and '28-05-2005'::date + interval '1 day'
order by rental_date desc

select rental_id, rental_date
from rental
where rental_date between '27-05-2005' and '28-05-2005 24:00:00'
order by rental_date desc

--как нужно
select rental_id, rental_date
from rental
where rental_date::date between '27-05-2005' and '28-05-2005'
order by rental_date desc

6* Вывести платежи поступившие после 2005-07-08
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- > - строгое больше (< - строгое меньше)

select *
from payment 
where payment_date::date > '2005-07-08'
order by payment_date

extract() --субъективно лучше не использовать

select date_part('year', '2024-02-29 21:14:15.590164+09'::timestamptz),
	date_part('month', '2024-02-29 21:14:15.590164+09'::timestamptz),
	date_part('day', '2024-02-29 21:14:15.590164+09'::timestamptz),
	date_part('hours', '2024-02-29 21:14:15.590164+09'::timestamptz),
	date_part('minutes', '2024-02-29 21:14:15.590164+09'::timestamptz),
	date_part('seconds', '2024-02-29 21:14:15.590164+09'::timestamptz),
	date_part('quarter', '2024-02-29 21:14:15.590164+09'::timestamptz),
	date_part('week', '2024-02-29 21:14:15.590164+09'::timestamptz),
	date_part('isodow', '2024-02-29 21:14:15.590164+09'::timestamptz),
	date_part('epoch', '2024-02-29 21:14:15.590164+09'::timestamptz)
	
date_part('year', ...) + date_part('month', ...)
	
century
decade
doy
julian
millennium

select to_char('2024-02-29 21:14:15.590164+09'::timestamptz, 'dd-month-yyyy')

select date_trunc('year', '2024-02-29 21:14:15.590164+09'::timestamptz),
	date_trunc('month', '2024-02-29 21:14:15.590164+09'::timestamptz),
	date_trunc('day', '2024-02-29 21:14:15.590164+09'::timestamptz),
	date_trunc('hours', '2024-02-29 21:14:15.590164+09'::timestamptz),
	date_trunc('minutes', '2024-02-29 21:14:15.590164+09'::timestamptz),
	date_trunc('seconds', '2024-02-29 21:14:15.590164+09'::timestamptz),
	date_trunc('quarter', '2024-02-29 21:14:15.590164+09'::timestamptz),
	date_trunc('week', '2024-02-29 21:14:15.590164+09'::timestamptz)

date_trunc('month', ...)

select date_trunc('month', '15.03.2024'::date) + interval '+ 1 month - 1 day + 12 hours - 5 minutes'
	
7. Получить количество дней с '17-04-2007' по сегодняшний день.
Получить количество месяцев с '17-04-2007' по сегодняшний день.
Получить количество лет с '17-04-2007' по сегодняшний день.

select now()

select current_timestamp

select current_time

select current_date 

select current_user 

select current_schema

timestamp - timestamp = interval 
date - date = integer

--дни:
select current_date - '17-04-2007' --6162

--Месяцы:
select date_part('year', age('17-04-2007'::date)) * 12 + date_part('month', age('17-04-2007'::date))

--Года:
select date_part('year', age('17-04-2007'::date))

--select (current_date - '17-04-2007') / 365.25 --ПЛОХО !!!!!!!

select current_timestamp - '17-04-2007'

select age(current_date, '17-04-2007')

select date_part('year', age('17-04-2007'::date))

8. Булев тип

true 1 't' 'yes'
false 0 'f' 'no'

'yes'::boolean

select *
from customer 
where activebool
order by customer_id

select *
from customer 
where activebool = true
order by customer_id

select *
from customer 
where activebool = false
order by customer_id

select abs('17-04-2007' - current_date)

select *
from customer 
where activebool = null --ОШИБКА !!!!!!!!!!!

select *
from customer 
where activebool is not null

select *
from customer 
where activebool is true
order by customer_id

select *
from customer 
where activebool is false
order by customer_id

9 Логические операторы and и or

оператор and имеет приоритет работы перед оператором or !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

select customer_id, amount
from payment 
where customer_id = 1 or customer_id = 2 and amount = 2.99 or amount = 4.99

	a + b * c + d

and = *
or = +

select customer_id, amount
from payment 
where (customer_id = 1 or customer_id = 2) and (amount = 2.99 or amount = 4.99)

	(a + b) * (c + d)

/*	
select customer_id, amount
from payment 
where customer_id = 1 or 2 and amount = 2.99 or 4.99
*/
	
select concat_ws(' ', last_name, first_name, middle_name)
from person 
where (left(first_name, 1) = 'А' and left(last_name, 1) = 'А') or (left(first_name, 1) = 'В' and left(last_name, 1) = 'В')


select concat_ws(' ', last_name, first_name, middle_name)
from person 
where left(first_name, 1) = 'А' or left(first_name, 1) = 'В'

4809