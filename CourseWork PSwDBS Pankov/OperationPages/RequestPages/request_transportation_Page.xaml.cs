using CourseWork_PSwDBS_Pankov.DB;
using CourseWork_PSwDBS_Pankov.OperationPages.TablePages;
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
    /// Логика взаимодействия для request_transportation_Page.xaml
    /// </summary>
    public partial class request_transportation_Page : IRequestPage
    {
        private DbContext_Npgsql dbContext = DbContext_Npgsql.GetInstance();

        public request_transportation_Page()
        {
            InitializeComponent();
        }

        public void LoadData()
        {
            //var dt = dbContext.GetDataTableByTable("get_urban_areas_for_each_arrival_city()");
            //ComponentOperator_ForPages.SetContentDataGridByDataTable(UrbanAreasDataGrid, dt);
            UrbanAreasDataGrid_Frame.Navigate(new DB_Content_Page("get_urban_areas_for_each_arrival_city()"));
        }

        private void CalculateCostButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                var costObj = dbContext.ExecuteScalar<object>($"SELECT * FROM getTransportationCostByCargoWeight('{WeightTextBox.Text}')");

                if(costObj is int)
                {
                    CostTranspoerationLable.Content = "Общая стоимость: " + costObj;
                }
                else
                {
                    CostTranspoerationLable.Content = "Нет";
                }


            } catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}
