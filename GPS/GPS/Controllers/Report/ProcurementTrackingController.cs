using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using GPS.CommonFunc;
using GPS.Constants.PR;
using GPS.Models.Common;
using GPS.Models.Master;
using GPS.Models.Report;
using NPOI.HSSF.UserModel;
using NPOI.SS.UserModel;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Report
{
    public class ProcurementTrackingController : PageController
    {


        public ProcurementTrackingController()
        {
            Settings.Title = "Procurment Tracking Screen";
        }


        protected override void Startup()

        {
            //ViewData["Division"] = DivisionRepository.Instance.GetUserDivision(this.GetCurrentRegistrationNumber());
            ViewData["Division"] = DivisionRepository.Instance.GetUserDivision(this.GetCurrentRegistrationNumber());
            ViewData["UserMapping"] = GetUserDivision(this.GetCurrentRegistrationNumber());
        }

        private int GetUserDivision(string noReg)
        {
            return  ProcurementTrackingRepository.Instance.GetUserMapping(noReg);

        }

        #region SEARCH
        private void Calldata(int Display, int page, string PR_NO, string PR_DT_FROM, string PR_DT_TO, string VENDOR, string CREATED_BY, string PO_NO, string PO_DT, string WBS_NO, string GR_NO, string GR_DATE, string DIVISION_ID, string INV_NO, string INV_DT, string PCS_GRP, string CLEARING_NO, string CLEARING_DATE)
        {
            Paging pg = new Paging(ProcurementTrackingRepository.Instance.CountData(PR_NO, PR_DT_FROM, PR_DT_TO, VENDOR, CREATED_BY, PO_NO, PO_DT, WBS_NO, GR_NO, GR_DATE, DIVISION_ID, INV_NO, INV_DT, PCS_GRP, CLEARING_NO, CLEARING_DATE), page, Display);
            ViewData["Paging"] = pg;

            List<ProcurementTracking> list = ProcurementTrackingRepository.Instance.GetData(PR_NO, PR_DT_FROM, PR_DT_TO, VENDOR, CREATED_BY, PO_NO, PO_DT, WBS_NO, GR_NO, GR_DATE, DIVISION_ID, INV_NO, INV_DT, PCS_GRP, CLEARING_NO, CLEARING_DATE, page, Display);
            ViewData["ListProcurementTracking"] = list;
        }

        public ActionResult onGetData(string clear, int Display, int Page, string PR_NO, string PR_DT_FROM, string PR_DT_TO, string VENDOR, string CREATED_BY, string PO_NO, string PO_DT, string WBS_NO, string GR_NO, string GR_DATE, string DIVISION_ID, string INV_NO, string INV_DT, string PCS_GRP, string CLEARING_NO, string CLEARING_DATE)
        {
            if (clear == "N")
            {
                Calldata(Display, Page, PR_NO, PR_DT_FROM, PR_DT_TO, VENDOR, CREATED_BY, PO_NO, PO_DT, WBS_NO, GR_NO, GR_DATE, DIVISION_ID, INV_NO, INV_DT, PCS_GRP, CLEARING_NO, CLEARING_DATE);
            }
            return PartialView("_ProcurementTrackingGrid");
        }

        //public ActionResult onGetDetail(string wbs_no)
        //{
        //    return new JsonResult
        //    {
        //        Data = new
        //        {
        //            Result = ProcurementTrackingRepository.Instance.GetSingleWBSData(wbs_no),
        //            //Message = profile,
        //        }
        //    };
        //}

        //public ActionResult SearchWBSDetail(int Display, int Page, string wbs_no, string action_type)
        //{
        //    CallWBSDetail(Display, Page, wbs_no, action_type);
        //    return PartialView("_ProcurementTrackingDetailGrid");
        //}

        //private void CallWBSDetail(int Display, int Page, string wbs_no, string action_type)
        //{
        //    Paging pg = new Paging(ProcurementTrackingRepository.Instance.CountWBSDetail(wbs_no, action_type), Page, Display);
        //    ViewData["PagingDetail"] = pg;
        //    ViewData["ActionType"] = action_type;
        //    List<ProcurementTracking> list = ProcurementTrackingRepository.Instance.GetListWBSDetail(pg.StartData, pg.EndData, wbs_no, action_type);
        //    ViewData["WBSDetailGrid"] = list;
        //}

        //[HttpGet]
        //public ContentResult GetHeaderSortWBS(int Page, int Display, string field, string sort, string division, string wbs_no, string year)
        //{
        //    List<String> result = new List<String>();
        //    result = GetHeaderSort(Page, Display, field, sort, division, wbs_no, year);

        //    return Content(String.Join("", result.ToArray()));
        //}

        //public List<String> GetHeaderSort(int Page, int Display, string field, string sort, string division, string wbs_no, string year)
        //{
        //    Paging pg = new Paging(ProcurementTrackingRepository.Instance.CountData(division, wbs_no, year), Page, Display);
        //    ViewData["Paging"] = pg;
        //    List<String> result = new List<String>();
        //    List<ProcurementTracking> resultItem = ProcurementTrackingRepository.Instance.GetData(pg.StartData, pg.EndData, division, wbs_no, year);
        //    List<ProcurementTracking> returnResult = new List<ProcurementTracking>();
        //    switch (field)
        //    {
        //        case "WBS_NO":
        //            returnResult = ((sort == "asc" || sort == "none") ? resultItem.OrderBy(o => o.WBS_NO).ToList() : resultItem.OrderByDescending(o => o.WBS_NO).ToList());
        //            break;
        //        case "WBS_DESCRIPTION":
        //            returnResult = ((sort == "asc" || sort == "none") ? resultItem.OrderBy(o => o.WBS_DESCRIPTION).ToList() : resultItem.OrderByDescending(o => o.WBS_DESCRIPTION).ToList());
        //            break;
        //    }

        //    foreach (ProcurementTracking bc in returnResult)
        //    {
        //        result.Add("<tr>" +
        //                "<td style=\"width:37px\" class=\"text-center\">" + bc.NUMBER + "</td>" +
        //                "<td style=\"width:169px\" class=\"text-left\"><a id=\"lnk-docno-" + bc.WBS_NO + "\" href=\"#\" onclick=\"onGetDetailWBS('" + bc.WBS_NO + "',1)\">" + bc.WBS_NO + "</td>" +
        //                "<td style=\"width:324px\" class=\"text-left\">" + bc.WBS_DESCRIPTION + "</td>" +
        //                "<td style=\"width:113px\" class=\"text-right ellipsis\">" + (String.Format("{0:n0}", bc.INITIAL_BUDGET)) + "</td>" +
        //                "<td style=\"width:113px\" class=\"text-right\"><a id=\"lnk-docno-" + bc.WBS_NO + "\" href=\"#\" onclick=\"onGetDetailWBS('" + bc.WBS_NO + "',2)\">" + (String.Format("{0:n0}", bc.COMMITMENT)) + "</td>" +
        //                "<td style=\"width:113px\" class=\"text-right\"><a id=\"lnk-docno-" + bc.WBS_NO + "\" href=\"#\" onclick=\"onGetDetailWBS('" + bc.WBS_NO + "',3)\">" + (String.Format("{0:n0}", bc.BUDGET_CONSUME_GR_SA)) + "</td>" +
        //                "<td style=\"width:113px\" class=\"text-right\">" + (String.Format("{0:n0}", bc.REMAINING_BUDGET_ACTUAL)) + "</td>" +
        //                "<td style=\"width:50px\" class=\"text-right\">" + bc.WBS_YEAR + "</td>" +
        //                "<td style=\"width:55px\" class=\"text-center\">" + bc.CURR_CD + "</td>" +
        //                "<td style=\"width:113px\" class=\"text-right\">" + (String.Format("{0:n0}", bc.INITIAL_AMOUNT)) + "</td>" +
        //                "<td style=\"width:70px\" class=\"text-right\">" + (String.Format("{0:n0}", bc.INITIAL_RATE)) + "</td>" +
        //                //"<td width=\"8%\" class=\"text-right\">" + (String.Format("{0:n0}", bc.REMAINING_BUDGET_INITIAL_RATE)) + "</td>" +
        //                "</tr>");
        //    }
        //    return result;
        //}

        //[HttpGet]
        //public ContentResult GetDetailSortWBS(int Page, int Display, string field, string sort, string wbs_no, string action_type)
        //{
        //    List<String> result = new List<String>();
        //    result = GetDetailSort(Page, Display, field, sort, wbs_no, action_type);

        //    return Content(String.Join("", result.ToArray()));
        //}

        //public List<String> GetDetailSort(int Page, int Display, string field, string sort, string wbs_no, string action_type)
        //{
        //    //CallWBSDetail(Page, Display, wbs_no, action_type);
        //    Paging pg = new Paging(ProcurementTrackingRepository.Instance.CountWBSDetail(wbs_no, action_type), Page, Display);
        //    ViewData["PagingDetail"] = pg;
        //    List<String> result = new List<String>();
        //    List<ProcurementTracking> resultItem = ProcurementTrackingRepository.Instance.GetListWBSDetail(pg.StartData, pg.EndData, wbs_no, action_type);
        //    List<ProcurementTracking> returnResult = new List<ProcurementTracking>();
        //    switch (field)
        //    {
        //        case "REFERENCE_DOC_NO":
        //            returnResult = ((sort == "asc" || sort == "none") ? resultItem.OrderBy(o => o.REFERENCE_DOC_NO).ToList() : resultItem.OrderByDescending(o => o.REFERENCE_DOC_NO).ToList());
        //            break;
        //        case "ITEM_DESCRIPTION":
        //            returnResult = ((sort == "asc" || sort == "none") ? resultItem.OrderBy(o => o.ITEM_DESCRIPTION).ToList() : resultItem.OrderByDescending(o => o.ITEM_DESCRIPTION).ToList());
        //            break;
        //    }

        //    string sign = "";
        //    foreach (ProcurementTracking bc in returnResult)
        //    {
        //        sign = "<tr>" +
        //             "<td width=\"3%\" class=\"text-center\">" + bc.NUMBER + "</td>" +
        //             "<td class=\"text-left\">" + bc.REFERENCE_DOC_NO + "</td>" +
        //             "<td class=\"text-left\">" + bc.ITEM_DESCRIPTION + "</td>" +
        //             "<td width=\"3%\" class=\"text-center\">" + bc.CURR_CD + "</td>" +
        //             "<td width=\"8%\" class=\"text-right\">" + (String.Format("{0:n0}", bc.ACTUAL_AMOUNT)) + "</td>" +
        //             "<td width=\"5%\" class=\"text-right\">" + (String.Format("{0:n0}", bc.EXC_RATE_ACTUAL)) + "</td>";
        //        if (bc.SIGN == "P")
        //        {
        //            sign = sign + "<td width=\"8%\" class=\"text-right\">" + (String.Format("{0:n0}", bc.TOTAL_AMOUNT)) + "</td>" +
        //            "<td width=\"8%\" class=\"text-right\">" + 0 + "</td>";
        //        }
        //        else
        //        {
        //            sign = sign + "<td width=\"8%\" class=\"text-right\">" + 0 + "</td>" +
        //            "<td width=\"8%\" class=\"text-right\">" + (String.Format("{0:n0}", bc.TOTAL_AMOUNT)) + "</td>";
        //        }
        //        sign = sign + "<td width=\"12%\" class=\"text-left\">" + bc.ACTION_TYPE + "</td>" +
        //            "<td width=\"6%\" class=\"text-center\">" + bc.CHANGED_BY + "</td>" +
        //            "<td width=\"6%\" class=\"text-center\">" + bc.CHANGED_DT + "</td>" +
        //            "</tr>";
        //        result.Add(sign);
        //    }
        //    return result;
        //}
        #endregion

        #region DOWNLOAD
        public void DownloadHeader(string PR_NO, string PR_DT_FROM, string PR_DT_TO, string VENDOR, string CREATED_BY, string PO_NO, string PO_DT, string WBS_NO, string GR_NO, string GR_DATE, string DIVISION_ID, string INV_NO, string INV_DT, string PCS_GRP, string CLEARING_NO, string CLEARING_DATE)
        {
            string filePath = HttpContext.Request.MapPath("~/Content/Download/ProcurementTrackingHeader.xls");
            FileStream ftmp = new FileStream(filePath, FileMode.Open, FileAccess.Read);

            HSSFWorkbook workbook = new HSSFWorkbook(ftmp);

            IRow Hrow;
            int row = 1;

            string username = this.GetCurrentUsername();
            List<ProcurementTracking> header = new List<ProcurementTracking>();
            header = ProcurementTrackingRepository.Instance.getDownloadHeader(PR_NO, PR_DT_FROM, PR_DT_TO, VENDOR, CREATED_BY, PO_NO, PO_DT, WBS_NO, GR_NO, GR_DATE, DIVISION_ID, INV_NO, INV_DT, PCS_GRP, CLEARING_NO, CLEARING_DATE).ToList();

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

            foreach (ProcurementTracking bc_header in header)
            {
                Hrow = sheet.CreateRow(row);
                Hrow.CreateCell(0).SetCellValue(bc_header.PR_NO);
                Hrow.CreateCell(1).SetCellValue(bc_header.PR_ITEM_NO);
                Hrow.CreateCell(2).SetCellValue(bc_header.PR_SUBITEM_NO);
                Hrow.CreateCell(3).SetCellValue(bc_header.PR_DOC_DT.ToShortDateString() == "" ? "" : bc_header.PR_DOC_DT.ToStandardFormat());
                Hrow.CreateCell(4).SetCellValue(bc_header.PLANT_CD);
                Hrow.CreateCell(5).SetCellValue(bc_header.SLOC_CD);
                Hrow.CreateCell(6).SetCellValue(bc_header.MAT_NO);
                Hrow.CreateCell(7).SetCellValue(bc_header.MAT_DESC);
                Hrow.CreateCell(8).SetCellValue(bc_header.PR_QTY.ToString() == "0" ? "": bc_header.PR_QTY.ToString());
                Hrow.CreateCell(9).SetCellValue(bc_header.UNIT_OF_MEASURE_CD);
                Hrow.CreateCell(10).SetCellValue(bc_header.PR_ORI_AMOUNT.ToStandardFormat() == "0" ? "" : bc_header.PR_ORI_AMOUNT.ToStandardFormat());
                Hrow.CreateCell(11).SetCellValue(bc_header.ORI_CURR_CD);
                Hrow.CreateCell(12).SetCellValue(bc_header.BUDGET_REF);
                Hrow.CreateCell(13).SetCellValue(bc_header.CREATED_BY);
                Hrow.CreateCell(14).SetCellValue(bc_header.PO_NO);
                Hrow.CreateCell(15).SetCellValue(bc_header.PO_ITEM_NO);
                Hrow.CreateCell(16).SetCellValue(bc_header.PO_SUBITEM_NO);
                Hrow.CreateCell(17).SetCellValue(bc_header.PURCHASING_GRP_CD);
                Hrow.CreateCell(18).SetCellValue(bc_header.PO_DOC_DT.ToShortDateString() == "" ? "" : bc_header.PO_DOC_DT.ToStandardFormat());
                Hrow.CreateCell(19).SetCellValue(bc_header.PO_CURR);
                Hrow.CreateCell(20).SetCellValue(bc_header.PO_QTY_ORI.ToString() == "0" ? "" : bc_header.PO_QTY_ORI.ToString());
                Hrow.CreateCell(21).SetCellValue(bc_header.UOM);
                Hrow.CreateCell(22).SetCellValue(bc_header.PO_ORI_AMOUNT.ToStandardFormat() == "0" ? "" : bc_header.PO_ORI_AMOUNT.ToStandardFormat());
                Hrow.CreateCell(23).SetCellValue(bc_header.VENDOR_CD == "" ? "" : bc_header.VENDOR_CD + " - " + bc_header.VENDOR_NAME);
                Hrow.CreateCell(24).SetCellValue(bc_header.MAT_DOC_NO);
                Hrow.CreateCell(25).SetCellValue(bc_header.MAT_DOC_ITEM_NO);
                Hrow.CreateCell(26).SetCellValue(bc_header.GR_PO_SUBITEM_NO);
                Hrow.CreateCell(27).SetCellValue(bc_header.DOCUMENT_DT.ToStandardFormat() == "" ? "" : bc_header.DOCUMENT_DT.ToStandardFormat());
                Hrow.CreateCell(28).SetCellValue(bc_header.GR_IR_AMOUNT.ToStandardFormat() == "0" ? "" : bc_header.GR_IR_AMOUNT.ToStandardFormat());
                Hrow.CreateCell(29).SetCellValue(bc_header.InvoiceNo);
                Hrow.CreateCell(30).SetCellValue(bc_header.InvoiceDate.ToShortDateString()== "" ? "" : bc_header.InvoiceDate.ToStandardFormat());
                Hrow.CreateCell(31).SetCellValue(bc_header.InvoiceAmount.ToStandardFormat() == "0" ? "" : bc_header.InvoiceAmount.ToStandardFormat());
                Hrow.CreateCell(32).SetCellValue(bc_header.InvoiceCurrency);
                Hrow.CreateCell(33).SetCellValue(bc_header.ClearingNo);
                Hrow.CreateCell(34).SetCellValue(bc_header.ClearingDate.ToShortDateString() == "" ? "" : bc_header.ClearingDate.ToStandardFormat());
                row++;
            }

            MemoryStream ms = new MemoryStream();
            workbook.Write(ms);
            ftmp.Close();
            Response.BinaryWrite(ms.ToArray());

            Response.ContentType = "application/ms-excel";
            string filenametrimmed = "ProcurementTrackingHeader.xls";
            Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", filenametrimmed));
        }

        //public void DownloadDetail(string PR_NO, string PR_DT_FROM, string PR_DT_TO, string VENDOR, string CREATED_BY, string PO_NO, string PO_DT, string WBS_NO, string GR_NO, string GR_DATE, string DIVISION_ID, string CLEARING_NO, string CLEARING_DATE)
        //{
        //    string filePath = HttpContext.Request.MapPath("~/Content/Download/ProcurementTrackingDetail.xls");
        //    FileStream ftmp = new FileStream(filePath, FileMode.Open, FileAccess.Read);

        //    HSSFWorkbook workbook = new HSSFWorkbook(ftmp);

        //    IRow Hrow;
        //    int row = 2;

        //    string username = this.GetCurrentUsername();
        //    List<ProcurementTracking> detail = new List<ProcurementTracking>();
        //    detail = ProcurementTrackingRepository.Instance.getDownloadDetail(PR_NO, PR_DT_FROM, PR_DT_TO, VENDOR, CREATED_BY, PO_NO, PO_DT, WBS_NO, GR_NO, GR_DATE, DIVISION_ID, CLEARING_NO, CLEARING_DATE).ToList();

        //    ISheet sheet;

        //    ICellStyle styleContent1 = workbook.CreateCellStyle();
        //    styleContent1.VerticalAlignment = VerticalAlignment.TOP;
        //    styleContent1.BorderLeft = NPOI.SS.UserModel.BorderStyle.THIN;
        //    styleContent1.BorderBottom = NPOI.SS.UserModel.BorderStyle.THIN;
        //    styleContent1.BorderTop = NPOI.SS.UserModel.BorderStyle.THIN;
        //    styleContent1.BorderRight = NPOI.SS.UserModel.BorderStyle.THIN;
        //    styleContent1.FillForegroundColor = NPOI.HSSF.Util.HSSFColor.YELLOW.index;

        //    ICellStyle styleContent2 = workbook.CreateCellStyle();
        //    styleContent2.Alignment = HorizontalAlignment.CENTER;
        //    styleContent2.BorderLeft = NPOI.SS.UserModel.BorderStyle.THIN;
        //    styleContent2.BorderBottom = NPOI.SS.UserModel.BorderStyle.THIN;
        //    styleContent2.BorderTop = NPOI.SS.UserModel.BorderStyle.THIN;
        //    styleContent2.BorderRight = NPOI.SS.UserModel.BorderStyle.THIN;
        //    styleContent2.FillForegroundColor = NPOI.HSSF.Util.HSSFColor.YELLOW.index;
        //    styleContent2.FillBackgroundColor = NPOI.HSSF.Util.HSSFColor.RED.index;
        //    styleContent2.WrapText = true;

        //    ICellStyle styleContent3 = workbook.CreateCellStyle();
        //    styleContent3.Alignment = HorizontalAlignment.CENTER;
        //    styleContent3.BorderLeft = NPOI.SS.UserModel.BorderStyle.THIN;
        //    styleContent3.BorderBottom = NPOI.SS.UserModel.BorderStyle.THIN;
        //    styleContent3.BorderTop = NPOI.SS.UserModel.BorderStyle.THIN;
        //    styleContent3.BorderRight = NPOI.SS.UserModel.BorderStyle.THIN;
        //    styleContent3.FillForegroundColor = NPOI.HSSF.Util.HSSFColor.YELLOW.index;
        //    styleContent3.WrapText = true;//Word wrap
        //    styleContent3.VerticalAlignment = VerticalAlignment.CENTER;

        //    sheet = workbook.GetSheetAt(0);

        //    int rowCount = detail.Count();

        //    foreach (ProcurementTracking bc_detail in detail)
        //    {
        //        Hrow = sheet.CreateRow(row);
        //        Hrow.CreateCell(0).SetCellValue(bc_detail.REFERENCE_DOC_NO);
        //        Hrow.CreateCell(1).SetCellValue(bc_detail.ITEM_DESCRIPTION);
        //        Hrow.CreateCell(2).SetCellValue(bc_detail.CURR_CD);
        //        Hrow.CreateCell(3).SetCellValue(bc_detail.ACTUAL_AMOUNT);
        //        Hrow.CreateCell(4).SetCellValue(Convert.ToDouble(bc_detail.EXC_RATE_ACTUAL));
        //        if (bc_detail.SIGN == "P")
        //        {
        //            Hrow.CreateCell(5).SetCellValue(bc_detail.TOTAL_AMOUNT);
        //            Hrow.CreateCell(6).SetCellValue(0);
        //        }
        //        else
        //        {
        //            Hrow.CreateCell(5).SetCellValue(0);
        //            Hrow.CreateCell(6).SetCellValue(bc_detail.TOTAL_AMOUNT);
        //        }
        //        Hrow.CreateCell(7).SetCellValue(bc_detail.ACTION_TYPE);
        //        Hrow.CreateCell(8).SetCellValue(bc_detail.CHANGED_BY);
        //        Hrow.CreateCell(9).SetCellValue(bc_detail.CHANGED_DT);
        //        row++;
        //    }

        //    MemoryStream ms = new MemoryStream();
        //    workbook.Write(ms);
        //    ftmp.Close();
        //    Response.BinaryWrite(ms.ToArray());

        //    Response.ContentType = "application/ms-excel";
        //    string filenametrimmed = "ProcurementTrackingDetail.xls";
        //    Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", filenametrimmed));
        //}
        #endregion
    }
}
