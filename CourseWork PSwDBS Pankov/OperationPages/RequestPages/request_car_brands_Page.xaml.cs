using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
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
using static OfficeOpenXml.ExcelErrorValue;

namespace CourseWork_PSwDBS_Pankov.OperationPages.RequestPages
{
    /// <summary>
    /// Логика взаимодействия для request_car_brands_Page.xaml
    /// </summary>
    public partial class request_car_brands_Page : Page, IRequestPage
    {
        public request_car_brands_Page()
        {
            contentPage = new DB_Content_Page();
            InitializeComponent();
        }

        public void LoadData()
        {
            CarBrandsWithHighAverageFuelConsumption_Frame.Navigate(contentPage);
        }

        DB_Content_Page contentPage;

        private void ThresholdConsumption_TextBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            var textBox = sender as TextBox;

            if (textBox.Text.Length == 0 || Regex.IsMatch(textBox.Text, @"[^\d]|[^\d\.]|[^\d\.\d]"))
                return;

            try
            {
                contentPage.SetDataGridByTableName($"car_brands_with_high_average_fuel_consumption('{textBox.Text}')");
            } 
            catch { }
        }
    }
}
