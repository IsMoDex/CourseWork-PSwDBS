using CourseWork_PSwDBS_Pankov.DB;
using System;
using System.Collections;
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
    /// Логика взаимодействия для dataOP_urban_areas_Page.xaml
    /// </summary>
    public partial class dataOP_urban_areas_Page : Page, IDataOP
    {
        DbContext_Npgsql dbContext;
        public long id = -1;

        public dataOP_urban_areas_Page()
        {
            InitializeComponent();

            dbContext = DbContext_Npgsql.GetInstance();
        }

        public dataOP_urban_areas_Page(long ID) : this()
        {
            id = ID;
        }

        public void Add()
        {
            try
            {
                dbContext.SendRequest($"SELECT insert_data_urban_areas('{NameUrbanAreaTextBox.Text}', '{CityComboBox.Text}')");
                MessageBox.Show("Район был успешно добавлен!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
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
                dbContext.SendRequest($"SELECT update_data_urban_areas('{id}', '{NameUrbanAreaTextBox.Text}', '{CityComboBox.Text}')");
                MessageBox.Show("Информация о районе была успешно обновлена!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        public void LoadData()
        {
            var cities = dbContext.ReadDictionaryFromDatabaseBySQL($"SELECT * FROM get_cities_info();");

            ComponentOperator_ForPages.SetContentByListDictionary(CityComboBox, cities, "Город");

            if (id != -1)
            {
                Dictionary<string, object> urban_areas = dbContext.ReadFirstDictionaryRecordFromDatabaseBySQL($"SELECT * FROM get_urban_areas_info() WHERE \"ID\" = {id};");
                NameUrbanAreaTextBox.Text = Convert.ToString(urban_areas["Район"]);

                var cityName = Convert.ToString(urban_areas["Город"]);

                ComponentOperator_ForPages.SetSelectedItemByContent(CityComboBox, cityName);
            }
        }
    }
}
