using System;

namespace GPS.Models.PRPOApproval
{
    public class CommonApprovalNoticeUser
    {
        public String NOTICE_TO_USER { get; set; }
        public String NOTICE_TO_ALIAS { get; set; }
    }

    public class CommonApprovalNotice
    {
        public String DOC_NO { get; set; }
        public String DOC_TYPE { get; set; }
        public String DOC_DATE { get; set; }
        public Int16 SEQ_NO { get; set; }
        public String NOTICE_FROM_USER { get; set; }
        public String NOTICE_FROM_ALIAS { get; set; }
        public String NOTICE_TO_USER { get; set; }
        public String NOTICE_TO_ALIAS { get; set; }
        public String NOTICE_MESSAGE { get; set; }
        public String NOTICE_IMPORTANCE { get; set; }
        public String IS_REPLIED { get; set; }
        public Int32 REPLY_FOR { get; set; }
        public String NOTICE_REPLY_FROM_ALIAS { get; set; }
        public String NOTICE_REPLY_MESSAGE { get; set; }
        public String CREATED_BY { get; set; }
        public DateTime CREATED_DT { get; set; }
    }
}