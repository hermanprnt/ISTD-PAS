using System;
using System.Collections.Generic;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Models.Master;
using Toyota.Common.Web.Platform;
using GPS.Models.PR.PRStatusMonitoring;
using GPS.Models.Common;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using System.IO;
using GPS.Models;
using System.Linq;

namespace GPS.Controllers.PR
{
    public class PRStatusMonitoringController : PageController
    {
        /** Controller Method **/
        
        public PRStatusMonitoringController()
        {
            Settings.Title = "PR Status Monitoring Screen";
        }

        protected override void Startup()
        {
            int divId = DivisionRepository.Instance.GetUserDivision(this.GetCurrentRegistrationNumber());
            TempData["DIVISION_ID"] = divId;

            var orderParams = PRStatusMonitoringRepository.Instance.GetFilterDelayStatus().ToList();
            var orderParam = orderParams.Where(x => x.Name.Length > 0).First();
            PRStatusMonitoringParam param = new PRStatusMonitoringParam() { DIVISION_ID = divId, ORDER_BY = orderParam.Value };

            var listData = PRStatusMonitoringRepository.Instance.GetDetailPR(param, 1, 25);

            var listGrid = new List<PRStatusMonitoring>();
            if(listData.Item2.Length>0 )
            {
                ViewData["Message"] = "Error : " + listData.Item2;
            }
            else
            {
                listGrid = listData.Item1;
            }

            var listCountData = PRStatusMonitoringRepository.Instance.CountDetailPR(param);
            var countItem = 0;
            if (listCountData.Item2.Length > 0)
            {
                ViewData["Message"] = "Error : " + listCountData.Item2;
            }
            else
            {
                countItem = listCountData.Item1;
            }

            var paging = new Tuple<Paging, string, string>(GeneratePaging(countItem, 25, 1), "SearchPRDetail", "0");

            var summaryData = PRStatusMonitoringRepository.Instance.GetSummaryData(param.DIVISION_ID);

            ViewData["SummaryData"] = summaryData;
            ViewData["GridData"] = listGrid;
            ViewData["PagingData"] = paging;
        }

        public ActionResult SearchData(PRStatusMonitoringParam param, int page = 1, int pageSize = 25)
        {
            try
            {
                var listData = PRStatusMonitoringRepository.Instance.GetDetailPR(param, page, pageSize);

                var listGrid = new List<PRStatusMonitoring>();
                if (listData.Item2.Length > 0)
                {
                    throw new Exception( listData.Item2);
                }
                else
                {
                    listGrid = listData.Item1;
                }

                var listCountData = PRStatusMonitoringRepository.Instance.CountDetailPR(param);
                var countItem = 0;
                if (listCountData.Item2.Length > 0)
                {
                    ViewData["Message"] = "Error : " + listCountData.Item2;
                }
                else
                {
                    countItem = listCountData.Item1;
                }

                var paging = new Tuple<Paging, string, string>(GeneratePaging(countItem, pageSize, page), "SearchPRDetail", "0");

                ViewData["GridData"] = listGrid;
                ViewData["PagingData"] = paging;
            }
            catch (Exception e)
            {
                ViewData["Message"] = "Error : " + e.Message;
            }

            return PartialView("_PartialStatusMonitoringGrid");
        }

        public static SelectList GetFilterDelayStatus()
        {
            return PRStatusMonitoringRepository.Instance
                .GetFilterDelayStatus()
                .AsSelectList(x => x.Name,
                    x => x.Value);
        }

        public void OnDownloadExcel(PRStatusMonitoringParam viewModel)
        {
            try
            {
                CommonDownload downloadEngine = CommonDownload.Instance;
                string FileName = string.Format("Download PR Status Monitoring_{0}.xls", DateTime.Now.ToString("yyyyMMdd"));
                var RowCounts = PRStatusMonitoringRepository.Instance.CountDetailPR(viewModel);

                string filePath = HttpContext.Request.MapPath(downloadEngine.GetServerFilePath("PRMonitoringTemplete.xls"));
                FileStream ftmp = new FileStream(filePath, FileMode.Open, FileAccess.Read);
                var workbook = new HSSFWorkbook(ftmp);
                var dataListPR = PRStatusMonitoringRepository.Instance.GetDetailPR(viewModel, 1, RowCounts.Item1);

                ISheet sheet; IRow Hrow; int row = 2;
                IFont font = downloadEngine.GenerateFontExcel(workbook);
                ICellStyle styleCenter = downloadEngine.GenerateStyleCenter(workbook, font);
                ICellStyle styleLeft = downloadEngine.GenerateStyleLeft(workbook, font);
                ICellStyle styleNormal = downloadEngine.GenerateStyleNormal(workbook, font);

                sheet = workbook.GetSheetAt(0);

                foreach (PRStatusMonitoring item in dataListPR.Item1)
                {
                    Hrow = sheet.CreateRow(row);
                    downloadEngine.WriteCellValue(Hrow, 0, styleCenter, item.NO);
                    downloadEngine.WriteCellValue(Hrow, 1, styleNormal, item.PR_NO);
                    downloadEngine.WriteCellValue(Hrow, 2, styleCenter, item.PR_ITEM_NO);
                    downloadEngine.WriteCellValue(Hrow, 3, styleNormal, item.MAT_DESC);
                    downloadEngine.WriteCellValue(Hrow, 4, styleNormal, item.WBS_NO);
                    downloadEngine.WriteCellValue(Hrow, 5, styleNormal, item.PR_STATUS_DESC);
                    downloadEngine.WriteCellValue(Hrow, 6, styleNormal, item.PR_CREATED_BY);
                    downloadEngine.WriteCellValue(Hrow, 7, styleCenter, item.PR_CREATED_DATE == DateTime.MinValue?"": string.Format("{0:yyyy-MM-dd}", item.PR_CREATED_DATE));
                    downloadEngine.WriteCellValue(Hrow, 8, styleCenter, item.i_SH_INTERVAL >= 0 ? (item.i_SH_DATE == DateTime.MinValue && item.i_SH_DELAY > 0) ? item.i_SH_DELAY.ToString() : (item.i_SH_DATE == DateTime.MinValue ? "" : string.Format("{0:yyyy-MM-dd}", item.i_SH_DATE)):"x");
                    downloadEngine.WriteCellValue(Hrow, 9, styleCenter, item.i_DPH_INTERVAL >= 0 ? (item.i_DPH_DATE == DateTime.MinValue && item.i_DPH_DELAY > 0) ? item.i_DPH_DELAY.ToString() : (item.i_DPH_DATE == DateTime.MinValue ? "" : string.Format("{0:yyyy-MM-dd}", item.i_DPH_DATE)) : "x");
                    downloadEngine.WriteCellValue(Hrow, 10, styleCenter, item.i_DH_INTERVAL >= 0 ? (item.i_DH_DATE == DateTime.MinValue && item.i_DH_DELAY > 0) ? item.i_DH_DELAY.ToString() : (item.i_DH_DATE == DateTime.MinValue ? "" : string.Format("{0:yyyy-MM-dd}", item.i_DH_DATE)) : "x");
                    downloadEngine.WriteCellValue(Hrow, 11, styleCenter, item.STAFF_INTERVAL >= 0 ? (item.STAFF_DATE == DateTime.MinValue && item.STAFF_DELAY > 0) ? item.STAFF_DELAY.ToString() : (item.STAFF_DATE == DateTime.MinValue ? "" : string.Format("{0:yyyy-MM-dd}", item.STAFF_DATE)) : "x");
                    downloadEngine.WriteCellValue(Hrow, 12, styleCenter, item.c_SH_INTERVAL >= 0 ? (item.c_SH_DATE == DateTime.MinValue && item.c_SH_DELAY > 0) ? item.c_SH_DELAY.ToString() : (item.c_SH_DATE == DateTime.MinValue ? "" : string.Format("{0:yyyy-MM-dd}", item.c_SH_DATE)) : "x");
                    downloadEngine.WriteCellValue(Hrow, 13, styleCenter, item.c_DPH_INTERVAL >= 0 ? (item.c_DPH_DATE == DateTime.MinValue && item.c_DPH_DELAY > 0) ? item.c_DPH_DELAY.ToString() : (item.c_DPH_DATE == DateTime.MinValue ? "" : string.Format("{0:yyyy-MM-dd}", item.c_DPH_DATE)) : "x");
                    downloadEngine.WriteCellValue(Hrow, 14, styleCenter, item.FINANCE_INTERVAL >= 0 ? (item.FINANCE_DATE == DateTime.MinValue && item.FINANCE_DELAY > 0) ? item.FINANCE_DELAY.ToString() : (item.FINANCE_DATE == DateTime.MinValue ? "" : string.Format("{0:yyyy-MM-dd}", item.FINANCE_DATE)) : "x");
                    downloadEngine.WriteCellValue(Hrow, 15, styleNormal, item.PO_NO);
                    downloadEngine.WriteCellValue(Hrow, 16, styleNormal, item.PO_STATUS_DESC);
                    downloadEngine.WriteCellValue(Hrow, 17, styleNormal, item.PO_CREATED_BY);
                    downloadEngine.WriteCellValue(Hrow, 18, styleCenter, item.PO_CREATED_DATE == DateTime.MinValue ? "" : string.Format("{0:yyyy-MM-dd}", item.PO_CREATED_DATE));
                    downloadEngine.WriteCellValue(Hrow, 19, styleCenter, item.PO_SH_INTERVAL >= 0?(item.PO_SH_DATE == DateTime.MinValue && item.PO_SH_DELAY > 0) ? item.PO_SH_DELAY.ToString() : (item.PO_SH_DATE == DateTime.MinValue ? "" : string.Format("{0:yyyy-MM-dd}", item.PO_SH_DATE)) : "x");
                    downloadEngine.WriteCellValue(Hrow, 20, styleCenter, item.PO_DPH_INTERVAL >= 0?(item.PO_DPH_DATE == DateTime.MinValue && item.PO_DPH_DELAY > 0) ? item.PO_DPH_DELAY.ToString() : (item.PO_DPH_DATE == DateTime.MinValue ? "" : string.Format("{0:yyyy-MM-dd}", item.PO_DPH_DATE)) : "x");
                    downloadEngine.WriteCellValue(Hrow, 21, styleCenter, item.PO_DH_INTERVAL >= 0?(item.PO_DH_DATE == DateTime.MinValue && item.PO_DH_DELAY > 0) ? item.PO_DH_DELAY.ToString() : (item.PO_DH_DATE == DateTime.MinValue ? "" : string.Format("{0:yyyy-MM-dd}", item.PO_DH_DATE)) : "x");
                    downloadEngine.WriteCellValue(Hrow, 22, styleCenter, double.Parse(item.TOTAL_DELAY.ToString()));
                    downloadEngine.WriteCellValue(Hrow, 23, styleNormal, item.VENDOR_CD + "-" +item.VENDOR_NAME);
                    downloadEngine.WriteCellValue(Hrow, 24, styleNormal, item.GR_NO);
                    downloadEngine.WriteCellValue(Hrow, 25, styleNormal, item.GR_CREATED_BY);
                    downloadEngine.WriteCellValue(Hrow, 26, styleCenter, item.GR_CREATED_DATE == DateTime.MinValue ? "" : string.Format("{0:yyyy-MM-dd}", item.GR_CREATED_DATE));
                    row++;
                }

                CreateExcelFile(FileName, ftmp, workbook);
            }
            catch (Exception ex)
            {
                var errorFile = PdfFileCreator.GenerateErrorInfoTextFile(ex);
                Response.BinaryWrite(errorFile.FileByteArray);
                Response.ContentType = errorFile.MimeType;
                Response.AddHeader("content-disposition", String.Format("attachment;filename=\"{0}\"", errorFile.Filename));
                Response.AddHeader("Set-Cookie", "fileDownload=true; path=/");
                Response.Flush();
                Response.End();
            }
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

        private Paging GeneratePaging(int count, int length, int page)
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
    }
}