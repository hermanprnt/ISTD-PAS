using System;
using System.Collections.Generic;
using Toyota.Common.Credential;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using System.Web.Mvc;
using GPS.Models.Master;
using GPS.Models.Home;
using GPS.CommonFunc;

namespace GPS.Models.ReceivingList
{
    public class GRApproval
    {
        public string MAT_DOC_NO { get; set; }
        public string PLANT_CD { get; set; }
        public string SLOC_CD { get; set; }
        public string HEADER_TEXT { get; set; }
        public string DIVISION_ID { get; set; }
        public string PR_COORDINATOR { get; set; }
        public string START_DOC_DATE { get; set; }
        public string END_DOC_DATE { get; set; }    
        public string USER_TYPE { get; set; }
        
        public DateTime? DOCUMENT_DT { get; set; }
        public string PO_NO { get; set; }
        public string VENDOR_CD { get; set; }
        public string VENDOR_NAME { get; set; }
        public string ITEM_CURRENCY { get; set; }
        public decimal AMOUNT { get; set; }
        public string STATUS { get; set; }

        public string CREATED_BY { get; set; }
        public DateTime CREATED_DT { get; set; }
        public string CHANGED_BY { get; set; }
        public DateTime? CHANGED_DT { get; set; }

        public string ATTACHMENT_DOC_PATH { get; set; }
        public string ATTACHMENT_DOC_FILE_NM { get; set; }
        public string OTHERS_ATTACHMENT_DOC_PATH { get; set; }
        public string OTHER_ATTACHMENT_DOC_FILE_NM { get; set; }

        public DateTime LastChange => CHANGED_DT ?? CREATED_DT;

        public string SURAT_JALAN_PATH {
            get
            {
                if (!System.IO.File.Exists(ATTACHMENT_DOC_PATH))
                    return string.Empty;
                return $"<a href='File/Download?file={ATTACHMENT_DOC_PATH}'>{ATTACHMENT_DOC_FILE_NM}</a>";
            }
        }
        public string OTHER_PATH { 
            get
            {
                if (!System.IO.File.Exists(OTHERS_ATTACHMENT_DOC_PATH))
                    return string.Empty;
                return $"<a href='File/Download?file={OTHERS_ATTACHMENT_DOC_PATH}'>{OTHER_ATTACHMENT_DOC_FILE_NM}</a>";
            }
        }

        public string SURAT_JALAN_PATH_ICON
        {
            get
            {
                if (!System.IO.File.Exists(ATTACHMENT_DOC_PATH))
                    return string.Empty;
                return $"<a href='File/Download?file={ATTACHMENT_DOC_PATH}' title=\"Surat Jalan File\"><i class=\"fa fa-paperclip\" aria-hidden=\"true\"></i></a>";
            }
        }

        public string OTHER_PATH_ICON
        {
            get
            {
                if (!System.IO.File.Exists(OTHERS_ATTACHMENT_DOC_PATH))
                    return string.Empty;
                return $"<a href='File/Download?file={OTHERS_ATTACHMENT_DOC_PATH}' title=\"Other File\"><i class=\"fa fa-paperclip\" aria-hidden=\"true\"></i></a>";
            }
        }

        public string DocDateDateRange { get; set; }

        public void ConvertDocDate()
        {
            if (string.IsNullOrEmpty(DocDateDateRange))
                return;

            var dateFromTo = DocDateDateRange.Split('-');
            if (dateFromTo.Length != 2)
                return;
            START_DOC_DATE = dateFromTo[0].Trim().FromStandardFormat().ToSqlCompatibleFormat();
            END_DOC_DATE = dateFromTo[1].Trim().FromStandardFormat().ToSqlCompatibleFormat();
        }

    }

    public class GRDetail
    {
        public string MAT_DOC_ITEM_NO { get; set; }

        public string MATERIAL_NO { get; set; }
        public string MATERIAL_DESCRIPTION { get; set; }
        public decimal? PO_QTY_ORI { get; set; }
        public decimal? MOVEMENT_QTY { get; set; }

        public string UNIT_OF_MEASURE_CD { get; set; }

        public decimal? GR_IR_AMOUNT { get; set; }

        public string PO_ITEM { get; set; }
    }
}