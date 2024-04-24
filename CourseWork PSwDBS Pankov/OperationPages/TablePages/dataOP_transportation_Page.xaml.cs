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
    /// Логика взаимодействия для dataOP_transportation_Page.xaml
    /// </summary>
    public partial class dataOP_transportation_Page : Page, IDataOP
    {
        DbContext_Npgsql dbContext;
        public long id = -1;

        public dataOP_transportation_Page()
        {
            InitializeComponent();

            dbContext = DbContext_Npgsql.GetInstance();
        }

        public dataOP_transportation_Page(long ID) : this()
        {
            id = ID;
        }

        public void Add()
        {
            try
            {
                var cargo = (Cargo_ComboBox.SelectedItem as ComboBoxItem)?.Tag;
                var startCity = (StartCity_ComboBox.SelectedItem as ComboBoxItem)?.Content;
                var endCity = (EndCity_ComboBox.SelectedItem as ComboBoxItem)?.Content;
                var startData = StartDate_DatePicker.SelectedDate?.ToString("dd.MM.yyyy");
                var endData = EndDate_DatePicker.SelectedDate?.ToString("dd.MM.yyyy");
                var car = (Car_ComboBox.SelectedItem as ComboBoxItem)?.Tag;
                var driver = (Driver_ComboBox.SelectedItem as ComboBoxItem)?.Tag;

                if (endData == null)
                    endData = "NULL";
                else
                    endData = $"'{endData}'";

                //dbContext.WriteDataBySQL($"SELECT insert_data_transportation('{cargo}', '{CountCargo_TextBox.Text}', '{startCity}', '{endCity}', '{startData}', '{endData}', '{CostTransportation_TextBox.Text}', '{car}', '{driver}')");

                string sql = $"SELECT insert_data_transportation('{cargo}', '{CountCargo_TextBox.Text}', '{startCity}', '{endCity}', '{startData}', {endData}, '{CostTransportation_TextBox.Text}', '{car}', '{driver}')";

                dbContext.SendRequest(sql);
                MessageBox.Show("Предприятие было успешно добавлено!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
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
                var cargo = (Cargo_ComboBox.SelectedItem as ComboBoxItem)?.Tag;
                var startCity = (StartCity_ComboBox.SelectedItem as ComboBoxItem)?.Content;
                var endCity = (EndCity_ComboBox.SelectedItem as ComboBoxItem)?.Content;
                var startData = StartDate_DatePicker.SelectedDate?.ToString("dd.MM.yyyy");
                var endData = EndDate_DatePicker.SelectedDate?.ToString("dd.MM.yyyy");
                var car = (Car_ComboBox.SelectedItem as ComboBoxItem)?.Tag;
                var driver = (Driver_ComboBox.SelectedItem as ComboBoxItem)?.Tag;

                dbContext.SendRequest($"SELECT update_data_transportation('{id}', '{cargo}', '{CountCargo_TextBox.Text}', '{startCity}', '{endCity}', '{startData}', '{endData}', '{CostTransportation_TextBox.Text}', '{car}', '{driver}')");
                MessageBox.Show("Информация о предприятии была успешно обновлена!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        public void LoadData()
        {
            var cargo_s = dbContext.ReadDictionaryFromDatabaseBySQL($"SELECT * FROM get_cargo_info();");
            var cities = dbContext.ReadDictionaryFromDatabaseBySQL($"SELECT * FROM get_cities_info();");
            var cars = dbContext.ReadDictionaryFromDatabaseBySQL($"SELECT * FROM get_cars_info();");
            var drivers = dbContext.ReadDictionaryFromDatabaseBySQL($"SELECT \"ID\", \"Фамилия\" || ' ' || \"Имя\" || ' ' || \"Отчество\" || ': ' || \"Категория\" AS \"ФИО и категория\" FROM get_drivers_info();");

            ComponentOperator_ForPages.SetContentByListDictionary(Cargo_ComboBox, cargo_s, "Груз");
            ComponentOperator_ForPages.SetContentByListDictionary(StartCity_ComboBox, cities, "Город");
            ComponentOperator_ForPages.SetContentByListDictionary(EndCity_ComboBox, cities, "Город");
            ComponentOperator_ForPages.SetContentByListDictionary(Car_ComboBox, cars, "Номер");
            ComponentOperator_ForPages.SetContentByListDictionary(Driver_ComboBox, drivers, "ФИО и категория");

            if (id != -1)
            {
                var transportation = dbContext.ReadFirstDictionaryRecordFromDatabaseBySQL($"SELECT * FROM get_transportation_info() WHERE \"ID\" = {id};");
                
                var cargo = Convert.ToString(transportation["Груз"]);
                CountCargo_TextBox.Text = Convert.ToString(transportation["Количество единиц"]);
                var startCity = Convert.ToString(transportation["Город отбытия"]);
                var endCity = Convert.ToString(transportation["Город прибытия"]);
                StartDate_DatePicker.SelectedDate = DateTime.Parse(transportation["Дата отбытия"].ToString());
                
                var endDate = transportation["Дата прибытия"].ToString();
                if(endDate.Length != 0)
                {
                    EndDate_DatePicker.SelectedDate = DateTime.Parse(endDate);
                }
                
                CostTransportation_TextBox.Text = Convert.ToString(transportation["Стоимость перевозки"]);
                var car = Convert.ToString(transportation["Номер автомобиля"]);
                var driver = Convert.ToString(transportation["ФИО водителя"]) + ": " + transportation["Категория"].ToString();

                ComponentOperator_ForPages.SetSelectedItemByContent(Cargo_ComboBox, cargo);
                ComponentOperator_ForPages.SetSelectedItemByContent(StartCity_ComboBox, startCity);
                ComponentOperator_ForPages.SetSelectedItemByContent(EndCity_ComboBox, endCity);
                ComponentOperator_ForPages.SetSelectedItemByContent(Car_ComboBox, car);
                ComponentOperator_ForPages.SetSelectedItemByContent(Driver_ComboBox, driver);
            }
        }
    }
}
