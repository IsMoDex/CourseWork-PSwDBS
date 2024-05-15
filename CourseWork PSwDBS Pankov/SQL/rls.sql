--ROLE LEVEL SECURITY
-- Создаем политики безопасности для таблицы atc
CREATE POLICY restrict_select_atc_access ON public.atc
FOR SELECT
TO owner_atc
USING (user_owner = CURRENT_USER);

-- Создаем новую политику безопасности для просмотра данных в таблице atc для роли analyst и moderator
CREATE POLICY allow_select_atc_access_for_analyst_or_moderator ON public.atc
FOR SELECT
TO analyst, moderator
USING (true);

CREATE POLICY restrict_insert_atc_access ON public.atc
FOR INSERT
TO owner_atc
WITH CHECK (user_owner = CURRENT_USER);

CREATE POLICY restrict_update_atc_access ON public.atc
FOR UPDATE
TO owner_atc
USING (user_owner = CURRENT_USER);

CREATE POLICY restrict_delete_atc_access ON public.atc
FOR DELETE
TO owner_atc
USING (user_owner = CURRENT_USER);

-- Создаем политики безопасности для таблицы drivers
CREATE POLICY restrict_select_driver_access ON public.drivers
FOR SELECT
USING (
    -- Проверяем, что user_owner в соответствующей ATC равен текущему пользователю
    EXISTS (
        SELECT 1
        FROM public.atc
        WHERE atc.id = drivers.id_owning_atc
        AND atc.user_owner = CURRENT_USER
    )
);

-- Создаем новую политику безопасности для просмотра данных в таблице drivers для роли analyst и moderator
CREATE POLICY allow_select_drivers_access_for_analyst_or_moderator ON public.drivers
FOR SELECT
TO analyst, moderator
USING (true);

CREATE POLICY restrict_insert_driver_access ON public.drivers
FOR INSERT
WITH CHECK (
    -- Проверяем, что user_owner в соответствующей ATC равен текущему пользователю
    EXISTS (
        SELECT 1
        FROM public.atc
        WHERE atc.id = drivers.id_owning_atc
        AND atc.user_owner = CURRENT_USER
    )
);

CREATE POLICY restrict_update_driver_access ON public.drivers
FOR UPDATE
USING (
    -- Проверяем, что user_owner в соответствующей ATC равен текущему пользователю
    EXISTS (
        SELECT 1
        FROM public.atc
        WHERE atc.id = drivers.id_owning_atc
        AND atc.user_owner = CURRENT_USER
    )
);

CREATE POLICY restrict_delete_driver_access ON public.drivers
FOR DELETE
USING (
    -- Проверяем, что user_owner в соответствующей ATC равен текущему пользователю
    EXISTS (
        SELECT 1
        FROM public.atc
        WHERE atc.id = drivers.id_owning_atc
        AND atc.user_owner = CURRENT_USER
    )
);

-- Создаем политики безопасности для таблицы cars
CREATE POLICY restrict_select_cars_access ON public.cars
FOR SELECT
TO owner_atc
USING (
    -- Проверяем, что user_owner в соответствующей ATC равен текущему пользователю
    EXISTS (
        SELECT 1
        FROM public.atc
        WHERE atc.id = cars.id_owning_atc
        AND atc.user_owner = CURRENT_USER
    )
);

-- Создаем новую политику безопасности для просмотра данных в таблице cars для роли analyst и moderator
CREATE POLICY allow_select_cars_access_for_analyst_or_moderator ON public.cars
FOR SELECT
TO analyst, moderator
USING (true);

CREATE POLICY restrict_insert_cars_access ON public.cars
FOR INSERT
TO owner_atc
WITH CHECK (
    -- Проверяем, что user_owner в соответствующей ATC равен текущему пользователю
    EXISTS (
        SELECT 1
        FROM public.atc
        WHERE atc.id = cars.id_owning_atc
        AND atc.user_owner = CURRENT_USER
    )
);

CREATE POLICY restrict_update_cars_access ON public.cars
FOR UPDATE
TO owner_atc
USING (
    -- Проверяем, что user_owner в соответствующей ATC равен текущему пользователю
    EXISTS (
        SELECT 1
        FROM public.atc
        WHERE atc.id = cars.id_owning_atc
        AND atc.user_owner = CURRENT_USER
    )
);

CREATE POLICY restrict_delete_cars_access ON public.cars
FOR DELETE
TO owner_atc
USING (
    -- Проверяем, что user_owner в соответствующей ATC равен текущему пользователю
    EXISTS (
        SELECT 1
        FROM public.atc
        WHERE atc.id = cars.id_owning_atc
        AND atc.user_owner = CURRENT_USER
    )
);

-- Создаем политики безопасности для таблицы transportation
CREATE POLICY restrict_select_transportation_access ON public.transportation
FOR SELECT
TO owner_atc
USING (
    -- Проверяем, что user_owner в соответствующей ATC равен текущему пользователю
    EXISTS (
        SELECT 1
        FROM public.atc
        WHERE atc.user_owner = CURRENT_USER AND 
        atc.id = (
                SELECT id_owning_atc 
                FROM public.cars 
                WHERE cars.id = transportation.id_car
            )
    )
);

-- Создаем новую политику безопасности для просмотра данных в таблице transportation для роли analyst и moderator
CREATE POLICY allow_select_transportation_access_for_analyst_or_moderator ON public.transportation
FOR SELECT
TO analyst, moderator
USING (true);

CREATE POLICY restrict_insert_transportation_access ON public.transportation
FOR INSERT
TO owner_atc
WITH CHECK (
    -- Проверяем, что user_owner в соответствующей ATC равен текущему пользователю
    EXISTS (
        SELECT 1
        FROM public.atc
        WHERE atc.user_owner = CURRENT_USER AND 
        atc.id = (
                SELECT id_owning_atc 
                FROM public.cars 
                WHERE cars.id = transportation.id_car
            )
    )
);

CREATE POLICY restrict_update_transportation_access ON public.transportation
FOR UPDATE
TO owner_atc
USING (
    -- Проверяем, что user_owner в соответствующей ATC равен текущему пользователю
    EXISTS (
        SELECT 1
        FROM public.atc
        WHERE atc.user_owner = CURRENT_USER AND 
        atc.id = (
                SELECT id_owning_atc 
                FROM public.cars 
                WHERE cars.id = transportation.id_car
            )
    )
);

CREATE POLICY restrict_delete_transportation_access ON public.transportation
FOR DELETE
TO owner_atc
USING (
    -- Проверяем, что user_owner в соответствующей ATC равен текущему пользователю
    EXISTS (
        SELECT 1
        FROM public.atc
        WHERE atc.user_owner = CURRENT_USER AND 
        atc.id = (
                SELECT id_owning_atc 
                FROM public.cars 
                WHERE cars.id = transportation.id_car
            )
    )
);