using System;
using System.Data;
using System.Data.SqlClient;
using GPS.Core.GPSLogService;
using GPS.Core.TDKSimplifier;
using Toyota.Common.Database;

namespace VMSAPDataImporterConsole
{
    class VMSAPImportDataRepository
    {
        private readonly ConnectionDescriptor cDesc;
        private readonly IDBContext db;
        private readonly ILogService logger;

        public VMSAPImportDataRepository(ILogService logger)
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

        public Int64 ImportInit(Int64 ProcessId, string what, string userid, string where, string id, string type, string module, string function, int status)
        {
            Int64 result = db.SingleOrDefault<Int64>("ImportInit", new { PROCESS_ID = ProcessId, what, userid, where, id, type, module, function, status});
            db.Close();

            return result;
        }

        public string SaveTemp(DataTable data)
        {
            logger.Info("Insert Data Vendor Master SAP Into Temporary Table Started");

            using (SqlConnection conn = new SqlConnection(cDesc.ConnectionString))
            {
                using (SqlBulkCopy sqlBulkCopy = new SqlBulkCopy(conn))
                {
                    conn.Open();

                    sqlBulkCopy.DestinationTableName = "TB_T_VENDOR_SAP";
                    try
                    {
                        sqlBulkCopy.ColumnMappings.Add("VENDOR_CD", "VENDOR_CD");
                        sqlBulkCopy.ColumnMappings.Add("VENDOR_NAME", "VENDOR_NAME");
                        sqlBulkCopy.ColumnMappings.Add("VENDOR_PLANT", "VENDOR_PLANT");
                        sqlBulkCopy.ColumnMappings.Add("SAP_VENDOR_ID", "SAP_VENDOR_ID");
                        sqlBulkCopy.ColumnMappings.Add("PAYMENT_METHOD_CD", "PAYMENT_METHOD_CD");
                        sqlBulkCopy.ColumnMappings.Add("PAYMENT_TERM_CD", "PAYMENT_TERM_CD");
                        sqlBulkCopy.ColumnMappings.Add("DELETION_FLAG", "DELETION_FLAG");
                        sqlBulkCopy.ColumnMappings.Add("VENDOR_ADDRESS", "VENDOR_ADDRESS");                                          
                        sqlBulkCopy.ColumnMappings.Add("POSTAL_CODE", "POSTAL_CODE");
                        sqlBulkCopy.ColumnMappings.Add("CITY", "CITY");
                        sqlBulkCopy.ColumnMappings.Add("ATTENTION", "ATTENTION");
                        sqlBulkCopy.ColumnMappings.Add("PHONE", "PHONE");
                        sqlBulkCopy.ColumnMappings.Add("FAX", "FAX");
                        sqlBulkCopy.ColumnMappings.Add("COUNTRY", "COUNTRY");
                        sqlBulkCopy.ColumnMappings.Add("EMAIL_ADDR", "EMAIL_ADDR");
                        sqlBulkCopy.ColumnMappings.Add("CREATED_BY", "CREATED_BY");
                        sqlBulkCopy.ColumnMappings.Add("CREATED_DT", "CREATED_DT");
                        sqlBulkCopy.ColumnMappings.Add("STATUS", "STATUS");

                        sqlBulkCopy.WriteToServer(data);
                        logger.Info("Insert Data Vendor Master SAP Into Temporary Table Finished Successfully");

                        conn.Close();
                        return "SUCCESS";
                    }
                    catch (Exception ex)
                    {
                        conn.Close();
                        return ex.Message;
                    }
                }
            }
        }

        public string SaveData(Int64 ProcessId)
        {
            string result = "";
            try
            {
                result = db.SingleOrDefault<string>("SaveData", new { PROCESS_ID = ProcessId });
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            finally
            {
                db.Close();
            }

            return result;
        }
    }
}

