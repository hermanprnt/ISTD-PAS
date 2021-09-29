namespace GPS.Models.Common
{
    public class Attachment
    {
        public string DOC_NO { get; set; }
        public string DOC_SOURCE { get; set; }
        public string SEQ_NO { get; set; }
        public string DOC_TYPE { get; set; }
        public string FILE_PATH { get; set; }
        public string FILE_NAME_ORI { get; set; }
        public string DOC_YEAR { get; set; }
        //added : 20190528 : isid.rgl : PR_NO
        public string PR_NO { get; set; }
        public string PROCESS_ID { get; set; }
        //ended : 20190528 : isid.rgl : PR_NO
    }
}