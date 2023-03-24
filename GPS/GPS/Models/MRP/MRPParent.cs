using System;

namespace GPS.Models.MRP
{
    public class MRPParent
    {
        public string USER_NAME { get; set; }
        public Int32 NUMBER { get; set; }
        public string PARENT_CD_HIDE { get; set; } 
        public string PARENT_CD { get; set; }
        public string PARENT_TYPE_HIDE { get; set; } 
        public string PARENT_TYPE { get; set; }     
        public string CREATED_BY { get; set; }
        public string CREATED_DT { get; set; }
        public string CHANGED_BY { get; set; }
        public string CHANGED_DT { get; set; }
    }
}