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
    /// Логика взаимодействия для dataOP_atc_Page.xaml
    /// </summary>
    public partial class dataOP_atc_Page : Page, IDataOP
    {
        DbContext_Npgsql dbContext;
        public long id = -1;

        public dataOP_atc_Page()
        {
            InitializeComponent();

            dbContext = DbContext_Npgsql.GetInstance();
        }

        public dataOP_atc_Page(long ID) : this()
        {
            id = ID;
        }

        public void Add()
        {
            try
            {
                var city = (City_ComboBox.SelectedItem as ComboBoxItem)?.Content;
                var area = (UrbanArea_ComboBox.SelectedItem as ComboBoxItem)?.Content;
                var typeOwner = (TypeOwner_ComboBox.SelectedItem as ComboBoxItem)?.Content;
                var owner_atc = (TypeOwner_ComboBox.SelectedItem as ComboBoxItem)?.Content;

                if (dbContext.CheckRoleUser(DbContext_Npgsql.Roles.Moderator))
                    dbContext.SendRequest($"SELECT insert_data_atc('{NameATC_TextBox.Text}', '{city}', '{area}', '{typeOwner}', '{StartYear_TextBox.Text}', '{Phone_TextBox.Text}', '{owner_atc}')");
                else
                    dbContext.SendRequest($"SELECT insert_data_atc('{NameATC_TextBox.Text}', '{city}', '{area}', '{typeOwner}', '{StartYear_TextBox.Text}', '{Phone_TextBox.Text}')");

                MessageBox.Show("Предприятие было успешно добавлено!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
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
                var city = (City_ComboBox.SelectedItem as ComboBoxItem)?.Content;
                var area = (UrbanArea_ComboBox.SelectedItem as ComboBoxItem)?.Content;
                var typeOwner = (TypeOwner_ComboBox.SelectedItem as ComboBoxItem)?.Content;
                var owner_atc = (TypeOwner_ComboBox.SelectedItem as ComboBoxItem)?.Content;

                if (dbContext.CheckRoleUser(DbContext_Npgsql.Roles.Moderator))
                    dbContext.SendRequest($"SELECT update_data_atc('{NameATC_TextBox.Text}', '{city}', '{area}', '{typeOwner}', '{StartYear_TextBox.Text}', '{Phone_TextBox.Text}', '{owner_atc}')");
                else
                    dbContext.SendRequest($"SELECT update_data_atc('{NameATC_TextBox.Text}', '{city}', '{area}', '{typeOwner}', '{StartYear_TextBox.Text}', '{Phone_TextBox.Text}')");

                MessageBox.Show("Информация о предприятии была успешно обновлена!", "Оповещение", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Ошибка", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        public void LoadData()
        {
            var cities = dbContext.ReadDictionaryFromDatabaseBySQL($"SELECT * FROM get_cities_info();");
            var typesOwner = dbContext.ReadDictionaryFromDatabaseBySQL($"SELECT * FROM get_types_of_ownership_info();");

            ComponentOperator_ForPages.SetContentByListDictionary(City_ComboBox, cities, "Город");
            ComponentOperator_ForPages.SetContentByListDictionary(TypeOwner_ComboBox, typesOwner, "Тип собственности");

            if (dbContext.CheckRoleUser(DbContext_Npgsql.Roles.Moderator))
            {
                Owners_ComboBox.Visibility = Visibility.Visible;
                Owners_Label.Visibility = Visibility.Visible;
                var owners = dbContext.ReadDictionaryFromDatabaseBySQL($"SELECT * FROM get_free_atc_owners(1500);");
                ComponentOperator_ForPages.SetContentByListDictionary(Owners_ComboBox, owners, "login", "login");
            }

            if (id != -1)
            {
                Dictionary<string, object> atc = dbContext.ReadFirstDictionaryRecordFromDatabaseBySQL($"SELECT * FROM get_atc_info() WHERE \"ID\" = {id};");
                NameATC_TextBox.Text = Convert.ToString(atc["Название предприятия"]);

                var cityName = Convert.ToString(atc["Город"]);
                var urban_area = Convert.ToString(atc["Район"]);
                var typeOwner = Convert.ToString(atc["Тип собственности"]);
                var owner = atc["Владелец"].ToString();

                StartYear_TextBox.Text = Convert.ToString(atc["Год открытия"]);
                Phone_TextBox.Text = Convert.ToString(atc["Телефон"]);

                ComponentOperator_ForPages.SetSelectedItemByContent(City_ComboBox, cityName);
                ComponentOperator_ForPages.SetSelectedItemByContent(UrbanArea_ComboBox, urban_area);
                ComponentOperator_ForPages.SetSelectedItemByContent(TypeOwner_ComboBox, typeOwner);
                ComponentOperator_ForPages.SetSelectedItemByContent(Owners_ComboBox, owner);
            }
        }

        private void City_ComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            var cityName = (City_ComboBox.SelectedItem as ComboBoxItem).Content.ToString();

            var areas = dbContext.ReadDictionaryFromDatabaseBySQL($"SELECT * FROM get_urban_areas_info() WHERE \"Город\" = '{cityName}';");

            ComponentOperator_ForPages.SetContentByListDictionary(UrbanArea_ComboBox, areas, "Район");

            UrbanArea_ComboBox.IsEnabled = true;
        }
    }
}
