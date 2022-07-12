using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Constants.PR;
using GPS.Models.Common;
using GPS.Models.Master;
using GPS.Models.PR.Common;
using GPS.Models.PR.PRCreation;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.PR
{
    public class PRCreationController : PageController
    {
        #region Controller Method
        public const String _PRCreationController = "/PRCreation/";

        public const String _GetValuationClass = _PRCreationController + "getValuationClass";
        public const String _GetValuationClassGrid = _PRCreationController + "getValuationClassGrid";
        public const String _GetMaterial = _PRCreationController + "getMaterial";
        public const String _GetMaterialGrid = _PRCreationController + "getMaterialGrid";
        public const String _GetGLAccount = _PRCreationController + "getGLAccount";
        public const String _GetGLAccountGrid = _PRCreationController + "getGLAccountGrid";
        public const String _GetWBS = _PRCreationController + "getWBS";
        public const String _GetWBSGrid = _PRCreationController + "getWBSGrid";
        public const String _GetVendor = _PRCreationController + "getVendor";
        public const String _GetAssetNo = _PRCreationController + "getAssetNo";
        public const String _GetVendorGrid = _PRCreationController + "getVendorGrid";
        public const String _GetAssetNoGrid = _PRCreationController + "getAssetNoGrid";
        public const String _GetAssetLocation = _PRCreationController + "getAssetLoc";

        public const String _AddPR = _PRCreationController + "GetPRNO";
        public const String _CancelCreation = _PRCreationController + "CancelCreation";
        public const String _SavePR = _PRCreationController + "SavePR";
        public const String _SaveHeader = _PRCreationController + "SaveHeader";
        public const String _GetFile = _PRCreationController + "GetFile";
        public const String _DeleteTempFiles = _PRCreationController + "DeleteTempFiles";
        public const String _EditDetailValidation = _PRCreationController + "EditDetailValidation";
        public const String _ValidateDownloadCreation = _PRCreationController + "ValidateDownload";

        public const String _GetItemTemp = _PRCreationController + "GetItemTempData";
        public const String _SaveItem = _PRCreationController + "SaveItem";
        public const String _DeleteItem = _PRCreationController + "DeleteItem";
        public const String _DeleteAllItem = _PRCreationController + "DeleteAllTempData";
        public const String _CopyData = _PRCreationController + "CopyData";

        public const String _GetSubItemTemp = _PRCreationController + "GetSubItemTempData";
        public const String _SaveSubItem = _PRCreationController + "SaveSubItem";
        public const String _DeleteSelectedSubItemTemp = _PRCreationController + "DeleteSelectedSubItemTemp";
        public const String _GetListItem = _PRCreationController + "GetListItemData";
#endregion

        public PRCreationController()
        {
            Settings.Title = "PR Creation Screen";
        }

        protected override void Startup()
        {
            ViewData["PRType"] = PRCommonRepository.Instance.GetDataPRType();
            ViewData["UOM"] = UnitOfMeasureRepository.Instance.GetAllData();
            CreatePR();
        }

        #region COMMON LIST 
        public static SelectList SelectAssetCat()
        {
            return PRCommonRepository.Instance
                    .GetDataAsset_Cat()
                    .AsSelectList(assetcat => assetcat.ASSET_CATEGORY_DESC, assetcat => assetcat.ASSET_CATEGORY_CD);
        }

        public static SelectList SelectAssetClass()
        {
            return PRCommonRepository.Instance
                    .GetDataAsset_Class()
                    .AsSelectList(assetclass => assetclass.ASSET_CLASS + ' ' + '-' + ' ' + assetclass.ASSET_CLASS_DESC, assetclass => assetclass.ASSET_CLASS);
        }

        public PartialViewResult GetSlocbyPlant(string param)
        {
            ViewData["Sloc"] = SLocRepository.Instance.GetSLocList(param);
            return PartialView("~/Views/PRInquiry/" + PurchaseRequisitionPage._CascadeSloc + ".cshtml"); ;
        }

        public PartialViewResult SelectCostCenter(int param = 0)
        {
            ViewData["CostCenter"] = PRCommonRepository.Instance.GetDataCostCenter(param);
            return PartialView(PurchaseRequisitionPage._CascadeCostCenter);
        }

        public PartialViewResult SelectCostCenterByCoordinator(string paramPrCoordinator, int paramDivId = 0)
        {
            ViewData["CostCenter"] = PRCommonRepository.Instance.GetDataCostCenterByCoordinator(paramPrCoordinator, paramDivId, this.GetCurrentRegistrationNumber());
            return PartialView(PurchaseRequisitionPage._CascadeCostCenter);
        }
        //FID.Ridwan: 20220705
        public PartialViewResult SelectCostCentertoFamsDB(string assetNo, string subassetNo)
        {
            ViewData["CostCenter"] = PRCommonRepository.Instance.GetDataCostCenterFamsDB(assetNo, subassetNo);
            return PartialView(PurchaseRequisitionPage._CascadeCostCenter);
        }
        #endregion

        #region GRID LOOKUP
        public ActionResult getValuationClass(PRCreation param, int pageSize = 10, int page = 1)
        {
            BindValuationClass(param, pageSize, page);
            return PartialView(PurchaseRequisitionPage._LookupValuationClass);
        }

        public ActionResult getValuationClassGrid(PRCreation param, int pageSize = 10, int page = 1)
        {
            BindValuationClass(param, pageSize, page);
            return PartialView(PurchaseRequisitionPage._LookupValuationClassGrid);
        }

        private void BindValuationClass(PRCreation param, int pageSize = 10, int page = 1)
        {
            ViewData["ValClass"] = PRCreationRepository.Instance.GetDataValuationClass(param, (page * pageSize), (((page - 1) * pageSize) + 1)).ToList();
            ViewData["Paging"] = CountIndex(PRCreationRepository.Instance.CountValClass(param), pageSize, page);
            ViewData["FUNC"] = "getValClassGrid";
        }

        public ActionResult getMaterial(PRCreation param, int pageSize = 10, int page = 1)
        {
            BindMaterial(param, pageSize, page);
            return PartialView(PurchaseRequisitionPage._LookupMaterial);
        }

        public ActionResult getMaterialGrid(PRCreation param, int pageSize = 10, int page = 1)
        {
            BindMaterial(param, pageSize, page);
            return PartialView(PurchaseRequisitionPage._LookupMaterialGrid);
        }

        private void BindMaterial(PRCreation param, int pageSize = 10, int page = 1)
        {
            ViewData["Material"] = PRCreationRepository.Instance.GetDataMatNumberConst(param, (page * pageSize), (((page - 1) * pageSize) + 1)).ToList();
            ViewData["Paging"] = CountIndex(PRCreationRepository.Instance.CountMatnoConst(param), pageSize, page);
            ViewData["FUNC"] = "getMaterialGrid";
        }

        public ActionResult getGLAccount(PRCreation param, int pageSize = 10, int page = 1)
        {
            BindGLAccount(param, pageSize, page);
            return PartialView(PurchaseRequisitionPage._LookupGLAccount);
        }

        public ActionResult getGLAccountGrid(PRCreation param, int pageSize = 10, int page = 1)
        {
            BindGLAccount(param, pageSize, page);
            return PartialView(PurchaseRequisitionPage._LookupGLAccountGrid);
        }

        private void BindGLAccount(PRCreation param, int pageSize = 10, int page = 1)
        {
            var valuelist = PRCreationRepository.Instance.GetGLAccount(param, (page * pageSize), (((page - 1) * pageSize) + 1)).ToList();
            ViewData["GLAccount"] = valuelist;
            ViewData["Paging"] = CountIndex(valuelist.Count(), pageSize,page);
            //ViewData["Paging"] = CountIndex(PRCreationRepository.Instance.CountGLAccount(param), pageSize, page);
            ViewData["FUNC"] = "getGLAccountGrid";
        }

        public ActionResult getWBS(PRCreation param, int pageSize = 10, int page = 1)
        {
            BindWBS(param, pageSize, page);
            return PartialView(PurchaseRequisitionPage._LookupWBS);
        }

        public ActionResult getWBSGrid(PRCreation param, int pageSize = 10, int page = 1)
        {
            BindWBS(param, pageSize, page);
            return PartialView(PurchaseRequisitionPage._LookupWBSGrid);
        }

        private void BindWBS(PRCreation param, int pageSize = 10, int page = 1)
        {
            List<PRCreation> wbs = PRCreationRepository.Instance.GetWBS(param, this.GetCurrentRegistrationNumber(), (page * pageSize), (((page - 1) * pageSize) + 1)).ToList();
            ViewData["WBS"] = wbs;
            ViewData["Paging"] = CountIndex(PRCreationRepository.Instance.CountWBS(param, this.GetCurrentRegistrationNumber()), pageSize, page);
            if (wbs.Count() == 0)
            {
                    string a = MessageRepository.Instance.GetMessageText("INF00005");
                ViewData["msg"] = a;

            }
            else
            {
                ViewData["msg"] = "";
            }
            ViewData["FUNC"] = "getWBSGrid";
        }

        public ActionResult getVendor(PRCreation param, int pageSize = 10, int page = 1)
        {
            BindVendor(param, pageSize, page);
            return PartialView(PurchaseRequisitionPage._LookupVendor);
        }
        public ActionResult getAssetNo(PRCreation param, int pageSize = 10, int page = 1)
        {
            BindAssetNo(param, pageSize, page);
            return PartialView(PurchaseRequisitionPage._LookupAssetNo);
        }

        public ActionResult getVendorGrid(PRCreation param, int pageSize = 10, int page = 1)
        {
            BindVendor(param, pageSize, page);
            return PartialView(PurchaseRequisitionPage._LookupVendorGrid);
        }
        public ActionResult getAssetNoGrid(PRCreation param, int pageSize = 10, int page = 1)
        {
            BindAssetNo(param, pageSize, page);
            return PartialView(PurchaseRequisitionPage._LookupAssetNoGrid);
        }

        private void BindVendor(PRCreation param, int pageSize = 10, int page = 1)
        {
            if (String.IsNullOrEmpty(param.VENDOR_PARAM)) param.VENDOR_PARAM = "";

            ViewData["Vendor"] = VendorRepository.Instance.GetListDataVenPr(param.VENDOR_PARAM, param.VALUATION_CLASS_PARAM, "", "", "", "", (((page - 1) * pageSize) + 1), (page * pageSize));
            ViewData["Paging"] = CountIndex(VendorRepository.Instance.CountDataPr(param.VENDOR_PARAM, param.VALUATION_CLASS_PARAM, "", "", "", ""), pageSize, page);
            ViewData["FUNC"] = "getVendorGrid";
        }
        //FID.Ridwan: 20220712 --> add wbs no param
        private void BindAssetNo(PRCreation param, int pageSize = 10, int page = 1)
        {
            if (String.IsNullOrEmpty(param.ASSETNO_PARAM)) param.ASSETNO_PARAM = "";

            ViewData["AssetNo"] = PRCreationRepository.Instance.GetListDataAssetNo(param.ASSETNO_PARAM, param.DIVISION_PARAM, "", "", "",param.WBS_PARAM, (((page - 1) * pageSize) + 1), (page * pageSize));
            ViewData["Paging"] = CountIndex(PRCreationRepository.Instance.CountDataAssetNo(param.ASSETNO_PARAM, param.DIVISION_PARAM, "", "", "", param.WBS_PARAM), pageSize, page);
            ViewData["FUNC"] = "getAssetNoGrid";
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


        public ActionResult getAssetLoc()
        {
            var data = PRCreationRepository.Instance.getAssetLocation();
            return Json(new { data }, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region PR CREATION INITIALIZE
        public string GetPRNO(string PR_NO)
        {
            string message = "";
            try
            {
                Tuple<Int64, string> newcreation = PRCreationRepository.Instance.CreationInit(this.GetCurrentUsername(), PR_NO, this.GetCurrentRegistrationNumber(), this.GetCurrentUserFullName());
                Session["ProcessID"] = newcreation.Item1;
                Session["PRNO"] = PR_NO;
                Session["Username"] = this.GetCurrentUsername();

                if ((newcreation.Item2 != "") && (newcreation.Item2 != null))
                    throw new Exception(newcreation.Item2);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            return message;
        }

        public void CreatePR()
        {
            string message = "";
            try
            {
                bool exist = Session["ProcessID"] != null;
                if (exist) exist = Session["ProcessID"].ToString() != "0";

                if (!exist)
                {
                    Tuple<Int64, string> datalock = PRCreationRepository.Instance.CheckLocking(this.GetCurrentUsername());

                    Int64 ProcessId = datalock.Item1;
                    if(ProcessId != 0) {
                        Session["ProcessID"] = ProcessId;
                        Session["Username"] = this.GetCurrentUsername();
                        Session["PRNO"] = datalock.Item2;
                        exist = true;
                    }
                    else
                        message = GetPRNO("0");
                }

                if(exist)
                {
                    exist = Session["ProcessID"].ToString() == "0";
                    if (exist) 
                        message = GetPRNO("0");

                    if (Session["Username"].ToString() != this.GetCurrentUsername())
                        message = GetPRNO("0");
                }

                if ((message != null) && (message != ""))
                    throw new Exception(message);

                string PR_NO = Session["PRNO"].ToString();
                Int64 PROCESS_ID = Convert.ToInt64(Session["ProcessID"]);

                message = DeleteTemporaryFolder(PROCESS_ID.ToString());
                if ((message != null) && (message != ""))
                    throw new Exception(message);

                Tuple<Dictionary<string, string[]>, List<string[]>, string, long, long, int, int, Tuple<string>> attachment = GetAttachmentFile(PROCESS_ID, PR_NO);
                ViewData["PR_TEMP_ATTACHMENT"] = attachment;
                if ((attachment.Rest.Item1 != null) && (attachment.Rest.Item1 != ""))
                    throw new Exception(attachment.Rest.Item1);

                Tuple<PRCreation, PRCreation, List<PRCreation>, string> PRData = GetPRData(PROCESS_ID);
                ViewData["ITEM_TEMP_DATA"] = PRData.Item3.ToList();
                ViewData["PR_H_TEMP_DATA"] = new Tuple<PRCreation, PRCreation, string, Int64>(PRData.Item1, PRData.Item2, PR_NO, PROCESS_ID);
                ViewData["LIST_TEMP_DATA"] = PRCreationRepository.Instance.GetListItem(PROCESS_ID);
                if ((PRData.Item4 != null) && (PRData.Item4 != ""))
                    throw new Exception(PRData.Item4);

                GetSlocbyPlant(PRData.Item2 != null ? PRData.Item2.PLANT_CD : "");
            }
            catch (Exception e)
            {
                ViewData["Message"] = e.Message;
            }
        }

        private Tuple<PRCreation, PRCreation, List<PRCreation>, string> GetPRData(Int64 PROCESS_ID)
        {
            string message = "";
            PRCreation userdescription = new PRCreation();
            PRCreation PRHTempData = new PRCreation();
            List<PRCreation> PRItemTempData = new List<PRCreation>();

            try
            {
                userdescription = PRCreationRepository.Instance.GetUserDescription(this.GetCurrentRegistrationNumber());
                if ((userdescription.MESSAGE != null) && (userdescription.MESSAGE != ""))
                    throw new Exception(userdescription.MESSAGE);

                PRHTempData = PRCreationRepository.Instance.GetTempPRH(PROCESS_ID);

                if (PRHTempData == null)
                    PRHTempData = new PRCreation();

                if ((PRHTempData.MESSAGE == null) || (PRHTempData.MESSAGE == ""))
                {
                    PRHTempData.PR_TYPE = String.IsNullOrEmpty(PRHTempData.PR_TYPE) ? "0" : PRHTempData.PR_TYPE.ToString();
                    PRHTempData.PR_DESC = String.IsNullOrEmpty(PRHTempData.PR_DESC) ? "" : PRHTempData.PR_DESC;
                    PRHTempData.PR_COORDINATOR = String.IsNullOrEmpty(PRHTempData.PR_COORDINATOR) ? "" : PRHTempData.PR_COORDINATOR;
                    PRHTempData.PLANT_CD = String.IsNullOrEmpty(PRHTempData.PLANT_CD) ? "" : PRHTempData.PLANT_CD;
                    PRHTempData.SLOC_CD = String.IsNullOrEmpty(PRHTempData.SLOC_CD) ? "" : PRHTempData.SLOC_CD;
                    PRHTempData.DIVISION_ID = String.IsNullOrEmpty(PRHTempData.DIVISION_ID) ? userdescription.DIVISION_ID.ToString() : PRHTempData.DIVISION_ID;
                    PRHTempData.URGENT_DOC = String.IsNullOrEmpty(PRHTempData.URGENT_DOC) ? "N" : PRHTempData.URGENT_DOC.ToString().Trim();
                    PRHTempData.PROJECT_NO = String.IsNullOrEmpty(PRHTempData.PROJECT_NO) ? "" : PRHTempData.PROJECT_NO;
                    PRHTempData.DELIVERY_DATE = PRHTempData.DELIVERY_DATE == "01.01.0001" ? String.Empty :
                                                (PRHTempData.DELIVERY_DATE == "01.01.1900" ? String.Empty : PRHTempData.DELIVERY_DATE);
                    PRHTempData.PR_NOTES = String.IsNullOrEmpty(PRHTempData.PR_NOTES) ? "" : PRHTempData.PR_NOTES;
                    PRHTempData.MAIN_ASSET_NO = String.IsNullOrEmpty(PRHTempData.MAIN_ASSET_NO) ? "" : PRHTempData.MAIN_ASSET_NO;
                }

                if ((PRHTempData != null) && (PRHTempData.MESSAGE != null) && (PRHTempData.MESSAGE != ""))
                    throw new Exception(PRHTempData.MESSAGE);

                PRItemTempData = PRCreationRepository.Instance.GetTempItem(PROCESS_ID);
            }
            catch (Exception e)
            {
                message = e.Message;
            }

            return new Tuple<PRCreation, PRCreation, List<PRCreation>, string>
                (userdescription, PRHTempData, PRItemTempData, message);
        }

        private Tuple<Dictionary<string, string[]>, List<string[]>, string, long, long, int, int, Tuple<string>> GetAttachmentFile(Int64 PROCESS_ID, string PR_NO)
        {
            string message = "";
            long maxFileSize = 0;
            long maxFileSizeQuot = 0;
            int maxUploadFile = 0;
            int maxQuot = 0;

            Dictionary<string, string[]> commonfile = new Dictionary<string, string[]>();
            List<string[]> quotationfile = new List<string[]>();
            string validextension = "";

            try
            {
                maxFileSize = Convert.ToInt64(SystemRepository.Instance.GetUploadFileSizeLimit());
                maxUploadFile = Convert.ToInt32(SystemRepository.Instance.GetSystemValue("UPLOAD_MAX_FILE"));
                maxQuot = Convert.ToInt16(SystemRepository.Instance.GetSystemValue("UPLOAD_MAX_QUOT"));
                maxFileSizeQuot = maxFileSize;

                validextension = SystemRepository.Instance.GetUploadDocumentFileExtension();

                Tuple<List<PRCreation>, string> attachmentfile = PRCreationRepository.Instance.GetAllTempAttachment(PROCESS_ID, PR_NO);
                if (attachmentfile.Item1.Count > 0)
                {
                    foreach (PRCreation a in attachmentfile.Item1)
                    {
                        if (a.DOC_TYPE != "QUOT")
                        {
                            commonfile.Add(a.DOC_TYPE, new string[]{
                                a.FILE_SEQ_NO.ToString(),
                                a.FILE_NAME_ORI.Length > 20 ? a.FILE_NAME_ORI.Substring(0, 20) + ". . ." : a.FILE_NAME_ORI, 
                                a.FILE_PATH
                            });
                        }
                        else
                        {
                            maxFileSizeQuot = maxFileSizeQuot - a.FILE_SIZE;
                            quotationfile.Add(new string[] {
                                a.FILE_SEQ_NO.ToString(),
                                a.FILE_NAME_ORI.Length > 20 ? a.FILE_NAME_ORI.Substring(0, 20) + ". . ." : a.FILE_NAME_ORI, 
                                a.FILE_PATH
                            });
                        }
                    }
                }

                if (attachmentfile.Item2 != "")
                    throw new Exception(attachmentfile.Item2);
            }
            catch (Exception e)
            {
                message = e.Message;
            }
            return new Tuple<Dictionary<string, string[]>, List<string[]>, string, long, long, int, int, Tuple<string>>
                                (commonfile, quotationfile, validextension, maxFileSize, maxFileSizeQuot, maxQuot, maxUploadFile, new Tuple<string>(message));
        }

        private string DeleteTemporaryFolder(string PROCESS_ID)
        {
            string mainpath = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
            string temppath = mainpath + SystemRepository.Instance.GetSystemValue("PR_UPLOAD_TEMP_PATH");
            string path = mainpath + SystemRepository.Instance.GetSystemValue("PR_UPLOAD_PATH");
            string lastprocessid = PRCreationRepository.Instance.GetLastProcessIDonTemp(this.GetCurrentUsername());
            string message = "";
            try
            {
                if (String.Compare(PROCESS_ID, lastprocessid) != 0)
                {
                    if (Directory.Exists(temppath + lastprocessid + "\\") && (lastprocessid != null))
                    {
                        DirectoryInfo DirInfo = new DirectoryInfo(temppath + lastprocessid + "\\");
                        foreach (FileInfo file in DirInfo.GetFiles()) { file.Delete(); }
                        Directory.Delete(temppath + lastprocessid + "\\", true);
                    }
                }
            }
            catch (Exception e)
            {
                message = e.Message;
            }

            return message;
        }
        #endregion

        #region SAVING PR
        public string SavePR(PRCreation param, string type)
        {
            Tuple<string, string> result = new Tuple<string, string>("SUCCESS", "");

            type = type.ToLower();

            result = PRCreationRepository.Instance.InitialValidation(param.PROCESS_ID, type);

            if (result.Item1 == "SUCCESS" && type == "submit")
                result = PRCreationRepository.Instance.SavingPRValidation(param);

            if (result.Item1 == "SUCCESS")
                result = SavePRProcessing(param, type, this.GetCurrentUsername(), this.GetCurrentRegistrationNumber());

            if (result.Item1 == "SUCCESS")
            {
                param.PR_NO = result.Item2;
                result = SavingPhysicalFile(param.PROCESS_ID, param.PR_NO);
            }

            switch (result.Item1)
            {
                case "SUCCESS":
                    {
                        Session["ProcessID"] = null;
                        return "SUCCESS|" + param.PR_NO;
                    }
                case "FAILED":
                    {
                        PRCreation ErrorLog = PRCreationRepository.Instance.GetErrorLog(Convert.ToInt64(param.PROCESS_ID));
                        String originalPath = new Uri(HttpContext.Request.Url.AbsoluteUri).OriginalString;
                        String logPath = originalPath.Substring(0, originalPath.LastIndexOf("/", originalPath.LastIndexOf("/") - 1)) + "/LogMonitoringDetail/?ProcessId=" + param.PROCESS_ID.ToString();
                        
                        return "ERROR|<p>There is Error while Saving Data : </p>" +
                                              "<p>Process ID : <a target='_blank' href='" + logPath + "'>" + param.PROCESS_ID + "</a></p>" +
                                              "<p>Location : " + ErrorLog.LOCATION + "</p>" +
                                              "<p>Message : " + ErrorLog.MESSAGE_CONTENT + "</p>";
                    }
                case "WARNING":
                    {
                        Session["ProcessID"] = null;
                        return "WARNING|" + param.PR_NO + "|" + result.Item2;
                    }
                default:
                    {
                        if (result.Item2 == "") 
                            return "ERROR|" + result.Item1;
                        else
                            return "ERROR|" + result.Item2;
                    }
            }
        }

        public Tuple<string, string> SavePRProcessing(PRCreation param, string type, string username, string noreg)
        {
            string FI_Year = "";
            string ErrorLocation = "";
            int errorbudget = 0;

            //Add int in tuple to save total row that needs to rollback in budget calculation, in case there is an error in budget calculation
            Tuple<string, string, int> rollbackResult = new Tuple<string, string, int>("", "", 0);
            Tuple<string, string, int> result = new Tuple<string, string, int>("SUCCESS", "", 0);
            
            if (result.Item1 == "SUCCESS" && type == "submit") 
                FI_Year = SystemRepository.Instance.GetSystemValue("FI_YEAR");

            if (result.Item1 == "SUCCESS" && ((Session["PRNO"] == null ? "0" : Session["PRNO"].ToString()) == "0"))
            {
                result = PRCreationRepository.Instance.GeneratePRNumber(param.PROCESS_ID, param.PR_TYPE, username);
                Session["PRNO"] = result.Item2;
            }

            if (result.Item1 == "SUCCESS")
            {
                if(param.PR_NO == "0") param.PR_NO = Session["PRNO"].ToString();
                if (type == "submit")
                {
                    if (param.PR_TYPE == "RR")
                        result = PRCreationRepository.Instance.QuotaProcessing(param, username, "Commit");
                }
            }

            if (result.Item1 == "SUCCESS" && type == "submit")
            {
                result = PRCreationRepository.Instance.BudgetProcessing(param, username, "Commit", 0);
                if (result.Item1 != "SUCCESS")
                {
                    ErrorLocation = "Budget";
                    errorbudget = result.Item3;
                }
            }

            if (result.Item1 == "SUCCESS")
            {
                result = PRCreationRepository.Instance.SavingProcessing(param, type, username, noreg);
                if (result.Item1 != "SUCCESS")
                    ErrorLocation = "Save";
            }

            if (result.Item1 != "SUCCESS" && (ErrorLocation == "Budget" || ErrorLocation == "Save") && type == "submit") 
                rollbackResult = PRCreationRepository.Instance.BudgetProcessing(param, username, "Rollback", errorbudget);

            if (result.Item1 != "SUCCESS" && (ErrorLocation == "Budget" || ErrorLocation == "Save") && type == "submit" && param.PR_TYPE == "RR")
                rollbackResult = PRCreationRepository.Instance.QuotaProcessing(param, username, "Rollback");

            return new Tuple<string,string>(result.Item1, result.Item2);
        }

        public string CancelCreation(string PROCESS_ID, string PR_NO)
        {
            string mainpath = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
            string temppath = mainpath + SystemRepository.Instance.GetSystemValue("PR_UPLOAD_TEMP_PATH");
            string result = "";
            try
            {
                result = PRCreationRepository.Instance.DeleteTempbyUser(PROCESS_ID, PR_NO);
                if (result == "SUCCESS")
                {
                    if (Directory.Exists(temppath + PROCESS_ID + "\\"))
                    {
                        DirectoryInfo DirInfo = new DirectoryInfo(temppath + PROCESS_ID + "\\");

                        foreach (FileInfo file in DirInfo.GetFiles())
                        {
                            file.Delete();
                        }
                        Directory.Delete(temppath + PROCESS_ID + "\\", true);
                    }
                    Session["ProcessID"] = null;
                }
                else
                    throw new Exception(result);
            }
            catch (Exception e)
            {
                result = e.Message;
            }
            return result;
        }

        #region FILE MANAGEMENT
        private Tuple<string, string> SavingPhysicalFile(string PROCESS_ID, string PR_NO)
        {
            string result = "";
            string status = "";
            try
            {
                string mainpath = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
                string temppath = mainpath + SystemRepository.Instance.GetSystemValue("PR_UPLOAD_TEMP_PATH");
                string historypath = mainpath + SystemRepository.Instance.GetSystemValue("PR_UPLOAD_HISTORY_PATH");
                string path = mainpath + SystemRepository.Instance.GetSystemValue("PR_UPLOAD_PATH");
                Tuple<List<PRCreation>, string> deletedFiles = PRCreationRepository.Instance.GetDeletedTempAttachment(PROCESS_ID);
                Tuple<List<PRCreation>, string> newFiles = PRCreationRepository.Instance.GetAttachedFile(PROCESS_ID);

                if (deletedFiles.Item2 == "SUCCESS")
                {
                    foreach (var item in deletedFiles.Item1)
                    {
                        if (!System.IO.Directory.Exists(historypath + PR_NO + "//"))
                            System.IO.Directory.CreateDirectory(historypath + PR_NO + "//");

                        if (System.IO.File.Exists(temppath + PROCESS_ID + "//" + item.FILE_PATH) && item.NEW_FLAG == "N")
                            System.IO.File.Move(temppath + PROCESS_ID + "//" + item.FILE_PATH, historypath + PR_NO + "//" + item.FILE_PATH);

                        if (System.IO.File.Exists((PR_NO == "0" ? temppath : path) + (PR_NO == "0" ? PROCESS_ID : PR_NO) + "//" + item.FILE_PATH))
                            System.IO.File.Delete((PR_NO == "0" ? temppath : path) + (PR_NO == "0" ? PROCESS_ID : PR_NO) + "//" + item.FILE_PATH);
                    }

                    if (newFiles.Item2 == "SUCCESS")
                    {
                        if (newFiles.Item1.Count > 0)
                        {
                            if (System.IO.Directory.Exists(temppath + PROCESS_ID + "//"))
                            {
                                if (!System.IO.Directory.Exists(path + PR_NO + "//"))
                                    System.IO.Directory.CreateDirectory(path + PR_NO + "//");

                                foreach (var file in Directory.EnumerateFiles(temppath + PROCESS_ID + "//"))
                                {
                                    var dest = Path.Combine(path + PR_NO + "//", Path.GetFileName(file));
                                    System.IO.File.Move(file, dest);
                                }
                                Directory.Delete(temppath + PROCESS_ID + "//", true);
                                status = "SUCCESS";
                            }
                            else
                            {
                                result = "Path : " + temppath + " doesnt exist";
                                status = "WARNING";
                            }
                        }
                        else
                            status = "SUCCESS";
                    }
                    else
                    {
                        result = newFiles.Item2;
                        status = "WARNING";
                    }
                }
                else
                {
                    result = deletedFiles.Item2;
                    status = "WARNING";
                }
            }
            catch (Exception e)
            {
                result = e.Message;
                status = "WARNING";
            }
            return new Tuple<string, string>(status, result);
        }
        #endregion
        #endregion

        #region TEMPORARY DATA MANAGEMENT
        /*public string EditDetailValidation(PRCreation param)
        {
            if (param.PR_NO != "0")
                return PRCreationRepository.Instance.EditDetailValidation(param);
            else
                return "";      
        }*/

        public void DeleteAllTempData(string PROCESS_ID)
        {
            PRCreationRepository.Instance.DeleteAllTempData(PROCESS_ID);
        }

        public string SaveHeader(PRCreation param)
        {
            string result = "SUCCESS";
            try
            {
                result = PRCreationRepository.Instance.InsertTempHeader(param, this.GetCurrentUsername());
            }
            catch (Exception e)
            {
                result = e.Message;
            }
            return result;
        }

        #region Item Temp Data Management
        public string SaveItem(PRCreation param)
        {
            string result = "SUCCESS";
            try
            {
                if (param.ITEM_CLASS == "S")
                {
                    param.ITEM_CLASS_DESC = "Service";
                }
                else if (param.ITEM_CLASS == "M")
                {
                    param.ITEM_CLASS_DESC = "Material";
                }

                if (param.ITEM_NO == "0")
                    param.ITEM_NO = PRCreationRepository.Instance.GetLatestSeqItem(param.PROCESS_ID, param.PR_TYPE);

                result = PRCreationRepository.Instance.InsertTempItem(param, this.GetCurrentUsername());
            }
            catch (Exception e) 
            {
                result = e.Message;
            }
            return result;
        }

        public ActionResult GetItemTempData(string PROCESS_ID)
        {
            try
            {
                List<PRCreation> ITEM_TEMP_DATA = PRCreationRepository.Instance.GetTempItem(Int64.Parse(PROCESS_ID));
                ViewData["ITEM_TEMP_DATA"] = ITEM_TEMP_DATA;
                return PartialView(PurchaseRequisitionPage._CreationItemGrid);
            }
            catch (Exception e) {
                return Json(new PRCreation() { PROCESS_STATUS = "ERR", MESSAGE_CONTENT = e.Message });
            } 
        }

        public ActionResult GetListItemData(string PROCESS_ID)
        {
            try
            {
                List<PRCreation> ITEM_TEMP_DATA = PRCreationRepository.Instance.GetListItem(Int64.Parse(PROCESS_ID));
                ViewData["LIST_TEMP_DATA"] = ITEM_TEMP_DATA;
                return PartialView(PurchaseRequisitionPage._LookupItem);
            }
            catch (Exception e)
            {
                return Json(new PRCreation() { PROCESS_STATUS = "ERR", MESSAGE_CONTENT = e.Message });
            }
        }

        public string DeleteItem(string ITEM_NO, string PROCESS_ID)
        {
            string result = PRCreationRepository.Instance.DeleteItem(PROCESS_ID, ITEM_NO); 
            return result;
        }

        public string CopyData(string ITEM_NO, string SUBITEM_NO, string TYPE, string PR_TYPE, string PROCESS_ID)
        {
            string NEW_ITEM_NO = "";
            string NEW_SUBITEM_NO = "";

            if (TYPE == "item")
                NEW_ITEM_NO = PRCreationRepository.Instance.GetLatestSeqItem(PROCESS_ID, PR_TYPE);
            else
                NEW_SUBITEM_NO = PRCreationRepository.Instance.GetLatestSeqSubItem(PROCESS_ID, ITEM_NO, PR_TYPE);

            string result = PRCreationRepository.Instance.CopyData(ITEM_NO, SUBITEM_NO, TYPE, this.GetCurrentUsername(), PROCESS_ID, NEW_ITEM_NO, NEW_SUBITEM_NO);
            return result;
        }
        #endregion

        #region Sub Item Temp Data Management
        public string SaveSubItem(PRCreation param)
        {
            string result = "";
            try
            {
                if (param.SUBITEM_NO == "0")
                    param.SUBITEM_NO = PRCreationRepository.Instance.GetLatestSeqSubItem(param.PROCESS_ID, param.ITEM_NO, param.PR_TYPE);

                result = PRCreationRepository.Instance.InsertTempSubItem(param, this.GetCurrentUsername());
            }
            catch (Exception e)
            {
                result = e.Message;
            }
            return result;
        }

        public ActionResult GetSubItemTempData(string PROCESS_ID, string ITEM_NO, string type, string addeditflag)
        {
            try
            {
                List<PRCreation> SUB_ITEM_TEMP_DATA = PRCreationRepository.Instance.GetTempSubItem(Int64.Parse(PROCESS_ID), ITEM_NO);
                ViewData["SUB_ITEM_PR"] = SUB_ITEM_TEMP_DATA;
                ViewData["ITEM_NO"] = ITEM_NO;
                ViewData["ADDEDIT_FLAG"] = addeditflag;
                ViewData["UOM"] = UnitOfMeasureRepository.Instance.GetAllData();
                
                if (type == "init") return PartialView(PurchaseRequisitionPage._CreationSubItem);
                else return PartialView(PurchaseRequisitionPage._CreationSubItemGrid);

            }
            catch (Exception e)
            {
                return Json(new PRCreation() { PROCESS_STATUS = "ERR", MESSAGE_CONTENT = e.Message });
            }
        }

        public string DeleteSelectedSubItemTemp(string PROCESS_ID, string ITEM_NO, string SUBITEM_NO)
        {
            return PRCreationRepository.Instance.DeleteSelectedTempSubItem(PROCESS_ID, ITEM_NO, SUBITEM_NO);
        }
        #endregion

        #endregion

        #region TEMPORARY FILE MANAGEMENT
        [HttpPost]
        public ActionResult GetFile(HttpPostedFileBase file, string DOC_TYPE, string PR_NO, string PROCESS_ID)
        {
            PRCreation FileData = new PRCreation();
            string mainpath = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
            string temppath = mainpath + SystemRepository.Instance.GetSystemValue("PR_UPLOAD_TEMP_PATH");
            Tuple<List<PRCreation>, string> AttachmentData = new Tuple<List<PRCreation>, string>(new List<PRCreation>(), "");

            try
            {
                if (file == null)
                {
                    throw new Exception("File is Null, Please Upload Again");
                }

                string filename = DOC_TYPE + "_" + DateTime.Now.ToString("ddMMyyyyHHmmssffff") + Path.GetExtension(file.FileName);
                if (!Directory.Exists(temppath + PROCESS_ID + "\\"))
                    Directory.CreateDirectory(temppath + PROCESS_ID + "\\");

                var newpath = temppath + PROCESS_ID + "\\" + filename;

                file.SaveAs(newpath);

                FileData.PR_NO = PR_NO;
                FileData.PROCESS_ID = PROCESS_ID;
                FileData.DOC_TYPE = DOC_TYPE;
                FileData.FILE_EXTENSION = Path.GetExtension(file.FileName);
                FileData.FILE_SIZE = file.ContentLength;
                FileData.FILE_PATH = filename;
                FileData.FILE_NAME_ORI = file.FileName;

                string result = PRCreationRepository.Instance.SaveTempAttachment(FileData, this.GetCurrentUsername());
                if (result != "SUCCESS")
                    throw new Exception(result);

                AttachmentData = PRCreationRepository.Instance.GetTempAttachment(this.GetCurrentUsername(), FileData.PR_NO, FileData.DOC_TYPE);
                if((AttachmentData.Item2 != "") && (AttachmentData.Item2 != null))
                    throw new Exception(AttachmentData.Item2);

                return Json(AttachmentData.Item1);
            }
            catch (Exception ex)
            {
                return Json(new PRCreation() { PROCESS_STATUS = "ERR", MESSAGE_CONTENT = ex.ToString() });
            }
        }

        public ActionResult DeleteTempFiles(string PR_NO, string SEQ_NO, string PROCESS_ID, string FILE_PATH)
        {
            return Json(PRCreationRepository.Instance.DeleteTempFiles(this.GetCurrentUsername(), PR_NO, SEQ_NO, PROCESS_ID));
        }

        private string GetMimeType(string fileName)
        {
            string mimeType = "application/unknown";
            string ext = Path.GetExtension(fileName).ToLower();
            Microsoft.Win32.RegistryKey regKey = Microsoft.Win32.Registry.ClassesRoot.OpenSubKey(ext);
            if (regKey != null && regKey.GetValue("Content Type") != null)
                mimeType = regKey.GetValue("Content Type").ToString();
            return mimeType;
        }

        public string ValidateDownload(string path, string id)
        {
            id = id.Trim();
            path = path.Trim();
            string mainpath = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
            string temppath = SystemRepository.Instance.GetSystemValue("PR_UPLOAD_TEMP_PATH");
            string fixpath = SystemRepository.Instance.GetSystemValue("PR_UPLOAD_PATH");
            string fix_attachment_path = mainpath + fixpath + "\\" + id + "\\" + path;
            string temp_attachment_path = mainpath + temppath + "\\" + id + "\\" + path;

            if (System.IO.File.Exists(fix_attachment_path)) return "Y";
            if (System.IO.File.Exists(temp_attachment_path)) return "Y";
            else return "<p>File Not Found in " + mainpath + fixpath + "\\" + id + "\\" + 
                        "</p><p> Or in " + mainpath + temppath + "\\" + id + "\\" + "</p>";
        } 

        public void DownloadFile(string path, string id) {
            id = id.Trim();
            path = path.Trim();
            string mainpath = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
            string temppath = SystemRepository.Instance.GetSystemValue("PR_UPLOAD_TEMP_PATH");
            string fixpath = SystemRepository.Instance.GetSystemValue("PR_UPLOAD_PATH");
            string fix_attachment_path = mainpath + fixpath + "\\" + id + "\\" + path;
            string temp_attachment_path = mainpath + temppath + "\\" + id + "\\" + path;
            string filename = path;
            string mime = GetMimeType(path);

            if (System.IO.File.Exists(fix_attachment_path)) path = fix_attachment_path;
            else path = temp_attachment_path;

            Response.Clear();
            Response.ContentType = mime;
            Response.AppendHeader( "content-disposition", "attachment; filename=" + filename );
            Response.TransmitFile(path);
            Response.End();
        } 
        #endregion
    }
}
