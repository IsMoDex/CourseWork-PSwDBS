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
using System.Windows.Shapes;

namespace CourseWork_PSwDBS_Pankov
{
    /// <summary>
    /// Логика взаимодействия для RegistationWindow.xaml
    /// </summary>
    public partial class RegistationWindow : Window
    {
        public RegistationWindow()
        {
            InitializeComponent();
        }

        private void CloseButton_Click(object sender, RoutedEventArgs e) => Application.Current.Shutdown();

        private void RegisterButton_Click(object sender, RoutedEventArgs e)
        {
            var dbContext = DbContext_Npgsql.GetInstance();

            dbContext.User = LoginTextBox.Text;
            dbContext.Password = PasswordBox.Password;

            try
            {
                dbContext.Connect();
                new MainWindow().Show();
                this.Close();

            } catch
            {
                MessageBox.Show("Неверные данные подключения!", "Ошибка подключения!", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
    }
}
