-- Создание партиций
CREATE TABLE transportation_2022 PARTITION OF get_transportation_info()
    FOR VALUES FROM (2022);

CREATE INDEX ON transportation_2022 (EXTRACT(YEAR FROM arrival_date));