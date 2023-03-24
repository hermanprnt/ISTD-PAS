using System;

namespace GPS.Core.WindowsService
{
    public class Schedule
    {
        public String FunctionId { get; set; }
        public String SystemCode { get; set; }
        public DateTime Datetime { get; set; }
        public Int32 Span { get; set; }
    }
}