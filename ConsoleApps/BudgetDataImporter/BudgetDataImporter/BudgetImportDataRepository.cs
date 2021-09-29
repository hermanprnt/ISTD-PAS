using GPS.Core.GPSLogService;
using GPS.Core.TDKSimplifier;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Toyota.Common.Database;

namespace BudgetDataImporter
{
    class BudgetImportDataRepository
    {
        private readonly ConnectionDescriptor cDesc;
        private readonly IDBContext db;
        private readonly ILogService logger;

        public BudgetImportDataRepository(ILogService logger)
        {
            cDesc = TDKConfig.GetConnectionDescriptor();
            var dbManager = new TDKDatabase(cDesc);
            db = dbManager.GetDefaultExecDbContext();
            this.logger = logger;
        }

        public String GetFtpCredential()
        {
            String result = db.SingleOrDefault<String>("GetFtpCredential");
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
                param.WBS_DESCRIPTION,
                param.WBS_DIVISION,
                param.EOA_FLAG,
                param.WBS_LEVEL,
                PROCESS_ID = ProcessId
            };

            db.Execute("SaveData", args);
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

            int id = db.ExecuteScalar<int>("InsertLog", args);
            return id;
        }

        public String SendEmail(Int32 processId, String functionId, List<string> processResult)
        {
            StringBuilder str = new StringBuilder();
            string single_result = "";

            if (processResult.Count > 0)
            {
                str.Append("<p>The Following WBS No is Error, </p><br/><br/>");
                str.Append("<table border='1' style='border-collapse: collapse; padding: 2px'><tr><th style='width: 100px;'>WBS No</th><th>WBS Year</th><th>FileName</th><th>Error</th></tr>");
                //str.Append("<table border='1' style='border-collapse: collapse; padding: 1px'><tr><th>WBS No</th><th>FileName</th><th>Error</th></tr>");
                foreach (string s in processResult)
                {
                    string[] data = s.Split('|');

                    int indexFileName = data[0].IndexOf("BCTRL");
                    string fileName = data[0].Substring(indexFileName);


                    if (data.Length == 1)
                    {
                        single_result = data[0];
                        break;
                    }
                    else if (data.Length == 2)
                    {
                        str.Append("<tr>");
                        
                        str.Append("<td>" + data[1] + "</td>");
                        str.Append("<td>" + fileName + "</td>");
                        str.Append("<td></td>");
                        str.Append("<td></td>");
                        
                        str.Append("</tr>");
                    }
                    else if (data.Length > 2)
                    {
                        str.Append("<tr>");

                        str.Append("<td>" + data[1] + "</td>");
                        str.Append("<td>" + data[2] + "</td>");
                        str.Append("<td>" + fileName + "</td>");
                        str.Append("<td>" + data[3] + "</td>");
                        str.Append("</tr>");
                    }
                    else
                    {
                        str.Append("<tr>");
                        str.Append("<td></td>");
                        str.Append("<td></td>");
                        str.Append("<td></td>");
                        str.Append("<td>Undefined Line</td>");
                        str.Append("</tr>");
                    }
                }
                str.Append("</table>");

                if (single_result == "")
                {
                    single_result = str.ToString();
                }

                single_result = "ERROR|" + single_result;
                String result = db.ExecuteScalar<String>("SendEmail", new { ProcessId = processId, FunctionId = functionId, ProcessResult = single_result });
                return result;
            }
            else {
                single_result = "SUCCESS|Process Interface from SAP Successfully";
                return single_result;
            }
        }
    }
}
