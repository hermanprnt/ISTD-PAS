using System.Web.Mvc;
using GPS.Models.Common;
using GPS.Models.Home;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Home
{
    public class LogMonitoringController : PageController
    {
        protected override void Startup()
        {
            Settings.Title = "Log Monitoring";
            ViewData["Function"] = LogMonitoringRepository.Instance.GetLookupFunction();
            ViewData["Status"] = LogMonitoringRepository.Instance.GetLookupStatus();
            ViewData["CreatedBy"] = LogMonitoringRepository.Instance.GetLookupUser();
        }

        private void Calldata(int Display, int Page, string ProcDateFrom, string ProcDateTo, string FunctionName, string ProcessId, string Status, string User)
        {
            if (ProcDateFrom == "NULLSTATE") ProcDateFrom = "";
            if (ProcDateTo == "NULLSTATE") ProcDateTo = "";

            Paging pg = new Paging(LogMonitoringRepository.Instance.CountData(ProcDateFrom, ProcDateTo, FunctionName, ProcessId, Status, User), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["ListLog"] = LogMonitoringRepository.Instance.GetListData(ProcDateFrom, ProcDateTo, FunctionName, ProcessId, Status, User, pg.StartData, pg.EndData);
        }

        [HttpPost]
        public ActionResult SearchData(int Display, int Page, string ProcDateFrom, string ProcDateTo, string FunctionName, string ProcessId, string Status, string User)
        {
            Calldata(Display, Page, ProcDateFrom, ProcDateTo, FunctionName, ProcessId, Status, User);
            return PartialView("_Grid");
        }
    }
}