using GPS.CommonFunc;
using GPS.Core;
using GPS.Models.Common;
using GPS.Models.PR;
using GPS.Models.SOP;
using GPS.ViewModels.SOP;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers.SOP
{
    public class SOPFileInquiryController : PageController
    {
        public class Partial
        {
            public const String InquiryGrid = "_inquiryGrid";
            public const String InquiryGridBody = "_inquiryGridBody";
            public const String Script = "_inquirySOPFileScript";
        }

        public const String _SOPFileInquiryController = "/SOPFileInquiry/";
        public const String _Search = _SOPFileInquiryController + "Search";
        public const String _DownloadSOPDocument = _SOPFileInquiryController + "DownloadSOPDocument";
        public const String _UploadSPODocument = _SOPFileInquiryController + "UploadSOPDocument";
        public const String _DeleteSPODocument = _SOPFileInquiryController + "DeleteSOPDocument";


        protected override void Startup()
        {
            Settings.Title = "SOP Download Document";

            var viewModel = new SOPFileViewModel();
            viewModel.CurrentUser = this.GetCurrentUser();
            viewModel.DataList = new List<AttachmentFile>(SOPFileInquiryRepository.Instance.GetList("PR", 1, 10));
            viewModel.GridPaging = SOPFileInquiryRepository.Instance.GetListPaging("PR", 1, 10);

            Model = viewModel;
        }

        public ActionResult Search(string moduleId, int pageIndex, int pageSize)
        {
            try
            {
                var viewModel = new SOPFileViewModel();
                viewModel.CurrentUser = this.GetCurrentUser();
                viewModel.DataList = new List<AttachmentFile>(SOPFileInquiryRepository.Instance.GetList(moduleId, (((pageIndex - 1) * pageSize) + 1), (pageIndex * pageSize)));
                viewModel.GridPaging = SOPFileInquiryRepository.Instance.GetListPaging(moduleId, pageIndex, pageSize);
                return PartialView(Partial.InquiryGrid, viewModel);
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }

        public ActionResult UploadSOPDocument(HttpPostedFileBase file, string docType, string fileDesc)
        {
            try
            {
                if (file == null)
                {
                    throw new Exception("Invalid file : please choose a file, before uploaded data.");
                }

                string mainpath = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
                string fullpath = mainpath + SystemRepository.Instance.GetSystemValue("SOP_PATH");

                if (!Directory.Exists(fullpath))
                {
                    Directory.CreateDirectory(fullpath);
                }

                string filename = docType + "_" + DateTime.Now.ToString("ddMMyyyyHHmmssffff") + Path.GetExtension(file.FileName);
                fileDesc = Regex.Replace(fileDesc, @"\r\n?|\n", " ");

                var newpath = fullpath + filename;
                var fileData = new AttachmentFile() { DOC_TYPE = docType, FILE_NAME = filename, FILE_NAME_ORI = Path.GetFileName(file.FileName), FILE_EXTENSION = Path.GetExtension(file.FileName), FILE_DESC = fileDesc, FILE_SIZE = file.ContentLength, CREATED_BY = this.GetCurrentUsername()};
                SOPFileInquiryRepository.Instance.SubmitSOP(fileData);

                file.SaveAs(newpath);

                return new JsonResult() { Data = new { ResponseType = "S", Content = "" }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
            
            
        }

        public ActionResult DeleteSOPDocument(string DOC_ID)
        {
            var fileName = "";
            var isArchived = false;
            try
            {
                var attachData = SOPFileInquiryRepository.Instance.GetFileData(DOC_ID);

                if(attachData ==null)
                {
                    throw new Exception("Invalid file : cannot find spesific file with id "+ DOC_ID + ".");
                }

                var fileInfo = new FileInfo(attachData.FILE_NAME);
                fileName = attachData.FILE_NAME;

                ArchiveFile(fileInfo);
                isArchived = true;
                SOPFileInquiryRepository.Instance.DeleteSOP(DOC_ID, this.GetCurrentUsername());

                return new JsonResult() { Data = new { ResponseType = "S", Content = "" }, JsonRequestBehavior = JsonRequestBehavior.AllowGet };
            }
            catch (Exception ex)
            {
                if(fileName.Length>0 && isArchived)
                {
                    var fileInfo = new FileInfo(fileName);
                    RestoreArchiveFile(fileInfo);
                }
                
                return Json(ex.AsActionResponseViewModel());
            }
        }

        private static void ArchiveFile(FileInfo fileInfo)
        {
            string mainpath = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
            string fullpath = mainpath + SystemRepository.Instance.GetSystemValue("SOP_PATH") + "Archive\\";
            if (!Directory.Exists(fullpath))
            {
                Directory.CreateDirectory(fullpath);
            }

            fileInfo.CopyTo(fullpath+ fileInfo.Name);
            fileInfo.Delete();
        }

        private static void RestoreArchiveFile(FileInfo fileInfo)
        {
            string mainpath = SystemRepository.Instance.GetSystemValue("UPLOAD_FILE_PATH");
            string fullpath = mainpath + SystemRepository.Instance.GetSystemValue("SOP_PATH") + "Archive\\";

            var restoreFileInfo = new FileInfo(fullpath+ fileInfo.Name);
            restoreFileInfo.CopyTo(fileInfo.FullName);
            restoreFileInfo.Delete();
        }

        public FileResult DownloadSOPDocument(string DOC_ID)
        {
            try
            {
                var attachData = SOPFileInquiryRepository.Instance.GetFileData(DOC_ID);

                var fileInfo = new FileInfo(attachData.FILE_NAME);
                String mimeType = fileInfo.GetMimeType();
                Byte[] result = FileManager.ReadFile(fileInfo.DirectoryName, fileInfo.Name);
                return File(result, mimeType, attachData.FILE_NAME_ORI);
            }
            catch (Exception ex)
            {
                var errorFile = PdfFileCreator.GenerateErrorInfoTextFile(ex);
                return File(errorFile.FileByteArray, errorFile.MimeType, errorFile.Filename);
            }
        }

        public static SelectList GetModuleList()
        {
            return SOPFileInquiryRepository.Instance
                .GetListModule()
                .AsRawSelectList(item => item.Name , item => item.Value);
        }
    }
}