namespace GPS.Models.Master
{
    public class Quota
    {
        public int Number { get; set; }
        public int DIVISION_ID { get; set; }
        public string DIVISION_ID2 { get; set; }
	    public string DIVISION_NAME { get; set; }
        public string WBS_NO { get; set; }
	    public string  QUOTA_TYPE { get; set; }
	    public string TYPE_DESCRIPTION { get; set; }
        public string ORDER_COORD { get; set; }
        public string ORDER_COORD2 { get; set; }
	    public string ORDER_COORD_NAME { get; set; }
        public decimal QUOTA_AMOUNT { get; set; }
        public string QUOTA_AMOUNT2 { get; set; }
        public decimal QUOTA_AMOUNT_TOL { get; set; }
        public string QUOTA_AMOUNT_TOL2 { get; set; }
	    public string CREATED_BY { get; set; }
	    public string CREATED_DT { get; set; }
	    public string CHANGED_BY { get; set; }
	    public string CHANGED_DT { get; set; }
    }

    public class COORDINATOR
    {
        public string COORDINATOR_CD { get; set; }
        public string COORDINATOR_DESC { get; set; }
    }

    public class QuotaUpload
    {
        public string QUOTA_NO { get; set; }
        public string YEAR { get; set; }
        public string DIVISION_ID { get; set; }
        public string MAT_NO { get; set; }
        public string MONTH { get; set; }
        public double QUOTA { get; set; }
        public double USAGE { get; set; }
        public double ADDITIONAL_QUOTA { get; set; }
    }
}