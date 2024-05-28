using CourseWork_PSwDBS_Pankov.DB;
using System;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Windows;
using System.Windows.Controls;

namespace CourseWork_PSwDBS_Pankov.OperationPages.TablePages
{
    /// <summary>
    /// Логика взаимодействия для dataOP_users_Page.xaml
    /// </summary>
    public partial class dataOP_users_Page : Page, IDataOP
    {
        DbContext_Npgsql dbContext;

        public dataOP_users_Page()
        {
            InitializeComponent();

            dbContext = DbContext_Npgsql.GetInstance();
        }

        public void Add()
        {
            try
            {
                string role = (Roles_ComboBox.SelectedItem as ComboBoxItem).Tag.ToString();

                //string user_data = "{" + $"\"age\": {Age_TestBox.Text}," + $"\"email\": {Email_TestBox.Text}," + $"\"phone\": +{Phone_TestBox.Text}," + $"\"address\": {Address_TestBox.Text}" + "}";

                var dataObject = new
                {
                    age = Age_TestBox.Text,
                    email = Email_TestBox.Text,
                    phone = "+" + Phone_TestBox.Text,
                    address = Address_TestBox.Text
                };

                string user_data = JsonSerializer.Serialize(dataObject);

                dbContext.SendRequest($"SELECT create_new_user_by_role('{Login_TextBox.Text}', '{Password_TextBox.Password}', '{role}', '{FirstName_TextBox.Text}', '{Name_TextBox.Text}', '{LastName_TestBox.Text}', '{user_data}')");
                MessageBox.Show("Пользователь был успешно добавлен!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        public void Change()
        {
            //try
            //{
            //    dbContext.SendRequest($"SELECT update_data_cities('{id}', '{NameCityTextBox.Text}')");
            //    MessageBox.Show("Город был успешно обновлен!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
            //}
            //catch (Exception ex)
            //{
            //    MessageBox.Show(ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            //}
        }

        public void LoadData()
        {
            //if (id != -1)
            //{
            //    dynamic city = dbContext.ReadObjectFromDatabaseBySQL($"SELECT * FROM get_cities_info() WHERE \"ID\" = {id};");
            //    NameCityTextBox.Text = city.Город;
            //}
        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
            Phone_TestBox.PreviewTextInput += TextBox_PreviewTextInput;
        }

        private void TextBox_PreviewTextInput(object sender, System.Windows.Input.TextCompositionEventArgs e)
        {
            // Проверяем, что вводимый символ - цифра
            if (!IsNumeric(e.Text))
            {
                e.Handled = true; // Отменяем ввод недопустимого символа
            }
        }

        // Метод для проверки, является ли строка числом
        private bool IsNumeric(string text)
        {
            return Regex.IsMatch(text, @"^[0-9]+$");
        }
    }
}
