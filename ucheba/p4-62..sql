======================== Создание таблиц ========================

select 
insert 
update 
delete 

create 
alter 
drop 

https://dbdiagram.io/, https://sqldbm.com, https://pgmodeler.io

create database название_базы_данных

create schema lecture_4

set search_path to lecture_4

1. Создайте таблицу "автор" с полями:
- id 
- имя
- псевдоним (может не быть)
- дата рождения
- город рождения
- родной язык
* Используйте 
    CREATE TABLE table_name (
        column_name TYPE column_constraint,
    );
* для id подойдет serial, ограничение primary key
* Имя и дата рождения - not null
* город и язык - внешние ключи

create table author (
	author_id serial primary key,
	author_name varchar(100) not null,
	nick_name varchar(30),
	born_date date not null check (date_part('year', born_date) >= 1800 and born_date <= current_date),
	born_city_id int2 not null references city(city_id),
	--language_id int2 not null references language(language_id),
	created_at timestamp not null default current_timestamp,
	created_user varchar(64) not null default current_user,
	deleted boolean not null default false--,
	--last_update
	--deleted int2 not null default 0 check (deleted in (0, 1, 2))
)

delete from author -> update -> true

serial = integer + sequence + default nextval(sequence)

select a.id, t1.id, t2.id, t2.id, a.name, t1.name, t2.name, t2.name
from author
join table_1	id = id 
join table_2    id = id
join table_3 	id = id

varchar(50)
varchar(8000)

1 млн строк 45-50 символов

1гб - 20гб

25 + 20 + 25 = 70 + 30% = 91 = 100

pay_id | user_name | city | amount | pay_date
3		ППП			Питер
5		ИИИ			Самара

uuid = guid

select gen_random_uuid() --version 4

ba95b5f3-893d-43e2-9c48-dabed57bf346 + scram-sha-256
8 - 4 - 4 - 4 - 12

serial8
1
2
3
4
5

--city_id = addres_id

id uuid default gen_random_uuid()

id uuid default uuid_generate_v1()

create extension "uuid-ossp"

select uuid_generate_v1()

0b53f1c6-dca3-11ee-9133-13bc7af26ef1
0dde3708-dca3-11ee-9134-dbeb0dd54515
0f9cc028-dca3-11ee-9135-d71d547a39b8

select uuid_generate_v4()

2aa0c1a7-5286-4262-b12f-d60d40342348
5085cab8-a0b7-4ce9-9437-3d3ab358a6c4

varchar(24)

1*  Создайте таблицы "Язык", "Город", "Страна".
* для id подойдет serial, ограничение primary key
* названия - not null и проверка на уникальность

create table city (
	city_id serial2 primary key,
	city_name varchar(50) not null,
	country_id int2 not null references country(country_id))

create table country (
	country_id serial2 primary key,
	country_name varchar(50) not null unique)

create table language (
	language_id serial2 primary key,
	language_name varchar(50) not null unique)
	
drop table language

== Отношения / связи ==
А		Б
один к одному  		Б является атрибутом А
один ко многим		А и Б два отдельных справочника
многие ко многим	в реляционной модели не существует, реализуется через два отношения один 
					ко многим А-В и В-Б
					
create table author (
	author_id serial primary key,
	author_name varchar(100) not null,
	--язык_на_котором_издавался
	
1 ИИИ русский
1 ИИИ французском

create table language (
	language_id serial2 primary key,
	language_name varchar(50) not null unique)
	
author_language
			
--ТАК ДЕЛАТЬ НЕЛЬЗЯ, ПЛОХО, ПИШЕМ ТОЛЬКО ДЛЯ ПРАКТИКИ И ПОНИМАНИЯ
create table author_language (
	author_id int unique,
	language_id int unique)
	
a_id l_id
1	2
2	1
3	4
4	5

--ТАК ДЕЛАТЬ НЕЛЬЗЯ, ПЛОХО, ПИШЕМ ТОЛЬКО ДЛЯ ПРАКТИКИ И ПОНИМАНИЯ
create table author_language (
	author_id int,
	language_id int unique)
	
a_id l_id
1	2
2	1
2	4
1	5

--ТАК ДЕЛАТЬ НЕЛЬЗЯ, ПЛОХО, ПИШЕМ ТОЛЬКО ДЛЯ ПРАКТИКИ И ПОНИМАНИЯ
create table author_language (
	author_id int unique,
	language_id int )
	
a_id l_id
1	1
2	1
3	2
4	2

--ТАК ДЕЛАТЬ НУЖНО
create table author_language (
	author_id int references author(author_id),
	language_id int references language(language_id),
	primary key (author_id, language_id))
	
a_id l_id
1	1
1	2
2	1
2	2

======================== Заполнение таблицы ========================

2. Вставьте данные в таблицу с языками:
'Русский', 'Французский', 'Японский'
* Можно вставлять несколько строк одновременно:
    INSERT INTO table (column1, column2, …)
    VALUES
     (value1, value2, …),
     (value1, value2, …) ,...;

select * from "language" l

insert into "language" (language_name)
values ('Русский'), ('Французский'), ('Японский')

insert into "language" 
values (4, 'Монгольский')

insert into "language" (language_name)
values ('Финский')

SQL Error [23505]: ОШИБКА: повторяющееся значение ключа нарушает ограничение уникальности "language_pkey"
  Подробности: Ключ "(language_id)=(4)" уже существует.
  
-- демонстрация работы счетчика и сброс счетчика

alter sequence language_language_id_seq restart with 3521

alter sequence language_language_id_seq restart with 1

insert into "language" (language_name)
values ('Канадский')

delete from language
where language_id = 4

drop table language

create table language (
	language_id int2 primary key generated always /*default*/ as identity,
	language_name varchar(50) not null unique)
	

insert into "language" (language_name)
values ('Русский'), ('Французский'), ('Японский')

insert into "language" 
values (4, 'Монгольский')

SQL Error [428C9]: ОШИБКА: в столбец "language_id" можно вставить только значение по умолчанию
  Подробности: Столбец "language_id" является столбцом идентификации со свойством GENERATED ALWAYS.
  Подсказка: Для переопределения укажите OVERRIDING SYSTEM VALUE.
  
insert into "language" 
--overriding system value
values (4, 'Монгольский')

insert into "language" (language_name)
values ('Финский')

select * from "language" l
	
--Работает начиная с 13 версии PostgreSQL - stored

create table some_pay (
	pay_id int primary key generated always as identity,
	cost_per_one numeric,
	qty numeric,
	total_amount_wo_nds numeric generated always as ( round(cost_per_one * qty / 1.2, 2)) stored)
	
insert into some_pay (cost_per_one, qty)
values (1000,3), (500, 2)

select * from some_pay

2.1 Вставьте данные в таблицу со странами из таблиц country базы dvd-rental:

select * from country c

insert into country
select country_id, country 
from public.country c

alter sequence country_country_id_seq restart with 110

2.2 Вставьте данные в таблицу с городами соблюдая связи из таблиц city базы dvd-rental:

select * from city c

insert into city (city_name, country_id)
select city, country_id
from public.city c

2.3 Вставьте данные в таблицу с авторами, идентификаторы языков и городов оставьте пустыми.
Жюль Верн, 08.02.1828
Михаил Лермонтов, 03.10.1814
Харуки Мураками, 12.01.1949

select * from author a

insert into author (author_name, nick_name, born_date, born_city_id)
values ('Жюль Верн', null, '08.02.1828', 345),
	('Михаил Лермонтов', 'Гр. Диарбекир', '03.10.1814', 1),
	('Харуки Мураками', null, '12.01.1549', 123)

SQL Error [23514]: ОШИБКА: новая строка в отношении "author" нарушает ограничение-проверку "author_born_date_check"
  Подробности: Ошибочная строка содержит (3, Харуки Мураками, null, 1549-01-12, 123, 2024-03-07 20:28:14.071044, postgres, f).

  insert into author (author_name, nick_name, born_date, born_city_id)
values ('Жюль Верн', null, '08.02.1828', 345),
	('Михаил Лермонтов', 'Гр. Диарбекир', '03.10.1814', 1),
	('Харуки Мураками', null, '12.01.1849', 123)

======================== Модификация таблицы ========================

3. Добавьте поле "идентификатор языка" в таблицу с авторами
* ALTER TABLE table_name 
  ADD COLUMN new_column_name TYPE;

select * from author a
 
-- добавление нового столбца
alter table author add column language_id int2

-- удаление столбца
alter table author drop column language_id 

-- добавление ограничения not null
alter table author alter column language_id set not null
 
-- удаление ограничения not null
alter table author alter column language_id drop not null

-- добавление ограничения unique
alter table author add constraint author_name_unique unique (author_name)

-- удаление ограничения unique
alter table author drop constraint author_name_unique

-- изменение типа данных столбца
alter table author alter column language_id type varchar(25)

alter table author alter column language_id type varchar(35)

alter table author alter column language_id type int2

alter table author alter column language_id type int2 using(language_id::int2)

'100aa'

-- добавление ограничения внешнего ключа
alter table author add constraint author_language_pkey foreign key (language_id) references language(language_id)

select *
from information_schema.table_constraints tc
where table_schema = 'lecture_4' and constraint_name like '%_pkey' --constraint_type = 'PRIMARY KEY'

alter table author drop constraint author_language_pkey 

alter table author add constraint author_language_fkey foreign key (language_id) references language(language_id)

 ======================== Модификация данных ========================

4. Обновите данные, проставив корректное языки писателям:
Жюль Габриэль Верн - Французский
Михаил Юрьевич Лермонтов - Российский
Харуки Мураками - Японский

select * from author a

4	Жюль Верн
5	Михаил Лермонтов
6	Харуки Мураками

select * from "language" l

1	Русский
2	Французский
3	Японский

insert 
update

update author
set language_id = 1
where author_id = 5

update author
set language_id = 2

update author
set language_id = 3, nick_name = 'отсутствует', born_city_id = 321
where author_id = 6

update author
set language_id = (select ...), nick_name = 'отсутствует', born_city_id = 321
where author_id in (select ...)

 ======================== Удаление данных ========================
 
5. Удалите Лермонтова

delete from author
where author_id = 5

select *
from city c
where city_id = 321

truncate author, "language", city, country

select * from country a

5.1 Удалите все страны

delete from country
where country_id = 90

SQL Error [23503]: ОШИБКА: UPDATE или DELETE в таблице "country" нарушает ограничение внешнего ключа "city_country_id_fkey" таблицы "city"
  Подробности: На ключ (country_id)=(90) всё ещё есть ссылки в таблице "city".
  
drop table language

drop schema lecture_4 cascade

drop database

cascade

========================================================================================================================

create schema lecture_4

--РОДИТЕЛЬСКАЯ
create table country (
	country_id serial2 primary key,
	country_name varchar(50) not null unique)
	
insert into country
select country_id, country 
from public.country c

--ДОЧЕРНЯЯ
create table city (
	city_id serial2 primary key,
	city_name varchar(50) not null,
	country_id int2 default 3 references country(country_id) on delete set default on update set null)
	
cascade
restrict 
no action 
set default 
set null
	
insert into city (city_name, country_id)
select city, country_id
from public.city c

select * from country 

select * from city 

select *
from information_schema.table_constraints tc
where table_schema = 'lecture_4' and constraint_type = 'FOREIGN KEY'

drop table country cascade

drop table city cascade

delete from country 

truncate country cascade

truncate cascade - удалим данные в дочерней таблице, сохраним FK

drop table country cascade

drop cascade - удалим АЛ, сохраним данные в дочерней таблице

delete from country
where country_id = 1

update country
set country_id = 3000
where country_id = 2

delete cascade - удалим данные в дочерней таблице, сохраним FK

========================================================================================================================

create temporary table table_name as (
	select *
	from information_schema.table_constraints tc
	where table_schema = 'lecture_4' and constraint_type = 'FOREIGN KEY')
	
select * from table_name

select *
from payment 

create table pay_new (like payment)

select * from pay_new

drop table pay_new

create table pay_new (like payment including all)

explain analyze --320.94 / 2 
select distinct customer_id
from payment 
where amount > 10

explain analyze --346.36 / 3.2 
select distinct customer_id
from payment 
where amount < 4

explain analyze --325.60 / 2.8 
select distinct customer_id
from payment 

create table pay_new (like payment) partition by range (amount)

create table pay_low partition of pay_new for values from (minvalue) to (5)

create table pay_mid partition of pay_new for values from (5) to (10)

create table pay_high partition of pay_new for values from (10) to (maxvalue) 

insert into pay_new
select * from payment

explain analyze --30.13 / 0.06 
select distinct customer_id
from pay_new 
where amount > 10

select 2 / 0.06

explain analyze --262.91 / 2.9
select distinct customer_id
from pay_new 
where amount < 4

explain analyze --401.86 / 3.8 
select distinct customer_id
from pay_new 

select * --3 843
from pay_mid

select *
from only pay_new 

create table customer_new (like customer) partition by list (lower(left(last_name, 1)))

create table customer_a_g partition of customer_new for values in ('a', 'b', 'c', 'd', 'e', 'f', 'g')

create table customer_h_q partition of customer_new for values in ('h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q')

create table customer_r_z partition of customer_new for values in ('r', 's', 't', 'u', 'y', 'v', 'w', 'x', 'z') 

insert into customer_new
select * from customer

explain analyze --20.23 / 0.3
select *
from customer c
where lower(left(last_name, 1)) in ('a', 'b', 'c')

explain analyze --8.22 / 0.12
select *
from customer_new c
where lower(left(last_name, 1)) in ('a', 'b', 'c')

create temporary table qwerty as (
	select *
	from customer_new c
	where lower(left(last_name, 1)) in ('h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q')
)

drop table customer_h_q

create table customer_h_l partition of customer_new for values in ('h', 'i', 'j', 'k', 'l')

create table customer_m_q partition of customer_new for values in ('m', 'n', 'o', 'p', 'q')

insert into customer_new
select * from qwerty

select *
from customer_m_q