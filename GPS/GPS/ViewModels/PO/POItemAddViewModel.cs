using System;
using System.Collections.Generic;

namespace GPS.ViewModels.PO
{
    public class POItemAddViewModel
    {
        public String ProcessId { get; set; }
        public String PONo { get; set; }
        public String POItemNo { get; set; }
        public String SeqItemNo { get; set; }
        public String Vendor { get;set; }
        public String VendorName { get; set; }
        public String PurchasingGroup { get; set; }
        public String ValuationClass { get; set; }
        public String MatNo { get; set; }
        public String MatDesc { get; set; }
        public Decimal Qty { get; set; }
        public String UOM { get; set; }
        public Decimal Price { get; set; }
        public String WBSNo { get; set; }
        public String CostCenter { get; set; }
        public String GLAccount { get; set; }
        public String DeliveryDateString { get; set; }
        public DateTime DeliveryDate { get; set; }
        public String Plant { get; set; }
        public String SLoc { get; set; }
        public String Currency { get; set; }
        public IEnumerable<POSubItemAddViewModel> SubItemList { get; set; }
    }
}