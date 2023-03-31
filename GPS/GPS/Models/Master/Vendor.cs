using System;

namespace GPS.Models.Master
{
    public class Vendor
    {
        public Int32 Number { get; set; }
        public String ATTACHMENT { get; set; }
        public String DD_STATUS { get; set; }
        public String VALID_DD_FROM { get; set; }
        public String VALID_DD_TO { get; set; }
        public String VendorCd { get; set; }
        public String VendorName { get; set; }
        public String VendorPlant { get; set; }
        public String PurchGroup { get; set; }
        public String SAPVendorID { get; set; }
        public String PaymentMethodCd { get; set; }
        public String PaymentTermCd { get; set; }
        public String DeletionFlag { get; set; }
        public String Address { get; set; }
        public String City { get; set; }
        public String Phone { get; set; }
        public String Fax { get; set; }
        public String Attention { get; set; }
        public String Postal { get; set; }
        public String Country { get; set; }
        public String Mail { get; set; }
        public String CreatedBy { get; set; }
        public DateTime CreatedDt { get; set; }
        public String ChangedBy { get; set; }
        public DateTime ChangedDt { get; set; }
        public String SetDisablePlant { get; set; }
        public String DivisionId { get; set; }
        //For Insert Upload
        public Int64 ProcessId { get; set; }
        public String Row { get; set; }
        public String ErrorFlag { get; set; }
    }
}