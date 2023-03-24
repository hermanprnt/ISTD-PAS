using System;

namespace GPS.Models.PRPOApproval
{
    /// <summary>
    /// PRApproval history view parameter model.
    /// </summary>
    public class CommonApprovalHistoryParam
    {
        public String DOC_NO { get; set; }
        public String ITEM_NO { get; set; }
        public String DOC_TYPE { get; set; }
    }

    /// <summary>
    /// PRApproval history view data model.
    /// </summary> 
    public class CommonApprovalHistory
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
    }
}