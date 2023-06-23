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
using GPS.Core.ViewModel;
using GPS.Core;
using System.Globalization;
using Toyota.Common.Utilities;
using GPS.Constants.PO;
using GPS.Models.PO;
using GPS.Models;
using GPS.ViewModels.PO;
using System.Web;
using System.Data;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using iTextSharp.text.pdf.codec;

namespace GPS.Controllers.Master
{
    public class MasterDueDilligenceController : PageController
    {
        string vendorCodeForUpload = "";


        #region List Of Controller Method
        public sealed class Action
        {


        }
        #endregion

        public MasterDueDilligenceController()
        {
            Settings.Title = "Master Due Dilligence Screen";
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
            ViewData["REG_NO"] = this.GetCurrentRegistrationNumber();
            ViewData["edit"] = flag;
            ViewData["MasterDueDilligenceData"] = flag == "0"
                ? new MasterDueDilligence()
                : MasterDueDilligenceRepository.Instance.GetSelectedData(VendorCode);

            return PartialView("_AddEditPopUp");
        }

        private void Calldata(int Display, int Page, string VendorCode, string VendorName, string DateFrom, string DateTo, string Status)
        {

            Paging pg = new Paging(MasterDueDilligenceRepository.Instance.CountData(VendorCode, VendorName, DateFrom, DateTo, Status), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["ListMasterDueDilligence"] = MasterDueDilligenceRepository.Instance.GetListData(VendorCode, VendorName, DateFrom, DateTo, Status, pg.StartData, pg.EndData);
        }

        [HttpPost]
        public ActionResult SearchData(int Display, int Page, string VendorCode, string VendorName, string DueDilDateRange, string Status)
        {
            string DateFrom = "";
            string DateTo = "";

            if (!DueDilDateRange.IsNullOrEmpty())
            {
                string[] DateRange = DueDilDateRange.Split('-');
                DateFrom = DateRange[0];
                DateTo = DateRange[1];
            }

            Calldata(Display, Page, VendorCode, VendorName, DateFrom, DateTo, Status);
            return PartialView("_Grid");
        }


        public JsonResult GetVendorOnChange(string vendor)
        {
            return Json(MasterDueDilligenceRepository.Instance.GetVendorSelected(vendor));
        }


        /// <summary>
        /// INSERT DATA TO TB_M_AGREEMENT_NO
        /// </summary>
        [HttpPost]
        public ActionResult SaveData()
        {
            string vendorcd = Request.Params[0];
            string vendornm = Request.Params[1];
            string status = Request.Params[2];
            string vldddfrom = Request.Params[3];
            string vldddto = Request.Params[4];
            string flag = Request.Params[5];
            string txtFile = Request.Params[6];

            if (!txtFile.IsNullOrEmpty())
            {
                var fileupload = Request.Files[0];
                string AttachmentPath = SystemRepository.Instance.GetSingleData("UPATT", "DueDilligenceAttachment").Value;

                var filename = vendorcd + "_" + Path.GetFileName(fileupload.FileName);
                string resultFilePath = Path.Combine("~", AttachmentPath + filename);
                fileupload.SaveAs(Server.MapPath(resultFilePath));
            }
           

            vldddfrom = conversiDate(vldddfrom);
            vldddto = conversiDate(vldddto);

            String message = MasterDueDilligenceRepository.Instance.SaveData(flag, vendorcd, vendornm, status, vldddfrom, vldddto, txtFile, this.GetCurrentUsername());

            return new JsonResult { Data = new { message } };
        }

        public ActionResult DownloadFile(string filePath)
        {
            string Attachment = SystemRepository.Instance.GetSingleData("UPATT", "DueDilligenceAttachment").Value;

            string fullName = Server.MapPath("~" + Attachment+ filePath);

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
                message = MasterDueDilligenceRepository.Instance.DeleteData(key, this.GetCurrentUsername());
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
                return Json("Error|" + message, JsonRequestBehavior.AllowGet);
            }

            return Json(message, JsonRequestBehavior.AllowGet);
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
                ISheet sheet = wb.GetSheet("MasterDueDilligence");

                for (int i = 1; i <= sheet.LastRowNum; i++)
                {
                    string message = "";

                    #region Mandatory Checking
                    if (sheet.GetRow(i).GetCell(1) == null)
                        message = message + "Vendor Code Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(1).ToString().Trim()))
                        message = message + "Vendor Code Should Not be Empty\n";

                    if (sheet.GetRow(i).GetCell(2) == null)
                        message = message + "Due Dilligence Status Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(2).ToString().Trim()))
                        message = message + "Due Dilligence Status Should Not be Empty\n";

                    if (sheet.GetRow(i).GetCell(3) == null)
                        message = message + "Due Dilligence From Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(3).ToString().Trim()))
                        message = message + "Due Dilligence From Should Not be Empty\n";
                    #endregion

                    #region Data Length Checking
                    if (message == "")
                    {

                        if (sheet.GetRow(i).GetCell(3).ToString().Trim().Length > 10)
                            message = message + "Due Dilligence From Should Not be More Than 10 Character\n";
                    }
                    #endregion

                    #region Date Format Checking
                    if (message == "")
                    {
                        if (!sheet.GetRow(i).GetCell(3).ToString().Trim().Contains("."))
                            message = message + "Due Dilligence From is not in Correct Format. Valid Format : dd.MM.yyyy\n";
                    }

                    if (message == "")
                    {
                        DateTime dDate;
                        string datetemp = sheet.GetRow(i).GetCell(3).ToString().Trim().Substring(3, 2) + "/" + sheet.GetRow(i).GetCell(3).ToString().Trim().Substring(0, 2) + "/" + sheet.GetRow(i).GetCell(3).ToString().Trim().Substring(6, 4);
                        if (!DateTime.TryParse(datetemp, out dDate))
                            message = message + "Due Dilligence From is not in Correct Format. Valid Format : dd.MM.yyyy\n";
                    }
                    #endregion

                    #region Numeric Checking
                    if (message == "")
                    {
                        if (sheet.GetRow(i).GetCell(3) != null)
                        {
                            if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(2).ToString().Trim()))
                            {
                                Int16 dInt;
                                if (!Int16.TryParse(sheet.GetRow(i).GetCell(2).ToString().Trim(), out dInt))
                                    message = message + "Due Dilligence Status is not in correct format\n";
                            }
                        }
                    }
                    #endregion

                    if (message == "")
                    {
                        MasterDueDilligence data = new MasterDueDilligence();

                        data.VENDOR_CODE = sheet.GetRow(i).GetCell(1).ToString().Trim();
                        data.DD_STATUS = sheet.GetRow(i).GetCell(2).ToString().Trim();
                        data.VALID_DD_FROM = sheet.GetRow(i).GetCell(3).ToString().Trim();

                        message = MasterDueDilligenceRepository.Instance.SaveUploadedData(data, this.GetCurrentUsername());
                    }

                    if (sheet.GetRow(i).GetCell(5) == null)
                        sheet.GetRow(i).CreateCell(5);

                    if (message.Substring(message.Length - 2, 2) == "\n")
                        message = message.Substring(0, message.Length - 2);

                    sheet.GetRow(i).GetCell(5).SetCellValue(message);
                    sheet.GetRow(i).GetCell(5).CellStyle.WrapText = true;
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
            string filepath = Path.Combine(Server.MapPath("~/Content/Download/Template/DueDilligentTemplate.xls"));
            byte[] docBytes = StreamFile(filepath);

            return File(docBytes, "application/vmd.ms-excel", "DueDilligentTemplate.xls");
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

            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/Template/DueDilligentTemplate.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
                cektemplate = "True";
            else
                cektemplate = "False";

            return Json(cektemplate, JsonRequestBehavior.AllowGet);
        }
        public void DownloadHeader(int Display, int Page, string VendorCode, string VendorName, string DateFrom, string DateTo, string Status)
        {
            CommonDownload downloadEngine = CommonDownload.Instance;
            //FixingSearchModelParam(searchViewModel);
            string FileName = string.Format("DueDilligence {0:dd-MM-yyyy}.xls", DateTime.Now);
            string filePath = HttpContext.Request.MapPath(downloadEngine.GetServerFilePath("DueDilligenceDownloadTemplete.xls"));
            FileStream ftmp = new FileStream(filePath, FileMode.Open, FileAccess.Read);
            var workbook = new HSSFWorkbook(ftmp);

            Paging pg = new Paging(MasterDueDilligenceRepository.Instance.CountData(VendorCode, VendorName, DateFrom, DateTo, Status), Page, Display);
            var dataListDueDilligence = new List<MasterDueDilligence>(MasterDueDilligenceRepository.Instance.GetListData(VendorCode, VendorName, DateFrom, DateTo, Status, pg.StartData, pg.EndData));

            ISheet sheet; IRow Hrow; int row = 1;

            IFont font = downloadEngine.GenerateFontExcel(workbook);
            ICellStyle styleCenter = downloadEngine.GenerateStyleCenter(workbook, font);
            ICellStyle styleLeft = downloadEngine.GenerateStyleLeft(workbook, font);
            ICellStyle styleNormal = downloadEngine.GenerateStyleNormal(workbook, font);

            sheet = workbook.GetSheetAt(0);

            foreach (MasterDueDilligence item in dataListDueDilligence)
            {
                Hrow = sheet.CreateRow(row);
                downloadEngine.WriteCellValue(Hrow, 0, styleNormal, item.Number);
                downloadEngine.WriteCellValue(Hrow, 1, styleNormal, item.VENDOR_CODE);
                downloadEngine.WriteCellValue(Hrow, 2, styleNormal, item.VENDOR_PLANT);
                downloadEngine.WriteCellValue(Hrow, 3, styleNormal, item.VENDOR_NAME);
                downloadEngine.WriteCellValue(Hrow, 4, styleNormal, item.DD_STATUS);
                downloadEngine.WriteCellValue(Hrow, 5, styleNormal, item.VALID_DD_FROM);
                downloadEngine.WriteCellValue(Hrow, 6, styleNormal, item.VALID_DD_TO);
                downloadEngine.WriteCellValue(Hrow, 7, styleNormal, item.DD_ATTACHMENT);
                downloadEngine.WriteCellValue(Hrow, 8, styleNormal, item.DELETION);
                downloadEngine.WriteCellValue(Hrow, 9, styleNormal, item.CREATED_BY);
                downloadEngine.WriteCellValue(Hrow, 10, styleNormal, string.Format("{0:yyyy-MM-dd}", item.CREATED_DT));
                downloadEngine.WriteCellValue(Hrow, 11, styleNormal, item.CHANGED_BY);
                downloadEngine.WriteCellValue(Hrow, 12, styleNormal, string.Format("{0:yyyy-MM-dd}", item.CHANGED_DT));
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


        public static SelectList GetStatusList()
        {
            return MasterDueDilligenceRepository.Instance
                .GetSTSDueDilligence()
                .AsSelectList(div => div.SYSTEM_CD + " - " + div.SYSTEM_VALUE,
                    div => div.SYSTEM_CD);
        }

        public static SelectList PlantSelectList()
        {
            return PlantRepository.Instance
                .GetPlantList()
                .AsSelectList(plant => plant.PLANT_CD + " - " + plant.PLANT_NAME, plant => plant.PLANT_CD);
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
