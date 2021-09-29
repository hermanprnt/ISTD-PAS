using System;

namespace GPS.Core.WindowsService
{
    public class RegisteredSchedule
    {
        public String ProcessId { get; set; }
        public String FunctionId { get; set; }
        public String SystemCode { get; set; }
        public Int32 Status { get; set; }
        public DateTime PlanExecutionTime { get; set; }
        public DateTime ActualExecutionTime { get; set; }
    }
}