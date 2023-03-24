using PR_Creation_Call_WS.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

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
            //args = new String[] { "PRC|202105280001|0|5000000155|teset|agan" };

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

                List<RequestH> ReqHeader = new List<RequestH>();
                List<RequestD> ReqDetail = LibraryRepo.Instance.GetParam(ProcessId);

                if (ReqDetail.Count == 0)
                {
                    Msg = LibraryRepo.Instance.GetMessageById("ERR00007");
                    Msg.MsgText = string.Format(Msg.MsgText, "Request Table");
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                    Console.WriteLine(Msg.MsgText);

                    Console.WriteLine("Call Rollback Data");
                    Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                    LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS");

                    Environment.Exit(0);
                }

                var DistinctH = ReqDetail.GroupBy(x => x.DocumentNo).Select(c => new RequestH
                {
                    DocumentNo = c.First().DocumentNo
                }).ToList();

                foreach (var h in DistinctH)
                {
                    RequestH tempH = new RequestH();

                    tempH.DocumentNo = h.DocumentNo;
                    tempH.Item = ReqDetail.Where(x => x.DocumentNo == h.DocumentNo).ToList();
                    ReqHeader.Add(tempH);
                }

                Console.WriteLine("Call Web Service Fund Commitment");
                Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                Msg.MsgText = string.Format(Msg.MsgText, "Call Web Service Fund Commitment");
                LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                var NewResponse = WebAPIUtil.Request(ProcessId, ReqHeader, "POST");

                if (NewResponse.Count == 0)
                {
                    Msg = LibraryRepo.Instance.GetMessageById("ERR00007");
                    Msg.MsgText = string.Format(Msg.MsgText, "Response data");
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                    Console.WriteLine(Msg.MsgText);

                    Console.WriteLine("Call Rollback Data");
                    Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                    LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS");

                    Environment.Exit(0);
                }

                Console.WriteLine("Retrieve Fund Commitment Response");
                Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                Msg.MsgText = string.Format(Msg.MsgText, "Retrieve Fund Commitment Response");
                LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                var DistinctResH = NewResponse.GroupBy(x => x.DocNo).Select(c => new RequestH
                {
                    DocumentNo = c.First().DocNo
                }).ToList();

                #region Create Data Table
                System.Data.DataTable table = new System.Data.DataTable();

                table.Columns.Add("PROCESS_ID");
                table.Columns.Add("ROW_NO");
                table.Columns.Add("DOCUMENT_NO");
                table.Columns.Add("DOCUMENT_LINE_ITEM_NO");
                table.Columns.Add("FUND_DOCUMENT_DOC_NO");
                table.Columns.Add("FUND_DOCUMENT_DOC_LINE_ITEM");
                table.Columns.Add("MESSAGE_ID");
                table.Columns.Add("MESSAGE_MESSAGE");
                table.Columns.Add("PROCESSED_BY");
                table.Columns.Add("PROCESSED_DT");
                #endregion


                int z = 0;
                int j = 0;
                foreach (var h in DistinctResH)
                {
                    foreach (var d in NewResponse[j].Item.Where(x => x.DocNo == h.DocumentNo).ToList())
                    {
                        System.Data.DataRow row = table.NewRow();
                        row["PROCESS_ID"] = ProcessId;
                        row["ROW_NO"] = z + 1;
                        row["DOCUMENT_NO"] = d.DocNo;
                        row["DOCUMENT_LINE_ITEM_NO"] = d.DocLineItemNo;
                        row["FUND_DOCUMENT_DOC_NO"] = d.FundCmntDoc;
                        row["FUND_DOCUMENT_DOC_LINE_ITEM"] = d.FundCmntDocLineItem;
                        row["MESSAGE_ID"] = d.status;
                        row["MESSAGE_MESSAGE"] = d.message;
                        row["PROCESSED_BY"] = Username;
                        row["PROCESSED_DT"] = DateTime.Now;

                        table.Rows.Add(row);

                        z++;
                    }
                    j++;
                }

                string responseRes = LibraryRepo.Instance.SaveToTemp(table);

                if (responseRes != "SUC")
                {
                    Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                    Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString(responseRes));
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                    Console.WriteLine(Msg.MsgText);

                    Console.WriteLine("Call Rollback Data");
                    Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                    LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS");

                    Console.WriteLine("End Process ...");
                    Environment.Exit(0);
                }

                List<FCResponse> getResponse = LibraryRepo.Instance.GetWSResponse(ProcessId);

                //Validation
                foreach (var item in getResponse)
                {
                    if (string.Equals(item.MESSAGE_ID, "S") || string.Equals(item.MESSAGE_ID, "Success")
                           || string.Equals(item.MESSAGE_ID, "") || string.Equals(item.MESSAGE_ID, null))
                    {
                        //Mandatory
                        if (string.IsNullOrEmpty(item.DOCUMENT_NO) || string.IsNullOrEmpty(item.DOCUMENT_LINE_ITEM_NO)
                            || string.IsNullOrEmpty(item.FUND_DOCUMENT_DOC_NO) || string.IsNullOrEmpty(item.FUND_DOCUMENT_DOC_LINE_ITEM))
                        {
                            Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                            Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString("Invalid data found from response data"));
                            LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                            Console.WriteLine(Msg.MsgText);

                            Console.WriteLine("Call Rollback Data");
                            Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                            Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                            LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                            LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS");

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

                            Console.WriteLine("Call Rollback Data");
                            Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                            Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                            LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                            LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS");

                            Console.WriteLine("End Process ...");
                            Environment.Exit(0);
                        }

                    }
                }

                Console.WriteLine("Update PR Data");
                Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                Msg.MsgText = string.Format(Msg.MsgText, "Update PR Data");
                LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                LibraryRepo.Instance.UpdatePRData(ProcessId, Username);
                
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

                Console.WriteLine("Call Rollback Data");
                Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                Msg.MsgText = string.Format(Msg.MsgText, "Call Rollback Data");
                LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                LibraryRepo.Instance.Rollback(ProcessId, Division, PRNo, PRDesc, Username, "ROLLBACK", "0", "WS");

                Console.WriteLine("End Process ...");
                Environment.Exit(0);
            }
        }

    }
}
