using System;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Master;

namespace GPS.Controllers.Master
{
    public class DocStatusController
    {
        public static SelectList GetDocStatusSelectList(String docType)
        {
            return DocStatusRepository.Instance
                .GetDocStatusList(docType)
                .AsSelectList(status => status.STATUS_CD + " - " + status.STATUS_DESC, status => status.STATUS_CD);

        }
        public static SelectList GetDocStatusSelectListPrInq(String docType)
        {
            return DocStatusRepository.Instance
                .GetDocStatusListPrInq(docType)
                .AsSelectList(status => status.STATUS_CD + " - " + status.STATUS_DESC, status => status.STATUS_CD);
        }
    }
}