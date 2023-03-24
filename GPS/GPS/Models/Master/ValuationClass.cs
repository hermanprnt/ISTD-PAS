using System;

namespace GPS.Models.Master
{
    public class ValuationClass
    {
        /*
         *
         * 
        */
        public string ITEM_CLASS { get; set; }
        public string ITEM_CLASS_DESC { get; set; }
        public string VALUATION_CLASS { get; set; }
        public string VALUATION_CLASS_DESC { get; set; }
        public string AREA_DESC { get; set; }
        public string PROCUREMENT_TYPE { get; set; }
        public string GL_ACCOUNT { get; set; }
        public string CALCULATION_SCHEME_CD { get; set; }
        public string PURCHASING_GROUP_CD { get; set; }
        public string PR_COORDINATOR { get; set; }
        public string PR_COORDINATOR_CD { get; set; }
        public string MATL_GROUP { get; set; }
        public string PROC_CHANNEL_CD { get; set; }
        public string FD_GROUP_CD { get; set; }
        public string CREATED_BY { get; set; }
        public DateTime CREATED_DT { get; set; }
        public string CHANGED_BY { get; set; }
        public DateTime CHANGED_DT { get; set; }

        public string PR_COORDINATOR_DESC { get; set; }
        public string PROCUREMENT_DESC { get; set; }
        public string PURCHASING_GRP_DESC { get; set; }
        public string FD_GROUP_DESC { get; set; }
        public string CALCULATION_SCHEME_DESC { get; set; }
        public string STATUS { get; set; }

        public string MESSAGE { get; set; }

        //Added From Models.Common.ValuationClass
        public int Number { get; set; }
        public int BUDGET_COORDINATOR { get; set; }
    }
}