-- atc
CREATE INDEX idx_atc_user_owner ON atc (user_owner);

--users
CREATE INDEX idx_users_login ON users(login);

-- transportation
-- Индексы для обычной таблицы
CREATE INDEX idx_transportation_id_cargo ON transportation (id_cargo);
CREATE INDEX idx_transportation_departure_date ON transportation (departure_date);
CREATE INDEX idx_transportation_arrival_date ON transportation (arrival_date);
CREATE INDEX idx_transportation_id_driver ON transportation (id_driver);

-- Users
-- Создание индекса на поле data
CREATE INDEX idx_users_data ON public.users USING gin (data);

-- Создание индекса на поле age внутри JSON документа
CREATE INDEX idx_users_age ON public.users ((data->'personal_info'->>'age'));

-- Создание индекса на поле email внутри JSON документа
CREATE INDEX idx_users_email ON public.users ((data->'contact_info'->>'email'));

-- transportation_hash
-- Индексы для основной таблицы
CREATE INDEX ON transportation_hash (id);

-- Индексы для каждой секции
CREATE INDEX ON transportations_hash_0 (id);
CREATE INDEX ON transportations_hash_1 (id);
CREATE INDEX ON transportations_hash_2 (id);
CREATE INDEX ON transportations_hash_3 (id);

-- Дополнительные индексы по ключевым полям
CREATE INDEX idx_transportation_hash_id_cargo ON transportation_hash (id_cargo);
CREATE INDEX idx_transportation_hash_departure_date ON transportation_hash (departure_date);
CREATE INDEX idx_transportation_hash_arrival_date ON transportation_hash (arrival_date);

-- transportation_range
-- Индексы для основной таблицы
CREATE INDEX ON transportation_range (arrival_date);

-- Индексы для каждой секции
CREATE INDEX ON transportation_range_old (arrival_date);
CREATE INDEX ON transportation_range_2022 (arrival_date);
CREATE INDEX ON transportation_range_2023 (arrival_date);
CREATE INDEX ON transportation_range_2024 (arrival_date);
CREATE INDEX ON transportation_range_default (arrival_date);

-- Дополнительные индексы по ключевым полям
CREATE INDEX idx_transportation_range_id_cargo ON transportation_range (id_cargo);
CREATE INDEX idx_transportation_range_departure_date ON transportation_range (departure_date);
CREATE INDEX idx_transportation_range_id_driver ON transportation_range (id_driver);