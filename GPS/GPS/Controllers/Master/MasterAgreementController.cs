using GPS.CommonFunc;
using GPS.Models;
using GPS.Models.Common;
using GPS.Models.Master;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using System;
using System.Collections.Generic;
using System.IO;
using System.Web.Mvc;
using Toyota.Common.Utilities;
using Toyota.Common.Web.Platform;

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

            ViewData["DOC_STS"] = SystemRepository.Instance.GetSingleData("AGR01", "StatusDoc").Value;
        }

        #region ark.herman 23/3/2023
        public ActionResult IsFlagEditAdd(String flag, String VendorCode, String AgreementNo, String ExpDate, String Identity)
        {
            ViewData["edit"] = flag;
            ViewData["MasterAgreementData"] = flag == "0"
                ? new MasterAgreement()
                : MasterAgreementRepository.Instance.GetSelectedData(VendorCode, AgreementNo, ExpDate, Identity);

            return PartialView("_AddEditPopUp");
        }

        private void Calldata(int Display, int Page, string VendorCode, string VendorName, string AgreementNo, string Status, string DateFrom, string DateTo)
        {
            Paging pg = new Paging(MasterAgreementRepository.Instance.CountData(VendorCode, VendorName, AgreementNo, Status, DateFrom, DateTo), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["ListMasterAgreement"] = MasterAgreementRepository.Instance.GetListData(VendorCode, VendorName, AgreementNo, Status, pg.StartData, pg.EndData, DateFrom, DateTo);
        }

        [HttpPost]
        public ActionResult SearchData(int Display, int Page, string VendorCode, string VendorName, string AgreementNo, string Status, string ExpDate)
        {
            string DateFrom = "";
            string DateTo = "";

            if (!ExpDate.IsNullOrEmpty())
            {
                string[] DateRange = ExpDate.Split('-');
                DateFrom = DateRange[0];
                DateTo = DateRange[1];
            }

            Calldata(Display, Page, VendorCode, VendorName, AgreementNo, Status, DateFrom, DateTo);
            return PartialView("_Grid");
        }

        /// <summary>
        /// INSERT DATA TO TB_M_AGREEMENT_NO
        /// </summary>
        public ActionResult SaveData()
        {
            var filename = "";

            MasterAgreement NewAgreement = new MasterAgreement
            {
                VENDOR_CODE = Request.Params[0],
                VENDOR_NAME = Request.Params[1],
                PURCHASING_GROUP = Request.Params[2],
                BUYER = Request.Params[3],
                AGREEMENT_NO = Request.Params[4],
                START_DATE = conversiDate(Request.Params[5]),
                EXP_DATE = conversiDate(Request.Params[6]),
                STATUS = Request.Params[7],
                NEXT_ACTION = Request.Params[8],
                AMOUNT = Request.Params[9],
                EMAIL_BUYER = Request.Params[10],
                EMAIL_SH = Request.Params[11],
                EMAIL_DPH = Request.Params[12],
                EMAIL_LEGAL = Request.Params[13],
                ID = Request.Params[16]
            };

            string txtFile = Request.Params[14];
            string flag = Request.Params[15];

            string[] statusSplit = NewAgreement.STATUS.Split('-');
            NewAgreement.STATUS = statusSplit[0].Trim();

            if (!txtFile.IsNullOrEmpty())
            {
                var fileupload = Request.Files[0];
                string AttachmentPath = SystemRepository.Instance.GetSingleData("UPATT", "MsAgreementAttachment").Value;

                filename = NewAgreement.VENDOR_CODE + "_" + Path.GetFileName(fileupload.FileName);
                string resultFilePath = Path.Combine("~", AttachmentPath + filename);
                fileupload.SaveAs(Server.MapPath(resultFilePath));
            }

            //String message = "";
            String message = MasterAgreementRepository.Instance.SaveData(flag, NewAgreement, filename, this.GetCurrentUsername());

            return new JsonResult
            {
                Data = new
                {
                    message
                }
            };
        }

        public ActionResult DownloadFile(string filePath)
        {
            string Attachment = SystemRepository.Instance.GetSingleData("UPATT", "MsAgreementAttachment").Value;
            string fullName = Server.MapPath("~" + Attachment + filePath);
            byte[] fileBytes = GetFile(fullName);
            FileContentResult fileContentResult = new FileContentResult(fileBytes, System.Net.Mime.MediaTypeNames.Application.Octet);
            fileContentResult.FileDownloadName = filePath;

            return File(fileBytes, System.Net.Mime.MediaTypeNames.Application.Octet, filePath);
        }

        byte[] GetFile(string s)
        {
            FileStream fs = System.IO.File.OpenRead(s);
            byte[] data = new byte[fs.Length];
            int br = fs.Read(data, 0, data.Length);
            if (br != fs.Length)
                throw new System.IO.IOException(s);
            return data;
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
                    //if (sheet.GetRow(i).GetCell(2) == null)
                    //    message = message + "Purchasing Group Should Not be Empty\n";
                    //else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(2).ToString().Trim()))
                    //    message = message + "Purchasing Group Should Not be Empty\n";
                    if (sheet.GetRow(i).GetCell(3) == null)
                        message = message + "Buyer Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(3).ToString().Trim()))
                        message = message + "Buyer Should Not be Empty\n";

                    if (sheet.GetRow(i).GetCell(4) == null)
                        message = message + "Email Buyer Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(4).ToString().Trim()))
                        message = message + "Email Buyer Should Not be Empty\n";
                    if (sheet.GetRow(i).GetCell(5) == null)
                        message = message + "Email SH Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(5).ToString().Trim()))
                        message = message + "Email SH Should Not be Empty\n";
                    if (sheet.GetRow(i).GetCell(6) == null)
                        message = message + "Email DPH Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(6).ToString().Trim()))
                        message = message + "Email DPH Should Not be Empty\n";
                    if (sheet.GetRow(i).GetCell(7) == null)
                        message = message + "Email Legal Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(7).ToString().Trim()))
                        message = message + "Email Legal Should Not be Empty\n";






                    if (sheet.GetRow(i).GetCell(8) == null)
                        message = message + "Agreement No Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(8).ToString().Trim()))
                        message = message + "Agreement No Should Not be Empty\n";
                    //if (sheet.GetRow(i).GetCell(9) == null)
                    //    message = message + "Start Date Should Not be Empty\n";
                    //else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(9).ToString().Trim()))
                    //    message = message + "Start Date Should Not be Empty\n";
                    //if (sheet.GetRow(i).GetCell(10) == null)
                    //    message = message + "Expired Date From Should Not be Empty\n";
                    //else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(10).ToString().Trim()))
                    //    message = message + "Expired Date Should Not be Empty\n";
                    if (sheet.GetRow(i).GetCell(11) == null)
                        message = message + "Next Action Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(11).ToString().Trim()))
                        message = message + "Next Action Should Not be Empty\n";
                    //if (sheet.GetRow(i).GetCell(12) == null)
                    //    message = message + "Amount Should Not be Empty\n";
                    //else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(12).ToString().Trim()))
                    //    message = message + "Amount Should Not be Empty\n";
                    #endregion

                    #region Data Length Checking
                    if (sheet.GetRow(i).GetCell(9).ToString().Trim().Length > 10)
                        message = message + "Start Date Should Not be More Than 10 Character\n";
                    if (sheet.GetRow(i).GetCell(10).ToString().Trim().Length > 10)
                        message = message + "End Date Should Not be More Than 10 Character\n";
                    #endregion

                    #region Date Format Checking
                    //if (message == "")
                    //{
                    //    if (!sheet.GetRow(i).GetCell(9).ToString().Trim().Contains("."))
                    //        message = message + "Start Date is not in Correct Format. Valid Format : dd.MM.yyyy\n";
                    //    if (!sheet.GetRow(i).GetCell(10).ToString().Trim().Contains("."))
                    //        message = message + "Expired Date is not in Correct Format. Valid Format : dd.MM.yyyy\n";
                    //}

                      
                    if (message == "")
                    {
                        if (sheet.GetRow(i).GetCell(9).ToString().Length > 0)
                        {   
                            DateTime dStartDate;
                            string startdatetemp = sheet.GetRow(i).GetCell(9).ToString().Trim().Substring(3, 2) + "/"
                                + sheet.GetRow(i).GetCell(9).ToString().Trim().Substring(0, 2) + "/"
                                + sheet.GetRow(i).GetCell(9).ToString().Trim().Substring(6, 4);
                            if (!DateTime.TryParse(startdatetemp, out dStartDate))
                                message = message + "Start Date is not in Correct Format. Valid Format : dd.MM.yyyy\n";

                            if (!sheet.GetRow(i).GetCell(9).ToString().Trim().Contains("."))
                                message = message + "Start Date is not in Correct Format. Valid Format : dd.MM.yyyy\n";
                        }

                        if (sheet.GetRow(i).GetCell(10).ToString().Length > 0)
                        {
                            DateTime dEndDate;
                            string enddatetemp = sheet.GetRow(i).GetCell(10).ToString().Trim().Substring(3, 2) + "/"
                                + sheet.GetRow(i).GetCell(10).ToString().Trim().Substring(0, 2) + "/"
                                + sheet.GetRow(i).GetCell(10).ToString().Trim().Substring(6, 4);
                            if (!DateTime.TryParse(enddatetemp, out dEndDate))
                                message = message + "Expired Date is not in Correct Format. Valid Format : dd.MM.yyyy\n";

                            if (!sheet.GetRow(i).GetCell(10).ToString().Trim().Contains("."))
                                message = message + "Expired Date is not in Correct Format. Valid Format : dd.MM.yyyy\n";
                        }
                    }

                    #endregion

                    #region Numeric Checking
                    //if (message == "")
                    //{
                    //    if (sheet.GetRow(i).GetCell(12) != null)
                    //    {
                    //        if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(12).ToString().Trim()))
                    //        {
                    //            Int32 dInt;
                    //            if (!Int32.TryParse(sheet.GetRow(i).GetCell(12).ToString().Trim(), out dInt))
                    //                message = message + "Amount is not in correct format\n";
                    //        }
                    //    }
                    //}
                   

                    #endregion

                    if (string.IsNullOrEmpty(message))
                    {
                        MasterAgreement data = new MasterAgreement();

                        data.VENDOR_CODE = sheet.GetRow(i).GetCell(1).ToString().Trim();
                        data.PURCHASING_GROUP = sheet.GetRow(i).GetCell(2).ToString().Trim();
                        data.BUYER = sheet.GetRow(i).GetCell(3).ToString().Trim();
                        data.EMAIL_BUYER = sheet.GetRow(i).GetCell(4).ToString().Trim();
                        data.EMAIL_SH = sheet.GetRow(i).GetCell(5).ToString().Trim();
                        data.EMAIL_DPH = sheet.GetRow(i).GetCell(6).ToString().Trim();
                        data.EMAIL_LEGAL = sheet.GetRow(i).GetCell(7).ToString().Trim();
                        data.AGREEMENT_NO = sheet.GetRow(i).GetCell(8).ToString().Trim();
                        data.START_DATE = conversiDate(sheet.GetRow(i).GetCell(9).ToString().Trim());
                        data.EXP_DATE = conversiDate(sheet.GetRow(i).GetCell(10).ToString().Trim());
                        data.NEXT_ACTION = sheet.GetRow(i).GetCell(11).ToString().Trim();
                        data.AMOUNT = sheet.GetRow(i).GetCell(12) != null ?  sheet.GetRow(i).GetCell(12).ToString().Trim() : "0";

                        message = MasterAgreementRepository.Instance.SaveUploadedData(data, this.GetCurrentUsername());
                    }

                    if (sheet.GetRow(i).GetCell(15) == null)
                        sheet.GetRow(i).CreateCell(15);

                    if (message.Substring(message.Length - 2, 2) == "\n")
                        message = message.Substring(0, message.Length - 2);

                    sheet.GetRow(i).GetCell(15).SetCellValue(message);
                    sheet.GetRow(i).GetCell(15).CellStyle.WrapText = true;

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
        public void DownloadHeader(int Display, int Page, string VendorCode, string VendorName, string Status, string AgreementNo, string ExpDate)
        {
            string DateFrom = "";
            string DateTo = "";

            if (!ExpDate.IsNullOrEmpty())
            {
                string[] DateRange = ExpDate.Split('-');
                DateFrom = DateRange[0];
                DateTo = DateRange[1];
            }

            CommonDownload downloadEngine = CommonDownload.Instance;
            string FileName = string.Format("AgreementNo {0:dd-MM-yyyy}.xls", DateTime.Now);
            string filePath = HttpContext.Request.MapPath(downloadEngine.GetServerFilePath("MasterAgreementDownloadTemplete.xls"));
            FileStream ftmp = new FileStream(filePath, FileMode.Open, FileAccess.Read);
            var workbook = new HSSFWorkbook(ftmp);

            Paging pg = new Paging(MasterAgreementRepository.Instance.CountData(VendorCode, VendorName, AgreementNo, Status, DateFrom, DateTo), Page, Display);
            var dataListDueDilligence = new List<MasterAgreement>(MasterAgreementRepository.Instance.GetListData(VendorCode, VendorName, AgreementNo, Status, pg.StartData, pg.EndData, DateFrom, DateTo));

            ISheet sheet; IRow Hrow; int row = 1;

            IFont font = downloadEngine.GenerateFontExcel(workbook);
            ICellStyle styleCenter = downloadEngine.GenerateStyleCenter(workbook, font);
            ICellStyle styleLeft = downloadEngine.GenerateStyleLeft(workbook, font);
            ICellStyle styleNormal = downloadEngine.GenerateStyleNormal(workbook, font);

            sheet = workbook.GetSheetAt(0);

            foreach (MasterAgreement item in dataListDueDilligence)
            {
                Hrow = sheet.CreateRow(row);
                downloadEngine.WriteCellValue(Hrow, 0, styleNormal, item.Number);
                downloadEngine.WriteCellValue(Hrow, 1, styleNormal, item.VENDOR_CODE);
                downloadEngine.WriteCellValue(Hrow, 2, styleNormal, item.VENDOR_NAME);
                downloadEngine.WriteCellValue(Hrow, 3, styleNormal, item.PURCHASING_GROUP);
                downloadEngine.WriteCellValue(Hrow, 4, styleNormal, item.BUYER);
                downloadEngine.WriteCellValue(Hrow, 5, styleNormal, item.AGREEMENT_NO);
                downloadEngine.WriteCellValue(Hrow, 6, styleNormal, item.AN_ATTACHMENT);
                downloadEngine.WriteCellValue(Hrow, 7, styleNormal, string.Format("{0:yyyy-MM-dd}", item.START_DATE));
                downloadEngine.WriteCellValue(Hrow, 8, styleNormal, string.Format("{0:yyyy-MM-dd}", item.EXP_DATE));
                downloadEngine.WriteCellValue(Hrow, 9, styleNormal, item.STATUS);
                downloadEngine.WriteCellValue(Hrow, 10, styleNormal, item.NEXT_ACTION);
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
        #endregion
    }
}
