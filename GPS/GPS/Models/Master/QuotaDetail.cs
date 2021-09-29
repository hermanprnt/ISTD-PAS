namespace GPS.Models.Master
{
    public class QuotaDetail
    {
        public int Number { get; set; }
        public string YEAR { get; set; }
        public string QUOTA_NO { get; set; }
        public string MONTH { get; set; }
        public string MAT_NO { get; set; }
        public string MAT_DESC { get; set; }
        public decimal QUOTA { get; set; }
        public decimal USAGE { get; set; }
        public decimal ADDITIONAL_QUOTA { get; set; }       
        public string CREATED_BY { get; set; }
        public string CREATED_DT { get; set; }
        public string CHANGED_BY { get; set; }
        public string CHANGED_DT { get; set; }

        public string DOC_NO { get; set; }
        public string QUOTA_MONTH { get; set; }
        public string QUOTA_MONTH2 { get; set; }
        public string QUOTA_TYPE { get; set; }
        public string DT_MONTH { get; set; }
        public string DST_TYPE { get; set; }
        public decimal AMOUNT { get; set; }
        public string CONFIRM_FLAG { get; set; }

        public int SEQ_NO { get; set; } 
        public string CONSUME_MONTH { get; set; }
        public string CONSUME_MONTH2 { get; set; }
        public string DIVISION_ID { get; set; }
        public string DIVISION_NAME { get; set; }
        public string WBS_NO { get; set; }
        public string TYPE { get; set; }
        public string TYPE_DESCRIPTION { get; set; }
        public string ORDER_COORD2 { get; set; }
        public string ORDER_COORD_NAME { get; set; }
        public decimal QUOTA_AMOUNT { get; set; }
        public string QUOTA_AMOUNT2 { get; set; }
        public double ADDITIONAL_AMOUNT { get; set; }
        public string ADDITIONAL_AMOUNT2 { get; set; }
        public decimal UNCONFIRM_AMOUNT { get; set; }
        public decimal USAGE_AMOUNT { get; set; }
        public string USAGE_AMOUNT2 { get; set; }
        public decimal REMAINING { get; set; }
        public string REMAINING2 { get; set; }
        public decimal TOLERANCE { get; set; }
        public string TOLERANCE2 { get; set; }

        public string CAR_FAMILY_CD { get; set; }
        public string MAT_TYPE_CD { get; set; }
        public string MAT_GRP_CD { get; set; }
        public string UOM { get; set; }

    }
}