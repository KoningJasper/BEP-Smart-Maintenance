using System.Linq;

using LinqToExcel;
using SmartMaintenance.Models;
using Task = SmartMaintenance.Models.Task;

namespace SmartMaintenance.Builders
{
    internal static class TaskBuilder
    {
        private const string TaskXLSXFileName = "../../../Data/Tasks.xlsx";

        public static Task[] Build()
        {
            var excel = new ExcelQueryFactory
            {
                FileName = TaskXLSXFileName
            };

            excel.AddTransformation<Task>(x => x.Location, location => (Location) int.Parse(location));

            return (from x in excel.Worksheet<Task>() select x).ToArray();
        }
    }
}
