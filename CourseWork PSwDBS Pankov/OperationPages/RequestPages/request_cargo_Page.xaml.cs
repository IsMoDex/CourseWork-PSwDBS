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

namespace CourseWork_PSwDBS_Pankov.OperationPages.RequestPages
{
    /// <summary>
    /// Логика взаимодействия для request_cargo_Page.xaml
    /// </summary>
    public partial class request_cargo_Page : Page, IRequestPage
    {
        private DbContext_Npgsql dbContext = DbContext_Npgsql.GetInstance();

        public request_cargo_Page()
        {
            InitializeComponent();
        }

        public void LoadData()
        {
            TotalTranspPerCargoType_Frame.Navigate(new DB_Content_Page("total_transportations_per_cargo_type()"));
        }
    }
}
