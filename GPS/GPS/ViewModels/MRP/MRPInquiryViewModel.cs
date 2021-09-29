using System.Collections.Generic;
using GPS.Models.MRP;

namespace GPS.ViewModels.MRP
{
    public class MRPInquiryViewModel : GenericViewModel<MaterialResourcePlanning>
    {
        public IList<ProcUsageGroup> ProcurementUsageGroup { get; set; }
    }
}