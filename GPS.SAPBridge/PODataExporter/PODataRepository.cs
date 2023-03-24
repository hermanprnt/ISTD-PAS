using System;
using System.Collections.Generic;
using GPS.Core.TDKSimplifier;
using GPS.Core.ViewModel;
using Toyota.Common.Database;

namespace PODataExporter
{
    class PODataRepository
    {
        private readonly IDBContext db;

        public PODataRepository()
        {
            TDKDatabase dbManager = ObjectPool.Factory.GetInstance<TDKDatabase>();
            db = dbManager.GetDefaultExecDbContext();
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
