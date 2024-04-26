using CourseWork_PSwDBS_Pankov.DB;
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

namespace CourseWork_PSwDBS_Pankov.OperationPages.RequestPages
{
    /// <summary>
    /// Логика взаимодействия для request_drivers_Page.xaml
    /// </summary>
    public partial class request_drivers_Page : Page, IRequestPage
    {
        DbContext_Npgsql dbContext = DbContext_Npgsql.GetInstance();
        public request_drivers_Page()
        {
            contentPage = new DB_Content_Page();
            InitializeComponent();
        }

        DB_Content_Page contentPage;

        public void LoadData()
        {
            DriverCategoryCount_Frame.Navigate(contentPage);
            HighEarningDrivers_Frame.Navigate(new DB_Content_Page($"get_high_earning_drivers()"));
        }

        private void TextBox_TextChanged(object sender, TextChangedEventArgs e)
        {
            var textBox = MaxSalary_TextBox as TextBox;
            var textBox2 = MinCount_TextBox as TextBox;

            if (textBox.Text.Length == 0 || Regex.IsMatch(textBox.Text, @"[^\d]|[^\d\.]|[^\d\.\d]") || textBox2.Text.Length == 0 || Regex.IsMatch(textBox2.Text, @"[^\d]|[^\d\.]|[^\d\.\d]"))
            {
                return;
            }

            try
            {
                contentPage.SetDataGridByTableName($"get_driver_category_count('{MaxSalary_TextBox.Text}', '{MinCount_TextBox.Text}')");
            }
            catch { }
        }
    }
}
