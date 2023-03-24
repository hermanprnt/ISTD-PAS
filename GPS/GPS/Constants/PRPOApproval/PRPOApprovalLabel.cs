using System;

namespace GPS.Constants.PRPOApproval
{
    public class PRPOApprovalPlaceHolder
    {
        public const String SelectOption = "";
        public const String StatusOption = "- Select Status -";
        public const String TypeOption = "- Select Type -";
        public const String VendorOption = "- Select Vendor -";
        public const String DivisionOption = "- Select Division -";
    }
}

namespace MvcApplication1.Helpers
{
    public class HTMLHelper
    {
        public static string LabelDate(DateTime date)
        {
            if(date==DateTime.MinValue)
            {
                return "";
            }

            string dayStr, yearStr, monthStr;
            dayStr = date.Day.ToString();
            monthStr = date.Month.ToString();
            yearStr = date.Year.ToString();

            return String.Format(@"<div class='custom-date'><sup class='small-num'>{0}</sup><span class='slash'></span><sub class='total-num'>{1}</sub><sup class='average-num'>{2}</sup></div>", dayStr, monthStr, yearStr);
        }

        public static string LabelDate(DateTime date, string red_green)
        {
            if (date == DateTime.MinValue)
            {
                return "";
            }

            string dayStr, yearStr, monthStr;
            dayStr = date.Day.ToString();
            monthStr = date.Month.ToString();
            yearStr = date.Year.ToString();
            var class_Color = (red_green == "RED" ? "" : "");
            var font_Color = (red_green == "RED" ? "f-white" : "f-white");

            return String.Format(@"<div class='custom-date " + class_Color + "'><sup class='small-num " + font_Color + "'>{0}</sup><span class='slash " + font_Color + "'></span><sub class='total-num " + font_Color + "'>{1}</sub><sup class='average-num " + font_Color + "'>{2}</sup></div>", dayStr, monthStr, yearStr);
        }

        public static string LabelDate(int delay, string red_green)
        {
            var class_Color = (red_green == "RED" ? "" : "");
            var font_Color = (red_green == "RED" ? "f-white" : "f-white");

            return String.Format(@"<div class='" + font_Color+ "'>{0}</div>", delay);
        }
    }
}