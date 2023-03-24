using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SADataExporter
{
    public class RunnerInfo
    {
        public string ProcessId { get; set; }
        public string ModuleId { get; set; }
        public string FunctionId { get; set; }
        public string processId { get { return this.ProcessId; } }
    }
}
