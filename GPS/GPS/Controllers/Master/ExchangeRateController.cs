using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web.Mvc;
using GPS.Models;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.Models.Master;
using NPOI.HSSF.UserModel;
using Toyota.Common.Web.Platform;
using NPOI.SS.UserModel;

namespace GPS.Controllers.Master
{
    public class ExchangeRateController : PageController
    {
        protected override void Startup()
        {
            Settings.Title = "Exchange Rate Inquiry";
            Calldata(10, 1, null, null, null, null, null, null, true);
            ViewData["ReleasedFlag"] = ExchangeRateRepository.Instance.GetReleasedFlag();
        }

        #region SEARCH
        private void Calldata(int Display, int Page, string curr_cd, string exchange_rate, string valid_dt_from, string valid_dt_to, string forex_type, string released_flag, bool isValidOnly)
        {
            Paging pg = new Paging(ExchangeRateRepository.Instance.CountData(curr_cd, exchange_rate, valid_dt_from, valid_dt_to, forex_type, released_flag, isValidOnly), Page, Display);
            ViewData["Paging"] = pg;
            List<ExchangeRate> list = ExchangeRateRepository.Instance.GetData(pg.StartData, pg.EndData, curr_cd, exchange_rate, valid_dt_from, valid_dt_to, forex_type, released_flag, isValidOnly);
            ViewData["ListExchangeRate"] = list;
        }

        public ActionResult onGetData(int Display, int Page, string curr_cd, string exchange_rate, string valid_dt_from, string valid_dt_to, string forex_type, string released_flag, bool isValidOnly)
        {    
            Calldata(Display, Page, curr_cd, exchange_rate, valid_dt_from, valid_dt_to, forex_type, released_flag, isValidOnly);
            return PartialView("_ViewTable");
        }
        #endregion

        #region ADD / EDIT
        public ActionResult SaveData(ExchangeRate er)
        {
            int result = 0;
            string message = "";
            try
            {
                result = ExchangeRateRepository.Instance.UptodateData(er, this.GetCurrentUsername());
                if (result == -1)
                {
                    message = "Error|You can not create two times the same currency in one day";
                }
                else if (result == -2)
                {
                    message = "Error|Cannot entry new exchange rate when valid date equal or lower than existing valid date";
                }
                else if (result == 1)
                {
                    message = "Exchange Rate <strong>" + er.CURR_CD + "</strong>, save successfully!";
                }
            }
            catch (Exception e)
            {
                message = "Error|" + e.Message.ToString();
            }
            return Json(message, JsonRequestBehavior.AllowGet);
        }

        //get single data (FOR UPDATE) 
        public ActionResult GetSingleData(string curr_cd)
        {
            var splittedId = curr_cd.Split('|');
            return Json(ExchangeRateRepository.Instance.GetSingleData(splittedId[0], splittedId[1]));
        }
        #endregion

        #region DELETE
        public ActionResult DeleteExchangeRate(string Key)
        {

            string valid = ExchangeRateRepository.Instance.DeleteDataValidation(Key.Split(';')[0], Key.Split(';')[1], Key.Split(';')[2]);

            if (valid == "")
            {
                String deleteResult =
                    CommonController.DeleteData(this, Key, id =>
                    {
                        var splittedId = id.Split(';');
                        return ExchangeRateRepository.Instance.DeleteData(splittedId[0], splittedId[1], splittedId[2], this.GetCurrentUsername());
                    });

                if (deleteResult.Contains("You must checked"))
                    return PartialView("_ViewTable");

                return Content(deleteResult + " deleted");
            }
            else
                return Content("Error|" + valid);
        }
        #endregion

        #region DOWNLOAD
        private byte[] StreamFile(string filename)
        {
            FileStream fs = new FileStream(filename, FileMode.Open, FileAccess.Read);
            byte[] ImageData = new byte[fs.Length];

            fs.Read(ImageData, 0, Convert.ToInt32(fs.Length));

            fs.Close();

            return ImageData;
        }

        public FileContentResult DownloadTemplate()
        {
            string filepath = Path.Combine(Server.MapPath("~/Content/Download/Template/EXCHANGE_RATE.xls"));
            byte[] docBytes = StreamFile(filepath);

            return File(docBytes, "application/vmd.ms-excel", "EXCHANGE_RATE.xls");
        }

        public ActionResult CekTemplate()
        {
            string cektemplate = "";

            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/Template/EXCHANGE_RATE.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
                cektemplate = "True";
            else
                cektemplate = "False";

            return Json(cektemplate, JsonRequestBehavior.AllowGet);
        }

        public void DownloadReport(int Page, int Display, string curr_cd, string exchange_rate, string valid_dt_from, string valid_dt_to, string forex_type,
                                                            string released_flag, bool isValidOnly)
        {
            Paging pg = new Paging(ExchangeRateRepository.Instance.CountData(curr_cd, exchange_rate, valid_dt_from, valid_dt_to, forex_type, released_flag, isValidOnly), Page, Display);
            ViewData["Paging"] = pg;
            List<ExchangeRate> List = ExchangeRateRepository.Instance.GetData(pg.StartData, pg.CountData, curr_cd, exchange_rate, valid_dt_from, valid_dt_to, forex_type, released_flag, isValidOnly).ToList();
            var workboook = new HSSFWorkbook();
            string FileName = string.Format("ExchangeRate.xls", DateTime.Now).Replace("/", "-");//for file name
            List<string[]> ListArr = new List<string[]>(); //array for choose data
            String[] header = new string[7] {  "Currency", "Exchange Rate", "Valid Date From", 
                                                "Valid Date To", "Forex Type", "Release Flag", "Created Date"}; //for header name
            ListArr.Add(header);
            //choose data for show in report
            foreach (ExchangeRate obj in List)
            {
                String[] myArr = new string[7] 
                { 
                    obj.CURR_CD,
                    obj.EXCHANGE_RATE,
                    obj.VALID_DT_FROM,
                    obj.VALID_DT_TO,
                    obj.FOREX_TYPE,
                    obj.RELEASED_FLAG,
                    obj.CREATED_DT
                };
                ListArr.Add(myArr);
            }
            workboook = CommonDownload.Instance.CreateExcelSheet(ListArr, "ExchangeRate");//call function execute report
            using (var exportData = new MemoryStream()) //binding to streamreader
            {
                workboook.Write(exportData);
                Response.ClearContent();
                Response.Buffer = true;
                Response.ContentType = "application/ms-excel";
                Response.AddHeader("Content-Disposition", string.Format("attachment;filename={0}", FileName));
                Response.BinaryWrite(exportData.GetBuffer());
                Response.Flush();
                Response.End();
            }
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
        #endregion

        #region UPLOAD
        [HttpPost]
        public ActionResult UploadFile()
        {
            string resultFilePath = "";
            string savefile = "";
            string result = "";

            try
            {
                #region Get File
                //IDBContext db = DatabaseManager.Instance.GetContext();

                var file = Request.Files[0];
                var filename = Path.GetFileName(file.FileName);
                savefile = Path.Combine(Server.MapPath("~/Content/UploadFile"), filename);
                resultFilePath = Path.Combine("~/Content/UploadFile", filename);
                file.SaveAs(Server.MapPath(resultFilePath));

                FileStream fs = new FileStream(Server.MapPath(resultFilePath), FileMode.OpenOrCreate, FileAccess.ReadWrite);
                HSSFWorkbook wb = new HSSFWorkbook(fs);
                ISheet sheet = wb.GetSheet("Sheet1");

                for (int i = 1; i <= sheet.LastRowNum; i++)
                {
                    string message = "";

                    #region Mandatory Checking
                    if (sheet.GetRow(i).GetCell(0) == null)
                        message = message + "Currency Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(0).ToString().Trim()))
                        message = message + "Currency Should Not be Empty\n";

                    if (sheet.GetRow(i).GetCell(1) == null)
                        message = message + "Exchange Rate Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(1).ToString().Trim()))
                        message = message + "Exchange Rate Should Not be Empty\n";

                    if (sheet.GetRow(i).GetCell(2) == null)
                        message = message + "Valid Date From Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(2).ToString().Trim()))
                        message = message + "Valid Date From Should Not be Empty\n";

                    if (sheet.GetRow(i).GetCell(3) == null)
                        message = message + "Valid Date To Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(3).ToString().Trim()))
                        message = message + "Valid Date To Should Not be Empty\n";

                    if (sheet.GetRow(i).GetCell(5) == null)
                        message = message + "Release Flag From Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(5).ToString().Trim()))
                        message = message + "Release Flag Should Not be Empty\n";

                    if (sheet.GetRow(i).GetCell(6) == null)
                        message = message + "Decimal Format From Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(6).ToString().Trim()))
                        message = "Decimal Format Should Not be Empty\n";
                    #endregion

                    #region Data Length Checking
                    if (message == "")
                    {
                        if (sheet.GetRow(i).GetCell(0).ToString().Trim().Length > 3)
                            message = message + "Currency Should Not be More Than 3 Character\n";

                        if (sheet.GetRow(i).GetCell(4) != null)
                        {
                            if (sheet.GetRow(i).GetCell(4).ToString().Trim().Length > 1)
                                message = message + "Forex Type Should Not be More Than 1 Character\n";
                        }

                        if (sheet.GetRow(i).GetCell(5).ToString().Trim().Length > 1)
                            message = message + "Release Flag Should Not be More Than 1 Character\n";

                        if (sheet.GetRow(i).GetCell(6).ToString().Trim().Length > 1)
                            message = message + "Decimal Format Should Not be More Than 1 Character\n";
                    }
                    #endregion

                    #region Date Format Checking
                    if (message == "")
                    {
                        if (!sheet.GetRow(i).GetCell(2).ToString().Trim().Contains('.'))
                            message = message + "Valid Date From is not in Correct Format. Valid Format : dd.MM.yyyy\n";

                        if (!sheet.GetRow(i).GetCell(3).ToString().Trim().Contains('.'))
                            message = message + "Valid Date To is not in Correct Format. Valid Format : dd.MM.yyyy\n";
                    }

                    if (message == "")
                    {
                        DateTime dDate;
                        string datetemp = sheet.GetRow(i).GetCell(2).ToString().Trim().Substring(3, 2) + "/" + sheet.GetRow(i).GetCell(2).ToString().Trim().Substring(0, 2) + "/" + sheet.GetRow(i).GetCell(2).ToString().Trim().Substring(6, 4);
                        if (!DateTime.TryParse(datetemp, out dDate))
                            message = message + "Valid Date From is not in Correct Format. Valid Format : dd.MM.yyyy\n";

                        datetemp = sheet.GetRow(i).GetCell(3).ToString().Trim().Substring(3, 2) + "/" + sheet.GetRow(i).GetCell(3).ToString().Trim().Substring(0, 2) + "/" + sheet.GetRow(i).GetCell(3).ToString().Trim().Substring(6, 4);
                        if (!DateTime.TryParse(datetemp, out dDate))
                            message = message + "Valid Date To is not in Correct Format. Valid Format : dd.MM.yyyy\n";
                    }
                    #endregion

                    #region Numeric Checking
                    if (message == "")
                    {
                        decimal dDecimal;
                        if (!Decimal.TryParse(sheet.GetRow(i).GetCell(1).ToString().Trim(), out dDecimal))
                            message = message + "Exchange Rate Should be in Decimal Format\n";

                        Int16 dInt;
                        if (!Int16.TryParse(sheet.GetRow(i).GetCell(6).ToString().Trim(), out dInt))
                            message = message + "Decimal Format Should be in Numeric Format\n";
                    }
                    #endregion

                    #region Flag Checking
                    if (message == "")
                    {
                        if (sheet.GetRow(i).GetCell(5).ToString().Trim() != "Y" && sheet.GetRow(i).GetCell(5).ToString().Trim() != "N")
                            message = message + "Release Flag Should be Filled by Y/N\n";
                    }
                    #endregion

                    if (message == "")
                    {
                        ExchangeRate data = new ExchangeRate();

                        data.CURR_CD = sheet.GetRow(i).GetCell(0).ToString().Trim();
                        data.EXCHANGE_RATE = sheet.GetRow(i).GetCell(1).ToString().Trim();
                        data.VALID_DT_FROM = sheet.GetRow(i).GetCell(2).ToString().Trim().Substring(6, 4) + "-" + sheet.GetRow(i).GetCell(2).ToString().Trim().Substring(3, 2) + "-" + sheet.GetRow(i).GetCell(2).ToString().Trim().Substring(0, 2);
                        data.VALID_DT_TO = sheet.GetRow(i).GetCell(3).ToString().Trim().Substring(6, 4) + "-" + sheet.GetRow(i).GetCell(3).ToString().Trim().Substring(3, 2) + "-" + sheet.GetRow(i).GetCell(3).ToString().Trim().Substring(0, 2);
                        data.FOREX_TYPE = sheet.GetRow(i).GetCell(4) == null ? null : sheet.GetRow(i).GetCell(4).ToString().Trim();
                        data.RELEASED_FLAG = sheet.GetRow(i).GetCell(5).ToString().Trim();
                        data.DECIMAL_FORMAT = sheet.GetRow(i).GetCell(6).ToString().Trim();

                        message = ExchangeRateRepository.Instance.SaveUploadedData(data, this.GetCurrentUsername());
                    }

                    if (sheet.GetRow(i).GetCell(7) == null)
                        sheet.GetRow(i).CreateCell(7);

                    if (message.Substring(message.Length - 2, 2) == "\n")
                        message = message.Substring(0, message.Length - 2);

                    sheet.GetRow(i).GetCell(7).SetCellValue(message);
                    sheet.GetRow(i).GetCell(7).CellStyle.WrapText = true;
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
        #endregion
    }
}