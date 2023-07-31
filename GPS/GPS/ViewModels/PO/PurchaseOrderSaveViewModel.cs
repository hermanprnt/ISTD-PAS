using System;
using System.Collections.Generic;

namespace GPS.ViewModels.PO
{
    public class PurchaseOrderSaveViewModel
    {
        public String ProcessId { get; set; }
        public String PONo { get; set; }
        public String PODesc { get;set;}
        public IEnumerable<String> PONote { get; set; }
        public String Vendor { get; set; }
        public String VendorName { get; set; }
        public String VendorAddress { get; set; }
        public String VendorCountry { get; set; }
        public String VendorCity { get; set; }
        public String VendorPostalCode { get; set; }
        public String VendorPhone { get; set; }
        public String VendorFax { get; set; }
        public String PurchasingGroup { get; set; }
        public String Currency { get; set; }
        public String DeliveryAddress { get ;set; }
        public POSPKViewModel SPKInfo { get; set; }
        public String OtherMail { get; set; }
        public String GOVERNMENT_RELATED { get; set; }
        public Boolean SaveAsDraft { get; set; }
    }
}