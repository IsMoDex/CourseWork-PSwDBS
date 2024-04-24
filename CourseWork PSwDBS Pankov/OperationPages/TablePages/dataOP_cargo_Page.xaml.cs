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

namespace CourseWork_PSwDBS_Pankov.OperationPages.TablePages
{
    /// <summary>
    /// Логика взаимодействия для dataOP_cargo_Page.xaml
    /// </summary>
    public partial class dataOP_cargo_Page : Page, IDataOP
    {
        DbContext_Npgsql dbContext;
        public long id = -1;

        public dataOP_cargo_Page()
        {
            InitializeComponent();

            dbContext = DbContext_Npgsql.GetInstance();
        }

        public dataOP_cargo_Page(long ID) : this()
        {
            id = ID;
        }

        public void Add()
        {
            try
            {
                dbContext.SendRequest($"SELECT insert_data_cargo('{NameCargo_TextBox.Text}', '{WeightCargo_TextBox.Text}')");
                MessageBox.Show("Груз был успешно добавлен!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
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
                dbContext.SendRequest($"SELECT update_data_cargo('{id}', '{NameCargo_TextBox.Text}', '{WeightCargo_TextBox.Text}')");
                MessageBox.Show("Информация о грузе была успешно обновлена!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
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
                var cargo = dbContext.ReadFirstDictionaryRecordFromDatabaseBySQL($"SELECT * FROM get_cargo_info() WHERE \"ID\" = {id};");
                NameCargo_TextBox.Text = Convert.ToString(cargo["Груз"]);
                WeightCargo_TextBox.Text = Convert.ToString(cargo["Вес"]);
            }
        }
    }
}
