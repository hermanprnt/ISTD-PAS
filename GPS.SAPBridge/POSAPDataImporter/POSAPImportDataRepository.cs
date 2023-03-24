using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using GPS.Core.GPSLogService;
using GPS.Core.TDKSimplifier;
using Toyota.Common.Configuration;
using Toyota.Common.Database;

namespace POSAPDataImporter
{
    class POSAPImportDataRepository
    {
        private readonly IDBContext db;
        private readonly ILogService logger;

        public POSAPImportDataRepository(ILogService logger)
        {
            TDKDatabase dbManager = ObjectPool.Factory.GetInstance<TDKDatabase>();
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
            logger.Info("Insert Data PO SAP Into Temporary Table Started");

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["DB"].ConnectionString))
            {
                using (SqlBulkCopy sqlBulkCopy = new SqlBulkCopy(conn))
                {
                    conn.Open();

                    sqlBulkCopy.DestinationTableName = "TB_T_SAP_PO";
                    try
                    {
                        sqlBulkCopy.ColumnMappings.Add("PO_NO", "PO_NO");
                        sqlBulkCopy.ColumnMappings.Add("PO_ITEM_NO", "PO_ITEM_NO");
                        sqlBulkCopy.ColumnMappings.Add("FILE_NO", "FILE_NO");
                        sqlBulkCopy.ColumnMappings.Add("SEQ_NO", "SEQ_NO");
                        sqlBulkCopy.ColumnMappings.Add("VENDOR_CD", "VENDOR_CD");
                        sqlBulkCopy.ColumnMappings.Add("VENDOR_NAME", "VENDOR_NAME");
                        sqlBulkCopy.ColumnMappings.Add("VENDOR_ADDR", "VENDOR_ADDR");
                        sqlBulkCopy.ColumnMappings.Add("VENDOR_POSTAL", "VENDOR_POSTAL");
                        sqlBulkCopy.ColumnMappings.Add("VENDOR_CITY", "VENDOR_CITY");
                        sqlBulkCopy.ColumnMappings.Add("VENDOR_ATTENTION", "VENDOR_ATTENTION");
                        sqlBulkCopy.ColumnMappings.Add("VENDOR_TELP", "VENDOR_TELP");
                        sqlBulkCopy.ColumnMappings.Add("VENDOR_FAX", "VENDOR_FAX");
                        sqlBulkCopy.ColumnMappings.Add("VENDOR_COUNTRY_ID", "VENDOR_COUNTRY_ID");
                        sqlBulkCopy.ColumnMappings.Add("DLV_NAME", "DLV_NAME");
                        sqlBulkCopy.ColumnMappings.Add("DLV_ADDR", "DLV_ADDR");
                        sqlBulkCopy.ColumnMappings.Add("DLV_POSTAL", "DLV_POSTAL");
                        sqlBulkCopy.ColumnMappings.Add("DLV_CITY", "DLV_CITY");
                        sqlBulkCopy.ColumnMappings.Add("CONTACT_PER", "CONTACT_PER");
                        sqlBulkCopy.ColumnMappings.Add("PO_DATE", "PO_DATE");
                        sqlBulkCopy.ColumnMappings.Add("PO_PAYMENT_TERM", "PO_PAYMENT_TERM");
                        sqlBulkCopy.ColumnMappings.Add("PO_TYPE", "PO_TYPE");
                        sqlBulkCopy.ColumnMappings.Add("PO_CAT", "PO_CAT");
                        sqlBulkCopy.ColumnMappings.Add("PURCH_GROUP", "PURCH_GROUP");
                        sqlBulkCopy.ColumnMappings.Add("CURR_CD", "CURR_CD");
                        sqlBulkCopy.ColumnMappings.Add("AMOUNT", "AMOUNT");
                        sqlBulkCopy.ColumnMappings.Add("EXCHANGE_RATE", "EXCHANGE_RATE");
                        sqlBulkCopy.ColumnMappings.Add("DELETION_FLAG", "DELETION_FLAG");
                        sqlBulkCopy.ColumnMappings.Add("INCOTERM1", "INCOTERM1");
                        sqlBulkCopy.ColumnMappings.Add("INCOTERM2", "INCOTERM2");
                        sqlBulkCopy.ColumnMappings.Add("INVOICE_FLAG", "INVOICE_FLAG");

                        sqlBulkCopy.ColumnMappings.Add("PR_NO", "PR_NO");
                        sqlBulkCopy.ColumnMappings.Add("PR_ITEM_NO", "PR_ITEM_NO");
                        sqlBulkCopy.ColumnMappings.Add("MAT_NO", "MAT_NO");
                        sqlBulkCopy.ColumnMappings.Add("MAT_DESC", "MAT_DESC");
                        sqlBulkCopy.ColumnMappings.Add("MAT_GRP", "MAT_GRP");
                        sqlBulkCopy.ColumnMappings.Add("VAL_CLASS", "VAL_CLASS");
                        sqlBulkCopy.ColumnMappings.Add("DELIVERY_PLAN_DT", "DELIVERY_PLAN_DT");
                        sqlBulkCopy.ColumnMappings.Add("PLANT_CD", "PLANT_CD");
                        sqlBulkCopy.ColumnMappings.Add("SLOC_CD", "SLOC_CD");
                        sqlBulkCopy.ColumnMappings.Add("WBS_NO", "WBS_NO");
                        sqlBulkCopy.ColumnMappings.Add("COST_CENTER", "COST_CENTER");
                        sqlBulkCopy.ColumnMappings.Add("GL_ACCOUNT", "GL_ACCOUNT");
                        sqlBulkCopy.ColumnMappings.Add("ORI_QTY", "ORI_QTY");
                        sqlBulkCopy.ColumnMappings.Add("NEW_QTY", "NEW_QTY");
                        sqlBulkCopy.ColumnMappings.Add("USED_QTY", "USED_QTY");
                        sqlBulkCopy.ColumnMappings.Add("UOM_CD", "UOM_CD");
                        sqlBulkCopy.ColumnMappings.Add("PRICE_PER_UOM", "PRICE_PER_UOM");
                        sqlBulkCopy.ColumnMappings.Add("ITEM_DELETION_FLAG", "ITEM_DELETION_FLAG");
                        sqlBulkCopy.ColumnMappings.Add("TAX_CD", "TAX_CD");
                        sqlBulkCopy.ColumnMappings.Add("COMP_CD", "COMP_CD");
                        sqlBulkCopy.ColumnMappings.Add("COMP_RATE", "COMP_RATE");

                        sqlBulkCopy.ColumnMappings.Add("SERV_ITEM", "SERV_ITEM");
                        sqlBulkCopy.ColumnMappings.Add("SERV_TEXT", "SERV_TEXT");
                        sqlBulkCopy.ColumnMappings.Add("SERV_UNIT", "SERV_UNIT");
                        sqlBulkCopy.ColumnMappings.Add("SERV_QTY", "SERV_QTY");
                        sqlBulkCopy.ColumnMappings.Add("SERV_GPRICE", "SERV_GPRICE");
                        sqlBulkCopy.ColumnMappings.Add("LINE_NO", "LINE_NO");
                        sqlBulkCopy.ColumnMappings.Add("LINE_TEXT", "LINE_TEXT");
                        sqlBulkCopy.ColumnMappings.Add("OUT_TYPE", "OUT_TYPE");
                        sqlBulkCopy.ColumnMappings.Add("OUT_MESSAGE", "OUT_MESSAGE");
                        sqlBulkCopy.ColumnMappings.Add("CREATED_BY", "CREATED_BY");
                        sqlBulkCopy.ColumnMappings.Add("CREATED_DT", "CREATED_DT");
                        sqlBulkCopy.ColumnMappings.Add("CHANGED_BY", "CHANGED_BY");
                        sqlBulkCopy.ColumnMappings.Add("CHANGED_DT", "CHANGED_DT");

                        sqlBulkCopy.WriteToServer(data);
                        logger.Info("Insert Data PO SAP Into Temporary Table Finished Successfully");

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

