using System;

namespace GPS.Constants
{
    public sealed class CommonFormat
    {
        public const String Date = "dd.MM.yyyy";
        public const String Datetime = "dd.MM.yyyy HH:mm";
        public const String DatetimeWithSecond = "dd.MM.yyyy HH:mm:ss";
        public const String FullDateTime = "ddMMyyyyHHmmssffff";
        public const String CommDateTime = "ddd d, MMM yyyy hh:mm tt";
        public const String SqlCompatibleDate = "yyyy-MM-dd";
        public const String SqlCompatibleDateTime = "yyyy-MM-dd HH:mm:ss";
        public const String Decimal = "#,#0.##";
        public const String JsonMimeType = "application/json; charset=utf-8";
        public const String TxtMimeType = "text/plain";
        public const String PdfMimeType = "application/pdf";
        public const String ExcelMimeType = "application/ms-excel";
        public const Char ListDelimiter = ',';
        public const Char ItemDelimiter = ';';

        public const String MinSqlCompatibleDate = "01.01.1753";
    }
}