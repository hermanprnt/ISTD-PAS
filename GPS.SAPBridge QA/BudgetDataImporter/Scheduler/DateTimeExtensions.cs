using System;

namespace BudgetDataImporter
{
    public static class DateTimeExtensions
    {
        public static Boolean IsInRunningTimeFrame(this DateTime scheduledTime)
        {
            var now = DateTime.Now;
            DateTime compareNow = new DateTime(now.Year, now.Month, now.Day, now.Hour, now.Minute, 0);

            return scheduledTime.IsInScheduleTimeFrame() && DateTime.Compare(compareNow, scheduledTime) == 0;
        }

        public static Boolean IsInScheduleTimeFrame(this DateTime scheduledTime)
        {
            const Int32 OneMinuteSpan = 60 * 1000;
            var timespan = scheduledTime.GetMillisecondSpan();

            return timespan >= (OneMinuteSpan * -1);
        }

        public static Int32 GetMillisecondSpan(this DateTime scheduledTime)
        {
            var now = DateTime.Now;
            return Convert.ToInt32(scheduledTime.Subtract(now).TotalMilliseconds);
        }
    }
}