using System;

namespace GPS.Models.Master
{
    public class CalculationMapping
    {
        // Header
        public string CALCULATION_SCHEME_CD { get; set; }
        public string CALCULATION_SCHEME_DESC { get; set; }

        // Mapping
        public string COMP_PRICE_CD { get; set; }
        public Int32 SEQ_NO { get; set; }
        public string COMP_PRICE_TEXT { get; set; }
        public Int32 BASE_VALUE_FROM { get; set; }
        public Int32 BASE_VALUE_TO { get; set; }
        public string INVENTORY_FLAG { get; set; }
        public string QTY_PER_UOM { get; set; }
        public string CALCULATION_TYPE { get; set; }
        public string PLUS_MINUS_FLAG { get; set; }
        public string CONDITION_CATEGORY { get; set; }
        public string ACCRUAL_FLAG_TYPE { get; set; }
        public string CONDITION_RULE { get; set; }
        public string CREATED_BY { get; set; }
        public DateTime CREATED_DT { get; set; }
        public string CHANGED_BY { get; set; }
        public DateTime CHANGED_DT { get; set; }

        public string BASE_VALUE { get; set; }
        public string STATUS { get; set; }
        public string ITEM_STATUS { get; set; }
        public string COMP_PRICE_DESC { get; set; }
        public string CALCULATION_TYPE_DESC { get; set; }
        public string PLUS_MINUS_SIGN { get; set; }
        public string CONDITION_CATEGORY_CD { get; set; }

        public string MESSAGE { get; set; }
        public Int64 PROCESS_ID { get; set; }
    }
}