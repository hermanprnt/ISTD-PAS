using System;

namespace GPS.Models.PR.PRStatusMonitoring
{
    public class PRSummaryMonitoring
    {
        public string DIVISION_ID { get; set; }
        public decimal TOTAL_PR { get; set; }
        public decimal TOTAL_AMOUNT_PR { get; set; }
    }

        public class PRStatusMonitoring
    {
        public int NO { get; set; }
        public int ROW_NUM { get; set; }
        public string PR_NO { get; set; }
        public string PR_ITEM_NO { get; set; }
        public int SIMILAR_PR_ROW { get; set; }
        public string MAT_DESC { get; set; }
        public string PR_STATUS { get; set; }
        public string PR_STATUS_DESC { get; set; }
        public string WBS_NO { get; set; }
        public string WBS_NAME { get; set; }
        public decimal PR_QTY_REMAIN { get; set; }
        public decimal PR_LOCAL_AMOUNT { get; set; }
        public string PR_CREATED_BY { get; set; }
        public DateTime PR_CREATED_DATE { get; set; }
        public DateTime i_SH_DATE { get; set; }
        public DateTime i_SH_PLANNING_DATE { get; set; }
        public string i_SH_PLANNING { get; set; }
        public int i_SH_INTERVAL { get; set; }
        public int i_SH_DELAY { get; set; }
        public DateTime i_DPH_DATE { get; set; }
        public DateTime i_DPH_PLANNING_DATE { get; set; }
        public string i_DPH_PLANNING { get; set; }
        public int i_DPH_INTERVAL { get; set; }
        public int i_DPH_DELAY { get; set; }
        public DateTime i_DH_DATE { get; set; }
        public DateTime i_DH_PLANNING_DATE { get; set; }
        public string i_DH_PLANNING { get; set; }
        public int i_DH_INTERVAL { get; set; }
        public int i_DH_DELAY { get; set; }
        public DateTime STAFF_DATE { get; set; }
        public DateTime STAFF_PLANNING_DATE { get; set; }
        public string STAFF_PLANNING { get; set; }
        public int STAFF_INTERVAL { get; set; }
        public int STAFF_DELAY { get; set; }
        public DateTime c_SH_DATE { get; set; }
        public DateTime c_SH_PLANNING_DATE { get; set; }
        public string c_SH_PLANNING { get; set; }
        public int c_SH_INTERVAL { get; set; }
        public int c_SH_DELAY { get; set; }
        public DateTime c_DPH_DATE { get; set; }
        public DateTime c_DPH_PLANNING_DATE { get; set; }
        public string c_DPH_PLANNING { get; set; }
        public int c_DPH_INTERVAL { get; set; }
        public int c_DPH_DELAY { get; set; }
        public DateTime FINANCE_DATE { get; set; }
        public DateTime FINANCE_PLANNING_DATE { get; set; }
        public string FINANCE_PLANNING { get; set; }
        public int FINANCE_INTERVAL { get; set; }
        public int FINANCE_DELAY { get; set; }
        public string VENDOR_CD { get; set; }
        public string VENDOR_NAME { get; set; }
        public string PO_NO { get; set; }
        public string PO_STATUS { get; set; }
        public string PO_STATUS_DESC { get; set; }
        public decimal PO_QTY_REMAIN { get; set; }
        public decimal PO_LOCAL_AMOUNT { get; set; }
        public string PO_CREATED_BY { get; set; }
        public DateTime PO_CREATED_DATE { get; set; }
        public DateTime PO_SH_DATE { get; set; }
        public DateTime PO_SH_PLANNING_DATE { get; set; }
        public string PO_SH_PLANNING { get; set; }
        public int PO_SH_INTERVAL { get; set; }
        public int PO_SH_DELAY { get; set; }
        public DateTime PO_DPH_DATE { get; set; }
        public DateTime PO_DPH_PLANNING_DATE { get; set; }
        public string PO_DPH_PLANNING { get; set; }
        public int PO_DPH_INTERVAL { get; set; }
        public int PO_DPH_DELAY { get; set; }
        public DateTime PO_DH_DATE { get; set; }
        public DateTime PO_DH_PLANNING_DATE { get; set; }
        public string PO_DH_PLANNING { get; set; }
        public int PO_DH_INTERVAL { get; set; }
        public int PO_DH_DELAY { get; set; }
        public int TOTAL_DELAY { get; set; }
        public string GR_NO { get; set; }
        public string GR_STATUS { get; set; }
        public string GR_STATUS_DESC { get; set; }
        public string GR_CREATED_BY { get; set; }
        public DateTime GR_CREATED_DATE { get; set; }
        public int ORDER_BY { get; set; }
    }
}