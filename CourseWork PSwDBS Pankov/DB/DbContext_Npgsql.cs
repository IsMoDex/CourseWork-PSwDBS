using Npgsql;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Documents;
using static CourseWork_PSwDBS_Pankov.DB.DbContext_Npgsql;

namespace CourseWork_PSwDBS_Pankov.DB
{
    class DbContext_Npgsql
    {
        private static DbContext_Npgsql dbContext;

        NpgsqlConnection connection;

        public string Server;
        public string Port;
        public string DataBase;
        public string User;
        public string Password;

        //private DbContext_Npgsql(string UserName, string Password) 
        //{
        //    this.Server = "localhost";
        //    this.Port = "5432";
        //    this.DataBase = "TransportCargo_to_MTC";
        //    this.User = UserName;
        //    this.Password = Password;
        //}

        private DbContext_Npgsql()
        {
            this.Server = "localhost";
            this.Port = "5432";
            this.DataBase = "TransportCargo_to_MTC";
        }

        public static DbContext_Npgsql GetInstance()
        {
            if (dbContext == null)
            {
                dbContext = new DbContext_Npgsql();
            }
            return dbContext;
        }

        public bool isConnected
        {
            get
            {
                if (connection == null)
                {
                    return false;
                }
                else if(connection.State == System.Data.ConnectionState.Open)
                {
                    return true;
                }

                return false;
            }
        }

        public void Connect()
        {
            Disconnect();

            string connectionString = $"Server={Server};Port={Port};Database={DataBase};User Id={User};Password={Password};";

            connection = new NpgsqlConnection(connectionString);
            connection.Open();
        }

        private void ConnectIFNeed()
        {
            if (!isConnected)
                Connect();
        }

        public void Disconnect()
        {
            if (isConnected)
            {
                connection.Close();
                connection.Dispose();
                connection = null;
            }
        }

        public List<dynamic> ReadObjectsFromDatabaseByTable(string TableName)
        {
            // Создаем SQL-запрос для выборки всех данных из указанной таблицы
            string query = $"SELECT * FROM {TableName}";

            return ReadObjectsFromDatabaseBySQL(query);
        }
        public List<dynamic> ReadObjectsFromDatabaseBySQL(string SQL)
        {
            ConnectIFNeed();

            List<dynamic> objects = new List<dynamic>();

            using (var cmd = new NpgsqlCommand(SQL, connection))
            {
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        // Создаем анонимный объект для каждой строки результата
                        var obj = new System.Dynamic.ExpandoObject() as IDictionary<string, Object>;

                        // Получаем количество столбцов в результате запроса
                        int fieldCount = reader.FieldCount;

                        // Заполняем анонимный объект значениями из результата запроса
                        for (int i = 0; i < fieldCount; i++)
                        {
                            string fieldName = reader.GetName(i);
                            object value = reader.GetValue(i);
                            obj.Add(fieldName, value);
                        }

                        // Добавляем анонимный объект в список
                        objects.Add(obj);
                    }
                }
            }

            return objects;
        }
        public dynamic ReadObjectFromDatabaseBySQL(string Request)
        {
            var list = ReadObjectsFromDatabaseBySQL(Request);

            if (list.Count > 0)
                return list.First();

            return null;
        }

        public List<Dictionary<string, object>> ReadDictionaryFromDatabaseBySQL(string SQL)
        {
            ConnectIFNeed();

            List<Dictionary<string, object>> objects = new List<Dictionary<string, object>>();

            using (var cmd = new NpgsqlCommand(SQL, connection))
            {
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        // Создаем словарь для каждой строки результата
                        var obj = new Dictionary<string, object>();

                        // Получаем количество столбцов в результате запроса
                        int fieldCount = reader.FieldCount;

                        // Заполняем анонимный объект значениями из результата запроса
                        for (int i = 0; i < fieldCount; i++)
                        {
                            string fieldName = reader.GetName(i);
                            object value = reader.GetValue(i);
                            obj.Add(fieldName, value);
                        }

                        // Добавляем анонимный объект в список
                        objects.Add(obj);
                    }
                }
            }

            return objects;
        }
        public Dictionary<string, object> ReadFirstDictionaryRecordFromDatabaseBySQL(string Request)
        {
            var list = ReadDictionaryFromDatabaseBySQL(Request);

            if (list.Count > 0)
                return list.First();

            return null;
        }

        public DataTable GetDataTableByTable(string TableName)
        {
            string SQL = $"SELECT * FROM {TableName}";

            return GetDataTableBySQL(SQL);
        }

        public DataTable GetDataTableBySQL(string SQL)
        {
            ConnectIFNeed();
            
            // Создаем новую DataTable
            DataTable dataTable = new DataTable();

            // Выполняем запрос к базе данных с помощью NpgsqlDataAdapter
            using (NpgsqlDataAdapter adapter = new NpgsqlDataAdapter(SQL, connection))
            {
                // Заполняем DataTable данными из запроса
                adapter.Fill(dataTable);
            }

            return dataTable;
        }
        public async Task<DataTable> GetDataTableBySQL_Async(string SQL)
        {
            // Используем TaskCompletionSource для создания задачи, которую мы сами завершим, когда выполнится SQL-запрос
            var tcs = new TaskCompletionSource<DataTable>();

            // Создаем новую задачу Task, которая будет выполняться в фоновом потоке
            Task.Run(() =>
            {
                try
                {
                    // Выполняем SQL-запрос и получаем DataTable
                    DataTable dt = GetDataTableBySQL(SQL);

                    // Устанавливаем результат выполнения задачи
                    tcs.SetResult(dt);
                }
                catch (Exception ex)
                {
                    // Если возникла ошибка, устанавливаем исключение в качестве результата задачи
                    tcs.SetException(ex);
                }
            });

            // Возвращаем Task, который мы создали с помощью TaskCompletionSource
            return await tcs.Task;
        }

        public void SendRequest(string SQL)
        {
            ConnectIFNeed();

            using (NpgsqlCommand cmd = new NpgsqlCommand(SQL, connection))
            {
                cmd.ExecuteNonQuery();
            }
        }

        public void WriteDataBySQL(string SQL, Dictionary<string, object> Values)
        {
            ConnectIFNeed();

            using (NpgsqlCommand cmd = new NpgsqlCommand(SQL, connection))
            {
                foreach (var dic in Values)
                {
                    cmd.Parameters.AddWithValue(dic.Key, dic.Value);
                }

                cmd.ExecuteNonQuery();
            }
        }

        public int ExecuteScalarInt(string query)
        {
            ConnectIFNeed();

            int result = 0;

            using (var command = new NpgsqlCommand(query, connection))
            {
                // Выполнение запроса и приведение результата к типу int
                object objResult = command.ExecuteScalar();
                if (objResult != null)
                {
                    int.TryParse(objResult.ToString(), out result);
                }
            }

            return result;
        }

        public T ExecuteScalar<T>(string query)
        {
            ConnectIFNeed();

            object result = null;

            using (var command = new NpgsqlCommand(query, connection))
            {
                // Выполнение запроса и получение результата
                result = command.ExecuteScalar();
            }

            // Преобразование результата к типу T
            return (T)Convert.ChangeType(result, typeof(T));
        }

        public enum Roles
        {
            Analyst,
            Moderator,
            OwnerATC,
            Unknown
        }

        public bool CheckRoleUser(Roles role)
        {
            var rolNname = ExecuteScalar<string>("SELECT * FROM get_role_user()");

            if (role == Roles.Analyst && rolNname.Equals("analyst"))
                return true;
            else if (role == Roles.Moderator && rolNname.Equals("moderator"))
                return true;
            else if (role == Roles.OwnerATC && rolNname.Equals("owner_atc"))
                return true;
            else if (role == Roles.Unknown)
                return true;
            else
                return false;
        }

        public Roles GetUserRole()
        {
            var rolNname = ExecuteScalar<string>("SELECT * FROM get_role_user()");

            if (rolNname.Equals("analyst"))
                return Roles.Analyst;
            else if (rolNname.Equals("moderator"))
                return Roles.Moderator;
            else if (rolNname.Equals("owner_atc"))
                return Roles.OwnerATC;
            else 
                return Roles.Unknown;
        }

        ~DbContext_Npgsql()
        {
            Disconnect();
        }
    }
}