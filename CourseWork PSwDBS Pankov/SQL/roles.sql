--Удаляем всех пользователей
DO $$
DECLARE
    username TEXT;
BEGIN
    FOR username IN SELECT usename FROM pg_catalog.pg_user WHERE usename <> 'postgres' LOOP
        EXECUTE format('DROP ROLE IF EXISTS %I;', username);
    END LOOP;
END $$;

--Удаление зависимых объектов
DROP FUNCTION IF EXISTS create_new_user_by_role;

--Удаление ролей
DO $$
DECLARE
    role_name TEXT;
    role_cursor CURSOR FOR SELECT rolname FROM pg_roles WHERE rolname IN ('owner_atc', 'moderator', 'analyst');
BEGIN
    FOR role_rec IN role_cursor LOOP
        role_name := role_rec.rolname;
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = role_name) THEN
            ----EXECUTE format('REVOKE ALL ON ALL TABLES IN SCHEMA public FROM %I', role_name);
            --EXECUTE format('REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM %I', role_name);
            --EXECUTE format('REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM %I', role_name);
            EXECUTE format('DROP ROLE IF EXISTS %I', role_name);
        END IF;
    END LOOP;
END $$;

--Создание и настройка ролей
CREATE ROLE owner_atc;

GRANT USAGE ON SCHEMA public TO owner_atc;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO owner_atc;
GRANT TRIGGER ON ALL TABLES IN SCHEMA public TO owner_atc;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO owner_atc;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.users FROM owner_atc;

GRANT ALL ON TABLE public.atc TO owner_atc;
GRANT ALL ON TABLE public.drivers TO owner_atc;
GRANT ALL ON TABLE public.cars TO owner_atc;
GRANT ALL ON TABLE public.transportation TO owner_atc;
--GRANT EXECUTE ON FUNCTION get_atc_user_info() TO owner_atc;

CREATE ROLE moderator;

GRANT USAGE ON SCHEMA public TO moderator;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO moderator;
GRANT TRIGGER ON ALL TABLES IN SCHEMA public TO moderator;

REVOKE ALL ON public.users FROM moderator;

GRANT ALL ON TABLE public.cities TO moderator;
GRANT ALL ON TABLE public.urban_areas TO moderator;
GRANT ALL ON TABLE public.types_of_ownership TO moderator;
GRANT ALL ON TABLE public.driving_categories TO moderator;
GRANT ALL ON TABLE public.cargo TO moderator;
GRANT ALL ON TABLE public.car_brands TO moderator;

GRANT SELECT (id, id_urban_area, id_type_of_ownership) ON TABLE public.atc TO moderator;
GRANT SELECT (id, id_owning_atc, id_driving_category) ON TABLE public.drivers TO moderator;
GRANT SELECT (id, id_owning_atc, id_car_brand) ON TABLE public.cars TO moderator;
GRANT SELECT (id, id_cargo, id_city_departure, id_city_arrival, id_car, id_driver) ON TABLE public.transportation TO moderator;


CREATE ROLE analyst;
GRANT USAGE ON SCHEMA public TO analyst;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analyst;
REVOKE ALL ON TABLE public.users FROM analyst;