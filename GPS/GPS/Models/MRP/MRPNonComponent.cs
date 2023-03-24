using System;

namespace GPS.Models.MRP
{
    public class MRPNonComponent
    {
        public string USER_NAME { get; set; }       
        public Int32 NUMBER { get; set; }
        public string PROC_USAGE_CD { get; set; }
        public string DESCRIPTION { get; set; }
        public string GENTANI_HEADER_TYPE { get; set; }
        public string GENTANI_HEADER_CD { get; set; }
        public string MAT_NO { get; set; }
        public string MAT_DESC { get; set; }
        public string USAGE_QTY { get; set; }
        public string USAGE_QTY_STRING { get; set; }
        public string UOM { get; set; }
        public string PLANT_CD { get; set; }
        public string PLANT_NAME { get; set; }
        public string STORAGE_LOCATION { get; set; }
        public string SLOC_NAME { get; set; }
        public string MODEL { get; set; }
        public string TRANSMISSION { get; set; }
        public string ENGINE { get; set; }
        public string DE { get; set; }
        public string PROD_SFX { get; set; }
        public string COLOR { get; set; }
        public string VALID_DT_FR { get; set; }
        public string VALID_DT_TO { get; set; }
        public string CREATED_BY { get; set; }
        public string CREATED_DT { get; set; }
        public string CHANGED_BY { get; set; }
        public string CHANGED_DT { get; set; }
    }
}