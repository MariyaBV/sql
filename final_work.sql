/*Итоговая работа*/
/*1. Выведите название самолетов, которые имеют менее 50 посадочных мест?*/

select a.model , a.aircraft_code, count(s.seat_no)
from seats s 
join aircrafts a on s.aircraft_code = a.aircraft_code 
group by a.aircraft_code
having count(s.seat_no) < 50

/*---------*/

select a.aircraft_code, a.model 
from (
	select aircraft_code
	from seats 
	group by aircraft_code 
	having count(seat_no) < 50) s
join aircrafts a on s.aircraft_code = a.aircraft_code 

/*2. Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых.*/

select  date_trunc('month', book_date), 
	ROUND((sum(total_amount) - (lag(sum(total_amount)) over (order by date_trunc('month', book_date)))) / (lag(sum(total_amount)) over (order by date_trunc('month', book_date))) * 100, 2) as change_sum_pct
from bookings b 
group by date_trunc('month', book_date)

/*---------*/

select date_trunc('month', book_date), sum(total_amount),
	round(sum(total_amount) * 100 / (lag(sum(total_amount)) over (order by date_trunc('month', book_date))) - 100, 2)
from bookings b
group by date_trunc('month', book_date)

/*3. Выведите названия самолетов не имеющих бизнес - класс. Решение должно быть через функцию array_agg.*/

select a.model, array_agg(distinct s.fare_conditions)
from seats s 
join aircrafts a on a.aircraft_code = s.aircraft_code
group by a.aircraft_code
having 'Business' != all(array_agg(s.fare_conditions))

/*---------*/

select a.aircraft_code, a.model 
from (
	select aircraft_code, array_agg(fare_conditions) 
	from seats
	group by aircraft_code
	having not array['Business'::varchar] && array_agg(fare_conditions)) s
join aircrafts a on s.aircraft_code = a.aircraft_code 

/*4. Вывести накопительный итог количества мест в самолетах по каждому аэропорту на каждый день, учитывая только те самолеты, 
 которые летали пустыми и только те дни, где из одного аэропорта таких самолетов вылетало более одного.
 В результате должны быть код аэропорта, дата, количество пустых мест в самолете и накопительный итог.*/

select *, sum(t1.empty_seats) over (partition by t1.departure_airport, date_part('day', t1.actual_departure) order by t1.actual_departure) 
from (select distinct  nul_flight.departure_airport, nul_flight.actual_departure, 
		count(s.seat_no) over (partition by a.aircraft_code) as empty_seats
	from (	select *
			from (select f.departure_airport, f.actual_departure, f.aircraft_code,
					count(f.flight_id) over (partition by f.departure_airport, f.actual_departure::date)
				from boarding_passes bp 
				right join flights f on f.flight_id = bp.flight_id 
				where bp.boarding_no is null and f.actual_departure is not null)
			where count > 1
			) as nul_flight
	join aircrafts a on a.aircraft_code = nul_flight.aircraft_code
	join seats s on s.aircraft_code = a.aircraft_code) as t1

/*---------*/

with c as (
	select departure_airport, actual_departure, actual_departure::date ad_date, c_s
	from flights f
	join (
		select aircraft_code, count(*) c_s
		from seats
		group by aircraft_code) s on s.aircraft_code = f.aircraft_code
	left join boarding_passes bp on bp.flight_id = f.flight_id
	where actual_departure is not null and bp.flight_id is null)
select departure_airport, ad_date, c_s, sum(c_s) over (partition by departure_airport, ad_date order by actual_departure)
from c 
where (departure_airport, ad_date) in (
	select departure_airport, ad_date
	from c 
	group by 1,2 
	having count(*) > 1)
	
	
/*5. Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов.
 Выведите в результат названия аэропортов и процентное отношение.
 Решение должно быть через оконную функцию.*/

select f.departure_airport, f.arrival_airport,
	count(*) / ((sum(count(*)) over ()) * 1.00) as percentage
from flights f 
group by f.departure_airport, f.arrival_airport

/*---------*/

select d.airport_name, a.airport_name, round(count(*) * 100. / sum(count(*)) over () , 3)
from flights f
join airports d on f.departure_airport = d.airport_code
join airports a on f.arrival_airport = a.airport_code
group by 1, 2 
	
/*6. Выведите количество пассажиров по каждому коду сотового оператора, если учесть, что код оператора - это три символа после +7*/

select substring((contact_data ->>'phone')::varchar(20) from 3 for 3) as operator_code, count(t.passenger_id) as num_passengers
from tickets t
group by substring((contact_data ->>'phone')::varchar(20) from 3 for 3)

/*---------*/

select substring(contact_data ->> 'phone', 3, 3), count(*)
from tickets 
group by 1

/*7. Классифицируйте финансовые обороты (сумма стоимости перелетов) по маршрутам:
 До 50 млн - low
 От 50 млн включительно до 150 млн - middle
 От 150 млн включительно - high
 Выведите в результат количество маршрутов в каждом полученном классе*/

select sum_price_routes, count(*)
from (select f.departure_airport, f.arrival_airport, sum(tf.amount),
		case
			WHEN sum(tf.amount) < 50000000 THEN 'low'
			WHEN (sum(tf.amount) >= 50000000) and (sum(tf.amount) < 150000000) THEN 'middle'
	        ELSE 'high' 
		end sum_price_routes
	from flights f
	join ticket_flights tf on f.flight_id = tf.flight_id 
	group by f.departure_airport, f.arrival_airport)
group by sum_price_routes

/*---------*/

select c, count(*)
from (
	select 
		case 
			when sum(tf.amount) < 50000000 then 'low'
			when sum(tf.amount) >= 50000000 and sum(tf.amount) < 150000000 then 'middle'
			else 'high'
		end c
	from flights f 
	join ticket_flights tf on tf.flight_id = f.flight_id 
	group by flight_no) t
group by c

/*8. Вычислите медиану стоимости перелетов, медиану размера бронирования и отношение медианы бронирования 
 к медиане стоимости перелетов, округленной до сотых*/

with cte1 as (
	SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY tf.amount) as median_flights
	FROM ticket_flights tf),
cte2 as (
	SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY b.total_amount) as median_bookings
	FROM bookings b)
select cte1.median_flights, cte2.median_bookings, (cte2.median_bookings/cte1.median_flights)::numeric(5,2) as ratio_median_bookings_flights
from cte1, cte2

select t1.median_flights, t2.median_bookings, (t2.median_bookings/t1.median_flights)::numeric(5,2) as ratio_median_bookings_flights
from (SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY tf.amount) as median_flights
	FROM ticket_flights tf) t1
cross join (SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY b.total_amount) as median_bookings
	FROM bookings b) t2
	
/*---------*/

select t2.mediana_bookings, t1.mediana_tickets, round(t2.mediana_bookings /  t1.mediana_tickets, 2)
from (select percentile_cont(0.5) within group(order by amount)::numeric mediana_tickets from ticket_flights) t1,
	(select percentile_cont(0.5) within group(order by total_amount)::numeric mediana_bookings from bookings) t2

/*9. Найдите значение минимальной стоимости полета 1 км для пассажиров. То есть нужно найти расстояние между аэропортами 
  и с учетом стоимости перелетов получить искомый результат
  Для поиска расстояния между двумя точками на поверхности Земли используется модуль earthdistance.
  Для работы модуля earthdistance необходимо предварительно установить модуль cube.
  Установка модулей происходит через команду: create extension название_модуля.*/

create extension "cube"

create extension "earthdistance"

with cte as (select f.flight_id, a1.longitude as d_longitude, a1.latitude as d_latitude,
				a2.longitude as a_longitude, a2.latitude as a_latitude
			from flights f 
			join airports a1 on a1.airport_code = f.departure_airport 
			join airports a2 on a2.airport_code = f.arrival_airport 
			group by f.flight_id, a1.longitude, a1.latitude, a2.longitude, a2.latitude)
select min(tf.amount / (earth_distance(ll_to_earth(cte.d_latitude, cte.d_longitude), ll_to_earth(cte.a_latitude, cte.a_longitude)) / 1000)::numeric(10,1))::numeric(10,2) as min_cost_flight_km
from cte
join ticket_flights tf on tf.flight_id = cte.flight_id

/*---------*/
create extension cube

create extension earthdistance

select tf.min / (earth_distance(ll_to_earth(d.latitude, d.longitude), ll_to_earth (a.latitude, a.longitude)) / 1000)
from (
	select flight_id, min(amount)
	from ticket_flights 
	group by flight_id) tf
join flights f on f.flight_id = tf.flight_id
join airports d on f.departure_airport = d.airport_code
join airports a on f.arrival_airport = a.airport_code
order by 1 
limit 1
