using System;
using System.Collections.Generic;
using GPS.Core.GPSLogService;
using GPS.Core.TDKSimplifier;
using Toyota.Common.Database;
using System.Data.SqlClient;

namespace MaterialPriceDataExporter
{
    class MaterialPriceDataRepository
    {
        private readonly ConnectionDescriptor cDesc;
        private readonly IDBContext db;
        private readonly ILogService logger;

        public MaterialPriceDataRepository(ILogService logger)
        {
            cDesc = TDKConfig.GetConnectionDescriptor();
            var dbManager = new TDKDatabase(cDesc);
            db = dbManager.GetDefaultExecDbContext();
            this.logger = logger;
        }

        public IList<string> GetData(string FunctionId, ref long processId)
        {
            var pOutput = new SqlParameter
            {
                ParameterName = "@Process_Id",
                DbType = System.Data.DbType.Int64,
                Direction = System.Data.ParameterDirection.Output
            };

            dynamic args = new
            {
                FunctionId = FunctionId,
                Process_Id = pOutput
            };

            var result = db.Fetch<String>("GetDataMaterialPrice", args);
            processId = Int64.Parse( pOutput.SqlValue.ToString());
            db.Close();

            return result;
        }

        public void DeleteLock(long processId)
        {
            dynamic args = new
            {
                PROCESS_ID = processId,
            };

            var result = db.Execute("DeleteLockData", args);
            db.Close();
        }

        public String GetFtpCredential()
        {
            String result = db.SingleOrDefault<String>("GetFtpCredential");
            return result;
        }
    }
}
