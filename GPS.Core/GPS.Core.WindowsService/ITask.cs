using System;
using System.Collections.Generic;
using GPS.Core.ViewModel;

namespace GPS.Core.WindowsService
{
    public interface ITask
    {
        String FunctionId { get; }
        IList<NameValueItem> ScheduleList { get; set; }
        Int32 TaskControl { get; set; }
        void OnSchedule(Object state);
    }
}