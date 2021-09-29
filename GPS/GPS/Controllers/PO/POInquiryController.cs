using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.Constants.PO;
using GPS.Controllers.Master;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models.Common;
using GPS.Models.PO;
using GPS.ViewModels;
using GPS.ViewModels.PO;
using NPOI.HSSF.UserModel;
using GPS.Models;
using System.Globalization;
using NPOI.SS.UserModel;
using NPOI.HSSF.Util;
using GPS.CommonFunc.WebControl;
using iTextSharp.text;
using iTextSharp.text.pdf;
using System.Diagnostics;
using GPS.Models.PRPOApproval;

namespace GPS.Controllers.PO
{
    // NOTE: inherit from POCommon because POCommon is not registered in SC and won't registered ever :'(
    public class POInquiryController : POCommonController
    {
        private readonly POApprovalRepository approvalRepo = new POApprovalRepository();
        public new sealed class Partial
        {
            public const String InquiryGrid = "_inquiryGrid";
            public const String InquiryGridBody = "_inquiryGridBody";
            public const String InquiryGetPO = "_inquiryGetPO";
            public const String InquiryApproval = "_inquiryApproval";
            public const String InquiryCancel = "_inquiryPopupCancel";
            public const String InquiryTriggerPO = "_inquiryPopupTriggerPO";
            public const String CancelReasonPopup = "_PartialInquiryCancelReasonPopup";
            public const String WorklistHistory = "_PartialWorklistHistoryGrid";
            public const String InquiryNotice = "_Notice";
            public const String InquiryNoticeMesssage = "_NoticeMessage";
        }

        public sealed class Action
        {
            public const String Index = "/POInquiry";
            public const String Cancel = "/POInquiry/Cancel";
            public const String Search = "/POInquiry/Search";
            public const String SortSearch = "/POInquiry/SortSearch";
            public const String ClearSearch = "/POInquiry/ClearSearch";
            public const String GetByNo = "/POInquiry/GetByNo";
            public const String IsReleased = "/POInquiry/IsReleased";
            public const String DownloadPdf = "/POInquiry/DownloadPdf";
            public const String DownloadSPKPdf = "/POInquiry/DownloadSPKPdf";
            public const String POSearchSubItem = "/POInquiry/SearchSubItem";
            public const String GetVendorList = "/POInquiry/GetVendorList";
            public const String GetUserVendor = "POInquiry/GetUserVendor";
            public const String UnlockPO = "/POInquiry/UnlockPO";
            public const String RejectByVendor = "/POInquiry/RejectByVendor";
            public const String RejectItemByVendor = "/POInquiry/RejectItemByVendor";

            // NOTE: exist in POCommon
            public const String CheckEmployee = "/POInquiry/IsEmployee";
            public const String SearchItem = "/POInquiry/POItemSearch";
            public const String RefreshItemMaterialList = "/POInquiry/RefreshItemMaterialList";
            public const String GetItemConditionList = "/POInquiry/GetPOItemConditionList";
            public const String GetComponentPriceList = "/POInquiry/GetComponentPriceList";
            public const String OpenVendorLookup = "/POInquiry/OpenVendorLookup";
            public const String SearchVendorLookup = "/POInquiry/SearchVendorLookup";
            public const String DownloadHeader = "/POInquiry/DownloadHeader";
            public const String _forceGeneratePO = "/POInquiry/ForceGeneratePO";
            public const String GetGeneratePROutstanding = "/POInquiry/GetGeneratePROutstanding";
            public const String GetPRMonitoringOutstanding = "/POInquiry/GetPRMonitoringOutstanding";
            public const String GetPOMonitoring = "/POInquiry/GetPOMonitoring";
            public const String _hasJobPOCompleted = "/POInquiry/HasJobPOCompleted";

            public const String Error_PO = "/POInquiry/errorPosting";//20200129
        }

        private readonly POInquiryRepository inquiryRepo = new POInquiryRepository();

        protected override void Startup()
        {
            Settings.Title = "Purchase Order Inquiry";
            ViewData["UserNoreg"] = this.GetCurrentRegistrationNumber();
            ViewData["UserProcChannel"] = Models.Master.ProcurementChannelRepository.Instance.GetProcurementChannelList(this.GetCurrentRegistrationNumber()).ToList();
            
            if (Session[POCreationController.PONoSaveSessionKey] == null)
                Model = SearchEmpty();
            else
            {
                String poNo = Session[POCreationController.PONoSaveSessionKey].ToString();
                Session.Remove(POCreationController.PONoSaveSessionKey);
                PurchaseOrderSearchViewModel searchViewModel = GetSearchingparameter(poNo);

                var viewModel = new POInquiryViewModel();
                viewModel.CurrentUser = this.GetCurrentUser();
                viewModel.DataList = new List<PurchaseOrder>(inquiryRepo.GetList(searchViewModel)); 
                viewModel.GridPaging = inquiryRepo.GetListPaging(searchViewModel);
                viewModel.ItemDataName = POCommonRepository.POItemDataName;
                viewModel.SubItemDataName = POCommonRepository.SubItemDataName;

                Model = viewModel;
            }
        }

        private PurchaseOrderSearchViewModel GetSearchingparameter(string poNo)
        {
            PurchaseOrderSearchViewModel searchViewModel;
            searchViewModel = new PurchaseOrderSearchViewModel { PONo = poNo, CurrentPage = 1, PageSize = PaginationViewModel.DefaultPageSize };
            searchViewModel.FixDateFromAndTo();
            return searchViewModel;
        }

        public string IsEmployee(string noreg)
        {
            var result =  inquiryRepo.IsEmployee(noreg);

            if (result == "FALSE")
            {
                var getRoleAdminList = SystemRepository.Instance.GetByFunctionId("ADROLE");
                var currentUser = this.GetCurrentUser();

                var isAdmin = false;
                foreach (var item in getRoleAdminList)
                {
                    isAdmin = currentUser.Roles.Where(x => x.Id == item.Value).Count() > 0;
                    if (isAdmin)
                        return "TRUE";
                }
            }

            return result;
        }

        // NOTE: <ActionName>Empty could means 2 action.
        // 1. action returning partial with empty data.
        // 2. action with empty logic, like redirecting to other page.
        private POInquiryViewModel SearchEmpty()
        {
            var viewModel = new POInquiryViewModel();
            viewModel.CurrentUser = this.GetCurrentUser();
            viewModel.DataList = new List<PurchaseOrder>();
            viewModel.GridPaging = PaginationViewModel.GetDefault(POCommonRepository.DataName);
            viewModel.ItemDataName = POCommonRepository.POItemDataName;
            viewModel.SubItemDataName = POCommonRepository.SubItemDataName;

            return viewModel;
        }

        [HttpPost]
        public ActionResult Search(PurchaseOrderSearchViewModel searchViewModel)
        {
            try
            {
                searchViewModel.FixDateFromAndTo();

                var viewModel = new POInquiryViewModel();
                viewModel.CurrentUser = this.GetCurrentUser();
                viewModel.DataList = new List<PurchaseOrder>(inquiryRepo.GetList(searchViewModel));
                viewModel.GridPaging = inquiryRepo.GetListPaging(searchViewModel);
                viewModel.ItemDataName = POCommonRepository.POItemDataName;
                viewModel.SubItemDataName = POCommonRepository.SubItemDataName;

                return PartialView(Partial.InquiryGrid, viewModel);
            }
            catch (Exception ex)
            { 
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult SortSearch(PurchaseOrderSearchViewModel searchViewModel)
        {
            try
            {
                searchViewModel.FixDateFromAndTo();

                var viewModel = new POInquiryViewModel();
                viewModel.CurrentUser = this.GetCurrentUser();
                viewModel.DataList = new List<PurchaseOrder>(inquiryRepo.GetList(searchViewModel));
                viewModel.GridPaging = inquiryRepo.GetListPaging(searchViewModel);
                viewModel.ItemDataName = POCommonRepository.POItemDataName;
                viewModel.SubItemDataName = POCommonRepository.SubItemDataName;

                return PartialView(Partial.InquiryGridBody, viewModel);
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
                return PartialView(Partial.InquiryGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult Cancel(PurchaseOrderSearchViewModel searchViewModel, String poNo, String cancelReason)
        {
            try
            {
                var execParam = new ExecProcedureModel();
                execParam.CurrentUser = this.GetCurrentUsername();
                execParam.ModuleId = ModuleId.PurchaseOrder;
                execParam.FunctionId = FunctionId.POCreation;

                var result = inquiryRepo.CancelValidation(execParam, poNo);
                //if (result.ResponseType == ActionResponseViewModel.Success)
                //{
                    inquiryRepo.Cancel(execParam, poNo, cancelReason);
                //}
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "PO " + poNo + " is canceled." });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult GetByNo(String poNo)
        {
            try
            {
                var viewModel = new POCreationViewModel();
                viewModel.CurrentUser = this.GetCurrentUser();
                
				  //start : 20190716 : isid.rgl
                //viewModel.Header = inquiryRepo.GetByNo(poNo);
                viewModel.Header = inquiryRepo.GetByNo(poNo, this.GetCurrentRegistrationNumber());
                //end : 20190716 : isid.rgl
                ViewData["CheckDocNoShow"] = poNo;

                var attachmentRepo = new AttachmentRepository();
                IList<Attachment> allAttachment = attachmentRepo.GetAllData(poNo);
                viewModel.AttachmentList = allAttachment.Where(att => att.DOC_TYPE == "BID").ToList();
                viewModel.QuotationList = allAttachment.Where(att => att.DOC_TYPE == "QUOT").ToList();

                var itemList = new PRItemAdoptResultViewModel();
                itemList.CurrentUser = this.GetCurrentUser();
                itemList.DataList = inquiryRepo.GetPOItemSearchList(poNo, 1, PaginationViewModel.DefaultPageSize);
                itemList.GridPaging = PaginationViewModel.GetDefault(POCommonRepository.POItemDataName);
                viewModel.ItemList = itemList;

                viewModel.POItemDataName = POCommonRepository.POItemDataName;
                viewModel.SubItemDataName = POCommonRepository.SubItemDataName;
                viewModel.ItemConditionDataName = POCommonRepository.ItemConditionDataName;

                var approvalList = new GenericViewModel<POApprovalInfoViewModel>();
                approvalList.DataList = new List<POApprovalInfoViewModel>(inquiryRepo.GetApprovalList(poNo));
                approvalList.GridPaging = new PaginationViewModel {DataName = POInquiryRepository.ApprovalDataName};
                viewModel.ApprovalList = approvalList;

                var approvalhistory = new GenericViewModel<PurchaseOrderApprovalHistory>();
                approvalhistory.DataList = new List<PurchaseOrderApprovalHistory>(inquiryRepo.GetApprovalHistory(poNo));
                approvalhistory.GridPaging = new PaginationViewModel { DataName = POInquiryRepository.ApprovalDataName };
                viewModel.ApprovalHistory = approvalhistory;

                ViewData["PoCancelStatus"] = SystemRepository.Instance.GetSystemValue("PO_CANCEL_STS");
                BindPOApprovalNotice(poNo);
                BindPOApprovalNoticeUser(poNo);
                //BindPOApprovalNotice(docNo, showNotice);

                return PartialView(Partial.InquiryGetPO, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpGet]
        public FileResult DownloadAttachment(String docNo, String docSource, String fileName, String fileNameOri, String docYear)
        {
            try
            {
                String filePath = Path.GetFullPath(commonRepo.GetDocumentBasePath() + "\\" + docYear + "\\" + docNo);
                String mimeType = "image/" + Path.GetExtension(fileName).Replace(".", "");
                Byte[] result = FileManager.ReadFile(filePath, fileName);
                return File(result, mimeType, fileNameOri);
            }
            catch (Exception ex)
            {
                var errorFile = PdfFileCreator.GenerateErrorInfoTextFile(ex);
                return File(errorFile.FileByteArray, errorFile.MimeType, errorFile.Filename);
            }
        }

        [HttpGet]
        public FileResult DownloadPdf(String poNo, String poDate)
        {
            try
            {
                var pdfCreator = new PdfFileCreator();
                var docNoList = new String[] { poNo };

                var addressPoList = inquiryRepo.GetPdfAddressList(poNo);
                List<byte[]> listFile = new List<byte[]>();
                PdfFileCreator.FileInfo fileInfoMain = new PdfFileCreator.FileInfo();

                string plan_code = "";
                foreach (var address in addressPoList)
                {
                    plan_code = plan_code + (plan_code.Length<=0?"":", ") + address.Code;
                    PdfFileCreator.FileInfo fileInfo = pdfCreator.GetPdfFileInfo(
                        commonRepo.GetDocumentBasePath() + "\\" + poDate,
                        Server.MapPath(ReportPath.POLetter),
                        POPdfFilenamePrefix.POLetter,
                        docNoList,
                        () => (new POInquiryRepository()).GetPdfDataTableList(poNo, AppDomain.CurrentDomain.BaseDirectory, address.Value, plan_code));

                    fileInfoMain = fileInfo;
                    listFile.Add(fileInfo.FileByteArray);
                }

                inquiryRepo.UpdateLastDownloadingUser(this.GetCurrentUsername(), poNo);
                var pdfMerger = MergeFiles(listFile); 
                return File(pdfMerger, fileInfoMain.MimeType, fileInfoMain.Filename);
            }
            catch (Exception ex)
            {
                var errorFile = PdfFileCreator.GenerateErrorInfoTextFile(ex);
                return File(errorFile.FileByteArray, errorFile.MimeType, errorFile.Filename);
            }
        }

        private byte[] MergeFiles(List<byte[]> sourceFiles)
        {
            Document document = new Document();
            using (MemoryStream ms = new MemoryStream())
            {
                PdfCopy copy = new PdfCopy(document, ms);
                document.Open();
                int documentPageCounter = 0;
                int documentPageTotal = GetTotalPage(sourceFiles);

                for (int fileCounter = 0; fileCounter < sourceFiles.Count; fileCounter++)
                {
                    PdfReader reader = new PdfReader(sourceFiles[fileCounter]);
                    int numberOfPages = reader.NumberOfPages;

                    for (int currentPageIndex = 1; currentPageIndex <= numberOfPages; currentPageIndex++)
                    {
                        documentPageCounter++;

                        PdfImportedPage importPage = copy.GetImportedPage(reader, currentPageIndex);
                        PdfCopy.PageStamp pageStamp = copy.CreatePageStamp(importPage);

                        //Draw White retangle page info
                        //if(currentPageIndex == 1)
                        //{
                        //    DrawRetangle(pageStamp, 590f, importPage.Height - 65, 80f, 10f);
                        //}
                        //else
                        //{
                            DrawRetangle(pageStamp, 710f, importPage.Height - 65, 80f, 10f);
                        //}

                        if (currentPageIndex == 1 && documentPageCounter>1)
                        {
                            DrawRetangle(pageStamp, 26f, importPage.Height - 98, 150f, 18f);
                            DrawRetangle(pageStamp, 26f, importPage.Height-230, 390f, 125f);
                            DrawRetangle(pageStamp, 26f, 58f, importPage.Width - 65, 90f);
                        }



                        //re-Write page info
                        float fntSize, lineSpacing;
                        fntSize = 9.2f;
                        lineSpacing = 10f;
                        string page_string = GeneratepageInfo(documentPageTotal, documentPageCounter);
                        //if (currentPageIndex == 1)
                        //{
                        //    ColumnText.ShowTextAligned(pageStamp.GetOverContent(), Element.ALIGN_CENTER, new Phrase(lineSpacing, page_string, FontFactory.GetFont(FontFactory.COURIER, fntSize)), (importPage.Width / 2) + 205, importPage.Height - 63, importPage.Width < importPage.Height ? 0 : 1);
                        //}
                        //else
                        //{
                            ColumnText.ShowTextAligned(pageStamp.GetOverContent(), Element.ALIGN_CENTER, new Phrase(lineSpacing, page_string, FontFactory.GetFont(FontFactory.COURIER, fntSize)), (importPage.Width / 2) + 315, importPage.Height - 63, importPage.Width < importPage.Height ? 0 : 1);
                        //}
                        
                        //ColumnText.ShowTextAligned(pageStamp.GetOverContent(), Element.ALIGN_CENTER, new Phrase(string.Format("Page {0}", documentPageCounter)), importPage.Width/2,30,importPage.Width<importPage.Height?0:1);

                        pageStamp.AlterContents();

                        copy.AddPage(importPage);
                    }

                    copy.FreeReader(reader);
                    reader.Close();
                }

                document.Close();

                return ms.GetBuffer();
            }
        }

        private static void DrawRetangle(PdfCopy.PageStamp pageStamp, float x, float y, float width, float height )
        {
            //Draw White retangle
            PdfContentByte cb = pageStamp.GetOverContent();

            cb.SaveState();
            cb.SetRGBColorFill(0xFF, 0xFF, 0xFF);
            cb.SetColorStroke(BaseColor.BLACK);
            cb.Rectangle(x, y, width, height);
            cb.Fill();
            cb.Stroke();
            cb.RestoreState();
        }

        private static int GetTotalPage(List<byte[]> sourceFiles)
        {
            int documentPageTotal = 0;

            for (int fileCounter = 0; fileCounter < sourceFiles.Count; fileCounter++)
            {
                PdfReader reader = new PdfReader(sourceFiles[fileCounter]);
                documentPageTotal = documentPageTotal + reader.NumberOfPages;
            }

            return documentPageTotal;
        }

        private static string GeneratepageInfo(int numberOfPages, int currentPageIndex)
        {
            string page_string = "", current_page = "", total_page = "";
            current_page = currentPageIndex.ToString().PadRight(3, ' ');
            total_page = numberOfPages.ToString().PadLeft(3, ' ');
            page_string = current_page + "of" + total_page;
            return page_string;
        }

        [HttpGet]
        public FileResult DownloadSPKPdf(String poNo, String poDate)
        {
            try
            {
                var pdfCreator = new PdfFileCreator();
                var docNoList = new String[] { poNo };
                PdfFileCreator.FileInfo fileInfo = pdfCreator.GetPdfFileInfo(
                    commonRepo.GetDocumentBasePath() + "\\" + poDate,
                    Server.MapPath(ReportPath.SPKDocument),
                    POPdfFilenamePrefix.SPK,
                    docNoList,
                    () => (new POInquiryRepository()).GetSPKPdfDataTableList(poNo));

                return File(fileInfo.FileByteArray, fileInfo.MimeType, fileInfo.Filename);
            }
            catch (Exception ex)
            {
                var errorFile = PdfFileCreator.GenerateErrorInfoTextFile(ex);
                return File(errorFile.FileByteArray, errorFile.MimeType, errorFile.Filename);
            }
        }

        [HttpPost]
        public ActionResult SearchSubItem(PRPOSubItemSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new GenericViewModel<PRPOSubItem>();
                viewModel.CurrentUser = this.GetCurrentUser();
                viewModel.DataList = inquiryRepo.GetPOSubItemSearchList(searchViewModel).ToList();
                viewModel.GridPaging = new PaginationViewModel {DataName = searchViewModel.DataName};

                return PartialView(POCommonController.Partial.CommonSubItemGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public string UnlockPO(string PONo)
        {
            try
            {
                return inquiryRepo.UnlockPO(PONo, this.GetCurrentUsername());
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }
        
        [HttpPost]
        public ActionResult GetVendorList()
        {
            var vc = new VendorController();
            return vc.GetVendorList();
        }

        [HttpPost]
        public ActionResult GetUserVendor(string vendor)
        {
            var vc = new VendorController();
            return vc.GetUserVendor(vendor);
        }

        public void DownloadHeader(PurchaseOrderSearchViewModel searchViewModel)
        {
            CommonDownload downloadEngine = CommonDownload.Instance;
            FixingSearchModelParam(searchViewModel);
            string FileName = string.Format("PO {0:dd-MM-yyyy}.xls", DateTime.Now);
            string filePath = HttpContext.Request.MapPath(downloadEngine.GetServerFilePath("PODownloadTemplete.xls"));
            FileStream ftmp = new FileStream(filePath, FileMode.Open, FileAccess.Read);
            var workbook = new HSSFWorkbook(ftmp);
            var dataListPO = new List<PurchaseOrder>(inquiryRepo.GetList(searchViewModel));

            ISheet sheet;IRow Hrow;int row = 1;
            
            IFont font = downloadEngine.GenerateFontExcel(workbook);
            ICellStyle styleCenter = downloadEngine.GenerateStyleCenter(workbook, font);
            ICellStyle styleLeft = downloadEngine.GenerateStyleLeft(workbook, font);
            ICellStyle styleNormal = downloadEngine.GenerateStyleNormal(workbook, font);

            sheet = workbook.GetSheetAt(0);

            foreach (PurchaseOrder item in dataListPO)
            {
                Hrow = sheet.CreateRow(row);
                downloadEngine.WriteCellValue(Hrow,0, styleNormal, item.DataNo);
                downloadEngine.WriteCellValue(Hrow, 1, styleNormal, item.PONo);
                downloadEngine.WriteCellValue(Hrow, 2, styleCenter, item.IsHaveAttachment ? "Yes" : "No");
                downloadEngine.WriteCellValue(Hrow, 3, styleNormal, item.POHeaderText);
                downloadEngine.WriteCellValue(Hrow, 4, styleCenter, string.Format("{0:yyyy-MM-dd}", item.PODate));
                downloadEngine.WriteCellValue(Hrow,5, styleCenter, item.PurchasingGroup);
                downloadEngine.WriteCellValue(Hrow, 6, styleNormal, item.Vendor);
                downloadEngine.WriteCellValue(Hrow, 7, styleCenter, item.Currency);
                downloadEngine.WriteCellValue(Hrow, 8, styleNormal, double.Parse(item.Amount.ToString()));
                downloadEngine.WriteCellValue(Hrow, 9, styleNormal, item.POStatus);
                downloadEngine.WriteCellValue(Hrow, 10, styleCenter, item.HasSPK ? "Yes" : "No");
                downloadEngine.WriteCellValue(Hrow, 11, styleCenter, item.POStatusCode == POStatus.Posting || item.POStatusCode == POStatus.Released ? "Yes" : "No");
                row++;
            }

            CreateExcelFile(FileName, ftmp, workbook);

        }

        [HttpPost]
        public ActionResult RejectByVendor(String poNo)
        {
            try
            {
                inquiryRepo.RejectByVendor(poNo, this.GetCurrentUsername());
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "PO " + poNo + " is rejected." });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult RejectItemByVendor(String poNo, string poItem)
        {
            try
            {
                inquiryRepo.RejectItemByVendor(poNo, poItem, this.GetCurrentUsername());
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "PO " + poNo + " is rejected." });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        #region Force Generate PO 
        public ActionResult ForceGeneratePO()
        {
            try
            {
                var Result = inquiryRepo.ForceGeneratePObyJob(this.GetCurrentUsername(), this.GetCurrentRegistrationNumber());

                return new JsonResult() { Data = new { ResultType = "S", Content = new { Process_Id = Result } }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
            }
            catch (Exception ex)
            {
                return new JsonResult() { Data = new { ResultType = "E", Content = "Error:" + ex.Message }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
            }
        }

        public ActionResult HasJobPOCompleted(string Process_Id)
        {
            try
            {
                var finishFlag = inquiryRepo.isJobGeneratePO_Finished(Process_Id)?1:0 ;

                return new JsonResult() { Data = new { ResultType = "S", Content = new { Job_completed = finishFlag } }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
            }
            catch (Exception ex)
            {
                return new JsonResult() { Data = new { ResultType = "E", Content = "Error:" + ex.Message }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
            }
        }

        //public ActionResult ForceGeneratePO()
        //{
        //    try
        //    {
        //        var Result = inquiryRepo.ForceGeneratePObyJob(this.GetCurrentUsername(), this.GetCurrentRegistrationNumber());
        //        var dataSystem = SystemRepository.Instance.GetSingleData("00000", "WAIT_TIME");
        //        var waitSecond = 180;
        //        if (dataSystem != null)
        //            waitSecond = Int32.Parse(dataSystem.Value);

        //        bool finishFlag = false;
        //        Stopwatch s = new Stopwatch();
        //        s.Start();
        //        while (!finishFlag && s.Elapsed < TimeSpan.FromSeconds(waitSecond))
        //        {
        //            finishFlag = inquiryRepo.isJobGeneratePO_Finished(Result);

        //            if (finishFlag)
        //                break;
        //            System.Threading.Thread.Sleep(5000);
        //        }

        //        s.Stop();

        //        string ProcessId = Result;
        //        string TotalPODocument = "0";
        //        string TotalDocument = "0";
        //        string TotalFailed = "0";
        //        string TotalSucceed = "0";
        //        if (finishFlag)
        //        {
        //            var feedbackResult = inquiryRepo.GetFeedbackAutoPoECatalogue(ProcessId);
        //            List<string> ResultList = feedbackResult.Split('|').ToList<string>();
        //            ProcessId = ResultList[0];
        //            TotalPODocument = ResultList[1];
        //            TotalDocument = ResultList[2];
        //            TotalFailed = ResultList[3];
        //            TotalSucceed = ResultList[4];
        //        }

        //        return new JsonResult() { Data = new { ResultType = "S", Content = new { Process_Id = ProcessId, Total_PO_Processed = TotalPODocument, Total_Processed = TotalDocument, Total_Failed = TotalFailed, Total_Succeed = TotalSucceed } }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
        //    }
        //    catch (Exception ex)
        //    {
        //        return new JsonResult() { Data = new { ResultType = "E", Content = "Error:" + ex.Message }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
        //    }
        //}

        public ActionResult GetGeneratePROutstanding()
        {
            try
            {
                string noreg = this.GetCurrentRegistrationNumber();
                var Result = inquiryRepo.GetListPROutstanding(noreg);
                return PartialView("_inquiryPopupTriggerPOGrid_Outstanding", Result);
            }
            catch (Exception ex)
            {
                return new JsonResult() { Data = new { ResultType = "E", Content = "Error:" + ex.Message }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
            }
        }

        public ActionResult GetPRMonitoringOutstanding(string process_id)
        {
            try
            {
                var Result = inquiryRepo.GetListPRMonitoringOutstanding(process_id);
                return new JsonResult() { Data = new { ResultType = "S", Content = Result }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
            }
            catch (Exception ex)
            {
                return new JsonResult() { Data = new { ResultType = "E", Content = "Error:" + ex.Message }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
            }
        }

        public ActionResult GetPOMonitoring(string PRNo, string Status, string DateFrom, string DateTo, int page, int pageSize)
        {
            try
            {
                string noreg = this.GetCurrentRegistrationNumber();
                DateFrom = FixDateFromStringUI(DateFrom);
                DateTo = FixDateFromStringUI(DateTo);
                var Result = inquiryRepo.GetPOMonitoringList(PRNo, Status, DateFrom, DateTo, noreg, (page * pageSize),(((page - 1) * pageSize) + 1));
                var rowCount = inquiryRepo.GetPOMonitoringCount(PRNo, Status, DateFrom, DateTo, noreg);
                ViewData["PagingData"] = new Tuple<Paging, string>(CountIndex(rowCount, pageSize, page), "GetMonitoring");

                return PartialView("_inquiryPopupTriggerPOGrid_Monitoring", Result);
            }
            catch (Exception ex)
            {
                return new JsonResult() { Data = new { ResultType = "E", Content = "Error:" + ex.Message }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
            }
        }

        private string FixDateFromStringUI(string dateString)
        {
            String dateFrom = (dateString ?? String.Empty).Trim();

            if (dateFrom != String.Empty)
                return dateFrom.FromStandardFormat().ToSqlCompatibleFormat();

            return "";
        }

        private Paging CountIndex(int count, int length, int page)
        {
            Paging PG = new Paging(count, page, length);
            List<int> index = new List<int>();

            PG.Length = count;
            PG.CountData = count;
            Double Total = Math.Ceiling((Double)count / (Double)length);

            for (int i = 1; i <= Total; i++) { index.Add(i); }
            PG.IndexList = index;
            return PG;
        }

        //public string RenderRazorViewToString(string viewName, object model)
        //{
        //    ViewData.Model = model;
        //    using (var sw = new StringWriter())
        //    {
        //        var viewResult = ViewEngines.Engines.FindPartialView(ControllerContext,
        //                                                                 viewName);
        //        var viewContext = new ViewContext(ControllerContext, viewResult.View,
        //                                     ViewData, TempData, sw);
        //        viewResult.View.Render(viewContext, sw);
        //        viewResult.ViewEngine.ReleaseView(ControllerContext, viewResult.View);
        //        return sw.GetStringBuilder().ToString();
        //    }
        //}
        #endregion

        private void CreateExcelFile(string FileName, FileStream ftmp, HSSFWorkbook workbook)
        {
            MemoryStream ms = new MemoryStream();
            workbook.Write(ms);
            ftmp.Close();
            Response.BinaryWrite(ms.ToArray());
            Response.ContentType = "application/ms-excel";
            Response.AddHeader("content-disposition", String.Format("attachment;filename=\"{0}\"", FileName));
            Response.AddHeader("Set-Cookie", "fileDownload=true; path=/");
            Response.Flush();
            Response.End();
        }

        private void FixingSearchModelParam(PurchaseOrderSearchViewModel searchViewModel)
        {
            searchViewModel.DateFrom = DateTime.ParseExact(searchViewModel.DateFrom, "dd.MM.yyyy", CultureInfo.InvariantCulture).ToShortDateString();
            searchViewModel.DateTo = DateTime.ParseExact(searchViewModel.DateTo, "dd.MM.yyyy", CultureInfo.InvariantCulture).ToShortDateString();
            var PageSize = inquiryRepo.GetListPaging(searchViewModel);
            searchViewModel.PageSize = PageSize.TotalDataCount;
        }

        public static SelectList ProcurementChannelSelectList(string noreg)
        {
            return Models.Master.ProcurementChannelRepository.Instance
                .GetProcurementChannelList(noreg)
                .AsSelectList(pc => pc.PROC_CHANNEL_CD + " - " + pc.PROC_CHANNEL_DESC,
                    pc => pc.PROC_CHANNEL_CD);
        }

        //20191008 notice
        private void BindPOApprovalNotice(String docNo)
        {
            String userName = this.GetCurrentUsername();

            //ViewData["POInquiryShowNotice"] = showNotice;

            // Bind current user.
            ViewData["POInquiryNoticeCurrentUser"] = userName;

            // Bind data notice.
            ViewData["POInquiryNotice"] = CommonApprovalRepository.Instance.GetNoticeList(docNo, this.GetCurrentRegistrationNumber());
        }
        //20191008 notice user
        private void BindPOApprovalNoticeUser(String docNo)
        {
            List<CommonApprovalNoticeUser> dt = CommonApprovalRepository.Instance.GetNoticeUserListPR(docNo).ToList<CommonApprovalNoticeUser>();
            dt.Remove(new CommonApprovalNoticeUser() { NOTICE_TO_USER = this.GetCurrentRegistrationNumber() });
            ViewData["POInquiryNoticeUser"] = dt.Select(x => new { x.NOTICE_TO_USER, NOTICE_TO_ALIAS = x.NOTICE_TO_ALIAS.ToPascalCase() });
        }

        private void BindPOApproval(POApprovalParam param)
        {
            param.FixDateFromAndTo();

            // Bind data.
            ViewData["POApproval"] = approvalRepo.SearchList(param);

            // Bind pagination.
            ViewData["POApprovalPage"] = approvalRepo.SearchListCount(param);
        }
        [HttpPost]
        public ActionResult PostPOApprovalNotice(CommonApprovalNotice param)
        {
            try
            {
                param.NOTICE_FROM_USER = this.GetCurrentRegistrationNumber();
                param.NOTICE_FROM_ALIAS = this.GetCurrentUserNameDescription(this.GetCurrentRegistrationNumber()).PERSONNEL_NAME;
                param.CREATED_BY = this.GetCurrentUsername();
                int result = CommonApprovalRepository.Instance.PostNotice(param);
                if (result >= 1)
                    BindPOApprovalNotice(param.DOC_NO);

                return PartialView(Partial.InquiryNoticeMesssage);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult ReplyPOApprovalNotice(CommonApprovalNotice param)
        {
            try
            {
                param.NOTICE_FROM_USER = this.GetCurrentRegistrationNumber();
                param.NOTICE_FROM_ALIAS = this.GetCurrentUserNameDescription(this.GetCurrentRegistrationNumber()).PERSONNEL_NAME;
                param.CREATED_BY = this.GetCurrentUsername();
                int result = CommonApprovalRepository.Instance.ReplyNotice(param);
                if (result >= 1)
                    BindPOApprovalNotice(param.DOC_NO);

                return PartialView(Partial.InquiryNoticeMesssage);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult DeletePOApprovalNotice(CommonApprovalNotice param)
        {
            try
            {
                int result = CommonApprovalRepository.Instance.DeleteNotice(param);
                if (result >= 1)
                    BindPOApprovalNotice(param.DOC_NO);

                return PartialView(Partial.InquiryNoticeMesssage);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        public JsonResult errorPosting(string poNo)
        {
            //string result = "";
            List<string> result = new List<string>();
            //IList<PurchaseOrder> result = null;
            string msg = "";
            try
            {
                result = inquiryRepo.getErrorPosting(poNo);
            }
            catch (Exception e)
            {
                msg = e.Message;
            }
            //return Json(result, JsonRequestBehavior.AllowGet);
            return Json(result);
        }
    }
}   