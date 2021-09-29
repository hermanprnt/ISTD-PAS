using System;

namespace GPS.ViewModels.PO
{
    public class UrgentSPKViewModel
    {
        public Int32 DataNo { get; set; }
        public String PRNo { get; set; }
        public String Description { get; set; }
        public String Vendor { get; set; }
        public String PRStatus { get; set; }
        public String SPKNo { get; set; }
        public DateTime SPKDate { get; set; }
        public Decimal Amount { get; set; }
        public Boolean HasSPK { get; set; }
    }
}