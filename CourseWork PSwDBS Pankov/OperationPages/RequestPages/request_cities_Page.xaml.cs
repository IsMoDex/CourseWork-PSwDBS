using CourseWork_PSwDBS_Pankov.DB;
using CourseWork_PSwDBS_Pankov.OperationPages.TablePages;
using Microsoft.EntityFrameworkCore;
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

namespace CourseWork_PSwDBS_Pankov.OperationPages.RequestPages
{
    /// <summary>
    /// Логика взаимодействия для request_cities_Page.xaml
    /// </summary>
    public partial class request_cities_Page : Page, IRequestPage
    {
        DbContext_Npgsql dbContext = DbContext_Npgsql.GetInstance();
        public request_cities_Page()
        {
            InitializeComponent();
        }

        public void LoadData()
        {
            //var count_urban_areas_per_city = dbContext.GetDataTableByTable("count_urban_areas_per_city()");
            //var get_cities_with_urban_areas = dbContext.GetDataTableByTable("get_cities_with_urban_areas()");
            //var get_cities_without_urban_areas = dbContext.GetDataTableByTable("get_cities_without_urban_areas()");

            //ComponentOperator_ForPages.SetContentDataGridByDataTable(UAPerCity_DataGrid, count_urban_areas_per_city);
            //ComponentOperator_ForPages.SetContentDataGridByDataTable(CitiesWithUA_DataGrid, get_cities_with_urban_areas);
            //ComponentOperator_ForPages.SetContentDataGridByDataTable(CitiesWithNoUA_DataGrid, get_cities_without_urban_areas);

            UAPerCity_Frame.Navigate(new DB_Content_Page("count_urban_areas_per_city()"));
            CitiesWithUA_Frame.Navigate(new DB_Content_Page("get_cities_with_urban_areas()")); 
            CitiesWithNoUA_Frame.Navigate(new DB_Content_Page("get_cities_without_urban_areas()"));
            SumCargoWeightPerCity_Frame.Navigate(new DB_Content_Page("get_sum_cargo_weight_per_city()"));
        }

        private void SearchDiapasoneBetwenDates_Button_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var startData = StartDate_DatePicker.SelectedDate?.ToString(Generator.Generator.DATE_FORMAT);
                var endData = EndDate_DatePicker.SelectedDate?.ToString(Generator.Generator.DATE_FORMAT);

                //var dt = dbContext.GetDataTableByTable($"get_cities_with_transportations_between_dates('{startData}', '{endData}')");
                //ComponentOperator_ForPages.SetContentDataGridByDataTable(CitiesWithTrBeetwenDates_DataGrid, dt);
                CitiesWithTrBeetwenDates_Frame.Navigate(new DB_Content_Page($"get_cities_with_transportations_between_dates('{startData}', '{endData}')"));
            } catch(Exception ex)
            {
                MessageBox.Show(ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}
