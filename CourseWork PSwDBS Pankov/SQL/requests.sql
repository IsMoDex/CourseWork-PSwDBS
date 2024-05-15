-- CREATE OR REPLACE FUNCTION get_asd()
-- RETURNS TABLE 
-- (

-- )
-- AS $$
-- BEGIN
--     RETURN QUERY
--     SELECT

-- END;
-- $$ LANGUAGE plpgsql;

-- Симметричное внутреннее соединение с условием лб.1
-- Первый с условием отбора по внешнему ключу 
-- Получить список грузов, перевезенных с помощью транспортного средства определенного бренда:
CREATE OR REPLACE FUNCTION get_cargos_transported_by_car_brand(brand_name TEXT)
RETURNS TABLE ("Грузы" TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT c.name
    FROM cargo c
    INNER JOIN transportation t ON c.id = t.id_cargo
    INNER JOIN cars cr ON t.id_car = cr.id
    INNER JOIN car_brands cb ON cr.id_car_brand = cb.id
    WHERE cb.name = brand_name;
END;
$$ LANGUAGE plpgsql;

-- Второй с условием отбора по внешнему ключу 
-- Получить список транспортных средств, которые доставили груз в определенный город:
CREATE OR REPLACE FUNCTION get_transportation_vehicles_to_city(city_name TEXT)
RETURNS TABLE ("Автомобильные номера" character varying(15)) AS $$
BEGIN
    RETURN QUERY
    SELECT b.license_plate
    FROM transportation t
    INNER JOIN cars b ON t.id_car = b.id
    INNER JOIN cities c ON t.id_city_arrival = c.id
    WHERE c.name = city_name;
END;
$$ LANGUAGE plpgsql;


-- Первый с условием отбора по датам
-- Получить список городов, в которых было выполнено транспортировка груза в определенный период времени:
CREATE OR REPLACE FUNCTION get_cities_with_transportations_between_dates(start_date DATE, end_date DATE)
RETURNS TABLE ("Города" TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT c.name
    FROM cities c
    INNER JOIN urban_areas ua ON c.id = ua.id_city
    INNER JOIN atc a ON ua.id = a.id_urban_area
    INNER JOIN cars b ON b.id_owning_atc = a.id
    INNER JOIN transportation t ON t.id_car = b.id
    WHERE t.departure_date BETWEEN start_date AND end_date;
END;
$$ LANGUAGE plpgsql;

-- Второй с условием отбора по датам
-- Получить список грузов, перевезенных в определенный день:
CREATE OR REPLACE FUNCTION get_cargos_transported_on_date(transportation_date DATE)
RETURNS TABLE ("Грузы" TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT c.name
    FROM cargo c
    INNER JOIN transportation t ON c.id = t.id_cargo
    WHERE t.departure_date = transportation_date;
END;
$$ LANGUAGE plpgsql;

-- Симметричное внутреннее соединение без условия (три запроса):
-- Первый
-- Получить стоимость всех перевозок для определенного груза
CREATE OR REPLACE FUNCTION get_transportation_cost_for_cargo(cargo_id bigint)
RETURNS INTEGER AS $$
DECLARE
    "Общая стоимость" INTEGER;
BEGIN
    SELECT SUM(transportation.cost_of_transportation)
    INTO total_cost
    FROM transportation
    INNER JOIN cargo ON transportation.id_cargo = cargo.id AND cargo.id = cargo_id;

    RETURN total_cost;
END;
$$ LANGUAGE plpgsql;


-- Второй
CREATE OR REPLACE FUNCTION get_cities_with_urban_areas()
RETURNS TABLE (city_name TEXT, urban_area_name TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT c.name, ua.name
    FROM cities c
    INNER JOIN urban_areas ua ON c.id = ua.id_city;
END;
$$ LANGUAGE plpgsql;

-- Третий
CREATE OR REPLACE FUNCTION get_all_cars_with_brands()
RETURNS TABLE (car_license_plate character varying(15), car_brand TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT c.license_plate, cb.name
    FROM cars c
    INNER JOIN car_brands cb ON c.id_car_brand = cb.id;
END;
$$ LANGUAGE plpgsql;

-- Левое внешнее соединение
-- Получить список всех грузов и их веса, включая грузы, которые не были перевезены:
CREATE OR REPLACE FUNCTION get_all_cargos_with_weights()
RETURNS TABLE (cargo_name TEXT, weight INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT c.name, COALESCE(c.weight, 0)
    FROM cargo c
    LEFT JOIN transportation t ON c.id = t.id_cargo;
END;
$$ LANGUAGE plpgsql;


-- Правое внешнее соединение
-- Получить список всех водителей и их даты рождения, включая водителей без указанных дат рождения:
CREATE OR REPLACE FUNCTION get_all_drivers_with_birthdates()
RETURNS TABLE ("ФИО Водителя" TEXT, "Дата рождения" DATE) AS $$
BEGIN
    RETURN QUERY
    SELECT CONCAT(first_name, ' ', last_name), date_of_birth
    FROM drivers;
END;
$$ LANGUAGE plpgsql;

-- Запрос на запросе по принципу левого соединения
-- -- Функция возвращает количество транспортировок для заданного города. <--- Исправить и заменить
-- CREATE OR REPLACE FUNCTION get_urban_area_transportation_count(city_id bigint)
-- RETURNS INTEGER AS $$
-- DECLARE
--     total_count INTEGER;
-- BEGIN
--     SELECT COUNT(*)
--     INTO total_count
--     FROM (
--         SELECT *
--         FROM urban_areas
--         LEFT JOIN transportation ON urban_areas.id = transportation.id_city_departure
--     ) AS subquery
--     WHERE subquery.id_city_departure = city_id;

--     RETURN total_count;
-- END;
-- $$ LANGUAGE plpgsql;
-- Получить районы если они есть всех городов в которые были осуществелны поставки
CREATE OR REPLACE FUNCTION get_urban_areas_for_each_arrival_city()
RETURNS TABLE (
    "Район" TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT ua.name
    FROM transportation t
    LEFT JOIN cities c_arr ON t.id_city_arrival = c_arr.id
    LEFT JOIN urban_areas ua ON c_arr.id = ua.id_city
    WHERE ua.name IS NOT NULL;
END;
$$ LANGUAGE plpgsql;


-- Запросы на выборку лб.2
-- Итоговый запрос без условия
-- Подсчета количества районов для каждого городу
CREATE FUNCTION count_urban_areas_per_city()
RETURNS TABLE ("Город" text, "Количество районов" integer) AS $$
BEGIN
    RETURN QUERY
    SELECT cities.name, COUNT(urban_areas.id)::integer
    FROM cities
    LEFT JOIN urban_areas ON cities.id = urban_areas.id_city
    GROUP BY cities.name;
END;
$$ LANGUAGE plpgsql;

-- Итоговый запрос с условием на данные
-- Функция для определения общего количества перевозок для каждого типа грузов, учитывая только перевозки, произведенные в текущем году
CREATE FUNCTION total_transportations_per_cargo_type()
RETURNS TABLE (cargo_type_id bigint, cargo_type_name text, total_transportations bigint) AS $$
BEGIN
    RETURN QUERY
    SELECT cargo.id AS cargo_type_id, cargo.name AS cargo_type_name, COUNT(transportation.id) AS total_transportations
    FROM cargo
    LEFT JOIN transportation ON cargo.id = transportation.id_cargo
    WHERE EXTRACT(YEAR FROM transportation.departure_date) = EXTRACT(YEAR FROM CURRENT_DATE)
    GROUP BY cargo.id, cargo.name;
END;
$$ LANGUAGE plpgsql;

-- Итоговый запрос с условием на группы
-- Функция для выявления брендов автомобилей, у которых средний расход топлива выше заданного значения
CREATE FUNCTION car_brands_with_high_average_fuel_consumption(threshold_consumption numeric)
RETURNS TABLE (brand_id bigint, brand_name text, average_consumption numeric) AS $$
BEGIN
    RETURN QUERY
    SELECT cars.id_car_brand AS brand_id, car_brands.name AS brand_name, AVG(car_brands.fuel_consumption) AS average_consumption
    FROM cars
    LEFT JOIN car_brands ON cars.id_car_brand = car_brands.id
    GROUP BY cars.id_car_brand, car_brands.name
    HAVING AVG(car_brands.fuel_consumption) > threshold_consumption;
END;
$$ LANGUAGE plpgsql;

-- Итоговый запрос с условием на данные и на группы
-- Функция для подсчета количества водителей, имеющих зарплату выше заданного уровня
CREATE OR REPLACE FUNCTION count_drivers_above_salary(salary_threshold integer)
RETURNS INTEGER AS $$
DECLARE
    driver_count INTEGER;
BEGIN
    SELECT COUNT(id) INTO driver_count
    FROM drivers
    WHERE salary > salary_threshold
    GROUP BY salary
    HAVING COUNT(*) > 0;

    RETURN driver_count;
END;
$$ LANGUAGE plpgsql;

-- Запрос на запросе по принципу итогового запроса
--
CREATE OR REPLACE FUNCTION sum_cargo_weight_per_city()
RETURNS TABLE (city_name text, total_weight bigint) AS $$
BEGIN
    RETURN QUERY
    SELECT cities.name AS city_name, SUM(transportation_subquery.number_of_units * cargo.weight) AS total_weight
    FROM cities
    LEFT JOIN (
        SELECT id_city_arrival, number_of_units, id_cargo
        FROM transportation
    ) AS transportation_subquery ON cities.id = transportation_subquery.id_city_arrival
    LEFT JOIN cargo ON transportation_subquery.id_cargo = cargo.id
    GROUP BY cities.name;
END;
$$ LANGUAGE plpgsql;

-- Запрос с подзапросом
-- Функция возвращает общую стоимость транспортировок для грузов весом больше заданного.
CREATE OR REPLACE FUNCTION getTransportationCostByCargoWeight(min_weight INTEGER)
RETURNS INTEGER AS $$
DECLARE
    total_cost INTEGER;
BEGIN
    SELECT SUM(cost_of_transportation)
    INTO total_cost
    FROM transportation
    WHERE id_cargo IN (
        SELECT id
        FROM cargo
        WHERE weight > min_weight
    );
    
    RETURN total_cost;
END;
$$ LANGUAGE plpgsql;

-- Запросы ТЗ
-- Запрос с использованием объединения
-- Выбрать имена районов из таблицы urban_areas и города из таблицы cities, добавив указание на тип местности:
CREATE OR REPLACE FUNCTION get_locations_with_type()
RETURNS TABLE (
    "Название локации" TEXT,
    "Тип локации" TEXT
) AS $$
BEGIN
    RETURN QUERY
    (
        SELECT name, 'Район' FROM urban_areas
        UNION
        SELECT name, 'Город' FROM cities
    );
END;
$$ LANGUAGE plpgsql;

-- Запросы с подзапросами (с использованием in, not in, case, операциями над итоговыми данными).
-- Запрос с использованием IN 
-- Получить список городов, в которых есть районы
CREATE OR REPLACE FUNCTION get_cities_with_urban_areas()
RETURNS TABLE (
    "Город" TEXT
) AS $$
BEGIN
    RETURN QUERY
    (
        SELECT name AS city_name
        FROM cities
        WHERE id IN (SELECT id_city FROM urban_areas)
    );
END;
$$ LANGUAGE plpgsql;

-- Запрос с использованием NOT I
-- Получить список городов, в которых нет районов
CREATE OR REPLACE FUNCTION get_cities_without_urban_areas()
RETURNS TABLE (
    "Город" TEXT
) AS $$
BEGIN
    RETURN QUERY
    (
        SELECT name AS city_name
        FROM cities
        WHERE id NOT IN (SELECT id_city FROM urban_areas)
    );
END;
$$ LANGUAGE plpgsql;

-- Запрос с использованием CASE
-- Получить все автомобили и информацию заняты ли они сейчас доставкой
CREATE OR REPLACE FUNCTION get_cars_status()
RETURNS TABLE (
    "Номерной знак" VARCHAR(15),
    "Статус" VARCHAR(8)
) AS $$
BEGIN
    RETURN QUERY
    (
        SELECT license_plate,
            CASE 
                WHEN id IN (SELECT id_car FROM transportation WHERE arrival_date IS NULL) 
                THEN 'Занята'::VARCHAR(8)
                ELSE 'Свободна'::VARCHAR(8)
            END AS status
        FROM cars
    );
END;
$$ LANGUAGE plpgsql;

-- Запрос с использованием HAVING
-- Получить список водителей, чья заработная плата превышает среднюю заработную плату всех водителей
CREATE OR REPLACE FUNCTION get_high_earning_drivers()
RETURNS TABLE (
    "ФИО водителя" TEXT,
    "Зарплата" INTEGER
) AS $$
BEGIN
    RETURN QUERY
    (
        SELECT CONCAT(name, ' ', first_name, ' ', last_name) AS driver_name, salary
        FROM drivers
        GROUP BY id
        HAVING AVG(salary) > (SELECT AVG(salary) FROM drivers)
    );
END;
$$ LANGUAGE plpgsql;