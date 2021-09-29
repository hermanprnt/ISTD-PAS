namespace GPS.Models.Report
{
    public class ProcurementTrackingParam
    {
        public string PR_NO { get; set; }
        public string PR_DT_FROM { get; set; }
        public string PR_DT_TO { get; set; }
        public string VENDOR { get; set; }
        public string CREATED_BY { get; set; }


        public string PO_NO { get; set; }
        public string PO_DT { get; set; }
        public string WBS_NO { get; set; }
        
       
        
        
        public string GR_NO { get; set; }
        public string GR_DATE { get; set; }
        public string DIVISION_ID { get; set; }


        public string CLEARING_NO { get; set; }
        public string CLEARING_DATE { get; set; }
        public int page { get; set; }
        public int pageSize { get; set; }
    }
}