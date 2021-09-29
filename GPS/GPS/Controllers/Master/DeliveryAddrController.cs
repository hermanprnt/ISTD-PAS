using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Master;

namespace GPS.Controllers.Master
{
    public class DeliveryAddrController : Controller
    {
        public static SelectList DeliveryAddrSelectList
        {
            get
            {
                return DeliveryAddrRepository.Instance
                    .GetDeliveryAddrList()
                    .AsSelectList(addr => addr.Address, addr => addr.DeliveryAddress);
            }
        }
    }
}
