using System;

namespace GPS.Models.PO
{
    public class POItemCondition
    {
        public Int32 DataNo { get; set; }
        public String PONo { get; set; }
        public String POItemNo { get; set; }
        /*public String PRNo { get; set; }
        public String PRItemNo { get; set; }*/
        public String CompPriceCode { get; set; }
        public String CompPriceName { get; set; }
        public String ConditionCategory { get; set; }
        public String ConditionCategoryName { get; set; }
        public Int32 QtyPerUOM { get; set; }
        public Decimal CompPriceRate { get; set; }
        public String CompPriceType { get; set; }
        public Decimal Amount { get; set; }
    }
}