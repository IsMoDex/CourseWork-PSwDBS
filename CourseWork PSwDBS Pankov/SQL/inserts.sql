--SELECT start_sql('E:\\PosgreSQL_Scripts\\Sem_VI\\db.sql');

INSERT INTO public.cities (name) VALUES ('Город1'), ('Город2'), ('Город3'); 
INSERT INTO public.urban_areas (name, id_city) VALUES ('Area1', 1), ('Area2', 2), ('Area3', 3); 
INSERT INTO public.types_of_ownership (name) VALUES ('Частная'), ('Не очень частная'); 
INSERT INTO public.atc (name, id_urban_area, id_type_of_ownership, year, phone) 
VALUES ('Name1', 1, 1, 2024, '794934444'),
('Name2', 2, 2, 2023, '794934442'),
('Name3', 2, 1, 2021, '794934443'); --Не актуально

SELECT 
	atc.name "Название АТС", 
	u.name "Район", 
	cit.name "Город", 
	typ.name "Тип собственности",
	atc.year "Год открытия",
	atc.phone "Телефон"
	FROM public.atc atc
	JOIN public.urban_areas u ON u.id = atc.id_urban_area
	JOIN public.types_of_ownership typ ON typ.id = atc.id_type_of_ownership
	JOIN public.cities cit ON cit.id = u.id_city;