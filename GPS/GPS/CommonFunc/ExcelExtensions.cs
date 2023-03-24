using System;
using System.Globalization;
using NPOI.SS.UserModel;

namespace GPS.CommonFunc
{
    public static class ExcelExtensions
    {
        public static String GetString(this ICell cell)
        {
            return Convert.ToString(cell) ?? String.Empty;
        }

        public static Int32 GetInt32(this ICell cell)
        {
            if (cell.GetString() == String.Empty)
                return 0;

            return Convert.ToInt32(cell.GetString());
        }

        public static Int16 GetInt16(this ICell cell)
        {
            if (cell.GetString() == String.Empty)
                return 0;

            return Convert.ToInt16(cell.GetString());
        }

        public static Decimal GetDecimal(this ICell cell)
        {
            if (cell.GetString() == String.Empty)
                return 0;

            return Convert.ToDecimal(cell.GetString());
        }

        public static DateTime GetMDYDatetime(this ICell cell)
        {
            return FixDatetimeStringValue(cell).GetDatetime("MM/dd/yyyy", true);
        }

        public static DateTime GetDMYDatetime(this ICell cell)
        {
            return FixDatetimeStringValue(cell).GetDatetime("dd/MM/yyyy", true);
        }

        private static ICell FixDatetimeStringValue(ICell cell)
        {
            if (cell.GetString() == String.Empty)
                return cell;

            String[] splitted = cell.GetString().Split('/');
            String fixedString = splitted[0].PadLeft(2, '0') + "/" + splitted[1].PadLeft(2, '0') + "/" + splitted[2].PadLeft(2, '0');
            cell.SetCellValue(fixedString);
            return cell;
        }

        public static DateTime GetDatetime(this ICell cell, String stringFormat)
        {
            return cell.GetDatetime(stringFormat, true);
        }

        public static DateTime GetDatetime(this ICell cell, String stringFormat, Boolean useMinSqlDatetime)
        {
            if (cell.GetString() == String.Empty)
                return useMinSqlDatetime ? new DateTime(1753, 1, 1) : new DateTime(1, 1, 1);

            DateTime result = DateTime.ParseExact(cell.GetString(), stringFormat, CultureInfo.InvariantCulture);
            return result;
        }
    }
}