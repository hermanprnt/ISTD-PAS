using System;
using GPS.Models.MRP;

namespace GPS.ViewModels.MRP
{
    public class MRPGetViewModel : GenericViewModel<MRPItem>
    {
        public String ProcUsageGroupCode { get; set; }
        public String MRPMonth { get; set; }
        public String PRNo { get; set; }
        public String Status { get; set; }
        //public String GentaniDock { get; set; }

    }
}