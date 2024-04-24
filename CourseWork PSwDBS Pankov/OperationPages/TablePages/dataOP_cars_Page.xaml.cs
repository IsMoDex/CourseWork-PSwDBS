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
    /// Логика взаимодействия для dataOP_cars_Page.xaml
    /// </summary>
    public partial class dataOP_cars_Page : Page, IDataOP
    {
        DbContext_Npgsql dbContext;
        public long id = -1;

        public dataOP_cars_Page()
        {
            InitializeComponent();

            dbContext = DbContext_Npgsql.GetInstance();
        }

        public dataOP_cars_Page(long ID) : this()
        {
            id = ID;
        }

        public void Add()
        {
            try
            {
                var car_brand = (CarBrand_ComboBox.SelectedValue as ComboBoxItem)?.Content;

                dbContext.SendRequest($"SELECT insert_data_cars('{LicencePlate_TextBox.Text}', '{car_brand}')");
                MessageBox.Show("Автомобиль был успешно добавлен!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
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
                var car_brand = (CarBrand_ComboBox.SelectedValue as ComboBoxItem)?.Content;

                dbContext.SendRequest($"SELECT update_data_cars('{id}', '{LicencePlate_TextBox.Text}', '{car_brand}')");
                MessageBox.Show("Информация о автомобиле была успешно обновлена!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        public void LoadData()
        {
            var car_brands = dbContext.ReadDictionaryFromDatabaseBySQL($"SELECT * FROM get_car_brands_info();");

            ComponentOperator_ForPages.SetContentByListDictionary(CarBrand_ComboBox, car_brands, "Марка");

            if (id != -1)
            {
                var car = dbContext.ReadFirstDictionaryRecordFromDatabaseBySQL($"SELECT * FROM get_cars_info() WHERE \"ID\" = {id};");
                
                LicencePlate_TextBox.Text = Convert.ToString(car["Номер"]);
                var brand = Convert.ToString(car["Марка"]);

                ComponentOperator_ForPages.SetSelectedItemByContent(CarBrand_ComboBox, brand);
            }
        }
    }
}
