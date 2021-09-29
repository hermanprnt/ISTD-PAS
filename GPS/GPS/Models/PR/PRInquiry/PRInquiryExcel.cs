using System;

namespace GPS.Models.PR.PRInquiry
{

    public class PRInquiryExcel
    {
        /*
         *
         * 
        */

        public string NUMBER { get; set; }
        public string PR_NO { get; set; }
        public DateTime? CREATED_DT { get; set; }
        public DateTime? CHANGED_DT { get; set; }
        public DateTime? DOC_DT { get; set; }
        public string DIVISION_NAME { get; set; }
        public string SLOC_CD { get; set; }
        public string SLOC_NAME { get; set; }
        public string PLANT_CD { get; set; }
        public string PLANT_NAME { get; set; }
        public string PR_DESC { get; set; }
        public string PR_STATUS { get; set; }
        public string STATUS_DESC { get; set; }
        public string PR_ITEM_NO { get; set; }
        public string ITEM_CLASS { get; set; }
        public string MAT_NO { get; set; }
        public string MAT_DESC { get; set; }
        public decimal PR_QTY { get; set; }
        public string UNIT_OF_MEASURE_CD { get; set; }
        public double PRICE_PER_UOM { get; set; }
        public string LOCAL_CURR_CD { get; set; }
        public double EXCHANGE_RATE { get; set; }
        public double ORI_AMOUNT { get; set; }
        public double LOCAL_AMOUNT { get; set; }
        public string WBS_NO { get; set; }
        public string GL_ACCOUNT { get; set; }
        public string COST_CENTER_CD { get; set; }
        public string VENDOR_CD { get; set; }
        public string VENDOR_NAME { get; set; }

        public string PO_NO { get; set; }
        public string PO_ITEM_NO { get; set; }
        public string PROCUREMENT_DESC { get; set; }
        public string COORDINATOR_DESC { get; set; }
        public string ASSET_NO { get; set; }
        public string CREATED_BY { get; set; }
        public string CURRENT_REG_APPROVER { get; set; }
        public string CURRENT_APPROVER { get; set; }
        
    }
}