using System;
using System.IO;
using System.Web.Mvc;
using GPS.Models.Common;
using GPS.CommonFunc;
using GPS.Models.MRP;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.MRP
{
    public class MRPParentController : PageController
    {
        ProcessIdRepository processIdRepo = new ProcessIdRepository();
        string ProcessId = "";
        string USER_ID = "";

        protected override void Startup()
        {            
            Settings.Title = "Material Resource Planning : Parent";            
        }

        private void Calldata(int Display, int Page, string ParentCode, string ParentType)
        {
            Paging pg = new Paging(MRPParentRepository.Instance.CountData(ParentCode, ParentType), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["ListParent"] = MRPParentRepository.Instance.GetListData(ParentCode, ParentType, pg.StartData, pg.EndData);
        }       

        public ActionResult IsFlagAddEditCopy(string flag)
        {
            ViewData["edit"] = flag;                     

            return PartialView("_AddEditPopUp");
        }

        public ActionResult GetSingleData(string ParentCode, string ParentType)
        {
            return Json(MRPParentRepository.Instance.GetSingleData(ParentCode, ParentType));
        }                    
       
        [HttpPost]
        public ActionResult SearchData(int Display, int Page, string USER_NAME, string ParentCode, string ParentType)
        {
            Calldata(Display, Page, ParentCode, ParentType);

            ViewData["USER_NAME"] = USER_NAME;
           
            return PartialView("_Grid");
        }       

        public ActionResult SaveData(string flag, MRPParent data)
        {
            string message = "";

            message = MRPParentRepository.Instance.SaveData(flag, data);

            return new JsonResult
            {
                Data = new
                {
                    message = message                    
                }
            };
        }

        public ActionResult DeleteData(string key, string ParentCode, string ParentType)
        {
            string message = "";
            try
            {
                message = MRPParentRepository.Instance.DeleteData(key, ParentCode, ParentType);
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
                return Json(message, JsonRequestBehavior.AllowGet);
            }

            return Json(message, JsonRequestBehavior.AllowGet);
        }

        public ActionResult DownloadData2(object sender, EventArgs e, string ParentCode, string ParentType)
        {
            var data = MRPParentRepository.Instance.GetDownloadData(ParentCode, ParentType);

            string filename = "";
            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/Parent.xls");
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

                ISheet sheet = workbook.GetSheet("Sheet1");
                string date = DateTime.Now.ToString("yyyyMMddhhmmss");
                filename = "MRP-Parent_" + date + ".xls";

                string dateNow = DateTime.Now.ToString("dd-MM-yyyy");
                sheet.GetRow(2).GetCell(2).SetCellValue(this.GetCurrentUsername());
                sheet.GetRow(3).GetCell(2).SetCellValue(dateNow);               

                int row = 7;
                IRow Hrow;
                foreach (var item in data)
                {
                    Hrow = sheet.CreateRow(row);
                   
                    Hrow.CreateCell(1).SetCellValue(item.PARENT_CD);
                    Hrow.CreateCell(2).SetCellValue(item.PARENT_TYPE);                             
                    Hrow.CreateCell(3).SetCellValue(item.CREATED_BY);
                    Hrow.CreateCell(4).SetCellValue(item.CREATED_DT); 
                    Hrow.CreateCell(5).SetCellValue(item.CHANGED_BY); 
                    Hrow.CreateCell(6).SetCellValue(item.CHANGED_DT);
                  
                    Hrow.GetCell(1).CellStyle = styleContent;
                    Hrow.GetCell(2).CellStyle = styleContent;
                    Hrow.GetCell(3).CellStyle = styleContent;
                    Hrow.GetCell(4).CellStyle = styleContent;
                    Hrow.GetCell(5).CellStyle = styleContent;
                    Hrow.GetCell(6).CellStyle = styleContent;                                    
                   
                    row++;
                }

                MemoryStream ms = new MemoryStream();
                workbook.Write(ms);
                ftmp.Close();
                Response.BinaryWrite(ms.ToArray());
                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", filename));
            }

            Calldata(10, 1, ParentCode, ParentType);

            return PartialView("_Grid");
        }

        public ActionResult DownloadData(object sender, EventArgs e, string ParentCode, string ParentType)
        {
            var data = MRPParentRepository.Instance.GetDownloadData(ParentCode, ParentType);

            string filename = "";
            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/Parent.xls");
            FileInfo FI = new FileInfo(filesTmp);
            if (FI.Exists)
            {
                FileStream ftmp = new FileStream(filesTmp, FileMode.Open, FileAccess.Read);

                HSSFWorkbook workbook = new HSSFWorkbook(ftmp, true);

                ISheet sheet = workbook.GetSheet("Sheet1");
                string date = DateTime.Now.ToString("yyyyMMddhhmmss");
                filename = "MRP-Parent_" + date + ".xls";

                int row = 1;
                IRow Hrow;
                foreach (var item in data)
                {
                    Hrow = sheet.CreateRow(row);

                    Hrow.CreateCell(0).SetCellValue(item.PARENT_CD);
                    Hrow.CreateCell(1).SetCellValue(item.PARENT_TYPE);
                    Hrow.CreateCell(2).SetCellValue(item.CREATED_BY);
                    Hrow.CreateCell(3).SetCellValue(item.CREATED_DT);
                    Hrow.CreateCell(4).SetCellValue(item.CHANGED_BY);
                    Hrow.CreateCell(5).SetCellValue(item.CHANGED_DT);                   

                    row++;
                }

                MemoryStream ms = new MemoryStream();
                workbook.Write(ms);
                ftmp.Close();
                Response.BinaryWrite(ms.ToArray());
                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", filename));
            }

            Calldata(10, 1, ParentCode, ParentType);

            return PartialView("_Grid");
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
            string filepath = Path.Combine(Server.MapPath("~/Content/Download/Template/MRP_PARENT.xls"));
            byte[] docBytes = StreamFile(filepath);

            return File(docBytes, "application/vmd.ms-excel","MRP_PARENT.xls");
        }

        public ActionResult CekTemplate()
        {
            string cektemplate = "";

            string filesTmp = HttpContext.Request.MapPath("~/Content/Download/Template/MRP_PARENT.xls");
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
            MRPParent data = new MRPParent();
            string resultFilePath = "";
            string savefile = "";
            string message = "";

            ProcessId = "0"; //processIdRepo.GetNewProcessId();
            USER_ID = "SYSTEM";            
            string ModuleID = "4";
            string FunctionID = "406001";
            string Status = "0";

            //0 = start
            //1 = proses
            //2 = finish
            //3 = finish with error
            //4 = abnormal
            
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
                MRPParentRepository.Instance.DELETE_TB_T();
                for (int i = 0; i < sheet.LastRowNum; i++)
                {
                    
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(0).ToString()))
                            data.PARENT_CD = sheet.GetRow(row).GetCell(0).ToString();
                        else
                            data.PARENT_CD = "";
                    }
                    catch
                    {
                        data.PARENT_CD = "";
                    }
                    try
                    {
                        if (!string.IsNullOrEmpty(sheet.GetRow(row).GetCell(1).ToString()))
                            data.PARENT_TYPE = sheet.GetRow(row).GetCell(1).ToString();
                        else
                            data.PARENT_TYPE = "";
                    }
                    catch
                    {
                        data.PARENT_TYPE = "";
                    }
                    
                    MRPParentRepository.Instance.INSERT_TB_T(row, LINE, data);
                    row++;
                    LINE++;
                }

                //LOG start
                //MRPParentRepository.Instance.Log_Header(Convert.ToInt64(ProcessId), ModuleID, FunctionID, Status, UserName);

                message = MRPParentRepository.Instance.UploadToDatabase(UserName, Convert.ToInt64(ProcessId));

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