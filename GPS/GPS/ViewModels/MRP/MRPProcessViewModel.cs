using System;

namespace GPS.ViewModels.MRP
{
    public class MRPProcessViewModel
    {
        public String ProcessId { get; set; }
        public String CurrentUser { get; set; }
        public String ProcUsageGroup { get; set; }
        public String MRPMonth { get; set; }
        public Int32 ProcessType { get; set; }
    }
}