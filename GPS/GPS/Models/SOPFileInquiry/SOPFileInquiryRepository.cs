using System;
using System.Collections.Generic;
using GPS.Core;
using GPS.Models.Common;
using GPS.ViewModels;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using System.Linq;

namespace GPS.Models.SOP
{
    public class SOPFileInquiryRepository
    {
        public const String DataName = "_Data";
        public sealed class SqlFile
        {
            public const String _Root_Folder_SOP = "SOPFileInquiry/";
            public const String GetListCount = _Root_Folder_SOP + "sp_SOPFileInquiry_GetListCount";
            public const String GetList = _Root_Folder_SOP + "sp_SOPFileInquiry_GetList";
            public const String GetModuleList = _Root_Folder_SOP + "sp_SOPFileInquiry_GetModuleList";
            public const String GetData = _Root_Folder_SOP + "sp_SOPFileInquiry_GetData";
            public const String SubmitSPO = _Root_Folder_SOP + "sp_SOPFileInquiry_SubmitSOP";
            public const String DeleteSPO = _Root_Folder_SOP + "sp_SOPFileInquiry_DeleteSOP";
        }

        private SOPFileInquiryRepository() { }
        private static SOPFileInquiryRepository instance = null;

        public static SOPFileInquiryRepository Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new SOPFileInquiryRepository();
                }
                return instance;
            }
        }

        public AttachmentFile GetFileData(string docId)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            var args = new { DOCID = docId };
            AttachmentFile result = db.SingleOrDefault<AttachmentFile>(SqlFile.GetData, args);
            db.Close();

            return result;
        }

        public List<NameValueItem> GetListModule()
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            IList<NameValueItem> result = db.Fetch<NameValueItem>(SqlFile.GetModuleList);
            db.Close();

            return result.ToList() ;
        }

        public PaginationViewModel GetListPaging(string module, int currentPage, int pageSize)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            var model = new PaginationViewModel();
            model.DataName = SOPFileInquiryRepository.DataName;
            model.TotalDataCount = db.SingleOrDefault<Int32>(SqlFile.GetListCount, new { Module = module });
            model.PageIndex = currentPage;
            model.PageSize = pageSize;

            db.Close();

            return model;
        }

        public List<AttachmentFile> GetList(string module, int currentPage, int pageSize)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            IList<AttachmentFile> result = db.Fetch<AttachmentFile>(SqlFile.GetList, new { Module = module, Start = currentPage, Length = pageSize });
            db.Close();

            return result.ToList();
        }

        public string SubmitSOP(AttachmentFile fileData)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            
            dynamic args = new
            {
                DOC_TYPE = fileData.DOC_TYPE,
                FILE_NAME = fileData.FILE_NAME,
                FILE_NAME_ORI = fileData.FILE_NAME_ORI,
                FILE_DESC = fileData.FILE_DESC,
                FILE_EXTENSION = fileData.FILE_EXTENSION,
                FILE_SIZE = fileData.FILE_SIZE,
                currentUser = fileData.CREATED_BY
            };
            String resultquery = db.SingleOrDefault<string>(SqlFile.SubmitSPO, args);
            db.Close();

            var resultViewModel = resultquery.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == Core.ViewModel.ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultquery;
        }

        public string DeleteSOP(string dOC_ID, string currentUser)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                DOCID = dOC_ID,
                currentUser
            };
            String resultquery = db.SingleOrDefault<string>(SqlFile.DeleteSPO, args);
            db.Close();

            var resultViewModel = resultquery.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == Core.ViewModel.ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultquery;
        }
    }
}