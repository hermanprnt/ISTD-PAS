using System;
using GPS.CommonFunc;

namespace GPS.Models.PO
{
    // NOTE: fields in this class could be used as result of PRItem search and POItem search
    public class PRPOItem
    {
        public Int32 DataNo { get; set; }
        public String PONo { get; set; }
        public String POItemNo { get; set; }
        public String PRNo { get; set; }
        public String PRItemNo { get; set; }
        public String SeqItemNo { get; set; }
        public String AssetNo { get; set; }
        public String SubAssetNo { get; set; }
        public String AssetStatus { get; set; }
        public String ValuationClass { get; set; }
        public String WBSNo { get; set; }
        public String CostCenter { get; set; }
        public String GLAccount { get; set; }
        public String Plant { get; set; }
        public String SLoc { get; set; }
        public String Vendor { get; set; }

        public String Creator { get; set; } // add by khanif 18-07-2019
        public String VendorName { get; set; } // add by khanif 24 April 2019
        public String VendorDesc { get; set; } // add by isid.rgl 27 Juni 2019
        public String MatNo { get; set; }
        public String MatDesc { get; set; }
        public Decimal PricePerUOM { get; set; }
        public Decimal PriceAmount { get; set; }
        public String UOM { get; set; }
        public DateTime? DeliveryPlanDate { get; set; }
        public String DeliveryPlanDateString
        {
            get { return DeliveryPlanDate == null ? String.Empty : DeliveryPlanDate.Value.ToStandardFormat(); }
            set { DeliveryPlanDate = String.IsNullOrEmpty(value) ? (DateTime?) null : value.FromStandardFormat(); }
        }
        public Decimal Qty { get; set; }
        public String Currency { get; set; }
        public Boolean HasItem { get; set; }
        public Boolean IsLocked { get; set; }
        public Boolean IsUrgent { get; set; }
        public Boolean IsService { get; set; }
        public Boolean IsEcatalogue { get; set; }
        public string PoStatus { get; set; }
    }
    #region 20190627 : isid.rgl : Listing Vendor in T_PO_ITEm after adopt PR
    public class ListVendorAdoptPR
    {
        public String VendorCD { get; set; }

    }
    #endregion
}