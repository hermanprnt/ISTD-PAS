using System;

namespace GPS.Common.Data
{
    [Serializable]
    public class CANCEL_GR_OUT
    {
        public string MATDOC_NUMBER { get; set; }
        public string MATDOC_YEAR { get; set; }
        public string REVMAT_NUMBER { get; set; }
        public string REVMAT_YEAR { get; set; }
        public string TYPE { get; set; }
        public string MESSAGE { get; set; }
    }
}
