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

        #region ark.herman 23/3/2023
        public ActionResult IsFlagEditAdd(String flag, String VendorCode)
        {
            ViewData["edit"] = flag;
            ViewData["MasterAgreementData"] = flag == "0"
                ? new MasterAgreement()
                : MasterAgreementRepository.Instance.GetSelectedData(VendorCode);

            return PartialView("_AddEditPopUp");
        }

        private void Calldata(int Display, int Page, string VendorCode, string VendorName, string AgreementNo, string Status)
        {
            Paging pg = new Paging(MasterAgreementRepository.Instance.CountData(VendorCode, VendorName, AgreementNo, Status), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["ListMasterAgreement"] = MasterAgreementRepository.Instance.GetListData(VendorCode, VendorName, AgreementNo, Status, pg.StartData, pg.EndData);
        }

        [HttpPost]
        public ActionResult SearchData(int Display, int Page, string VendorCode, string VendorName, string AgreementNo, string Status)
        {
            Calldata(Display, Page, VendorCode, VendorName, AgreementNo, Status);
            return PartialView("_Grid");
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

        public ActionResult DeleteData(String key)
        {
            string message = "";

            try
            {
                message = MasterAgreementRepository.Instance.DeleteData(key, this.GetCurrentUsername());
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
                return Json("Error|" + message, JsonRequestBehavior.AllowGet);
            }

            return Json(message, JsonRequestBehavior.AllowGet);
        }


        public static SelectList GetStatusList()
        {
            return MasterAgreementRepository.Instance
                .GetSTSAgreement()
                .AsSelectList(div => div.SYSTEM_CD + " - " + div.SYSTEM_VALUE,
                    div => div.SYSTEM_CD);
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
                ISheet sheet = wb.GetSheet("MasterAgreement");

                for (int i = 1; i <= sheet.LastRowNum; i++)
                {
                    string message = "";

                    #region Mandatory Checking
                    if (sheet.GetRow(i).GetCell(1) == null)
                        message = message + "Vendor Code Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(1).ToString().Trim()))
                        message = message + "Vendor Code Should Not be Empty\n";
                    if (sheet.GetRow(i).GetCell(2) == null)
                        message = message + "Purchasing Group Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(2).ToString().Trim()))
                        message = message + "Purchasing Group Should Not be Empty\n";
                    if (sheet.GetRow(i).GetCell(3) == null)
                        message = message + "Buyer Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(3).ToString().Trim()))
                        message = message + "Buyer Should Not be Empty\n";
                    if (sheet.GetRow(i).GetCell(4) == null)
                        message = message + "Agreement No Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(4).ToString().Trim()))
                        message = message + "Agreement No Should Not be Empty\n";
                    if (sheet.GetRow(i).GetCell(5) == null)
                        message = message + "Start Date Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(5).ToString().Trim()))
                        message = message + "Start Date Should Not be Empty\n";
                    if (sheet.GetRow(i).GetCell(6) == null)
                        message = message + "Expired Date From Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(6).ToString().Trim()))
                        message = message + "Expired Date Should Not be Empty\n";
                    if (sheet.GetRow(i).GetCell(7) == null)
                        message = message + "Next Action Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(7).ToString().Trim()))
                        message = message + "Next Action Should Not be Empty\n";
                    #endregion

                    var a = sheet.GetRow(i).GetCell(1).ToString().Trim();
                    var b = sheet.GetRow(i).GetCell(2).ToString().Trim();
                    var c = sheet.GetRow(i).GetCell(3).ToString().Trim();

                    #region Data Length Checking
                    if (message == "")
                    {

                        if (sheet.GetRow(i).GetCell(5).ToString().Trim().Length > 10)
                            message = message + "Start Date Should Not be More Than 10 Character\n";
                        if (sheet.GetRow(i).GetCell(6).ToString().Trim().Length > 10)
                            message = message + "End Date Should Not be More Than 10 Character\n";
                       
                    }
                    #endregion

                    #region Date Format Checking
                    if (message == "")
                    {
                        if (!sheet.GetRow(i).GetCell(5).ToString().Trim().Contains("."))
                            message = message + "Start Date is not in Correct Format. Valid Format : dd.MM.yyyy\n";
                        if (!sheet.GetRow(i).GetCell(6).ToString().Trim().Contains("."))
                            message = message + "Expired Date is not in Correct Format. Valid Format : dd.MM.yyyy\n";
                    }

                    if (message == "")
                    {
                        DateTime dStartDate;
                        string startdatetemp = sheet.GetRow(i).GetCell(5).ToString().Trim().Substring(3, 2) + "/" + sheet.GetRow(i).GetCell(5).ToString().Trim().Substring(0, 2) + "/" + sheet.GetRow(i).GetCell(5).ToString().Trim().Substring(6, 4);
                        if (!DateTime.TryParse(startdatetemp, out dStartDate))
                            message = message + "Start Date is not in Correct Format. Valid Format : dd.MM.yyyy\n";

                        DateTime dEndDate;
                        string enddatetemp = sheet.GetRow(i).GetCell(6).ToString().Trim().Substring(3, 2) + "/" + sheet.GetRow(i).GetCell(6).ToString().Trim().Substring(0, 2) + "/" + sheet.GetRow(i).GetCell(6).ToString().Trim().Substring(6, 4);
                        if (!DateTime.TryParse(enddatetemp, out dEndDate))
                            message = message + "Expired Date is not in Correct Format. Valid Format : dd.MM.yyyy\n";
                    }
                    #endregion

                    #region Numeric Checking
                    //if (message == "")
                    //{
                    //    if (sheet.GetRow(i).GetCell(3) != null)
                    //    {
                    //        if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(2).ToString().Trim()))
                    //        {
                    //            Int16 dInt;
                    //            if (!Int16.TryParse(sheet.GetRow(i).GetCell(2).ToString().Trim(), out dInt))
                    //                message = message + "Due Dilligence Status is not in correct format\n";
                    //        }
                    //    }
                    //}
                    #endregion

                    if (message == "")
                    {
                        MasterAgreement data = new MasterAgreement();

                        data.VENDOR_CODE = sheet.GetRow(i).GetCell(1).ToString().Trim();
                        data.PURCHASING_GROUP = sheet.GetRow(i).GetCell(2).ToString().Trim();
                        data.BUYER = sheet.GetRow(i).GetCell(3).ToString().Trim();
                        data.AGREEMENT_NO = sheet.GetRow(i).GetCell(4).ToString().Trim();
                        data.START_DATE = sheet.GetRow(i).GetCell(5).ToString().Trim();
                        data.EXP_DATE = sheet.GetRow(i).GetCell(6).ToString().Trim();
                        data.NEXT_ACTION = sheet.GetRow(i).GetCell(7).ToString().Trim();

                        message = MasterAgreementRepository.Instance.SaveUploadedData(data, this.GetCurrentUsername());
                    }

                    if (sheet.GetRow(i).GetCell(10) == null)
                        sheet.GetRow(i).CreateCell(10);

                    if (message.Substring(message.Length - 2, 2) == "\n")
                        message = message.Substring(0, message.Length - 2);

                    sheet.GetRow(i).GetCell(10).SetCellValue(message);
                    sheet.GetRow(i).GetCell(10).CellStyle.WrapText = true;
                }

                using (FileStream tfile = new FileStream(Path.Combine(Server.MapPath("~/Content/UploadFile"), filename), FileMode.Open, FileAccess.Write))
                {
                    wb.Write(tfile);
                    tfile.Close();
                }

                result = "Success|" + Path.Combine(Server.MapPath("~/Content/UploadFile"), filename);
                #endregion
            }
            catch (Exception e)
            {
                result = e.Message.ToString();
                return Json(new { message = "Error|" + result }, JsonRequestBehavior.AllowGet);
            }

            return Json(new { message = result }, JsonRequestBehavior.AllowGet);
        }

        public FileContentResult DownloadTemplate()
        {
            string filepath = Path.Combine(Server.MapPath("~/Content/Download/Template/MasterAgreementUploadTemplate.xls"));
            byte[] docBytes = StreamFile(filepath);

            return File(docBytes, "application/vmd.ms-excel", "MasterAgreementUploadTemplate.xls");
        }

        private byte[] StreamFile(string filename)
        {
            FileStream fs = new FileStream(filename, FileMode.Open, FileAccess.Read);
            byte[] ImageData = new byte[fs.Length];

            fs.Read(ImageData, 0, Convert.ToInt32(fs.Length));

            fs.Close();

            return ImageData;
        }

        public ActionResult CekTemplate()
        {
            string cektemplate = "";

            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/Template/MasterAgreementUploadTemplate.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
                cektemplate = "True";
            else
                cektemplate = "False";

            return Json(cektemplate, JsonRequestBehavior.AllowGet);
        }

        #endregion
    }
}
