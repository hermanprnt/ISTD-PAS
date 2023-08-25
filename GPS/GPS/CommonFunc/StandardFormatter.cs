using System;
using System.Globalization;
using GPS.Constants;

namespace GPS.CommonFunc
{
    public static class StandardFormatter
    {
        public static String ToStandardRangeFormat(DateTime from, DateTime to)
        {
            return @from.ToStandardFormat() + " - " + to.ToStandardFormat();
        }

        public static String ToStandardFormat(this DateTime datetime)
        {
            String dateString = datetime.ToString(CommonFormat.Date, CultureInfo.InvariantCulture);
            if (dateString == "01.01.0001")
                return String.Empty;
            return dateString;
        }

        public static String ToStandardFormatWithTime(this DateTime datetime)
        {
            String dateString = datetime.ToString(CommonFormat.Datetime, CultureInfo.InvariantCulture);
            if (dateString == "01.01.0001")
                return String.Empty;
            return dateString;
        }

        public static String ToStandardFormat(this DateTime? datetime)
        {
            if (datetime == null)
                return String.Empty;
            String dateString = datetime.Value.ToString(CommonFormat.Date, CultureInfo.InvariantCulture);
            if (dateString == "01.01.0001")
                return String.Empty;
            return dateString;
        }

        public static String ToSqlCompatibleFormat(this DateTime datetime)
        {
            return datetime.ToString(CommonFormat.SqlCompatibleDateTime, CultureInfo.InvariantCulture);
        }

        public static String ToSqlCompatibleFormat(this DateTime? datetime)
        {
            return datetime == null ? String.Empty : datetime.Value.ToString(CommonFormat.SqlCompatibleDateTime, CultureInfo.InvariantCulture);
        }

        public static DateTime FromStandardFormat(this String datetime)
        {
            DateTime dt;
            DateTime.TryParseExact(datetime, CommonFormat.Date, CultureInfo.InvariantCulture, DateTimeStyles.None, out dt);

            return dt;
        }

        public static DateTime FromStandardFormatWithTime(this String datetime)
        {
            DateTime dt;
            DateTime.TryParseExact(datetime, CommonFormat.Datetime, CultureInfo.InvariantCulture, DateTimeStyles.None, out dt);

            return dt;
        }

        public static DateTime FromSqlCompatibleFormat(this String datetime)
        {
            DateTime dt;
            DateTime.TryParseExact(datetime, CommonFormat.SqlCompatibleDateTime, CultureInfo.InvariantCulture, DateTimeStyles.None, out dt);

            return dt;
        }

        public static String ToStandardFormat(this Decimal number)
        {
            return number.ToString(CommonFormat.Decimal, CultureInfo.InvariantCulture);
        }

        public static String ToStandardFormat(this Decimal? number)
        {
            return number == null ? String.Empty : number.Value.ToString(CommonFormat.Decimal, CultureInfo.InvariantCulture);
        }
    }
}