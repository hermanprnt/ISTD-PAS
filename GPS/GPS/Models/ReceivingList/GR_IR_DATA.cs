using System;

namespace GPS.Common.Data
{
    [Serializable]
    public class GR_IR_DATA
    {
        public string PO_NUMBER { get; set; }
        public string PO_ITEM { get; set; }
        public string MATDOC_YEAR { get; set; }
        public string MATDOC_NUMBER { get; set; }
        public string MATDOC_ITEM { get; set; }
        public DateTime? MATDOC_DATE { get; set; }
        public string SPC_STOCK { get; set; }
        public Double MATDOC_AMOUNT { get; set; }
        public string VEND_CODE { get; set; }
        public string SUPPLIER_NAME { get; set; }
        public string PURCHDOC_PRICE { get; set; }
        public string MAT_NUMBER { get; set; }
        public string MAT_DESCR { get; set; }
        public string PLANT_CODE { get; set; }
        public string SLOC_CODE { get; set; }
        public string MATDOC_UNIT { get; set; }
        public string CANCEL { get; set; }
        public string ORI_MAT_NUMBER { get; set; }
        public string MATDOC_CURRENCY { get; set; }
        public Double MATDOC_QTY { get; set; }
        public string TAX_CODE { get; set; }
        //public string PO_DATE { get; set; }
        public string HEADER_TEXT { get; set; }
        public string IR_NO { get; set; }
        public string MOV_TYPE { get; set; }
        public string REF_DOC { get; set; }
        public string USRID { get; set; }

        public string CANCEL_DOC_NO { get; set; }

        public string GR_STATUS { get; set; }
        public string INVOICE_ID { get; set; }

        public DateTime? PO_DATE { get; set; }

        public String PO_DATE_STRING { get; set; }

        public String CURRENCY { get; set; }
    }
}
