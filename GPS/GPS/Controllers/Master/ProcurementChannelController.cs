using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Master;

namespace GPS.Controllers.Master
{
    public class ProcurementChannelController
    {
        public static SelectList ProcurementChannelSelectList
        {
            get
            {
                return ProcurementChannelRepository.Instance
                    .GetProcurementChannelList()
                    .AsSelectList(pc => pc.PROC_CHANNEL_CD + " - " + pc.PROC_CHANNEL_DESC,
                        pc => pc.PROC_CHANNEL_CD);
            }
        }
    }
}