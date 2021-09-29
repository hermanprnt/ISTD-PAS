using System;
using System.Collections.Generic;
using GPS.Constants;
using GPS.Constants.MRP;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models.Common;
using GPS.ViewModels.MRP;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.Models.MRP
{
    public class MRPCreationRepository
    {
        private MRPCreationRepository() { }
        private static readonly MRPCreationRepository instance = null;
        public static MRPCreationRepository Instance
        {
            get { return instance ?? new MRPCreationRepository(); }
        }

        public String Initial(String currentUser)
        {
            var execParam = new ExecProcedureModel();
            execParam.CurrentUser = currentUser;
            execParam.ModuleId = ModuleId.MRP;
            execParam.FunctionId = FunctionId.MRPExecution;

            IDBContext db = DatabaseManager.Instance.GetContext();
            ExecProcedureResultModel result = db.SingleOrDefault<ExecProcedureResultModel>(MRPSqlFile.CreationInitial, execParam);
            db.Close();

            var resultViewModel = result.Message.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return result.ProcessId;
        }

        public LastMRPInfo GetLastMRPInfo(String procUsageGroup)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            LastMRPInfo result = db.SingleOrDefault<LastMRPInfo>(MRPSqlFile.CreationGetLastMRPInfo, new { ProcUsageGroup = procUsageGroup });
            db.Close();

            return result;
        }

        public void PutMRPProcessToQueue(MRPProcessViewModel viewModel)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            var args = new
            {
                viewModel.ProcessId,
                Parameter = String.Format("{0}|{1}|{2}|{3}|{4}|{5}", viewModel.CurrentUser, viewModel.ProcessId,
                    ModuleId.MRP, FunctionId.MRPExecution, viewModel.ProcUsageGroup, viewModel.MRPMonth),
                MRPType = viewModel.ProcessType,
                viewModel.CurrentUser
            };
            
            db.Execute(MRPSqlFile.CreationPutMRPProcessToQueue, args);
            db.Close();
        }


        public int CountData(string ProcUsage)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                ProcUsage = ProcUsage
            };

            int result = db.SingleOrDefault<int>("MRP/Creation/CountData", args);
            db.Close();

            return result;
        }

        public IEnumerable<MRPCreation> GetListData( int start, int length)
        {
            IDBContext db = DatabaseManager.Instance.GetContext();
            dynamic args = new
            {
                start = start,
                length = length
            };

            IEnumerable<MRPCreation> result = db.Fetch<MRPCreation>("MRP/Creation/GetData", args);
            db.Close();
            return result;
        }


    }
}