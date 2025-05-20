Задание 1. Посчитайте для каждого фильма, сколько раз его брали в аренду, а также общую стоимость аренды фильма за всё время.
Ожидаемый результат запроса: letsdocode.ru...in/3-7.png

--ложный запрос
explain analyze --1743.69 / 20
select f.title, f.rating, l."name", c."name", count(r.rental_id), sum(p.amount)
from film f 
left join inventory i on f.film_id = i.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
left join "language" l on l.language_id = f.language_id
left join film_category fc on f.film_id = fc.film_id
left join category c on c.category_id = fc.category_id
group by f.film_id, l.language_id, c.category_id


select *
from film_category fc

insert into film_category
values (1, 1, now()), (1, 2, now()), (1, 3, now()), (1, 4, now())

1	5
1	4
1	2
1	5
2	5
2	5
2	4

id	sum()
1	16
2	14

group by id

--верный запрос
explain analyze --1293.33 / 18
select f.title, f.rating, l."name", fc.string_agg, i.count, i.sum
from film f 
left join (
	select i.film_id, count(r.rental_id), sum(p.amount)
	from inventory i 
	left join rental r on r.inventory_id = i.inventory_id
	left join payment p on p.rental_id = r.rental_id
	group by i.film_id) i on f.film_id = i.film_id
left join "language" l on l.language_id = f.language_id
left join (
	select fc.film_id, string_agg(c.name, ', ')
	from film_category fc 
	left join category c on c.category_id = fc.category_id
	group by fc.film_id) fc on f.film_id = fc.film_id
	
Задание 2. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые отсутствуют на dvd-дисках.
Ожидаемый результат запроса: letsdocode.ru...in/3-8.png

--ложный запрос
explain analyze --1783.82 / 20
select f.title, f.rating, l."name", c."name", count(r.rental_id), sum(p.amount)
from film f 
left join inventory i on f.film_id = i.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
left join "language" l on l.language_id = f.language_id
left join film_category fc on f.film_id = fc.film_id
left join category c on c.category_id = fc.category_id
group by f.film_id, l.language_id, c.category_id
having count(r.rental_id) = 0

--ложный запрос
explain analyze --592.44 / 3.4
select f.title, f.rating, l."name", c."name", count(r.rental_id), sum(p.amount)
from film f 
left join inventory i on f.film_id = i.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
left join "language" l on l.language_id = f.language_id
left join film_category fc on f.film_id = fc.film_id
left join category c on c.category_id = fc.category_id
where i.film_id is null
group by f.film_id, l.language_id, c.category_id

explain analyze --1295.49 / 18
select f.title, f.rating, l."name", fc.string_agg, i.count, i.sum
from film f 
left join (
	select i.film_id, count(r.rental_id), sum(p.amount)
	from inventory i 
	left join rental r on r.inventory_id = i.inventory_id
	left join payment p on p.rental_id = r.rental_id
	group by i.film_id) i on f.film_id = i.film_id
left join "language" l on l.language_id = f.language_id
left join (
	select fc.film_id, string_agg(c.name, ', ')
	from film_category fc 
	left join category c on c.category_id = fc.category_id
	group by fc.film_id) fc on f.film_id = fc.film_id
where i.film_id is null

explain analyze --631.649 / 4.2
select f.title, f.rating, l."name", fc.string_agg, f.count, f.sum
from (
	select f.film_id, f.title, f.language_id, f.rating, count(r.rental_id), sum(p.amount)
	from film f 
	left join inventory i on f.film_id = i.film_id
	left join rental r on r.inventory_id = i.inventory_id
	left join payment p on p.rental_id = r.rental_id
	where i.film_id is null
	group by f.film_id) f
left join "language" l on l.language_id = f.language_id
left join (
	select fc.film_id, string_agg(c.name, ', ')
	from film_category fc 
	left join category c on c.category_id = fc.category_id
	group by fc.film_id) fc on f.film_id = fc.film_id

select i.*
from inventory i
left join rental r on i.inventory_id = r.inventory_id
where r.rental_id is null

payment - по каким арендам не было платежей
rental - какие диски не сдавали в аренду
inventory - фильмы, которых нет на дисках

Задание 3. Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 7 300, 
то значение в колонке будет «Да», иначе должно быть значение «Нет».
Ожидаемый результат запроса: letsdocode.ru...in/3-9.png

--ложный запрос
select staff_id, count(payment_id),
	case
		when count(payment_id) > 7300 then 'yes'
		else 'no'
	end	
from payment
group by staff_id

--ложный запрос
select s.staff_id, count(p.payment_id),
	case
		when count(p.payment_id) > 7300 then 'yes'
		else 'no'
	end	
from payment p
join staff s on s.staff_id = p.staff_id
group by s.staff_id

--верный запрос
select s.staff_id, count(p.payment_id),
	case
		when count(p.payment_id) > 7300 then 'yes'
		else 'no'
	end	
from payment p
right join staff s on s.staff_id = p.staff_id
group by s.staff_id

select *
from staff s

insert into staff
values (3,	'new Mike',	'new Hillyer',	3,	'Mike.Hillyer@sakilastaff.com',	1,	true,	'Mike',	'8cb2237d0679ca88db6464eac60da96345513964',	'2006-02-15 04:57:16', null)

Задание 4. Посчитайте количество продаж, выполненных продавцами, которые совершали продажи. Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 7 300, 
то значение в колонке будет «Да», иначе должно быть значение «Нет».

--верным решением
select staff_id, count(payment_id), count(amount),
	case
		when count(payment_id) > 7300 then 'yes'
		else 'no'
	end	
from payment
group by staff_id

Задание 1. Создайте новую таблицу film_new со следующими полями:
· film_name — название фильма — тип данных varchar(255) и ограничение not null;
· film_year — год выпуска фильма — тип данных integer, условие, что значение должно быть больше 0;
· film_rental_rate — стоимость аренды фильма — тип данных numeric(4,2), значение по умолчанию 0.99;
· film_duration — длительность фильма в минутах — тип данных integer, ограничение not null и условие, что значение должно быть больше 0.
Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.

create table film_new (
	film_id serial primary key,
	film_name varchar(255) not null,
	film_year integer check(film_year > 0),
	film_rental_rate numeric(4,2) default 0.99,
	film_duration integer not null check(film_duration > 0))

Задание 2. Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
· film_name — array[The Shawshank Redemption, The Green Mile, Back to the Future, Forrest Gump, Schindler’s List];
· film_year — array[1994, 1999, 1985, 1994, 1993];
· film_rental_rate — array[2.99, 0.99, 1.99, 2.99, 3.99];
· film_duration — array[142, 189, 116, 142, 195].

select unnest(array[])

from unnest(array_1[], array_2[] ... array_N[])

insert into film_new(film_name, film_year, film_rental_rate, film_duration)
select *
from unnest(
	array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindler’s List'],
	array[1994, 1999, 1985, 1994, 1993],
	array[2.99, 0.99, 1.99, 2.99, 3.99],
	array[142, 189, 116, 142, 195])
	
select * from film_new

Задание 3. Обновите стоимость аренды фильмов в таблице film_new с учётом информации, что стоимость аренды всех фильмов поднялась на 1.41.

update film_new
set film_rental_rate = film_rental_rate + 1.41

Задание 4. Фильм с названием Back to the Future был снят с аренды, удалите строку с этим фильмом из таблицы film_new.

delete from film_new
where film_id = 3

Чужой
Один дома

title 				part
Back to the Future	1
Back to the Future	2
Back to the Future	3

Задание 5. Добавьте в таблицу film_new запись о любом другом новом фильме.

insert into film_new(film_name, film_year, film_rental_rate, film_duration)
values ('a', 2004, 10, 800)

Задание 6. Напишите SQL-запрос, который выведет все колонки из таблицы film_new, а также новую вычисляемую колонку «длительность фильма в часах», округлённую до десятых.

alter -- ошибка!

select *, round(film_duration / 60., 1)
from film_new

Задание 7. Удалите таблицу film_new.

drop table film_new