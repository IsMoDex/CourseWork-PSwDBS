----Operation for tables function----
--SELECT data functions
CREATE OR REPLACE FUNCTION get_cities_info()
RETURNS TABLE
(
    "ID" bigint,
    "Город" text
) AS $$
BEGIN
    RETURN QUERY SELECT a.id, a.name FROM public.cities a;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_urban_areas_info()
RETURNS TABLE
(
    "ID" bigint,
    "Район" text,
    "Город" text
) AS $$
BEGIN
    RETURN QUERY 
        SELECT a.id, 
            a.name, 
            b.name
        FROM public.urban_areas a
        JOIN public.cities b ON b.id = a.id_city;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_types_of_ownership_info()
RETURNS TABLE
(
    "ID" integer,
    "Тип собственности" text
) AS $$
BEGIN
    RETURN QUERY 
        SELECT a.id "ID", a.name "Тип собственности"
        FROM public.types_of_ownership a;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_users_info()
RETURNS TABLE
(
    "ID" text, 
    "Логин" text, 
    "Фамилия" text, 
    "Имя" text, 
    "Отчество" text, 
    "Прочее" text 
) AS $$
BEGIN
    RETURN QUERY 
        SELECT login::TEXT, 
            login::TEXT, 
            first_name::TEXT, 
            name::TEXT, 
            last_name::TEXT, 
            data::TEXT
        FROM public.users;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_atc_info()
RETURNS TABLE
(
    "ID" bigint, 
    "Название предприятия" text, 
    "Город" text, 
    "Район" text, 
    "Тип собственности" text, 
    "Год открытия" integer, 
    "Телефон" bigint
) AS $$
BEGIN
    RETURN QUERY 
        SELECT a.id, 
            a.name, 
            c.name, 
            b.name, 
            d.name, 
            a.year, 
            a.phone::BIGINT
        FROM public.atc a
        JOIN public.urban_areas b ON b.id = a.id_urban_area
        JOIN public.cities c ON c.id = b.id_city
        JOIN public.types_of_ownership d ON d.id = a.id_type_of_ownership;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_driving_categories_info()
RETURNS TABLE
(
    "ID" integer,
    "Категория" character varying(6)
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM driving_categories;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_drivers_info()
RETURNS TABLE
(
    "ID" bigint,
    "Фамилия" character varying(32),
    "Имя" character varying(32),
    "Отчество" character varying(32),
    "Дата рождения" date,
    "Начало работы" date,
    "Категория" character varying(6),
    "Оклад" integer
) AS $$
BEGIN
    RETURN QUERY 
        SELECT a.id, 
        a.first_name, 
        a.name, 
        a.last_name, 
        a.date_of_birth, 
        a.start_date, 
        c.name, 
        a.salary
    FROM public.drivers a
    JOIN public.driving_categories c ON c.id = a.id_driving_category;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_cargo_info()
RETURNS TABLE
(
    "ID" bigint,
    "Груз" text,
    "Вес" integer
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM cargo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_car_brands_info()
RETURNS TABLE
(
    "ID" bigint,
    "Марка" text,
    "Максимальная загруженность" integer,
    "Расход топлива" integer
) AS $$
BEGIN
    RETURN QUERY 
        SELECT a.id, 
            a.name, 
            a.load_capacity, 
            a.fuel_consumption
        FROM public.car_brands a;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_cars_info()
RETURNS TABLE
(
    "ID" bigint,
    "Номер" character varying(15),
    "Марка" text
) AS $$
BEGIN
    RETURN QUERY 
        SELECT a.id,
            a.license_plate,
            c.name
        FROM public.cars a
        JOIN public.car_brands c ON c.id = a.id_car_brand;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_transportation_info()
RETURNS TABLE
(
    "ID" bigint,
    "Груз" text,
    "Количество единиц" integer,
    "Город отбытия" text,
    "Город прибытия" text,
    "Дата отбытия" date,
    "Дата прибытия" date,
    "Стоимость перевозки" integer,
    "Номер автомобиля" character varying(6),
    "ФИО водителя" text,
    "Категория" character varying(6)
) AS $$
BEGIN
    RETURN QUERY 
        SELECT a.id,
            b.name,
            a.number_of_units,
            c1.name,
            c2.name,
            a.departure_date,
            a.arrival_date,
            a.cost_of_transportation,
            d.license_plate,
            e.first_name || ' ' || e.name || ' ' || e.last_name,
            f.name
        FROM public.transportation a
        JOIN public.cargo b ON b.id = a.id_cargo
        JOIN public.cities c1 ON c1.id = a.id_city_departure
        JOIN public.cities c2 ON c2.id = a.id_city_arrival
        JOIN public.cars d ON d.id = a.id_car
        JOIN public.drivers e ON e.id = a.id_driver
        JOIN public.driving_categories f ON f.id = e.id_driving_category;
        --JOIN public.atc atc ON atc.id = e.id_owning_atc AND atc.user_owner = CURRENT_USER;
END;
$$ LANGUAGE plpgsql;

--
CREATE OR REPLACE FUNCTION private_get_user_atc_data()
RETURNS TABLE 
(
    id bigint,
    name text,
    id_urban_area bigint,
    id_type_of_ownership integer,
    year integer,
    phone bigint
) AS $$
BEGIN
    RETURN QUERY SELECT a.id, a.name, a.id_urban_area, a.id_type_of_ownership, a.year, a.phone::BIGINT
        FROM atc  a
        WHERE a.user_owner = CURRENT_USER;
END;
$$ LANGUAGE plpgsql;
--
--INSERT data functions--
--
CREATE OR REPLACE FUNCTION insert_data_cities
(
    city_name text
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO cities(name) VALUES (city_name);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_data_urban_areas
(
    area_name text,
    city text
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO urban_areas(name, id_city) SELECT area_name, id FROM cities WHERE name = city;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_data_types_of_ownership
(
    type_name text
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO types_of_ownership(name) VALUES (type_name);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_data_atc
(
    name_atc TEXT,
    city TEXT,
    urban_area TEXT,
    type_ownership TEXT,
    year_atc INTEGER,
    phone_atc BIGINT
)
RETURNS VOID AS $$
DECLARE
    urban_area_id BIGINT;
    type_ownership_id BIGINT;
BEGIN

    IF EXISTS (SELECT 1 FROM private_get_user_atc_data() LIMIT 1)
    THEN
        RAISE EXCEPTION 'У вас уже есть собственное предприятие!';
    END IF;

    -- Получение id_urban_area
    SELECT ua.id INTO urban_area_id
    FROM urban_areas ua
    JOIN cities c ON ua.id_city = c.id
    WHERE ua.name = urban_area AND c.name = city;

    IF (urban_area_id IS NULL)
    THEN
        RAISE EXCEPTION 'Такого района не существует!';
    END IF;

    -- Получение id_type_of_ownership
    SELECT a.id INTO type_ownership_id
    FROM types_of_ownership a
    WHERE a.name = type_ownership;

    IF (type_ownership_id IS NULL)
    THEN
        RAISE EXCEPTION 'Такого типа собственности не существует!';
    END IF;

    -- Вставка данных в таблицу atc
    INSERT INTO atc(name, id_urban_area, id_type_of_ownership, year, phone) 
    VALUES (name_atc, urban_area_id, type_ownership_id, year_atc, phone_atc::phone_domain);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_data_driving_categories
(
    category_name character varying(6)
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO driving_categories(name) VALUES (category_name);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_data_drivers
(
    first_name_driver character varying(32),
    name_driver character varying(32),
    last_name_driver character varying(32),
    date_of_birth_driver date,
    start_work_date_driver date,
    category_name character varying(6),
    salary_driver integer
)
RETURNS VOID AS $$
DECLARE
    owning_atc_rec RECORD; 
    id_driving_category INTEGER;
BEGIN
    -- Получение owning_atc_rec
    SELECT * INTO owning_atc_rec FROM private_get_user_atc_data();

    IF (owning_atc_rec IS NULL)
    THEN
        RAISE EXCEPTION 'У вас нет собственной ATC!';
    END IF;

    -- Получение id_driving_category
    SELECT id INTO id_driving_category
    FROM driving_categories
    WHERE name = category_name
    LIMIT 1;

    IF (id_driving_category IS NULL)
    THEN
        RAISE EXCEPTION 'Такой водительской категории не существует!';
    END IF;

    -- Вставка данных в таблицу drivers
    INSERT INTO drivers(first_name, name, last_name, date_of_birth, start_date, id_owning_atc, id_driving_category, salary) 
    VALUES (first_name_driver, name_driver, last_name_driver, date_of_birth_driver, start_work_date_driver, owning_atc_rec.id, id_driving_category, salary_driver);

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_data_cargo
(
    cargo_name text,
    cargo_weight integer
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO cargo(name, weight) VALUES (cargo_name, cargo_weight);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_data_car_brands
(
    brand_name text,
    brand_load_capacity integer,
    brand_fuel_consumption integer
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO car_brands(name, load_capacity, fuel_consumption) 
    VALUES (brand_name, brand_load_capacity, brand_fuel_consumption);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_data_cars
(
    license_plate_car character varying(15),
    car_brand_name text
)
RETURNS VOID AS $$
DECLARE
    owning_atc_rec RECORD;
    id_car_brand BIGINT;
BEGIN
    -- Получение owning_atc_rec
    SELECT * INTO owning_atc_rec FROM private_get_user_atc_data();

    IF (owning_atc_rec IS NULL)
    THEN
        RAISE EXCEPTION 'У вас нет собственной ATC!';
    END IF;

    -- Получение owning_atc_rec
    SELECT id INTO id_car_brand
    FROM car_brands
    WHERE name = car_brand_name;

    IF (id_car_brand IS NULL)
    THEN
        RAISE EXCEPTION 'Выбранной марки автомобиля, не существует!';
    END IF;

    INSERT INTO cars(license_plate, id_owning_atc, id_car_brand) 
    VALUES (license_plate_car, owning_atc_rec.id, id_car_brand);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_data_transportation
(
    id_cargo_for_transportation bigint,
    number_of_units integer,
    city_departure_name text,
    city_arrival_name text,
    departure_date_transportation date,
    arrival_date_transportation date,
    cost_of_transportation integer,
    id_car bigint,
    id_driver bigint
)
RETURNS VOID AS $$
DECLARE
    owning_atc_rec RECORD;
    id_city_departure BIGINT;
    id_city_arrival BIGINT;
BEGIN
    -- Получение owning_atc_rec
    SELECT * INTO owning_atc_rec FROM private_get_user_atc_data();

    IF (owning_atc_rec IS NULL)
    THEN
        RAISE EXCEPTION 'У вас нет собственной ATC!';
    END IF;

    -- Получение id_city_departure
    SELECT id INTO id_city_departure
    FROM cities
    WHERE name = city_departure_name;

    IF (id_city_departure IS NULL)
    THEN
        RAISE EXCEPTION 'Выбранного города отбытия не существует!';
    END IF;

    -- Получение id_city_arrival
    SELECT id INTO id_city_arrival
    FROM cities
    WHERE name = city_arrival_name;

    IF (id_city_arrival IS NULL)
    THEN
        RAISE EXCEPTION 'Выбранного города прибытия не существует!';
    END IF;

    INSERT INTO transportation
    (
        id_cargo, 
        number_of_units, 
        id_city_departure, 
        id_city_arrival, 
        departure_date, 
        arrival_date, 
        cost_of_transportation, 
        id_car, 
        id_driver
    ) 
    VALUES (
        id_cargo_for_transportation, 
        number_of_units, 
        id_city_departure, 
        id_city_arrival, 
        departure_date_transportation, 
        arrival_date_transportation, 
        cost_of_transportation, 
        id_car, 
        id_driver
    );
    
END;
$$ LANGUAGE plpgsql;
--
--UPDATE data functions--
--
CREATE OR REPLACE FUNCTION update_data_cities
(
    id_replace bigint,
    city_name text
)
RETURNS VOID AS $$
BEGIN
    UPDATE cities SET name = city_name WHERE id = id_replace;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для обновления!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_data_urban_areas
(
    id_replace bigint,
    area_name text,
    city text
)
RETURNS VOID AS $$
BEGIN
    UPDATE urban_areas 
    SET name = area_name, 
    id_city = (SELECT id FROM cities WHERE name = city)
    WHERE id = id_replace;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для обновления!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_data_types_of_ownership
(
    id_replace bigint,
    type_name text
)
RETURNS VOID AS $$
BEGIN
    UPDATE types_of_ownership 
    SET name = type_name 
    WHERE id = id_replace;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для обновления!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_data_atc
(
    name_atc TEXT,
    city TEXT,
    urban_area TEXT,
    type_ownership TEXT,
    year_atc INTEGER,
    phone_atc BIGINT
)
RETURNS VOID AS $$
DECLARE
    id_user_atc BIGINT;
    urban_area_id BIGINT;
    type_ownership_id BIGINT;
BEGIN

    -- Помещаем результат запроса в переменную
    SELECT id INTO id_user_atc FROM private_get_user_atc_data() LIMIT 1;

    -- Проверяем, получили ли мы значение в переменной
    IF id_user_atc IS NULL THEN
        RAISE EXCEPTION 'У вас нет собственного предприятия!';
    END IF;

    -- Получение id_urban_area
    SELECT ua.id INTO urban_area_id
    FROM urban_areas ua
    JOIN cities c ON ua.id_city = c.id
    WHERE ua.name = urban_area AND c.name = city;

    IF (urban_area_id IS NULL)
    THEN
        RAISE EXCEPTION 'Такого района не существует!';
    END IF;

    -- Получение id_type_of_ownership
    SELECT a.id INTO type_ownership_id
    FROM types_of_ownership a
    WHERE a.name = type_ownership;

    IF (type_ownership_id IS NULL)
    THEN
        RAISE EXCEPTION 'Такого типа собственности не существует!';
    END IF;

    -- Вставка данных в таблицу atc
    UPDATE atc
    SET 
        name = name_atc, 
        id_urban_area = urban_area_id, 
        id_type_of_ownership = type_ownership_id, 
        year = year_atc, 
        phone = phone_atc::phone_domain
    WHERE id = id_user_atc;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для обновления!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_data_driving_categories
(
    id_replace bigint,
    category_name character varying(6)
)
RETURNS VOID AS $$
BEGIN
    UPDATE driving_categories 
    SET name = category_name
    WHERE id = id_replace;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_data_drivers
(
    id_replace bigint,
    first_name_driver character varying(32),
    name_driver character varying(32),
    last_name_driver character varying(32),
    date_of_birth_driver date,
    start_work_date_driver date,
    category_name character varying(6),
    salary_driver integer
)
RETURNS VOID AS $$
DECLARE
    owning_atc_rec RECORD; 
    id_driving_category_loc INTEGER;
BEGIN
    -- Получение owning_atc_rec
    SELECT * INTO owning_atc_rec FROM private_get_user_atc_data();

    IF (owning_atc_rec IS NULL)
    THEN
        RAISE EXCEPTION 'У вас нет собственной ATC!';
    END IF;

    -- Получение id_driving_category_loc
    SELECT id INTO id_driving_category_loc
    FROM driving_categories
    WHERE name = category_name
    LIMIT 1;

    IF (id_driving_category_loc IS NULL)
    THEN
        RAISE EXCEPTION 'Такой водительской категории не существует!';
    END IF;

    -- Вставка данных в таблицу drivers
    UPDATE drivers
    SET 
        first_name = first_name_driver, 
        name = name_driver, 
        last_name = last_name_driver, 
        date_of_birth = date_of_birth_driver, 
        start_date = start_work_date_driver, 
        id_owning_atc = owning_atc_rec.id, 
        id_driving_category = id_driving_category_loc, 
        salary = salary_driver
    WHERE id = id_replace;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для обновления!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_data_cargo
(
    id_replace bigint,
    cargo_name text,
    cargo_weight integer
)
RETURNS VOID AS $$
BEGIN
    UPDATE cargo
    SET 
        name = cargo_name, 
        weight = cargo_weight
    WHERE id = id_replace;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для обновления!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_data_car_brands
(
    id_replace bigint,
    brand_name text,
    brand_load_capacity integer,
    brand_fuel_consumption integer
)
RETURNS VOID AS $$
BEGIN
    UPDATE car_brands
    SET
        name = brand_name, 
        load_capacity = brand_load_capacity, 
        fuel_consumption = brand_fuel_consumption 
    WHERE id = id_replace;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для обновления!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_data_cars
(
    id_replace bigint,
    license_plate_car character varying(15),
    car_brand_name text
)
RETURNS VOID AS $$
DECLARE
    owning_atc_rec RECORD;
    id_car_brand_loc BIGINT;
BEGIN
    -- Получение owning_atc_rec
    SELECT * INTO owning_atc_rec FROM private_get_user_atc_data();

    IF (owning_atc_rec IS NULL)
    THEN
        RAISE EXCEPTION 'У вас нет собственной ATC!';
    END IF;

    -- Получение owning_atc_rec
    SELECT id INTO id_car_brand_loc
    FROM car_brands
    WHERE name = car_brand_name;

    IF (id_car_brand_loc IS NULL)
    THEN
        RAISE EXCEPTION 'Выбранной марки автомобиля, не существует!';
    END IF;

    UPDATE cars
    SET 
        license_plate = license_plate_car, 
        --id_owning_atc = owning_atc_rec.id, 
        id_car_brand = id_car_brand_loc 
    WHERE id = id_replace;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для обновления!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_data_transportation
(
    id_replace bigint,
    id_cargo_for_transportation bigint,
    count_units integer,
    city_departure_name text,
    city_arrival_name text,
    departure_date_transportation date,
    arrival_date_transportation date,
    cost_of_transportation_replace integer,
    id_car_replace bigint,
    id_driver_replace bigint
)
RETURNS VOID AS $$
DECLARE
    owning_atc_rec RECORD;
    id_city_departure_loc BIGINT;
    id_city_arrival_loc BIGINT;
BEGIN
    -- Получение owning_atc_rec
    SELECT * INTO owning_atc_rec FROM private_get_user_atc_data();

    IF (owning_atc_rec IS NULL)
    THEN
        RAISE EXCEPTION 'У вас нет собственной ATC!';
    END IF;

    -- Получение id_city_departure_loc
    SELECT id INTO id_city_departure_loc
    FROM cities
    WHERE name = city_departure_name;

    IF (id_city_departure_loc IS NULL)
    THEN
        RAISE EXCEPTION 'Выбранного города отбытия не существует!';
    END IF;

    -- Получение id_city_arrival_loc
    SELECT id INTO id_city_arrival_loc
    FROM cities
    WHERE name = city_arrival_name;

    IF (id_city_arrival_loc IS NULL)
    THEN
        RAISE EXCEPTION 'Выбранного города прибытия не существует!';
    END IF;

    UPDATE transportation
    SET
        id_cargo = id_cargo_for_transportation, 
        number_of_units = count_units, 
        id_city_departure = id_city_departure_loc, 
        id_city_arrival = id_city_arrival_loc, 
        departure_date = departure_date_transportation, 
        arrival_date = arrival_date_transportation, 
        cost_of_transportation = cost_of_transportation_replace, 
        id_car = id_car_replace, 
        id_driver = id_driver_replace
    WHERE id = id_replace;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для обновления!';
    END IF;
END;
$$ LANGUAGE plpgsql;
--
--DELETE data functions--
--
CREATE OR REPLACE FUNCTION delete_data_cities
(
    id_delete bigint
)
RETURNS VOID AS $$
BEGIN
    DELETE FROM cities WHERE id = id_delete; 
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для удаления!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_data_urban_areas
(
    id_delete bigint
)
RETURNS VOID AS $$
BEGIN
    DELETE FROM urban_areas WHERE id = id_delete; 
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для удаления!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_data_types_of_ownership
(
    id_delete bigint
)
RETURNS VOID AS $$
BEGIN
    DELETE FROM types_of_ownership WHERE id = id_delete; 
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для удаления!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_data_atc()
RETURNS VOID AS $$
BEGIN
    DELETE FROM atc WHERE user_owner = CURRENT_USER; 
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'У вас нет собственной АТС!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_data_atc
(
    id_delete bigint
)
RETURNS VOID AS $$
BEGIN
    DELETE FROM atc WHERE id = id_delete;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'АТС с таким индексом не существует!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_data_driving_categories
(
    id_delete bigint
)
RETURNS VOID AS $$
BEGIN
    DELETE FROM driving_categories WHERE id = id_delete; 
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для удаления!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_data_drivers
(
    id_delete bigint
)
RETURNS VOID AS $$
DECLARE
    owning_atc_rec RECORD;

BEGIN
    -- Получение owning_atc_rec
    SELECT * INTO owning_atc_rec FROM private_get_user_atc_data();

    IF (owning_atc_rec IS NULL)
    THEN
        RAISE EXCEPTION 'У вас нет собственной ATC!';
    END IF;

    DELETE FROM drivers WHERE id_owning_atc = owning_atc_rec.id AND id = id_delete; 
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для удаления!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_data_cargo
(
    id_delete bigint
)
RETURNS VOID AS $$
BEGIN
    DELETE FROM cargo WHERE id = id_delete; 
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для удаления!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_data_car_brands
(
    id_delete bigint
)
RETURNS VOID AS $$
BEGIN
    DELETE FROM car_brands WHERE id = id_delete; 
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для удаления!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_data_cars
(
    id_delete bigint
)
RETURNS VOID AS $$
DECLARE
    owning_atc_rec RECORD;
BEGIN
    -- Получение owning_atc_rec
    SELECT * INTO owning_atc_rec FROM private_get_user_atc_data();

    IF (owning_atc_rec IS NULL)
    THEN
        RAISE EXCEPTION 'У вас нет собственной ATC!';
    END IF;

    DELETE FROM cars WHERE id_owning_atc = owning_atc_rec.id AND id = id_delete; 
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для удаления!';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_data_transportation
(
    id_delete bigint
)
RETURNS VOID AS $$
DECLARE
    owning_atc_rec RECORD;
BEGIN
    -- Получение owning_atc_rec
    SELECT * INTO owning_atc_rec FROM private_get_user_atc_data();

    IF (owning_atc_rec IS NULL)
    THEN
        RAISE EXCEPTION 'У вас нет собственной ATC!';
    END IF;

    DELETE FROM transportation a
    WHERE id = id_delete AND 
    EXISTS (
        SELECT 1 FROM drivers b
        WHERE b.id_owning_atc = owning_atc_rec.id AND 
        a.id_driver = b.id
        LIMIT 1
    ); 
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Запись не найдена для удаления!';
    END IF;
END;
$$ LANGUAGE plpgsql;
--
--COUNT CASCADING DELETIONS data functions--
--
-- CREATE OR REPLACE FUNCTION count_cascading_deletions_cities(id_to_delete bigint)
-- RETURNS INTEGER AS $$
-- DECLARE
--     total_count INTEGER;
-- BEGIN
--     SELECT SUM(count) INTO total_count FROM (
--         SELECT COUNT(*) AS count FROM cities WHERE id = id_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM urban_areas WHERE id_city = id_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM atc WHERE id_urban_area IN (SELECT id FROM urban_areas WHERE id_city = id_to_delete)
--         UNION ALL
--         SELECT COUNT(*) FROM drivers WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_urban_area IN (SELECT id FROM urban_areas WHERE id_city = id_to_delete))
--         UNION ALL
--         SELECT COUNT(*) FROM cars WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_urban_area IN (SELECT id FROM urban_areas WHERE id_city = id_to_delete))
--         UNION ALL
--         SELECT COUNT(*) FROM transportation WHERE id_city_departure = id_to_delete OR id_city_arrival = id_to_delete
--     ) AS subquery;

--     RETURN total_count;
-- END;
-- $$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION count_cascading_deletions_cities(id_to_delete bigint)
-- RETURNS TABLE(table_name TEXT, count_deleted BIGINT) AS $$
-- BEGIN
--     RETURN QUERY
--     SELECT 'Города', COUNT(*) FROM cities WHERE id = id_to_delete
--     UNION ALL
--     SELECT 'Районы', COUNT(*) FROM urban_areas WHERE id_city = id_to_delete
--     UNION ALL
--     SELECT 'АТС', COUNT(*) FROM atc WHERE id_urban_area IN (SELECT id FROM urban_areas WHERE id_city = id_to_delete)
--     UNION ALL
--     SELECT 'Водители', COUNT(*) FROM drivers WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_urban_area IN (SELECT id FROM urban_areas WHERE id_city = id_to_delete))
--     UNION ALL
--     SELECT 'Автомобили', COUNT(*) FROM cars WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_urban_area IN (SELECT id FROM urban_areas WHERE id_city = id_to_delete))
--     UNION ALL
--     SELECT 'Перевозки', COUNT(*) FROM transportation WHERE id_city_departure = id_to_delete OR id_city_arrival = id_to_delete;
-- END;
-- $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_cascading_deletions_cities(id_to_delete bigint)
RETURNS TABLE(table_name TEXT, count_deleted BIGINT) AS $$
DECLARE
    cities_count BIGINT;
    urban_areas_count BIGINT;
    atc_count BIGINT;
    drivers_count BIGINT;
    cars_count BIGINT;
    transportation_count BIGINT;
    total_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO cities_count FROM cities WHERE id = id_to_delete;
    SELECT COUNT(*) INTO urban_areas_count FROM urban_areas WHERE id_city = id_to_delete;
    SELECT COUNT(*) INTO atc_count FROM atc WHERE id_urban_area IN (SELECT id FROM urban_areas WHERE id_city = id_to_delete);
    SELECT COUNT(*) INTO drivers_count FROM drivers WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_urban_area IN (SELECT id FROM urban_areas WHERE id_city = id_to_delete));
    SELECT COUNT(*) INTO cars_count FROM cars WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_urban_area IN (SELECT id FROM urban_areas WHERE id_city = id_to_delete));
    SELECT COUNT(*) INTO transportation_count FROM transportation WHERE id_city_departure = id_to_delete OR id_city_arrival = id_to_delete;

    total_count := cities_count + urban_areas_count + atc_count + drivers_count + cars_count + transportation_count;

    RETURN QUERY
    SELECT 'Города', cities_count
    UNION ALL
    SELECT 'Районы', urban_areas_count
    UNION ALL
    SELECT 'АТС', atc_count
    UNION ALL
    SELECT 'Водители', drivers_count
    UNION ALL
    SELECT 'Автомобили', cars_count
    UNION ALL
    SELECT 'Перевозки', transportation_count
    UNION ALL 
    SELECT 'Всего', total_count;
END;
$$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION count_cascading_deletions_urban_areas(id_to_delete bigint)
-- RETURNS INTEGER AS $$
-- DECLARE
--     total_count INTEGER;
-- BEGIN
--     SELECT SUM(count) INTO total_count FROM (
--         SELECT COUNT(*) AS count FROM urban_areas WHERE id = id_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM atc WHERE id_urban_area = id_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM drivers WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_urban_area = id_to_delete)
--         UNION ALL
--         SELECT COUNT(*) FROM cars WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_urban_area = id_to_delete)
--         UNION ALL
--         SELECT COUNT(*) FROM transportation WHERE id_car IN (SELECT id FROM cars WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_urban_area = id_to_delete));
--     ) AS subquery;

--     RETURN total_count;
-- END;
-- $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_cascading_deletions_urban_areas(id_to_delete bigint)
RETURNS TABLE(table_name TEXT, count_deleted BIGINT) AS $$
DECLARE
    atc_count BIGINT;
    drivers_count BIGINT;
    cars_count BIGINT;
    transportation_count BIGINT;
    total_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO atc_count FROM atc WHERE id_urban_area = id_to_delete;
    SELECT COUNT(*) INTO drivers_count FROM drivers WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_urban_area = id_to_delete);
    SELECT COUNT(*) INTO cars_count FROM cars WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_urban_area = id_to_delete);
    SELECT COUNT(*) INTO transportation_count FROM transportation WHERE id_car IN (SELECT id FROM cars WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_urban_area = id_to_delete));

    total_count := atc_count + drivers_count + cars_count + transportation_count;
	
    RETURN QUERY
    SELECT 'АТС', atc_count
    UNION ALL
    SELECT 'Водители', drivers_count
    UNION ALL
    SELECT 'Автомобили', cars_count
    UNION ALL
    SELECT 'Перевозки', transportation_count
    UNION ALL 
    SELECT 'Всего', total_count;
END;
$$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION count_cascading_deletions_types_of_ownership(id_to_delete bigint)
-- RETURNS INTEGER AS $$
-- DECLARE
--     total_count INTEGER;
-- BEGIN
--     SELECT SUM(count) INTO total_count FROM (
--         SELECT COUNT(*) AS count FROM types_of_ownership WHERE id = id_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM atc WHERE id_type_of_ownership = id_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM drivers WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_type_of_ownership = id_to_delete)
--         UNION ALL
--         SELECT COUNT(*) FROM cars WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_type_of_ownership = id_to_delete)
--         UNION ALL
--         SELECT COUNT(*) FROM transportation WHERE id_car IN (SELECT id FROM cars WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_type_of_ownership = id_to_delete))
--     ) AS subquery;

--     RETURN total_count;
-- END;
-- $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_cascading_deletions_types_of_ownership(id_to_delete bigint)
RETURNS TABLE(table_name TEXT, count_deleted INTEGER) AS $$
DECLARE
    types_of_ownership_count INTEGER;
    atc_count INTEGER;
    drivers_count INTEGER;
    cars_count INTEGER;
    transportation_count INTEGER;
    total_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO types_of_ownership_count FROM types_of_ownership WHERE id = id_to_delete;
    SELECT COUNT(*) INTO atc_count FROM atc WHERE id_type_of_ownership = id_to_delete;
    SELECT COUNT(*) INTO drivers_count FROM drivers WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_type_of_ownership = id_to_delete);
    SELECT COUNT(*) INTO cars_count FROM cars WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_type_of_ownership = id_to_delete);
    SELECT COUNT(*) INTO transportation_count FROM transportation WHERE id_car IN (SELECT id FROM cars WHERE id_owning_atc IN (SELECT id FROM atc WHERE id_type_of_ownership = id_to_delete));

    total_count := atc_count + drivers_count + cars_count + transportation_count;

    RETURN QUERY
    SELECT 'Типы собственности', types_of_ownership_count
    UNION ALL
    SELECT 'АТС', atc_count
    UNION ALL
    SELECT 'Водители', drivers_count
    UNION ALL
    SELECT 'Автомобили', cars_count
    UNION ALL 
    SELECT 'Перевозки', transportation
    UNION ALL 
    SELECT 'Всего', total_count;
END;
$$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION count_cascading_deletions_atc(id_to_delete bigint)
-- RETURNS INTEGER AS $$
-- DECLARE
--     total_count INTEGER;
-- BEGIN
--     SELECT SUM(count) INTO total_count FROM (
--         SELECT COUNT(*) AS count FROM atc WHERE id = id_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM drivers WHERE id_owning_atc = id_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM cars WHERE id_owning_atc = id_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM transportation WHERE id_car IN (SELECT id FROM cars WHERE id_owning_atc = id_to_delete)
--     ) AS subquery;

--     RETURN total_count;
-- END;
-- $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_cascading_deletions_atc(id_to_delete bigint)
RETURNS TABLE(table_name TEXT, count_deleted BIGINT) AS $$
DECLARE
    atc_count BIGINT;
    drivers_count BIGINT;
    cars_count BIGINT;
    transportation_count BIGINT;
    total_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO atc_count FROM atc WHERE id = id_to_delete;
    SELECT COUNT(*) INTO drivers_count FROM drivers WHERE id_owning_atc = id_to_delete;
    SELECT COUNT(*) INTO cars_count FROM cars WHERE id_owning_atc = id_to_delete;
    SELECT COUNT(*) INTO transportation_count FROM transportation WHERE id_car IN (SELECT id FROM cars WHERE id_owning_atc = id_to_delete);

    total_count := atc_count + drivers_count + cars_count + transportation_count;

    RETURN QUERY
    SELECT 'АТС', atc_count
    UNION ALL
	SELECT 'Водители', drivers_count
    UNION ALL
    SELECT 'Автомобили', cars_count
    UNION ALL
    SELECT 'Перевозки', transportation_count
    UNION ALL 
    SELECT 'Всего', total_count;
END;
$$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION count_cascading_deletions_users(login_to_delete text)
-- RETURNS INTEGER AS $$
-- DECLARE
--     total_count INTEGER;
-- BEGIN
--     SELECT SUM(count) INTO total_count FROM (
--         SELECT COUNT(*) AS count FROM users WHERE login = login_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM atc WHERE user_owner = login_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM drivers WHERE id_owning_atc IN (SELECT id FROM atc WHERE user_owner = login_to_delete)
--         UNION ALL
--         SELECT COUNT(*) FROM cars WHERE id_owning_atc IN (SELECT id FROM atc WHERE user_owner = login_to_delete)
--         UNION ALL
--         SELECT COUNT(*) FROM transportation WHERE id_car IN (SELECT id FROM cars WHERE id_owning_atc IN (SELECT id FROM atc WHERE user_owner = login_to_delete))
--     ) AS subquery;

--     RETURN total_count;
-- END;
-- $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_cascading_deletions_users(login_to_delete TEXT)
RETURNS TABLE(table_name TEXT, count_deleted BIGINT) AS $$
DECLARE
    users_count BIGINT;
    atc_count BIGINT;
    drivers_count BIGINT;
    cars_count BIGINT;
    transportation_count BIGINT;
    total_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO users_count FROM users WHERE login = login_to_delete;
    SELECT COUNT(*) INTO atc_count FROM atc WHERE user_owner = login_to_delete;
    SELECT COUNT(*) INTO drivers_count FROM drivers WHERE id_owning_atc IN (SELECT id FROM atc WHERE user_owner = login_to_delete);
    SELECT COUNT(*) INTO cars_count FROM cars WHERE id_owning_atc IN (SELECT id FROM atc WHERE user_owner = login_to_delete);
    SELECT COUNT(*) INTO transportation_count FROM transportation WHERE id_car IN (SELECT id FROM cars WHERE id_owning_atc IN (SELECT id FROM atc WHERE user_owner = login_to_delete));

    total_count := users_count + atc_count + drivers_count + cars_count + transportation_count;

    RETURN QUERY
    SELECT 'Пользователи', users_count
    UNION ALL
    SELECT 'АТС', atc_count
    UNION ALL
    SELECT 'Водители', drivers_count
    UNION ALL
    SELECT 'Автомобили', cars_count
    UNION ALL
    SELECT 'Перевозки', transportation_count
    UNION ALL 
    SELECT 'Всего', total_count;
END;
$$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION count_cascading_deletions_driving_categories(id_to_delete bigint)
-- RETURNS INTEGER AS $$
-- DECLARE
--     total_count INTEGER;
-- BEGIN
--     SELECT SUM(count) INTO total_count FROM (
--         SELECT COUNT(*) AS count FROM driving_categories WHERE id = id_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM drivers WHERE id_driving_category = id_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM transportation WHERE id_driver IN (SELECT id FROM drivers WHERE id_driving_category = id_to_delete)
--     ) AS subquery;

--     RETURN total_count;
-- END;
-- $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_cascading_deletions_driving_categories(id_to_delete bigint)
RETURNS TABLE(table_name TEXT, count_deleted BIGINT) AS $$
DECLARE
    driving_categories_count BIGINT;
    drivers_count BIGINT;
    transportation_count BIGINT;
    total_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO driving_categories_count FROM driving_categories WHERE id = id_to_delete;
    SELECT COUNT(*) INTO drivers_count FROM drivers WHERE id_driving_category = id_to_delete;
    SELECT COUNT(*) INTO transportation_count FROM transportation WHERE id_driver IN (SELECT id FROM drivers WHERE id_driving_category = id_to_delete);

    total_count := driving_categories_count + drivers_count + transportation_count;

    RETURN QUERY
    SELECT 'Водительская категория', driving_categories_count
    UNION ALL
    SELECT 'Водители', drivers_count
    UNION ALL
    SELECT 'Перевозки', transportation_count
    UNION ALL 
    SELECT 'Всего', total_count;
END;
$$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION count_cascading_deletions_drivers(id_to_delete bigint)
-- RETURNS INTEGER AS $$
-- DECLARE
--     total_count INTEGER;
-- BEGIN
--     SELECT SUM(count) INTO total_count FROM (
--         SELECT COUNT(*) AS count FROM drivers WHERE id = id_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM transportation WHERE id_driver = id_to_delete
--     ) AS subquery;

--     RETURN total_count;
-- END;
-- $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_cascading_deletions_drivers(id_to_delete bigint)
RETURNS TABLE(table_name TEXT, count_deleted BIGINT) AS $$
DECLARE
    drivers_count BIGINT;
    transportation_count BIGINT;
    total_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO drivers_count FROM drivers WHERE id = id_to_delete;
    SELECT COUNT(*) INTO transportation_count FROM transportation WHERE id_driver = id_to_delete;

    total_count := drivers_count + transportation_count;

    RETURN QUERY
    SELECT 'Водители', drivers_count
    UNION ALL
    SELECT 'Перевозки', transportation_count
    UNION ALL 
    SELECT 'Всего', total_count;
END;
$$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION count_cascading_deletions_cargo(id_to_delete bigint)
-- RETURNS INTEGER AS $$
-- DECLARE
--     total_count INTEGER;
-- BEGIN
--     SELECT SUM(count) INTO total_count FROM (
--         SELECT COUNT(*) AS count FROM cargo WHERE id = id_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM transportation WHERE id_cargo = id_to_delete
--     ) AS subquery;

--     RETURN total_count;
-- END;
-- $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_cascading_deletions_cargo(id_to_delete bigint)
RETURNS TABLE(table_name TEXT, count_deleted BIGINT) AS $$
DECLARE
    cargo_count BIGINT;
    transportation_count BIGINT;
    total_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO cargo_count FROM cargo WHERE id = id_to_delete;
    SELECT COUNT(*) INTO transportation_count FROM transportation WHERE id_cargo = id_to_delete;

    total_count := cargo_count + transportation_count;

    RETURN QUERY
    SELECT 'Грузы', cargo_count
    UNION ALL
    SELECT 'Перевозки', transportation_count
    UNION ALL 
    SELECT 'Всего', total_count;
END;
$$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION count_cascading_deletions_car_brands(id_to_delete bigint)
-- RETURNS INTEGER AS $$
-- DECLARE
--     total_count INTEGER;
-- BEGIN
--     SELECT SUM(count) INTO total_count FROM (
--         SELECT COUNT(*) AS count FROM car_brands WHERE id = id_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM cars WHERE id_car_brand = id_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM transportation WHERE id_car IN (SELECT id FROM cars WHERE id_car_brand = id_to_delete)
--     ) AS subquery;

--     RETURN total_count;
-- END;
-- $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_cascading_deletions_car_brands(id_to_delete bigint)
RETURNS TABLE(table_name TEXT, count_deleted BIGINT) AS $$
DECLARE
    car_brands_count BIGINT;
    cars_count BIGINT;
    transportation_count BIGINT;
    total_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO car_brands_count FROM car_brands WHERE id = id_to_delete;
    SELECT COUNT(*) INTO cars_count FROM cars WHERE id_car_brand = id_to_delete;
    SELECT COUNT(*) INTO transportation_count FROM transportation WHERE id_car IN (SELECT id FROM cars WHERE id_car_brand = id_to_delete);

    total_count := car_brands_count + cars_count + transportation_count;

    RETURN QUERY
    SELECT 'Марки автомобилей', car_brands_count
    UNION ALL
    SELECT 'Автомобили', cars_count
    UNION ALL
    SELECT 'Перевозки', transportation_count
    UNION ALL 
    SELECT 'Всего', total_count;
END;
$$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION count_cascading_deletions_cars(id_to_delete bigint)
-- RETURNS INTEGER AS $$
-- DECLARE
--     total_count INTEGER;
-- BEGIN
--     SELECT SUM(count) INTO total_count FROM (
--         SELECT COUNT(*) AS count FROM cars WHERE id = id_to_delete
--         UNION ALL
--         SELECT COUNT(*) FROM transportation WHERE id_car = id_to_delete
--     ) AS subquery;

--     RETURN total_count;
-- END;
-- $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_cascading_deletions_cars(id_to_delete bigint)
RETURNS TABLE(table_name TEXT, count_deleted INTEGER) AS $$
DECLARE
    cars_count INTEGER;
    transportation_count INTEGER;
    total_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO cars_count FROM cars WHERE id = id_to_delete;
    SELECT COUNT(*) INTO transportation_count FROM transportation WHERE id_car = id_to_delete;

    total_count := cars_count + transportation_count;

    RETURN QUERY
    SELECT 'Автомобили', cars_count
    UNION ALL
    SELECT 'Перевозки', transportation_count
    UNION ALL 
    SELECT 'Всего', total_count;
END;
$$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION count_cascading_deletions_transportation(id_to_delete bigint)
-- RETURNS INTEGER AS $$
-- DECLARE
--     total_count INTEGER;
-- BEGIN
--     SELECT COUNT(*) INTO total_count FROM transportation WHERE id = id_to_delete;

--     RETURN total_count;
-- END;
-- $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_cascading_deletions_transportation(id_to_delete bigint)
RETURNS TABLE(table_name TEXT, count_deleted INTEGER) AS $$
DECLARE
    transportation_count INTEGER;
    total_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO transportation_count FROM transportation WHERE id = id_to_delete;

    total_count := transportation_count;

    RETURN QUERY
    SELECT 'Перевозки', transportation_count
    UNION ALL 
    SELECT 'Всего', total_count;
END;
$$ LANGUAGE plpgsql;