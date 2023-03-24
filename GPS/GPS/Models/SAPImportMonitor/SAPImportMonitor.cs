using System;

namespace GPS.Models.SAPImportMonitor
{
    public class SAPImportMonitor
    {
        public String ProcessId { get; set; }
        public String PONo { get; set; }
        public String PurchasingGroup { get; set; }
        public DateTime ExecutionDate { get; set; }
        public String Status { get; set; }
        public String Message { get; set; }
        public String CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public String ChangedBy { get; set; }
        public DateTime ChangedDate { get; set; }
    }
}