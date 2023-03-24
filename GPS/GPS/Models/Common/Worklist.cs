using System;

namespace GPS.Models.Common
{
    public class WorklistParam
    {
        public String DOC_NO { get; set; }
        public String ITEM_NO { get; set; }
        public String DOC_TYPE { get; set; }
    }

    public class Worklist
    {
        public Int16 NUMBER { get; set; }

        public String DOCUMENT_NO { get; set; }
        public String ITEM_NO { get; set; }
        public String DOCUMENT_SEQ { get; set; }
        public String DOCUMENT_TYPE { get; set; }

        public String APPROVAL_CD { get; set; }
        public String APPROVAL_DESC { get; set; }
        public String APPROVED_BY { get; set; }
        public String APPROVED_BYPASS { get; set; }
        public DateTime APPROVED_DT { get; set; }

        public String STRUCTURE_ID { get; set; }
        public String STRUCTURE_NAME { get; set; }
        public String APPROVER_POSITION { get; set; }

        /** For Detail PR **/
        public String PIC_REGISTERED { get; set; }
        public String ACTUAL_REGISTERED { get; set; }

        public String PIC_STAFF { get; set; }
        public String PLAN_STAFF { get; set; }
        public String ACTUAL_STAFF { get; set; }
        public String PLNLT_STAFF { get; set; }
        public String ACTLT_STAFF { get; set; }

        public String PIC_SH { get; set; }
        public String PLAN_SH { get; set; }
        public String ACTUAL_SH { get; set; }
        public String PLNLT_SH { get; set; }
        public String ACTLT_SH { get; set; }

        public String PIC_DPH { get; set; }
        public String PLAN_DPH { get; set; }
        public String ACTUAL_DPH { get; set; }
        public String PLNLT_DPH { get; set; }
        public String ACTLT_DPH { get; set; }

        public String PIC_DH { get; set; }
        public String PLAN_DH { get; set; }
        public String ACTUAL_DH { get; set; }
        public String PLNLT_DH { get; set; }
        public String ACTLT_DH { get; set; }
        /** End of data for detail PR **/
    }

    public class WorklistHistory
    {
        public string ITEM_NO { get; set; }
        public string LAST_STATUS { get; set; }
        public string LAST_APPROVED_BY { get; set; }
        public string LAST_APPROVED_DT { get; set; }
    }
}