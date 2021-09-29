using System;

namespace GPS.ViewModels.MRP
{
    public class ProcUsageGroupCheckViewModel
    {
        public DropdownListViewModel MRPMonth { get; set; }
        public String LastPOApproval { get; set; }
        public String LastMRPMonth { get; set; }
        public String LastMRPCreated { get; set; } 
    }
}