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

namespace GPS.Controllers.Master
{
    public class BudgetControlController : PageController
    {
        public BudgetControlController()
        {
            Settings.Title = "Budget Control Monitoring";
        }

        protected override void Startup()
        {
            ViewData["Division"] = DivisionRepository.Instance.GetUserDivision(this.GetCurrentRegistrationNumber());
            ViewData["WBSYear"] = BudgetControlRepository.Instance.GetFiscalYear();

        }

        #region SEARCH
        private void Calldata(int Display, int Page, string division, string wbs_no, string year)
        {
            Paging pg = new Paging(BudgetControlRepository.Instance.CountData(division, wbs_no, year), Page, Display);
            ViewData["Paging"] = pg;
            List<BudgetControl> list = BudgetControlRepository.Instance.GetData(pg.StartData, pg.EndData, division, wbs_no, year);
            ViewData["ListWBS"] = list;
        }

        public ActionResult onGetData(string clear, string division, string wbs_no, string year, int Display, int Page)
        {
            if (clear == "N")
            {
                Calldata(Display, Page, division, wbs_no, year);
            }
            return PartialView("_BudgetControlGrid");
        }

        public ActionResult onGetDetail(string wbs_no)
        {
            return new JsonResult
            {
                Data = new
                {
                    Result = BudgetControlRepository.Instance.GetSingleWBSData(wbs_no),
                    //Message = profile,
                }
            };
        }

        public ActionResult SearchWBSDetail(int Display, int Page, string wbs_no, string action_type)
        {
            CallWBSDetail(Display, Page, wbs_no, action_type);
            return PartialView("_BudgetControlDetailGrid");
        }

        private void CallWBSDetail(int Display, int Page, string wbs_no, string action_type)
        {
            Paging pg = new Paging(BudgetControlRepository.Instance.CountWBSDetail(wbs_no, action_type), Page, Display);
            ViewData["PagingDetail"] = pg;
            ViewData["ActionType"] = action_type;
            List<BudgetControl> list = BudgetControlRepository.Instance.GetListWBSDetail(pg.StartData, pg.EndData, wbs_no, action_type);
            ViewData["WBSDetailGrid"] = list;
        }

        [HttpGet]
        public ContentResult GetHeaderSortWBS(int Page, int Display, string field, string sort, string division, string wbs_no, string year)
        {
            List<String> result = new List<String>();
            result = GetHeaderSort(Page, Display, field, sort, division, wbs_no, year);

            return Content(String.Join("", result.ToArray()));
        }

        public List<String> GetHeaderSort(int Page, int Display, string field, string sort, string division, string wbs_no, string year)
        {
            Paging pg = new Paging(BudgetControlRepository.Instance.CountData(division, wbs_no, year), Page, Display);
            ViewData["Paging"] = pg;
            List<String> result = new List<String>();
            List<BudgetControl> resultItem = BudgetControlRepository.Instance.GetData(pg.StartData, pg.EndData, division, wbs_no, year);
            List<BudgetControl> returnResult = new List<BudgetControl>();
            switch (field)
            {
                case "WBS_NO":
                    returnResult = ((sort == "asc" || sort == "none") ? resultItem.OrderBy(o => o.WBS_NO).ToList() : resultItem.OrderByDescending(o => o.WBS_NO).ToList());
                    break;
                case "WBS_DESCRIPTION":
                    returnResult = ((sort == "asc" || sort == "none") ? resultItem.OrderBy(o => o.WBS_DESCRIPTION).ToList() : resultItem.OrderByDescending(o => o.WBS_DESCRIPTION).ToList());
                    break;
            }

            foreach (BudgetControl bc in returnResult)
            {
                result.Add("<tr>" +
                        "<td style=\"width:37px\" class=\"text-center\">" + bc.NUMBER + "</td>" +
                        "<td style=\"width:169px\" class=\"text-left\"><a id=\"lnk-docno-" + bc.WBS_NO + "\" href=\"#\" onclick=\"onGetDetailWBS('" + bc.WBS_NO + "',1)\">" + bc.WBS_NO + "</td>" +
                        "<td style=\"width:324px\" class=\"text-left\">" + bc.WBS_DESCRIPTION + "</td>" +
                        "<td style=\"width:113px\" class=\"text-right ellipsis\">" + (String.Format("{0:n0}", bc.INITIAL_BUDGET)) + "</td>" +
                        "<td style=\"width:113px\" class=\"text-right\"><a id=\"lnk-docno-" + bc.WBS_NO + "\" href=\"#\" onclick=\"onGetDetailWBS('" + bc.WBS_NO + "',2)\">" + (String.Format("{0:n0}", bc.COMMITMENT)) + "</td>" +
                        "<td style=\"width:113px\" class=\"text-right\"><a id=\"lnk-docno-" + bc.WBS_NO + "\" href=\"#\" onclick=\"onGetDetailWBS('" + bc.WBS_NO + "',3)\">" + (String.Format("{0:n0}", bc.BUDGET_CONSUME_GR_SA)) + "</td>" +
                        "<td style=\"width:113px\" class=\"text-right\">" + (String.Format("{0:n0}", bc.REMAINING_BUDGET_ACTUAL)) + "</td>" +
                        "<td style=\"width:50px\" class=\"text-right\">" + bc.WBS_YEAR + "</td>" +
                        "<td style=\"width:55px\" class=\"text-center\">" + bc.CURR_CD + "</td>" +
                        "<td style=\"width:113px\" class=\"text-right\">" + (String.Format("{0:n0}", bc.INITIAL_AMOUNT)) + "</td>" +
                        "<td style=\"width:70px\" class=\"text-right\">" + (String.Format("{0:n0}", bc.INITIAL_RATE)) + "</td>" +
                    //"<td width=\"8%\" class=\"text-right\">" + (String.Format("{0:n0}", bc.REMAINING_BUDGET_INITIAL_RATE)) + "</td>" +
                        "</tr>");
            }
            return result;
        }

        [HttpGet]
        public ContentResult GetDetailSortWBS(int Page, int Display, string field, string sort, string wbs_no, string action_type)
        {
            List<String> result = new List<String>();
            result = GetDetailSort(Page, Display, field, sort, wbs_no, action_type);

            return Content(String.Join("", result.ToArray()));
        }

        public List<String> GetDetailSort(int Page, int Display, string field, string sort, string wbs_no, string action_type)
        {
            //CallWBSDetail(Page, Display, wbs_no, action_type);
            Paging pg = new Paging(BudgetControlRepository.Instance.CountWBSDetail(wbs_no, action_type), Page, Display);
            ViewData["PagingDetail"] = pg;
            List<String> result = new List<String>();
            List<BudgetControl> resultItem = BudgetControlRepository.Instance.GetListWBSDetail(pg.StartData, pg.EndData, wbs_no, action_type);
            List<BudgetControl> returnResult = new List<BudgetControl>();
            switch (field)
            {
                case "REFERENCE_DOC_NO":
                    returnResult = ((sort == "asc" || sort == "none") ? resultItem.OrderBy(o => o.REFERENCE_DOC_NO).ToList() : resultItem.OrderByDescending(o => o.REFERENCE_DOC_NO).ToList());
                    break;
                case "ITEM_DESCRIPTION":
                    returnResult = ((sort == "asc" || sort == "none") ? resultItem.OrderBy(o => o.ITEM_DESCRIPTION).ToList() : resultItem.OrderByDescending(o => o.ITEM_DESCRIPTION).ToList());
                    break;
            }

            string sign = "";
            foreach (BudgetControl bc in returnResult)
            {
                sign = "<tr>" +
                     "<td width=\"3%\" class=\"text-center\">" + bc.NUMBER + "</td>" +
                     "<td class=\"text-left\">" + bc.REFERENCE_DOC_NO + "</td>" +
                     "<td class=\"text-left\">" + bc.ITEM_DESCRIPTION + "</td>" +
                     "<td width=\"3%\" class=\"text-center\">" + bc.CURR_CD + "</td>" +
                     "<td width=\"8%\" class=\"text-right\">" + (String.Format("{0:n0}", bc.ACTUAL_AMOUNT)) + "</td>" +
                     "<td width=\"5%\" class=\"text-right\">" + (String.Format("{0:n0}", bc.EXC_RATE_ACTUAL)) + "</td>";
                if (bc.SIGN == "P")
                {
                    sign = sign + "<td width=\"8%\" class=\"text-right\">" + (String.Format("{0:n0}", bc.TOTAL_AMOUNT)) + "</td>" +
                    "<td width=\"8%\" class=\"text-right\">" + 0 + "</td>";
                }
                else
                {
                    sign = sign + "<td width=\"8%\" class=\"text-right\">" + 0 + "</td>" +
                    "<td width=\"8%\" class=\"text-right\">" + (String.Format("{0:n0}", bc.TOTAL_AMOUNT)) + "</td>";
                }
                sign = sign + "<td width=\"12%\" class=\"text-left\">" + bc.ACTION_TYPE + "</td>" +
                    "<td width=\"6%\" class=\"text-center\">" + bc.CHANGED_BY + "</td>" +
                    "<td width=\"6%\" class=\"text-center\">" + bc.CHANGED_DT + "</td>" +
                    "</tr>";
                result.Add(sign);
            }
            return result;
        }
        #endregion

        #region DOWNLOAD
        public void DownloadHeader(string division, string wbs_no, string year)
        {
            string filePath = HttpContext.Request.MapPath("~/Content/Download/BudgetControlHeader.xls");
            FileStream ftmp = new FileStream(filePath, FileMode.Open, FileAccess.Read);

            HSSFWorkbook workbook = new HSSFWorkbook(ftmp);

            IRow Hrow;
            int row = 1;

            string username = this.GetCurrentUsername();
            List<BudgetControl> header = new List<BudgetControl>();
            header = BudgetControlRepository.Instance.getDownloadHeader(division, wbs_no, year).ToList();

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

            foreach (BudgetControl bc_header in header)
            {
                Hrow = sheet.CreateRow(row);
                Hrow.CreateCell(0).SetCellValue(bc_header.WBS_NO);
                Hrow.CreateCell(1).SetCellValue(bc_header.WBS_DESCRIPTION);
                Hrow.CreateCell(2).SetCellValue(bc_header.INITIAL_BUDGET);
                Hrow.CreateCell(3).SetCellValue(bc_header.COMMITMENT);
                Hrow.CreateCell(4).SetCellValue(bc_header.BUDGET_CONSUME_GR_SA);
                Hrow.CreateCell(5).SetCellValue(bc_header.REMAINING_COMMITMENT);
                Hrow.CreateCell(6).SetCellValue(bc_header.WBS_YEAR);
                Hrow.CreateCell(7).SetCellValue(bc_header.CURR_CD);
                Hrow.CreateCell(8).SetCellValue(bc_header.INITIAL_AMOUNT);
                Hrow.CreateCell(9).SetCellValue(Convert.ToDouble(bc_header.INITIAL_RATE));
                row++;
            }

            MemoryStream ms = new MemoryStream();
            workbook.Write(ms);
            ftmp.Close();
            Response.BinaryWrite(ms.ToArray());

            Response.ContentType = "application/ms-excel";
            string filenametrimmed = "BudgetControlHeader.xls";
            Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", filenametrimmed));
        }

        public void DownloadDetail(string wbs_no, string action_type)
        {
            string filePath = HttpContext.Request.MapPath("~/Content/Download/BudgetControlDetail.xls");
            FileStream ftmp = new FileStream(filePath, FileMode.Open, FileAccess.Read);

            HSSFWorkbook workbook = new HSSFWorkbook(ftmp);

            IRow Hrow;
            int row = 2;

            string username = this.GetCurrentUsername();
            List<BudgetControl> detail = new List<BudgetControl>();
            detail = BudgetControlRepository.Instance.getDownloadDetail(wbs_no, action_type).ToList();

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

            int rowCount = detail.Count();

            foreach (BudgetControl bc_detail in detail)
            {
                Hrow = sheet.CreateRow(row);
                Hrow.CreateCell(0).SetCellValue(bc_detail.REFERENCE_DOC_NO);
                Hrow.CreateCell(1).SetCellValue(bc_detail.ITEM_DESCRIPTION);
                Hrow.CreateCell(2).SetCellValue(bc_detail.CURR_CD);
                Hrow.CreateCell(3).SetCellValue(bc_detail.ACTUAL_AMOUNT);
                Hrow.CreateCell(4).SetCellValue(Convert.ToDouble(bc_detail.EXC_RATE_ACTUAL));
                if (bc_detail.SIGN == "P")
                {
                    Hrow.CreateCell(5).SetCellValue(bc_detail.TOTAL_AMOUNT);
                    Hrow.CreateCell(6).SetCellValue(0);
                }
                else
                {
                    Hrow.CreateCell(5).SetCellValue(0);
                    Hrow.CreateCell(6).SetCellValue(bc_detail.TOTAL_AMOUNT);
                }
                Hrow.CreateCell(7).SetCellValue(bc_detail.ACTION_TYPE);
                Hrow.CreateCell(8).SetCellValue(bc_detail.CHANGED_BY);
                Hrow.CreateCell(9).SetCellValue(bc_detail.CHANGED_DT);
                row++;
            }

            MemoryStream ms = new MemoryStream();
            workbook.Write(ms);
            ftmp.Close();
            Response.BinaryWrite(ms.ToArray());

            Response.ContentType = "application/ms-excel";
            string filenametrimmed = "BudgetControlDetail.xls";
            Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", filenametrimmed));
        }
        #endregion
    }
}