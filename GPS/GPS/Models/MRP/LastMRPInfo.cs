using System;

namespace GPS.Models.MRP
{
    public class LastMRPInfo
    {
        public DateTime? LastPOApproval { get; set; }
        public String LastMRPMonth { get; set; }
        public DateTime? LastMRPCreated { get; set; }
    }
}