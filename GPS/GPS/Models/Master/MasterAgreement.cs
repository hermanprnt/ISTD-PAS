using System;

namespace GPS.Models.Master
{
    public class MasterAgreement
    {
        public String VENDOR_CODE { get; set; }
        public String VENDOR_NAME { get; set; }
        public String PURCHASING_GROUP { get; set; }
        public String BUYER { get; set; }
        public String AGREEMENT_NO { get; set; }
        public String START_DATE { get; set; }
        public String EXP_DATE { get; set; }
        public String STATUS { get; set; }
        public String NEXT_ACTION { get; set; }
    }
    public class StatusAgreement
    {
        public String SYSTEM_CD { get; set; }
        public String SYSTEM_VALUE { get; set; }
    }
}