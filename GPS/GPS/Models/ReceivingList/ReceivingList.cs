using System;

namespace GPS.Models.ReceivingList
{
    public class ReceivingList
    {
        public string PO_NO { set; get; }
        public string PO_ITEM { set; get; }
        public DateTime? PO_DT { set; get; }
        public String PO_TEXT { get; set; }

        public int TOTAL_QTY { set; get; }
        public double TOTAL_AMOUNT { set; get; }
        public string UNIT_OF_MEASURE_CD { get; set; }
        public string ITEM_CURRENCY { get; set; }
        public string VENDOR_CD { set; get; }
        public string VENDOR_NAME { get; set; }
        public string MAT_DOC_NO { get; set; }
        public string PROCESS_ID { get; set; }

        public Int32 DataNo { get; set; }
        public String ReceivingNo { get; set; }
        public DateTime ReceivingDate { get; set; }
        public String HeaderText { get; set; }
        public String PONo { get; set; }
        public String Vendor { get; set; }
        public String Currency { get; set; }
        public String Status { get; set; }
        public String StatusCode { get; set; }
        public String SAPDocNo { get; set; }
        public String ProcessId { get; set; }
        public Decimal TotalQty { get; set; }
        public String CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public String ChangedBy { get; set; }
        public DateTime ChangedDate { get; set; }

        public string STATUS_CD { get; set; }
        public string STATUS_DESC { get; set; }
    }
}