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
    /// Логика взаимодействия для request_record_cities_Page.xaml
    /// </summary>
    public partial class request_record_cities_Page : Page, IRequestPage
    {
        private long ID;

        public request_record_cities_Page(long ID)
        {
            InitializeComponent();
            this.ID = ID;
        }

        public void LoadData()
        {
            TranspCarsToCity_Frame.Navigate(new DB_Content_Page($"get_transportation_cars_to_city({ID})"));
        }
    }
}
