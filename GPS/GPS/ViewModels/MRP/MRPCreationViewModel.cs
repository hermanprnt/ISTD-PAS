using System;
using System.Collections.Generic;
using GPS.Models.MRP;

namespace GPS.ViewModels.MRP
{
    public class MRPCreationViewModel
    {
        public String ProcessId { get; set; }
        public IEnumerable<ProcUsageGroup> ProcUsageGroup { get; set; }
    }
}