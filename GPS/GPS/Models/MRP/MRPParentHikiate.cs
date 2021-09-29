using System;

namespace GPS.Models.MRP
{
    public class MRPParentHikiate
    {
        public string USER_NAME { get; set; }
        public Int32 NUMBER { get; set; }
        public string PARENT_CD { get; set; }
        public string PARENT_TYPE { get; set; }
        public string PROC_USAGE_CD { get; set; }
        public string GENTANI_HEADER_TYPE { get; set; }
        public string DESCRIPTION { get; set; }        
        public string GENTANI_HEADER_CD { get; set; }       
        public string VALID_DT_FR { get; set; }
        public string VALID_DT_TO { get; set; }
        public string MODEL { get; set; }
        public string TRANSMISSION { get; set; }
        public string ENGINE { get; set; }
        public string DE { get; set; }
        public string PROD_SFX { get; set; }
        public string COLOR { get; set; }
        public int MULTIPLY_USAGE { get; set; }
        public string MULTIPLY_USAGE_STRING { get; set; }
        public string CREATED_BY { get; set; }
        public string CREATED_DT { get; set; }
        public string CHANGED_BY { get; set; }
        public string CHANGED_DT { get; set; }
    }
}