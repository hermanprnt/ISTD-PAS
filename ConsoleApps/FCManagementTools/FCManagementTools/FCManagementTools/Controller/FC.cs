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
using System.IO;
using FCManagementTools.Models;
using System.Xml.Linq;
using System.Web.Configuration;
using System.Xml.Serialization;
using System.Xml;
using System.Net;
using System.Data;

namespace FCManagementTools.Controller
{
    class FC
    {
        string ConnString = "FC";
        static string Dir = AppDomain.CurrentDomain.BaseDirectory;

        private FC() { }
        private static FC instance = null;
        public static FC Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = new FC();
                }
                return instance;
            }
        }

        #region Exec Fund Commitment
        public void ExecFundCommitment(string dirlog, string docType)
        {
            string AuthUser = "";//WebConfigurationManager.AppSettings["AuthUser"];
            string AuthPassword = "";//WebConfigurationManager.AppSettings["AuthPassword"];
            string isdummy = "";//WebConfigurationManager.AppSettings["IsDummy"];
            string WSUriDummy = WebConfigurationManager.AppSettings["WSUriDummy"];
            string WSUriProd = WebConfigurationManager.AppSettings["WSUriProd"];
            string url = "";//isdummy == "0" ? WSUriProd : WSUriDummy;

            if (docType == "PR" || docType == "PO")
            {
                AuthUser = LibraryRepo.Instance.GetSystemMasterById("FC", "PAS_USER");
                AuthPassword = LibraryRepo.Instance.GetSystemMasterById("FC", "PAS_PWD");
                url = LibraryRepo.Instance.GetSystemMasterById("FC", "PAS_URL");
            }
            else if (docType == "TP")
            {
                AuthUser = LibraryRepo.Instance.GetSystemMasterById("FC", "TRV_USER");
                AuthPassword = LibraryRepo.Instance.GetSystemMasterById("FC", "TRV_PWD");
                url = LibraryRepo.Instance.GetSystemMasterById("FC", "TRV_URL");
            }
            else if (docType == "PV")
            {
                AuthUser = LibraryRepo.Instance.GetSystemMasterById("FC", "ELV_USER");
                AuthPassword = LibraryRepo.Instance.GetSystemMasterById("FC", "ELV_PWD");
                url = LibraryRepo.Instance.GetSystemMasterById("FC", "ELV_URL");
            }

            Console.WriteLine("Get Data FC Management Tool..\n");
            LibraryRepo.GenerateLog("Get Data FC Management Tool..\n", dirlog);
            try
            {
                /*1. Get data header from TB_S_FUND_COMMITMENT with top maximum count*/
                List<DataHeader> Data = DataHeaderFC(docType);
                Console.WriteLine("Exec Management Tool per Doc No..\n");
                LibraryRepo.GenerateLog("Exec Management Tool per Doc No..\n", dirlog);
                if (Data.Count > 0)
                {
                    string Folder = WebConfigurationManager.AppSettings["LogDirDoc"];
                    string FileName = "LogFCManagement_" + Data.FirstOrDefault().PROCESS_ID;
                    foreach (var item in Data)
                    {
                        try
                        {
                            /*2. Generate XML file per item*/
                            LibraryRepo.GenerateLog("Generate XML Header No: " + item.HEADER_NO + "..\n", Folder + FileName);
                            XElement XML = GenerateXML(item);
                            string xml_param = "";
                            if (XML != null) xml_param = XML.ToString();

                            /*3. Send to Web Service*/
                            LibraryRepo.GenerateLog("Send Request Web Service Header No: " + item.HEADER_NO + "..\n", Folder + FileName);
                            MaintainFundCommitResp_MT response = RequestBasicAuthentication(url, AuthUser, AuthPassword, xml_param);
                            /*3. Bulk Insert and Update*/
                            LibraryRepo.GenerateLog("Bulk Insert and Update Header No: " + item.HEADER_NO + "..\n", Folder + FileName);
                            string ResultSave = SaveData(response.RESPONSE, item.DOCUMENT_TYPE, item.PROCESS_ID, item.HEADER_NO);
                            LibraryRepo.GenerateLog("Bulk Insert and Update Result: " + ResultSave + "..\n", Folder + FileName);
                        }
                        catch (Exception ex)
                        {
                            if (ex.InnerException != null)
                            {
                                if (ex.InnerException.InnerException != null)
                                {
                                    Console.WriteLine(ex.InnerException.InnerException);
                                    LibraryRepo.GenerateLog(ex.InnerException.InnerException.ToString(), Folder + FileName);
                                }
                                Console.WriteLine(ex.InnerException);
                                LibraryRepo.GenerateLog(ex.InnerException.ToString(), Folder + FileName);
                            }
                            else
                            {
                                Console.WriteLine(ex.Message);
                                LibraryRepo.GenerateLog(ex.Message.ToString(), Folder + FileName);
                            }
                            Environment.Exit(0);
                        }

                    }
                }
                else
                {
                    Console.WriteLine("No Data Found..\n");
                    LibraryRepo.GenerateLog("No Data Found..\n", dirlog);
                    Environment.Exit(0);
                }

            }
            catch (Exception ex)
            {

                if (ex.InnerException != null)
                {
                    if (ex.InnerException.InnerException != null)
                    {
                        Console.WriteLine(ex.InnerException.InnerException);
                        LibraryRepo.GenerateLog(ex.InnerException.InnerException.ToString(), dirlog);
                    }
                    Console.WriteLine(ex.InnerException);
                    LibraryRepo.GenerateLog(ex.InnerException.ToString(), dirlog);
                }
                else
                {
                    Console.WriteLine(ex.Message);
                    LibraryRepo.GenerateLog(ex.Message.ToString(), dirlog);
                }
                Environment.Exit(0);
            }

        }
        #endregion

        #region Get Data Header
        public List<DataHeader> DataHeaderFC(string docType)
        {
            string sql = "";
            sql = System.IO.File.ReadAllText(System.IO.Path.Combine(Dir + @"\Sql\GetHeaderFCRequest.sql"));
            using (var db = new Database(ConnString))
            {
                db.CommandTimeout = 0;
                db.EnableAutoSelect = false;
                List<DataHeader> result = db.Fetch<DataHeader>(sql, new {
                    DOC_TYPE = docType
                }).ToList();
                db.CloseSharedConnection();
                return result;
            }
        }
        #endregion

        #region Generate XML
        public XElement GenerateXML(DataHeader item)
        {
            string sql = "";
            List<DataRequest> result = new List<DataRequest>();
            sql = System.IO.File.ReadAllText(System.IO.Path.Combine(Dir + @"\Sql\GetDetailFCRequest.sql"));
            using (var db = new Database(ConnString))
            {
                db.CommandTimeout = 0;
                db.EnableAutoSelect = false;
                result = db.Fetch<DataRequest>(sql, new
                {
                    HEADER_NO = item.HEADER_NO,
                    PROCESS_ID = item.PROCESS_ID,
                    DOC_TYPE = item.DOCUMENT_TYPE,
                    DOC_NO = item.DOCUMENT_NO,
                    ACTION = item.ACTION
                });
                db.CloseSharedConnection();
            }
            string XE_item = WebConfigurationManager.AppSettings["item"];
            string XE_doc_type = WebConfigurationManager.AppSettings["doc_type"];
            string XE_action = WebConfigurationManager.AppSettings["action"];
            string XE_system = WebConfigurationManager.AppSettings["system"];
            string XE_test_run = WebConfigurationManager.AppSettings["test_run"];
            string XE_doc_no = WebConfigurationManager.AppSettings["doc_no"];
            string XE_closed = WebConfigurationManager.AppSettings["closed"];
            string XE_doc_date = WebConfigurationManager.AppSettings["doc_date"];
            string XE_submit_date = WebConfigurationManager.AppSettings["submit_date"];
            string XE_requestor = WebConfigurationManager.AppSettings["requestor"];
            string XE_company_code = WebConfigurationManager.AppSettings["company_code"];
            string XE_currency = WebConfigurationManager.AppSettings["currency"];
            string XE_currency_rate = WebConfigurationManager.AppSettings["currency_rate"];
            string XE_line_no = WebConfigurationManager.AppSettings["line_no"];
            string XE_closed2 = WebConfigurationManager.AppSettings["closed2"];
            string XE_ref_doc_no = WebConfigurationManager.AppSettings["ref_doc_no"];
            string XE_ref_doc_line_item_no = WebConfigurationManager.AppSettings["ref_doc_line_item_no"];
            string XE_item_code = WebConfigurationManager.AppSettings["item_code"];
            string XE_item_description = WebConfigurationManager.AppSettings["item_description"];
            string XE_part_category = WebConfigurationManager.AppSettings["part_category"];
            string XE_inventory_type = WebConfigurationManager.AppSettings["inventory_type"];
            string XE_material_type = WebConfigurationManager.AppSettings["material_type"];
            string XE_supplier_code = WebConfigurationManager.AppSettings["supplier_code"];
            string XE_asset = WebConfigurationManager.AppSettings["asset"];
            string XE_wbs_element = WebConfigurationManager.AppSettings["wbs_element"];
            string XE_cost_center_charger = WebConfigurationManager.AppSettings["cost_center_charger"];
            string XE_total_amount = WebConfigurationManager.AppSettings["total_amount"];
            string XE_quantity = WebConfigurationManager.AppSettings["quantity"];
            string XE_uom = WebConfigurationManager.AppSettings["uom"];
            string XE_journal_source = WebConfigurationManager.AppSettings["journal_source"];
            string XE_gl_account = WebConfigurationManager.AppSettings["gl_account"];

            string xmlns = LibraryRepo.Instance.GetSystemMasterById("FC", "WS_NAME_SPACE");//WebConfigurationManager.AppSettings["WSNamespace"];
            string prefix = LibraryRepo.Instance.GetSystemMasterById("FC", "WS_PREFIX"); //WebConfigurationManager.AppSettings["WSPrefix"];
            XNamespace aw = xmlns;
            XElement doc =
                new XElement(aw + "MaintainFundCommitReq_MT", new XAttribute(XNamespace.Xmlns + prefix, xmlns),
                new XElement(result.FirstOrDefault().H2,
                new XElement(result.FirstOrDefault().H3,
                     new XElement(XE_doc_type, item.DOCUMENT_TYPE),
                     new XElement(XE_action, item.ACTION),
                     new XElement(XE_system, item.SYSTEM),
                     new XElement(XE_test_run, item.TEST_RUN),
                     new XElement(XE_doc_no, item.DOCUMENT_NO),
                     new XElement(XE_closed, item.CLOSED),
                     new XElement(XE_doc_date, item.DOCUMENT_DT),
                     new XElement(XE_submit_date, item.SUBMIT_DT),
                     new XElement(XE_requestor, item.REQUESTOR),
                     new XElement(XE_company_code, item.COMPANY_CD),
                     new XElement(XE_currency, item.CURRENCY),
                     new XElement(XE_currency_rate, item.CURRENCY_RATE),
                     (
                        from items in result
                        select new XElement(XE_item,
                            new XElement(XE_line_no, items.LINE_NO),
                            new XElement(XE_closed2, items.CLOSED2),
                            new XElement(XE_ref_doc_no, items.REFERENCE_NO),
                            new XElement(XE_ref_doc_line_item_no, items.REFERENCE_LINE_NO),
                            new XElement(XE_item_code, items.ITEM_CD),
                            new XElement(XE_item_description, items.ITEM_DESCRIPTION),
                            new XElement(XE_part_category, items.PART_CATEGORY),
                            new XElement(XE_inventory_type, items.INVENTORY_TYPE),
                            new XElement(XE_material_type, items.MATERIAL_TYPE),
                            new XElement(XE_supplier_code, items.SUPPLIER_CD),
                            new XElement(XE_asset, items.ASSET_NO),
                            new XElement(XE_wbs_element, items.WBS_ELEMENT),
                            new XElement(XE_cost_center_charger, items.COST_CENTER_CD),
                            new XElement(XE_total_amount, items.TOTAL_AMOUNT),
                            new XElement(XE_quantity, items.QUANTITY),
                            new XElement(XE_uom, items.UOM),
                            new XElement(XE_journal_source, items.JOURNAL_SOURCE),
                            new XElement(XE_gl_account, items.GL_ACCOUNT)
                            )))));


            return doc;
        }
        #endregion

        #region Web Service and Get Response
        private MaintainFundCommitResp_MT RequestBasicAuthentication(string url, string username, string password, string parameter)
        {
            string credentials = Convert.ToBase64String(Encoding.ASCII.GetBytes(username + ":" + password));

            ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072;
            HttpWebRequest webRequest = (HttpWebRequest)WebRequest.Create(url);
            webRequest.Headers.Add("Authorization", string.Format("Basic {0}", credentials));
            webRequest.ContentType = "application/x-www-form-urlencoded";
            webRequest.Method = WebRequestMethods.Http.Post;
            webRequest.AllowAutoRedirect = true;
            webRequest.Proxy = null;

            string data = parameter;

            byte[] requestBytes = System.Text.Encoding.ASCII.GetBytes(data);
            webRequest.Method = "POST";
            webRequest.ContentType = "text/xml;charset=utf-8";
            webRequest.UserAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)";
            webRequest.ContentLength = requestBytes.Length;
            Stream requestStream = webRequest.GetRequestStream();
            requestStream.Write(requestBytes, 0, requestBytes.Length);
            requestStream.Close();

            HttpWebResponse res = (HttpWebResponse)webRequest.GetResponse();
            StreamReader sr = new StreamReader(res.GetResponseStream(), System.Text.Encoding.Default);
            string s = sr.ReadToEnd();

            sr.Close();
            res.Close();
            /* edit riani 
            var serializer = new XmlSerializer(typeof(MaintainFundCommitResp_MT));
            MaintainFundCommitResp_MT result;

            using (TextReader reader = new StringReader(s))
            {
                result = (MaintainFundCommitResp_MT)serializer.Deserialize(reader);
            }
            */
            string prefix = LibraryRepo.Instance.GetSystemMasterById("FC", "WS_PREFIX");
            string xmlns = LibraryRepo.Instance.GetSystemMasterById("FC", "WS_NAME_SPACE");
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(s);
            MaintainFundCommitResp_MT result = new MaintainFundCommitResp_MT();
            result.RESPONSE = new RESPONSE();
            result.RESPONSE.document = new List<document>();
            List<document> fullst = new List<document>();

            #region TDEM
            var nsmgr = new XmlNamespaceManager(doc.NameTable);
            nsmgr.AddNamespace(prefix, xmlns);

            XmlNodeList xnList = doc.SelectNodes("/" + prefix + ":MaintainFundCommitResp_MT", nsmgr);
            #endregion

            //XmlNodeList xnList = doc.GetElementsByTagName("MaintainFundCommitResp_MT");//doc.SelectNodes("/MaintainFundCommitResp_MT");

            foreach (XmlNode xn in xnList)
            {
                XmlNode anode = xn.FirstChild; //xn.SelectSingleNode("RESPONSE");
                if (anode != null)
                {
                    XmlNodeList CNodes = xn.FirstChild.ChildNodes; //xn.SelectNodes("RESPONSE/document");
                    foreach (XmlNode node in CNodes)
                    {
                        document lst = new document();

                        lst.doc_no = node["doc_no"].InnerText;
                        lst.doc_line_item_no = node["doc_line_item_no"].InnerText;
                        lst.fund_cmmt_doc = node["fund_cmmt_doc"].InnerText;
                        lst.fund_cmmt_doc_line_item = node["fund_cmmt_doc_line_item"].InnerText;
                        lst.msg_type = node["msg_type"].InnerText;
                        lst.msg_id = node["msg_id"].InnerText;
                        lst.msg_no = node["msg_no"].InnerText;
                        lst.msg = node["msg"].InnerText;

                        fullst.Add(lst);
                    }
                }
            }            
            result.RESPONSE.document = fullst;
            return result;
        }
        #endregion

        #region Save Data Bulk
        public string SaveData(RESPONSE data, string docType, string process_id, string header)
        {
            string system = "";
            if (docType == "PR" || docType == "PO")
                system = "FC";
            else if (docType == "TP")
                system = "TRAVEL";
            else if (docType == "PV")
                system = "ELVIS";

            string result = "";
            DataTable myDataTable = new DataTable();
            myDataTable.Columns.Add(new DataColumn("PROCESS_ID", typeof(long)));
            myDataTable.Columns.Add(new DataColumn("HEADER_NO", typeof(string)));
            myDataTable.Columns.Add(new DataColumn("DOCUMENT_NO", typeof(string)));
            myDataTable.Columns.Add(new DataColumn("ACTION", typeof(string)));
            myDataTable.Columns.Add(new DataColumn("DOCUMENT_LINE_ITEM_NO", typeof(string)));
            myDataTable.Columns.Add(new DataColumn("FUND_DOCUMENT_DOC_NO", typeof(string)));
            myDataTable.Columns.Add(new DataColumn("FUND_DOCUMENT_DOC_LINE_ITEM", typeof(string)));
            myDataTable.Columns.Add(new DataColumn("MESSAGE_TYPE", typeof(string)));
            myDataTable.Columns.Add(new DataColumn("MESSAGE_ID", typeof(string)));
            myDataTable.Columns.Add(new DataColumn("MESSAGE_NO", typeof(string)));
            myDataTable.Columns.Add(new DataColumn("MESSAGE_MESSAGE", typeof(string)));
            myDataTable.Columns.Add(new DataColumn("PROCESSED_BY", typeof(string)));
            myDataTable.Columns.Add(new DataColumn("PROCESSED_DT", typeof(DateTime)));
            myDataTable.Columns.Add(new DataColumn("DOC_TYPE", typeof(string)));
            myDataTable.Clone();
            foreach (var item in data.document)
            {
                DataRow row = myDataTable.NewRow();
                row["PROCESS_ID"] = process_id;
                row["HEADER_NO"] = header;
                row["DOCUMENT_NO"] = item.doc_no;
                row["ACTION"] = "";
                row["DOCUMENT_LINE_ITEM_NO"] = item.doc_line_item_no;
                row["FUND_DOCUMENT_DOC_NO"] = item.fund_cmmt_doc;
                row["FUND_DOCUMENT_DOC_LINE_ITEM"] = item.fund_cmmt_doc_line_item;
                row["MESSAGE_TYPE"] = item.msg_type;
                row["MESSAGE_ID"] = item.msg_id;
                row["MESSAGE_NO"] = item.msg_no;
                row["MESSAGE_MESSAGE"] = item.msg;
                row["PROCESSED_BY"] = DBNull.Value;
                row["PROCESSED_DT"] = DBNull.Value;
                row["DOC_TYPE"] = docType;
                myDataTable.Rows.Add(row);
            }

            string Error = "";
            #region old logic
            /*
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["FC"].ConnectionString))
            {
                conn.Open();
                try
                {
                    using (SqlCommand cmd = new SqlCommand("SP_MIGRATE_FUND_COMMITMENT"))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Connection = conn;
                        cmd.Parameters.AddWithValue("@TABLES", myDataTable);
                        SqlDataReader rdr = cmd.ExecuteReader();
                        while (rdr.Read())
                        {
                            Error = rdr.GetString(0);
                        }
                    }
                }
                catch (Exception ex)
                {
                    conn.Close();
                    result = result + " " + ex.Message;
                }
                conn.Close();
            }
            if (Error != "Y" && system != "FC" && system != "")
            {
                using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[system].ConnectionString))
                {
                    conn.Open();
                    try
                    {
                        using (SqlCommand cmd = new SqlCommand("SP_MIGRATE_FUND_COMMITMENT"))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Connection = conn;
                            cmd.Parameters.AddWithValue("@TABLES", myDataTable);
                            SqlDataReader rdr = cmd.ExecuteReader();
                            while (rdr.Read())
                            {
                                Error = rdr.GetString(0);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        conn.Close();
                        result = result + " " + ex.Message;
                    }
                    conn.Close();
                }
            }*/
            #endregion

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["FC"].ConnectionString))
            {
                conn.Open();
                try
                {
                    using (SqlCommand cmd = new SqlCommand("SP_MIGRATE_FUND_COMMITMENT"))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Connection = conn;
                        cmd.Parameters.AddWithValue("@TABLES", myDataTable);
                        cmd.Parameters.Add("@DOC_TYPE", SqlDbType.VarChar).Value = docType;
                        SqlDataReader rdr = cmd.ExecuteReader();
                        while (rdr.Read())
                        {
                            Error = rdr.GetString(0);
                        }
                    }
                }
                catch (Exception ex)
                {
                    conn.Close();
                    result = result + " " + ex.Message;
                }
                conn.Close();
            }

            if (docType == "TP" || docType == "PV")
            {
                using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings[system].ConnectionString))
                {
                    conn.Open();
                    try
                    {
                        using (SqlCommand cmd = new SqlCommand("SP_MIGRATE_FUND_COMMITMENT"))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Connection = conn;
                            cmd.Parameters.AddWithValue("@TABLES", myDataTable);
                            SqlDataReader rdr = cmd.ExecuteReader();
                            while (rdr.Read())
                            {
                                Error = rdr.GetString(0);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        conn.Close();
                        result = result + " " + ex.Message;
                    }
                    conn.Close();
                }
            }
            
            return result;
        }
        #endregion
    }
}