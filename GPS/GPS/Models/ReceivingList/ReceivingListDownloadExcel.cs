using System;

namespace GPS.Models.ReceivingList
{
    public class ReceivingListDownloadExcel
    {
        public string RECEIVING_NO { set; get; }
        public string RECEIVING_ITEM_NO { set; get; }
        public DateTime? RECEIVING_DATE { set; get; }
        public string HEADER_TEXT { get; set; }

        public Int32 RECEIVING_QUANTITY { set; get; }
        public int PO_QUANTITY { set; get; }
        public int REMAINING_QUANTITY { set; get; }
        public double RECEIVING_AMOUNT { set; get; }
        public string VENDOR_CD { set; get; }
        public string VENDOR_NAME { get; set; }
        public string STATUS { get; set; }
        public DateTime? POSTING_DATE { get; set; }
        public string DOCUMENT_NO { get; set; }
        public string PO_NO { get; set; }
        public string PO_ITEM_NO { get; set; }
        public string PR_NO { get; set; }
        public string PR_ITEM_NO { get; set; }
        public DateTime? CANCEL_DATE { get; set; }
        public string CANCEL_REASON { get; set; }
       
    }
}