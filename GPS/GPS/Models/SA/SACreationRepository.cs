using System;
using System.Collections.Generic;
using GPS.CommonFunc;
using GPS.Models.Common;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;
using GPS.ViewModels.SA;

namespace GPS.Models.MRP
{
    public class SACreationRepository
    {
        private SACreationRepository() { }
        private static SACreationRepository instance = null;
        public static SACreationRepository Instance
        {
            get { return instance ?? (instance = new SACreationRepository()); }
        }

        public string CheckPO(string PO, string REFF)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                PO = PO,
                REFF = REFF
            };
            string result = db.SingleOrDefault<string>("SA/CheckPO", args);
            db.Close();
            return result;
        }
        public List<SACreation> GetDataPObyReff(string REFF)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                REFF = REFF
            };

            List<SACreation> result = db.Fetch<SACreation>("SA/GetDataPObyREFF", args);
            db.Close();
            return result;
        }
        public string GetDataREFF(string REFF)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                REFF = REFF
            };

            string result = db.Fetch<string>("SA/GetDataRef", args);
            db.Close();
            return result;
        }

        public String Submit(ExecProcedureModel execModel, SASubmitViewModel viewModel)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                execModel.CurrentUser,
                execModel.ProcessId,
                execModel.ModuleId,
                execModel.FunctionId,
                SAList = viewModel.SAList
                    .AsDelimitedString(
                        sa => sa.PONo,
                        sa => sa.POItemNo,
                        sa => sa.POSubItemNo,
                        sa => sa.Qty),
                viewModel.SADocNo,
                viewModel.PostingDate,
                viewModel.ShortText
            };

            String query = "EXEC sp_GoodReceive_CreateSA @CurrentUser, @ProcessId, @ModuleId, @FunctionId, @SAList, @SADocNo, @PostingDate, @ShortText";
            String result = db.SingleOrDefault<String>(query, args);
            db.Close();

            return result;
        }

        public List<SACreation> GetDataPO(string PO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                PO = PO
            };

            List<SACreation> result = db.Fetch<SACreation>("SA/GetDataPO", args);
            db.Close();
            return result;
        }
        public IEnumerable<SACreation> GetDetailData(string PO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                 PO = PO
            };

            IEnumerable<SACreation> result = db.Fetch<SACreation>("SA/GetDetailPO", args);
            db.Close();
            return result;
        }

        public IEnumerable<SACreation> GetPOItem(string PO)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();

            dynamic args = new
            {
                PO = PO
            };

            IEnumerable<SACreation> result = db.Fetch<SACreation>("SA/GetPOItem", args);
            db.Close();
            return result;
        }

        public IEnumerable<SACreation> GetPOSubItem(String poNo, String poItemNo, String dataName)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                PO = poNo,
                ITEM_NO = poItemNo
            };

            IEnumerable<SACreation> result = db.Fetch<SACreation>("SA/GetSubItem", args);
            foreach (SACreation subItem in result)
                subItem.DataName = dataName;

            db.Close();
            return result;
        }

    }
}