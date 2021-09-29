using System;
using System.Collections.Generic;
using NPOI.HSSF.UserModel;
using NPOI.HSSF.Util;
using NPOI.SS.UserModel;

namespace GPS.Models
{
    public class CommonDownload
    {
        private CommonDownload() { }
        private static CommonDownload instance = null;
        public static CommonDownload Instance
        {
            get { return instance ?? (instance = new CommonDownload()); }
        }

        public String GetServerFilePath(String filename)
        {
            return "~/Content/Download/Template/" + filename;
        }

        public HSSFWorkbook CreateExcelSheet(IList<String[]> dataList, String sheetName)
        {
            var workbook = new HSSFWorkbook();
            ISheet sheet = workbook.CreateSheet(sheetName);
            IFont font = workbook.CreateFont();
            font.FontHeightInPoints = 10;
            font.Color = HSSFColor.WHITE.index;
            font.FontName = "Arial";
            font.Boldweight = (Int16)FontBoldWeight.BOLD;

            ICellStyle style = workbook.CreateCellStyle();
            style.FillBackgroundColor = HSSFColor.GREY_25_PERCENT.index;
            style.FillPattern = FillPatternType.SOLID_FOREGROUND;
            style.Alignment = HorizontalAlignment.CENTER;

            ICellStyle styleDefault = workbook.CreateCellStyle();

            CreateHeader(ref sheet, style, font, dataList);
            PopulateData(ref sheet, styleDefault, dataList);

            return workbook;
        }

        private void CreateHeader(ref ISheet sheet, ICellStyle style, IFont font, IList<String[]> dataList)
        {
            IRow headerRow = sheet.CreateRow(0);
            String[] columnHeader = dataList[0];

            for (int colIdx = 0; colIdx < columnHeader.Length; colIdx++)
            {
                ICell cell = headerRow.CreateCell(colIdx);
                cell.SetCellValue(columnHeader[colIdx]);
                cell.CellStyle = style;
                cell.CellStyle.SetFont(font);
            }
        }

        private void PopulateData(ref ISheet sheet, ICellStyle style, IList<String[]> dataList)
        {
            PopulateData(ref sheet, style, dataList, false);
        }

        private void PopulateData(ref ISheet sheet, ICellStyle style, IList<String[]> dataList, bool autosizeColumn)
        {
            dataList.RemoveAt(0);
            for (int rowIdx = 1; rowIdx <= dataList.Count; rowIdx++)
            {
                IRow row = sheet.CreateRow(rowIdx);
                Int32 columnLength = dataList[0].Length;
                for (int colIdx = 0; colIdx < columnLength; colIdx++)
                {
                    row.CreateCell(colIdx);
                    //row.CreateCell(colIdx).SetCellValue(dataList[rowIdx - 1][colIdx]);
                    ICell cell = row.CreateCell(colIdx);
                    cell.CellStyle = style;
                    cell.SetCellValue(dataList[rowIdx - 1][colIdx]);
                    if (autosizeColumn)
                    { 
                        sheet.AutoSizeColumn(colIdx); //--> diremark dulu karena error saat download
                        GC.Collect(); // Add this line
                    }
                }
            }
        }

        public HSSFWorkbook CreateExcelSheetWithBorder(IList<String[]> dataList, String sheetName)
        {
            var workbook = new HSSFWorkbook();
            ISheet sheet = workbook.CreateSheet(sheetName);
            IFont font = workbook.CreateFont();
            font.FontHeightInPoints = 11;
            font.Color = HSSFColor.BLACK.index;
            font.FontName = "Calibri";
            //font.Boldweight = (Int16)FontBoldWeight.BOLD;
            ICellStyle style = SettingHeaderStyle(workbook);
            ICellStyle styleDetail = SettingDetailStyle(workbook);
            styleDetail.SetFont(font);

            CreateHeader(ref sheet, style, font, dataList);
            PopulateData(ref sheet, styleDetail, dataList, true);

            return workbook;
        }

        private static ICellStyle SettingHeaderStyle(HSSFWorkbook workbook)
        {
            ICellStyle style = workbook.CreateCellStyle();
            //style.FillForegroundColor = HSSFColor.GREY_25_PERCENT.index;
            HSSFColor lightGray = SetColor(workbook, (byte)0xF2, (byte)0xF2, (byte)0xF2);
            style.FillForegroundColor = lightGray.GetIndex();
            style.FillPattern = FillPatternType.SOLID_FOREGROUND;
            style.Alignment = HorizontalAlignment.CENTER;
            style.BorderLeft = BorderStyle.THIN;
            style.BorderRight = BorderStyle.THIN;
            style.BorderTop = BorderStyle.THIN;
            style.BorderBottom = BorderStyle.THIN;
            return style;
        }

        public static HSSFColor SetColor(HSSFWorkbook workbook, byte r, byte g, byte b)
        {
            HSSFPalette palette = workbook.GetCustomPalette();
            HSSFColor hssfColor = null;
            try
            {
                hssfColor = palette.FindColor(r, g, b);
                if (hssfColor == null)
                {
                    palette.SetColorAtIndex(HSSFColor.LAVENDER.index, r, g, b);
                    hssfColor = palette.GetColor(HSSFColor.LAVENDER.index);
                }
            }
            catch
            {
            }

            return hssfColor;
        }

        public static ICellStyle SettingDetailStyle(HSSFWorkbook workbook)
        {
            ICellStyle style2 = workbook.CreateCellStyle();
            style2.BorderLeft = BorderStyle.THIN;
            style2.BorderRight = BorderStyle.THIN;
            style2.BorderTop = BorderStyle.THIN;
            style2.BorderBottom = BorderStyle.THIN;
            return style2;
        }

        public void WriteCellValue(IRow Hrow, int icolumn, ICellStyle styleNormal, int dataValue)
        {
            ICell cell = Hrow.CreateCell(icolumn);
            cell.CellStyle = styleNormal;
            cell.SetCellValue(dataValue);
        }

        public void WriteCellValue(IRow Hrow, int icolumn, ICellStyle styleNormal, string dataValue)
        {
            ICell cell = Hrow.CreateCell(icolumn);
            cell.CellStyle = styleNormal;
            cell.SetCellValue(dataValue);
        }

        public void WriteCellValue(IRow Hrow, int icolumn, ICellStyle styleNormal, double dataValue)
        {
            ICell cell = Hrow.CreateCell(icolumn);
            cell.CellStyle = styleNormal;
            cell.SetCellValue(dataValue);
        }

        public IFont GenerateFontExcel(HSSFWorkbook workbook)
        {
            IFont font = workbook.CreateFont();
            font.FontHeightInPoints = 11;
            font.Color = HSSFColor.BLACK.index;
            font.FontName = "Calibri";
            return font;
        }

        public ICellStyle GenerateStyleNormal(HSSFWorkbook workbook, IFont font)
        {
            ICellStyle styleLeft = workbook.CreateCellStyle();
            styleLeft.BorderLeft = NPOI.SS.UserModel.BorderStyle.THIN;
            styleLeft.BorderBottom = NPOI.SS.UserModel.BorderStyle.THIN;
            styleLeft.BorderTop = NPOI.SS.UserModel.BorderStyle.THIN;
            styleLeft.BorderRight = NPOI.SS.UserModel.BorderStyle.THIN;
            styleLeft.FillForegroundColor = NPOI.HSSF.Util.HSSFColor.YELLOW.index;
            styleLeft.WrapText = true;//Word wrap
            styleLeft.SetFont(font);
            return styleLeft;
        }

        public ICellStyle GenerateStyleLeft(HSSFWorkbook workbook, IFont font)
        {
            ICellStyle styleCell = GenerateStyleNormal(workbook, font);
            styleCell.Alignment = HorizontalAlignment.LEFT;
            return styleCell;
        }

        public ICellStyle GenerateStyleRight(HSSFWorkbook workbook, IFont font)
        {
            ICellStyle styleCell = GenerateStyleNormal(workbook, font);
            styleCell.Alignment = HorizontalAlignment.RIGHT;
            return styleCell;
        }

        public ICellStyle GenerateStyleCenter(HSSFWorkbook workbook, IFont font)
        {
            ICellStyle styleCell = GenerateStyleNormal(workbook, font);
            styleCell.Alignment = HorizontalAlignment.CENTER;
            return styleCell;
        }
    }
}