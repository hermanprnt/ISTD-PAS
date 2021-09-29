using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using GPS.Constants;
using GPS.Core.GPSLogService;
using Microsoft.Reporting.WebForms;

namespace GPS.CommonFunc
{
    public class PdfFileCreator
    {
        public class FileInfo
        {
            public Byte[] FileByteArray { get; set; }
            public String MimeType { get; set; }
            public String Filename { get; set; }
            public String DocumentFullPath { get; set; }
            public String DocumentNo { get; set; }
            public String DocumentName { get; set; }
        }

        public FileInfo GetPdfFileInfo(String documentBasePath, String reportPath, String docName, IEnumerable<String> docNoList, Func<Dictionary<String, DataTable>> getDataTableListAction)
        {
            String combinedDocNo = GetDocFilenameFromDocNo(docNoList);
            String docFilename = GetDocFilename(docName, combinedDocNo);
            String docFullPath = GetDocFullPath(documentBasePath, docFilename, combinedDocNo);

            var fileInfo = new FileInfo();
            fileInfo.DocumentName = docName;
            fileInfo.DocumentNo = combinedDocNo;
            fileInfo.Filename = docFilename;
            fileInfo.DocumentFullPath = docFullPath;

            String tempDirPath = docFullPath.Replace(Path.GetFileName(docFullPath), "");
            if (!Directory.Exists(tempDirPath))
                Directory.CreateDirectory(tempDirPath);

            return GeneratePdfFile(fileInfo, reportPath, getDataTableListAction);
        }

        private FileInfo GeneratePdfFile(FileInfo fileInfo, String reportPath, Func<Dictionary<String, DataTable>> getDataTableListAction)
        {
            Dictionary<String, DataTable> dataTableList = getDataTableListAction();
            if (!dataTableList.Any())
                throw new InvalidOperationException("Report Datatables have zero items.");

            var rv = new ReportViewer();
            rv.ProcessingMode = ProcessingMode.Local;
            rv.LocalReport.EnableExternalImages = true;
            rv.LocalReport.ReportPath = reportPath;
            rv.LocalReport.DataSources.Clear();

            foreach (String key in dataTableList.Keys)
            {
                DataTable dt = dataTableList[key];
                if (dt == null)
                    throw new InvalidOperationException("Datatable for " + key + " is null.");
                rv.LocalReport.DataSources.Add(new ReportDataSource(key, dt));
            }

            rv.LocalReport.Refresh();

            // NOTE: needed for "out" keyword in Render method
            String mimeType = String.Empty;
            String encoding = String.Empty;
            String fileNameExtension = String.Empty;
            String[] streamIdArray = null;
            Warning[] warningArray = null;
            fileInfo.FileByteArray = rv.LocalReport.Render("PDF", null, out mimeType, out encoding, out fileNameExtension, out streamIdArray, out warningArray);
            fileInfo.MimeType = mimeType;

            File.WriteAllBytes(fileInfo.DocumentFullPath, fileInfo.FileByteArray);

            return fileInfo;
        }

        private String GetDocFullPath(String docBasePath, String filename, String documentNo)
        {
            // NOTE: download and upload fit in same dir but upload using processid sub-dir and download using docno sub-dir
            String fullPath = Path.GetFullPath(docBasePath + "\\" + documentNo);
            return Path.Combine(fullPath, filename);
        }

        private String GetDocFilename(String docName, String docNo)
        {
            return new StringBuilder()
                .Append(docName)
                .Append("_")
                .Append(docNo)
                .Append(".pdf")
                .ToString();
        }

        private String GetDocFilenameFromDocNo(IEnumerable<String> docNoList)
        {
            return String.Join(String.Empty, docNoList.Select(docNo => Regex.Replace(docNo, "[^a-zA-Z0-9 _]", "", RegexOptions.Compiled)));
        }

        public static FileInfo GenerateErrorInfoTextFile(Exception ex)
        {
            String errorMessage = ex.GetExceptionMessage();
            var errorTextFile = new FileInfo();
            errorTextFile.MimeType = CommonFormat.TxtMimeType;
            errorTextFile.Filename = "ErrorTextFile_" + DateTime.Now.ToString("ddMMyyyyHHmmss") + ".txt";
            errorTextFile.FileByteArray = Encoding.UTF8.GetBytes(errorMessage);

            return errorTextFile;
        }
    }
}