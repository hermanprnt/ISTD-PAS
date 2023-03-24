using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace GPS.Models.ReceivingList
{
    public class Supplier
    {
        public string TAX_INVOICE_NO { get; set; }
        public string REPLACEMENT_FG { get; set; }
        public string SUPPLIER_CODE { get; set; }
        public string NAME { get; set; }
        public string NPWP { get; set; }
        public string ADDRESS { get; set; }
        public DateTime? CREATED_DT { get; set; }
        public string CREATED_BY { get; set; }

        public DateTime? UPDATED_DT { get; set; }        
        public string UPDATED_BY { get; set; }

        public string SUPPLIER_ID { get; set; }
        public string VENDOR_CD { get; set; }
        public string VENDOR_NAME { get; set; }
        public string PKP_FLAG { get; set; }
        public Double PPN_RATE { get; set; }
        public string S_PPN_RATE { get; set; }
        public string EDIT_AMOUNT_FLAG { get; set; }
    }
}