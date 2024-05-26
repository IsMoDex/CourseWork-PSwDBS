-- Первый Создать запросы, с выводом конкретных полей и их значений
-- Получить всю информацию о пользователях которые предпочитают определенную тему и у которых включены/выключены SMS-уведомления.
-- Не оптимизированный
CREATE OR REPLACE FUNCTION get_users_by_preferences(
    theme TEXT,
    sms_notifications BOOLEAN
)
RETURNS TABLE (
    login TEXT,
    fio TEXT,
    data JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.login,
        (SELECT first_name || ' ' || name || ' ' || last_name FROM public.users u2 WHERE u2.login = u.login) as fio,
        u.data
    FROM public.users u
    WHERE u.data->'preferences'->>'theme' = theme
    AND u.data->'preferences'->'notifications'->>'sms' = sms_notifications::TEXT;
END;
$$ LANGUAGE plpgsql;

-- Оптимизированный
CREATE OR REPLACE FUNCTION get_users_by_preferences(
    theme TEXT,
    sms_notifications BOOLEAN
)
RETURNS TABLE (
    login TEXT,
    fio TEXT,
    data JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.login,
        (first_name || ' ' || name || ' ' || last_name) as fio,
        u.data
    FROM public.users u
    WHERE u.data->'preferences'->>'theme' = theme
    AND u.data->'preferences'->'notifications'->>'sms' = sms_notifications::TEXT;
END;
$$ LANGUAGE plpgsql;

-- Второй Создать запросы, с выводом конкретных полей и их значений
-- Функция для извлечения всей контактной информации пользователя по его логину
-- Не оптимизированный
CREATE OR REPLACE FUNCTION get_contact_info(user_login text)
RETURNS jsonb AS $$
BEGIN
    RETURN (
        SELECT (SELECT data FROM public.users u2 WHERE u2.login = u.login)->'contact_info'
        FROM public.users u
        WHERE login = user_login
    );
END;
$$ LANGUAGE plpgsql;

-- Оптимизированный
CREATE OR REPLACE FUNCTION get_contact_info(user_login text)
RETURNS jsonb AS $$
BEGIN
    RETURN (
        SELECT data->'contact_info'
        FROM public.users
        WHERE login = user_login
    );
END;
$$ LANGUAGE plpgsql;

-- Третий Создать запросы, с выводом конкретных полей и их значений
--Функция для извлечения списка хобби пользователя, возраст которого больше указанного значения
-- Не оптимизированный
CREATE OR REPLACE FUNCTION get_hobbies_by_age(min_age int)
RETURNS TABLE (login text, hobbies jsonb) AS $$
BEGIN
    RETURN QUERY
    SELECT u.login, u.data->'additional_info'->'hobbies'
    FROM public.users u
    WHERE u.data->'personal_info'->>'age' IS NOT NULL 
    AND (u.data->'personal_info'->>'age')::int::text::int > min_age;
END;
$$ LANGUAGE plpgsql;

-- Оптимизированный
CREATE OR REPLACE FUNCTION get_hobbies_by_age(min_age int)
RETURNS TABLE (login text, hobbies jsonb) AS $$
BEGIN
    RETURN QUERY
    SELECT u.login, u.data->'additional_info'->'hobbies'
    FROM public.users u
    WHERE u.data->'personal_info'->>'age' IS NOT NULL 
    AND (u.data->'personal_info'->>'age')::int > min_age;
END;
$$ LANGUAGE plpgsql;

-- Функция для извлечения полного адреса пользователя по логину и условию, что уведомления по email включены
CREATE OR REPLACE FUNCTION get_address_if_email_notifications_enabled(user_login text)
RETURNS jsonb AS $$
BEGIN
    RETURN (
        SELECT data->'personal_info'->'address'
        FROM public.users
        WHERE login = user_login
          AND (data->'preferences'->'notifications'->>'email')::boolean = true
    );
END;
$$ LANGUAGE plpgsql;


-- Первый. Выборки (запросы) с использованием jsonpath 
-- Получить почтовые адреса пользователей, у которых включена почтовая рассылка
-- Не оптимизированный
CREATE OR REPLACE FUNCTION get_emails_with_email_notifications()
RETURNS SETOF text AS $$
BEGIN
    RETURN QUERY
    SELECT jsonb_path_query(data, '$.contact_info.email')::TEXT
    FROM public.users
    WHERE jsonb_path_exists(data, '$.preferences.notifications.email ? (@ == true && $.preferences.theme == "dark")');
END;
$$ LANGUAGE plpgsql;

-- Оптимизированный
CREATE OR REPLACE FUNCTION get_emails_with_email_notifications()
RETURNS SETOF text AS $$
BEGIN
    RETURN QUERY
    SELECT jsonb_path_query(data, '$.contact_info.email')::TEXT
    FROM public.users
    WHERE jsonb_path_exists(data, '$.preferences.notifications.email ? (@ == true)');
END;
$$ LANGUAGE plpgsql;

-- Второй. Выборки (запросы) с использованием jsonpath 
-- Получить рабочие номера пользователей, у которых включена смс рассылка
-- Не оптимизированный
CREATE OR REPLACE FUNCTION get_work_number_with_phone_notifications()
RETURNS SETOF text AS $$
BEGIN
    RETURN QUERY
    SELECT jsonb_path_query(data, '$.contact_info.phones.work')::TEXT
    FROM public.users
    WHERE jsonb_path_exists(data, '$.preferences.notifications.sms ? (@ == true && $.personal_info.age > 18)');
END;
$$ LANGUAGE plpgsql;

-- Оптимизированный
CREATE OR REPLACE FUNCTION get_work_number_with_phone_notifications()
RETURNS SETOF text AS $$
BEGIN
    RETURN QUERY
    SELECT jsonb_path_query(data, '$.contact_info.phones.work')::TEXT
    FROM public.users
    WHERE jsonb_path_exists(data, '$.preferences.notifications.sms ? (@ == true)');
END;
$$ LANGUAGE plpgsql;

-- Третий. Выборки (запросы) с использованием jsonpath 
CREATE OR REPLACE FUNCTION get_addresses_by_region(region text)
RETURNS SETOF jsonb AS $$
BEGIN
    RETURN QUERY
    SELECT jsonb_path_query_array(data, '$.personal_info.address.*')
    FROM public.users
    WHERE jsonb_path_exists(data, '$.personal_info.address.region ? (@ == $region)', jsonb_build_object('region', region));
END;
$$ LANGUAGE plpgsql;

-- Первый. Обновление/добавление/удаление данных в JSON документе 
-- Функция для обновления email пользователя по его логину
CREATE OR REPLACE FUNCTION update_user_email(user_login text, new_email text)
RETURNS void AS $$
BEGIN
    UPDATE public.users
    SET data = jsonb_set(data, '{contact_info, email}', to_jsonb(new_email))
    WHERE login = user_login;
END;
$$ LANGUAGE plpgsql;

-- Второй. Обновление/добавление/удаление данных в JSON документе 
-- Изменение доступа к email и sms оповещениям
CREATE OR REPLACE FUNCTION update_notifications(user_login text, email_notifications boolean, sms_notifications boolean)
RETURNS void AS $$
BEGIN
    UPDATE public.users
    SET data = jsonb_set(data, '{preferences, notifications}', 
              jsonb_build_object(
                  'email', email_notifications, 
                  'sms', sms_notifications
              )::jsonb)
    WHERE login = user_login;
END;
$$ LANGUAGE plpgsql;


-- Третий. Обновление/добавление/удаление данных в JSON документе 
-- Добавление нового хобби
CREATE OR REPLACE FUNCTION add_hobby(user_login text, new_hobby text)
RETURNS void AS $$
BEGIN
    UPDATE public.users
    SET data = jsonb_set(data, '{additional_info, hobbies}', 
              (data->'additional_info'->'hobbies') || to_jsonb(new_hobby)::jsonb)
    WHERE login = user_login;
END;
$$ LANGUAGE plpgsql;


-- Четвертый. Обновление/добавление/удаление данных в JSON документе 
-- Добавления нового поля и данных в дополнительную информацию
CREATE OR REPLACE FUNCTION add_additional_info_field(user_login text, field_name text, field_value jsonb)
RETURNS void AS $$
BEGIN
    UPDATE public.users
    SET data = jsonb_set(data, '{additional_info, ' || field_name || '}', field_value)
    WHERE login = user_login;
END;
$$ LANGUAGE plpgsql;


-- Пятый. Обновление/добавление/удаление данных в JSON документе 
-- Удаление параметра веса из дополнительной информации
CREATE OR REPLACE FUNCTION remove_weight(user_login text)
RETURNS void AS $$
BEGIN
    UPDATE public.users
    SET data = data #- '{additional_info, weight}'
    WHERE login = user_login;
END;
$$ LANGUAGE plpgsql;

-- Шестой. Обновление/добавление/удаление данных в JSON документе 
-- Удаление всей дополнительной информации пользователя
CREATE OR REPLACE FUNCTION clear_additional_info(user_login text)
RETURNS void AS $$
BEGIN
    UPDATE public.users
    SET data = data - 'additional_info'
    WHERE login = user_login;
END;
$$ LANGUAGE plpgsql;