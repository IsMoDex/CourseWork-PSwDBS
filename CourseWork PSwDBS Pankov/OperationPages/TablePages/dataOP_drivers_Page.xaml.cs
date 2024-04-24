using CourseWork_PSwDBS_Pankov.DB;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace CourseWork_PSwDBS_Pankov.OperationPages.TablePages
{
    /// <summary>
    /// Логика взаимодействия для dataOP_drivers_Page.xaml
    /// </summary>
    public partial class dataOP_drivers_Page : Page, IDataOP
    {
        DbContext_Npgsql dbContext;
        public long id = -1;

        public dataOP_drivers_Page()
        {
            InitializeComponent();

            dbContext = DbContext_Npgsql.GetInstance();
        }

        public dataOP_drivers_Page(long ID) : this()
        {
            id = ID;
        }

        public void Add()
        {
            try
            {
                string dateOfBirth = DateOfBirth_DatePicker.SelectedDate?.ToString("dd.MM.yyyy"); // Формат "dd.MM.yyyy" будет дд.мм.гггг
                string startDate = StartDate_DatePicker.SelectedDate?.ToString("dd.MM.yyyy"); // Формат "dd.MM.yyyy" будет дд.мм.гггг
                var category = (DrivingCategory_ComboBox.SelectedItem as ComboBoxItem)?.Content;

                dbContext.SendRequest($"SELECT insert_data_drivers('{FirstName_TextBox.Text}', '{Name_TextBox.Text}', '{LastName_TextBox.Text}', '{dateOfBirth}', '{startDate}', '{category}', '{Salary_TextBox.Text}')");
                MessageBox.Show("Водитель был успешно добавлен!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        public void Change()
        {
            try
            {
                string dateOfBirth = DateOfBirth_DatePicker.SelectedDate?.ToString("dd.MM.yyyy"); // Формат "dd.MM.yyyy" будет дд.мм.гггг
                string startDate = StartDate_DatePicker.SelectedDate?.ToString("dd.MM.yyyy"); // Формат "dd.MM.yyyy" будет дд.мм.гггг
                var category = (DrivingCategory_ComboBox.SelectedItem as ComboBoxItem)?.Content;

                dbContext.SendRequest($"SELECT update_data_drivers('{id}', '{FirstName_TextBox.Text}', '{Name_TextBox.Text}', '{LastName_TextBox.Text}', '{dateOfBirth}', '{startDate}', '{category}', '{Salary_TextBox.Text}')");
                MessageBox.Show("Информация о водителе была успешно обновлена!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        public void LoadData()
        {
            var categories = dbContext.ReadDictionaryFromDatabaseBySQL($"SELECT * FROM get_driving_categories_info();");

            ComponentOperator_ForPages.SetContentByListDictionary(DrivingCategory_ComboBox, categories, "Категория");

            if (id != -1)
            {
                var drivers = dbContext.ReadFirstDictionaryRecordFromDatabaseBySQL($"SELECT * FROM get_drivers_info() WHERE \"ID\" = {id};");
                FirstName_TextBox.Text = Convert.ToString(drivers["Фамилия"]);
                Name_TextBox.Text = Convert.ToString(drivers["Имя"]);
                LastName_TextBox.Text = Convert.ToString(drivers["Отчество"]);
                DateOfBirth_DatePicker.SelectedDate = DateTime.Parse(drivers["Дата рождения"].ToString());
                StartDate_DatePicker.SelectedDate = DateTime.Parse(drivers["Начало работы"].ToString());

                var category = Convert.ToString(drivers["Категория"]);

                Salary_TextBox.Text = Convert.ToString(drivers["Оклад"]);

                ComponentOperator_ForPages.SetSelectedItemByContent(DrivingCategory_ComboBox, category);
            }
        }
    }
}
