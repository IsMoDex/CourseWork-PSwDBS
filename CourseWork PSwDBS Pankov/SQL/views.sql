CREATE OR REPLACE VIEW cities_view AS
    SELECT a.id "ID", a.name "Город"
    FROM public.cities a;

CREATE OR REPLACE VIEW urban_areas_view AS
    SELECT a.id "ID", a.name "Район", b.name "Город"
    FROM public.urban_areas a
    JOIN public.cities b ON b.id = a.id_city;

CREATE OR REPLACE VIEW types_of_ownership_view AS
    SELECT a.id "ID", a.name "Тип собственности"
    FROM public.types_of_ownership a;

CREATE OR REPLACE VIEW atc_view AS
    SELECT a.id "ID", 
        a.name "Название предприятия", 
        b.name "Район", 
        c.name "Тип собственности", 
        a.year "Год открытия", 
        a.phone "Телефон"
    FROM public.atc a
    JOIN public.urban_areas b ON b.id = a.id_urban_area
    JOIN public.types_of_ownership c ON c.id = a.id_type_of_ownership
    WHERE user_owner = CURRENT_USER;

CREATE OR REPLACE VIEW driving_categories_view AS
    SELECT a.id "ID", a.name "Категория"
    FROM public.driving_categories a;

CREATE OR REPLACE VIEW drivers_view AS 
    SELECT a.id "ID", 
        a.first_name "Фамилия", 
        a.name "Имя", 
        a.last_name "Отчество", 
        a.date_of_birth "Дата рождения", 
        a.start_date "Начало работы", 
        b.name "Владеющая АТС", 
        c.name "Категория", 
        a.salary "Оклад"
    FROM public.drivers a
    JOIN public.atc b ON b.id = a.id_owning_atc
    JOIN public.driving_categories c ON c.id = a.id_driving_category;

CREATE OR REPLACE VIEW cargo_view AS
    SELECT a.id "ID", a.name "Груз", a.weight "Вес"
    FROM public.cargo a;

CREATE OR REPLACE VIEW car_brands_view AS
    SELECT a.id "ID", 
        a.name "Марка", 
        a.load_capacity "Максимальная загруженность", 
        a.fuel_consumption "Расход топлива"
    FROM public.car_brands a;

CREATE OR REPLACE VIEW cars_view AS
    SELECT a.id "ID",
        a.license_plate "Номер",
        b.name "Владеющая АТС",
        c.name "Марка"
    FROM public.cars a
    JOIN public.atc b ON b.id = a.id_owning_atc
    JOIN public.car_brands c ON c.id = a.id_car_brand
    WHERE b.user_owner = CURRENT_USER;

CREATE OR REPLACE VIEW transportation_view AS
    SELECT a.id "ID",
        b.name "Груз",
        a.number_of_units "Количество единиц",
        c1.name "Город отбытия",
        c2.name "Город прибытия",
        a.departure_date "Дата отбытия",
        a.arrival_date "Дата прибытия",
        a.cost_of_transportation "Стоимость перевозки",
        d.license_plate "Номер автомобиля",
        e.first_name || ' ' || e.name || ' ' || e.last_name AS "ФИО водителя"
    FROM public.transportation a
    JOIN public.cargo b ON b.id = a.id_cargo
    JOIN public.cities c1 ON c1.id = a.id_city_departure
    JOIN public.cities c2 ON c2.id = a.id_city_arrival
    JOIN public.cars d ON d.id = a.id_car
    JOIN public.drivers e ON e.id = a.id_driver
    JOIN public.atc atc ON atc.id = e.id_owning_atc AND atc.user_owner = CURRENT_USER;