using System;

namespace GPS.Models.Master
{
    public class CostCenterGroup
    {
        public Int64 Number { get; set; }
        public string CostCenterGroupCd { get; set; }
        public string CostCenterGroupDesc { get; set; }
        public string DivisionCd { get; set; }
        public string CreatedBy { get; set; }
        public DateTime CreatedDt { get; set; }
        public string ChangedBy { get; set; }
        public DateTime ChangedDt { get; set; }

        public string DivisionName { get; set; }

        //For Insert Upload
        public Int64 ProcessId { get; set; }
        public String Row { get; set; }
        public String ErrorFlag { get; set; }
    }
}