using System;
using System.Collections.Generic;
using System.Net;
using GPS.Core;
using GPS.Core.TDKSimplifier;
using GPS.Core.ViewModel;
using Toyota.Common.Database;

namespace SADataExporter
{
    public class SARepository
    {
        private readonly IDBContext db;

        public SARepository()
        {
            var connectionConfig = AppConfig.Get<ConnectionDescriptor>();
            var tdkdb = new TDKDatabase(connectionConfig);
            db = tdkdb.GetDefaultExecDbContext();
        }

        public IList<String> GetData()
        {
            var result = db.Fetch<String>("GetData");
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

        public String GetSAExportPath()
        {
            var result = db.SingleOrDefault<String>("GetSAExportPath");
            db.Close();

            return result;
        }

        public ActionResponseViewModel UpdateSAToPosting()
        {
            String result = db.ExecuteScalar<String>("UpdateSAToPosting");
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }
    }
}