namespace GPS.Models.Master
{
    public class SourceList
    {
        public int Number { get; set; }
        public string MAT_NO { get; set; }
        public string VENDOR_CD { get; set; }
        public string VALID_DT_FROM { get; set; }
        public string VALID_DT_TO { get; set; }
        public string CREATED_BY { get; set; }
        public string CREATED_DT { get; set; }
        public string CHANGED_BY { get; set; }
        public string CHANGED_DT { get; set; }
    }

    public class SourceListValidate
    {
        //public int Number { get; set; }
        public string PROCESS_CD { get; set; }
        public string MAT_NO { get; set; }
        public string VENDOR_CD { get; set; }
        public string VALID_DT_FROM { get; set; }
        public string VALID_DT_TO { get; set; }
        public string CREATED_BY { get; set; }
        public string CREATED_DT { get; set; }
        public string CHANGED_BY { get; set; }
        public string CHANGED_DT { get; set; }
    }
}