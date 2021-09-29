using System;

namespace GPS.Models.Master
{
    public class ProcurementChannel
    {
        public String PROC_CHANNEL_CD { get; set; }
        public String PROC_CHANNEL_DESC { get; set; }
        public String PO_PREFIX{ get; set; }
        public String DIVISION_ID{ get; set; }
        public String DEPARTMENT_ID { get; set; }
        public String SECTION { get; set; }
        public String CREATED_BY { get; set; }
        public String CREATED_DT { get; set; }
        public String CHANGED_BY { get; set; }
        public String CHANGED_DT { get; set; }
    }
}