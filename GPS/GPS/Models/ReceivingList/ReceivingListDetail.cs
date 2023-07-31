using System;

namespace GPS.Models.ReceivingList
{
    public class ReceivingListDetail
    {
        public string PO_NO { get; set; }
        public string PO_ITEM { get; set; }
        public string MAT_DOC_NO { get; set; }
        public string HEADER_TEXT { get; set; }
        public DateTime? DOCUMENT_DT { get; set; }
        public string MATERIAL_NO { get; set; }
        public Double MOVEMENT_QTY { get; set; }
        public Double GR_IR_AMOUNT { get; set; }
        public string UNIT_OF_MEASURE_CD { get; set; }


        public string MATDOC_YEAR { get; set; }
        public string MATDOC_ITEM { get; set; }
        public string SPC_STOCK { get; set; }
        public string VEND_CODE { get; set; }
        public string SUPPLIER_NAME { get; set; }
        public string PURCHDOC_PRICE { get; set; }
        public string MAT_DESCR { get; set; }
        public string PLANT_CODE { get; set; }
        public string SLOC_CODE { get; set; }
        public string CANCEL { get; set; }
        public string ORI_MAT_NUMBER { get; set; }
        public string MATDOC_CURRENCY { get; set; }
        public string TAX_CODE { get; set; }
        //public string PO_DATE { get; set; }
        public string IR_NO { get; set; }
        public string MOV_TYPE { get; set; }
        public string REF_DOC { get; set; }
        public string USRID { get; set; }

        public string CANCEL_DOC_NO { get; set; }

        public string GR_STATUS { get; set; }

        public DateTime? PO_DATE { get; set; }

        public String ReceivingNo { get; set; }
        public String ReceivingItemNo { get; set; }
        public String HeaderText { get; set; }
        public String PONo { get; set; }
        public String POItemNo { get; set; }
        public String ItemNo { get; set; }
        public String MaterialNo { get; set; }
        public String MaterialDesc { get; set; }
        public Decimal OrderQty { get; set; }
        public Decimal ReceiveQty { get; set; }
        public String UOM { get; set; }
        public Decimal TotalReceive { get; set; }
        
    }


    public class ReceivingListUpload
    {
        public String ReceivingNo { get; set; }
        public String VendorName { get; set; }
        public String AttachmentFilename { get; set; }
        public String OtherAttachmentFilename { get; set; }
        public String AttachmentPath { get; set; }
        public String ChangeDtParam { get; set; }

    }
}