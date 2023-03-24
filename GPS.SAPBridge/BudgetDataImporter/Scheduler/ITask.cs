using System;
using System.Collections.Generic;
using GPS.Core.ViewModel;

namespace BudgetDataImporter
{
    public interface ITask
    {
        String SystemType { get; }
        String SystemCd { get; }
        IList<NameValueItem> ScheduleList { get; set; }
        Int32 TaskControl { get; set; }
        void OnSchedule(Object state);
    }
}