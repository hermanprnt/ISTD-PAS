using GPS.Core.GPSLogService;
using GPS.Core.TDKSimplifier;
using System;
using System.Collections.Generic;
using System.Linq;
using Toyota.Common.Database;

namespace BudgetDataImporter
{
    class BudgetImportDataRepository
    {
        private readonly IDBContext db;
        private readonly ILogService logger;

        public BudgetImportDataRepository(ILogService logger)
        {
            TDKDatabase dbManager = ObjectPool.Factory.GetInstance<TDKDatabase>();
            db = dbManager.GetDefaultExecDbContext();
            this.logger = logger;
        }

        public String GetFtpCredential()
        {
            String result = db.SingleOrDefault<String>("Importer/GetFtpCredential");
            return result;
        }

        public void SaveData(int ProcessId, Budget param)
        {
            dynamic args = new
            {
                param.WBS_NO,
                param.ORIGINAL_WBS_NO,
                param.WBS_YEAR,
                param.CURRENCY,
                param.INITIAL_AMOUNT,
                param.INITIAL_RATE,
                param.INITIAL_BUDGET,
                param.ADJUSTED_BUDGET,
                param.REMAINING_BUDGET_ACTUAL,
                param.REMAINING_BUDGET_INITIAL_RATE,
                param.BUDGET_CONSUME_GR_SA,
                param.BUDGET_CONSUME_INITIAL_RATE,
                param.BUDGET_COMMITMENT_INITIAL_RATE,
                param.BUDGET_COMMITMENT_PR_PO,
                PROCESS_ID = ProcessId
            };

            db.Execute("Importer/SaveData", args);
        }

        public int InsertLog(int PROCESS_ID, string MSG_TYPE, string LOCATION, string MSG)
        {
            dynamic args = new
            {
                PROCESS_ID,
                MSG_TYPE,
                LOCATION,
                MSG
            };

            int id = db.ExecuteScalar<int>("Importer/InsertLog", args);
            return id;
        }
    }
}
