using System;

namespace GPS.Models.PRPOApproval
{
    public class CommonApprovalVendorAssignment
    {
        public String DIVISION_ID { get; set; }
        public String VENDOR_CD { get; set; }
        public String VENDOR_NAME { get; set; }
        public DateTime FISCAL_FROM { get; set; }
        public DateTime FISCAL_TO { get; set; }
        public String CURRENT_YEAR { get; set; }
        public decimal CURRENT_AMOUNT { get; set; }
        public String LAST_YEAR { get; set; }
        public decimal LAST_AMOUNT { get; set; }
        public decimal LIMIT_AMOUNT { get; set; }
    }
}