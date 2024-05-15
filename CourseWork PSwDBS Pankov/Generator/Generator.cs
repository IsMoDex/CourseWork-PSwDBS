using CourseWork_PSwDBS_Pankov.DB;
using Npgsql;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;

namespace CourseWork_PSwDBS_Pankov.Generator
{
    delegate void UpdateProgressBarDelegate(int Progress);

    internal class Generator
    {
        private Random random = new Random();

        DbContext_Npgsql dbContext = DbContext_Npgsql.GetInstance();

        public UpdateProgressBarDelegate updateProgressBar { private get; set; }

        //private static string contentPath = Path.Combine(Directory.GetCurrentDirectory(), "Content");

        const int MAX_ERRORS_TO_GENERATE = 20;
        public const string DATE_FORMAT = "dd.MM.yyyy";

        public Dictionary<string, string> GenerateUsers(int count)
        {
            //const string path = "FIO";

            string[] fnames_m = GetLinesFromBytes(Properties.Resources.fnames_m); //ReadLinesFromFile(Path.Combine(contentPath, path, "fnames_m"));
            string[] names_m = GetLinesFromBytes(Properties.Resources.names_m); //ReadLinesFromFile(Path.Combine(contentPath, path, "names_m"));
            string[] lnames_m = GetLinesFromBytes(Properties.Resources.lnames_m); //ReadLinesFromFile(Path.Combine(contentPath, path, "lnames_m"));

            string[] fnames_w = GetLinesFromBytes(Properties.Resources.fnames_w); //ReadLinesFromFile(Path.Combine(contentPath, path, "fnames_w"));
            string[] names_w = GetLinesFromBytes(Properties.Resources.names_w); //ReadLinesFromFile(Path.Combine(contentPath, path, "names_w"));
            string[] lnames_w = GetLinesFromBytes(Properties.Resources.lnames_w); //ReadLinesFromFile(Path.Combine(contentPath, path, "lnames_w"));

            string role = "owner_atc";

            var createdUsers = new Dictionary<string, string>();

            try
            {
                int countErrorsToGenerete = 0;

                int countRecords = dbContext.ExecuteScalarInt("SELECT COUNT(*) FROM users");

                for (int i = 0; i < count; i++)
                {
                    bool gender = random.Next(10) < 7;

                    string userLogin = $"user{countRecords + i + 1}";
                    string password = GenerateRandomPassword();
                    string firstName = string.Empty;
                    string name = string.Empty;
                    string lastName = string.Empty;
                    string roleName = role;

                    //string email = GenerateRandomEmail();
                    //int age = random.Next(22, 65);
                    //string phone = "+" + GenerateRandomPhoneNumber().ToString();
                    //string address = GenerateRandomAddress();

                    //string user_data = "{" + $"\"age\": {age}," + $"\"email\": {email}," + $"\"phone\": {phone}," + $"\"address\": {address}" + "}";

                    var dataObject = new
                    {
                        age = new Random().Next(22, 65),
                        email = GenerateRandomEmail(),
                        phone = "+" + GenerateRandomPhoneNumber().ToString(),
                        address = GenerateRandomAddress()
                    };

                    string user_data = JsonSerializer.Serialize(dataObject);


                    if (gender)
                    {
                        firstName = fnames_m[random.Next(fnames_m.Length)];
                        name = names_m[random.Next(names_m.Length)];
                        lastName = lnames_m[random.Next(lnames_m.Length)];
                    }
                    else
                    {
                        firstName = fnames_w[random.Next(fnames_w.Length)];
                        name = names_w[random.Next(names_w.Length)];
                        lastName = lnames_w[random.Next(lnames_w.Length)];
                    }
                    
                    try
                    {
                        dbContext.SendRequest($"SELECT create_new_user_by_role('{userLogin}', '{password}', '{roleName}', '{firstName}', '{name}', '{lastName}', '{user_data}')");

                        createdUsers.Add(userLogin, password);
                        countErrorsToGenerete = 0;

                        Console.WriteLine($"Был создан Пользователь: {userLogin}\tПароль: {password}\tРоль: {roleName}.");
                    }
                    catch (Exception ex) 
                    {
                        if (countErrorsToGenerete >= MAX_ERRORS_TO_GENERATE)
                            throw new Exception($"Превишино количество попыток генерации записей, последняя ошибка: {ex.Message}");

                        count++;
                        countErrorsToGenerete++;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred: {ex.Message}");
            }

            return createdUsers;
        }

        private string GenerateRandomPassword()
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            char[] passwordChars = new char[random.Next(5, 13)];
            for (int i = 0; i < passwordChars.Length; i++)
            {
                passwordChars[i] = chars[random.Next(chars.Length)];
            }
            return new string(passwordChars);
        }

        public int GenerateAtc(int count)
        {
            //const string path = "ATC";

            string[] adjectives = GetLinesFromBytes(Properties.Resources.adjectives); //ReadLinesFromFile(Path.Combine(contentPath, path, "adjectives"));
            string[] nouns = GetLinesFromBytes(Properties.Resources.nouns); ;//ReadLinesFromFile(Path.Combine(contentPath, path, "nouns"));
            string[] adverbial = GetLinesFromBytes(Properties.Resources.adverbial); ;//ReadLinesFromFile(Path.Combine(contentPath, path, "adverbial"));

            long[] idUrbanAreas = dbContext.GetDataTableBySQL($"SELECT id FROM urban_areas").AsEnumerable().Select(row => row.Field<long>("id")).ToArray();
            int[] idOwnershipTypes = dbContext.GetDataTableBySQL($"SELECT id FROM types_of_ownership").AsEnumerable().Select(row => row.Field<int>("id")).ToArray();
            string[] logins = GenerateUsers(count).Select(x => x.Key).ToArray();

            int countCreatedATC = 0;

            try
            {
                int countErrorsToGenerete = 0;

                for (int i = 0; i < logins.Length; i++)
                {
                    string atcName = string.Empty;
                    long idUrbanArea = idUrbanAreas[random.Next(idUrbanAreas.Length)];
                    int idOwnershipType = idOwnershipTypes[random.Next(idOwnershipTypes.Length)];
                    int year = random.Next(1900, DateTime.Now.Year);
                    long phone = GenerateRandomPhoneNumber();
                    string login = logins[i];

                    if(random.Next(10) <= 3)
                    {
                        atcName = $"{adjectives[random.Next(adjectives.Length)]} {nouns[random.Next(nouns.Length)]} {adverbial[random.Next(adverbial.Length)]}";
                    }
                    else
                    {
                        atcName = $"{adjectives[random.Next(adjectives.Length)]} {nouns[random.Next(nouns.Length)]}";
                    }

                    try
                    {
                        dbContext.SendRequest($"INSERT INTO atc (name, id_urban_area, id_type_of_ownership, year, phone, user_owner) VALUES ('{atcName}', '{idUrbanArea}', '{idOwnershipType}', '{year}', '{phone}', '{login}')");

                        countCreatedATC++;
                        countErrorsToGenerete = 0;
                        UpdateProgressBar(i + 1, count);

                        Console.WriteLine($"Было создано АТС: {atcName} в районе с id: {idUrbanArea}.");
                    }
                    catch (Exception ex)
                    {
                        if (countErrorsToGenerete >= MAX_ERRORS_TO_GENERATE)
                            throw new Exception($"Превышено количество попыток генерации записей, последняя ошибка: {ex.Message}");

                        countErrorsToGenerete++;
                        i--;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred: {ex.Message}");
            }

            return countCreatedATC;
        }

        public int GenerateDrivers(int count)
        {
            //const string path = "FIO";

            string[] fnames_m = GetLinesFromBytes(Properties.Resources.fnames_m); //ReadLinesFromFile(Path.Combine(contentPath, path, "fnames_m"));
            string[] names_m = GetLinesFromBytes(Properties.Resources.names_m); //ReadLinesFromFile(Path.Combine(contentPath, path, "names_m"));
            string[] lnames_m = GetLinesFromBytes(Properties.Resources.lnames_m); //ReadLinesFromFile(Path.Combine(contentPath, path, "lnames_m"));

            string[] fnames_w = GetLinesFromBytes(Properties.Resources.fnames_w); //ReadLinesFromFile(Path.Combine(contentPath, path, "fnames_w"));
            string[] names_w = GetLinesFromBytes(Properties.Resources.names_w); //ReadLinesFromFile(Path.Combine(contentPath, path, "names_w"));
            string[] lnames_w = GetLinesFromBytes(Properties.Resources.lnames_w); //ReadLinesFromFile(Path.Combine(contentPath, path, "lnames_w"));

            int[] idCategories = dbContext.GetDataTableBySQL($"SELECT id FROM driving_categories").AsEnumerable().Select(row => row.Field<int>("id")).ToArray();
            Dictionary<long, int> idAtcs = dbContext.GetDataTableBySQL($"SELECT id, year FROM atc")
                .AsEnumerable()
                .ToDictionary(row => row.Field<long>("id"), row => row.Field<int>("year"));

            int countCreatedDrivers = 0;

            try
            {
                int countErrorsToGenerate = 0;  

                for (int i = 0; i < count; i++)
                {
                    string firstName = string.Empty;
                    string name = string.Empty;
                    string lastName = string.Empty;
                    long idOwningATC = idAtcs.Keys.ElementAt(random.Next(idAtcs.Count));
                    var dateBirth = GenerateRandomDate(DateTime.Now.AddYears(-70), DateTime.Now.AddYears(-19));
                    var startDate = DateTime.Now;
                    long idDrivingCategory = idCategories[random.Next(idCategories.Length)];
                    int salary = random.Next(20000, 500000);

                    if (random.Next(10) < 8)
                    {
                        firstName = fnames_m[random.Next(fnames_m.Length)];
                        name = names_m[random.Next(names_m.Length)];
                        lastName = lnames_m[random.Next(lnames_m.Length)];
                    }
                    else
                    {
                        firstName = fnames_w[random.Next(fnames_w.Length)];
                        name = names_w[random.Next(names_w.Length)];
                        lastName = lnames_w[random.Next(lnames_w.Length)];
                    }

                    {
                        var createDateAtc = DateTime.Parse($"01.01.{idAtcs[idOwningATC]}");

                        // Определяем границы для startDate
                        var earliestStartDate = createDateAtc > dateBirth.AddYears(19) ? createDateAtc : dateBirth.AddYears(19);
                        var latestStartDate = DateTime.Now;

                        // Генерируем случайную дату начала работы
                        startDate = GenerateRandomDate(earliestStartDate, latestStartDate);
                    }

                    try
                    {
                        dbContext.SendRequest($"INSERT INTO drivers (first_name, name, last_name, date_of_birth, start_date, id_owning_atc, id_driving_category, salary) " +
                                              $"VALUES ('{firstName}', '{name}', '{lastName}', '{dateBirth.ToString(DATE_FORMAT)}', '{startDate.ToString(DATE_FORMAT)}', '{idOwningATC}', '{idDrivingCategory}', '{salary}')");

                        countCreatedDrivers++;
                        countErrorsToGenerate = 0;
                        UpdateProgressBar(i + 1, count);

                        Console.WriteLine($"Driver created: {firstName} {name} {lastName}, Category: {idDrivingCategory}, Salary: {salary}.");
                    }
                    catch (Exception ex)
                    {
                        if (countErrorsToGenerate >= MAX_ERRORS_TO_GENERATE)
                            throw new Exception($"Exceeded maximum attempts to generate records, last error: {ex.Message}");

                        countErrorsToGenerate++;
                        i--;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred: {ex.Message}");
            }

            return countCreatedDrivers;
        }

        public int GenerateCars(int count)
        {
            long[] idCarBrands = dbContext.GetDataTableBySQL($"SELECT id FROM car_brands").AsEnumerable().Select(row => row.Field<long>("id")).ToArray();
            long[] idATC_s = dbContext.GetDataTableBySQL($"SELECT id FROM atc").AsEnumerable().Select(row => row.Field<long>("id")).ToArray();

            var createdCars = 0;

            try
            {
                int countErrorsToGenerate = 0;

                for (int i = 0; i < count; i++)
                {
                    string licensePlate = GenerateRandomLicensePlate();
                    long idOwningATC = idATC_s[random.Next(idATC_s.Length)];
                    long idCarBrand = idCarBrands[random.Next(idCarBrands.Length)];

                    try
                    {
                        dbContext.SendRequest($"INSERT INTO cars (license_plate, id_owning_atc, id_car_brand) " +
                                              $"VALUES ('{licensePlate}', '{idOwningATC}', '{idCarBrand}')");

                        createdCars++;
                        countErrorsToGenerate = 0;
                        UpdateProgressBar(i + 1, count);

                        Console.WriteLine($"Car created: License Plate: {licensePlate}, BrandID: {idCarBrand}, IDOwningATC: {idOwningATC}.");
                    }
                    catch (Exception ex)
                    {
                        if (countErrorsToGenerate >= MAX_ERRORS_TO_GENERATE)
                            throw new Exception($"Exceeded maximum attempts to generate records, last error: {ex.Message}");

                        countErrorsToGenerate++;
                        i--;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred: {ex.Message}");
            }

            return createdCars;
        }

        private string GenerateRandomLicensePlate()
        {
            // Генерация случайного государственного номера автомобиля
            string letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            string digits = "0123456789";

            string licensePlate = $"{letters[random.Next(letters.Length)]}{letters[random.Next(letters.Length)]}{letters[random.Next(letters.Length)]} " +
                                  $"{digits[random.Next(digits.Length)]}{digits[random.Next(digits.Length)]}{digits[random.Next(digits.Length)]} " +
                                  $"{letters[random.Next(letters.Length)]}{letters[random.Next(letters.Length)]}{letters[random.Next(letters.Length)]} " +
                                  $"{digits[random.Next(digits.Length)]}{digits[random.Next(digits.Length)]}";

            return licensePlate;
        }

        private class Car_ATC_info
        {
            public long ID_car { get; set; }
            public int LoadCapacity_car { get; set; }

            public long ID_OvningATC { get; set; }
            public int StartYear_Atc { get; set; }
        }

        public int GenerateTransportations(int count)
        {
            var idCities = dbContext.GetDataTableBySQL("SELECT id FROM cities").AsEnumerable()
                            .Select(row => row.Field<long>("id")).ToArray();

            Dictionary<long, int> cargos = dbContext.GetDataTableBySQL("SELECT id, weight FROM cargo")
                .AsEnumerable()
                .ToDictionary(row => row.Field<long>("id"), row => row.Field<int>("weight"));

            List<Car_ATC_info> cars = dbContext.GetDataTableBySQL("SELECT DISTINCT id_owning_atc, year, cars.id as id_car, load_capacity \r\nFROM cars \r\nJOIN car_brands ON cars.id_car_brand = car_brands.id \r\nJOIN atc ON atc.id = id_owning_atc\r\nJOIN transportation ON cars.id = transportation.id_car\r\nWHERE transportation.arrival_date IS NOT NULL")
                .AsEnumerable()
                .Select(row => new Car_ATC_info
                {
                    ID_car = row.Field<long>("id_car"),
                    ID_OvningATC = row.Field<long>("id_owning_atc"),
                    LoadCapacity_car = row.Field<int>("load_capacity"),
                    StartYear_Atc = row.Field<int>("year")
                })
                .ToList();

            Dictionary<long, long[]> idDriversByIdATC = dbContext.GetDataTableBySQL("SELECT id_owning_atc, ARRAY_AGG(distinct_id) AS array \r\nFROM (\r\n    SELECT DISTINCT id_owning_atc, drivers.id as distinct_id\r\n    FROM drivers \r\n    LEFT JOIN transportation ON drivers.id = transportation.id_driver\r\n    WHERE transportation IS NULL OR transportation.arrival_date IS NOT NULL\r\n) AS subquery\r\nGROUP BY id_owning_atc;")
                .AsEnumerable()
                .ToDictionary(row => row.Field<long>("id_owning_atc"), row => row.Field<long[]>("array"));

            var createdTransportations = 0;

            try
            {
                int countErrorsToGenerate = 0;

                for (int i = 0; i < count; i++)
                {
                    var atc_car_info = cars[random.Next(cars.Count)];
                    var drivers_arr = idDriversByIdATC[atc_car_info.ID_OvningATC];

                    var idCargo = cargos.Keys.ElementAt(random.Next(cargos.Count));
                    int numberOfUnits = random.Next(1, atc_car_info.LoadCapacity_car / cargos[idCargo]);

                    var idCityDeparture = idCities[random.Next(idCities.Length)];
                    var idCityArrival = idCities[random.Next(idCities.Length)];

                    var departureDate = GenerateRandomDate(DateTime.Parse($"01.01.{atc_car_info.StartYear_Atc}"), DateTime.Now.AddDays(-1));
                    var arrivalDate = GenerateRandomDate(departureDate, DateTime.Now);

                    int costOfTransportation = random.Next(1000, 99999);

                    var idCar = atc_car_info.ID_car;
                    var idDriver = drivers_arr[random.Next(drivers_arr.Length)];

                    try
                    {
                        dbContext.SendRequest($"INSERT INTO transportation (id_cargo, number_of_units, id_city_departure, id_city_arrival, departure_date, arrival_date, cost_of_transportation, id_car, id_driver) " +
                                $"VALUES ('{idCargo}', '{numberOfUnits}', '{idCityDeparture}', '{idCityArrival}', '{departureDate}', '{arrivalDate}', '{costOfTransportation}', '{idCar}', '{idDriver}')");

                        createdTransportations++;
                        countErrorsToGenerate = 0;
                        UpdateProgressBar(i + 1, count);

                        Console.WriteLine($"Transportation created: Cargo: {idCargo}, Number of Units: {numberOfUnits}, Departure: {idCityDeparture}, Arrival: {idCityArrival}, Departure Date: {departureDate}, Arrival Date: {arrivalDate}, Cost: {costOfTransportation}, Car: {idCar}, Driver: {idDriver}.");
                    }
                    catch (Exception ex)
                    {
                        if (countErrorsToGenerate >= MAX_ERRORS_TO_GENERATE)
                            throw new Exception($"Exceeded maximum attempts to generate records, last error: {ex.Message}");

                        countErrorsToGenerate++;
                        i--;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred: {ex.Message}");
            }

            return createdTransportations;
        }

        private void UpdateProgressBar(int progress, int finalValue)
        {
            if(updateProgressBar != null)
            {
                int percentProgress = (progress * 100) / finalValue;

                Application.Current.Dispatcher.Invoke(() =>
                {
                    updateProgressBar(percentProgress);
                });
            }
        }


        public DateTime GenerateRandomDate(DateTime startDate, DateTime endDate)
        {
            if (startDate >= endDate)
            {
                throw new ArgumentException("startDate must be earlier than endDate");
            }

            Random random = new Random(this.random.Next(int.MaxValue));
            int range = (endDate - startDate).Days;
            return startDate.AddDays(random.Next(range));
        }

        private long GenerateRandomPhoneNumber()
        {
            long min = 1000000000; // 10-digit phone number
            long max = 9999999999;
            return random.Next((int)min, (int)max);
        }

        private string GenerateRandomString(int length)
        {
            Random random = new Random();
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"; // Доступные символы
            StringBuilder stringBuilder = new StringBuilder(length);

            for (int i = 0; i < length; i++)
            {
                stringBuilder.Append(chars[random.Next(chars.Length)]);
            }

            return stringBuilder.ToString();
        }

        private string GenerateRandomEmail()
        {
            string[] emailDomains = { "gmail.com", "yahoo.com", "outlook.com", "mail.ru", "yandex.ru", "aol.com", "protonmail.com", "icloud.com", "zoho.com", "gmx.com" };

            return GenerateRandomString(random.Next(3, 20)) + "@" + emailDomains[random.Next(emailDomains.Length)];
        }

        static string GenerateRandomAddress()
        {
            Random random = new Random();

            if (random.Next(10) <= 4)
            {
                string[] usStreetNames = { "Maple", "Oak", "Pine", "Cedar", "Elm", "Main", "First", "Second", "Third" };
                string[] usStreetTypes = { "Street", "Avenue", "Lane", "Road", "Boulevard", "Court" };
                string[] usCities = { "New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia", "San Antonio", "San Diego", "Dallas", "San Jose" };
                string[] usStates = { "NY", "CA", "IL", "TX", "AZ", "PA", "TX", "CA", "TX", "CA" };
                int usHouseNumber = random.Next(1, 1000);
                string usStreetName = usStreetNames[random.Next(usStreetNames.Length)];
                string usStreetType = usStreetTypes[random.Next(usStreetTypes.Length)];
                string usCity = usCities[random.Next(usCities.Length)];
                string usState = usStates[random.Next(usStates.Length)];

                return $"{usHouseNumber} {usStreetName} {usStreetType}, {usCity}, {usState}";
            }
            else
            {
                string[] ruStreetNames = { "Ленина", "Пушкина", "Гагарина", "Советская", "Мира", "Центральная", "Новая", "Садовая", "Школьная" };
                string[] ruStreetTypes = { "ул.", "пр-т.", "пер.", "пл.", "проезд", "бул." };
                string[] ruCities = { "Москва", "Санкт-Петербург", "Новосибирск", "Екатеринбург", "Нижний Новгород", "Казань", "Челябинск", "Омск", "Самара", "Ростов-на-Дону" };
                string[] ruRegions = { "Московская обл.", "Ленинградская обл.", "Новосибирская обл.", "Свердловская обл.", "Нижегородская обл.", "Республика Татарстан", "Челябинская обл.", "Омская обл.", "Самарская обл.", "Ростовская обл." };
                int ruHouseNumber = random.Next(1, 200);
                string ruStreetName = ruStreetNames[random.Next(ruStreetNames.Length)];
                string ruStreetType = ruStreetTypes[random.Next(ruStreetTypes.Length)];
                string ruCity = ruCities[random.Next(ruCities.Length)];
                string ruRegion = ruRegions[random.Next(ruRegions.Length)];

                return $"{ruCity}, {ruStreetName} {ruStreetType}, {ruHouseNumber}, {ruRegion}";
            }
        }



        private string[] ReadLinesFromFile(string filePath)
        {
            List<string> lines = new List<string>();

            try
            {
                using (StreamReader sr = new StreamReader(filePath))
                {
                    string line;
                    while ((line = sr.ReadLine()) != null)
                    {
                        lines.Add(line);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred while reading the file: {ex.Message}");
                MessageBox.Show($"An error occurred while reading the file: {ex.Message}", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
                return null;
            }

            return lines.ToArray();
        }

        private string[] GetLinesFromBytes(byte[] bytes)
        {
            // Получаем массив байтов из ресурсов
            byte[] byteArray = bytes;

            // Преобразуем массив байтов в строку, используя определенную кодировку
            string content = Encoding.UTF8.GetString(byteArray); // Используйте правильную кодировку

            // Разделяем строку на массив строк по разделителю (если строки разделены, например, символом новой строки)
            string[] lines = content.Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);

            return lines;
        }
    }
}
