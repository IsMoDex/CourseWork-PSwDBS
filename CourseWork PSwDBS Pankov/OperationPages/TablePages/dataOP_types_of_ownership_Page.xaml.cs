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
    /// Логика взаимодействия для dataOP_types_of_ownership_Page.xaml
    /// </summary>
    public partial class dataOP_types_of_ownership_Page : Page, IDataOP
    {
        DbContext_Npgsql dbContext;
        public long id = -1;

        public dataOP_types_of_ownership_Page()
        {
            InitializeComponent();

            dbContext = DbContext_Npgsql.GetInstance();
        }

        public dataOP_types_of_ownership_Page(long ID) : this()
        {
            id = ID;
        }

        public void Add()
        {
            try
            {
                dbContext.SendRequest($"SELECT insert_data_types_of_ownership('{NameTypeTextBox.Text}')");
                MessageBox.Show("Тип собственности был успешно добавлен!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
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
                dbContext.SendRequest($"SELECT update_data_types_of_ownership('{id}', '{NameTypeTextBox.Text}')");
                MessageBox.Show("Тип собственности был успешно обновлен!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
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
                var type = dbContext.ReadFirstDictionaryRecordFromDatabaseBySQL($"SELECT * FROM get_types_of_ownership_info() WHERE \"ID\" = {id};");
                NameTypeTextBox.Text = type["Тип собственности"].ToString();
            }
        }
    }
}
