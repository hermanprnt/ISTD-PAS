using System;

namespace GPS.Models.Home
{
    public class LogMonitoring
    {
        public Int64 Number { get; set; }
        public Int64 ProcessId { get; set; }
        public String ModuleId { get; set; }
        public String FunctionId { get; set; }
        public DateTime StartDt { get; set; }
        public DateTime EndDt { get; set; }
        public String ProcessStatus { get; set; }
        public String CreatedBy { get; set; }
        public DateTime CreatedDt { get; set; }
        public DateTime ChangedBy { get; set; }
        public DateTime ChangedDt { get; set; }

        //For Lookup
        public String StatusValue { get; set; }
        public String FunctionName { get; set; }
    }
}