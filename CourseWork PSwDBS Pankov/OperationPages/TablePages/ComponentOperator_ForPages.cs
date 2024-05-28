using CourseWork_PSwDBS_Pankov.DB;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Windows;
using System.Windows.Controls;

namespace CourseWork_PSwDBS_Pankov.OperationPages.TablePages
{
    internal class ComponentOperator_ForPages
    {
        public static void SetSelectedItemByContent(ComboBox comboBox, string Content)
        {
            foreach (ComboBoxItem item in comboBox.Items)
            {
                if (item.Content.ToString() == Content)
                {
                    comboBox.SelectedItem = item;
                    break;
                }
            }
        }

        public static void SetContentByListDictionary(ComboBox comboBox, List<Dictionary<string, object>> listDictionaries, string ContentName)
            => SetContentByListDictionary(comboBox, listDictionaries, ContentName, "ID");

        public static void SetContentByListDictionary(ComboBox comboBox, List<Dictionary<string, object>> listDictionaries, string ContentName, string TagName)
        {
            if (comboBox.Items.Count > 0)
                comboBox.Items.Clear();

            foreach (var dictionary in listDictionaries)
            {
                var item = new ComboBoxItem()
                {
                    Tag = dictionary[TagName],
                    Content = dictionary[ContentName]
                };

                comboBox.Items.Add(item);
            }
        }

        public static void SetTablesContentInComboBox(ComboBox comboBox)
        {
            var dbContext = DbContext_Npgsql.GetInstance();

            var availableTables = dbContext.ReadObjectsFromDatabaseByTable("get_available_tables_between_role()");

            comboBox.Items.Clear();

            foreach (var table in availableTables)
            {
                var key = table.Таблицы;

                var comboBoxItem = new ComboBoxItem { Tag = key };

                switch (key)
                {
                    case "cities":
                        comboBoxItem.Content = "Города";
                        break;

                    case "urban_areas":
                        comboBoxItem.Content = "Районы";
                        break;

                    case "types_of_ownership":
                        comboBoxItem.Content = "Типы собственности";
                        break;

                    case "atc":
                        comboBoxItem.Content = "АТС";
                        break;

                    case "users":
                        comboBoxItem.Content = "Пользователи";
                        break;

                    case "driving_categories":
                        comboBoxItem.Content = "Водительские категории";
                        break;

                    case "drivers":
                        comboBoxItem.Content = "Водители";
                        break;

                    case "cargo":
                        comboBoxItem.Content = "Грузы";
                        break;

                    case "car_brands":
                        comboBoxItem.Content = "Автомобильные марки";
                        break;

                    case "cars":
                        comboBoxItem.Content = "Автомобили";
                        break;

                    case "transportation":
                        comboBoxItem.Content = "Перевозки";
                        break;

                    default:
                        continue;
                }

                comboBox.Items.Add(comboBoxItem);
            }
        }

        public static void SetContentDataGridByDataTable(DataGrid dg, DataTable dt)
        {
            // Применяем DataTable к ItemsSource DataGrid
            dg.ItemsSource = dt.DefaultView;

            // Настраиваем формат отображения даты для всех столбцов, содержащих тип данных DateTime
            foreach (DataColumn column in dt.Columns)
            {
                if (column.DataType == typeof(DateTime))
                {
                    var dateColumn = dg.Columns.FirstOrDefault(c => c.Header.ToString() == column.ColumnName);
                    if (dateColumn != null && dateColumn is DataGridTextColumn)
                    {
                        // Задаем формат отображения даты
                        ((DataGridTextColumn)dateColumn).Binding.StringFormat = "dd.MM.yyyy";
                    }
                }
            }

            // Прячем столбец с именем "ID"
            var idColumn = dg.Columns.FirstOrDefault(c => c.Header.ToString() == "ID");
            if (idColumn != null)
            {
                idColumn.Visibility = Visibility.Collapsed;
            }
        }

    }
}
