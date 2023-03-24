using System;

namespace GPS.ViewModels.PO
{
    public class UrgentSPKSaveViewModel
    {
        public String ProcessId { get; set; }
        public String PRNo { get; set; }
        public String PONo { get; set; }
        public String SPKNo { get; set; }
        public POSPKViewModel SPKInfo { get; set; }
    }
}