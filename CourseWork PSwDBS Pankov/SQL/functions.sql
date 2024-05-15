-- Сначала удаляем существующий ENUM
DROP TYPE IF EXISTS roles;

-- Затем создаем новый ENUM
CREATE TYPE roles AS ENUM ('owner_atc', 'moderator', 'analyst');

-- Создаем нового пользователя с определенной ролью
CREATE OR REPLACE FUNCTION create_new_user_by_role
(
    user_login text, 
    pass text, 
    user_role roles,
    first_name character varying(32), 
    name character varying(32), 
    last_name character varying(32),
    user_data JSONB
)
RETURNS VOID AS $$
BEGIN
    EXECUTE format('CREATE USER %I WITH PASSWORD %L', user_login, pass);

    CASE user_role
        WHEN 'owner_atc' THEN
            EXECUTE format('GRANT owner_atc TO %I', user_login);
        WHEN 'moderator' THEN
            EXECUTE format('GRANT moderator TO %I', user_login);
        WHEN 'analyst' THEN
            EXECUTE format('GRANT analyst TO %I', user_login);
    END CASE;

    INSERT INTO users (login, first_name, name, last_name, data) VALUES (user_login, first_name, name, last_name, user_data);
END;
$$ LANGUAGE plpgsql;

-- Удаляем пользователя по логину
CREATE OR REPLACE FUNCTION delete_user_by_login
(
    user_login text
)
RETURNS VOID AS $$
BEGIN
    EXECUTE format('DROP USER %I', user_login);

    EXECUTE format('DELETE FROM users WHERE login = %L', user_login);
END;
$$ LANGUAGE plpgsql

-- Получаем названия всех таблиц к которым есть доступ у пользователя
-- CREATE OR REPLACE FUNCTION get_available_tables_between_all()
-- RETURNS TABLE ("Таблицы" text) AS $$
-- BEGIN
--     RETURN QUERY SELECT DISTINCT table_name::text
--     FROM information_schema.table_privileges
--     WHERE privilege_type IN ('INSERT', 'UPDATE', 'DELETE') AND table_name NOT LIKE 'pg_%';
-- END;
-- $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_available_tables_between_role()
RETURNS TABLE ("Таблицы" text) AS $$
BEGIN
    IF ((SELECT pg_has_role(CURRENT_USER, 'owner_atc', 'MEMBER')) OR (SELECT pg_has_role(CURRENT_USER, 'moderator', 'MEMBER')))
    THEN
        RETURN QUERY 
        SELECT table_name::text
        FROM information_schema.tables
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
        AND has_table_privilege(
            quote_ident(table_schema) || '.' || quote_ident(table_name),
            'SELECT'
        )
        AND has_table_privilege(
            quote_ident(table_schema) || '.' || quote_ident(table_name),
            'INSERT'
        )
        AND has_table_privilege(
            quote_ident(table_schema) || '.' || quote_ident(table_name),
            'UPDATE'
        )
        AND has_table_privilege(
            quote_ident(table_schema) || '.' || quote_ident(table_name),
            'DELETE'
        );
    ELSIF (SELECT pg_has_role(CURRENT_USER, 'analyst', 'MEMBER'))
    THEN
        RETURN QUERY 
        SELECT table_name::text
        FROM information_schema.tables
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
        AND has_table_privilege(
            quote_ident(table_schema) || '.' || quote_ident(table_name),
            'SELECT'
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Получаем роль пользователя 
CREATE OR REPLACE FUNCTION get_role_user()
RETURNS roles AS $$
BEGIN
    IF (SELECT pg_has_role(CURRENT_USER, 'owner_atc', 'MEMBER'))
    THEN
        RETURN 'owner_atc';
    ELSIF (SELECT pg_has_role(CURRENT_USER, 'analyst', 'MEMBER'))
    THEN
        RETURN 'analyst';
    ELSIF (SELECT pg_has_role(CURRENT_USER, 'moderator', 'MEMBER'))
    THEN
        RETURN 'moderator';
	END IF;
END;
$$ LANGUAGE plpgsql;