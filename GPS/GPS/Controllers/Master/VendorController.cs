using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.Constants;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models.Master;
using GPS.ViewModels.Lookup;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using Toyota.Common.Web.Platform;
using NameValueItem = GPS.Models.Common.NameValueItem;
using System.Text.RegularExpressions;

namespace GPS.Controllers.Master
{
    public class VendorController : PageController
    {
        public const String OpenVendorLookupAction = "/Vendor/OpenVendorLookup";
        public const String SearchVendorLookupAction = "/Vendor/SearchVendorLookup";
        public const String GetVendorListAction = "/Vendor/GetVendorList";

        protected override void Startup()
        {
            Settings.Title = "Supplier-Vendor Master Screen";
            ViewData["REG_NO"] = this.GetCurrentRegistrationNumber();
        }

        #region COMMON LIST
        public static SelectList VendorSelectList
        {
            get
            {
                return VendorRepository.Instance
                    .GetVendorData()
                    .AsSelectList(vendor => vendor.VendorCd + " - " + vendor.VendorName, vendor => vendor.VendorCd);
            }
        }

        [HttpPost]
        public JsonResult GetVendorList()
        {
            try
            {
                IDictionary<String, Vendor> vendorList = VendorRepository.Instance.GetVendorData().ToDictionary(v => v.VendorCd, v => v);
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = new JavaScriptSerializer().Serialize(vendorList) });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public JsonResult GetUserVendor(string vendor)
        {
            try
            {
                string vendorResult = VendorRepository.Instance.GetSelectedData(vendor).VendorCd;
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = vendorResult });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult OpenVendorLookup(LookupSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new LookupViewModel<NameValueItem>();
                viewModel.Title = "Vendor";
                viewModel.DataList = VendorRepository.Instance.GetVendorLookupSearchList(searchViewModel);
                viewModel.GridPaging = VendorRepository.Instance.GetVendorLookupSearchListPaging(searchViewModel);

                return PartialView(LookupPage.GenericLookup, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult SearchVendorLookup(LookupSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new LookupViewModel<NameValueItem>();
                viewModel.DataList = VendorRepository.Instance.GetVendorLookupSearchList(searchViewModel);
                viewModel.GridPaging = VendorRepository.Instance.GetVendorLookupSearchListPaging(searchViewModel);

                return PartialView(LookupPage.GenericLookupGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
        #endregion

        #region SEARCH DATA
        private void Calldata(int Display, int Page, string VendorCode, string VendorName, string PayMethod, string PayTerm)
        {
            Paging pg = new Paging(VendorRepository.Instance.CountData("", VendorCode, VendorName, PayMethod, PayTerm), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["ListVendor"] = VendorRepository.Instance.GetListData("", VendorCode, VendorName, PayMethod, PayTerm, pg.StartData, pg.EndData);
        }

        [HttpPost]
        public ActionResult SearchData(int Display, int Page, string VendorCode, string VendorName, string PayMethod, string PayTerm)
        {
            Calldata(Display, Page, VendorCode, VendorName, PayMethod, PayTerm);
            return PartialView("_Grid");
        }

        #endregion

        #region CRUD METHOD
        public ActionResult SaveData(string flag, Vendor param)
        {
            string message = "";
            string uid = this.GetCurrentUsername(); //dummy, change with user id from session
            message = VendorRepository.Instance.SaveData(flag, param, uid);

            return new JsonResult
            {
                Data = new
                {
                    message = message
                }
            };
        }

        public ActionResult DeleteData(string VendorCode)
        {
            string message = "";

            // For support SQL Syntax, replace to SQL format string
            VendorCode = "'" + VendorCode.Replace(",", "','") + "'";

            try
            {
                message = VendorRepository.Instance.DeleteData(VendorCode);
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
                return Json(message, JsonRequestBehavior.AllowGet);
            }

            return Json(message, JsonRequestBehavior.AllowGet);
        }

        public ActionResult IsFlagEditAdd(string flag, string VendorCode)
        {
            ViewData["edit"] = flag;
            string PlantCd = "";
            if (flag == "0" && String.IsNullOrEmpty(VendorCode))
            {
                ViewData["VendorData"] = new Vendor();
            }
            else
            {
                ViewData["VendorData"] = VendorRepository.Instance.GetSelectedData(VendorCode);
                PlantCd = VendorRepository.Instance.GetPlantData(VendorCode);
                ViewData["DISABLED_FLAG"] = VendorRepository.Instance.CheckPlantCodeByRegNo(PlantCd, this.GetCurrentRegistrationNumber());
                ViewData["DIV_CD"] = VendorRepository.Instance.GetDivisionCode(this.GetCurrentRegistrationNumber());
            }
            
            ViewData["REG_NO"] = this.GetCurrentRegistrationNumber();
            ViewData["PLANT_BEFORE"] = PlantCd;
            return PartialView("_AddEditPopUp");
        }

        #endregion

        #region DOWNLOAD/UPLOAD
        public void DownloadData(object sender, EventArgs e, string VendorCode, string VendorName, string PayTerm, string PayMethod)
        {
            try
            {
                List<Vendor> data = VendorRepository.Instance.GetDownloadData(VendorCode, VendorName, PayTerm, PayMethod);

                string uid = this.GetCurrentUsername();
                string filename = "";
                string filesTmp = HttpContext.Request.MapPath(ReportPath.TemplateVendor);
                FileInfo FI = new FileInfo(filesTmp);
                if (FI.Exists)
                {
                    FileStream ftmp = new FileStream(filesTmp, FileMode.Open, FileAccess.Read);

                    HSSFWorkbook workbook = new HSSFWorkbook(ftmp, true);

                    ICellStyle styleContent1 = workbook.CreateCellStyle();
                    styleContent1.VerticalAlignment = VerticalAlignment.TOP;
                    styleContent1.BorderLeft = BorderStyle.THIN;
                    styleContent1.BorderRight = BorderStyle.THIN;
                    styleContent1.BorderBottom = BorderStyle.THIN;
                    styleContent1.Alignment = HorizontalAlignment.CENTER;

                    ICellStyle styleContent2 = workbook.CreateCellStyle();
                    styleContent2.VerticalAlignment = VerticalAlignment.TOP;
                    styleContent2.BorderLeft = BorderStyle.THIN;
                    styleContent2.BorderRight = BorderStyle.THIN;
                    styleContent2.BorderBottom = BorderStyle.THIN;
                    styleContent2.Alignment = HorizontalAlignment.LEFT;

                    ISheet sheet = workbook.GetSheet("VendorMaster");
                    string date = DateTime.Now.ToString("yyyyMMddhhmmss");
                    filename = "vendorMaster_" + date + ".xls";

                    sheet.GetRow(2).GetCell(2).SetCellValue(uid);
                    sheet.GetRow(3).GetCell(2).SetCellValue(DateTime.Now.ToString("dd.MM.yyyy"));

                    int row = 7;
                    IRow Hrow;
                    string dt;
                    foreach (var item in data)
                    {
                        Hrow = sheet.CreateRow(row);

                        Hrow.CreateCell(1).SetCellValue(item.VendorCd);
                        Hrow.CreateCell(2).SetCellValue(item.VendorName);
                        Hrow.CreateCell(3).SetCellValue(item.VendorPlant);
                        Hrow.CreateCell(4).SetCellValue(item.SAPVendorID);
                        Hrow.CreateCell(5).SetCellValue(item.PaymentMethodCd);
                        Hrow.CreateCell(6).SetCellValue(item.PaymentTermCd);
                        Hrow.CreateCell(7).SetCellValue(item.CreatedBy);
                        Hrow.CreateCell(8).SetCellValue(item.CreatedDt.ToString("dd.MM.yyyy"));
                        Hrow.CreateCell(9).SetCellValue(item.ChangedBy);
                        dt = item.ChangedDt.ToString("dd.MM.yyyy") == "01.01.0001" ? "" : item.ChangedDt.ToString("dd.MM.yyyy");
                        Hrow.CreateCell(10).SetCellValue(dt);

                        Hrow.GetCell(1).CellStyle = styleContent1;
                        Hrow.GetCell(2).CellStyle = styleContent2;
                        Hrow.GetCell(3).CellStyle = styleContent1;
                        Hrow.GetCell(4).CellStyle = styleContent1;
                        Hrow.GetCell(5).CellStyle = styleContent1;
                        Hrow.GetCell(6).CellStyle = styleContent1;
                        Hrow.GetCell(7).CellStyle = styleContent2;
                        Hrow.GetCell(8).CellStyle = styleContent1;
                        Hrow.GetCell(9).CellStyle = styleContent2;
                        Hrow.GetCell(10).CellStyle = styleContent1;

                        row++;
                    }

                    MemoryStream ms = new MemoryStream();
                    workbook.Write(ms);
                    ftmp.Close();
                    Response.BinaryWrite(ms.ToArray());
                    Response.ContentType = "application/vnd.ms-excel";
                    Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", filename));
                    Session["Message"] = "Data Downloaded Successfully";
                }
            }
            catch (Exception ex)
            {
                Session["Message"] = "Error | " + ex.Message;
            }
        }

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
            string filepath = Path.Combine(Server.MapPath("~/Content/Download/Template/VENDOR.xls"));
            byte[] docBytes = StreamFile(filepath);

            return File(docBytes, "application/vmd.ms-excel", "VENDOR.xls");
        }

        public ActionResult CekTemplate()
        {
            string cektemplate = "";

            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/Template/VENDOR.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
                cektemplate = "True";
            else
                cektemplate = "False";

            return Json(cektemplate, JsonRequestBehavior.AllowGet);
        }

        public bool EmailValidation(string listmail)
        {
            foreach (string mail in listmail.Split(';'))
            {
                if (!Regex.IsMatch(mail, @"\A(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?)\Z", RegexOptions.IgnoreCase))
                    return false;
            }
            return true;
        }

        [HttpPost]
        public ActionResult UploadFile()
        {
            string resultFilePath = "";
            string savefile = "";
            string message = "";

            string uid = this.GetCurrentUsername();
            string FunctionId = "102002";
            string ModuleId = "1";
            string loc = "Upload Vendor Master";
            Int64 ProcessId = VendorRepository.Instance.GetProcessId("Upload Process Started", loc, "", "INF", ModuleId, FunctionId, 0, uid);

            try
            {
                var file = Request.Files[0];
                var filename = Path.GetFileName(file.FileName);
                savefile = Path.Combine(Server.MapPath("~/Content/UploadFile"), filename);
                resultFilePath = Path.Combine("~/Content/UploadFile", filename);
                file.SaveAs(Server.MapPath(resultFilePath));

                #region Open Excel File
                FileStream fs = new FileStream(Server.MapPath(resultFilePath), FileMode.OpenOrCreate, FileAccess.ReadWrite);
                HSSFWorkbook wb = new HSSFWorkbook(fs);
                ISheet sheet = wb.GetSheet("Sheet1");
                #endregion

                loc = "Get Data From Excel File";
                VendorRepository.Instance.InsertLog("Insert Data Into Temporary Table Started", loc, ProcessId, "", "INF", "", null, 0, uid);
                int row = 1;
                for (int i = 1; i <= sheet.LastRowNum; i++)
                {
                    if ((sheet.GetRow(row) != null) && ((sheet.GetRow(row).GetCell(1) != null) && (sheet.GetRow(row).GetCell(2) != null) && (sheet.GetRow(row).GetCell(3) != null) &&
                        (sheet.GetRow(row).GetCell(4) != null) && (sheet.GetRow(row).GetCell(5) != null) && (sheet.GetRow(row).GetCell(6) != null)))
                    {
                        Vendor data = new Vendor();
                        //DataRow dtrow = dt.NewRow();
                        data.VendorCd = sheet.GetRow(row).GetCell(0).ToString();
                        data.VendorName = sheet.GetRow(row).GetCell(1).ToString();
                        data.VendorPlant = sheet.GetRow(row).GetCell(2).ToString();
                        data.SAPVendorID = sheet.GetRow(row).GetCell(3).ToString();
                        data.PurchGroup = sheet.GetRow(row).GetCell(4).ToString();
                        data.PaymentMethodCd = sheet.GetRow(row).GetCell(5).ToString();
                        data.PaymentTermCd = sheet.GetRow(row).GetCell(6).ToString();
                        data.Address = sheet.GetRow(row).GetCell(7).ToString();
                        data.City = sheet.GetRow(row).GetCell(8).ToString();
                        data.Phone = sheet.GetRow(row).GetCell(9).ToString();
                        data.Fax = sheet.GetRow(row).GetCell(10).ToString();
                        data.Attention = sheet.GetRow(row).GetCell(11).ToString();
                        data.Postal = sheet.GetRow(row).GetCell(12).ToString();
                        data.Country = sheet.GetRow(row).GetCell(13).ToString();
                        data.Mail = sheet.GetRow(row).GetCell(14).ToString();
                        data.CreatedBy = uid;
                        data.ProcessId = ProcessId;
                        data.Row = (row + 1).ToString();
                        if (data.Mail == "" || data.Mail == "-" || data.Mail == "NULL")
                            data.ErrorFlag = "N";
                        else
                            data.ErrorFlag = EmailValidation(data.Mail) ? "N" : "Y";

                        VendorRepository.Instance.InsertTemporary(data);

                        row++;
                    }
                    else break;
                }
                VendorRepository.Instance.InsertLog("Insert Data Into Temporary Table Finished", loc, ProcessId, "", "INF", "", null, 0, uid);

                loc = "Data Validation";
                VendorRepository.Instance.UploadValidation(ProcessId, loc, uid);

                loc = "Insert Data Into Master Table";
                int rowsuccess = VendorRepository.Instance.SaveUploadData(ProcessId, loc, uid);
                message = "Data Successfully Uploaded";

                if (System.IO.File.Exists(savefile))
                    System.IO.File.Delete(savefile);

                VendorRepository.Instance.DeleteTemporary(ProcessId);
                loc = "Upload Vendor Master";
                VendorRepository.Instance.InsertLog("Upload Process Finished", loc, ProcessId, "", "INF", "", null, 0, uid);

                if (rowsuccess == (row - 1)) message = "Data Successfully Uploaded";
                else if (rowsuccess < (row - 1) && rowsuccess > 0) message = "War|Upload Finish with Error. Please view logging with Process Id " + ProcessId.ToString() + " for detail.";
                else message = "Error|Error occured when uploading. Please view logging with Process Id " + ProcessId.ToString() + " for detail.";
            }
            catch (Exception e)
            {
                if (System.IO.File.Exists(savefile))
                    System.IO.File.Delete(savefile);

                VendorRepository.Instance.InsertLog(e.Message, loc, ProcessId, "", "ERR", "", null, 1, uid);
                loc = "Upload Vendor Master";
                VendorRepository.Instance.InsertLog("Upload Process Finished", loc, ProcessId, "", "INF", "", null, 3, uid);
                VendorRepository.Instance.DeleteTemporary(ProcessId);

                message = e.Message.ToString();
                return Json(new { message = "Error|" + message }, JsonRequestBehavior.AllowGet);
            }
            return Json(new { message = message }, JsonRequestBehavior.AllowGet);
        }
        #endregion
    }
}