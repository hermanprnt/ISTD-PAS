using System;

namespace GPS.Models.PO
{
    public class PRPOSubItem
    {
        public Int32 DataNo { get; set; }
        public String PONo { get; set; }
        public String POItemNo { get; set; }
        public String POSubItemNo { get; set; }
        public String PRNo { get; set; }
        public String PRItemNo { get; set; }
        public String PRSubItemNo { get; set; }
        public String SeqItemNo { get; set; }
        public String SeqNo { get; set; }
        public String ValuationClass { get; set; }
        public String WBSNo { get; set; }
        public String CostCenter { get; set; }
        public String GLAccount { get; set; }
        public String Plant { get; set; }
        public String SLoc { get; set; }
        public String Vendor { get; set; }
        public String MatNo { get; set; }
        public String MatDesc { get; set; }
        public Decimal PricePerUOM { get; set; }
        public Decimal PriceAmount { get; set; }
        public String UOM { get; set; }
        public DateTime DeliveryPlanDate { get; set; }
        public Decimal Qty { get; set; }
        public Boolean IsLocked { get; set; }

        public String ActionOrigin { get; set; } //added : 20190722 : isid.rgl
    }
}