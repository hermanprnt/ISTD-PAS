using System;
namespace GPS.Models.Report
{
    public class ProcurementTracking
    {
        public string PR_NO { get; set; }
        public string PR_ITEM_NO { get; set; }
        public string PR_SUBITEM_NO { get; set; }
        public DateTime PR_DOC_DT { get; set; }
        public string PLANT_CD { get; set; }
        public string SLOC_CD { get; set; }
        public string MAT_NO { get; set; }
        public string MAT_DESC { get; set; }
        public int PR_QTY { get; set; }
        public string UNIT_OF_MEASURE_CD { get; set; }
        public decimal PR_ORI_AMOUNT { get; set; }
        public string ORI_CURR_CD { get; set; }
        public string BUDGET_REF { get; set; }
        public string CREATED_BY { get; set; }
        public string PO_NO { get; set; }
        public string PO_ITEM_NO { get; set; }
        public string PO_SUBITEM_NO { get; set; }
        public string PURCHASING_GRP_CD { get; set; }
        public DateTime PO_DOC_DT { get; set; }
        public string PO_CURR { get; set; }
        public int PO_QTY_ORI { get; set; }
        public string UOM { get; set; }
        public decimal PO_ORI_AMOUNT { get; set; }
        public string VENDOR_CD { get; set; }
        public string VENDOR_NAME { get; set; }
        public string MAT_DOC_NO { get; set; }
        public string MAT_DOC_ITEM_NO { get; set; }
        public string GR_PO_SUBITEM_NO { get; set; }
        public DateTime DOCUMENT_DT { get; set; }
        public decimal GR_IR_AMOUNT { get; set; }
        public string InvoiceNo { get; set; }
        public DateTime InvoiceDate { get; set; }
        public decimal InvoiceAmount { get; set; }
        public string InvoiceCurrency { get; set; }
        public string ClearingNo { get; set; }
        public DateTime ClearingDate { get; set; }
        public string SAPDocNo { get; set; }
        public string SAPDocYear { get; set; }


        
    }
}