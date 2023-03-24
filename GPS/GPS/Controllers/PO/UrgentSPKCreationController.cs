using System;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.Constants.PO;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models.Common;
using GPS.Models.PO;
using GPS.ViewModels;
using GPS.ViewModels.PO;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.PO
{
    public class UrgentSPKCreationController : PageController
    {
        public sealed class Partial
        {
            public const String CreationSPKGrid = "_creationSPKGrid";
        }

        public sealed class Action
        {
            public const String Search = "/UrgentSPKCreation/Search";
            public const String ClearSearch = "/UrgentSPKCreation/ClearSearch";
            public const String Save = "/UrgentSPKCreation/Save";
            public const String Update = "/UrgentSPKCreation/Update";
            public const String DownloadSPKPdf = "/UrgentSPKCreation/DownloadSPKPdf";
            public const String GetSPKInfo = "/UrgentSPKCreation/GetSPKInfo";
            public const String GetVendorInfo = "/UrgentSPKCreation/GetVendorInfo";
        }

        private readonly UrgentSPKRepository creationRepo = new UrgentSPKRepository();

        protected override void Startup()
        {
            Settings.Title = "Urgent PO SPK Creation";

            Model = SearchEmpty();
        }

        private GenericViewModel<UrgentSPKViewModel> SearchEmpty()
        {
            var emptySearch = new UrgentSPKSearchViewModel { CurrentPage = 1, PageSize = PaginationViewModel.DefaultPageSize };
            var viewModel = new GenericViewModel<UrgentSPKViewModel>();
            viewModel.DataList = creationRepo.GetSearchList(emptySearch);
            viewModel.GridPaging = creationRepo.GetSearchListPaging(emptySearch);

            return viewModel;
        }

        [HttpPost]
        public ActionResult Search(UrgentSPKSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new GenericViewModel<UrgentSPKViewModel>();
                viewModel.DataList = creationRepo.GetSearchList(searchViewModel);
                viewModel.GridPaging = creationRepo.GetSearchListPaging(searchViewModel);

                return PartialView(Partial.CreationSPKGrid, viewModel);
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
                return PartialView(Partial.CreationSPKGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult Save(UrgentSPKSaveViewModel viewModel)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.CurrentRegNo = this.GetCurrentRegistrationNumber();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = viewModel.ProcessId;

                String spkNo = creationRepo.Save(execModel, viewModel);
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "SPK No: " + spkNo + " is saved successfully." });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult Update(UrgentSPKSaveViewModel viewModel)
        {
            try
            {
                var execModel = new ExecProcedureModel();
                execModel.CurrentUser = this.GetCurrentUsername();
                execModel.CurrentRegNo = this.GetCurrentRegistrationNumber();
                execModel.ModuleId = ModuleId.PurchaseOrder;
                execModel.FunctionId = FunctionId.POCreation;
                execModel.ProcessId = viewModel.ProcessId;

                String spkNo = creationRepo.Update(execModel, viewModel);
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "SPK No: " + spkNo + " is updated successfully." });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult GetSPKInfo(String prNo, String spkNo)
        {
            try
            {
                POSPKViewModel spk = creationRepo.GetSPKInfo(prNo, spkNo);
                return Json(new ActionResponseViewModel { Message = new JavaScriptSerializer().Serialize(spk), ResponseType = ActionResponseViewModel.Success });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public FileResult DownloadSPKPdf(String prNo, String spkNo)
        {
            var pdfCreator = new PdfFileCreator();
            var docNoList = new String[] {prNo, spkNo};
            String combinedDocNo = String.Join(CommonFormat.ItemDelimiter.ToString(), prNo, spkNo);
            PdfFileCreator.FileInfo fileInfo = pdfCreator.GetPdfFileInfo(
                    (new POCommonRepository()).GetDocumentBasePath(),
                    Server.MapPath(ReportPath.SPKDocument),
                    POPdfFilenamePrefix.SPK,
                    docNoList,
                    () => (new UrgentSPKRepository()).GetSPKPdfDataTableList(combinedDocNo));

            return File(fileInfo.FileByteArray, fileInfo.MimeType, fileInfo.Filename);
        }

        [HttpPost]
        public ActionResult GetVendorInfo(String vendorCode)
        {
            try
            {
                SPKVendorViewModel vendor = creationRepo.GetVendorInfo(vendorCode);
                return Json(new ActionResponseViewModel { Message = new JavaScriptSerializer().Serialize(vendor), ResponseType = ActionResponseViewModel.Success });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
    }
}
