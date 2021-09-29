using System;

namespace GPS.Models.MRP
{
    public class MaterialResourcePlanning
    {
        public Int32 DataNo { get; set; }
        public String MRPMonth { get; set; }
        public String PRNo { get; set; }
        public String Status { get; set; }
        public String CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public String ChangedBy { get; set; }
        public DateTime ChangedDate { get; set; }
        public String POApprovalBy { get; set; }
        public DateTime POApprovalDate { get; set; }
        public String POReleasedBy { get; set; }
        public DateTime POReleasedDate { get; set; }
    }
}