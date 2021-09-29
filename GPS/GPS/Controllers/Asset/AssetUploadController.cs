using System;
using System.Collections.Generic;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.Models.Asset;
using Toyota.Common.Web.Platform;
using System.IO;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using Toyota.Common.Web.Platform;
using System.IO;
using GPS.CommonFunc;
using GPS.Models.Master;
using GPS.Models.Common;
using System;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;


namespace GPS.Controllers.Asset
{
    public class AssetUploadController : PageController
    {
        #region List Of Controller Method
        public const String _AssetUploadController = "/AssetUpload/";

        public const String _DeleteData = _AssetUploadController + "DeleteData";
        public const String _Search = _AssetUploadController + "Search";
        
        public const String _UploadInit = _AssetUploadController + "UploadInitialization";
        public const String _UploadValidation = _AssetUploadController + "UploadValidation";
        public const String _SaveFileTemp = _AssetUploadController + "MoveFileToTemp";
        public const String _DeleteFileTemp = _AssetUploadController + "DeleteTempFile";

        public const String _GetTemp = _AssetUploadController + "GetTempData";
        public const String _DeleteTemp = _AssetUploadController + "DeleteTempData";
        public const String _SaveTemp = _AssetUploadController + "SaveTempData";
        public const String _CancelUpload = _AssetUploadController + "CancelUpload";
        public const String _CancelSave = _AssetUploadController + "CancelSave";
        public const String _SaveData = _AssetUploadController + "SaveData";
        #endregion

        public AssetUploadController()
        {
            Settings.Title = "Asset Upload Screen";
        }

        protected override void Startup()
        {
        }

        #region SEARCH
        public ActionResult Search(AssetUpload param, string issearch, int page = 1, int pageSize = 10)
        {
            if (issearch == "Y")
            {
                Tuple<int, string> RowCounts = new Tuple<int, string>(0, "");
                int RowLimit = 0;
                int RowCount = 0;
                Tuple<List<AssetUpload>, string> List = new Tuple<List<AssetUpload>, string>(new List<AssetUpload>(), "");

                try
                {
                    List = AssetRepository.Instance.ListData(param, (((page - 1) * pageSize) + 1), (page * pageSize));
                    if (List.Item2 != "")
                        throw new Exception(List.Item2);

                    RowCounts = AssetRepository.Instance.CountRetrievedData(param);
                    if (RowCounts.Item2 != "")
                        throw new Exception(RowCounts.Item2);

                    RowLimit = Convert.ToInt32(SystemRepository.Instance.GetSystemValue("MAX_SEARCH"));

                    string message = RowCounts.Item1 >= RowLimit ? "Total data too much, more than " + RowLimit + ", System only show new " + RowLimit + " Data" : "";
                    RowCount = RowCounts.Item1 >= RowLimit ? RowLimit : RowCounts.Item1;

                    ViewData["GridData"] = new Tuple<List<AssetUpload>, int, string>(List.Item1, page, message);
                    ViewData["TypePaging"] = "Header";
                    ViewData["PagingDataHeader"] = new Tuple<Paging, string, string>(CountIndex(RowCount, pageSize, page), "Search", "0");
                }
                catch (Exception e)
                {
                    ViewData["Message"] = "Error : " + e.Message;
                }
            }
            return PartialView("_GridAsset");
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

        #region UPLOAD
        public ActionResult UploadInitialization()
        {
            Tuple<string, long, int, string> file_validation;
            string validextension = "";
            string message = "";
            long maxFileSize = 0;
            int maxUploadFile = 0;
            string ProcessId = "0";

            try
            {
                validextension = SystemRepository.Instance.GetUploadDataFileExtension();
                maxFileSize = Convert.ToInt64(SystemRepository.Instance.GetUploadFileSizeLimit());
                maxUploadFile = Convert.ToInt32(SystemRepository.Instance.GetSystemValue("UPLOAD_MAX_FILE"));

                ProcessIdRepository procidrepo = new ProcessIdRepository();
                ProcessId = procidrepo.GetNewProcessId("2", "202001", "Asset Upload");
            }
            catch (Exception ex)
            {
                message = ex.Message;
            }
            finally
            {
                file_validation = new Tuple<string, long, int, string>(validextension, maxFileSize, maxUploadFile, message);
                ViewData["ValidationTemp"] = file_validation;
                ViewData["ProcessId"] = ProcessId;
            }

            return PartialView("_PopupUploadAsset");
        }

        public string MoveFileToTemp(HttpPostedFileBase file, string PROCESS_ID)
        {
            string message = "";

            try
            {
                if (file == null)
                {
                    throw new Exception("File is Null, Please Upload Again");
                }

                string dirpath = GetDocumentTempPath() + PROCESS_ID + "\\";
                if (Directory.Exists(dirpath))
                    Directory.Delete(dirpath, true);

                Directory.CreateDirectory(dirpath);

                string filepath = dirpath + "ASSET_" + DateTime.Now.ToString("ddMMyyyyHHmmssffff") + Path.GetExtension(file.FileName);
                file.SaveAs(filepath);

                message = "SUCCESS|" + Path.GetFileName(filepath);
            }
            catch (Exception ex)
            { 
                message = "ERR|" + ex.Message;
            }
            
            return message;
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

        public void DownloadFile(string PROCESS_ID, string FILE_PATH)
        {
            string path = GetDocumentTempPath() + PROCESS_ID + "\\" + FILE_PATH;
            string mime = GetMimeType(path);

            Response.Clear();
            Response.ContentType = mime;
            Response.AppendHeader("content-disposition", "attachment; filename=" + FILE_PATH);
            Response.TransmitFile(path);
            Response.End();
        } 

        public String GetDocumentTempPath()
        {
            String downloadBasePathSystemValue = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
            String tempPathSystemValue = SystemRepository.Instance.GetSystemValue("ASSET_UPLOAD_TEMP_PATH");
            return Path.GetFullPath(downloadBasePathSystemValue + "\\" + tempPathSystemValue);
        }

        public String DeleteTempFile(string PROCESS_ID, string FILE_PATH)
        {
            try
            {
                string dirpath = GetDocumentTempPath() + PROCESS_ID + "\\" + FILE_PATH;
                System.IO.File.Delete(dirpath);
                return "SUCCESS|";
            }
            catch (Exception ex)
            {
                return "ERR|" + ex.Message;
            }
        }

        public String DeleteTempFolder(string FOLDER_PATH)
        {
            try
            {
                if (Directory.Exists(FOLDER_PATH))
                    Directory.Delete(FOLDER_PATH, true);
                
                return "SUCCESS|";
            }
            catch (Exception ex)
            {
                return "ERR|" + ex.Message;
            }
        }

        public string SaveTempData(string PROCESS_ID)
        {
            string message = "";

            try
            {
                string dirpath = GetDocumentTempPath() + PROCESS_ID + "\\";
                string[] files = Directory.GetFiles(dirpath);

                foreach (string filename in files)
                { 
                    AssetRepository.Instance.SaveTemp(filename, this.GetCurrentUsername(), PROCESS_ID);
                    AssetRepository.Instance.ValidateTemp(PROCESS_ID);
                }
                message = "SUCCESS|";
            }
            catch (Exception ex)
            {
                message = "ERR|" + ex.Message;
                AssetRepository.Instance.DeleteTemp(PROCESS_ID);
            }

            return message;
        }

        [HttpPost]
        public ActionResult UploadValidation(string PROCESS_ID)
        {
            Tuple<List<AssetUpload>, string, string> assetdetail = AssetRepository.Instance.GetTemp(PROCESS_ID);
            ViewData["AssetDetail"] = assetdetail;

            return PartialView("_PopupValidationAsset");
        }

        public ActionResult GetTempData(string PROCESS_ID)
        {
            Tuple<List<AssetUpload>, string, string> assetdetail = AssetRepository.Instance.GetTemp(PROCESS_ID);
            ViewData["AssetDetail"] = assetdetail;

            return PartialView("_PopupValidationGrid");
        }

        public string DeleteTempData(AssetUpload param)
        {
            string result = "";

            result = AssetRepository.Instance.DeleteSelectedTemp(param);

            return result;
        }

        public string CancelUpload(string PROCESS_ID)
        {
            string dirpath = GetDocumentTempPath() + PROCESS_ID + "\\";
            string result = DeleteTempFolder(dirpath);

            return result;
        }

        public string CancelSave(string PROCESS_ID)
        {
            string result = "";

            result = AssetRepository.Instance.CancelSaving(PROCESS_ID);
            if (result.Split('|')[0] == "SUCCESS")
            {
                string dirpath = GetDocumentTempPath() + PROCESS_ID + "\\";
                result = DeleteTempFolder(dirpath);
            }

            return result;
        }

        public string SaveData(string PROCESS_ID)
        {
            Tuple<string, string> result;

            result = AssetRepository.Instance.SaveValidation(PROCESS_ID);
            if (result.Item1 == "SUCCESS")
                result = AssetRepository.Instance.SaveData(PROCESS_ID);

            if (result.Item1 == "SUCCESS")
            {
                string dirpath = GetDocumentTempPath() + PROCESS_ID + "\\";
                string strresult = DeleteTempFolder(dirpath);
                result = new Tuple<string, string>(strresult.Split('|')[0], strresult.Split('|')[1]);
            }

            return result.Item1 + "|" + result.Item2;
        }
        #endregion

        #region DELETE
        public string DeleteData(AssetUpload param)
        {
            string result = "";

            result = AssetRepository.Instance.DeleteData(param);

            return result;
        }
        #endregion

        #region DOWNLOAD
        public void Download(AssetUpload param)
        {
            string filePath = HttpContext.Request.MapPath("~/Content/Download/Template/ASSET.xls");
            FileStream ftmp = new FileStream(filePath, FileMode.Open, FileAccess.Read);

            HSSFWorkbook workbook = new HSSFWorkbook(ftmp);

            IRow Hrow;
            int row = 1;

            string username = this.GetCurrentUsername();
            List<AssetUpload> header = new List<AssetUpload>();
            header = AssetRepository.Instance.DownloadData(param).ToList();

            ISheet sheet;

            ICellStyle styleContent1 = workbook.CreateCellStyle();
            styleContent1.VerticalAlignment = VerticalAlignment.TOP;
            styleContent1.BorderLeft = NPOI.SS.UserModel.BorderStyle.THIN;
            styleContent1.BorderBottom = NPOI.SS.UserModel.BorderStyle.THIN;
            styleContent1.BorderTop = NPOI.SS.UserModel.BorderStyle.THIN;
            styleContent1.BorderRight = NPOI.SS.UserModel.BorderStyle.THIN;
            styleContent1.FillForegroundColor = NPOI.HSSF.Util.HSSFColor.YELLOW.index;

            ICellStyle styleContent2 = workbook.CreateCellStyle();
            styleContent2.Alignment = HorizontalAlignment.CENTER;
            styleContent2.BorderLeft = NPOI.SS.UserModel.BorderStyle.THIN;
            styleContent2.BorderBottom = NPOI.SS.UserModel.BorderStyle.THIN;
            styleContent2.BorderTop = NPOI.SS.UserModel.BorderStyle.THIN;
            styleContent2.BorderRight = NPOI.SS.UserModel.BorderStyle.THIN;
            styleContent2.FillForegroundColor = NPOI.HSSF.Util.HSSFColor.YELLOW.index;
            styleContent2.FillBackgroundColor = NPOI.HSSF.Util.HSSFColor.RED.index;
            styleContent2.WrapText = true;

            ICellStyle styleContent3 = workbook.CreateCellStyle();
            styleContent3.Alignment = HorizontalAlignment.CENTER;
            styleContent3.BorderLeft = NPOI.SS.UserModel.BorderStyle.THIN;
            styleContent3.BorderBottom = NPOI.SS.UserModel.BorderStyle.THIN;
            styleContent3.BorderTop = NPOI.SS.UserModel.BorderStyle.THIN;
            styleContent3.BorderRight = NPOI.SS.UserModel.BorderStyle.THIN;
            styleContent3.FillForegroundColor = NPOI.HSSF.Util.HSSFColor.YELLOW.index;
            styleContent3.WrapText = true;//Word wrap
            styleContent3.VerticalAlignment = VerticalAlignment.CENTER;

            sheet = workbook.GetSheetAt(0);

            int rowCount = header.Count();

            foreach (AssetUpload asset in header)
            {
                Hrow = sheet.CreateRow(row);
                Hrow.CreateCell(0).SetCellValue(asset.PR_NO);
                Hrow.CreateCell(1).SetCellValue(asset.ITEM_NO);
                Hrow.CreateCell(2).SetCellValue(asset.SEQ_NO);
                Hrow.CreateCell(3).SetCellValue(asset.ASSET_CATEGORY);
                Hrow.CreateCell(4).SetCellValue(asset.ASSET_CLASS);
                Hrow.CreateCell(5).SetCellValue(asset.ASSET_LOCATION);
                Hrow.CreateCell(6).SetCellValue(asset.REGISTRATION_DATE);
                Hrow.CreateCell(7).SetCellValue(asset.ASSET_NO);
                Hrow.CreateCell(8).SetCellValue(asset.SUBASSET_NO);
                Hrow.CreateCell(9).SetCellValue(asset.SERIAL_NO);
                //Hrow.CreateCell(9).SetCellValue(Convert.ToDouble(asset.INITIAL_RATE));
                row++;
            }

            MemoryStream ms = new MemoryStream();
            workbook.Write(ms);
            ftmp.Close();
            Response.BinaryWrite(ms.ToArray());

            Response.ContentType = "application/ms-excel";
            string filenametrimmed = "Asset.xls";
            Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", filenametrimmed));
        }
        #endregion


    }
}
