using System;

namespace GPS.Models.Asset
{
    public class AssetUpload
    {
        public Int16 NUMBER { get; set; }
        public Int16 SEQ_NO { get; set; }

        public string PR_NO { get; set; }
        public string DESCRIPTION { get; set; }
        public string STATUS_CD { get; set; }
        public string ITEM_NO { get; set; }
        public string ASSET_NO { get; set; }
        public string ASSET_CATEGORY { get; set; }
        public string ASSET_LOCATION { get; set; }
        public string SUBASSET_NO { get; set; }
        public string ASSET_CLASS { get; set; }
        public string VALID_FLAG { get; set; }
        public string SERIAL_NO { get; set; }
        public string REGISTRATION_DATE { get; set; }
        public string REGISTRATION_DATE_FROM { get; set; }
        public string REGISTRATION_DATE_TO { get; set; }

        public string PROCESS_ID { get; set; }
        public string PROCESS_STATUS { get; set; }
        public string MESSAGE { get; set; }

        public string CREATED_BY { get; set; } 
        public string CREATED_DT { get; set; }
        public string CHANGED_BY { get; set; }
        public string CHANGED_DT { get; set; }
    }
}