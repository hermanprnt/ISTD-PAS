using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Constants.MRP;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models.Common;
using GPS.Models.MRP;
using GPS.ViewModels;
using GPS.ViewModels.MRP;
using Toyota.Common.Web.Platform;
using NameValueItem = GPS.Models.Common.NameValueItem;

namespace GPS.Controllers.MRP
{
    public class MRPCreationController : PageController
    {
        protected override void Startup()
        {
            Settings.Title = "Material Resource Planning Creation";

            var viewModel = new MRPCreationViewModel();
            viewModel.ProcessId = MRPCreationRepository.Instance.Initial(this.GetCurrentUsername());
            viewModel.ProcUsageGroup = MRPCommonRepository.Instance.GetProcurementUsageGroupList().ToList();

            Model = viewModel;
            //CallData("x","x",1,0);
        }
        public ActionResult CallData(string ProcUsage, int Page, int Display)
        {
            Paging pg = new Paging(MRPCreationRepository.Instance.CountData(ProcUsage), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["ListMRPProcess"] = MRPCreationRepository.Instance.GetListData(pg.StartData, pg.EndData);
            return PartialView("_MRPGrid");
        }
        [HttpPost]
        public ActionResult MRPCheck(String procUsageGroup)
        {
            try
            {
                LastMRPInfo info = MRPCreationRepository.Instance.GetLastMRPInfo(procUsageGroup) ?? new LastMRPInfo();

                var viewModel = new ProcUsageGroupCheckViewModel();
                viewModel.MRPMonth = CreateMRPMonthDropdownList(info.LastMRPMonth);
                viewModel.LastPOApproval = info.LastPOApproval.ToStandardFormat();
                viewModel.LastMRPCreated = info.LastMRPCreated.ToStandardFormat();
                if (!String.IsNullOrEmpty(info.LastMRPMonth))
                    viewModel.LastMRPMonth = CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(Convert.ToInt32(info.LastMRPMonth.Substring(0, 2)));

                /*throw new InvalidOperationException("Error when checking");*/

                return PartialView(MRPPage.CreationMRPCheckPartial, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());    
            }
        }

        private DropdownListViewModel CreateMRPMonthDropdownList(String lastMRPMonth)
        {
            var mrpMonthList = new List<NameValueItem>();
            Int32 currentMonth = DateTime.Now.Month;
            Int32 currentYear = DateTime.Now.Year;

            if (!String.IsNullOrEmpty(lastMRPMonth))
                mrpMonthList.Add(new NameValueItem(
                    "Revision - " + CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(Convert.ToInt32(lastMRPMonth.Substring(0, 2))),
                        MRPProcessType.Revision.ToString()));

            mrpMonthList.Add(new NameValueItem(
                "New - " + CultureInfo.CurrentCulture.DateTimeFormat.GetAbbreviatedMonthName(currentMonth),
                    MRPProcessType.New.ToString()));

            var viewModel = new DropdownListViewModel();
            viewModel.DataName = "mrpmonth";
            viewModel.DataList = mrpMonthList.AsSelectList(month => month.Name, month => month.Value );
            viewModel.EmbeddedDataList = mrpMonthList.Select(month => new NameValueItem(month.Value, String.IsNullOrEmpty(lastMRPMonth) ? GetCurrentMRPMonth(currentMonth) + currentYear.ToString() : lastMRPMonth + currentYear.ToString()));

            return viewModel;
        }

        private String GetCurrentMRPMonth(Int32 currentMonth)
        {
            return currentMonth.ToString().PadLeft(2, '0') + "-" + DateTime.Now.Year;
        }

        [HttpPost]
        public ActionResult MRPProcess(MRPProcessViewModel viewModel)
        {
            try
            {
                viewModel.CurrentUser = this.GetCurrentUsername();
                MRPCreationRepository.Instance.PutMRPProcessToQueue(viewModel);
                String responseMessage = String.Format("{0} {1} is processed with Process Id: {2}.",
                    viewModel.ProcessType == MRPProcessType.New ? "New MRP " : "MRP Revision ", viewModel.MRPMonth, viewModel.ProcessId);

                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = responseMessage });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
    }
}