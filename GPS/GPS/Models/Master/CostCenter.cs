using System;

namespace GPS.Models.Master
{
    public class CostCenter
    {
        public Int32 Number { get; set; }
        public String CostCenterCd { get; set; }
        public String CostCenterDesc { get; set; }
        public String RespPerson { get; set; }
        public String Division { get; set; }
        public String ValidDtFrom { get; set; }
        public String ValidDtTo { get; set; }
        public String CreatedBy { get; set; }
        public String CreatedDt { get; set; }
        public String ChangedBy { get; set; }
        public String ChangedDt { get; set; }

        //public CostCenter()
        //{
        //    ValidDtFrom = DateTime.Now;
        //    ValidDtTo = new DateTime(9999, 12, 31);
        //}
    }
}