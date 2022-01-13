using PetaPoco;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace PR_Creation_Call_WS.Models
{
    class LibraryRepo
    {
        string ConnString = "PAS";
        static string Dir = AppDomain.CurrentDomain.BaseDirectory;

        private LibraryRepo() { }
        private static LibraryRepo instance = null;
        public static LibraryRepo Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new LibraryRepo();
                }
                return instance;
            }
        }


        #region Get Message
        public MessageModel GetMessageById(string MsgId)
        {
            string sql = @"SELECT MESSAGE_ID as MsgId, MESSAGE_TEXT as MsgText, MESSAGE_TYPE as MsgType FROM TB_M_MESSAGE WHERE MESSAGE_ID = @MSG_ID";

            using (var db = new Database(ConnString))
            {
                db.CommandTimeout = 0;
                MessageModel result = db.SingleOrDefault<MessageModel>(sql, new
                {
                    MSG_ID = MsgId
                });
                db.CloseSharedConnection();
                return result;
            }


        }
        #endregion

        #region Generate Log
        public void GenerateLog(string PROCESS_ID,
            string MOD_ID,
            string FUNC_ID,
            string MSG_ID,
            string MSG_TEXT,
            string MSG_TYPE,
            string PROCESS_NM,
            int PROCESS_STATUS,
            string USER_ID)
        {
            string sql = @"EXEC [dbo].[SP_Generate_Log] 
			                            @PROCESS_ID,
			                            @MOD_ID,
			                            @FUNC_ID,
			                            @MSG_ID,
			                            @MSG_TEXT,
			                            @MSG_TYPE,
			                            @PROCESS_NM,
			                            @PROCESS_STATUS,
			                            @USER_ID";
            using (var db = new Database(ConnString))
            {
                db.CommandTimeout = 0;
                db.Execute(sql, new
                {
                    PROCESS_ID = PROCESS_ID,
                    MOD_ID = MOD_ID,
                    FUNC_ID = FUNC_ID,
                    MSG_ID = MSG_ID,
                    MSG_TEXT = MSG_TEXT,
                    MSG_TYPE = MSG_TYPE,
                    PROCESS_NM = PROCESS_NM,
                    PROCESS_STATUS = PROCESS_STATUS,
                    USER_ID = USER_ID
                });
                db.CloseSharedConnection();
            }
        }

        #endregion

        public List<item> GetParam(string ProcessId, string type)
        {
            string sql = "";
            if (type == "C")
            {
                sql = System.IO.File.ReadAllText(System.IO.Path.Combine(Dir + @"\Sql\GetParamCancel.sql"));
            }
            else if (type == "U")
            {
                sql = System.IO.File.ReadAllText(System.IO.Path.Combine(Dir + @"\Sql\GetParamUpdate.sql"));
            }
            else
            {
                sql = System.IO.File.ReadAllText(System.IO.Path.Combine(Dir + @"\Sql\GetParam.sql"));
            }

            using (var db = new Database(ConnString))
            {
                db.CommandTimeout = 0;
                List<item> result = db.Fetch<item>(sql, new
                {
                    ProcessId = ProcessId
                });
                db.CloseSharedConnection();
                return result;
            }
        }

        public string SaveToTemp(System.Data.DataTable data)
        {
            string result = "";
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["PAS"].ConnectionString))
            {
                using (SqlBulkCopy sqlBulkCopy = new SqlBulkCopy(conn))
                {
                    conn.Open();

                    sqlBulkCopy.DestinationTableName = "TB_H_FUND_COMMITMENT_RESPONSE";
                    try
                    {
                        sqlBulkCopy.ColumnMappings.Add("PROCESS_ID", "PROCESS_ID");
                        sqlBulkCopy.ColumnMappings.Add("ROW_NO", "ROW_NO");
                        sqlBulkCopy.ColumnMappings.Add("ACTION", "ACTION");
                        sqlBulkCopy.ColumnMappings.Add("DOCUMENT_NO", "DOCUMENT_NO");
                        sqlBulkCopy.ColumnMappings.Add("DOCUMENT_LINE_ITEM_NO", "DOCUMENT_LINE_ITEM_NO");
                        sqlBulkCopy.ColumnMappings.Add("FUND_DOCUMENT_DOC_NO", "FUND_DOCUMENT_DOC_NO");
                        sqlBulkCopy.ColumnMappings.Add("FUND_DOCUMENT_DOC_LINE_ITEM", "FUND_DOCUMENT_DOC_LINE_ITEM");
                        sqlBulkCopy.ColumnMappings.Add("MESSAGE_TYPE", "MESSAGE_TYPE");
                        sqlBulkCopy.ColumnMappings.Add("MESSAGE_ID", "MESSAGE_ID");
                        sqlBulkCopy.ColumnMappings.Add("MESSAGE_NO", "MESSAGE_NO");
                        sqlBulkCopy.ColumnMappings.Add("MESSAGE_MESSAGE", "MESSAGE_MESSAGE");
                        sqlBulkCopy.ColumnMappings.Add("PROCESSED_BY", "PROCESSED_BY");
                        sqlBulkCopy.ColumnMappings.Add("PROCESSED_DT", "PROCESSED_DT");

                        sqlBulkCopy.WriteToServer(data);

                        conn.Close();
                        result = "SUC";
                    }
                    catch (Exception ex)
                    {
                        if (ex.Message.Contains("Received an invalid column length from the bcp client for colid"))
                        {
                            string pattern = @"\d+";
                            Match match = Regex.Match(ex.Message.ToString(), pattern);
                            var index = Convert.ToInt32(match.Value) - 1;

                            FieldInfo fi = typeof(SqlBulkCopy).GetField("_sortedColumnMappings", BindingFlags.NonPublic | BindingFlags.Instance);
                            var sortedColumns = fi.GetValue(sqlBulkCopy);
                            var items = (Object[])sortedColumns.GetType().GetField("_items", BindingFlags.NonPublic | BindingFlags.Instance).GetValue(sortedColumns);

                            FieldInfo itemdata = items[index].GetType().GetField("_metadata", BindingFlags.NonPublic | BindingFlags.Instance);
                            var metadata = itemdata.GetValue(items[index]);

                            var column = metadata.GetType().GetField("column", BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance).GetValue(metadata);
                            var length = metadata.GetType().GetField("length", BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance).GetValue(metadata);

                            result = column.ToString() + " " + length.ToString();
                        }

                        conn.Close();
                        result = result + " " + ex.Message;
                    }
                }
            }
            return result;
        }

        public List<FCResponse> GetWSResponse(string ProcessId, string type)
        {
            string sql = "";
            if (type == "C")
            {
                sql = System.IO.File.ReadAllText(System.IO.Path.Combine(Dir + @"\Sql\GetResponseCancel.sql"));
            }
            else if (type == "U")
            {
                sql = System.IO.File.ReadAllText(System.IO.Path.Combine(Dir + @"\Sql\GetResponseUpdate.sql"));
            }
            else
            {
                sql = System.IO.File.ReadAllText(System.IO.Path.Combine(Dir + @"\Sql\GetResponse.sql"));
            }

            using (var db = new Database(ConnString))
            {
                db.CommandTimeout = 0;
                List<FCResponse> result = db.Fetch<FCResponse>(sql, new
                {
                    ProcessId = ProcessId
                });
                db.CloseSharedConnection();
                return result;
            }
        }

        public void UpdatePRData(string ProcessID, string Username, string type)
        {
            string sql = "";
            if (type == "C")
            {
                sql = System.IO.File.ReadAllText(System.IO.Path.Combine(Dir + @"\Sql\UpdatePRDataCancel.sql"));
            }
            else if (type == "U")
            {
                sql = System.IO.File.ReadAllText(System.IO.Path.Combine(Dir + @"\Sql\UpdatePRDataUpdate.sql"));
            }
            else
            {
                sql = System.IO.File.ReadAllText(System.IO.Path.Combine(Dir + @"\Sql\UpdatePRData.sql"));
            }

            using (var db = new Database(ConnString))
            {
                db.CommandTimeout = 0;
                string res = db.ExecuteScalar<string>(sql, new
                {
                    ProcessID,
                    Username
                });
                db.CloseSharedConnection();
            }

        }

        public void Rollback(string PROCESS_ID,
            string DIVISION,
            string PR_NO,
            string PR_DESC,
            string USER_ID,
            string PROCESS_TYPE,
            string ROW_ROLLBACK,
            string TriggerType,
            string from)
        {
            string sql = "";

            if (from == "PR")
            {
                sql = @"EXEC [dbo].[sp_prcreation_budgetProcessing] 
			                            @PROCESS_ID,
			                            @DIVISION,
			                            @PR_NO,
			                            @PR_DESC,
			                            @USER_ID,
			                            @PROCESS_TYPE,
			                            @ROW_ROLLBACK,
			                            @TriggerType";
            }
            else
            {
                sql = @"EXEC [dbo].[sp_prcreation_budgetProcessingFromWO] 
			                            @PROCESS_ID,
			                            @DIVISION,
			                            @PR_NO,
			                            @PR_DESC,
			                            @USER_ID,
			                            @PROCESS_TYPE,
			                            @ROW_ROLLBACK,
			                            @TriggerType";
            }


            using (var db = new Database(ConnString))
            {
                db.CommandTimeout = 0;
                db.Execute(sql, new
                {
                    PROCESS_ID = PROCESS_ID,
                    DIVISION = DIVISION,
                    PR_NO = PR_NO,
                    PR_DESC = PR_DESC,
                    USER_ID = USER_ID,
                    PROCESS_TYPE = PROCESS_TYPE,
                    ROW_ROLLBACK = ROW_ROLLBACK,
                    TriggerType = TriggerType
                });
                db.CloseSharedConnection();
            }
        }

    }
}
