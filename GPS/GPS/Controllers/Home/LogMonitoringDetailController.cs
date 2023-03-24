using System;
using System.Web.Mvc;
using GPS.Models.Common;
using GPS.Models.Home;
using GPS.CommonFunc;
using Toyota.Common.Web.Platform;
using System.Collections.Generic;
using System.IO;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;

namespace GPS.Controllers.Home
{
    public class LogMonitoringDetailController : PageController
    {
        protected override void Startup()
        {
            Int64 ProcessId = Convert.ToInt64(Request.Params["ProcessId"]);
            Settings.Title = "Log Monitoring Detail";
            ViewData["LogHeader"] = LogMonitoringDetailRepository.Instance.GetHeader(ProcessId.ToString());
        }

        private void Calldata(int Display, int Page, string ProcessId)
        {
            Paging pg = new Paging(LogMonitoringDetailRepository.Instance.CountData(ProcessId), Page, Display);
            ViewData["Paging"] = pg;
            ViewData["ListLogDetail"] = LogMonitoringDetailRepository.Instance.GetListData(ProcessId, pg.StartData, pg.EndData);
        }

        [HttpPost]
        public ActionResult SearchData(int Display, int Page, string ProcessId)
        {
            Calldata(Display, Page, ProcessId);
            return PartialView("_Grid");
        }

        public void DownloadData(object sender, EventArgs e, string ProcessId)
        {
            try
            {
                List<LogMonitoringDetail> data = LogMonitoringDetailRepository.Instance.GetDownloadData(ProcessId);

                string filename = "";
                string filesTmp = HttpContext.Request.MapPath("~/Content/Download/LogMonitoring.xls");
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
                    styleContent1.BorderTop = BorderStyle.THIN;
                    styleContent2.BorderLeft = BorderStyle.THIN;
                    styleContent2.BorderRight = BorderStyle.THIN;
                    styleContent2.BorderBottom = BorderStyle.THIN;
                    styleContent2.Alignment = HorizontalAlignment.LEFT;

                    ISheet sheet = workbook.GetSheet("LogMonitoring");
                    string date = DateTime.Now.ToString("yyyyMMddhhmmss");
                    filename = "LogMonitoring_"+ ProcessId + ".xls";

                    sheet.GetRow(2).GetCell(2).SetCellValue(this.GetCurrentUsername());
                    sheet.GetRow(3).GetCell(2).SetCellValue(DateTime.Now.ToString("dd.MM.yyyy"));
                    sheet.GetRow(4).GetCell(2).SetCellValue(ProcessId);

                    int row = 8;
                    string dt;
                    IRow Hrow;
                    foreach (var item in data)
                    {
                        Hrow = sheet.CreateRow(row);

                        Hrow.CreateCell(1).SetCellValue(item.SeqNo);
                        Hrow.CreateCell(2).SetCellValue(item.CreatedDt.ToString());
                        Hrow.CreateCell(3).SetCellValue(item.MessageType);
                        Hrow.CreateCell(4).SetCellValue(item.Location);
                        Hrow.CreateCell(5).SetCellValue(item.MessageContent);

                        Hrow.GetCell(1).CellStyle = styleContent1;
                        Hrow.GetCell(2).CellStyle = styleContent1;
                        Hrow.GetCell(3).CellStyle = styleContent1;
                        Hrow.GetCell(4).CellStyle = styleContent2;
                        Hrow.GetCell(5).CellStyle = styleContent2;

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
    }
}