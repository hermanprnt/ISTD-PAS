using System;

namespace GPS.Models.Master
{
    public class BudgetConfig
    {
        public string WBS_NO { get; set; }
        public string WBS_NAME { get; set; }
        public string WBS_YEAR { get; set; }
        public string WBS_TYPE { get; set; }
        public string DIVISION_ID { get; set; }
        public string DIVISION_DESC { get; set; }

    }
    public class DataWBSNO
    {
        public Int32 Number { get; set; }
        public string WBS_NO { get; set; }
        public string WBS_NAME { get; set; }
        public string WBS_YEAR { get; set; }
        public string DIVISION_ID { get; set; }
        public string DIVISION_DESC { get; set; }
        public string WBS_TYPE { get; set; }        /*PROJECT_NO*/
        public string CREATED_BY { get; set; }
        public string CREATED_DT { get; set; }
        public string CHANGED_BY { get; set; }
        public string CHANGED_DT { get; set; }

    }
    public class ComboWBSType
    {
        public string WBS_TYPE { get; set; }
    }
}