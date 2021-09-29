using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Constants;
using GPS.Constants.Master;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models.Common;
using GPS.Models.Master;
using GPS.ViewModels;
using GPS.ViewModels.Lookup;
using GPS.ViewModels.Master;
using Toyota.Common.Web.Platform;
using System.Web;
using System.IO;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;

namespace GPS.Controllers.Master
{
    public class PriceController : PageController
    {
        public const String SearchAction = "/Price/Search";
        public const String ClearSearchAction = "/Price/ClearSearch";
        public const String EditAction = "/Price/Edit";
        public const String DeleteAction = "/Price/Delete";
        public const String SaveAction = "/Price/Save";
        public const String GetUploadValidationInfoAction = "/Price/GetUploadValidationInfo";
        public const String UploadAction = "/Price/Upload";
        public const String UploadInit = "/Price/UploadInitialization";
        public const String SaveFileTemp = "/Price/MoveFileToTemp";
        public const String SaveUploadedData = "/Price/SaveUploadData";
        public const String DeleteFile = "/Price/DeleteTempFile";
        public const String Cancel= "/Price/CancelUpload";

        public sealed class Action
        {
            public const String OpenDraftVendorLookup = "/Price/OpenDraftVendorLookup";
            public const String SearchDraftVendorLookup = "/Price/SearchDraftVendorLookup";
            public const String OpenItemVendorLookup = "/Price/OpenItemVendorLookup";
            public const String SearchItemVendorLookup = "/Price/SearchItemVendorLookup";
        }

        protected override void Startup()
        {
            Settings.Title = "Price Master";
            Model = SearchEmpty();
        }

        private GenericViewModel<MaterialPrice> SearchEmpty()
        {
            var viewModel = new GenericViewModel<MaterialPrice>();
            viewModel.DataList = new List<MaterialPrice>();
            viewModel.GridPaging = PaginationViewModel.GetDefault(MaterialPriceRepository.DataName);

            return viewModel;
        }

        public static SelectList PriceStatusSelectList
        {
            get
            {
                return SystemRepository.Instance
                    .GetByFunctionId(FunctionId.PriceStatus)
                    .AsSelectList(sys => sys.Value + " - " + sys.Code, sys => sys.Code);
            }
        }

        public static SelectList PriceTypeSelectList
        {
            get
            {
                return SystemRepository.Instance
                    .GetByFunctionId(FunctionId.PriceType)
                    .AsSelectList(sys => sys.Value, sys => sys.Code);
            }
        }

        [HttpPost]
        public ActionResult Search(MaterialPriceSearchViewModel searchViewModel)
        {
            try
            {
                searchViewModel.FixDateFromAndTo();

                var viewModel = new GenericViewModel<MaterialPrice>();
                viewModel.CurrentUser = this.GetCurrentUser();
                viewModel.DataList = new List<MaterialPrice>(MaterialPriceRepository.Instance.GetList(searchViewModel));
                viewModel.GridPaging = MaterialPriceRepository.Instance.GetListPaging(searchViewModel);

                return PartialView(MaterialPricePage.GridPartial, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult ClearSearch()
        {
            try
            {
                var viewModel = SearchEmpty();
                return PartialView(MaterialPricePage.GridPartial, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult Delete(String primaryKeyList)
        {
            try
            {
                IEnumerable<String> codeList = MaterialPriceRepository.Instance.Delete(primaryKeyList);
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "Material Price(s) " + String.Join(", ", codeList) + " have been deleted." });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
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

        public ActionResult SearchData(string issearch, string MAT_NO, string DATE_FROM, string DATE_TO, string VENDOR_CD, 
                                       string PRICE_STATUS, string PRICE_TYPE, string SOURCE_TYPE, string PRODUCTION_PURPOSE,
                                       string PART_COLOR_SFX, string PACKING_TYPE, int page = 1, int pageSize = 10)
        {
            if (issearch == "Y")
            {
                List<MaterialPrice> PRList = MaterialPriceRepository.Instance.GetPrice(MAT_NO, DATE_FROM, DATE_TO, VENDOR_CD, PRICE_STATUS, PRICE_TYPE,
                                                                       SOURCE_TYPE, PRODUCTION_PURPOSE, PART_COLOR_SFX, PACKING_TYPE,
                                                                       (((page - 1) * pageSize) + 1), (pageSize)).ToList();

                int count = MaterialPriceRepository.Instance.CountPrice(MAT_NO, DATE_FROM, DATE_TO, VENDOR_CD, PRICE_STATUS, PRICE_TYPE,
                                                                SOURCE_TYPE, PRODUCTION_PURPOSE, PART_COLOR_SFX, PACKING_TYPE);

                ViewData["MaterialPrice"] = PRList;
                ViewData["RowData"] = count;
                ViewData["page"] = page;
                ViewData["FUNC"] = "SearchPrice";
                ViewData["CountData"] = CountIndex(count, pageSize, page);
            }
            return PartialView("_PartialPriceGrid");
        }

        public ActionResult getMaterial(string matno, string matdesc, int pageSize = 10, int page = 1)
        {
            BindMaterial(matno, matdesc, pageSize, page);
            return PartialView("_PartialPriceLookupMaterial");
        }

        public ActionResult getMaterialGrid(string matno, string matdesc, int pageSize = 10, int page = 1)
        {
            BindMaterial(matno, matdesc, pageSize, page);
            return PartialView("_PartialPriceLookupMaterialGrid");
        }

        private void BindMaterial(string matno, string matdesc, int pageSize = 10, int page = 1)
        {
            ViewData["Material"] = MaterialPriceRepository.Instance.GetDataMatNumber(matno, matdesc, (page * pageSize), (((page - 1) * pageSize) + 1)).ToList();
            ViewData["CountData"] = CountIndex(MaterialPriceRepository.Instance.CountMatno(matno, matdesc), pageSize, page);
            ViewData["FUNC"] = "getMaterialGrid";
        }

        public string SavePrice(string PRICE_TYPE, string MAT_NO, string MAT_DESC, string VENDOR_CD, string PRODUCTION_PURPOSE, string CURR_CD,
                                double PRICE_AMT, string VALID_DT_FROM, string PART_COLOR_SFX = "X", string WARP_BUYER_CD = "X",
                                string SOURCE_TYPE = "1", string PRICE_STS = "F", string PACKING_TYPE = "0")
        {
            string result = MaterialPriceRepository.Instance.validateSave(PRICE_TYPE, MAT_NO, MAT_DESC, VENDOR_CD, PRODUCTION_PURPOSE, CURR_CD, PRICE_AMT, VALID_DT_FROM,
                                                                  PART_COLOR_SFX, WARP_BUYER_CD, SOURCE_TYPE, PRICE_STS, PACKING_TYPE);
            
            string[] msg = result.Split('|');
            string USER_ID = this.GetCurrentUsername();
            if(msg[0] != "ERR")
            {
                result = MaterialPriceRepository.Instance.processingSave(PRICE_TYPE, MAT_NO, MAT_DESC, VENDOR_CD, PRODUCTION_PURPOSE, CURR_CD, PRICE_AMT, VALID_DT_FROM,
                                                                 PART_COLOR_SFX, WARP_BUYER_CD, SOURCE_TYPE, PRICE_STS, PACKING_TYPE, USER_ID);
            }
            
            return result;
        }

        public string DeletePrice(string PRICE_TYPE, string MAT_NO, string VENDOR_CD, string PRODUCTION_PURPOSE, string VALID_DT_FROM,
                                  string PART_COLOR_SFX, string WARP_BUYER_CD, string SOURCE_TYPE, string PACKING_TYPE)
        {
            string USER_ID = this.GetCurrentUsername();
            string result = MaterialPriceRepository.Instance.DeletePrice(PRICE_TYPE, MAT_NO, VENDOR_CD, PRODUCTION_PURPOSE, VALID_DT_FROM,
                                                                PART_COLOR_SFX, WARP_BUYER_CD, SOURCE_TYPE, PACKING_TYPE, USER_ID);
            return result;
        }

        #region LOOKUP
        [HttpPost]
        public ActionResult OpenDraftVendorLookup(LookupSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new LookupViewModel<GPS.Models.Common.NameValueItem>();
                viewModel.Title = "Vendor";
                viewModel.DataList = VendorRepository.Instance.GetVendorLookupSearchList(searchViewModel);
                viewModel.GridPaging = MaterialPriceRepository.Instance.GetVendorLookupSearchListPaging(searchViewModel, "draftvendor");

                return PartialView(LookupPage.GenericLookup, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult SearchDraftVendorLookup(LookupSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new LookupViewModel<GPS.Models.Common.NameValueItem>();
                viewModel.DataList = VendorRepository.Instance.GetVendorLookupSearchList(searchViewModel);
                viewModel.GridPaging = MaterialPriceRepository.Instance.GetVendorLookupSearchListPaging(searchViewModel, "draftvendor");

                return PartialView(LookupPage.GenericLookupGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult OpenItemVendorLookup(LookupSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new LookupViewModel<GPS.Models.Common.NameValueItem>();
                viewModel.Title = "Vendor";
                viewModel.DataList = VendorRepository.Instance.GetVendorLookupSearchList(searchViewModel);
                viewModel.GridPaging = MaterialPriceRepository.Instance.GetVendorLookupSearchListPaging(searchViewModel, "itemvendor");

                return PartialView(LookupPage.GenericLookup, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        [HttpPost]
        public ActionResult SearchItemVendorLookup(LookupSearchViewModel searchViewModel)
        {
            try
            {
                var viewModel = new LookupViewModel<GPS.Models.Common.NameValueItem>();
                viewModel.DataList = VendorRepository.Instance.GetVendorLookupSearchList(searchViewModel);
                viewModel.GridPaging = MaterialPriceRepository.Instance.GetVendorLookupSearchListPaging(searchViewModel, "itemvendor");

                return PartialView(LookupPage.GenericLookupGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
        #endregion

        #region UPLOAD/DOWNLOAD
        public void DownloadTemplate(string type)
        {
            string path = SystemRepository.Instance.GetSystemValue("UPLOAD_TEMPLATE_PATH");
            string filename = SystemRepository.Instance.GetSingleData(FunctionId.TemplatePrice, type).Value;

            CommonController.DownloadTemplate(this, path + filename);
        }

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
                ProcessId = procidrepo.GetNewProcessId(ModuleId.MasterData, FunctionId.MaterialPrice, "Material Price Upload");
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

            return PartialView("_PartialUploadPricePopup");
        }

        public String GetDocumentTempPath()
        {
            String downloadBasePathSystemValue = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
            String tempPathSystemValue = SystemRepository.Instance.GetSystemValue("PRICE_UPLOAD_TEMP_PATH");
            return Path.GetFullPath(downloadBasePathSystemValue + "\\" + tempPathSystemValue);
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

                string filepath = dirpath + "PRICE_" + DateTime.Now.ToString("ddMMyyyyHHmmssffff") + Path.GetExtension(file.FileName);
                file.SaveAs(filepath);

                message = "SUCCESS|" + Path.GetFileName(filepath);
            }
            catch (Exception ex)
            {
                message = "ERR|" + ex.Message;
            }

            return message;
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

        public void CancelUpload(string PROCESS_ID)
        {
            string dirpath = GetDocumentTempPath() + PROCESS_ID + "\\";
            Directory.Delete(dirpath, true);
        }

        public string SaveUploadData(string PROCESS_ID, string type)
        {
            string message = "";

            try
            {
                string dirpath = GetDocumentTempPath() + PROCESS_ID + "\\";
                string[] files = Directory.GetFiles(dirpath);

                foreach (string filename in files)
                {
                    ValidateandSave(filename, type);
                    message = "SUCCESS|" + filename;
                }
            }
            catch (Exception ex)
            {
                message = "ERR|" + ex.Message;
            }

            return message;
        }

        public Boolean ValidDate(string date, out DateTime dt)
        {
            dt = DateTime.Now;

            if (!date.Trim().Contains('.'))
                return false;

            string datetemp = date.Trim().Substring(3, 2) + "/" + date.Trim().Substring(0, 2) + "/" + date.Trim().Substring(6, 4);
            if (!DateTime.TryParse(datetemp, out dt))
                return false;
            else
                return true;
        }

        public void ValidateandSave(string filename, string type) 
        {
            string message = "";
            MaterialPrice datarow;
            
            FileStream fs = new FileStream(filename, FileMode.OpenOrCreate, FileAccess.ReadWrite);

            HSSFWorkbook wb = new HSSFWorkbook(fs);
            if (wb.GetSheetAt(0).SheetName != (type == "Draft" ? "DraftPrice" : "MasterPrice"))
                throw new Exception("Please use right template.");

            ISheet sheet = type == "Draft" ? wb.GetSheet("DraftPrice") : wb.GetSheet("MasterPrice");

            for (int i = 1; i <= sheet.LastRowNum; i++)
            {
                message = "";

                try
                {
                    #region Get Data
                    datarow = new MaterialPrice();

                    if (type == "Draft")
                    {
                        datarow.MaterialNo = sheet.GetRow(i).GetCell(0) == null ? "" : sheet.GetRow(i).GetCell(0).ToString().Trim();
                        datarow.VendorCode = sheet.GetRow(i).GetCell(1) == null ? "" : sheet.GetRow(i).GetCell(1).ToString().Trim();
                        datarow.ProdPurpose = sheet.GetRow(i).GetCell(2) == null ? "" : sheet.GetRow(i).GetCell(2).ToString().Trim();
                        datarow.WarpBuyerCode = sheet.GetRow(i).GetCell(3) == null ? "" : sheet.GetRow(i).GetCell(3).ToString().Trim();
                        datarow.SourceType = sheet.GetRow(i).GetCell(4) == null ? "" : sheet.GetRow(i).GetCell(4).ToString().Trim();
                        datarow.PartColorSfx = sheet.GetRow(i).GetCell(5) == null ? "" : sheet.GetRow(i).GetCell(5).ToString().Trim();
                        datarow.PackingType = sheet.GetRow(i).GetCell(6) == null ? "" : sheet.GetRow(i).GetCell(6).ToString().Trim();
                        datarow.CurrCode = sheet.GetRow(i).GetCell(7) == null ? "" : sheet.GetRow(i).GetCell(7).ToString().Trim();
                        datarow.PriceStatus = sheet.GetRow(i).GetCell(10) == null ? "" : sheet.GetRow(i).GetCell(10).ToString().Trim();

                        message = message + datarow.MaterialNo == "" ? "Material No should not be empty\n" : "";
                        message = message + datarow.VendorCode == "" ? "VendorCode should not be empty\n" : "";
                        message = message + datarow.ProdPurpose == "" ? "Production Purpose should not be empty\n" : "";
                        message = message + datarow.CurrCode == "" ? "Currency should not be empty\n" : "";

                        if ((sheet.GetRow(i).GetCell(8) == null ? "" : sheet.GetRow(i).GetCell(8).ToString().Trim()) == "")
                            message = message + "Amount should not be empty";
                        else
                        {
                            Decimal tempAmt;
                            if (Decimal.TryParse(sheet.GetRow(i).GetCell(8) == null ? "0" : sheet.GetRow(i).GetCell(8).ToString(), out tempAmt))
                                datarow.Amount = tempAmt;
                            else
                                message = message + "Incorrect amount's decimal format\n";
                        }

                        if ((sheet.GetRow(i).GetCell(9) == null ? "" : sheet.GetRow(i).GetCell(9).ToString().Trim()) == "")
                            message = message + "Valid From should not be empty";
                        else
                        {
                            DateTime tempDt;
                            if (ValidDate(sheet.GetRow(i).GetCell(9) == null ? "" : sheet.GetRow(i).GetCell(9).ToString(), out tempDt))
                                datarow.ValidDateFromStr = sheet.GetRow(i).GetCell(9).ToString().Trim().Substring(3, 2) + "-" + sheet.GetRow(i).GetCell(9).ToString().Trim().Substring(0, 2) + "-" + sheet.GetRow(i).GetCell(9).ToString().Trim().Substring(6, 4);
                            else
                                message = message + "Valid From is not in Correct Format. Valid Format : dd.MM.yyyy\n";
                        }

                    }
                    else /** MASTER PRICE **/ 
                    {
                        datarow.MaterialNo = sheet.GetRow(i).GetCell(0) == null ? "" : sheet.GetRow(i).GetCell(0).ToString();
                        datarow.VendorCode = sheet.GetRow(i).GetCell(1) == null ? "" : sheet.GetRow(i).GetCell(1).ToString();
                        datarow.ProdPurpose = sheet.GetRow(i).GetCell(2) == null ? "" : sheet.GetRow(i).GetCell(2).ToString();
                        datarow.CurrCode = sheet.GetRow(i).GetCell(3) == null ? "" : sheet.GetRow(i).GetCell(3).ToString();

                        message = message + datarow.MaterialNo == "" ? "Material No should not be empty\n" : "";
                        message = message + datarow.VendorCode == "" ? "VendorCode should not be empty\n" : "";
                        message = message + datarow.ProdPurpose == "" ? "Production Purpose should not be empty\n" : "";
                        message = message + datarow.CurrCode == "" ? "Currency should not be empty\n" : "";

                        if ((sheet.GetRow(i).GetCell(4) == null ? "" : sheet.GetRow(i).GetCell(4).ToString().Trim()) == "")
                            message = message + "Amount should not be empty";
                        else
                        {
                            Decimal tempAmt;
                            if (Decimal.TryParse(sheet.GetRow(i).GetCell(4) == null ? "0" : sheet.GetRow(i).GetCell(4).ToString(), out tempAmt))
                                datarow.Amount = tempAmt;
                            else
                                message = message + "Incorrect amount's decimal format\n";
                        }

                        if ((sheet.GetRow(i).GetCell(5) == null ? "" : sheet.GetRow(i).GetCell(5).ToString().Trim()) == "")
                            message = message + "Valid From should not be empty";
                        else
                        {
                            DateTime tempDt;
                            if (ValidDate(sheet.GetRow(i).GetCell(5) == null ? "" : sheet.GetRow(i).GetCell(5).ToString(), out tempDt))
                                datarow.ValidDateFromStr = sheet.GetRow(i).GetCell(5).ToString().Trim().Substring(3, 2) + "-" + sheet.GetRow(i).GetCell(5).ToString().Trim().Substring(0, 2) + "-" + sheet.GetRow(i).GetCell(5).ToString().Trim().Substring(6, 4);
                            else
                                message = message + "Valid From is not in Correct Format. Valid Format : dd.MM.yyyy\n";
                        }

                    }
                    #endregion

                    #region Save Data
                    if(message == "")
                        message = MaterialPriceRepository.Instance.SaveUploadData(type, datarow, this.GetCurrentUsername());
                    #endregion
                }
                catch (Exception ex)
                {
                    message = message + ex.Message + "\n";
                }
                finally 
                {
                    int colresult = type == "Draft" ? 11 : 6;
                    if (sheet.GetRow(i).GetCell(colresult) == null)
                        sheet.GetRow(i).CreateCell(colresult);

                    if (message.Substring(message.Length - 2, 2) == "\n" || message.Substring(message.Length - 2, 2) == "\\n")
                        message = message.Substring(0, message.Length - 2);

                    sheet.GetRow(i).GetCell(colresult).SetCellValue(message);
                    sheet.GetRow(i).GetCell(colresult).CellStyle.WrapText = true;

                    using (FileStream tfile = new FileStream(filename, FileMode.Open, FileAccess.Write))
                    {
                        wb.Write(tfile);
                        tfile.Close();
                    }
                }
            }
        }

        public FileResult DownloadUploadedResult(string path)
        {
            try
            {
                String mimeType = "application/vnd.ms-excel";
                Byte[] result = FileManager.ReadFile(path.Substring(0, path.IndexOf(Path.GetFileName(path))), Path.GetFileName(path));
                System.IO.File.Delete(path);
                return File(result, mimeType, Path.GetFileName(path));
            }
            catch (Exception ex)
            {
                var errorFile = PdfFileCreator.GenerateErrorInfoTextFile(ex);
                return File(errorFile.FileByteArray, errorFile.MimeType, errorFile.Filename);
            }
        }
        #endregion
    }
}
