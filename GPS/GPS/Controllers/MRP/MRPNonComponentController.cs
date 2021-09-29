using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using GPS.Models.Common;
using GPS.CommonFunc;
using GPS.Models.MRP;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.MRP
{
    public class MRPNonComponentController : PageController
    {
        ProcessIdRepository processIdRepo = new ProcessIdRepository();
        string ProcessId = "";
        string USER_ID = "";

        protected override void Startup()
        {            
            Settings.Title = "Material Resource Planning : Non Component Part List";
            ViewData["ListProcUsage"] = MRPNonComponentRepository.Instance.ListProcUsage();
            ViewData["ListHeaderType"] = MRPNonComponentRepository.Instance.ListHeaderType();
            ViewData["ListPlantCode"] = MRPNonComponentRepository.Instance.ListPlantCode();
        }

        private void Calldata(int Display, int Page, string ProcUsage, string HeaderType, string HeaderCd, string MatNo, string ValidDt, string Model, string Engine, string Trans, string DE, string ProdSfx, string Color)
        {
            Paging pg = new Paging(MRPNonComponentRepository.Instance.CountData(ProcUsage, HeaderType, HeaderCd, MatNo, ValidDt, Model, Engine, Trans, DE, ProdSfx, Color), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["ListNonComponent"] = MRPNonComponentRepository.Instance.GetListData(ProcUsage, HeaderType, HeaderCd, MatNo, ValidDt,  Model,  Engine,  Trans,  DE,  ProdSfx,  Color,pg.StartData, pg.EndData);
        }       

        public ActionResult IsFlagAddEditCopy(string flag)
        {
            ViewData["edit"] = flag;
            ViewData["ListProcUsage"] = MRPNonComponentRepository.Instance.ListProcUsage();
            ViewData["ListHeaderType"] = MRPNonComponentRepository.Instance.ListHeaderType();
            ViewData["ListPlantCode"] = MRPNonComponentRepository.Instance.ListPlantCode();

            return PartialView("_AddEditPopUp");
        }

        public string checkMaterial(string MatNo)
        {
            string message = "";
            message = MRPNonComponentRepository.Instance.checkMaterial(MatNo);
            return message;
        }

        public ActionResult GetSingleData(string ProcUsage, string HeaderType, string HeaderCd, string Model, string MatNo, string ValidDt)
        {
            return Json(MRPNonComponentRepository.Instance.GetSingleData(ProcUsage, HeaderType, HeaderCd, MatNo, Model, ValidDt));
        }

        public string GetListHeaderCode(string HeaderType)
        {
            string result = MRPNonComponentRepository.Instance.GetListHeaderCode(HeaderType);
            return result;
        }

        public string GetListStorageLoc(string PlantCd)
        {
            string result = MRPNonComponentRepository.Instance.GetListStorageLoc(PlantCd);
            return result;
        }
       
        [HttpPost]
        public ActionResult SearchData(int Display, int Page, string USER_NAME, string ProcUsage, string HeaderType, string HeaderCd, string MatNo, string ValidDt, string Model, string Engine, string Trans, string DE, string ProdSfx, string Color)
        {
            Calldata(Display, Page, ProcUsage, HeaderType, HeaderCd, MatNo, ValidDt,  Model,  Engine,  Trans,  DE,  ProdSfx,  Color);

            ViewData["USER_NAME"] = USER_NAME;
            if (checkMaterial(MatNo)=="0")
            {

                return PartialView("_Grid");
            }
            else
            {
                return Json("err" + "+" , JsonRequestBehavior.AllowGet);
            }
        }

        public ContentResult SearchLookup(int Display, int Page, string MatNo)
        {     
            List<MRPNonComponent> selectMatNo = MRPNonComponentRepository.Instance.GetListDataMatNo(MatNo, (((Page - 1) * Display) + 1), (Page * Display)).ToList();

            var jsonserializer = new JavaScriptSerializer();
            var json = jsonserializer.Serialize(selectMatNo);

            return Content(json);
        }      

        //paging popup
        public ContentResult LookupPaging(string MatNo, int pageSize)
        {
            int count = 0;
            count = MRPNonComponentRepository.Instance.CountDataMatNo(MatNo);

            PagingLookup PG = new PagingLookup();
            List<int> index = new List<int>();

            PG.Length = count;
            PG.CountData = count;

            Double Total = Math.Ceiling((Double)count / (Double)pageSize);
            for (int i = 1; i <= Total; i++)
            {
                index.Add(i);
            }
            PG.IndexList = index;

            var jsonserializer = new JavaScriptSerializer();
            var json = jsonserializer.Serialize(PG);
            return Content(json);
        }

        public ActionResult SaveData(string flag,MRPNonComponent data)
        {
            string message = "";

            message = MRPNonComponentRepository.Instance.SaveData(flag, data);

            return new JsonResult
            {
                Data = new
                {
                    message = message                    
                }
            };
        }

        public ActionResult DeleteData(string key,string ProcUsage, string HeaderType, string HeaderCd, string MatNo, string ValidDt)
        {
            string message = "";
            try
            {
                message = MRPNonComponentRepository.Instance.DeleteData(key,ProcUsage, HeaderType, HeaderCd, MatNo, ValidDt);
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
                return Json(message, JsonRequestBehavior.AllowGet);
            }

            return Json(message, JsonRequestBehavior.AllowGet);
        }

        public ActionResult ValidateDownloadData(string ProcUsage, string HeaderType, string HeaderCd, string MatNo, string ValidDt)
        {
            int count = 0;

            count = MRPNonComponentRepository.Instance.CountData(ProcUsage, HeaderType, HeaderCd, MatNo, ValidDt, null, null, null, null, null, null);

            return Json(count, JsonRequestBehavior.AllowGet);
        }

        public ActionResult DownloadData2(object sender, EventArgs e, string ProcUsage, string HeaderType, string HeaderCd, string MatNo, string ValidDt)
        {
            var data = MRPNonComponentRepository.Instance.GetDownloadData(ProcUsage, HeaderType, HeaderCd, MatNo, ValidDt);

            string filename = "";
            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/NonComponentPartList.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
            {
                FileStream ftmp = new FileStream(filesTmp, FileMode.Open, FileAccess.Read);

                HSSFWorkbook workbook = new HSSFWorkbook(ftmp, true);

                ICellStyle styleContent = workbook.CreateCellStyle();
                styleContent.VerticalAlignment = VerticalAlignment.TOP;
                styleContent.BorderLeft = BorderStyle.THIN;
                styleContent.BorderRight = BorderStyle.THIN;
                styleContent.BorderBottom = BorderStyle.THIN;
                styleContent.Alignment = HorizontalAlignment.CENTER;

                ICellStyle styleContent2 = workbook.CreateCellStyle();
                styleContent2.VerticalAlignment = VerticalAlignment.TOP;
                styleContent2.BorderLeft = BorderStyle.THIN;
                styleContent2.BorderRight = BorderStyle.THIN;
                styleContent2.BorderBottom = BorderStyle.THIN;
                styleContent2.Alignment = HorizontalAlignment.RIGHT;

                ICellStyle styleContent3 = workbook.CreateCellStyle();
                styleContent3.VerticalAlignment = VerticalAlignment.TOP;
                styleContent3.BorderLeft = BorderStyle.THIN;
                styleContent3.BorderRight = BorderStyle.THIN;
                styleContent3.BorderBottom = BorderStyle.THIN;
                styleContent3.Alignment = HorizontalAlignment.LEFT;

                ISheet sheet = workbook.GetSheet("Sheet1");
                string date = DateTime.Now.ToString("yyyyMMddhhmmss");
                filename = "MRP-NonComponentPartList_" + date + ".xls";

                string dateNow = DateTime.Now.ToString("dd-MM-yyyy");
                sheet.GetRow(2).GetCell(2).SetCellValue(this.GetCurrentUsername());
                sheet.GetRow(3).GetCell(2).SetCellValue(dateNow);               

                int row = 7;
                IRow Hrow;
                foreach (var item in data)
                {
                    Hrow = sheet.CreateRow(row);

                    Hrow.CreateCell(1).SetCellValue(item.PROC_USAGE_CD);
                    Hrow.CreateCell(2).SetCellValue(item.GENTANI_HEADER_TYPE);
                    Hrow.CreateCell(3).SetCellValue(item.GENTANI_HEADER_CD);
                    Hrow.CreateCell(4).SetCellValue(item.MAT_NO);
                    Hrow.CreateCell(5).SetCellValue(item.USAGE_QTY);
                    Hrow.CreateCell(6).SetCellValue(item.PLANT_CD);
                    Hrow.CreateCell(7).SetCellValue(item.STORAGE_LOCATION);
                    Hrow.CreateCell(8).SetCellValue(item.VALID_DT_FR);
                    Hrow.CreateCell(9).SetCellValue(item.VALID_DT_TO);
                    Hrow.CreateCell(10).SetCellValue(item.CREATED_BY);
                    Hrow.CreateCell(11).SetCellValue(item.CREATED_DT); 
                    Hrow.CreateCell(12).SetCellValue(item.CHANGED_BY); 
                    Hrow.CreateCell(13).SetCellValue(item.CHANGED_DT);
                  
                    Hrow.GetCell(1).CellStyle = styleContent;
                    Hrow.GetCell(2).CellStyle = styleContent;
                    Hrow.GetCell(3).CellStyle = styleContent;
                    Hrow.GetCell(4).CellStyle = styleContent3;
                    Hrow.GetCell(5).CellStyle = styleContent2;
                    Hrow.GetCell(6).CellStyle = styleContent;
                    Hrow.GetCell(7).CellStyle = styleContent;
                    Hrow.GetCell(8).CellStyle = styleContent;
                    Hrow.GetCell(9).CellStyle = styleContent;
                    Hrow.GetCell(10).CellStyle = styleContent;
                    Hrow.GetCell(11).CellStyle = styleContent;
                    Hrow.GetCell(12).CellStyle = styleContent;
                    Hrow.GetCell(13).CellStyle = styleContent;                  

                    row++;
                }

                MemoryStream ms = new MemoryStream();
                workbook.Write(ms);
                ftmp.Close();
                Response.BinaryWrite(ms.ToArray());
                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", filename));

            }

            ViewData["ListProcUsage"] = MRPNonComponentRepository.Instance.ListProcUsage();
            ViewData["ListHeaderType"] = MRPNonComponentRepository.Instance.ListHeaderType();
            ViewData["ListPlantCode"] = MRPNonComponentRepository.Instance.ListPlantCode();
            Calldata(10, 1, ProcUsage, HeaderType, HeaderCd, MatNo, ValidDt,null,null,null,null,null,null);

            return PartialView("_Grid");
        }

        public ActionResult DownloadData(object sender, EventArgs e, string ProcUsage, string HeaderType, string HeaderCd, string MatNo, string ValidDt)
        {
            var data = MRPNonComponentRepository.Instance.GetDownloadData(ProcUsage, HeaderType, HeaderCd, MatNo, ValidDt);

            string filename = "";
            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/NonComponentPartList.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
            {
                FileStream ftmp = new FileStream(filesTmp, FileMode.Open, FileAccess.Read);

                HSSFWorkbook workbook = new HSSFWorkbook(ftmp, true);              

                ISheet sheet = workbook.GetSheet("Sheet1");
                string date = DateTime.Now.ToString("yyyyMMddhhmmss");
                filename = "MRP-NonComponentPartList_" + date + ".xls";

                int row = 1;
                IRow Hrow;
                foreach (var item in data)
                {
                    Hrow = sheet.CreateRow(row);

                    Hrow.CreateCell(0).SetCellValue(item.PROC_USAGE_CD);
                    Hrow.CreateCell(1).SetCellValue(item.GENTANI_HEADER_TYPE);
                    Hrow.CreateCell(2).SetCellValue(item.GENTANI_HEADER_CD);
                    Hrow.CreateCell(3).SetCellValue(item.MAT_NO);
                    Hrow.CreateCell(4).SetCellValue(item.USAGE_QTY);
                    Hrow.CreateCell(5).SetCellValue(item.PLANT_CD);
                    Hrow.CreateCell(6).SetCellValue(item.STORAGE_LOCATION);
                    Hrow.CreateCell(7).SetCellValue(item.VALID_DT_FR);
                    Hrow.CreateCell(8).SetCellValue(item.VALID_DT_TO);
                    Hrow.CreateCell(9).SetCellValue(item.CREATED_BY);
                    Hrow.CreateCell(10).SetCellValue(item.CREATED_DT);
                    Hrow.CreateCell(11).SetCellValue(item.CHANGED_BY);
                    Hrow.CreateCell(12).SetCellValue(item.CHANGED_DT);                   

                    row++;
                }

                MemoryStream ms = new MemoryStream();
                workbook.Write(ms);
                ftmp.Close();
                Response.BinaryWrite(ms.ToArray());
                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", filename));

            }

            ViewData["ListProcUsage"] = MRPNonComponentRepository.Instance.ListProcUsage();
            ViewData["ListHeaderType"] = MRPNonComponentRepository.Instance.ListHeaderType();
            ViewData["ListPlantCode"] = MRPNonComponentRepository.Instance.ListPlantCode();
            Calldata(10, 1, ProcUsage, HeaderType, HeaderCd, MatNo, ValidDt,null,null,null,null,null,null);

            return PartialView("_Grid");
        }

        private byte[] StreamFile(string filename)
        {
            FileStream fs = new FileStream(filename, FileMode.Open, FileAccess.Read);
            byte[] ImageData = new byte[fs.Length];

            fs.Read(ImageData, 0, System.Convert.ToInt32(fs.Length));

            fs.Close();

            return ImageData;
        }

        public FileContentResult DownloadTemplate()
        {
            string filepath = Path.Combine(Server.MapPath("~/Content/Download/Template/MRP_NON_COMPONENT.xls"));
            byte[] docBytes = StreamFile(filepath);

            return File(docBytes, "application/vmd.ms-excel", "MRP_NON_COMPONENT.xls");
        }

        public ActionResult CekTemplate()
        {
            string cektemplate = "";

            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/Template/MRP_NON_COMPONENT.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
                cektemplate = "True";
            else
                cektemplate = "False";

            return Json(cektemplate, JsonRequestBehavior.AllowGet);
        }

        [HttpPost]
        public ActionResult UploadFile(string UserName)
        {
            MRPNonComponent data = new MRPNonComponent();
            string resultFilePath = "";
            string savefile = "";
            string message = "";

            ProcessId = "0";// processIdRepo.GetNewProcessId();
            USER_ID = "SYSTEM";
            string ModuleID = "4";
            string FunctionID = "406001";
            string Status = "0";

            try
            {
                #region                
                IDBContext db = DatabaseManager.Instance.GetContext();

                for (int i = 0; i < Request.Files.Count; i++)
                {
                    var file = Request.Files[i];
                    var filename = Path.GetFileName(file.FileName);
                    savefile = Path.Combine(Server.MapPath("~/Content/UploadFile"), filename);
                    resultFilePath = Path.Combine("~/Content/UploadFile", filename);
                    file.SaveAs(Server.MapPath(resultFilePath));
                }

                // open excel
                FileStream fs = new FileStream(Server.MapPath(resultFilePath), FileMode.OpenOrCreate, FileAccess.ReadWrite);
                HSSFWorkbook wb = new HSSFWorkbook(fs);
                ISheet sheet = wb.GetSheet("Sheet1");
                
                int row = 1;
                int LINE = 2;
                MRPNonComponentRepository.Instance.DELETE_TB_T();
                for (int i = 0; i < sheet.LastRowNum; i++)
                {                                      
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(0).ToString()))
                            data.PROC_USAGE_CD = sheet.GetRow(row).GetCell(0).ToString();
                        else
                            data.PROC_USAGE_CD = "";
                    }
                    catch
                    {
                        data.PROC_USAGE_CD = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(1).ToString()))
                            data.GENTANI_HEADER_TYPE = sheet.GetRow(row).GetCell(1).ToString();
                        else
                            data.GENTANI_HEADER_TYPE = "";
                    }
                    catch
                    {
                        data.GENTANI_HEADER_TYPE = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(2).ToString()))
                            data.GENTANI_HEADER_CD = sheet.GetRow(row).GetCell(2).ToString();
                        else
                            data.GENTANI_HEADER_CD = "";
                    }
                    catch
                    {
                        data.GENTANI_HEADER_CD = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(3).ToString()))
                            data.MAT_NO = sheet.GetRow(row).GetCell(3).ToString();
                        else
                            data.MAT_NO = "";
                    }
                    catch
                    {
                        data.MAT_NO = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(4).ToString()))
                            data.USAGE_QTY_STRING = sheet.GetRow(row).GetCell(4).ToString();
                        else
                            data.USAGE_QTY_STRING = "";
                    }
                    catch
                    {
                        data.USAGE_QTY_STRING = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(5).ToString()))
                            data.UOM = sheet.GetRow(row).GetCell(5).ToString();
                        else
                            data.UOM = "";
                    }
                    catch
                    {
                        data.UOM = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(6).ToString()))
                            data.PLANT_CD = sheet.GetRow(row).GetCell(6).ToString();
                        else
                            data.PLANT_CD = "";
                    }
                    catch
                    {
                        data.PLANT_CD = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(7).ToString()))
                            data.STORAGE_LOCATION = sheet.GetRow(row).GetCell(7).ToString();
                        else
                            data.STORAGE_LOCATION = "";
                    }
                    catch
                    {
                        data.STORAGE_LOCATION = "";
                    }

                    if (sheet.GetRow(row).GetCell(8) == null)
                        data.VALID_DT_FR = null;
                    else
                    {
                        data.VALID_DT_FR = sheet.GetRow(row).GetCell(8).ToString();
                        if (data.VALID_DT_FR == "")
                            data.VALID_DT_FR = null;
                    }

                    if (sheet.GetRow(row).GetCell(9) == null)
                        data.VALID_DT_TO = null;
                    else
                    {
                        data.VALID_DT_TO = sheet.GetRow(row).GetCell(9).ToString();
                        if (data.VALID_DT_TO == "")
                            data.VALID_DT_TO = null;
                    }

                    //LOG start
                    //MRPNonComponentRepository.Instance.Log_Header(Convert.ToInt64(ProcessId), ModuleID, FunctionID, Status, UserName);

                    MRPNonComponentRepository.Instance.INSERT_TB_T(row, LINE, data);
                    row++;
                    LINE++;
                }

                message = MRPNonComponentRepository.Instance.UploadToDatabase(UserName, Convert.ToInt64(ProcessId));

                if (System.IO.File.Exists(savefile))
                    System.IO.File.Delete(savefile);
          
                #endregion
            }
            catch (Exception e)
            {
                if (System.IO.File.Exists(savefile))
                    System.IO.File.Delete(savefile);

                message = e.Message.ToString();
                return Json(new { message = "Error|" + message }, JsonRequestBehavior.AllowGet);
            }

            return Json(new { message = message }, JsonRequestBehavior.AllowGet);
        }      
       
    }
}