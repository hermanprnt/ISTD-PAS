using PR_Creation_Call_WS.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web.Configuration;
using System.Xml;
using System.Xml.Serialization;

namespace PR_Creation_Call_WS
{
    class Program
    {
        static MessageModel Msg = new MessageModel();
        static string ModId = "2";
        static string FuncId = "201002";
        static string ProcessName = "PR Call WS";

        static void Main(string[] args)
        {
            //args = new String[] { "PR|202105280001|0|5000000155|teset|agan" };

            Console.WriteLine("Starting ...");
            Console.WriteLine("Get argument");

            if (args.Length == 0)
            {
                Console.WriteLine("Invalid Parameter length");
                Environment.Exit(0);
            }

            String paramAll = args[0];
            bool isErr = false;

            string type = paramAll.Split('|')[0];
            string ProcessId = paramAll.Split('|')[1];
            string Division = paramAll.Split('|')[2];
            string PRNo = paramAll.Split('|')[3];
            string PRDesc = paramAll.Split('|')[4];
            string Username = paramAll.Split('|')[5];

            try
            {
                Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                Msg.MsgText = string.Format(Msg.MsgText, "PR Call WS Fund Commitment Console");
                LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                Console.WriteLine("Get Data");
                Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                Msg.MsgText = string.Format(Msg.MsgText, "Get Data for parameter");
                LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                List<Lookby> MainLoopby = LibraryRepo.Instance.GetLoopBy(ProcessId);

                List<MaintainFundCommitReq_MT> ReqHeader = new List<MaintainFundCommitReq_MT>();
                PAS_Document ReqDocument = new PAS_Document();
                List<item> MainRequest = new List<item>(); 

                if (MainLoopby.Count == 0)
                {
                    Msg = LibraryRepo.Instance.GetMessageById("ERR00007");
                    Msg.MsgText = string.Format(Msg.MsgText, "Request Table");
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                    Console.WriteLine(Msg.MsgText);

                    Environment.Exit(0);
                }

                foreach (var xx in MainLoopby)
                {
                    MainRequest = LibraryRepo.Instance.GetParam(xx);

                    #region Insert
                    if (MainRequest.Count > 0)
                    {
                        Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                        Msg.MsgText = string.Format(Msg.MsgText, xx.Variable + " data to SAP");
                        LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                        var DistinctH = MainRequest.GroupBy(x => x.doc_no).Select(c => new PAS_Header
                        {
                            doc_type = c.First().doc_type,
                            action = c.First().action,
                            system = c.First().system,
                            test_run = c.First().test_run,
                            doc_no = c.First().doc_no,
                            closed = c.First().closed,
                            doc_date = c.First().doc_date,
                            submit_date = c.First().submit_date,
                            requestor = c.First().requestor,
                            company_code = c.First().company_code,
                            currency = c.First().currency,
                            currency_rate = c.First().currency_rate
                        }).ToList();

                        foreach (var h in DistinctH)
                        {
                            MaintainFundCommitReq_MT tempM = new MaintainFundCommitReq_MT();
                            PAS_Header tempH = new PAS_Header();

                            tempH.doc_type = h.doc_type;
                            tempH.action = h.action;
                            tempH.system = h.system;
                            tempH.test_run = h.test_run;
                            tempH.doc_no = h.doc_no;
                            tempH.closed = h.closed;
                            tempH.doc_date = h.doc_date;
                            tempH.submit_date = h.submit_date;
                            tempH.requestor = h.requestor;
                            tempH.company_code = h.company_code;
                            tempH.currency = h.currency;
                            tempH.currency_rate = h.currency_rate;

                            tempH.item = MainRequest.Where(x => x.doc_no == h.doc_no).ToList();

                            ReqDocument.document = tempH;

                            tempM.REQUEST = ReqDocument;

                            ReqHeader.Add(tempM);
                        }

                        MaintainFundCommitReq_MT responses = new MaintainFundCommitReq_MT();
                        responses.REQUEST = ReqHeader[0].REQUEST;
                        MemoryStream Stream = new MemoryStream();
                        Type tp = typeof(MaintainFundCommitReq_MT);
                        XmlSerializer xml = new XmlSerializer(tp);

                        //string WSPrefix = WebConfigurationManager.AppSettings["WSPrefix"].ToString();
                        //string WSNamespace = WebConfigurationManager.AppSettings["WSNamespace"].ToString();

                        string WSPrefix = LibraryRepo.Instance.GetSystemMasterById("FC", "WS_PREFIX");
                        string WSNamespace = LibraryRepo.Instance.GetSystemMasterById("FC", "WS_NAME_SPACE");

                        XmlSerializerNamespaces xmlNameSpace = new XmlSerializerNamespaces();
                        xmlNameSpace.Add(WSPrefix, WSNamespace);

                        try
                        {
                            xml.Serialize(Stream, responses, xmlNameSpace);
                        }
                        catch (Exception ex)
                        {
                            Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                            Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString(ex.Message) + "--" + Convert.ToString(ex.InnerException));
                            LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                            Console.WriteLine(Msg.MsgText);

                            Console.WriteLine("Error: " + ex.Message);

                            Console.WriteLine("End Process ...");
                            Environment.Exit(0);
                        }

                        Stream.Position = 0;
                        StreamReader sr = new StreamReader(Stream);
                        string str = sr.ReadToEnd();
                        str = str.Replace("_x003A_", ":");

                        sr.Dispose();
                        Stream.Dispose();

                        //string str = MainRequest[0].retXML;

                        Console.WriteLine("Call Web Service Fund Commitment");
                        Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                        Msg.MsgText = string.Format(Msg.MsgText, "Call Web Service Fund Commitment");
                        LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                        var NewResponse = WebAPIUtil.XMLRequest(ProcessId, str, "POST");

                        if (NewResponse.Count == 0)
                        {
                            Msg = LibraryRepo.Instance.GetMessageById("ERR00007");
                            Msg.MsgText = string.Format(Msg.MsgText, "Response data");
                            LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                            Console.WriteLine(Msg.MsgText);

                            Environment.Exit(0);
                        }

                        Console.WriteLine("Retrieve Fund Commitment Response");
                        Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                        Msg.MsgText = string.Format(Msg.MsgText, "Retrieve Fund Commitment Response");
                        LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                        #region Create Data Table
                        System.Data.DataTable table = new System.Data.DataTable();

                        table.Columns.Add("PROCESS_ID");
                        table.Columns.Add("ROW_NO");
                        table.Columns.Add("ACTION");
                        table.Columns.Add("DOCUMENT_NO");
                        table.Columns.Add("DOCUMENT_LINE_ITEM_NO");
                        table.Columns.Add("FUND_DOCUMENT_DOC_NO");
                        table.Columns.Add("FUND_DOCUMENT_DOC_LINE_ITEM");
                        table.Columns.Add("MESSAGE_TYPE");
                        table.Columns.Add("MESSAGE_ID");
                        table.Columns.Add("MESSAGE_NO");
                        table.Columns.Add("MESSAGE_MESSAGE");
                        table.Columns.Add("PROCESSED_BY");
                        table.Columns.Add("PROCESSED_DT");
                        #endregion


                        int z = 0;

                        foreach (var d in NewResponse)
                        {
                            System.Data.DataRow row = table.NewRow();
                            row["PROCESS_ID"] = ProcessId;
                            row["ROW_NO"] = z + 1;
                            row["ACTION"] = xx.Action;
                            row["DOCUMENT_NO"] = d.doc_no;
                            row["DOCUMENT_LINE_ITEM_NO"] = d.doc_line_item_no;
                            row["FUND_DOCUMENT_DOC_NO"] = d.fund_cmmt_doc;
                            row["FUND_DOCUMENT_DOC_LINE_ITEM"] = d.fund_cmmt_doc_line_item;
                            row["MESSAGE_TYPE"] = d.msg_type;
                            row["MESSAGE_ID"] = d.msg_id;
                            row["MESSAGE_NO"] = d.msg_no;
                            row["MESSAGE_MESSAGE"] = d.msg;
                            row["PROCESSED_BY"] = Username;
                            row["PROCESSED_DT"] = DateTime.Now;

                            table.Rows.Add(row);

                            z++;
                        }

                        string responseRes = LibraryRepo.Instance.SaveToTemp(table);

                        if (responseRes != "SUC")
                        {
                            Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                            Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString(responseRes));
                            LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                            Console.WriteLine(Msg.MsgText);

                            Console.WriteLine("End Process ...");
                            Environment.Exit(0);
                        }

                        List<FCResponse> getResponse = LibraryRepo.Instance.GetWSResponse(xx);

                        //Validation
                        foreach (var item in getResponse)
                        {
                            if (string.Equals(item.MESSAGE_TYPE, "S") || string.Equals(item.MESSAGE_TYPE, "Success")
                                   || string.Equals(item.MESSAGE_TYPE, "") || string.Equals(item.MESSAGE_TYPE, null))
                            {
                                //Mandatory
                                if (string.IsNullOrEmpty(item.DOCUMENT_NO))
                                {
                                    isErr = true;
                                    Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                                    Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString("DOCUMENT_NO at line " + item.ROW_NO.ToString() + ", Should not be empty"));
                                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                                }
                                if (string.IsNullOrEmpty(item.DOCUMENT_LINE_ITEM_NO))
                                {
                                    isErr = true;
                                    Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                                    Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString("DOCUMENT_LINE_ITEM_NO at line " + item.ROW_NO.ToString() + ", Should not be empty"));
                                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                                }
                                if (string.IsNullOrEmpty(item.FUND_DOCUMENT_DOC_NO))
                                {
                                    isErr = true;
                                    Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                                    Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString("FUND_DOCUMENT_DOC_NO at line " + item.ROW_NO.ToString() + ", Should not be empty"));
                                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                                }
                                if (string.IsNullOrEmpty(item.FUND_DOCUMENT_DOC_LINE_ITEM))
                                {
                                    isErr = true;
                                    Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                                    Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString("FUND_DOCUMENT_DOC_LINE_ITEM at line " + item.ROW_NO.ToString() + ", Should not be empty"));
                                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                                }

                                //lenght
                                if (!string.IsNullOrEmpty(item.DOCUMENT_NO) && item.DOCUMENT_NO.Length > 11)
                                {
                                    isErr = true;

                                    Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                                    Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString(" Invalid length of DOCUMENT_NO at line " + item.ROW_NO.ToString() + ". The length can not be more than 11"));
                                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                                }
                                if (!string.IsNullOrEmpty(item.DOCUMENT_LINE_ITEM_NO) && item.DOCUMENT_LINE_ITEM_NO.Length > 5)
                                {
                                    isErr = true;

                                    Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                                    Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString(" Invalid length of DOCUMENT_LINE_ITEM_NO at line " + item.ROW_NO.ToString() + ". The length can not be more than 5"));
                                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                                }
                                if (!string.IsNullOrEmpty(item.FUND_DOCUMENT_DOC_NO) && item.FUND_DOCUMENT_DOC_NO.Length > 10)
                                {
                                    isErr = true;

                                    Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                                    Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString(" Invalid length of FUND_DOCUMENT_DOC_NO at line " + item.ROW_NO.ToString() + ". The length can not be more than 10"));
                                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                                }
                                if (!string.IsNullOrEmpty(item.FUND_DOCUMENT_DOC_LINE_ITEM) && item.FUND_DOCUMENT_DOC_LINE_ITEM.Length > 3)
                                {
                                    isErr = true;

                                    Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                                    Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString(" Invalid length of FUND_DOCUMENT_DOC_LINE_ITEM at line " + item.ROW_NO.ToString() + ". The length can not be more than 3"));
                                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                                }
                            }

                            //return message
                            if (item.MESSAGE_TYPE == "E")
                            {
                                isErr = true;
                                Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                                Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString("Return message : " + item.MESSAGE_MESSAGE + " for DOCUMENT_NO: " + item.DOCUMENT_NO + " and DOCUMENT_LINE_ITEM_NO: " + item.DOCUMENT_LINE_ITEM_NO + " at line " + item.ROW_NO.ToString()));
                                LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText.Replace("Undefined Error :", ""), Msg.MsgType, ProcessName, 0, Username);
                            }

                            #region Old Validation
                            /*if (string.Equals(item.MESSAGE_TYPE, "S") || string.Equals(item.MESSAGE_TYPE, "Success")
                                   || string.Equals(item.MESSAGE_TYPE, "") || string.Equals(item.MESSAGE_TYPE, null))
                            {
                                //Mandatory
                                if (string.IsNullOrEmpty(item.DOCUMENT_NO) || string.IsNullOrEmpty(item.DOCUMENT_LINE_ITEM_NO)
                                    || string.IsNullOrEmpty(item.FUND_DOCUMENT_DOC_NO) || string.IsNullOrEmpty(item.FUND_DOCUMENT_DOC_LINE_ITEM))
                                {
                                    Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                                    Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString("Invalid data found from response data"));
                                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                                    Console.WriteLine(Msg.MsgText);

                                    Console.WriteLine("End Process ...");
                                    Environment.Exit(0);
                                }

                                //lenght
                                if (item.DOCUMENT_NO.Length > 11 || item.DOCUMENT_LINE_ITEM_NO.Length > 5 || item.FUND_DOCUMENT_DOC_NO.Length > 10 || item.FUND_DOCUMENT_DOC_LINE_ITEM.Length > 3)
                                {
                                    Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                                    Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString("Invalid data found from response data"));
                                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                                    Console.WriteLine(Msg.MsgText);

                                    Console.WriteLine("End Process ...");
                                    Environment.Exit(0);
                                }

                            }*/
                            #endregion

                            
                        }

                        Console.WriteLine("Update PR Data");
                        Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                        Msg.MsgText = string.Format(Msg.MsgText, "Update PR Data");
                        LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                        LibraryRepo.Instance.UpdatePRData(xx, Username);
                    }
                    #endregion
                }

                Console.WriteLine("Call Web Service Fund Commitment Finish");
                Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                Msg.MsgText = string.Format(Msg.MsgText, "Call Web Service Fund Commitment Finish");
                LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                Console.WriteLine("End Process ...");
            }
            catch (Exception ex)
            {
                Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString(ex.Message) + "--" + Convert.ToString(ex.InnerException));
                LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                Console.WriteLine(Msg.MsgText);

                Console.WriteLine("Error: " + ex.Message);

                Console.WriteLine("End Process ...");
                Environment.Exit(0);
            }
        }

    }
}
