using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using GPS.Constants.MRP;
using GPS.Core;
using GPS.Models.MRP;
using GPS.ViewModels.MRP;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.MRP
{
    public class MRPInquiryController : PageController
    {
        protected override void Startup()
        {
            Settings.Title = "Material Resource Planning Result Inquiry";
            Model = SearchEmpty();

        }

        public void CallData()
        {
 
        }

        private MRPInquiryViewModel SearchEmpty()
        {
            var viewModel = new MRPInquiryViewModel();
            //viewModel.CurrentUser = //this.GetCurrentUser();
            viewModel.ProcurementUsageGroup = MRPCommonRepository.Instance.GetProcurementUsageGroupList().ToList();
            viewModel.DataList = new List<MaterialResourcePlanning>();
            //viewModel.GridPaging = new GridPagingViewModel { Id = "mrp", CurrentPage = 1, PageSize = GridPagingViewModel.DefaultPageSize(), TotalDataCount = 0 };
            return viewModel;
        }

        [HttpPost]
        public ActionResult Search(MRPSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new MRPInquiryViewModel();
                //viewModel.CurrentUser = //this.GetCurrentUser();
                viewModel.ProcurementUsageGroup = MRPCommonRepository.Instance.GetProcurementUsageGroupList().ToList();
                viewModel.DataList = new List<MaterialResourcePlanning>(MRPInquiryRepository.Instance.GetMRPList(searchViewModel));
                //viewModel.GridPaging = new GridPagingViewModel { Id = "mrp", CurrentPage = 1, PageSize = GridPagingViewModel.DefaultPageSize(), TotalDataCount = 0 };

                return PartialView(MRPPage.InquiryGridPartial, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult ClearSearch()
        {
            try
            {
                var viewModel = SearchEmpty();
                return PartialView(MRPPage.InquiryGridPartial, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult GetMRP(String procUsageGroup, String mrpMonth)
        {
            try
            {
                var mrp = MRPInquiryRepository.Instance.GetMRP(procUsageGroup, mrpMonth);
                var mrpItemList = MRPInquiryRepository.Instance.GetMRPItemList(procUsageGroup, mrpMonth);
                var viewModel = new MRPGetViewModel();
                viewModel.ProcUsageGroupCode = procUsageGroup;
                viewModel.MRPMonth = mrp.MRPMonth;
                viewModel.PRNo = mrp.PRNo;
                viewModel.Status = mrp.Status;
                viewModel.DataList = new List<MRPItem>(mrpItemList);
                //viewModel.GridPaging = new GridPagingViewModel { Id = "mrpget", CurrentPage = 1, PageSize = GridPagingViewModel.DefaultPageSize(), TotalDataCount = 0 };
                return PartialView(MRPPage.InquiryGetPartial, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
    }
}