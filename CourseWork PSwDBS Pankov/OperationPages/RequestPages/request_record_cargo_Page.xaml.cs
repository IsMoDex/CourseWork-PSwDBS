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
    /// Логика взаимодействия для request_record_cargo_Page.xaml
    /// </summary>
    public partial class request_record_cargo_Page : Page, IRequestPage
    {
        private DbContext_Npgsql dbContext = DbContext_Npgsql.GetInstance();
        long ID;

        public request_record_cargo_Page(long ID)
        {
            InitializeComponent();
            this.ID = ID;
        }

        public void LoadData()
        {
            var cost = dbContext.ExecuteScalar<int>($"SELECT * FROM get_transportation_cost_for_cargo('{ID}')");
            TranspCostForCargo_Label.Content = "Стоимость: " + cost;
        }
    }
}
