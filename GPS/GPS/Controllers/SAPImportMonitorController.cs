using System;
using System.Collections.Generic;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models.SAPImportMonitor;
using GPS.ViewModels;
using GPS.ViewModels.SAPImportMonitor;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers
{
    public class SAPImportMonitorController : PageController
    {
        private readonly SAPImportMonitorRepository monitorRepo = new SAPImportMonitorRepository();
        public sealed class Partial
        {
            public const String Grid = "_monitorGrid";
        }

        public sealed class Action
        {
            public const String Search = "/SAPImportMonitor/Search";
            public const String ClearSearch = "/SAPImportMonitor/ClearSearch";
        }

        protected override void Startup()
        {
            Settings.Title = "SAP Import Monitor";
            Model = SearchEmpty();
        }

        public static SelectList StatusSelectList
        {
            get
            {
                var statusList = new List<NameValueItem>();
                statusList.Add(new NameValueItem("Initial", "0"));
                statusList.Add(new NameValueItem("On Progress", "1"));
                statusList.Add(new NameValueItem("Finish", "2"));
                statusList.Add(new NameValueItem("Finish with error", "3"));

                return statusList.AsSelectList(st => st.Value + " - " + st.Name, st => st.Value);
            }
        }

        [HttpPost]
        public ActionResult Search(SAPImportMonitorSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new SAPImportMonitorViewModel();
                viewModel.CurrentUser = this.GetCurrentUser();
                viewModel.DataList = new List<SAPImportMonitor>(monitorRepo.GetList(searchViewModel));
                viewModel.GridPaging = monitorRepo.GetListPaging(searchViewModel);

                return PartialView(Partial.Grid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        private SAPImportMonitorViewModel SearchEmpty()
        {
            var viewModel = new SAPImportMonitorViewModel();
            viewModel.CurrentUser = this.GetCurrentUser();
            viewModel.DataList = new List<SAPImportMonitor>();
            viewModel.GridPaging = PaginationViewModel.GetDefault(SAPImportMonitorRepository.DataName);

            return viewModel;
        }

        [HttpPost]
        public ActionResult ClearSearch()
        {
            try
            {
                SAPImportMonitorViewModel viewModel = SearchEmpty();
                return PartialView(Partial.Grid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
    }
}
