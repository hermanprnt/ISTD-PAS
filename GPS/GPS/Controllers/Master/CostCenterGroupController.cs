using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Common;
using GPS.Models.Master;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using Toyota.Common.Web.Platform;
using System.IO;

namespace GPS.Controllers.Master
{
    public class CostCenterGroupController : PageController
    {
        protected override void Startup()
        {
            Settings.Title = "Cost Center Group Master";
            ViewData["CostCenterGroup"] = CostCenterGroupRepository.Instance.GetLookupData();
        }

        public List<Division> GetDivision()
        {
            return CostCenterGroupRepository.Instance.GetDivisionData().ToList();
        }

        private void Calldata(int Display, int Page, string CostGroup, string DivisionCd)
        {
            Paging pg = new Paging(CostCenterGroupRepository.Instance.CountData(CostGroup, DivisionCd), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["ListCostGroup"] = CostCenterGroupRepository.Instance.GetListData(CostGroup, DivisionCd, pg.StartData, pg.EndData);
        }

        [HttpPost]
        public ActionResult SearchData(int Display, int Page, string CostGroup, string DivisionCd)
        {
            Calldata(Display, Page, CostGroup, DivisionCd);
            return PartialView("_Grid");
        }

        public ActionResult SaveData(string flag, string CostGroup, string CostGroupDesc, string DivisionCd)
        {
            string message = "";

            message = CostCenterGroupRepository.Instance.SaveData(flag, CostGroup, CostGroupDesc, DivisionCd, this.GetCurrentUsername());

            return new JsonResult
            {
                Data = new
                {
                    message = message
                }
            };
        }

        public ActionResult DeleteData(string Key)
        {
            string message = "";

            try
            {
                message = CostCenterGroupRepository.Instance.DeleteData(Key);
            }
            catch (Exception e)
            {
                message = e.Message.ToString();
                return Json(message, JsonRequestBehavior.AllowGet);
            }

            return Json(message, JsonRequestBehavior.AllowGet);
        }

        public ActionResult IsFlagEditAdd(string flag, string Key)
        {
            ViewData["edit"] = flag;
            if (flag == "0" && String.IsNullOrEmpty(Key))
            {
                ViewData["CostGroupData"] = new CostCenterGroup();
            }
            else
            {
                string CostGroup = Key.Split(';')[0];
                string DivisionCd = Key.Split(';')[1];
                ViewData["CostGroupData"] = CostCenterGroupRepository.Instance.GetSelectedData(CostGroup, DivisionCd);
            }
            ViewData["LookupCostGroup"] = CostCenterGroupRepository.Instance.GetLookupData();
            ViewData["Division"] = GetDivision();

            return PartialView("_AddEditPopUp");
        }

        public void DownloadData(object sender, EventArgs e, string CostGroup, string DivisionCd)
        {
            try
            {
                List<CostCenterGroup> data = CostCenterGroupRepository.Instance.GetDownloadData(CostGroup, DivisionCd);

                string filename = "";
                string filesTmp = HttpContext.Request.MapPath("~/Content/Download/CostCenterGroupMaster.xls");
                FileInfo FI = new FileInfo(filesTmp);
                if (FI.Exists)
                {
                    FileStream ftmp = new FileStream(filesTmp, FileMode.Open, FileAccess.Read);

                    HSSFWorkbook workbook = new HSSFWorkbook(ftmp, true);                  

                    ISheet sheet = workbook.GetSheet("CostCenterGroupMaster");
                    string date = DateTime.Now.ToString("yyyyMMddhhmmss");
                    filename = "CostCenterGroup_" + date + ".xls";

                    int row = 1;
                    string dt;
                    IRow Hrow;
                    foreach (var item in data)
                    {
                        Hrow = sheet.CreateRow(row);

                        Hrow.CreateCell(0).SetCellValue(item.CostCenterGroupCd);
                        Hrow.CreateCell(1).SetCellValue(item.DivisionCd);
                        Hrow.CreateCell(2).SetCellValue(item.CostCenterGroupDesc);
                        Hrow.CreateCell(3).SetCellValue(item.CreatedBy);
                        Hrow.CreateCell(4).SetCellValue(item.CreatedDt.ToString("dd.MM.yyyy"));
                        Hrow.CreateCell(5).SetCellValue(item.ChangedBy);
                        dt = item.ChangedDt.ToString("dd.MM.yyyy") == "01.01.0001" ? "" : item.ChangedDt.ToString("dd.MM.yyyy");
                        Hrow.CreateCell(6).SetCellValue(dt);                        

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

        private string GetMimeType(string fileName)
        {
            string mimeType = "application/unknown";
            string ext = Path.GetExtension(fileName).ToLower();
            Microsoft.Win32.RegistryKey regKey = Microsoft.Win32.Registry.ClassesRoot.OpenSubKey(ext);
            if (regKey != null && regKey.GetValue("Content Type") != null)
                mimeType = regKey.GetValue("Content Type").ToString();
            return mimeType;
        }

        public void DownloadTemplate()
        {
            string filename = "COST_CENTER_GROUP.xls";
            string filepath = "../Content/Download/Template/COST_CENTER_GROUP.xls";

            Response.Clear();
            Response.ContentType = GetMimeType(filename);
            Response.AppendHeader("content-disposition", "attachment; filename=" + filename);
            Response.TransmitFile(filepath);
            Response.End();   
        }

        [HttpPost]
        public ActionResult UploadFile()
        {
            string resultFilePath = "";
            string savefile = "";
            string message = "";
            string ModuleId = "1";
            string FunctionId = "105002";
            string loc = "Upload Cost Center Group Master";
            Int64 ProcessId = CostCenterGroupRepository.Instance.GetProcessId("Upload Process Started", loc, "", "INF", ModuleId, FunctionId, 0, this.GetCurrentUsername()); ;

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
                CostCenterGroupRepository.Instance.InsertLog("Insert Data Into Temporary Table Started", loc, ProcessId, "", "INF", "", null, 0, this.GetCurrentUsername());
                int row = 1;
                for (int i = 0; i < sheet.LastRowNum; i++)
                {
                    if ((sheet.GetRow(row) != null) && ((sheet.GetRow(row).GetCell(1) != null) && (sheet.GetRow(row).GetCell(2) != null) && (sheet.GetRow(row).GetCell(3) != null)))
                    {
                        CostCenterGroup data = new CostCenterGroup();
                        data.CostCenterGroupCd = sheet.GetRow(row).GetCell(0).ToString();
                        data.DivisionCd = sheet.GetRow(row).GetCell(1).ToString();
                        data.CostCenterGroupDesc = sheet.GetRow(row).GetCell(2).ToString();
                        data.CreatedBy = this.GetCurrentUsername();
                        data.ProcessId = ProcessId;
                        data.Row = (row + 1).ToString();
                        data.ErrorFlag = "N";

                        CostCenterGroupRepository.Instance.InsertTemporary(data);

                        row++;
                    }
                    else break;
                }
                CostCenterGroupRepository.Instance.InsertLog("Insert Data Into Temporary Table Finished", loc, ProcessId, "", "INF", "", null, 0, this.GetCurrentUsername());

                loc = "Data Validation";
                CostCenterGroupRepository.Instance.UploadValidation(ProcessId, loc, this.GetCurrentUsername());

                loc = "Insert Data Into Master Table";
                int rowsuccess = CostCenterGroupRepository.Instance.SaveUploadData(ProcessId, loc, this.GetCurrentUsername());

                if (System.IO.File.Exists(savefile))
                    System.IO.File.Delete(savefile);

                CostCenterGroupRepository.Instance.DeleteTemporary(ProcessId);
                loc = "Upload Cost Center Group Master";
                CostCenterGroupRepository.Instance.InsertLog("Upload Process Finished", loc, ProcessId, "", "INF", "", null, 0, this.GetCurrentUsername());

                if (rowsuccess == (row - 1)) message = "Data Successfully Uploaded";
                else if (rowsuccess < (row - 1) && rowsuccess > 0) message = "War|Upload Finish with Error. Please view logging with Process Id " + ProcessId.ToString() + " for detail.";
                else message = "Error|Error occured when uploading. Please view logging with Process Id " + ProcessId.ToString() + " for detail.";

            }
            catch (Exception e)
            {
                if (System.IO.File.Exists(savefile))
                    System.IO.File.Delete(savefile);

                CostCenterGroupRepository.Instance.InsertLog(e.Message, loc, ProcessId, "", "ERR", "", null, 1, this.GetCurrentUsername());
                loc = "Upload Cost Center Group Master";
                CostCenterGroupRepository.Instance.InsertLog("Upload Process Finished", loc, ProcessId, "", "INF", "", null, 0, this.GetCurrentUsername());
                CostCenterGroupRepository.Instance.DeleteTemporary(ProcessId);

                message = e.Message.ToString();
                return Json(new { message = "Error|" + message }, JsonRequestBehavior.AllowGet);
            }

            return Json(new { message = message }, JsonRequestBehavior.AllowGet);
        }
    }
}