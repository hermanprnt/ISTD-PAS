using System;

namespace GPS.Common.Data
{
    [Serializable]
    public class GR_IR_DOC_DATE
    {
        public string SIGN { get; set; }
        public string OPTION { get; set; }
        public DateTime? LOW { get; set; }
        public DateTime? HIGH { get; set; }
    }
}
