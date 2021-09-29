using System;

namespace GPS.Models.Common
{
    public class ExecProcedureModel
    {
        public String CurrentUser { get; set; }
        public String CurrentRegNo { get; set; }
        public String CurrentUserName { get; set; }
        public String ProcessId { get; set; }
        public String ModuleId { get; set; }
        public String FunctionId { get; set; }
    }
}