using System;
using GPS.CommonFunc;

namespace GPS.Models.PO
{
    public class POItemAdditionalInfo
    {
        public String Plant { get; set; }
        public String SLoc { get; set; }
        public DateTime DeliveryPlanDate { get; set; }
        public String DeliveryPlanDateString
        {
            get { return DeliveryPlanDate.ToStandardFormat(); }
            set { DeliveryPlanDate = value.FromStandardFormat(); }
        }
    }
}