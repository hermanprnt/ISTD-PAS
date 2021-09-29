using PetaPoco;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PAS_Interface_Indirect_Material.Models
{
    class LibraryRepo
    {
        string ConnString = "PAS_Interface_Indirect_Material.Properties.Settings.ConnectionString";
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

        #region Param H
        public List<SapParamH> GetParamH()
        {
            string sql = @"SELECT 
                                JOURNAL_NO
                        FROM TB_R_JOURNAL
                        WHERE MOV_TYPE IN (
		                    '101'
		                    ,'102'
		                    )
	                    AND DOC_TP = 'GR'
	                    AND POSTING_CD = 'N'";

            using (var db = new Database(ConnString))
            {
                db.CommandTimeout = 0;
                List<SapParamH> result = db.Fetch<SapParamH>(sql, new { });
                db.CloseSharedConnection();
                return result;
            }
        }
        #endregion

        #region Update
        public void UpdateSequence()
        {
            string sql = System.IO.File.ReadAllText(System.IO.Path.Combine(Dir + @"\Sql\UpdateSequence.sql"));
            using (var db = new Database(ConnString))
            {
                db.CommandTimeout = 0;
                string res = db.ExecuteScalar<string>(sql, new
                {
                });
                db.CloseSharedConnection();
            }

        }

        public void UpdateFileName(string filename)
        {
            string sql = System.IO.File.ReadAllText(System.IO.Path.Combine(Dir + @"\Sql\UpdateFileName.sql"));
            using (var db = new Database(ConnString))
            {
                db.CommandTimeout = 0;
                string res = db.ExecuteScalar<string>(sql, new
                {
                    filename = filename
                });
                db.CloseSharedConnection();
            }

        }

        #endregion


        #region Get System Master
        public List<SystemMasterModel> GetSystemMaster(string Type, string Code = "")
        {
            string sql = @"SELECT SYSTEM_CD, SYSTEM_VALUE, SYSTEM_REMARK FROM TB_M_SYSTEM WHERE FUNCTION_ID = @Type";
            List<SystemMasterModel> result;

            if (!string.IsNullOrEmpty(Code))
                sql = @"SELECT SYSTEM_CD, SYSTEM_VALUE, SYSTEM_REMARK FROM TB_M_SYSTEM WHERE FUNCTION_ID = @Type AND SYSTEM_CD = @Code";

            using (var db = new Database(ConnString))
            {
                db.CommandTimeout = 0;
                result = db.Fetch<SystemMasterModel>(sql, new
                {
                    Type = Type
                    , Code = Code
                });
                db.CloseSharedConnection();
                return result;
            }
        }
        #endregion

        #region Get Process Id
        public string GetProcessID()
        {
            string sql = @"SELECT dbo.fn_get_last_process_id() AS PROCESS_ID";
            using (var db = new Database(ConnString))
            {
                db.CommandTimeout = 0;
                string result = db.SingleOrDefault<string>(sql, new { });
                db.CloseSharedConnection();
                return result;
            }
        }
        #endregion

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
                db.Execute(sql, new {
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
    }
}
