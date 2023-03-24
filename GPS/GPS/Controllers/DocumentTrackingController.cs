using System;
using System.Collections.Generic;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.Models.Master;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Common
{
    public class DocumentTrackingController : PageController
    {
        /** Controller Method **/
        public const String _DocumentTrackingController = "/DocumentTracking/";

        public const String _getSecondRow = _DocumentTrackingController + "GetSecondRow";
        public const String _getThirdRow = _DocumentTrackingController + "GetThirdRow";
        public const String _Search = _DocumentTrackingController + "SearchData";

        public DocumentTrackingController()
        {
            Settings.Title = "Document Tracking Screen";
        }

        protected override void Startup()
        {
            //int DIVISION_ID = DivisionRepository.Instance.GetUserDivision(this.GetCurrentRegistrationNumber());
            //TempData["DIVISION_ID"] = DIVISION_ID;
        }

        //#region COMMON LIST 
        //public PartialViewResult GetSlocbyPlant(string param)
        //{
        //    ViewData["Sloc"] = SLocRepository.Instance.GetSLocList(param);
        //    return PartialView(PurchaseRequisitionPage._CascadeSloc);
        //}

        //public static SelectList SelectPRType()
        //{
        //    return PRCommonRepository.Instance
        //            .GetDataPRType()
        //            .AsSelectList(prtype => prtype.PROCUREMENT_DESC, prtype => prtype.PROCUREMENT_TYPE);
        //}

        //#endregion

        //#region SEARCH PR 
        //public void SaveLatestPRNO(string PR_NO, int DIVISION_ID)
        //{
        //    TempData["DIVISION_ID"] = DIVISION_ID;
        //    TempData["PR_NO"] = PR_NO;
        //}

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

        public ActionResult SearchData(DocTrackingParam param, string issearch, int page = 1, int pageSize = 10)
        {
            if (issearch == "Y")
            {
                Tuple<int, string> RowCounts = new Tuple<int, string>(0, "");
                int RowLimit = 0;
                int RowCount = 0;
                Tuple<List<DocTrackingList>, string> dt = new Tuple<List<DocTrackingList>, string>(new List<DocTrackingList>(), "");

                try
                {
                    dt = DocumentTrackingRepository.Instance.ListData(param, (((page - 1) * pageSize) + 1), (page * pageSize));
                    if (dt.Item2 != "")
                        throw new Exception(dt.Item2);

                    RowCounts = DocumentTrackingRepository.Instance.CountRetrievedData(param);
                    if (RowCounts.Item2 != "")
                        throw new Exception(RowCounts.Item2);

                    RowLimit = Convert.ToInt32(SystemRepository.Instance.GetSystemValue("MAX_SEARCH"));

                    string message = RowCounts.Item1 >= RowLimit ? "Total data too much, more than " + RowLimit + ", System only show new " + RowLimit + " Data" : "";
                    RowCount = RowCounts.Item1 >= RowLimit ? RowLimit : RowCounts.Item1;

                    ViewData["GridData"] = new Tuple<List<DocTrackingList>, int, string>(dt.Item1, page, message);
                    ViewData["Paging"] = new Tuple<Paging, string, string>(CountIndex(RowCount, pageSize, page), "Search", "0");
                }
                catch (Exception e)
                {
                    ViewData["Message"] = "Error : " + e.Message;
                }
            }
            return PartialView("_PartialGrid");
        }

        public ActionResult GetSecondRow(DocTrackingParam param)
        {
            ViewData["SecondRow"] = DocumentTrackingRepository.Instance.GetSecondRow(param);

            return PartialView("_PartialSecondRow");
        }

        public ActionResult GetThirdRow(DocTrackingParam param)
        {
            ViewData["ThirdRow"] = null;

            return PartialView("_PartialThirdRow");
        }

        //#endregion

        //#region DETAIL PR

        //#region DOWNLOAD FILE
        //private string GetMimeType(string fileName)
        //{
        //    string mimeType = "application/unknown";
        //    string ext = System.IO.Path.GetExtension(fileName).ToLower();
        //    Microsoft.Win32.RegistryKey regKey = Microsoft.Win32.Registry.ClassesRoot.OpenSubKey(ext);
        //    if (regKey != null && regKey.GetValue("Content Type") != null)
        //        mimeType = regKey.GetValue("Content Type").ToString();
        //    return mimeType;
        //}

        //public string ValidateDownload(string id, string filename)
        //{
        //    try
        //    {
        //        string mainpath = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
        //        string temppath = SystemRepository.Instance.GetSystemValue("PR_UPLOAD_TEMP_PATH");
        //        string fixpath = SystemRepository.Instance.GetSystemValue("PR_UPLOAD_PATH");

        //        string fix_attachment_path = mainpath + fixpath + "\\" + id.Trim() + "\\" + filename.Trim();
        //        string temp_attachment_path = mainpath + temppath + "\\" + id.Trim() + "\\" + filename.Trim();

        //        return System.IO.File.Exists(fix_attachment_path) ? fix_attachment_path :
        //              (System.IO.File.Exists(temp_attachment_path) ? temp_attachment_path :
        //              "E|File Not Found");
        //    }
        //    catch (Exception e)
        //    {
        //        return "E|" + e.Message;
        //    }
        //}

        //public void DownloadFile(string filepath, string filename)
        //{
        //    Response.Clear();
        //    Response.ContentType = GetMimeType(filename);
        //    Response.AppendHeader("content-disposition", "attachment; filename=" + filename);
        //    Response.TransmitFile(filepath);
        //    Response.End();
        //} 
        //#endregion

        //public ActionResult GetDetailPRH(string PR_NO)
        //{
        //    Tuple<List<PRInquiry>, string> attachment = new Tuple<List<PRInquiry>,string>(new List<PRInquiry>(), "");
        //    PRInquiry prdata = new PRInquiry();
        //    Dictionary<string, string[]> commonfile = new Dictionary<string, string[]>();
        //    List<string[]> quotationfile = new List<string[]>();
        //    try
        //    {
        //        prdata = PRInquiryRepository.Instance.GetDetailPRH(PR_NO);
        //        if (prdata == null)
        //            prdata = new PRInquiry();

        //        if (prdata != null)
        //        {
        //            prdata.PLANT_CD = prdata.PLANT_CD != null ? prdata.PLANT_CD.ToString() : String.Empty;
        //            prdata.SLOC_CD = prdata.SLOC_CD != null ? prdata.SLOC_CD.ToString() : String.Empty;
        //            prdata.VENDOR_NAME = prdata.VENDOR_NAME != null ? prdata.VENDOR_NAME.ToString() : String.Empty;
        //            prdata.DIVISION_NAME = prdata.DIVISION_NAME != null ? prdata.DIVISION_NAME.ToString() : String.Empty;
        //            prdata.PROJECT_NO = prdata.PROJECT_NO != null ? prdata.PROJECT_NO.ToString() : String.Empty;
        //            prdata.DOC_DT = prdata.DOC_DT != null ? prdata.DOC_DT.ToString() : String.Empty;
        //            prdata.STATUS_DESC = prdata.STATUS_DESC != null ? prdata.STATUS_DESC.ToString() : String.Empty;
        //            prdata.PR_DESC = prdata.PR_DESC != null ? prdata.PR_DESC.ToString() : String.Empty;
        //            prdata.PR_TYPE = prdata.PR_TYPE != null ? prdata.PR_TYPE.ToString() : String.Empty;
        //            prdata.PR_COORDINATOR = prdata.PR_COORDINATOR != null ? prdata.PR_COORDINATOR.ToString() : String.Empty;
    
        //            if ((prdata.MESSAGE != "") && (prdata.MESSAGE != null))
        //                throw new Exception(prdata.MESSAGE);
        //        }


        //        attachment = PRInquiryRepository.Instance.GetDetailAttachment(PR_NO);

        //        if (attachment.Item1.Count > 0)
        //        {
        //            foreach (PRInquiry a in attachment.Item1)
        //            {
        //                if (a.DOC_TYPE != "QUOT")
        //                {
        //                    commonfile.Add(a.DOC_TYPE + "_" + a.SEQ_NO, new string[]{
        //                        a.FILE_SEQ_NO.ToString(),
        //                        a.FILE_NAME_ORI.Length > 20 ? a.FILE_NAME_ORI.Substring(0, 20) + ". . ." : a.FILE_NAME_ORI, 
        //                        a.FILE_PATH
        //                    });
        //                }
        //                else
        //                {
        //                   quotationfile.Add(new string[] {
        //                        a.FILE_SEQ_NO.ToString(),
        //                        a.FILE_NAME_ORI.Length > 20 ? a.FILE_NAME_ORI.Substring(0, 20) + ". . ." : a.FILE_NAME_ORI, 
        //                        a.FILE_PATH
        //                    });
        //                }
        //            }
        //        }


        //        if (attachment.Item2 != "")
        //            throw new Exception(attachment.Item2);

        //        BindPRDetailItem(PR_NO, 10, 1);
        //        BindApproval("Division", PR_NO, 10, 1);
        //        BindApproval("Coordinator", PR_NO, 10, 1);
        //        BindApproval("Finance", PR_NO, 10, 1);
        //        ViewData["PR_Header"] = new Tuple<PRInquiry, Dictionary<string, string[]>, List<string[]>, string>(prdata, commonfile, quotationfile, PR_NO);
        //    }
        //    catch(Exception e)
        //    {
        //        ViewData["Message"] = "Error While Get Header PR : " + e.Message;
        //    }
        //    return PartialView(PurchaseRequisitionPage._InquiryDetail);
        //}

        //public ActionResult GetDetailPRItem(string PR_NO, int pageSize, int page = 1)
        //{
        //    BindPRDetailItem(PR_NO, pageSize, page);

        //    return PartialView(PurchaseRequisitionPage._InquiryDetailGrid);
        //}

        //public void BindPRDetailItem(string PR_NO, int pageSize, int page = 1)
        //{
        //    Tuple<List<PRInquiry>, string> PR_ITEM_DATA = new Tuple<List<PRInquiry>, string>(new List<PRInquiry>(), "");
        //    Tuple<int, string> PR_ITEM_DATA_Count = new Tuple<int, string>(0, "");
        //    try
        //    {

        //        PR_ITEM_DATA = PRInquiryRepository.Instance.GetDetailPRItem(PR_NO, (page * pageSize), (((page - 1) * pageSize) + 1));
        //        if (PR_ITEM_DATA.Item2 != "")
        //            throw new Exception(PR_ITEM_DATA.Item2);

        //        PR_ITEM_DATA_Count = PRInquiryRepository.Instance.CountPRItem(PR_NO);
        //        if (PR_ITEM_DATA_Count.Item2 != "")
        //            throw new Exception(PR_ITEM_DATA_Count.Item2);

        //        ViewData["PR_NO"] = PR_NO;
        //        ViewData["PR_Item"] = PR_ITEM_DATA.Item1;
        //        ViewData["TypePaging"] = "Item";
        //        ViewData["PagingDataItem"] = new Tuple<Paging, string, string>(CountIndex(PR_ITEM_DATA_Count.Item1, pageSize, page), "SearchPRItem", PR_NO);
        //    }
        //    catch (Exception e)
        //    {
        //        ViewData["Message"] = "Error While Get Detail PR : " + e.Message;
        //    }
        //}

        //public ActionResult GetDetailPRSubItem(string PR_NO, string PR_ITEM_NO)
        //{
        //    List<PRInquiry> SUB_ITEM_DATA = PRInquiryRepository.Instance.GetDetailPRSubItem(PR_NO, PR_ITEM_NO);
        //    ViewData["PR_SubItem"] = SUB_ITEM_DATA;

        //    return PartialView(PurchaseRequisitionPage._InquiryDetailSubItemGrid);
        //}

        //public PartialViewResult GetPRApprovalHistory(WorklistParam param, Int64 pageIndex = 1, int pageSize = 10)
        //{
        //    BindPRApprovalHistory(param, pageIndex, pageSize);

        //    return PartialView("~/Views/Worklist/_PartialPRWorklist.cshtml");
        //}

        //public PartialViewResult GetPRApprovalHistoryGrid(WorklistParam param, Int64 pageIndex = 1, int pageSize = 10)
        //{
        //    BindPRApprovalHistory(param, pageIndex, pageSize);

        //    return PartialView("~/Views/Worklist/_PartialPRWorklistGrid.cshtml");
        //}

        //private void BindPRApprovalHistory(WorklistParam param, Int64 pageIndex = 1, int pageSize = 10)
        //{
        //    Tuple<List<Worklist>, string> Worklist_Data = new Tuple<List<Worklist>, string>(new List<Worklist>(), "");
        //    Tuple<int, string> Worklist_Data_Count = new Tuple<int, string>(0, "");
        //    try
        //    {
        //        // Bind data.
        //        Worklist_Data = WorklistRepository.Instance.GetWorklist(param, pageIndex, pageSize);
        //        if (Worklist_Data.Item2 != "")
        //            throw new Exception(Worklist_Data.Item2);

        //        Worklist_Data_Count = WorklistRepository.Instance.CountWorklist(param);
        //        if (Worklist_Data_Count.Item2 != "")
        //            throw new Exception(Worklist_Data_Count.Item2);

        //        ViewData["PRApprovalHistory"] = Worklist_Data.Item1;
        //    }
        //    catch (Exception e)
        //    {
        //        ViewData["Message"] = "Error While Get Worklist Data : " + e.Message;
        //    }
        //}

        //public ActionResult GetApproval(string type, string PR_NO, int pageSize, int page = 1)
        //{
        //    string view = "";

        //    BindApproval(type, PR_NO, pageSize, page);

        //    ViewData["PR_NO"] = PR_NO;
        //    switch (type)
        //    {
        //        case "Division":
        //            {
        //                view = PurchaseRequisitionPage._ApprovalDivisionGrid;
        //                break;
        //            }
        //        case "Coordinator":
        //            {
        //                view = PurchaseRequisitionPage._ApprovalCoordinatorGrid;
        //                break;
        //            }
        //        case "Finance":
        //            {
        //                view = PurchaseRequisitionPage._ApprovalFinanceGrid;
        //                break;
        //            }
        //    }

        //    return PartialView(view);
        //}

        //public void BindApproval(string type, string PR_NO, int pageSize, int page = 1)
        //{
        //    Tuple<List<Worklist>, string> APPROVAL_DATA = new Tuple<List<Worklist>, string>(new List<Worklist>(), "");
        //    Tuple<int, string> APPROVAL_DATA_Count = new Tuple<int, string>(0, "");
            
        //    try
        //    {
        //        APPROVAL_DATA = PRInquiryRepository.Instance.GetApproval(type, PR_NO, (page * pageSize), (((page - 1) * pageSize) + 1));
        //        if (APPROVAL_DATA_Count.Item2 != "")
        //            throw new Exception(APPROVAL_DATA.Item2);

        //        APPROVAL_DATA_Count = PRInquiryRepository.Instance.CountApprovalData(PR_NO);
        //        if (APPROVAL_DATA_Count.Item2 != "")
        //            throw new Exception(APPROVAL_DATA_Count.Item2);

        //        ViewData["Approval_" + type] = APPROVAL_DATA.Item1;
        //        ViewData["TypePaging"] = type;
        //        ViewData["PagingData" + type] = new Tuple<Paging, string, string>(CountIndex(APPROVAL_DATA_Count.Item1, pageSize, page), "SearchApproval" + type, PR_NO);
        //    }
        //    catch (Exception e)
        //    {
        //        ViewData["Message"] = "Error While Get Approval " + type + " : " + e.Message;
        //    }
        //}
        //#endregion
    }
}