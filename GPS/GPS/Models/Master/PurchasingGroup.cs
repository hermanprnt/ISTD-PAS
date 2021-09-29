using System;
using System.Collections.Generic;

namespace GPS.Models.Master
{
    public class PurchasingGroupModel
    {
        public PurchasingGroup param { get; set; }
        public IEnumerable<PurchasingGroup> data { get; set; }

        private PurchasingGroupModel()
        {
            param = new PurchasingGroup();
            data = new List<PurchasingGroup>();
        }
    }

    public class PurchasingGroup
    {
        public Int32 DataNo { get; set; }
        public String PurchasingGroupCode { get; set; }
        public String Description { get; set; }
        public String ProcChannelCode { get; set; }
        public String ProcChannelDesc { get; set; }
        public String CreatedBy { get; set; }
        public DateTime CreatedDate { get; set; }
        public String ChangedBy { get; set; }
        public DateTime ChangedDate { get; set; }
    }
}
