using System;

namespace GPS.Models.Home
{
    public class LogMonitoringDetail
    {
        public Int64 ProcessId { get; set; }
        public Int32 SeqNo { get; set; }
        public String MessageId { get; set; }
        public String MessageType { get; set; }
        public String MessageContent { get; set; }
        public String Location { get; set; }
        public String CreatedBy { get; set; }
        public DateTime CreatedDt { get; set; }
        public String ChangedBy { get; set; }
        public DateTime ChangedDt { get; set; }

        //For Header Data
        public DateTime StartDt { get; set; }
        public DateTime EndDt { get; set; }
        public String FunctionName { get; set; }
        public String Status { get; set; }
        public String StatusValue { get; set; }
    }
}