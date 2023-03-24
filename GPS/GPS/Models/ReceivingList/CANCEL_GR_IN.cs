using System;

namespace GPS.Common.Data
{
    [Serializable]
    public class CANCEL_GR_IN
    {
        public string MATDOC_NUMBER { get; set; }
        public string ENTRYSHEET_NUM { get; set; }
        public string MATDOC_YEAR { get; set; }
        public DateTime? MATDOC_DOCDATE { get; set; }
        public DateTime? MATDOC_POSTDATE { get; set; }
        public string MATDOC_TEXT { get; set; }
    }
}
