using System;
using GPS.CommonFunc;

namespace GPS.ViewModels.SAPImportMonitor
{
    public class SAPImportMonitorSearchViewModel : SearchViewModel
    {
        public String ProcessId { get; set; }
        public String PONo { get; set; }
        public String Status { get; set; }
        public String PurchasingGroup { get; set; }
        public String ExecDateFromString
        {
            get { return ExecDateFrom.AsDatetimeString(); }
            set { ExecDateFrom = value.FromDatetimeString(); }
        }
        public DateTime? ExecDateFrom { get; set; }
        public String ExecDateToString
        {
            get { return ExecDateTo.AsDatetimeString(); }
            set { ExecDateTo = value.FromDatetimeString(); }
        }
        public DateTime? ExecDateTo { get; set; }
    }
}