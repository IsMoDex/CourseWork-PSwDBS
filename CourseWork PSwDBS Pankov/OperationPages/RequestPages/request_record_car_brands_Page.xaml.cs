using System;
using System.Collections.Generic;
using System.Data;
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
    /// Логика взаимодействия для request_record_car_brands_Page.xaml
    /// </summary>
    public partial class request_record_car_brands_Page : Page, IRequestPage
    {
        long ID;
        public request_record_car_brands_Page(long ID)
        {
            InitializeComponent();
            this.ID = ID;
        }

        public void LoadData()
        {
            CargosTranspByCarBrand_Frame.Navigate(new DB_Content_Page($"get_cargos_transported_by_car_brand({ID})"));
        }
    }
}
