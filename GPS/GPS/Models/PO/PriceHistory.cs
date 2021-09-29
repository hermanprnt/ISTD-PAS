using System;

namespace GPS.Models.PO
{
    public class PriceHistory
    {
        public String MaterialNo { get; set; }
        public String Vendor { get; set; }
        public Decimal Price { get; set; }
        public String Currency { get; set; }
        public DateTime ValidFrom { get; set; }
        public DateTime ValidTo { get; set; }
    }
}