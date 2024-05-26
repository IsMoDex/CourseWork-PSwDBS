CREATE TABLE transportation_hash (
    id bigserial PRIMARY KEY,
    id_cargo bigint NOT NULL,
    number_of_units integer NOT NULL,
    id_city_departure bigint NOT NULL,
    id_city_arrival bigint NOT NULL,
    departure_date date NOT NULL,
    arrival_date date,
    cost_of_transportation integer NOT NULL,
    id_car bigint NOT NULL,
    id_driver bigint NOT NULL
) PARTITION BY HASH (id);

CREATE TABLE transportations_hash_0 PARTITION OF transportation_hash FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE transportations_hash_1 PARTITION OF transportation_hash FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE transportations_hash_2 PARTITION OF transportation_hash FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE transportations_hash_3 PARTITION OF transportation_hash FOR VALUES WITH (MODULUS 4, REMAINDER 3);

--  --  --  --  --  --  --  --  --  --

CREATE TABLE transportation_range (
    id_cargo bigint NOT NULL
    number_of_units integer NOT NULL,
    id_city_departure bigint NOT NULL,
    id_city_arrival bigint NOT NULL,
    departure_date date NOT NULL,
    arrival_date date,
    cost_of_transportation integer NOT NULL,
    id_car bigint NOT NULL,
    id_driver bigint NOT NULL
) PARTITION BY RANGE (arrival_date);

ALTER TABLE transportation_range
ADD CONSTRAINT unique_record UNIQUE (id_cargo, number_of_units, id_city_departure, id_city_arrival, departure_date, arrival_date, cost_of_transportation, id_car, id_driver)

CREATE TABLE transportation_range_old PARTITION OF transportation_range FOR VALUES FROM ('01.01.1200') TO ('01.01.2022');
CREATE TABLE transportation_range_2022 PARTITION OF transportation_range FOR VALUES FROM ('01.01.2022') TO ('01.01.2023');
CREATE TABLE transportation_range_2023 PARTITION OF transportation_range FOR VALUES FROM ('01.01.2023') TO ('01.01.2024');
CREATE TABLE transportation_range_2024 PARTITION OF transportation_range FOR VALUES FROM ('01.01.2024') TO ('01.01.2025');
CREATE TABLE transportation_range_default PARTITION OF transportation_range DEFAULT;