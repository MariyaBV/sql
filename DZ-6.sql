--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;


create table table_one (
	name_one varchar(255) not null
);

create table table_two (
	name_two varchar(255) not null
);

insert into table_one (name_one)
values ('one'), ('two'), ('three'), ('four'), ('five');

insert into table_two (name_two)
values ('four'), ('five'), ('six'), ('seven'), ('eight');

select * from table_one;

select * from table_two;

select t1.name_one, t2.name_two
from table_one t1 
cross join table_two t2

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".

explain analyze --67.50 / 0.44
select *, special_features 
from film f 
where special_features @> array['Behind the Scenes']


--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.

explain analyze --77.50 / 0.40
select *, special_features 
from film f 
where 'Behind the Scenes' =  any(special_features)

explain analyze --67.50 / 0.46
select *, special_features 
from film f 
where special_features && array['Behind the Scenes', '1234456']

--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

explain analyze --854.16 / 8.930
--explain (format json, analyze)
with cte as (
	select special_features, f.film_id
	from film f 
	where special_features @> array['Behind the Scenes']
)
select r.customer_id, COUNT(r.rental_id) as film_count
from rental r
join inventory i on i.inventory_id = r.inventory_id
join cte on cte.film_id = i.film_id
right join customer c on r.customer_id = c.customer_id 
where cte.film_id = i.film_id 
group by r.customer_id
order by r.customer_id

--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

explain analyze -- 720.75 / 11.575
select r.customer_id, COUNT(r.rental_id) as film_count
from rental r
join inventory i on i.inventory_id = r.inventory_id
join (
	select special_features, f.film_id
	from film f 
	where special_features @> array['Behind the Scenes']
) as t1 on t1.film_id = i.film_id
right join customer c on r.customer_id = c.customer_id 
where t1.film_id = i.film_id 
group by r.customer_id
order by r.customer_id

--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

create materialized view mat_film_count_bts as 
	select r.customer_id, COUNT(r.rental_id) as film_count
	from rental r
	join inventory i on i.inventory_id = r.inventory_id
	join (
		select special_features, f.film_id
		from film f 
		where special_features @> array['Behind the Scenes']
	) as t1 on t1.film_id = i.film_id
	right join customer c on r.customer_id = c.customer_id 
	where t1.film_id = i.film_id 
	group by r.customer_id
	order by r.customer_id
with no data

refresh materialized view mat_film_count_bts 

select * from mat_film_count_bts

--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ стоимости выполнения запросов из предыдущих заданий и ответьте на вопросы:
--1. с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания: 
--поиск значения в массиве затрачивает меньше ресурсов системы;
--2. какой вариант вычислений затрачивает меньше ресурсов системы: 
--с использованием CTE или с использованием подзапроса.

/* 1) any стоит дороже && и @>, но выполняется быстрее
 * 2) CTE стоит дороже, но выполняется быстрее чем подзапрос
 */

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

--explain analyze --8600.22 / 38.107
--explain (format json, analyze)
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

/*Сделайте explain analyze этого запроса.
- Основываясь на описании запроса, найдите узкие места и опишите их.
-- Subquery Scan (inv.sf_string ~~ '%Behind the Scenes%'::text) costliest - самое дорогое сканирование по всем данным с поиском входящих слов
получается стали искать сравнивая входящую строку с большим объемом данных
-- unnest(f.special_features) - увеличивает кол-во строк в 2 раза
-- full outer join  r.inventory_id = inv.inventory_id - bad estimate - увелечение объема строк при full join
-- Nested Loop Left Join  (cost=8212.35..8596.30 rows=46 width=21) (actual time=6.777..23.612 rows=8632 loops=1) - 
join ren.cid = cu.customer_id  -  bad estimate - slowest самый медленный момент - перебирает каждую запись 
в первом наборе и пытаясь найти совпадение во втором наборе. Возвращаются все соответствующие записи.
-- SORT by (count(r.inventory_id) OVER ()) DESC,((((cu.first_name)::text || ' '::text) || (cu.last_name)::text)) и SORT by 
cu.customer_id в окнной функции - при условии что уже провели много не правильных join и получили много строк - bad estimate


- Сравните с вашим запросом из основной части (если ваш запрос изначально укладывается в 15мс — отлично!).
В моем запросе нет ошибочных моментов bad estimate, самое долгое это сканирование по rental - это нужно 
и медленный join по	(r.inventory_id = i.inventory_id) - это тоже нужно

- Сделайте построчное описание explain analyze на русском языке оптимизированного запроса.
на примере
explain analyze цена 854.16 / время 8.930
with cte as (
	select special_features, f.film_id
	from film f 
	where special_features @> array['Behind the Scenes']
)
select r.customer_id, COUNT(r.rental_id) as film_count
from rental r
join inventory i on i.inventory_id = r.inventory_id
join cte on cte.film_id = i.film_id
right join customer c on r.customer_id = c.customer_id 
where cte.film_id = i.film_id 
group by r.customer_id
order by r.customer_id

1) сперва скан по inventory Seq Scan on inventory i  (cost=0.00..70.81 rows=4581 width=6) (actual time=0.004..0.445 rows=4581 loops=1)
2) паралелльно проходит CTE scan и hash
CTE Scan on cte  (cost=0.00..10.76 rows=538 width=4) (actual time=0.010..0.560 rows=538 loops=1)
Hash  (cost=70.81..70.81 rows=4581 width=6) (actual time=0.970..0.970 rows=4581 loops=1)
3) происходит inner join  (cte.film_id = i.film_id) c помощью hash индексов Hash Join  (cost=128.07..172.01 rows=2578 width=4) (actual time=1.018..1.868 rows=2471 loops=1)
4) сканируется по rental Seq Scan on rental r  (cost=0.00..310.44 rows=16044 width=10) (actual time=0.005..1.167 rows=16044 loops=1)
в это же время происходит вызов Hash  (cost=172.01..172.01 rows=2578 width=4) (actual time=2.178..2.178 rows=2471 loops=1)
5) для дальнейшего Inner join по HASH JOIN (r.inventory_id = i.inventory_id) Hash Join  (cost=204.23..660.05 rows=9029 width=6) (actual time=2.206..5.878 rows=8608 loops=1)
6) HASH JOIN  Inner join по (r.customer_id = c.customer_id) Hash Join  (cost=226.71..706.40 rows=9029 width=6) (actual time=2.405..7.444 rows=8608 loops=1)
7) HashAggregate  (cost=751.54..757.53 rows=599 width=10) (actual time=8.827..8.895 rows=599 loops=1)
и Seq Scan on film f  (cost=0.00..67.50 rows=538 width=63) (actual time=0.008..0.416 rows=538 loops=1)
паралелльно group by r.customer_id и сканирование where special_features @> array['Behind the Scenes']
8) сортировка   order by r.customer_id

**/

explain analyze --654.22 / 23.823
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

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.

select pp.staff_id, f.film_id , f.title , pp.amount, pp.payment_date, c.last_name as customer_last_name, c.first_name as customer_first_name
from (select *, row_number() over (partition by p.staff_id order by p.payment_date)
	from payment p) pp
join rental r on pp.rental_id = r.rental_id 
join customer c on r.customer_id = c.customer_id 
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id 
where row_number = 1

--ЗАДАНИЕ №3 
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день

explain analyze --7436.78/ 132.581
with cte as (select *, count(i.film_id) over (partition by i.store_id, r.rental_date::date),
				sum(p.amount) over (partition by i.store_id order by p.payment_date::date)
			 from inventory i 
			 join rental r on r.inventory_id = i.inventory_id 
			 full join payment p on p.rental_id = r.rental_id)
select t1.store_id, t1.den_kogda_arendovali_bolshe_vsego, t1.kolvo_filmov_vzyatih_v_etot_den, 
	t2.den_kogda_arendovali_na_min_sum, t2.min_sum_v_etot_den
from (select cte.store_id, cte.payment_date::date as "den_kogda_arendovali_bolshe_vsego", cte.count as "kolvo_filmov_vzyatih_v_etot_den"
	from cte
	where cte.store_id = 2 and cte.count = (select max(cte.count) from cte where cte.store_id = 2)
	group by cte.store_id, cte.payment_date::date, cte.count) as t1
join 		
	(select cte.store_id, cte.payment_date::date as "den_kogda_arendovali_na_min_sum", cte.sum as "min_sum_v_etot_den"
	from cte
	where cte.store_id = 2 and cte.sum = (select min(cte.sum) from cte where cte.store_id = 2)
	group by cte.store_id, cte.payment_date::date, cte.sum)	t2 on t1.store_id = t2.store_id
union
select t3.store_id, t4.den_kogda_arendovali_bolshe_vsego, t4.kolvo_filmov_vzyatih_v_etot_den, 
		t3.den_kogda_arendovali_na_min_sum, t3.min_sum_v_etot_den	
from (select cte.store_id, cte.payment_date::date as "den_kogda_arendovali_na_min_sum", cte.sum as "min_sum_v_etot_den"
	from cte
	where cte.store_id = 1 and cte.sum = (select min(cte.sum) from cte where cte.store_id = 1)
	group by cte.store_id, cte.payment_date::date, cte.sum) t3
join		
	(select cte.store_id, cte.payment_date::date as "den_kogda_arendovali_bolshe_vsego", cte.count as "kolvo_filmov_vzyatih_v_etot_den"
	from cte
	where cte.store_id = 1 and cte.count = (select max(cte.count) from cte where cte.store_id = 1)
	group by cte.store_id, cte.payment_date::date, cte.count) t4 on t3.store_id = t4.store_id
	
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

explain analyze --5020.68 / 32.156
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

explain analyze --8675.69 / 63.007
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


