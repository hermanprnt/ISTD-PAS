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
        private readonly RunnerInfo runnerInfo;

        public SARepository(RunnerInfo runnerInfo)
        {
            var connectionConfig = AppConfig.Get<ConnectionDescriptor>();

            if (connectionConfig.ConnectionString == null)
                connectionConfig.ConnectionString = "Server=DBSQL-DVQA-2012.toyota.co.id\\DBSQLDEVQA2012;Database=PAS_DB_QA;User ID=P4SS_D8_QA;Password=P4sS_d8_qa;Trusted_Connection=false;MultipleActiveResultSets=true;Max Pool Size=1000";

            if (connectionConfig.Name == null)
                connectionConfig.Name = "QA";

            if (!connectionConfig.IsDefault)
                connectionConfig.IsDefault = true;

            this.runnerInfo = runnerInfo;

            var tdkdb = new TDKDatabase(connectionConfig);
            db = tdkdb.GetDefaultExecDbContext();
        }

        public IList<String> GetData()
        {
            IList<String> result = db.Fetch<String>("GetData", this.runnerInfo);

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
            String result = db.ExecuteScalar<String>("UpdateSAToPosting", this.runnerInfo);
            db.Close();

            var resultViewModel = result.AsActionResponseViewModel();
            if (resultViewModel.ResponseType == ActionResponseViewModel.Error)
                throw new InvalidOperationException(resultViewModel.Message);

            return resultViewModel;
        }
    }
}