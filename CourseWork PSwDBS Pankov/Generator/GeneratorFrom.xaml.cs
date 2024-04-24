using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace CourseWork_PSwDBS_Pankov.Generator
{
    /// <summary>
    /// Логика взаимодействия для GeneratorFrom.xaml
    /// </summary>
    public partial class GeneratorFrom : Window
    {
        public static bool isOpen { get; private set; }

        Generator generator;

        public GeneratorFrom()
        {
            InitializeComponent();

            generator = new Generator();
            generator.updateProgressBar = SetProgressBar;

            isOpen = true;
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            Tables_ComboBox.Items.Clear();

            Tables_ComboBox.Items.Add("АТС");
            Tables_ComboBox.Items.Add("Водители");
            Tables_ComboBox.Items.Add("Автомобили");
            Tables_ComboBox.Items.Add("Перевозки");
        }

        private async void Accept_Button_Click(object sender, RoutedEventArgs e)
        {
            if (Tables_ComboBox.SelectedItem == null)
                return;

            int Count = int.Parse(CountGenereteRecord_TextBox.Text);

            string key = Tables_ComboBox.SelectedItem.ToString();

            int CountGenereted = 0;

            await Task.Run(() => 
            {
                switch (key)
                {
                    case "АТС":
                        CountGenereted = generator.GenerateAtc(Count);
                        break;

                    case "Водители":
                        CountGenereted = generator.GenerateDrivers(Count);
                        break;

                    case "Автомобили":
                        CountGenereted = generator.GenerateCars(Count);
                        break;

                    case "Перевозки":
                        CountGenereted = generator.GenerateTransportations(Count);
                        break;
                }
            });

            MessageBox.Show($"Было успешно сгенерировано записей\r\nв количестве {CountGenereted} для таблицы \"{key}\"", "Оповещение", 0, MessageBoxImage.Information);
        }

        private void SetProgressBar(int progress)
        {
            Records_ProgressBar.Value = progress;
        }

        private void Close_Button_Click(object sender, RoutedEventArgs e)
        {
            isOpen = false;
            Close();
        }

        private void Tables_ComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e) => Accept_Button.IsEnabled = true;

        private void CountGenereteRecord_TextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Back || e.Key == Key.BrowserBack || char.IsDigit((char)KeyInterop.VirtualKeyFromKey(e.Key)))
                return;

            if(e.Key == Key.Enter)
            {
                e.Handled = true;
                Accept_Button_Click(null, null);
            }

            e.Handled = true;
        }
    }
}
