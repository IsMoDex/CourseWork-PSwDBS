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
    /// Логика взаимодействия для dataOP_car_brands_Page.xaml
    /// </summary>
    public partial class dataOP_car_brands_Page : Page, IDataOP
    {
        DbContext_Npgsql dbContext;
        public long id = -1;

        public dataOP_car_brands_Page()
        {
            InitializeComponent();

            dbContext = DbContext_Npgsql.GetInstance();
        }

        public dataOP_car_brands_Page(long ID) : this()
        {
            id = ID;
        }

        public void Add()
        {
            try
            {
                dbContext.SendRequest($"SELECT insert_data_car_brands('{BrandNameTextBox.Text}', '{LoadCapasityTextBox.Text}', '{FuelConsumptionTextBox.Text}')");
                MessageBox.Show("Автомобильная марка была успешно добавлена!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
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
                dbContext.SendRequest($"SELECT update_data_car_brands('{id}', '{BrandNameTextBox.Text}', '{LoadCapasityTextBox.Text}', '{FuelConsumptionTextBox.Text}')");
                MessageBox.Show("Автомобильная марка была успешно обновлена!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        public void LoadData()
        {
            if (id != -1)
            {
                var car_brands = dbContext.ReadFirstDictionaryRecordFromDatabaseBySQL($"SELECT * FROM get_car_brands_info() WHERE \"ID\" = {id};");
                BrandNameTextBox.Text = Convert.ToString(car_brands["Марка"]);
                LoadCapasityTextBox.Text = Convert.ToString(car_brands["Максимальная загруженность"]);
                FuelConsumptionTextBox.Text = Convert.ToString(car_brands["Расход топлива"]);
            }
        }
    }
}
