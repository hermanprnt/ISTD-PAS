using System;

namespace GPS.Models.PO
{
    public class ComponentPriceHistory
    {
        public String CompPriceCode { get; set; }
        public String CompPriceDesc { get; set; }
        public String Currency { get; set; }
        public Decimal Qty { get; set; }
        public Decimal Price { get; set; }
        public Decimal Amount { get; set; }
        public DateTime ValidFrom { get; set; }
        public DateTime ValidTo { get; set; }
    }
}