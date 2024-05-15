----TABLES----
--For table: atc
CREATE OR REPLACE FUNCTION trigger_update_or_insert_atc()
RETURNS TRIGGER AS $$
BEGIN

    IF (NEW.year > EXTRACT(YEAR FROM CURRENT_DATE)) THEN
        RAISE EXCEPTION 'Год открытия не может быть больше текущего!';
    ELSIF(NEW.year < 1200) THEN
        RAISE EXCEPTION 'Год открытия не может быть меньше 1200г!';
    END IF;

    IF (NEW.phone < 1) THEN
        RAISE EXCEPTION 'Телефон не может иметь отрицательное значение!';
    END IF;

    -- IF (NEW.user_owner != CURRENT_USER)
    -- THEN
    --     RAISE EXCEPTION 'Вы не являйтесь владельцем текущей АТС!';
    -- END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_update_or_insert_atc
    BEFORE INSERT OR UPDATE ON public.atc
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_or_insert_atc();

--For table: drivers
CREATE OR REPLACE FUNCTION trigger_update_or_insert_drivers()
RETURNS TRIGGER AS $$
BEGIN

    IF (NEW.date_of_birth >= CURRENT_DATE) THEN
        RAISE EXCEPTION 'Дата рождения не может быть позже или равна текущей!';
    ELSIF (EXTRACT(YEAR FROM age(CURRENT_DATE, NEW.date_of_birth))::INTEGER > 150) THEN
        RAISE EXCEPTION 'Водителю не может быть больше 150 лет!';
    ELSIF (EXTRACT(YEAR FROM age(CURRENT_DATE, NEW.date_of_birth))::INTEGER < 18) THEN
        RAISE EXCEPTION 'Водителю не может быть меньше 18 лет!';
    END IF;

    IF (NEW.start_date >= CURRENT_DATE) THEN
        RAISE EXCEPTION 'Дата начала работы не может быть позже текущей!';
    ELSIF (NEW.start_date < '1200-01-01'::DATE) THEN
        RAISE EXCEPTION 'Дата начала работы не может быть раньше 01.01.1200!';
    ELSIF (NEW.date_of_birth > NEW.start_date) THEN
        RAISE EXCEPTION 'Дата начала работы не может быть раньше даты рождения!';
    ELSIF (EXTRACT(YEAR FROM age(NEW.start_date, NEW.date_of_birth))::INTEGER < 18) THEN
        RAISE EXCEPTION 'На момент поступления на работу водителю не может быть меньше 18 лет!';
    ELSIF (EXTRACT(YEAR FROM age(NEW.start_date, NEW.date_of_birth))::INTEGER > (SELECT year FROM atc WHERE id = NEW.id_owning_atc)) THEN
        RAISE EXCEPTION 'Дата начала работы не может быть раньше даты открытия АТС!';
    END IF;

    IF (NEW.salary < 20000) THEN
        RAISE EXCEPTION 'Зарплата не может быть меньше 20000!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_update_or_insert_drivers
    BEFORE INSERT OR UPDATE ON public.drivers
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_or_insert_drivers();

--For table: cargo
CREATE OR REPLACE FUNCTION trigger_update_or_insert_cargo()
RETURNS TRIGGER AS $$
BEGIN

    IF (NEW.weight < 1) THEN
        RAISE EXCEPTION 'Вес груза не может быть меньше 1!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_update_or_insert_cargo
    BEFORE INSERT OR UPDATE ON public.cargo
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_or_insert_cargo();

--For table: car_brands
CREATE OR REPLACE FUNCTION trigger_update_or_insert_car_brands()
RETURNS TRIGGER AS $$
BEGIN

    IF (NEW.load_capacity < 1) THEN
        RAISE EXCEPTION 'Грузоподъемность не может быть меньше 1!';
    END IF;

    IF (NEW.fuel_consumption < 1) THEN
        RAISE EXCEPTION 'Расход топлива не может быть меньше 1!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_update_or_insert_car_brands
    BEFORE INSERT OR UPDATE ON public.car_brands
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_or_insert_car_brands();

--For table: transportation
CREATE OR REPLACE FUNCTION trigger_update_or_insert_transportation()
RETURNS TRIGGER AS $$
BEGIN

    IF (NEW.number_of_units < 1) THEN
        RAISE EXCEPTION 'Количество грузов не может быть меньше 1!';
    END IF;

    IF (NEW.departure_date > CURRENT_DATE) THEN
        RAISE EXCEPTION 'Дата отбытия не может быть позже текущей даты!';
    END IF;

    IF (NEW.arrival_date > CURRENT_DATE) THEN
        RAISE EXCEPTION 'Дата прибытия не может быть позже текущей даты!';
    ELSIF (NEW.arrival_date < NEW.departure_date) THEN
        RAISE EXCEPTION 'Дата прибытия не может быть раньше даты отбытия!';
    END IF;

    IF (NEW.cost_of_transportation < 50) THEN
        RAISE EXCEPTION 'Стоимость перевозки не может быть меньше 50!';
    END IF;

    IF (
        SELECT true 
        FROM public.drivers d
        JOIN public.cars c ON d.id_owning_atc != c.id_owning_atc
        WHERE d.id = NEW.id_driver AND c.id = NEW.id_car
    )
    THEN --Автомобиль
        RAISE EXCEPTION 'Данный водитель не принадлежит к той-же транспортной компании, к которой принадлежит автомобиль!';
    ELSIF (
        SELECT true 
        FROM public.transportation tr 
        WHERE tr.id != NEW.id AND tr.id_car = NEW.id_car AND tr.arrival_date IS NULL
    ) 
    THEN
        RAISE EXCEPTION 'Невозможно назначить данный автомобиль на задание, поскольку он уже занят другим перевозочным маршрутом!';
    END IF;

    IF (
        SELECT true 
        FROM public.transportation tr 
        WHERE tr.id != NEW.id AND tr.id_driver = NEW.id_driver AND tr.arrival_date IS NULL
    ) 
    THEN --Водитель
        RAISE EXCEPTION 'Невозможно назначить данного водителя на задание, поскольку он уже занят другим перевозочным маршрутом!';
    END IF;

    IF (EXTRACT(YEAR FROM NEW.departure_date) < (SELECT CAST(year AS INTEGER)
        FROM atc a 
        JOIN cars b ON b.id = NEW.id_car
        WHERE a.id = b.id_owning_atc
        )) THEN
        RAISE EXCEPTION 'Дата отправки не может быть раньше даты основания АТС!';
    END IF;

    IF ((SELECT NEW.number_of_units * weight 
        FROM cargo 
        WHERE id = NEW.id_cargo) > (SELECT load_capacity 
        FROM car_brands 
        JOIN cars ON cars.id_car_brand = car_brands.id 
        WHERE cars.id = NEW.id_car)) THEN
        RAISE EXCEPTION 'Вес груза больше, чем способен перевезти автомобиль!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_update_or_insert_transportation
    BEFORE INSERT OR UPDATE ON public.transportation
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_or_insert_transportation();