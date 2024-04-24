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

namespace CourseWork_PSwDBS_Pankov.OperationPages
{
    /// <summary>
    /// Логика взаимодействия для dataOP_cities_Page.xaml
    /// </summary>
    public partial class dataOP_cities_Page : Page, IDataOP
    {
        DbContext_Npgsql dbContext;
        public long id = -1;

        public dataOP_cities_Page()
        {
            InitializeComponent();

            dbContext = DbContext_Npgsql.GetInstance();
        }

        public dataOP_cities_Page(long ID) : this()
        {
            id = ID;
        }

        public void Add()
        {
            try
            {
                dbContext.SendRequest($"SELECT insert_data_cities('{NameCityTextBox.Text}')");
                MessageBox.Show("Город был успешно добавлен!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
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
                dbContext.SendRequest($"SELECT update_data_cities('{id}', '{NameCityTextBox.Text}')");
                MessageBox.Show("Город был успешно обновлен!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
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
                dynamic city = dbContext.ReadObjectFromDatabaseBySQL($"SELECT * FROM get_cities_info() WHERE \"ID\" = {id};");
                NameCityTextBox.Text = city.Город;
            }
        }
    }
}
