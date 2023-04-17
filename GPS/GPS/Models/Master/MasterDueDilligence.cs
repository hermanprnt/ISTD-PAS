using System;

namespace GPS.Models.Master
{
    public class MasterDueDilligence
    {
        public String Number { get; set; }
        public String VENDOR_CODE { get; set; }
        public String VENDOR_PLANT { get; set; }
        public String VENDOR_NAME { get; set; }
        public String DD_STATUS { get; set; }
        public String DD_ATTACHMENT { get; set; }
        public String VALID_DD_FROM { get; set; }
        public String VALID_DD_TO { get; set; }
        public String AGREEMENT_NO { get; set; }
        public String VALID_AGREEMENT_NO_FROM { get; set; }
        public String VALID_AGREEMENT_NO_TO { get; set; }
        public String DELETION { get; set; }
        public String BG_COLOR { get; set; }
        public String CREATED_BY { get; set; }
        public String CREATED_DT { get; set; }
        public String CHANGED_BY { get; set; }
        public String CHANGED_DT { get; set; }
    }
    public class DueDilligenceStatus
    {
        public String SYSTEM_CD { get; set; }
        public String SYSTEM_VALUE { get; set; }
    }
}