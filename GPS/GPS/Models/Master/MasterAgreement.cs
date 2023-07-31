using System;

namespace GPS.Models.Master
{
    public class MasterAgreement
    {
        public String Number { get; set; }
        public String ID { get; set; }
        public String VENDOR_CODE { get; set; }
        public String VENDOR_NAME { get; set; }
        public String PURCHASING_GROUP { get; set; }
        public String BUYER { get; set; }
        public String AGREEMENT_NO { get; set; }
        public String START_DATE { get; set; }
        public String EXP_DATE { get; set; }
        public String STATUS { get; set; }
        public String STATUS_STRING { get; set; }
        public String NEXT_ACTION { get; set; }
        public String BG_COLOR { get; set; }
        public String AN_ATTACHMENT { get; set; }
        public String AMOUNT { get; set; }
        public String EMAIL_BUYER { get; set; }
        public String EMAIL_SH { get; set; }
        public String EMAIL_DPH { get; set; }
        public String EMAIL_LEGAL { get; set; }
        public String CREATED_BY { get; set; }
        public String CREATED_DT{ get; set; }
        public String CHANGED_DT { get; set; }
        public String CHANGED_BY { get; set; }

    }
    public class StatusAgreement
    {
        public String SYSTEM_CD { get; set; }
        public String SYSTEM_VALUE { get; set; }
    }
}