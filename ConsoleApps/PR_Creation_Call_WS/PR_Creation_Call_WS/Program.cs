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

                List<MaintainFundCommitReq_MT> ReqHeader = new List<MaintainFundCommitReq_MT>();
                PAS_Document ReqDocument = new PAS_Document();
                List<item> MainRequest = LibraryRepo.Instance.GetParam(ProcessId, "I");

                List<MaintainFundCommitReq_MT> ReqHeaderCancel = new List<MaintainFundCommitReq_MT>();
                PAS_Document ReqDocumentCancel = new PAS_Document();
                List<item> MainRequestCancel = LibraryRepo.Instance.GetParam(ProcessId, "C");

                if (MainRequest.Count == 0 && MainRequestCancel.Count == 0)
                {
                    Msg = LibraryRepo.Instance.GetMessageById("ERR00007");
                    Msg.MsgText = string.Format(Msg.MsgText, "Request Table");
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                    Console.WriteLine(Msg.MsgText);

                    //Console.WriteLine("Call Rollback Data");
                    //Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    //Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                    //LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                    //LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS", type);

                    Environment.Exit(0);
                }

                #region Cancel
                if (MainRequestCancel.Count > 0)
                {
                    Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    Msg.MsgText = string.Format(Msg.MsgText, "Cancel data to SAP");
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                    var DistinctHCancel = MainRequestCancel.GroupBy(x => x.doc_no).Select(c => new PAS_Header
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

                    foreach (var h in DistinctHCancel)
                    {
                        MaintainFundCommitReq_MT tempMCancel = new MaintainFundCommitReq_MT();
                        PAS_Header tempHCancel = new PAS_Header();

                        tempHCancel.doc_type = h.doc_type;
                        tempHCancel.action = h.action;
                        tempHCancel.system = h.system;
                        tempHCancel.test_run = h.test_run;
                        tempHCancel.doc_no = h.doc_no;
                        tempHCancel.closed = h.closed;
                        tempHCancel.doc_date = h.doc_date;
                        tempHCancel.submit_date = h.submit_date;
                        tempHCancel.requestor = h.requestor;
                        tempHCancel.company_code = h.company_code;
                        tempHCancel.currency = h.currency;
                        tempHCancel.currency_rate = h.currency_rate;

                        tempHCancel.item = MainRequestCancel.Where(x => x.doc_no == h.doc_no).ToList();

                        ReqDocumentCancel.document = tempHCancel;

                        tempMCancel.REQUEST = ReqDocumentCancel;

                        ReqHeaderCancel.Add(tempMCancel);
                    }

                    MaintainFundCommitReq_MT responsesCancel = new MaintainFundCommitReq_MT();
                    responsesCancel.REQUEST = ReqHeaderCancel[0].REQUEST;
                    MemoryStream StreamCancel = new MemoryStream();
                    Type tpCancel = typeof(MaintainFundCommitReq_MT);
                    XmlSerializer xmlCancel = new XmlSerializer(tpCancel);

                    string WSPrefixCancel = WebConfigurationManager.AppSettings["WSPrefix"].ToString();
                    string WSNamespaceCancel = WebConfigurationManager.AppSettings["WSNamespace"].ToString();

                    XmlSerializerNamespaces xmlNameSpaceCancel = new XmlSerializerNamespaces();
                    xmlNameSpaceCancel.Add(WSPrefixCancel, WSNamespaceCancel);

                    try
                    {
                        xmlCancel.Serialize(StreamCancel, responsesCancel, xmlNameSpaceCancel);
                    }
                    catch (Exception ex)
                    {
                        Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                        Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString(ex.Message) + "--" + Convert.ToString(ex.InnerException));
                        LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                        Console.WriteLine(Msg.MsgText);

                        Console.WriteLine("Error: " + ex.Message);

                        //Console.WriteLine("Call Rollback Data");
                        //Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                        //Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                        //LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                        //LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS", type);

                        Console.WriteLine("End Process ...");
                        Environment.Exit(0);
                    }

                    StreamCancel.Position = 0;
                    StreamReader srCancel = new StreamReader(StreamCancel);
                    string strCancel = srCancel.ReadToEnd();
                    strCancel = strCancel.Replace("_x003A_", ":");

                    srCancel.Dispose();
                    StreamCancel.Dispose();

                    //string str = MainRequest[0].retXML;

                    Console.WriteLine("Call Web Service Fund Commitment");
                    Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    Msg.MsgText = string.Format(Msg.MsgText, "Call Web Service Fund Commitment");
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                    var NewResponseCancel = WebAPIUtil.XMLRequest(ProcessId, strCancel, "POST");

                    if (NewResponseCancel.Count == 0)
                    {
                        Msg = LibraryRepo.Instance.GetMessageById("ERR00007");
                        Msg.MsgText = string.Format(Msg.MsgText, "Response data");
                        LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                        Console.WriteLine(Msg.MsgText);

                        //Console.WriteLine("Call Rollback Data");
                        //Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                        //Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                        //LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                        //LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS", type);

                        Environment.Exit(0);
                    }

                    Console.WriteLine("Retrieve Fund Commitment Response");
                    Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    Msg.MsgText = string.Format(Msg.MsgText, "Retrieve Fund Commitment Response");
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                    #region Create Data Table
                    System.Data.DataTable tableCancel = new System.Data.DataTable();

                    tableCancel.Columns.Add("PROCESS_ID");
                    tableCancel.Columns.Add("ROW_NO");
                    tableCancel.Columns.Add("ACTION");
                    tableCancel.Columns.Add("DOCUMENT_NO");
                    tableCancel.Columns.Add("DOCUMENT_LINE_ITEM_NO");
                    tableCancel.Columns.Add("FUND_DOCUMENT_DOC_NO");
                    tableCancel.Columns.Add("FUND_DOCUMENT_DOC_LINE_ITEM");
                    tableCancel.Columns.Add("MESSAGE_TYPE");
                    tableCancel.Columns.Add("MESSAGE_ID");
                    tableCancel.Columns.Add("MESSAGE_NO");
                    tableCancel.Columns.Add("MESSAGE_MESSAGE");
                    tableCancel.Columns.Add("PROCESSED_BY");
                    tableCancel.Columns.Add("PROCESSED_DT");
                    #endregion


                    int zCancel = 0;

                    foreach (var d in NewResponseCancel)
                    {
                        System.Data.DataRow rowCancel = tableCancel.NewRow();
                        rowCancel["PROCESS_ID"] = ProcessId;
                        rowCancel["ROW_NO"] = zCancel + 1;
                        rowCancel["ACTION"] = "C";
                        rowCancel["DOCUMENT_NO"] = d.doc_no;
                        rowCancel["DOCUMENT_LINE_ITEM_NO"] = d.doc_line_item_no;
                        rowCancel["FUND_DOCUMENT_DOC_NO"] = d.fund_cmmt_doc;
                        rowCancel["FUND_DOCUMENT_DOC_LINE_ITEM"] = d.fund_cmmt_doc_line_item;
                        rowCancel["MESSAGE_TYPE"] = d.msg_type;
                        rowCancel["MESSAGE_ID"] = d.msg_id;
                        rowCancel["MESSAGE_NO"] = d.msg_no;
                        rowCancel["MESSAGE_MESSAGE"] = d.msg;
                        rowCancel["PROCESSED_BY"] = Username;
                        rowCancel["PROCESSED_DT"] = DateTime.Now;

                        tableCancel.Rows.Add(rowCancel);

                        zCancel++;
                    }

                    string responseResCancel = LibraryRepo.Instance.SaveToTemp(tableCancel);

                    if (responseResCancel != "SUC")
                    {
                        Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                        Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString(responseResCancel));
                        LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                        Console.WriteLine(Msg.MsgText);

                        //Console.WriteLine("Call Rollback Data");
                        //Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                        //Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                        //LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                        //LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS", type);

                        Console.WriteLine("End Process ...");
                        Environment.Exit(0);
                    }

                    List<FCResponse> getResponseCancel = LibraryRepo.Instance.GetWSResponse(ProcessId, "C");

                    //Validation
                    foreach (var item in getResponseCancel)
                    {
                        if (string.Equals(item.MESSAGE_TYPE, "S") || string.Equals(item.MESSAGE_TYPE, "Success")
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

                                //Console.WriteLine("Call Rollback Data");
                                //Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                                //Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                                //LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                                //LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS", type);

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

                                //Console.WriteLine("Call Rollback Data");
                                //Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                                //Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                                //LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                                //LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS", type);

                                Console.WriteLine("End Process ...");
                                Environment.Exit(0);
                            }

                        }
                    }

                    Console.WriteLine("Update PR Data");
                    Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    Msg.MsgText = string.Format(Msg.MsgText, "Update PR Data");
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                    LibraryRepo.Instance.UpdatePRData(ProcessId, Username, "C");
                
                }
                #endregion

                #region Insert
                if (MainRequest.Count > 0)
                {
                    Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    Msg.MsgText = string.Format(Msg.MsgText, "Insert data to SAP");
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

                    string WSPrefix = WebConfigurationManager.AppSettings["WSPrefix"].ToString();
                    string WSNamespace = WebConfigurationManager.AppSettings["WSNamespace"].ToString();

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

                        //Console.WriteLine("Call Rollback Data");
                        //Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                        //Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                        //LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                        //LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS", type);

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

                        //Console.WriteLine("Call Rollback Data");
                        //Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                        //Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                        //LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                        //LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS", type);

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
                        row["ACTION"] = "I";
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

                        //Console.WriteLine("Call Rollback Data");
                        //Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                        //Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                        //LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                        //LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS", type);

                        Console.WriteLine("End Process ...");
                        Environment.Exit(0);
                    }

                    List<FCResponse> getResponse = LibraryRepo.Instance.GetWSResponse(ProcessId, "I");

                    //Validation
                    foreach (var item in getResponse)
                    {
                        if (string.Equals(item.MESSAGE_TYPE, "S") || string.Equals(item.MESSAGE_TYPE, "Success")
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

                                //Console.WriteLine("Call Rollback Data");
                                //Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                                //Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                                //LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                                //LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS", type);

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

                                //Console.WriteLine("Call Rollback Data");
                                //Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                                //Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                                //LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                                //LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS", type);

                                Console.WriteLine("End Process ...");
                                Environment.Exit(0);
                            }

                        }
                    }

                    Console.WriteLine("Update PR Data");
                    Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    Msg.MsgText = string.Format(Msg.MsgText, "Update PR Data");
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                    LibraryRepo.Instance.UpdatePRData(ProcessId, Username, "I");
                }
                #endregion

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

                //Console.WriteLine("Call Rollback Data");
                //Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                //Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                //LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                //LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS", type);

                Console.WriteLine("End Process ...");
                Environment.Exit(0);
            }
        }

    }
}
