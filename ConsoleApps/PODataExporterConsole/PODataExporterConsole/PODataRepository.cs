using System;
using System.Collections.Generic;
using GPS.Core.GPSLogService;
using GPS.Core.TDKSimplifier;
using Toyota.Common.Database;

namespace PODataExporter
{
    class PODataRepository
    {
        private readonly ConnectionDescriptor cDesc;
        private readonly IDBContext db;
        private readonly ILogService logger;

        public PODataRepository(ILogService logger)
        {
            cDesc = TDKConfig.GetConnectionDescriptor();
            var dbManager = new TDKDatabase(cDesc);
            db = dbManager.GetDefaultExecDbContext();
            this.logger = logger;
        }

        public IList<string> GetData()
        {
            var result = db.Fetch<String>("GetDataPO");
            db.Close();

            return result;
        }

        public String GetFtpCredential()
        {
            String result = db.SingleOrDefault<String>("GetFtpCredential");
            return result;
        }
    }
}
