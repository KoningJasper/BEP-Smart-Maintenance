using System.Linq;

using LinqToExcel;

using SmartMaintenance.Models;

namespace SmartMaintenance.Builders
{
    internal static class ComponentBuilder
    {
        private const string ComponentXLSXFileName = "../../../Data/Components.xlsx";

        public static Component[] Build()
        {
            var excel = new ExcelQueryFactory
            {
                FileName = ComponentXLSXFileName
            };

            return (from x in excel.Worksheet<Component>() select x).ToArray();
        }
    }
}
