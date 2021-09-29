using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Common;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Master
{
    public class PaymentController : PageController
    {
        public static SelectList PaymentTermSelectList
        {
            get
            {
                return PaymentRepository.Instance
                    .GetAllPayTerm()
                    .AsSelectList(dt => dt.PAY_TERM_CD + " - " + dt.PAY_TERM_NAME, dt => dt.PAY_TERM_CD);
            }
        }

        public static SelectList PaymentMethodSelectList
        {
            get
            {
                return PaymentRepository.Instance
                    .GetAllPayMethod()
                    .AsSelectList(dt => dt.PAY_METHOD_CD + " - " + dt.PAY_METHOD_NAME, dt => dt.PAY_METHOD_CD);
            }
        }
    }
}
