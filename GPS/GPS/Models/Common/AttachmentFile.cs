using System;

namespace GPS.Models.Common
{
    public class AttachmentFile
    {
        public int NO { get; set; }
        public int DOCUMENT_ID { get; set; }
        public string DOC_TYPE { get; set; }
        public string FILE_NAME { get; set; }
        public string FILE_NAME_ORI { get; set; }
        public string FILE_TYPE { get; set; }
        public string FILE_DESC { get; set; }
        public string FILE_EXTENSION { get; set; }
        public string IMG_FILE_EXTENSION { get; set; }
        public int FILE_SIZE { get; set; }
        public string FILE_SIZE_STR { get; set; }
        public string CREATED_BY { get; set; }
        public DateTime CREATED_DT { get; set; }
    }
}