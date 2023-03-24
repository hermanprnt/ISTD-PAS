using System;
using System.Linq;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.Models.Master;
using Toyota.Common.Web.Platform;
using System.IO;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using System.Collections.Generic;
using GPS.Models;

namespace GPS.Controllers.Master
{
    public class CostCenterController : PageController
    {
        protected override void Startup()
        {
            Settings.Title = "Cost Center Master";
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

        private void Calldata(int Display, int Page, string Division, string CostCenter)
        {
            Paging pg = new Paging(CostCenterRepository.Instance.CountData(Division, CostCenter), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["ListCostCenter"] = CostCenterRepository.Instance.GetListData(Division, CostCenter, pg.StartData, pg.EndData);
        }

        [HttpPost]
        public ActionResult SearchData(int Display, int Page, string Division, string CostCenter)
        {
            Calldata(Display, Page, Division, CostCenter);
            return PartialView("_Grid");
        }

        public ActionResult SaveData(String flag, String costCenterGroupCode, String costCenterCode, String description, String division, String respperson, String validFrom, String validTo)
        {
            validFrom = conversiDate(validFrom);
            validTo = conversiDate(validTo);

            String message = CostCenterRepository.Instance.SaveData(flag, costCenterGroupCode, costCenterCode, description, division, respperson, validFrom, validTo, this.GetCurrentUsername());

            return new JsonResult { Data = new { message } };
        }

        public ActionResult DeleteData(String key)
        {
            string message = "";

            try
            {
                message = CostCenterRepository.Instance.DeleteData(key, this.GetCurrentUsername());
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
                return Json("Error|" + message, JsonRequestBehavior.AllowGet);
            }

            return Json(message, JsonRequestBehavior.AllowGet);
        }

        public ActionResult IsFlagEditAdd(String flag, String costCenterCode, String ValidFrom)
        {
            if (ValidFrom != null)
            ValidFrom = conversiDate(ValidFrom);

            ViewData["edit"] = flag;
            ViewData["CostCenterData"] = flag == "0"
                ? new CostCenter()
                : CostCenterRepository.Instance.GetSelectedData(costCenterCode, ValidFrom);

            return PartialView("_AddEditPopUp");
        }

        public static SelectList GetCostCenterSelectList(String currentRegNo)
        {
            return CostCenterRepository.Instance
                .GetList(currentRegNo)
                .AsSelectList(cc => cc.CostCenterCd + " - " + cc.CostCenterDesc, cc => cc.CostCenterCd);
        }
        #region added : 20190614 : isid.rgl
        public static SelectList GetCostCenterSelectListAll()
        {
            return CostCenterRepository.Instance
                .GetListAll()
                .AsSelectList(cc => cc.CostCenterCd + " - " + cc.CostCenterDesc, cc => cc.CostCenterCd);
        }
        #endregion
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
            string filepath = Path.Combine(Server.MapPath("~/Content/Download/Template/COST_CENTER.xls"));
            byte[] docBytes = StreamFile(filepath);

            return File(docBytes, "application/vmd.ms-excel", "COST_CENTER.xls");
        }

        public ActionResult CekTemplate()
        {
            string cektemplate = "";

            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/Template/COST_CENTER.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
                cektemplate = "True";
            else
                cektemplate = "False";

            return Json(cektemplate, JsonRequestBehavior.AllowGet);
        }

        #region UPLOAD
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
                ISheet sheet = wb.GetSheet("CostCenter");

                for (int i = 1; i <= sheet.LastRowNum; i++)
                {
                    string message = "";

                    #region Mandatory Checking
                    if (sheet.GetRow(i).GetCell(0) == null)
                        message = message + "Cost Center Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(0).ToString().Trim()))
                        message = message + "Cost Center Should Not be Empty\n";

                    if (sheet.GetRow(i).GetCell(1) == null)
                        message = message + "Description Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(1).ToString().Trim()))
                        message = message + "Description Should Not be Empty\n";

                    if (sheet.GetRow(i).GetCell(2) == null)
                        message = message + "Resp Person Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(2).ToString().Trim()))
                        message = message + "Resp Person Should Not be Empty\n";

                    if (sheet.GetRow(i).GetCell(4) == null)
                        message = message + "Valid Date From Should Not be Empty\n";
                    else if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(4).ToString().Trim()))
                        message = message + "Valid Date From Should Not be Empty\n";
                    #endregion

                    #region Data Length Checking
                    if (message == "")
                    {
                        if (sheet.GetRow(i).GetCell(0).ToString().Trim().Length > 8)
                            message = message + "Cost Center Should Not be More Than 8 Character\n";

                        if (sheet.GetRow(i).GetCell(1).ToString().Trim().Length > 50)
                            message = message + "Description Should Not be More Than 50 Character\n";

                        if (sheet.GetRow(i).GetCell(2).ToString().Trim().Length > 50)
                            message = message + "Resp Person Should Not be More Than 50 Character\n";
                    }
                    #endregion

                    #region Date Format Checking
                    if (message == "")
                    {
                        if (!sheet.GetRow(i).GetCell(4).ToString().Trim().Contains("."))
                            message = message + "Valid Date From is not in Correct Format. Valid Format : dd.MM.yyyy\n";
                    }

                    if (message == "")
                    {
                        DateTime dDate;
                        string datetemp = sheet.GetRow(i).GetCell(4).ToString().Trim().Substring(3, 2) + "/" + sheet.GetRow(i).GetCell(4).ToString().Trim().Substring(0, 2) + "/" + sheet.GetRow(i).GetCell(4).ToString().Trim().Substring(6, 4);
                        if (!DateTime.TryParse(datetemp, out dDate))
                            message = message + "Valid Date From is not in Correct Format. Valid Format : dd.MM.yyyy\n";
                    }
                    #endregion

                    #region Numeric Checking
                    if (message == "")
                    {
                        if (sheet.GetRow(i).GetCell(3) != null)
                        {
                            if (String.IsNullOrEmpty(sheet.GetRow(i).GetCell(3).ToString().Trim()))
                            {
                                Int16 dInt;
                                if (!Int16.TryParse(sheet.GetRow(i).GetCell(3).ToString().Trim(), out dInt))
                                    message = message + "Division ID is not in correct format\n";
                            }
                        }
                    }
                    #endregion

                    if (message == "")
                    {
                        CostCenter data = new CostCenter();

                        data.CostCenterCd = sheet.GetRow(i).GetCell(0).ToString().Trim();
                        data.CostCenterDesc = sheet.GetRow(i).GetCell(1).ToString().Trim();
                        data.RespPerson = sheet.GetRow(i).GetCell(2).ToString().Trim();
                        data.Division = sheet.GetRow(i).GetCell(3).ToString().Trim();
                        data.ValidDtFrom = sheet.GetRow(i).GetCell(4).ToString().Trim();

                        message = CostCenterRepository.Instance.SaveUploadedData(data, this.GetCurrentUsername());
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
        #endregion

        public void DownloadReport(string CostCenterCd, string Division, int currentPage, int recordPerPage)
        {
            Paging pg = new Paging(CostCenterRepository.Instance.CountData(CostCenterCd, Division),currentPage,recordPerPage);
            ViewData["Paging"] = pg;
            List<CostCenter> List = CostCenterRepository.Instance.GetData(
                CostCenterCd, Division, currentPage, recordPerPage).ToList();
            var workboook = new HSSFWorkbook();
            string FileName = string.Format("Cost_Center_Master_" + DateTime.Now.ToString("yyyyMMddhhmmss") + ".xls", DateTime.Now).Replace("/", "-");//for file name
            List<string[]> ListArr = new List<string[]>();//array for choose data
            String[] header = new string[6] {  "Cost Center Code", "Cost Center Description",
                                                "Resp Person","Division", "Valid Date From", "Valid Date To"};//for header name
            ListArr.Add(header);
            //choose data for show in report
            foreach (CostCenter obj in List)
            {
                String[] myArr = new string[6]
                {
                    obj.CostCenterCd ,
                    obj.CostCenterDesc ,
                    obj.RespPerson ,
                    obj.Division ,
                    obj.ValidDtFrom ,
                    obj.ValidDtTo
                };
                ListArr.Add(myArr);
            }
            workboook = CommonDownload.Instance.CreateExcelSheet(ListArr, "GLAccountMaster");//call function execute report
            using (var exportData = new MemoryStream())//binding to streamreader
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
    }
}