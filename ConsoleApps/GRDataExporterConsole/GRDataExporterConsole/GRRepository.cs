using System;
using System.Collections.Generic;
using System.Net;
using GPS.Core;
using GPS.Core.TDKSimplifier;
using GPS.Core.ViewModel;
using Toyota.Common.Database;

namespace GRDataExporterConsole
{
    public class GRRepository
    {
        private readonly ConnectionDescriptor cDesc;
        private readonly IDBContext db;

        public GRRepository()
        {
            cDesc = TDKConfig.GetConnectionDescriptor();
            var dbManager = new TDKDatabase(cDesc);
            db = dbManager.GetDefaultExecDbContext();
        }

        public String GetNewProcessId(String actionName, String functionId)
        {
            String result = db.ExecuteScalar<String>("GetNewProcessId", new { ActionName = actionName, FunctionId = functionId });
            db.Close();

            return result;
        }

        public IList<String> GetData(String processId, String moduleId, String functionId)
        {
            var result = db.Fetch<String>("GetData", new { ProcessId = processId, ModuleId = moduleId, FunctionId = functionId });
            db.Close();

            return result;
        }

        public NetworkCredential GetFtpCredential()
        {
            var result = db.SingleOrDefault<String>("GetFtpCredential") ?? String.Empty;
            db.Close();

            String[] splittedResult = result.Split(';');

            if (splittedResult.Length < 2)
                throw new NullReferenceException("Bug: Ftp Credential is not set right.");

            String username = splittedResult[0];
            String password = splittedResult[1];

            return new NetworkCredential(username, password);
        }

        public String GetGRExportPath()
        {
            var result = db.SingleOrDefault<String>("GetGRExportPath");
            db.Close();

            return result;
        }

        public ActionResponseViewModel UpdateGRToPosting(String processId, String moduleId, String functionId)
        {
            String result = db.ExecuteScalar<String>("UpdateGRToPosting", new { ProcessId = processId, ModuleId = moduleId, FunctionId = functionId });
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }
    }
}