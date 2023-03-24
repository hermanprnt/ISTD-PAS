using System;

namespace GPS.ViewModels.PO
{
    public class PRItemSearchViewModel : SearchViewModel
    {
        public String ProcessId { get; set; }
        public String PRNo { get; set; }
        public String MaterialNo { get; set; }
        public String MaterialDesc { get; set; }
        public String ValuationClass { get; set; }
        public String Currency { get; set; }
        public String VendorCode { get; set; }
        public String PlantCode { get; set; }
        public String SLocCode { get; set; }
        public String PRCoordinator { get; set; }
        public String PurchasingGroup { get; set; }
    }
}