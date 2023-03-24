using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using GPS.Core.GPSLogService;
using GPS.Core.TDKSimplifier;
using Toyota.Common.Database;

namespace SAPDataImporterConsole
{
    class SAPImportDataRepository
    {
        private readonly ConnectionDescriptor cDesc;
        private readonly IDBContext db;
        private readonly ILogService logger;

        public SAPImportDataRepository(ILogService logger)
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

        public string SaveData(string type, DataTable data, Int64 ProcessId, string module, string function)
        {
            logger.Info("Insert Data " + type + " Into Temporary Table Started");

            using (SqlConnection conn = new SqlConnection(cDesc.ConnectionString))
            {
                using (SqlBulkCopy sqlBulkCopy = new SqlBulkCopy(conn))
                {
                    conn.Open();

                    SqlCommand sql = conn.CreateCommand();
                    sql.CommandText = @"IF OBJECT_ID('tempdb..#SAP_OUTPUT_TEMP') IS NOT NULL
	                                    DROP TABLE #SAP_OUTPUT_TEMP

                                        CREATE TABLE #SAP_OUTPUT_TEMP
	                                        (ID INT IDENTITY,
	                                         IS_DONE CHAR(1),
	                                         STATUS CHAR(1),
	                                         MESSAGE VARCHAR(MAX),
	                                         PO_NO VARCHAR(11),			--PO
	                                         SAP_PO_NO VARCHAR(11),		--PO
	                                         REF_DOC_NO VARCHAR(11),	--GR
	                                         MAT_DOC_NO VARCHAR(11),	--GR
	                                         DOC_YEAR VARCHAR(4),		--GR
	                                         PO_ITEM VARCHAR(5),		--GR
	                                         ENTRY_SHEET VARCHAR(11)	--SA
	                                    );  ";
                    sql.ExecuteNonQuery();

                    sqlBulkCopy.DestinationTableName = "#SAP_OUTPUT_TEMP";
                    try
                    {
                        sqlBulkCopy.ColumnMappings.Add("PO_NO", "PO_NO");
                        sqlBulkCopy.ColumnMappings.Add("SAP_PO_NO", "SAP_PO_NO");
                        sqlBulkCopy.ColumnMappings.Add("REF_DOC_NO", "REF_DOC_NO");
                        sqlBulkCopy.ColumnMappings.Add("MAT_DOC_NO", "MAT_DOC_NO");
                        sqlBulkCopy.ColumnMappings.Add("DOC_YEAR", "DOC_YEAR");
                        sqlBulkCopy.ColumnMappings.Add("PO_ITEM", "PO_ITEM");
                        sqlBulkCopy.ColumnMappings.Add("ENTRY_SHEET", "ENTRY_SHEET");
                        sqlBulkCopy.ColumnMappings.Add("STATUS", "STATUS");
                        sqlBulkCopy.ColumnMappings.Add("MESSAGE", "MESSAGE");
                        sqlBulkCopy.ColumnMappings.Add("IS_DONE", "IS_DONE");

                        sqlBulkCopy.WriteToServer(data);
                        logger.Info("Insert Data " + type + " Into Temporary Table Finished Successfully");
                        
                        UpdateData(conn, type, ProcessId, module, function);

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

        // Note : Not using tdk yet, because previous method using bulkinsert
        public void UpdateData(SqlConnection conn, string type, Int64 ProcessId, string module, string function)
        {
            logger.Info("Update Data " + type + " Started");
            
            SqlCommand sql = conn.CreateCommand();
            sql.CommandText = File.ReadAllText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"SQL\UpdateData.sql"));

            sql.Parameters.Add("@PROCESS_ID", SqlDbType.BigInt);
            sql.Parameters.Add("@TYPE", SqlDbType.NVarChar);
            sql.Parameters.Add("@FUNCTION", SqlDbType.NVarChar);
            sql.Parameters.Add("@MODULE", SqlDbType.NVarChar);

            sql.Parameters["@PROCESS_ID"].Value = ProcessId;
            sql.Parameters["@TYPE"].Value = type;
            sql.Parameters["@MODULE"].Value = module;
            sql.Parameters["@FUNCTION"].Value = function;

            sql.ExecuteNonQuery();
            logger.Info("Update Data " + type + " Finished Successfully");
        }
    }
}

