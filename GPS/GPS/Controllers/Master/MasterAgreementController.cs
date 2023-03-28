using System;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.Models.Master;
using Toyota.Common.Web.Platform;
using System.Text.RegularExpressions;
using System.IO;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using System.Collections.Generic;

namespace GPS.Controllers.Master
{
    public class MasterAgreementController : PageController
    {
        #region List Of Controller Method
        public sealed class Action
        {
            public const String _getdata = "/BudgetConfig/GetData";
            public const String _updatedata = "/BudgetConfig/UpdateData";

            public const String _getLookupWBSGrid = "/BudgetConfig/getLookupWBSGrid";
            public const String _getLookupWBSPage = "/BudgetConfig/getLookupWBSPage";

            public const String _SaveEditDeleteData = "/BudgetConfig/SaveEditDeleteData";
            public const String _DeleteData = "/BudgetConfig/DeleteData";

            public const String _CheckTemplate = "/BudgetConfig/CheckTemplate";

            public const String _UploadFile = "/BudgetConfig/UploadFile";

        }
        #endregion

        public MasterAgreementController()
        {
            Settings.Title = "Master Agreement No Screen";
        }

        protected override void Startup()
        {
            ViewData["FI_YEAR"] = SystemRepository.Instance.GetSystemValue("FI_YEAR");

            int DIVISION_ID = DivisionRepository.Instance.GetUserDivision(this.GetCurrentRegistrationNumber());
            TempData["DIVISION_ID"] = DIVISION_ID;
        }

        #region 20190702 ~ 20190703 : isid.rgl : Fungsi Upload
        public ActionResult CheckTemplate()
        {
            string cektemplate = "";

            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/Template/BUDGET_CONFIG.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
                cektemplate = "True";
            else
                cektemplate = "False";

            return Json(cektemplate, JsonRequestBehavior.AllowGet);
        }
        public FileContentResult DownloadTemplate()
        {
            string filepath = HttpContext.Request.MapPath("~/Content/Download/Template/BUDGET_CONFIG.xls");
            byte[] docBytes = StreamFile(filepath);

            return File(docBytes, "application/vmd.ms-excel", "BUDGET_CONFIG.xls");
        }
        private byte[] StreamFile(string filename)
        {
            FileStream fs = new FileStream(filename, FileMode.Open, FileAccess.Read);
            byte[] ImageData = new byte[fs.Length];

            fs.Read(ImageData, 0, Convert.ToInt32(fs.Length));

            fs.Close();

            return ImageData;
        }
        public FileResult DownloadUploadedResult(string path)
        {
            try
            {
                String mimeType = "application/vnd.ms-excel";
                Byte[] result = FileManager.ReadFile(path.Substring(0, path.IndexOf(Path.GetFileName(path))), Path.GetFileName(path));
                return File(result, mimeType, Path.GetFileName(path));
            }
            catch (Exception ex)
            {
                var errorFile = PdfFileCreator.GenerateErrorInfoTextFile(ex);
                return File(errorFile.FileByteArray, errorFile.MimeType, errorFile.Filename);
            }
        }

        [HttpPost]
        public ActionResult UploadFile()
        {
            string resultFilePath = "";
            string savefile = "";
            string result = "";
            int ierror = 0;
            try
            {
                #region Get File
                var file = Request.Files[0];
                var filename = Path.GetFileName(file.FileName);
                savefile = Path.Combine(Server.MapPath("~/Content/UploadFile"), filename);
                resultFilePath = Path.Combine("~/Content/UploadFile", filename);
                file.SaveAs(Server.MapPath(resultFilePath));

                FileStream fs = new FileStream(Server.MapPath(resultFilePath), FileMode.OpenOrCreate, FileAccess.ReadWrite);
                HSSFWorkbook wb = new HSSFWorkbook(fs);
                ISheet sheet = wb.GetSheet("BudgetConfig");

                for (int i = 1; i <= sheet.LastRowNum; i++)
                {
                    string[] msg;
                    string message = "";

                    #region Mandatory Checking
                    if (sheet.GetRow(i).GetCell(0) == null)
                        message = message + "WBS No Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(0).ToString().Trim()))
                        message = message + "WBS No Should Not be Empty\n";

                    if (sheet.GetRow(i).GetCell(1) == null)
                        message = message + "WBS Year Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(1).ToString().Trim()))
                        message = message + "WBS Year Should Not be Empty\n";

                    if (sheet.GetRow(i).GetCell(2) == null)
                        message = message + "WBS Type Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(2).ToString().Trim()))
                        message = message + "WBS Type Should Not be Empty\n";

                    #endregion

                    #region Data Length Checking
                    if (message == "")
                    {
                        if (sheet.GetRow(i).GetCell(0).ToString().Trim().Length > 30)
                            message = message + "WBS No Should Not be More Than 30 Character\n";

                        if (sheet.GetRow(i).GetCell(1).ToString().Trim().Length > 4)
                            message = message + "WBS Year Should Not be More Than 4 Character\n";

                        if (sheet.GetRow(i).GetCell(2).ToString().Trim().Length > 30)
                            message = message + "WBS Type Should Not be More Than 30 Character\n";
                    }
                    #endregion


                    if (message == "")
                    {
                        BudgetConfig data = new BudgetConfig();

                        data.WBS_NO = sheet.GetRow(i).GetCell(0).ToString().Trim();
                        data.WBS_YEAR = sheet.GetRow(i).GetCell(1).ToString().Trim();
                        data.WBS_TYPE = sheet.GetRow(i).GetCell(2).ToString().Trim();

                        message = BudgetConfigRepository.Instance.SaveUploadedData(data, this.GetCurrentUsername());
                        if (message != "SUCCESS")
                        {
                            msg = message.Split('|');
                            if (msg[0].ToString() == "ERROR")
                            {
                                ierror++;
                            }
                        }
                    }

                    if (sheet.GetRow(i).GetCell(4) == null)
                        sheet.GetRow(i).CreateCell(4);

                    if (message.Substring(message.Length - 2, 2) == "\n")
                        message = message.Substring(0, message.Length - 2);

                    sheet.GetRow(i).GetCell(4).SetCellValue(message);
                    sheet.GetRow(i).GetCell(4).CellStyle.WrapText = true;
                }

                using (FileStream tfile = new FileStream(Path.Combine(Server.MapPath("~/Content/UploadFile"), filename), FileMode.Open, FileAccess.Write))
                {
                    wb.Write(tfile);
                    tfile.Close();
                }

                if (ierror != 0)
                {
                    result = "SuccessWithError|" + Path.Combine(Server.MapPath("~/Content/UploadFile"), filename);
                }
                else
                {
                    result = "Success|" + Path.Combine(Server.MapPath("~/Content/UploadFile"), filename);
                }
                #endregion
            }
            catch (Exception e)
            {
                result = e.Message.ToString();
                return Json(new { message = "Error|" + result }, JsonRequestBehavior.AllowGet);
            }

            return Json(new { message = result }, JsonRequestBehavior.AllowGet);
        }

        #endregion

        #region 20190717 : isid.rgl : combobox WBS Type
        public static SelectList SelectWBSType()
        {
            return BudgetConfigRepository.Instance
                    .GetAllData()
                    .AsSelectList(x => x.WBS_TYPE, x => x.WBS_TYPE);
        }
        public ActionResult IsFlagEditAdd(String flag, String wbsno)
        {
            ViewData["edit"] = flag;
            ViewData["BudgetConfigData"] = flag == "0"
                ? new BudgetConfig()
                : BudgetConfigRepository.Instance.GetSelectedData(wbsno);

            return PartialView("_AddEditPopUp");
        }

        public ActionResult SearchData(int Display, int Page, string Division_ID, string WBS_No, string WBS_Year, string WBS_Name)
        {
            BudgetConfig param = new BudgetConfig();
            param.WBS_NO = WBS_No;
            param.WBS_NAME = WBS_Name;
            param.WBS_YEAR = WBS_Year;
            param.DIVISION_ID = Division_ID;

            Calldata(Display, Page, param);
            return PartialView("_Grid");
        }

        private void Calldata(int Display, int Page, BudgetConfig param)
        {
            Paging pg = new Paging(BudgetConfigRepository.Instance.CountData(param), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["BUDGET_DATA"] = BudgetConfigRepository.Instance.GetListData(param, pg.StartData, pg.EndData);
        }
        #endregion

        #region 20190718 : isid.rgl : Popup WBS
        public ActionResult getLookupWBSGrid(string WBS_Year, string WBS_No, string WBS_Name, int pageSize, int page)
        {
            BudgetConfig param = new BudgetConfig();
            param.WBS_NO = WBS_No;
            param.WBS_YEAR = WBS_Year;
            param.WBS_NAME = WBS_Name;

            BindLookupWBS(param, pageSize, page);
            return PartialView("_LookupDataWBSGrid");
        }
        public ActionResult getLookupWBSPage(string WBS_Year, string WBS_No, string WBS_Name, int pageSize, int page)
        {
            BudgetConfig param = new BudgetConfig();
            param.WBS_NO = WBS_No;
            param.WBS_YEAR = WBS_Year;
            param.WBS_NAME = WBS_Name;

            BindLookupWBS(param, pageSize, page);
            return PartialView("_LookupDataWBSPage");
        }
        private void BindLookupWBS(BudgetConfig param, int pageSize, int page)
        {
            Paging pg = new Paging(BudgetConfigRepository.Instance.CountDataByFreeParam(param), page, pageSize);
            ViewData["Paging"] = pg;

            ViewData["LookWBSClass"] = BudgetConfigRepository.Instance.GetDataLookupWbsByFreeParam(param, pg.StartData, pg.EndData);
            ViewData["FUNC"] = "getLookupWbsClassGrid";
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
        #endregion

        #region : 20190719 : isid.rgl : SAVE / EDIT DATE
        public ActionResult SaveEditDeleteData(string flag, string WbsYear, string WbsName, string division, string WbsNo, string WbsType)
        {
            String msg = "";
            BudgetConfig param = new BudgetConfig();
            param.WBS_NO = WbsNo;
            param.WBS_NAME = WbsName;
            param.WBS_YEAR = WbsYear;
            param.WBS_TYPE = WbsType;
            try
            {
                msg = BudgetConfigRepository.Instance.SaveEditDeleteData(flag, this.GetCurrentUsername(), param);
            }
            catch (Exception ex)
            {
                msg = ex.Message + ", stack : " + ex.StackTrace;
                return Json("Error|" + msg, JsonRequestBehavior.AllowGet);
            }
            return Json(msg, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region : 20190719 : isid.rgl : Delete Data

        #endregion

        #region ark.herman 23/3/2023
        public static SelectList GetStatusList()
        {
            return MasterAgreementRepository.Instance
                .GetSTSAgreement()
                .AsSelectList(div => div.SYSTEM_CD + " - " + div.SYSTEM_VALUE,
                    div => div.SYSTEM_CD);
        }

        /// <summary>
        /// INSERT DATA TO TB_M_AGREEMENT_NO
        /// </summary>
        public ActionResult SaveData(String flag, String vendorcd, String vendornm, String purchasinggrp, String buyer, String agreementno, String startdate, String expdate,String status,String nextaction)
        {
            startdate = conversiDate(startdate);
            expdate = conversiDate(expdate);
            //String message = "";
            String message = MasterAgreementRepository.Instance.SaveData(flag, vendorcd, vendornm, purchasinggrp, buyer, agreementno, startdate, expdate,status,nextaction, this.GetCurrentUsername());

            return new JsonResult { Data = new { message } };
        }




        protected string conversiDate(string tgl)
        {
            string result = "";
            string[] dt = null;

            if (tgl != "")
            {
                dt = tgl.Split('.');
                tgl = dt[2] + "-" + dt[1] + "-" + dt[0];

                result = tgl;
            }
            return result;
        }

        #endregion
    }
}
