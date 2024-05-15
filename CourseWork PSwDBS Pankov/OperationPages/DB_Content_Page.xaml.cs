using CourseWork_PSwDBS_Pankov.DB;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Internal;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Markup;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace CourseWork_PSwDBS_Pankov.OperationPages
{
    public delegate void OperationBySelect(long ID);
    /// <summary>
    /// Логика взаимодействия для DB_Content_Page.xaml
    /// </summary>
    public partial class DB_Content_Page : Page
    {
        DbContext_Npgsql dbContext;
        string SelectedTable;
        public OperationBySelect bySelect { private get; set; }
        public DB_Content_Page()
        {
            InitializeComponent();

            dbContext = DbContext_Npgsql.GetInstance();
            //LoadData();
        }

        public DB_Content_Page(string TableName) : this()
        {
            SetDataGridByTableName(TableName);
        }

        public long CountRecords
        {
            get
            {
                var list = dbContext.ReadFirstDictionaryRecordFromDatabaseBySQL($"SELECT COUNT(*) FROM {SelectedTable}");


                if (list.Count == 0)
                    return 0;

                return (long)list["count"];
            }
        }

        private int LimitRecords = 50;
        private int CurrentList;
        private int CountLists;

        private ListSortDirection? sort;
        private string OrderByColumn = null;

        public DataColumnCollection Columns { private set; get; }

        private void ChangePagination()
        {
            int width_Buttons = 40;

            // Создаем список для хранения кнопок, которые нужно удалить
            List<Button> buttonsToRemove = new List<Button>();

            // Добавляем кнопки для удаления в список
            foreach (Button button in paginationStackPanel.Children)
            {
                if (button != pagination_next_button && button != pagination_prev_button)
                {
                    buttonsToRemove.Add(button);
                }
            }

            // Удаляем кнопки
            foreach (Button button in buttonsToRemove)
            {
                paginationStackPanel.Children.Remove(button);
            }

            int WidthStackPanel = (int)paginationStackPanel.ActualWidth;
            //int FreeWidth = WidthStackPanel - (paginationStackPanel.Children.Count - 2) * width_Buttons;
            int FreeWidth = WidthStackPanel - paginationStackPanel.Children.Count * width_Buttons;
            int CountButtons = (int)(FreeWidth / width_Buttons);

            Console.WriteLine($"Pagination_Width:{WidthStackPanel}");

            // Добавляем новые кнопки
            for (int i = 0; i < CountButtons; i++)
            {
                Button button = new Button();
                button.Width = width_Buttons;
                button.Content = (i + 1).ToString();
                paginationStackPanel.Children.Insert(i + 1, button);
            }
        }

        public void SetDataGridByTableName(string TableName)
        {
            SelectedTable = TableName;

            SetListByNumberList(0);
        }

        public void RefreshData() => SetListByNumberList(CurrentList);

        private void ResetInfo() => CountLists = (int)Math.Ceiling((double)CountRecords / LimitRecords);

        private void SetDataGridByDataTable(DataTable dt)
        {
            // Применяем DataTable к ItemsSource DataGrid
            Db_DataGrid.ItemsSource = dt.DefaultView;

            // Настраиваем формат отображения даты для всех столбцов, содержащих тип данных DateTime
            foreach (DataColumn column in dt.Columns)
            {
                if (column.DataType == typeof(DateTime))
                {
                    var dateColumn = Db_DataGrid.Columns.FirstOrDefault(c => c.Header.ToString() == column.ColumnName);
                    if (dateColumn != null && dateColumn is DataGridTextColumn)
                    {
                        // Задаем формат отображения даты
                        ((DataGridTextColumn)dateColumn).Binding.StringFormat = "dd.MM.yyyy";
                    }
                }
            }

            // Прячем столбец с именем "ID"
            var idColumn = Db_DataGrid.Columns.FirstOrDefault(c => c.Header.ToString() == "ID");
            if (idColumn != null)
            {
                idColumn.Visibility = Visibility.Collapsed;
            }
        }

        public long GetIDSelectedRecord()
        {
            // Получаем выбранную строку из DataGrid
            DataRowView rowView = (DataRowView)Db_DataGrid.SelectedItem;

            // Если строка не выбрана или объект rowView не содержит данных
            if (rowView == null || rowView.Row == null)
            {
                // Обработка случая, когда выбранная строка отсутствует
                return -1; // или любое другое значение по умолчанию
            }

            // Используем LINQ для поиска номера колонки с заголовком "ID"
            int columnIndex = -1;
            var column = Db_DataGrid.Columns.FirstOrDefault(c => c.Header.ToString() == "ID");
            if (column != null)
            {
                columnIndex = Db_DataGrid.Columns.IndexOf(column);
            }

            if (columnIndex == -1)
            {
                // Колонка с заголовком "ID" не найдена
                return -1; // или любое другое значение по умолчанию
            }

            // Получаем значение ячейки в найденной колонке
            object value = rowView.Row[columnIndex];

            return Convert.ToInt64(value);
        }

        private void SetListByNumberList(int NumberList)
        {
            CurrentList = NumberList;
            ResetInfo();

            bool isFirstPage = CurrentList <= 0;
            bool isLastPage = CurrentList + 1 >= CountLists;

            pagination_next_button.IsEnabled = !isLastPage;
            pagination_prev_button.IsEnabled = !isFirstPage;

            if (isFirstPage && isLastPage)
            {
                pagination_next_button.IsEnabled = false;
                pagination_prev_button.IsEnabled = false;
            }
            else if (isLastPage)
            {
                CurrentList = CountLists - 1;
            }
            else if (isFirstPage)
            {
                CurrentList = 0;
            }

            PagePosition_Lable.Content = $"Страница {CurrentList + 1} из {CountLists}";

            DataTable dt;

            if(sort == null || OrderByColumn == null)
            {
                dt = dbContext.GetDataTableBySQL($"SELECT * FROM {SelectedTable} OFFSET {CurrentList * LimitRecords} LIMIT {LimitRecords};");
            }
            else
            {
                string order_by = sort == ListSortDirection.Ascending ? "ASC" : "DESC";

                dt = dbContext.GetDataTableBySQL($"SELECT * FROM {SelectedTable} ORDER BY \"{OrderByColumn}\" {order_by} OFFSET {CurrentList * LimitRecords} LIMIT {LimitRecords};");
            }

            
            Columns = dt.Columns;
            
            SetDataGridByDataTable(dt);
        }

        private void pagination_prev_button_Click(object sender, RoutedEventArgs e) => SetListByNumberList(--CurrentList);

        private void pagination_next_button_Click(object sender, RoutedEventArgs e) => SetListByNumberList(++CurrentList);

        private void Db_DataGrid_Sorting(object sender, DataGridSortingEventArgs e)
        {
            e.Handled = true;

            // Получаем столбец, по которому производится сортировка
            DataGridColumn column = e.Column;


            // Меняем направление сортировки
            if (sort == null)
            {
                sort = ListSortDirection.Ascending;
                OrderByColumn = e.Column.Header.ToString();
            }
            else if(sort == ListSortDirection.Ascending)
            {
                sort = ListSortDirection.Descending;
                OrderByColumn = e.Column.Header.ToString();
            }
            else
            {
                sort = null;
                OrderByColumn = null;
            }

            SetListByNumberList(CurrentList);

            //// Меняем направление сортировки
            //if (sort == ListSortDirection.Ascending)
            //{
            //    column.SortDirection = ListSortDirection.Ascending;
            //}
            //else if (sort == ListSortDirection.Descending)
            //{
            //    column.SortDirection = ListSortDirection.Descending;
            //}
            //else
            //{
            //    column.SortDirection = null;
            //}

            //// Обновляем представление DataGrid
            //(sender as DataGrid).UpdateLayout();
        }

        private void Db_DataGrid_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (bySelect == null)
                return;

            DataGrid dataGrid = sender as DataGrid;

            // Проверяем, есть ли выбранная строка
            if (dataGrid.SelectedItem != null)
            {
                // Получаем выбранную строку
                var selectedRow = (DataRowView)dataGrid.SelectedItem;

                // Получаем значение ячейки с названием колонки "ID"
                var idValue = selectedRow["ID"];

                if (idValue is int || idValue is long)
                    bySelect(Convert.ToInt64(idValue));
                else
                    Console.WriteLine("Выбранная запись не имеет численный формат ID!");
            }
            else
            {
                bySelect(-1);
            }
        }

        private void Page_KeyDown(object sender, KeyEventArgs e)
        {
            if(e.Key == Key.Escape && Db_DataGrid.SelectedItem != null)
            {
                Db_DataGrid.SelectedItem = null;
            }
        }
    }
}
