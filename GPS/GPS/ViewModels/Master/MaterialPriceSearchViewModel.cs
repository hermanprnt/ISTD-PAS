using System;

namespace GPS.ViewModels.Master
{
    public class MaterialPriceSearchViewModel : SearchViewModel
    {
        public String MaterialNo { get; set; }
        public String Vendor { get; set; }
        public String SourceType { get; set; }
        public String PriceStatus { get; set; }
        public String PriceType { get; set; }
        public String ProdPurpose { get; set; }
        public String PartColorSfx { get; set; }
        public String PackingType { get; set; }
    }
}