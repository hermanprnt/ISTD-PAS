using System;
using System.Collections.Generic;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Constants.PR;
using GPS.Models.Common;
using GPS.Models.Master;
using GPS.Models.PR.Common;
using GPS.Models.PR.PRInquiry;
using Toyota.Common.Web.Platform;
using NPOI.HSSF.UserModel;
using GPS.Models;
using System.IO;
using GPS.Core.ViewModel;
using GPS.Core;
using NPOI.SS.UserModel;
using System.Linq;
using GPS.Models.PRPOApproval;
using Toyota.Common.Database;
using GPS.ViewModels;
using GPS.Constants.PRPOApproval;

namespace GPS.Controllers.PR
{
    public class PRInquiryController : PageController
    {
        /** Controller Method **/
        public const String _PRInquiryController = "/PRInquiry/";
        
        public const String _SearchPR = _PRInquiryController + "SearchData";
        public const String _SortPR = _PRInquiryController + "SortSearch";
        public const String _getPRApprovalHistory = _PRInquiryController + "GetPRApprovalHistory";
        public const String _EditPR = _PRInquiryController + "EditPR";
        public const String _CancelValidation = _PRInquiryController + "CancelValidation";
        public const String _CancelPR = _PRInquiryController + "CancelPR";
        public const String _ShowLatestPR = _PRInquiryController + "SaveLatestPRNO";
        public const String _ValidateDownload = _PRInquiryController + "ValidateDownload";
        public const String _UnlockPR = _PRInquiryController + "UnlockPR";
        public const String _OnDownloadExcel = _PRInquiryController + "OnDownloadExcel";

        public const String _getDetailPRH = _PRInquiryController + "GetDetailPRH";
        public const String _getDetailPRItem = _PRInquiryController + "GetDetailPRItem";
        public const String _getDetailPRSubItem = _PRInquiryController + "GetDetailPRSubItem";
        public const String _getApproval = _PRInquiryController + "GetApproval";
        public const String _getWorklistHistory = _PRInquiryController + "GetWorklistHistory";


        public PRInquiryController()
        {
            Settings.Title = "PR Inquiry Screen";
        }

        protected override void Startup()
        {
            int DIVISION_ID = DivisionRepository.Instance.GetUserDivision(this.GetCurrentRegistrationNumber());
            TempData["DIVISION_ID"] = DIVISION_ID;
            //20191007 instance for notice
            ViewData["PRApproval"] = new List<PRApproval>();
            ViewData["AccountingRolesFlag"] = GetFlagRoleAccountingAccess();
            ViewData["PRApprovalPage"] = new PaginationViewModel() { DataName = PRPOApprovalPage.PRApproval, PageIndex = 1, PageSize = 10 };

        }

        #region COMMON LIST 
        public PartialViewResult GetSlocbyPlant(string param)
        {
            ViewData["Sloc"] = SLocRepository.Instance.GetSLocList(param);
            return PartialView(PurchaseRequisitionPage._CascadeSloc);
        }

        public static SelectList SelectPRType()
        {
            return PRCommonRepository.Instance
                    .GetDataPRType()
                    .AsSelectList(prtype => prtype.PROCUREMENT_DESC, prtype => prtype.PROCUREMENT_TYPE);
        }

        #endregion

        #region SEARCH PR 
        public void SaveLatestPRNO(string PR_NO, int DIVISION_ID)
        {
            TempData["DIVISION_ID"] = DIVISION_ID;
            TempData["PR_NO"] = PR_NO;
        }

        private Paging CountIndex(int count, int length, int page)
        {
            Paging PG = new Paging(count,page,length);
            List<int> index = new List<int>();

            PG.Length = count;
            PG.CountData = count;
            Double Total = Math.Ceiling((Double)count / (Double)length);

            for (int i = 1; i <= Total; i++) { index.Add(i); }
            PG.IndexList = index;
            return PG;
        }

        public ActionResult SearchData(PRInquiry param, string issearch, int page = 1, int pageSize = 10)
        {
            if (issearch == "Y")
            {
                Tuple<int, string> RowCounts = new Tuple<int,string>(0, "");
                int RowLimit = 0;
                int RowCount = 0;
                Tuple<List<PRInquiry>, string> PRList = new Tuple<List<PRInquiry>, string>(new List<PRInquiry>(), "");

                try
                {
                    PRList = PRInquiryRepository.Instance.ListData(param, (((page - 1) * pageSize) + 1), (page * pageSize));
                    if (PRList.Item2 != "")
                        throw new Exception(PRList.Item2);

                    RowCounts = PRInquiryRepository.Instance.CountRetrievedPRData(param);
                    if (RowCounts.Item2 != "")
                        throw new Exception(RowCounts.Item2);

                    RowLimit = Convert.ToInt32(SystemRepository.Instance.GetSystemValue("MAX_SEARCH"));

                    string message = RowCounts.Item1 >= RowLimit ? "Total data too much, more than " + RowLimit + ", System only show new " + RowLimit + " Data" : "";
                    RowCount = RowCounts.Item1 >= RowLimit ? RowLimit : RowCounts.Item1;

                    ViewData["GridData"] = new Tuple<List<PRInquiry>, int, string>(PRList.Item1, page, message);
                    ViewData["TypePaging"] = "Header";
                    ViewData["PagingDataHeader"] = new Tuple<Paging, string, string>(CountIndex(RowCount, pageSize, page), "SearchPRHeader", "0");
                }
                catch (Exception e)
                {
                    ViewData["Message"] = "Error : " + e.Message;
                }
            }
            return PartialView(PurchaseRequisitionPage._InquiryGrid);
        }

        public ActionResult SortSearch(PRInquiry param, int page = 1, int pageSize = 10)
        {
            Tuple<List<PRInquiry>, string> PRList = new Tuple<List<PRInquiry>, string>(new List<PRInquiry>(), "");
            try
            {
                PRList = PRInquiryRepository.Instance.ListData(param, (((page - 1) * pageSize) + 1), (page * pageSize));
                if (PRList.Item2 != "")
                    throw new Exception(PRList.Item2);

                ViewData["GridData"] = new Tuple<List<PRInquiry>, int, string>(PRList.Item1, page, "");
            }
            catch (Exception e)
            {
                ViewData["Message"] = "Error : " + e.Message;
            }
            return PartialView(PurchaseRequisitionPage._InquiryGridBody);
        }
        #endregion

        #region DETAIL PR

        #region DOWNLOAD FILE
        private string GetMimeType(string fileName)
        {
            string mimeType = "application/unknown";
            string ext = System.IO.Path.GetExtension(fileName).ToLower();
            Microsoft.Win32.RegistryKey regKey = Microsoft.Win32.Registry.ClassesRoot.OpenSubKey(ext);
            if (regKey != null && regKey.GetValue("Content Type") != null)
                mimeType = regKey.GetValue("Content Type").ToString();
            return mimeType;
        }

        public string ValidateDownload(string id, string filename)
        {
            try
            {
                string mainpath = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
                string temppath = SystemRepository.Instance.GetSystemValue("PR_UPLOAD_TEMP_PATH");
                string fixpath = SystemRepository.Instance.GetSystemValue("PR_UPLOAD_PATH");

                string fix_attachment_path = mainpath + fixpath + "\\" + id.Trim() + "\\" + filename.Trim();
                string temp_attachment_path = mainpath + temppath + "\\" + id.Trim() + "\\" + filename.Trim();

                return System.IO.File.Exists(fix_attachment_path) ? fix_attachment_path :
                      (System.IO.File.Exists(temp_attachment_path) ? temp_attachment_path :
                      "E|File Not Found");
            }
            catch (Exception e)
            {
                return "E|" + e.Message;
            }
        }

        public void DownloadFile(string filepath, string filename)
        {
            Response.Clear();
            Response.ContentType = GetMimeType(filename);
            Response.AppendHeader("content-disposition", "attachment; filename=" + filename);
            Response.TransmitFile(filepath);
            Response.End();
        } 
        #endregion

        public ActionResult GetDetailPRH(string PR_NO)
        {
            Tuple<List<PRInquiry>, string> attachment = new Tuple<List<PRInquiry>,string>(new List<PRInquiry>(), "");
            PRInquiry prdata = new PRInquiry();
            Dictionary<string, string[]> commonfile = new Dictionary<string, string[]>();
            List<string[]> quotationfile = new List<string[]>();
            try
            {
                prdata = PRInquiryRepository.Instance.GetDetailPRH(PR_NO);
                if (prdata == null)
                    prdata = new PRInquiry();

                if (prdata != null)
                {
                    prdata.PLANT_CD = prdata.PLANT_CD != null ? prdata.PLANT_CD.ToString() : String.Empty;
                    prdata.SLOC_CD = prdata.SLOC_CD != null ? prdata.SLOC_CD.ToString() : String.Empty;
                    prdata.VENDOR_NAME = prdata.VENDOR_NAME != null ? prdata.VENDOR_NAME.ToString() : String.Empty;
                    prdata.DIVISION_NAME = prdata.DIVISION_NAME != null ? prdata.DIVISION_NAME.ToString() : String.Empty;
                    prdata.PROJECT_NO = prdata.PROJECT_NO != null ? prdata.PROJECT_NO.ToString() : String.Empty;
                    prdata.DOC_DT = prdata.DOC_DT != null ? prdata.DOC_DT.ToString() : String.Empty;
                    prdata.STATUS_DESC = prdata.STATUS_DESC != null ? prdata.STATUS_DESC.ToString() : String.Empty;
                    prdata.STATUS_CD = prdata.STATUS_CD != null ? prdata.STATUS_CD.ToString() : String.Empty;
                    prdata.PR_DESC = prdata.PR_DESC != null ? prdata.PR_DESC.ToString() : String.Empty;
                    prdata.PR_TYPE = prdata.PR_TYPE != null ? prdata.PR_TYPE.ToString() : String.Empty;
                    prdata.PR_COORDINATOR = prdata.PR_COORDINATOR != null ? prdata.PR_COORDINATOR.ToString() : String.Empty;
                    prdata.PR_NOTES = prdata.PR_NOTES != null ? prdata.PR_NOTES.ToString() : String.Empty;


                    ViewData["CheckDocNoShow"] = prdata.DOC_NO;

                    if ((prdata.MESSAGE != "") && (prdata.MESSAGE != null))
                        throw new Exception(prdata.MESSAGE);
                }
                else
                {
                    ViewData["CheckDocNoShow"] = "";
                }

                attachment = PRInquiryRepository.Instance.GetDetailAttachment(PR_NO);

                if (attachment.Item1.Count > 0)
                {
                    foreach (PRInquiry a in attachment.Item1)
                    {
                        if (a.DOC_TYPE != "QUOT")
                        {
                            commonfile.Add(a.DOC_TYPE + "_" + a.SEQ_NO, new string[]{
                                a.FILE_SEQ_NO.ToString(),
                                a.FILE_NAME_ORI.Length > 20 ? a.FILE_NAME_ORI.Substring(0, 20) + ". . ." : a.FILE_NAME_ORI, 
                                a.FILE_PATH
                            });
                        }
                        else
                        {
                           quotationfile.Add(new string[] {
                                a.FILE_SEQ_NO.ToString(),
                                a.FILE_NAME_ORI.Length > 20 ? a.FILE_NAME_ORI.Substring(0, 20) + ". . ." : a.FILE_NAME_ORI, 
                                a.FILE_PATH
                            });
                        }
                    }
                }
                
                

                if (attachment.Item2 != "")
                    throw new Exception(attachment.Item2);
                BindPRInquiryNotice(PR_NO);
                BindPRInquiryNoticeUser(PR_NO);
                BindPRDetailItem(PR_NO, 10, 1);
                CheckPONo(PR_NO);
                CheckRefDocNo(PR_NO);
                BindApproval("Division", PR_NO, 10, 1);
                BindApproval("Coordinator", PR_NO, 10, 1);
                BindApproval("Finance", PR_NO, 10, 1);
                BindWorklistHistory("History", PR_NO, 10, 1);
                ViewData["Cancel_Status"] = SystemRepository.Instance.GetSystemValue("PR_CANCEL_STS");
                ViewData["PR_Header"] = new Tuple<PRInquiry, Dictionary<string, string[]>, List<string[]>, string>(prdata, commonfile, quotationfile, PR_NO);
            }
            catch(Exception e)
            {
                ViewData["Message"] = "Error While Get Header PR : " + e.Message;
            }
            return PartialView(PurchaseRequisitionPage._InquiryDetail);
        }

        public ActionResult GetDetailPRItem(string PR_NO, int pageSize, int page = 1)
        {
            BindPRDetailItem(PR_NO, pageSize, page);

            return PartialView(PurchaseRequisitionPage._InquiryDetailGrid);
        }

        public void BindPRDetailItem(string PR_NO, int pageSize, int page = 1)
        {
            Tuple<List<PRInquiry>, string> PR_ITEM_DATA = new Tuple<List<PRInquiry>, string>(new List<PRInquiry>(), "");
            Tuple<int, string> PR_ITEM_DATA_Count = new Tuple<int, string>(0, "");
            try
            {

                PR_ITEM_DATA = PRInquiryRepository.Instance.GetDetailPRItem(PR_NO, (page * pageSize), (((page - 1) * pageSize) + 1));
                if (PR_ITEM_DATA.Item2 != "")
                    throw new Exception(PR_ITEM_DATA.Item2);

                PR_ITEM_DATA_Count = PRInquiryRepository.Instance.CountPRItem(PR_NO);
                if (PR_ITEM_DATA_Count.Item2 != "")
                    throw new Exception(PR_ITEM_DATA_Count.Item2);

                ViewData["PR_NO"] = PR_NO;
                ViewData["PR_Item"] = PR_ITEM_DATA.Item1;
                ViewData["TypePaging"] = "Item";
                ViewData["PagingDataItem"] = new Tuple<Paging, string, string>(CountIndex(PR_ITEM_DATA_Count.Item1, pageSize, page), "SearchPRItem", PR_NO);
            }
            catch (Exception e)
            {
                ViewData["Message"] = "Error While Get Detail PR : " + e.Message;
            }
        }

        public ActionResult GetDetailPRSubItem(string PR_NO, string PR_ITEM_NO)
        {
            List<PRInquiry> SUB_ITEM_DATA = PRInquiryRepository.Instance.GetDetailPRSubItem(PR_NO, PR_ITEM_NO);
            ViewData["PR_SubItem"] = SUB_ITEM_DATA;

            return PartialView(PurchaseRequisitionPage._InquiryDetailSubItemGrid);
        }

        public PartialViewResult GetPRApprovalHistory(WorklistParam param, Int64 pageIndex = 1, int pageSize = 10)
        {
            BindPRApprovalHistory(param, pageIndex, pageSize);

            return PartialView("~/Views/Worklist/_PartialPRWorklist.cshtml");
        }

        public PartialViewResult GetPRApprovalHistoryGrid(WorklistParam param, Int64 pageIndex = 1, int pageSize = 10)
        {
            BindPRApprovalHistory(param, pageIndex, pageSize);

            return PartialView("~/Views/Worklist/_PartialPRWorklistGrid.cshtml");
        }

        private void BindPRApprovalHistory(WorklistParam param, Int64 pageIndex = 1, int pageSize = 10)
        {
            Tuple<List<Worklist>, string> Worklist_Data = new Tuple<List<Worklist>, string>(new List<Worklist>(), "");
            Tuple<int, string> Worklist_Data_Count = new Tuple<int, string>(0, "");
            try
            {
                // Bind data.
                Worklist_Data = WorklistRepository.Instance.GetWorklist(param, pageIndex, pageSize);
                if (Worklist_Data.Item2 != "")
                    throw new Exception(Worklist_Data.Item2);

                Worklist_Data_Count = WorklistRepository.Instance.CountWorklist(param);
                if (Worklist_Data_Count.Item2 != "")
                    throw new Exception(Worklist_Data_Count.Item2);

                ViewData["PRApprovalHistory"] = Worklist_Data.Item1;
            }
            catch (Exception e)
            {
                ViewData["Message"] = "Error While Get Worklist Data : " + e.Message;
            }
        }

        public ActionResult GetApproval(string type, string PR_NO, int pageSize, int page = 1)
        {
            string view = "";

            BindApproval(type, PR_NO, pageSize, page);

            ViewData["PR_NO"] = PR_NO;
            switch (type)
            {
                case "Division":
                    {
                        view = PurchaseRequisitionPage._ApprovalDivisionGrid;
                        break;
                    }
                case "Coordinator":
                    {
                        view = PurchaseRequisitionPage._ApprovalCoordinatorGrid;
                        break;
                    }
                case "Finance":
                    {
                        view = PurchaseRequisitionPage._ApprovalFinanceGrid;
                        break;
                    }
            }

            return PartialView(view);
        }

        public void BindApproval(string type, string PR_NO, int pageSize, int page = 1)
        {
            Tuple<List<Worklist>, string> APPROVAL_DATA = new Tuple<List<Worklist>, string>(new List<Worklist>(), "");
            Tuple<int, string> APPROVAL_DATA_Count = new Tuple<int, string>(0, "");
            
            try
            {
                APPROVAL_DATA = PRInquiryRepository.Instance.GetApproval(type, PR_NO, (page * pageSize), (((page - 1) * pageSize) + 1));
                if (APPROVAL_DATA_Count.Item2 != "")
                    throw new Exception(APPROVAL_DATA.Item2);

                APPROVAL_DATA_Count = PRInquiryRepository.Instance.CountApprovalData(PR_NO);
                if (APPROVAL_DATA_Count.Item2 != "")
                    throw new Exception(APPROVAL_DATA_Count.Item2);

                ViewData["Approval_" + type] = APPROVAL_DATA.Item1;
                ViewData["TypePaging"] = type;
                ViewData["PagingData" + type] = new Tuple<Paging, string, string>(CountIndex(APPROVAL_DATA_Count.Item1, pageSize, page), "SearchApproval" + type, PR_NO);
            }
            catch (Exception e)
            {
                ViewData["Message"] = "Error While Get Approval " + type + " : " + e.Message;
            }
        }

        public void BindWorklistHistory(string type, string PR_NO, int pageSize, int page = 1)
        {
            Tuple<List<WorklistHistory>, string> APPROVAL_DATA = new Tuple<List<WorklistHistory>, string>(new List<WorklistHistory>(), "");
            Tuple<int, string> APPROVAL_DATA_Count = new Tuple<int, string>(0, "");

            try
            {
                APPROVAL_DATA = PRInquiryRepository.Instance.GetWorklistHistory(PR_NO, (page * pageSize), (((page - 1) * pageSize) + 1));
                if (APPROVAL_DATA_Count.Item2 != "")
                    throw new Exception(APPROVAL_DATA.Item2);

                APPROVAL_DATA_Count = PRInquiryRepository.Instance.CountWorklistHistory(PR_NO);
                if (APPROVAL_DATA_Count.Item2 != "")
                    throw new Exception(APPROVAL_DATA_Count.Item2);

                ViewData["Approval_" + type] = APPROVAL_DATA.Item1;
                ViewData["TypePaging"] = type;
                ViewData["PagingData" + type] = new Tuple<Paging, string, string>(CountIndex(APPROVAL_DATA_Count.Item1, pageSize, page), "SearchWorklistHistory", PR_NO);
            }
            catch (Exception e)
            {
                ViewData["Message"] = "Error While Get Approval " + type + " : " + e.Message;
            }
        }
        #endregion

        #region EDIT PR
        public string EditPR(string pPR_NO)
        {
            string result = PRInquiryRepository.Instance.EditPR(pPR_NO, this.GetCurrentUsername(), this.GetCurrentRegistrationNumber());
            return result;
        }
        #endregion

        #region UNLOCK PR
        public string UnlockPR(string pPR_NO, string pPROCESS_ID)
        {
            string result = PRInquiryRepository.Instance.UnlockPR(pPR_NO, pPROCESS_ID, this.GetCurrentUsername());
            return result;
        }
        #endregion

        #region CANCEL PR
        public string CancelValidation(string pPR_NO)
        {
            return PRInquiryRepository.Instance.CancelValidation(pPR_NO, this.GetCurrentUsername(), this.GetCurrentRegistrationNumber());
        }

        public string CancelPR(string pPR_NO, string pCANCEL_REASON)
        {
            Tuple<string, string, int> Result = new Tuple<string,string, int>("", "", 0);
            Tuple<string, string, int> rollbackResult = new Tuple<string, string, int>("", "", 0);
            string ProcessId = "";
            string errorLoc = "";
            string msg = "";
            int errorbudget = 0;

            try
            {
                Result = PRInquiryRepository.Instance.CancelInit(pPR_NO, this.GetCurrentUsername(), this.GetCurrentUserFullName());

                if (Result.Item1 == "SUCCESS")
                {
                    ProcessId = Result.Item2;
                    PRInquiry data = PRInquiryRepository.Instance.GetDetailPRH(pPR_NO);

                    if (data.STATUS_CD != "94" && data.STATUS_CD != "00")
                    {
                        if (data.PR_TYPE_CD == "MO")
                        {
                            // TO DO : Asset Cancellation
                        }

                        if (data.PR_TYPE_CD == "RR")
                        {
                            if (Result.Item1 == "SUCCESS")
                                Result = PRInquiryRepository.Instance.CancelQuota(ProcessId, pPR_NO, this.GetCurrentUsername(), "Commit");
                        }

                        if (Result.Item1 == "SUCCESS")
                        {
                            Result = PRInquiryRepository.Instance.CancelBudget(ProcessId, pPR_NO, this.GetCurrentUsername(), "Commit", 0);
                            if (Result.Item1 != "SUCCESS")
                            {
                                errorLoc = "Budget";
                                msg = Result.Item2;
                                errorbudget = Result.Item3;
                            }
                        }
                        else msg = Result.Item2;
                    }

                    if (Result.Item1 == "SUCCESS")
                    {
                        Result = PRInquiryRepository.Instance.CancelPR(ProcessId, pPR_NO, this.GetCurrentUsername(), pCANCEL_REASON);
                        if (Result.Item1 != "SUCCESS")
                        {
                            errorLoc = "Save";
                            msg = Result.Item2;
                        }
                    }

                    if (data.STATUS_CD != "94" && data.STATUS_CD != "00")
                    {
                        if (Result.Item1 != "SUCCESS" && (errorLoc == "Budget" || errorLoc == "Save"))
                            rollbackResult = PRInquiryRepository.Instance.CancelBudget(ProcessId, pPR_NO, this.GetCurrentUsername(), "Rollback", errorbudget);

                        if (Result.Item1 != "SUCCESS" && (errorLoc == "Budget" || errorLoc == "Save") && data.PR_TYPE_CD == "RR")
                            rollbackResult = PRInquiryRepository.Instance.CancelQuota(ProcessId, pPR_NO, this.GetCurrentUsername(), "Rollback");
                    }
                }
            }
            catch (Exception ex) 
            {
                Result = new Tuple<string, string, int>("ERROR", ex.Message, 0);
            }

            switch (Result.Item1) 
            { 
                case "SUCCESS" : 
                    {
                        return "SUCCESS|" + pPR_NO;
                    }
                case "ERROR":
                    {
                        return "ERROR|There is error when cancel PR : " + msg;
                    }
                default:
                    {
                        return "ERROR|" + Result.Item2;
                    }
            }
        }
        #endregion

        #region DOWNLOAD PR
        public void OnDownloadExcel(PRInquiry searchViewModel)
        {
            CommonDownload downloadEngine = CommonDownload.Instance;
            string FileName = string.Format("Download PR Inquiry.xls", DateTime.Now);
            var RowCounts = PRInquiryRepository.Instance.CountRetrievedPRData(searchViewModel);

            string filePath = HttpContext.Request.MapPath(downloadEngine.GetServerFilePath("PRDownloadTemplete.xls"));
            FileStream ftmp = new FileStream(filePath, FileMode.Open, FileAccess.Read);
            var workbook = new HSSFWorkbook(ftmp);
            var dataListPR = GenerateDataListForExcel(searchViewModel, RowCounts.Item1);

            ISheet sheet;IRow Hrow;int row = 1;
            IFont font = downloadEngine.GenerateFontExcel(workbook);
            ICellStyle styleCenter = downloadEngine.GenerateStyleCenter(workbook, font);
            ICellStyle styleLeft = downloadEngine.GenerateStyleLeft(workbook, font);
            ICellStyle styleNormal = downloadEngine.GenerateStyleNormal(workbook, font);

            sheet = workbook.GetSheetAt(0);

            foreach (PRInquiryExcel item in dataListPR)
            {
                Hrow = sheet.CreateRow(row);
                downloadEngine.WriteCellValue(Hrow, 0, styleNormal, item.PR_NO);
                downloadEngine.WriteCellValue(Hrow, 1, styleNormal, item.PR_ITEM_NO);
                downloadEngine.WriteCellValue(Hrow, 2, styleNormal, item.MAT_DESC);
                downloadEngine.WriteCellValue(Hrow, 3, styleNormal, double.Parse(item.PR_QTY.ToString()));
                downloadEngine.WriteCellValue(Hrow, 4, styleNormal, item.UNIT_OF_MEASURE_CD);
                downloadEngine.WriteCellValue(Hrow, 5, styleNormal, item.PRICE_PER_UOM);
                downloadEngine.WriteCellValue(Hrow, 6, styleCenter, item.LOCAL_CURR_CD);
                downloadEngine.WriteCellValue(Hrow, 7, styleNormal, double.Parse(item.EXCHANGE_RATE.ToString()));
                downloadEngine.WriteCellValue(Hrow, 8, styleNormal, double.Parse(item.ORI_AMOUNT.ToString()));
                downloadEngine.WriteCellValue(Hrow, 9, styleNormal, double.Parse(item.LOCAL_AMOUNT.ToString()));
                downloadEngine.WriteCellValue(Hrow, 10, styleCenter, item.WBS_NO);
                downloadEngine.WriteCellValue(Hrow, 11, styleCenter, item.GL_ACCOUNT);
                downloadEngine.WriteCellValue(Hrow, 12, styleCenter, item.COST_CENTER_CD);
                downloadEngine.WriteCellValue(Hrow, 13, styleCenter, item.ASSET_NO);
                downloadEngine.WriteCellValue(Hrow, 14, styleNormal, item.VENDOR_CD);
                downloadEngine.WriteCellValue(Hrow, 15, styleNormal, item.VENDOR_NAME);
                downloadEngine.WriteCellValue(Hrow, 16, styleNormal, item.STATUS_DESC);
                downloadEngine.WriteCellValue(Hrow, 17, styleNormal, item.CREATED_BY);
                downloadEngine.WriteCellValue(Hrow, 18, styleNormal, item.CURRENT_APPROVER);
                downloadEngine.WriteCellValue(Hrow, 19, styleNormal, item.PO_NO);
                downloadEngine.WriteCellValue(Hrow, 20, styleNormal, item.PO_ITEM_NO);
                downloadEngine.WriteCellValue(Hrow, 21, styleNormal, item.DIVISION_NAME);
                downloadEngine.WriteCellValue(Hrow, 22, styleNormal, string.Format("{0:yyyy-MM-dd}", item.DOC_DT));
                downloadEngine.WriteCellValue(Hrow, 23, styleNormal, item.PLANT_NAME);
                downloadEngine.WriteCellValue(Hrow, 24, styleNormal, item.SLOC_NAME);
                row++;
            }

            CreateExcelFile(FileName, ftmp, workbook);

        }

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

        private List<PRInquiryExcel> GenerateDataListForExcel(PRInquiry searchViewModel, int rowCount)
        {
            var prdata = PRInquiryRepository.Instance.ListDownloadExcel(searchViewModel, rowCount);
            if (prdata.Item2 != "")
                throw new Exception(prdata.Item2);
 
            return prdata.Item1;
        }

        #endregion

        public string GetPRCancelReason(string PR_NO)
        {
            return PRInquiryRepository.Instance.GetPRCancelReason(PR_NO);
        }

        public ActionResult GetWorklistHistory(string PR_NO, int pageSize, int page = 1)
        {
            BindWorklistHistory("History", PR_NO, pageSize, page);
            ViewData["PR_NO"] = PR_NO;
            return PartialView(PurchaseRequisitionPage._WorklistHistory);
        }

        #region Notice
        //20191004
        private void BindPRInquiryNotice(string PR_NO)
        {
            string userName = this.GetCurrentUsername();
            string docNo = PR_NO;
            // Bind current user.
            ViewData["PRInquiryNoticeCurrentUser"] = userName;

            // Bind data notice.
            ViewData["PRInquiryNotice"] = CommonApprovalRepository.Instance.GetNoticeList(docNo, this.GetCurrentRegistrationNumber());
        }
        //20191004
        private void BindPRInquiryNoticeUser(string PR_NO)
        {
            string docNo = PR_NO;
            // Bind user notice.
            ViewData["PRInquiryNoticeUser"] = CommonApprovalRepository.Instance.GetNoticeUserListPR(docNo).Select(x => new { x.NOTICE_TO_USER, NOTICE_TO_ALIAS = x.NOTICE_TO_ALIAS.ToPascalCase() }).Where(y => y.NOTICE_TO_USER != "-");
        }
        //20191004
        public ActionResult PostPRApprovalNotice(CommonApprovalNotice param)
        {
            try
            {
                param.NOTICE_FROM_USER = this.GetCurrentRegistrationNumber();
                param.NOTICE_FROM_ALIAS = this.GetCurrentUserNameDescription(this.GetCurrentRegistrationNumber()).PERSONNEL_NAME;
                param.CREATED_BY = this.GetCurrentUsername();
                int result = CommonApprovalRepository.Instance.PostNotice(param);
                if (result >= 1)
                    BindPRInquiryNotice(param.DOC_NO);

                return PartialView(PurchaseRequisitionPage._NoticeMessage);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult ReplyPRApprovalNotice(CommonApprovalNotice param)
        {
            try
            {
                param.NOTICE_FROM_USER = this.GetCurrentRegistrationNumber();
                param.NOTICE_FROM_ALIAS = this.GetCurrentUserNameDescription(this.GetCurrentRegistrationNumber()).PERSONNEL_NAME;
                param.CREATED_BY = this.GetCurrentUsername();
                int result = CommonApprovalRepository.Instance.ReplyNotice(param);
                if (result >= 1)
                    BindPRInquiryNotice(param.DOC_NO);

                return PartialView(PurchaseRequisitionPage._NoticeMessage);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult DeletePRApprovalNotice(CommonApprovalNotice param)
        {
            try
            {
                int result = CommonApprovalRepository.Instance.DeleteNotice(param);
                if (result >= 1)
                    BindPRInquiryNotice(param.DOC_NO);

                return PartialView(PurchaseRequisitionPage._NoticeMessage);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
        //20191007
        private void BindPRApproval(PRPOApprovalParam param = null, Int64 pageIndex = 1, int pageSize = 10)
        {
            // Bind data.
            var AccountRolesFlag = GetFlagRoleAccountingAccess();

            if (AccountRolesFlag)
                ViewData["PRApproval"] = PRApprovalRepository.Instance.GetPRListAccounting(param, pageIndex, pageSize);
            else
                ViewData["PRApproval"] = PRApprovalRepository.Instance.GetPRList(param, pageIndex, pageSize);

            // Bind pagination.
            PaginationViewModel result = new PaginationViewModel();
            result.DataName = PRPOApprovalPage.PRApproval;
            if (AccountRolesFlag)
                result.TotalDataCount = PRApprovalRepository.Instance.CountPRListAccounting(param);
            else
                result.TotalDataCount = PRApprovalRepository.Instance.CountPRList(param);
            result.PageIndex = Convert.ToInt32(pageIndex);
            result.PageSize = pageSize;
            result.TotalPageCount = Convert.ToInt32(Math.Ceiling((Double)result.TotalDataCount / result.PageSize));
            ViewData["PRApprovalPage"] = result;
        }
        //20191007
        private bool GetFlagRoleAccountingAccess()
        {
            var user = this.GetCurrentUser();
            var AccountingRoleList = SystemRepository.Instance.GetByFunctionId("ACROLE");
            Boolean flagAccRole = false;
            foreach (var item in AccountingRoleList)
            {
                var foundRoleList = user.Roles.Where(x => x.Id == item.Value);

                if (foundRoleList != null & foundRoleList.Count() > 0)
                    flagAccRole = true;
            }

            //return  true;
            return flagAccRole;
        }
        #endregion

        #region Cancel Remain Budget
        //20191014 delete remaining budget
        public string DeleteRemPR(string PR_NO, string ITEM_NO)
        {
            Tuple<string, string, int> Result = new Tuple<string, string, int>("", "", 0);
            Tuple<string, string, int> rollbackResult = new Tuple<string, string, int>("", "", 0);
            string ProcessId = "";
            string errorLoc = "";
            string msg = "";
            int errorbudget = 0;

            try
            {
                PRInquiry data = PRInquiryRepository.Instance.GetDetailPRH(PR_NO);
                
                if (data.STATUS_CD.Equals("95"))
                {
                    msg = "PR status already cancel";
                }
                else 
                {
                    List<PRInquiry> data1 = PRInquiryRepository.Instance.chkPrDetail(PR_NO, ITEM_NO);
                    foreach (PRInquiry datadata in data1)
                    {
                        if (datadata.CANCEL_QTY == 0 && datadata.OPEN_QTY != 0)
                        {
                            Result = PRInquiryRepository.Instance.CancelBudgetRem(ProcessId, PR_NO, ITEM_NO, this.GetCurrentUsername(), "Commit", 0);
                            if (Result.Item1 != "SUCCESS")
                            {
                                errorLoc = "Budget";
                                msg = Result.Item2;
                                errorbudget = Result.Item3;
                            }
                            else
                            {
                                string hasil = PRInquiryRepository.Instance.UpdateCancelRem(PR_NO, ITEM_NO, this.GetCurrentUsername());
                                //cek jika ada pr item lain yang telah dibuat po dan tidak di cancel atau pr tesebut hanya memiliki satu pr item
                                int data3 = PRInquiryRepository.Instance.AnotherPrItem(PR_NO, ITEM_NO);
                                if (data3 > 0)
                                {
                                    Result = PRInquiryRepository.Instance.CommitBudgetRemain(ProcessId, PR_NO, ITEM_NO, this.GetCurrentUsername(), "Commit", 0);
                                }
                            }
                        }
                        else
                        {
                            msg = "PR Item not have remaining budget";
                        }
                    }
                }
            }
            catch (Exception ex) 
            {
                Result = new Tuple<string, string, int>("ERROR", ex.Message, 0);
            }
            switch (Result.Item1)
            {
                case "SUCCESS":
                    {
                        return "SUCCESS|" + PR_NO;
                    }
                case "ERROR":
                    {
                        return "ERROR|There is error when delete remaining budget PR : " + msg;
                    }
                default:
                    {
                        return "ERROR|" + msg;
                    }
            }

        }
        //20191014
        public void CheckPONo(string pPR_NO)
        {
            int Count = 0;
            Count = PRInquiryRepository.Instance.ChkPONo(pPR_NO);
            ViewData["ChkPONo"] = Count;
        }

        public void CheckRefDocNo(string pPR_NO)
        {
            int Count = 0;
            Count = PRInquiryRepository.Instance.ChkRefDocNo(pPR_NO);
            ViewData["ChkRefDocNo"] = Count;
        }
        #endregion
    }
}