using System;
using GPS.Models.Common;

namespace GPS.Models.PRPOApproval
{
    public class ExecPOApprovalModel : ExecProcedureModel
    {
        public String ApprovalMode { get; set; }
        public String PONoList { get; set; }

        // NOTE: same as POApprovalParam
        public String DocNo { get; set; }
        public String DocDesc { get; set; }
        public String Plant { get; set; }
        public String SLoc { get; set; }
        public String PurchasingGroup { get; set; }
        public String Vendor { get; set; }
        public String Status { get; set; }
        public String DateFrom { get; set; }
        public String DateTo { get; set; }
        public String Currency { get; set; }
        public String UserType { get; set; }

        // NOTE: Added page model because if user choose check-all, just all of document in current page that can be proceed
        public String OrderBy { get; set; }
        public int CurrentPage { get; set; }
        public int PageSize { get; set; }
    }
}