using System;

namespace GPS.ViewModels.PO
{
    public class PurchaseOrderSearchViewModel : SearchViewModel
    {
        public String PONo { get; set; }
        public String Vendor { get; set; }
        public String Status { get; set; }
        public String CreatedBy { get; set; }
        public String PurchasingGroup { get; set; }
        public String POHeaderText { get; set; }
        public String PRNo { get; set; }
        public String ProcChannel { get; set; }
    }
}