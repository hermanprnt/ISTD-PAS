using System;
using GPS.Models.Common;

namespace GPS.Models.PRPOApproval
{
    public class ExecPOApprovalResultModel : ExecProcedureResultModel
    {
        public String ExecAction { get; set; }
        public Int32 DocCount { get; set; }
        public Int32 Success { get; set; }
        public Int32 Fail { get; set; }
    }
}