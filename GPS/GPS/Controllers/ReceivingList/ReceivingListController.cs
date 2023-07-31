using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Toyota.Common.Web.Platform;
using GPS.Models.ReceivingList;
using GPS.Models.Common;
using GPS.Common.Data;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.ViewModels;
using GPS.ViewModels.Master;
using GPS.ViewModels.ReceivingList;
using GPS.Models;
using System.IO;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using GPS.Models.Master;

namespace GPS.Controllers
{
    public class ReceivingListController : PageController
    {

        private ReceivingListRepository receivingListRepo = ReceivingListRepository.Instance;
        private SupplierRepository supplierRepo = SupplierRepository.Instance;
        private GR_IRRepository grIrRepo = GR_IRRepository.Instance;

        public const String _ReceivingUploadController = "/ReceivingList/";
        public const String _SaveFileTemp = _ReceivingUploadController + "MoveFileToTemp";
        public const String _DeleteFileTemp = _ReceivingUploadController + "DeleteTempFile";

        protected override void Startup()
        {
            Settings.Title = "Receiving List";

            constructComboBoxes();
            getRecevingList(new ReceivingListSearchViewModel {CurrentPage = 1, PageSize = PaginationViewModel.DefaultPageSize});

            var processIdRepo = new ProcessIdRepository();

            ViewBag.ProcessId = processIdRepo.GetNewProcessId(ModuleId.Receiving, FunctionId.ReceivingList, "Initial");
            ViewBag.UserName = this.GetCurrentUsername();

            ViewBag.MaxFileSize = SystemRepository.Instance.GetSingleData("RCVLST", "MAX_SIZE_FILE_UPLOAD").Value;
            ViewBag.AllowExtension = SystemRepository.Instance.GetSingleData("RCVLST", "EXT_FILE_UPLOAD").Value;
        }

        private void getRecevingList(ReceivingListSearchViewModel searchViewModel)
        {
            int countdata = 0;
            searchViewModel.User = this.GetCurrentUsername();
            countdata = receivingListRepo.countReceivingList(searchViewModel);

            Paging pg = new Paging(countdata, searchViewModel.CurrentPage, searchViewModel.PageSize);
            ViewData["CountData"] = countdata;
            ViewData["Paging"] = pg;
            ViewBag.MaxFileSize = SystemRepository.Instance.GetSingleData("RCVLST", "MAX_SIZE_FILE_UPLOAD").Value;
            ViewBag.AllowExtension = SystemRepository.Instance.GetSingleData("RCVLST", "EXT_FILE_UPLOAD").Value;        
            
            ViewData["ReceivingListInquiry"] = receivingListRepo.GetReceivingList(searchViewModel);
        }

        public static SelectList GRSASelectList
        {
            get
            {
                return ReceivingListRepository.Instance.GetStatus()
                    .AsSelectList(st => st.STATUS_DESC, st => st.STATUS_CD);
            }
        }

        public void constructComboBoxes()
        {
            ViewData["StatusList"] = receivingListRepo.GetStatus();

            getLookupSupplierSearch(
                CommonFunction.Instance.DefaultStringValue(),
                CommonFunction.Instance.DefaultPage(),
                CommonFunction.Instance.DefaultSize());
        }

        public ActionResult onLookupSupplier(string Parameter, string PartialViewSearchAndInput, int Page)
        {
            if (PartialViewSearchAndInput.Equals("_LookupTableSupplier"))
            {
                getLookupSupplierSearch(
                    Parameter,
                    Page,
                    CommonFunction.Instance.DefaultSize());
            }

            return PartialView(PartialViewSearchAndInput);
        }

        private void getLookupSupplierSearch(string parameter, int page, int size)
        {
            Paging pg = new Paging(supplierRepo.countSupplier(parameter), page, size);

            ViewData["LookupPaging"] = pg;

            ViewData["Suppliers"] = supplierRepo.GetSupplier(parameter, pg.StartData, pg.EndData);
        }

        public ActionResult GetReceivingListDetail(int CurrentPage, int PageSIZE, String receivingNo)
        {
            int countdata = 0;
            //searchViewModel.User = this.GetCurrentUsername();
            countdata = receivingListRepo.countReceivingListDetail(receivingNo);

            Paging pg = new Paging(countdata, CurrentPage, PageSIZE);
            ViewData["CountData"] = countdata;
            ViewData["LookupPaging"] = pg;

            ViewData["MaterialList"] = receivingListRepo.GetReceivingListDetail(receivingNo);
            return PartialView("_MatDocDetailPopUp");
        }

        public string ApproveGR(List<GR_IR_DATA> items)
        {
            string results = "";
            try
            {
                string NoReg = Lookup.Get<Toyota.Common.Credential.User>().RegistrationNumber;

                for (int i = 0; i < items.Count; i++)
                {
                    results = receivingListRepo.ApproveGR(items[i].PO_NUMBER, items[i].PO_ITEM,
                        items[i].PO_DATE_STRING, items[i].VEND_CODE, items[i].GR_STATUS, items[i].INVOICE_ID, NoReg);
                }

            }
            catch (Exception ex)
            {
                results = "ERR|" + ex.Message;
            }
            return results;
        }

        public String CancelGR(String matDocNumber, String cancelDate, String cancelReason, String ProcessId)
        {
            String results = "SUCCESS|";
            try
            {
                var viewModel = new CancelGRSAViewModel();
                viewModel.CurrentUser = this.GetCurrentUsername();
                viewModel.CurrentRegNo = this.GetCurrentRegistrationNumber();
                viewModel.ProcessId = ProcessId;
                viewModel.ModuleId = ModuleId.Receiving;
                viewModel.FunctionId = FunctionId.ReceivingList;
                viewModel.MatDoc = matDocNumber;
                viewModel.CancelDateString = cancelDate;
                viewModel.CancelReason = cancelReason;
                GR_IRRepository.Instance.ValidateCancelGR(viewModel);
                GR_IRRepository.Instance.SaveCancelGR(viewModel);
            }
            catch (Exception e)
            {
                results = "ERR|" + e.Message;
            }
            return results;
        }


        public ActionResult search(ReceivingListSearchViewModel searchViewModel)
        {
            string yhs = this.GetCurrentUsername();
            getRecevingList(searchViewModel);
            return PartialView("_GridView");
        }

        public void DownloadReceivingListExcel(ReceivingListSearchViewModel searchViewModel)
        {
            CommonDownload downloadEngine = CommonDownload.Instance;
            searchViewModel.User = this.GetCurrentUsername();
            string fileName = string.Format("ReceivingList{0}.xls", DateTime.Now.ToString("yyyyMMddHHmmss"));
            string filePathTemplete = HttpContext.Request.MapPath(downloadEngine.GetServerFilePath("ReceivingListTemplete.xls"));
            FileStream ftmp = new FileStream(filePathTemplete, FileMode.Open, FileAccess.Read);
            var workbook = new HSSFWorkbook(ftmp);
            var dataListExcel = new List<ReceivingListDownloadExcel>(receivingListRepo.GetDownloadExcel(searchViewModel));

            ISheet sheet; IRow Hrow; int row = 1;

            IFont font = downloadEngine.GenerateFontExcel(workbook);
            ICellStyle styleCenter = downloadEngine.GenerateStyleCenter(workbook, font);
            ICellStyle styleRight = downloadEngine.GenerateStyleRight(workbook, font);
            ICellStyle styleNormal = downloadEngine.GenerateStyleNormal(workbook, font);

            sheet = workbook.GetSheetAt(0);

            foreach (ReceivingListDownloadExcel item in dataListExcel)
            {
                Hrow = sheet.CreateRow(row);
                downloadEngine.WriteCellValue(Hrow, 0, styleNormal, item.RECEIVING_NO);
                downloadEngine.WriteCellValue(Hrow, 1, styleNormal, item.RECEIVING_ITEM_NO);
                downloadEngine.WriteCellValue(Hrow, 2, styleCenter, string.Format("{0:yyyy-MM-dd}", item.RECEIVING_DATE));
                downloadEngine.WriteCellValue(Hrow, 3, styleNormal, item.HEADER_TEXT);
                downloadEngine.WriteCellValue(Hrow, 4, styleCenter, item.RECEIVING_QUANTITY);
                downloadEngine.WriteCellValue(Hrow, 5, styleCenter, item.PO_QUANTITY);
                downloadEngine.WriteCellValue(Hrow, 6, styleCenter, item.REMAINING_QUANTITY);
                downloadEngine.WriteCellValue(Hrow, 7, styleRight, item.RECEIVING_AMOUNT);
                downloadEngine.WriteCellValue(Hrow, 8, styleNormal, item.VENDOR_CD);
                downloadEngine.WriteCellValue(Hrow, 9, styleNormal, item.VENDOR_NAME);
                downloadEngine.WriteCellValue(Hrow, 10, styleCenter, item.STATUS);
                downloadEngine.WriteCellValue(Hrow, 11, styleCenter, string.Format("{0:yyyy-MM-dd}", item.POSTING_DATE));
                downloadEngine.WriteCellValue(Hrow, 12, styleCenter, item.DOCUMENT_NO);
                downloadEngine.WriteCellValue(Hrow, 13, styleCenter, item.PO_NO);
                downloadEngine.WriteCellValue(Hrow, 14, styleCenter, item.PO_ITEM_NO);
                downloadEngine.WriteCellValue(Hrow, 15, styleCenter, item.PR_NO);
                downloadEngine.WriteCellValue(Hrow, 16, styleCenter, item.PR_ITEM_NO);
                downloadEngine.WriteCellValue(Hrow, 17, styleCenter, string.Format("{0:yyyy-MM-dd}", item.CANCEL_DATE));
                downloadEngine.WriteCellValue(Hrow, 18, styleNormal, item.CANCEL_REASON);
                row++;
            }

            CreateExcelFile(fileName, ftmp, workbook);
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

        //20191127 message error posting
        public JsonResult errorPosting(string receivingNo)
        {
            List<string> result = new List<string>();
            //string result = "";
            string msg = "";

            try
            {

                result = ReceivingListRepository.Instance.getErrorPosting(receivingNo);
                //System.Web.Script.Serialization.JavaScriptSerializer oSerializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                //string StudentJson = oSerializer.Serialize(result);

            }
            catch (Exception e)
            { 
                msg = e.Message;
            }
            return Json(result);
        }

        //20230705 -> Enchanced Vision Project
        public JsonResult concurencyChecking(string receivingNo, string changeDtParam)
        {
            int result = 0;
            string msg = "";

            try
            {

                result = ReceivingListRepository.Instance.concurencyChecking(receivingNo, changeDtParam);

            }
            catch (Exception e)
            {
                msg = e.Message;
            }
            return Json(result);
        }

        public ActionResult GetReceivingListUpload(String receivingNo)
        {
            ViewData["UploadList"] = receivingListRepo.GetReceivingListUpload(receivingNo);
            return PartialView("_UploadAttachPopUp");
        }

        public string MoveFileToTemp(HttpPostedFileBase file, string rcvNo, int id, string chgDate)
        {
            string message = "";

            string uid = this.GetCurrentUsername();
            string FunctionId = "501003";
            string ModuleId = "5";
            string loc = "Upload Attachment";
            Int64 ProcessID = 0;

            try
            {
                if (ReceivingListRepository.Instance.concurencyChecking(rcvNo, chgDate) == 1 && id == 1)
                {
                    message = "ERR|Concurrency found in Upload (Edit Mode) operation";
                }
                else
                {

                    Tuple<Int64, string> newcreation = receivingListRepo.UploadInit(this.GetCurrentUsername());
                    ProcessID = newcreation.Item1;

                    if (file == null)
                    {
                        throw new Exception("File is Null, Please Upload Again");
                    }

                    VendorRepository.Instance.InsertLog("Executing check uploaded attachment file (Receiving No " + rcvNo + ") process", loc, ProcessID, "INF00008", "INF", "", null, 0, uid);

                    string mainPath = SystemRepository.Instance.GetSingleData("RCVLST", "ATTACHMENT_PATH").Value;

                    string dirpath = mainPath + DateTime.Now.Year.ToString() + @"\" + rcvNo + @"\"; 

                    string filepath = dirpath + file.FileName;
                    bool flagNew = false;

                    if (Directory.Exists(dirpath))
                    {

                        loc = "File Found";
                        VendorRepository.Instance.InsertLog("Executing delete all physical file on " + dirpath + " process", loc, ProcessID, "INF00008", "INF", "", null, 0, uid);

                        //Directory.Delete(dirpath, true);
                        if (receivingListRepo.GetAttachByid(rcvNo, id) != null)
                        {
                            string oldPath = receivingListRepo.GetAttachByid(rcvNo, id).AttachmentPath;
                            if (System.IO.File.Exists(oldPath))
                            {
                                loc = "Delete file";
                                VendorRepository.Instance.InsertLog("Executing delete attachmend data for Receiving No " + rcvNo + " process", loc, ProcessID, "INF00008", "INF", "", null, 0, uid);

                                System.IO.File.Delete(oldPath);
                            }
                        }
                    }
                    else
                    {
                        flagNew = true;
                        loc = "Create Directory";
                        VendorRepository.Instance.InsertLog("Executing create new folder (" + dirpath + ") process", loc, ProcessID, "INF00008", "INF", "", null, 0, uid);

                        Directory.CreateDirectory(dirpath);
                    }

                    if (flagNew)
                    {
                        loc = "Save file";
                        VendorRepository.Instance.InsertLog("Executing insert attachment data for Receiving No " + rcvNo + " process", loc, ProcessID, "INF00008", "INF", "", null, 0, uid);
                    }
                    else
                    {
                        loc = "Save file";
                        VendorRepository.Instance.InsertLog("Executing upload new attachment file " + file.FileName + " to " + dirpath + " for Receiving No " + rcvNo + " process", loc, ProcessID, "INF00008", "INF", "", null, 0, uid);
                    }

                    file.SaveAs(filepath);

                    var a = receivingListRepo.UpdateGRAttachment(rcvNo, id, filepath, file.FileName, this.GetCurrentUsername());

                    loc = "Upload Attachment";
                    VendorRepository.Instance.InsertLog("Upload Attachment is finished successfully.", loc, ProcessID, "INF00006", "INF", "", null, 0, uid);

                    message = "SUCCESS|" + Path.GetFileName(filepath) + "|" + a;
                }
            }
            catch (Exception ex)
            {
                VendorRepository.Instance.InsertLog("System error has occurred : " + ex.Message, loc, ProcessID, "ERR00016", "ERR", "", null, 1, uid);
                loc = "Upload Attachment";
                VendorRepository.Instance.InsertLog("Upload Attachment is finished with error.", loc, ProcessID, "INF00007", "INF", "", null, 3, uid);

                message = "ERR|" + ex.Message;
            }

            return message;
        }

        public void DownloadFile(string rcvNo, int id)
        {
            string path = receivingListRepo.GetAttachByid(rcvNo, id).AttachmentPath;
            string mime = GetMimeType(path);

            Response.Clear();
            Response.ContentType = mime;
            Response.AppendHeader("content-disposition", "attachment; filename=" + Path.GetFileName(path));
            Response.TransmitFile(path);
            Response.End();
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

        public String DeleteTempFile(string rcvNo, int id, string chgDate)
        {
            try
            {
                if (ReceivingListRepository.Instance.concurencyChecking(rcvNo, chgDate) == 1)
                {
                    return "ERR|Concurrency found in Delete File operation";
                }
                else
                {
                    string dirpath = receivingListRepo.GetAttachByid(rcvNo, id).AttachmentPath;
                    var a = receivingListRepo.UpdateGRAttachment(rcvNo, id, "", "", this.GetCurrentUsername());
                    System.IO.File.Delete(dirpath);
                    return "SUCCESS|";
                }
            }
            catch (Exception ex)
            {
                return "ERR|" + ex.Message;
            }
        }

    }
}
