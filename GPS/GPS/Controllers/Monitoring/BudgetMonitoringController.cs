using System.Web.Mvc;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Monitoring
{
    public class BudgetMonitoringController : PageController
    {
        public BudgetMonitoringController()
        {
            Settings.Title = "Budget Monitoring Screen";
        }

        public ActionResult submitOrder(string doc_no, string doc_year, string doc_status, string wbs_no, string amount) 
        {
            string message = "sukses";
            


            return Json(message, JsonRequestBehavior.AllowGet);
        }

    }
}
