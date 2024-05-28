using CourseWork_PSwDBS_Pankov.OperationPages.TablePages;
using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Navigation;

namespace CourseWork_PSwDBS_Pankov.OperationPages
{
    /// <summary>
    /// Логика взаимодействия для InsertUpdate_Page.xaml
    /// </summary>
    public partial class InsertUpdate_Page : Page
    {
        Page contextPage;

        // Приватный конструктор, инициализирующий страницу
        private InsertUpdate_Page()
        {
            InitializeComponent();
        }

        // Публичный конструктор с параметром страницы
        public InsertUpdate_Page(Page page) : this()
        {
            // Проверка страницы
            CheckPage(page);

            // Установка контекстной страницы
            contextPage = page;
        }

        // Публичный конструктор с параметром имени таблицы
        public InsertUpdate_Page(string tableName) : this()
        {
            switch (tableName)
            {
                case "cities":
                    contextPage = new dataOP_cities_Page();
                    break;

                case "urban_areas":
                    contextPage = new dataOP_urban_areas_Page();
                    break;

                case "types_of_ownership":
                    contextPage = new dataOP_types_of_ownership_Page();
                    break;

                case "atc":
                    contextPage = new dataOP_atc_Page();
                    break;

                case "users":
                    contextPage = new dataOP_users_Page();
                    break;

                case "driving_categories":
                    contextPage = new dataOP_driving_categories_Page();
                    break;

                case "drivers":
                    contextPage = new dataOP_drivers_Page();
                    break;

                case "cargo":
                    contextPage = new dataOP_cargo_Page();
                    break;

                case "car_brands":
                    contextPage = new dataOP_car_brands_Page();
                    break;

                case "cars":
                    contextPage = new dataOP_cars_Page();
                    break;

                case "transportation":
                    contextPage = new dataOP_transportation_Page();
                    break;
            }

            // Проверка страницы
            CheckPage(contextPage);
        }

        public InsertUpdate_Page(string tableName, long ID) : this()
        {
            switch (tableName)
            {
                case "cities":
                    contextPage = new dataOP_cities_Page(ID);
                    break;

                case "urban_areas":
                    contextPage = new dataOP_urban_areas_Page(ID);
                    break;

                case "types_of_ownership":
                    contextPage = new dataOP_types_of_ownership_Page(ID);
                    break;

                case "atc":
                    contextPage = new dataOP_atc_Page(ID);
                    break;

                case "users":
                    contextPage = new dataOP_users_Page();
                    break;

                case "driving_categories":
                    contextPage = new dataOP_driving_categories_Page(ID);
                    break;

                case "drivers":
                    contextPage = new dataOP_drivers_Page(ID);
                    break;

                case "cargo":
                    contextPage = new dataOP_cargo_Page(ID);
                    break;

                case "car_brands":
                    contextPage = new dataOP_car_brands_Page(ID);
                    break;

                case "cars":
                    contextPage = new dataOP_cars_Page(ID);
                    break;

                case "transportation":
                    contextPage = new dataOP_transportation_Page(ID);
                    break;
            }


            // Проверка страницы
            CheckPage(contextPage);
            ChangeVisibilityToAccept();
        }

        // Метод для проверки корректности страницы
        private void CheckPage(Page page)
        {
            if (page as IDataOP == null)
                throw new ArgumentException("Переданная страница не относится к IDataOP!");
        }

        private void Page_Loaded(object sender, RoutedEventArgs e)
        {
            DataOP_Frame.Navigate(contextPage);
        }

        private void ChangeVisibilityToAccept()
        {
            AddRecordButton.Visibility = Visibility.Collapsed;
            ChangeRecordButton.Visibility = Visibility.Visible;
        }

        private void AddRecordButton_Click(object sender, RoutedEventArgs e)
        {
            var insert = contextPage as IDataOP;
            insert.Add();
        }

        private void ChangeRecordButton_Click(object sender, RoutedEventArgs e)
        {
            var update = contextPage as IDataOP;
            update.Change();
        }

        private void CanselButton_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.GoBack();
            NavigationService.RemoveBackEntry();
        }

        private void DataOP_Frame_Navigated(object sender, NavigationEventArgs e)
        {
            var page = contextPage as IDataOP;
            page.LoadData();
        }
    }
}
