using CommonPostingLibrary;
using PAS_Interface_Indirect_Material.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace PAS_Interface_Indirect_Material
{
    class Program
    {
        static string ProcessId;
        static string ftpUrl;
        static string ftpIPAddress;
        static string ftpUsername;
        static string ftpPassword;
        static string ftpfqdn;
        static string ftphosttype;
        static string ftpsendtype;
        static string ftptranstype;
        static string ftpcompmode;
        static string ftpregmode;
        static string ftpsync;
        static string ftpgcno;
        static string Dir = AppDomain.CurrentDomain.BaseDirectory;
        static string ModId = "0";
        static string FuncId = "070100";
        static string ProcessName = "Interface Ind Material";
        static string Username;
        static string fn;
        static int seq;
        static string fgwUsername;
        static string fgwPassword;
        static string fgwIPAddress;
        static string isHeaderFGW;
        static string isHeaderFile;
        static string isDetailFile;
        static string isFooterFile;

        static MessageModel Msg = new MessageModel();



        static void Main(string[] args)
        {
            string FileName = "", Content = "";
            string DOC_NO = "";
            string ConnString = ConfigurationManager.ConnectionStrings["PAS_Interface_Indirect_Material.Properties.Settings.ConnectionString"].ConnectionString;
            Username = (args.Length > 0) ? args[0] : "System";

            int CounterError = 0;

            OutputModel o = new OutputModel();

            try
            {
                Console.WriteLine("Starting ...");
                Console.WriteLine("Generate Process Id");
                try
                {
                    ProcessId = LibraryRepo.Instance.GetProcessID();
                }
                catch (Exception w)
                {
                    Console.WriteLine(w.Message);
                }

                LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                #region Get System Master
                Console.WriteLine("Get Configuration");

                Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                Msg.MsgText = string.Format(Msg.MsgText, "Get Configuration from System Master");
                LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                List<SystemMasterModel> Sys = LibraryRepo.Instance.GetSystemMaster("BH6011");

                ftpUrl = (Sys.Where(x => x.SYSTEM_CD == "FTP_HOSTNAME").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "FTP_HOSTNAME").Select(x => x.SYSTEM_VALUE).Single() : "";
                ftpIPAddress = (Sys.Where(x => x.SYSTEM_CD == "FTP_IP").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "FTP_IP").Select(x => x.SYSTEM_VALUE).Single() : "";
                ftpUsername = (Sys.Where(x => x.SYSTEM_CD == "FTP_USER").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "FTP_USER").Select(x => x.SYSTEM_VALUE).Single() : "";
                ftpPassword = (Sys.Where(x => x.SYSTEM_CD == "FTP_PASSWORD").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "FTP_PASSWORD").Select(x => x.SYSTEM_VALUE).Single() : "";
                ftpfqdn = (Sys.Where(x => x.SYSTEM_CD == "FTP_FQDN").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "FTP_FQDN").Select(x => x.SYSTEM_VALUE).Single() : "";
                ftphosttype = (Sys.Where(x => x.SYSTEM_CD == "FTP_HOST_TYPE").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "FTP_HOST_TYPE").Select(x => x.SYSTEM_VALUE).Single() : "";
                ftpsendtype = (Sys.Where(x => x.SYSTEM_CD == "FTP_SEND_TYPE").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "FTP_SEND_TYPE").Select(x => x.SYSTEM_VALUE).Single() : "";
                ftptranstype = (Sys.Where(x => x.SYSTEM_CD == "FTP_TRANSFER_TYPE").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "FTP_TRANSFER_TYPE").Select(x => x.SYSTEM_VALUE).Single() : "";
                ftpcompmode = (Sys.Where(x => x.SYSTEM_CD == "FTP_COMP_MODE").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "FTP_COMP_MODE").Select(x => x.SYSTEM_VALUE).Single() : "";
                ftpregmode = (Sys.Where(x => x.SYSTEM_CD == "FTP_REG_MODE").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "FTP_REG_MODE").Select(x => x.SYSTEM_VALUE).Single() : "";
                ftpsync = (Sys.Where(x => x.SYSTEM_CD == "FTP_SYNC_ASYNC").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "FTP_SYNC_ASYNC").Select(x => x.SYSTEM_VALUE).Single() : "";
                ftpgcno = (Sys.Where(x => x.SYSTEM_CD == "FTP_GCNO").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "FTP_GCNO").Select(x => x.SYSTEM_VALUE).Single() : "";
                fn = (Sys.Where(x => x.SYSTEM_CD == "INTERFACE_FILENAME").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "INTERFACE_FILENAME").Select(x => x.SYSTEM_VALUE).Single() : "";
                seq = (Sys.Where(x => x.SYSTEM_CD == "SEQ_INTERFACE_FILE").Count() > 0) ? Convert.ToInt32(Sys.Where(x => x.SYSTEM_CD == "SEQ_INTERFACE_FILE").Select(x => x.SYSTEM_VALUE).Single()) : 1;
                fgwIPAddress = (Sys.Where(x => x.SYSTEM_CD == "FGW_IP").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "FGW_IP").Select(x => x.SYSTEM_VALUE).Single() : "";
                fgwUsername = (Sys.Where(x => x.SYSTEM_CD == "FGW_USER").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "FGW_USER").Select(x => x.SYSTEM_VALUE).Single() : "";
                fgwPassword = (Sys.Where(x => x.SYSTEM_CD == "FGW_PASSWORD").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "FGW_PASSWORD").Select(x => x.SYSTEM_VALUE).Single() : "";
                isHeaderFGW = (Sys.Where(x => x.SYSTEM_CD == "HEADER_FGW").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "HEADER_FGW").Select(x => x.SYSTEM_VALUE).Single() : "";
                isHeaderFile = (Sys.Where(x => x.SYSTEM_CD == "HEADER_FILE").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "HEADER_FILE").Select(x => x.SYSTEM_VALUE).Single() : "";
                isDetailFile = (Sys.Where(x => x.SYSTEM_CD == "DETAIL_FILE").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "DETAIL_FILE").Select(x => x.SYSTEM_VALUE).Single() : "";
                isFooterFile = (Sys.Where(x => x.SYSTEM_CD == "FOOTER_FILE").Count() > 0) ? Sys.Where(x => x.SYSTEM_CD == "FOOTER_FILE").Select(x => x.SYSTEM_VALUE).Single() : "";

                if (string.IsNullOrEmpty(ftpUrl)) throw new Exception(string.Format("Data {0} not found", "URL FTP on System Master"));
                if (string.IsNullOrEmpty(ftpIPAddress)) throw new Exception(string.Format("Data {0} not found", "FTP IP Address on System Master"));
                if (string.IsNullOrEmpty(ftpUsername)) throw new Exception(string.Format("Data {0} not found", "Username FTP on System Master"));
                if (string.IsNullOrEmpty(ftpPassword)) throw new Exception(string.Format("Data {0} not found", "Password FTP on System Master"));
                if (string.IsNullOrEmpty(fn)) throw new Exception(string.Format("Data {0} not found", "File Name on System Master"));
                #endregion

                Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                Msg.MsgText = string.Format(Msg.MsgText, "Get list from Journal Table");
                LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                List<SapParamH> ParamH = LibraryRepo.Instance.GetParamH();
                if (ParamH.Count > 0)
                {
                    Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    Msg.MsgText = string.Format(Msg.MsgText, "Total data: " + ParamH.Count.ToString() + " record(s).");
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                    //create file
                    Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    Msg.MsgText = string.Format(Msg.MsgText, "Check FTP / Connection");
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                    Console.WriteLine("Create a lock file");
                    File.WriteAllText(Path.Combine(Dir + @"\File\lock"), Content);

                    o = SendFile("lock");
                    if (!o.Status) throw new Exception(o.Message.ToString());

                    Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    Msg.MsgText = string.Format(Msg.MsgText, "Get common filename");
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                    GenerateFile source = new GenerateFile();
                    FileName = source.createFileName(fn, seq, "");

                    LibraryRepo.Instance.UpdateFileName(FileName);

                    Console.WriteLine(string.Format("Create a file {0}", FileName));

                    Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    Msg.MsgText = string.Format(Msg.MsgText, string.Format("Create a file {0}", FileName));
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                    string path = source.create(ConnString, "File/", FileName,
                        (isHeaderFGW == "1" ? true : false),
                        (isHeaderFile == "1" ? true : false),
                        (isDetailFile == "1" ? true : false),
                        (isFooterFile == "1" ? true : false), "");

                    //FileName = Path.GetFileName(path.Split('|')[1]);

                    Console.WriteLine(string.Format("Sending a file {0} to SAP", FileName));

                    Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    Msg.MsgText = string.Format(Msg.MsgText, string.Format("Sending a file {0} to SAP", FileName));
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                    o = SendFile(FileName);

                    Console.WriteLine(string.Format("Create a file CTF {0}", FileName));

                    Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    Msg.MsgText = string.Format(Msg.MsgText, string.Format("Create a file CTF {0}", FileName));
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                    FileInfo info = new FileInfo(path.Split('|')[1]);
                    long size = info.Length;

                    string CTFvalue = "\0" + fgwIPAddress + "\0" + "\0" + ftphosttype + "\0" + ftpsendtype + "\0" + ftptranstype + "\0" + ftpcompmode +
                        "\0" + fgwUsername + "\0" + fgwPassword + "\0" + "\0" + "\0" + "\0" + "\0" + "\0" + "\0" + ftpregmode + "\0"
                        + size.ToString() + "\0" + "\0" + ftpsync + "\0" + ftpgcno;

                    string pathCTF = source.createCTF("File/", FileName + ".CTF", CTFvalue);

                    string filenameCTF = Path.GetFileName(pathCTF.Split('|')[1]);

                    Console.WriteLine(string.Format("Sending a file CTF {0} to SAP", filenameCTF));

                    Msg = LibraryRepo.Instance.GetMessageById("INF00002");
                    Msg.MsgText = string.Format(Msg.MsgText, string.Format("Sending a file CTF {0} to SAP", filenameCTF));
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                    o = SendFile(filenameCTF);

                    if (o.Status)
                    {

                        Msg = LibraryRepo.Instance.GetMessageById("INF00003");
                        Msg.MsgText = string.Format(Msg.MsgText, "Update File name sequence");
                        LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);

                        LibraryRepo.Instance.UpdateSequence();

                        Msg = LibraryRepo.Instance.GetMessageById("INF00003");
                        Msg.MsgText = string.Format(Msg.MsgText, "Sending File: " + FileName);
                        LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                        Console.WriteLine(Msg.MsgText + "\r\n");
                        Console.WriteLine(string.Format("Deleting a file {0}", FileName));
                        File.Delete(Path.Combine(Dir + @"\File\", FileName));
                        File.Delete(Path.Combine(Dir + @"\File\", FileName + ".CTF"));
                        Console.WriteLine(string.Format("Deleted a file {0}", FileName));
                    }
                    else
                    {
                        Msg = LibraryRepo.Instance.GetMessageById("ERR00009");
                        Msg.MsgText = string.Format(Msg.MsgText, "Sending File: " + FileName + " with error: " + o.Message);
                        LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                        Console.WriteLine(Msg.MsgText + "\r\n");
                        CounterError++;
                        Console.WriteLine(string.Format("Deleting a file {0}", FileName));
                        File.Delete(Path.Combine(Dir + @"\File\", FileName));
                        File.Delete(Path.Combine(Dir + @"\File\", FileName + ".CTF"));
                        Console.WriteLine(string.Format("Deleted a file {0}", FileName));
                    }

                    Console.WriteLine("Deleting lock file");
                    DeleteFile("lock");

                    int ProcessSts = (CounterError == 0) ? 1 : 3;
                    if (CounterError == 0)
                    {
                        LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, "", "", "INF", ProcessName, 1, Username);
                    }
                    else
                    {
                        Msg = LibraryRepo.Instance.GetMessageById("ERR00009");
                        Msg.MsgText = string.Format(Msg.MsgText, "PAS_Interface_Indirect_Material");
                        LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 1, Username);
                    }

                    Console.WriteLine("Finished");
                    //Console.ReadKey();

                }
                else
                {
                    Msg = LibraryRepo.Instance.GetMessageById("ERR00007");
                    Msg.MsgText = string.Format(Msg.MsgText, "Journal Table");
                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                    Console.WriteLine(Msg.MsgText);

                    LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, "", "", "INF", ProcessName, 1, Username);
                }


            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString(e.Message) + "--" + Convert.ToString(e.InnerException));
                LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, Msg.MsgId, Msg.MsgText, Msg.MsgType, ProcessName, 0, Username);
                Console.WriteLine(Msg.MsgText);

                LibraryRepo.Instance.GenerateLog(ProcessId, ModId, FuncId, "", "", "ERR", ProcessName, 1, Username);
                Console.ReadKey();
                Environment.Exit(0);
            }
        }


        #region Send File
        private static OutputModel SendFile(string FileName)
        {
            OutputModel Output = new OutputModel();

            string sourcefilepath = Path.Combine(Dir, FileName);
            try
            {
                FtpWebRequest ftp = (FtpWebRequest)FtpWebRequest.Create(ftpUrl + "/" + FileName);
                ftp.Proxy = null; ;
                ftp.Credentials = new NetworkCredential(ftpUsername, ftpPassword);
                ftp.Method = WebRequestMethods.Ftp.UploadFile;
                ftp.KeepAlive = true;
                ftp.UseBinary = true;

                FileInfo fi = new FileInfo(Dir + @"File\" + FileName);
                ftp.ContentLength = fi.Length;
                byte[] buffer = new byte[4097];
                int bytes = 0;
                int total_bytes = (int)fi.Length;

                using (var fs = (FileStream)fi.OpenRead())
                using (var rs = (Stream)ftp.GetRequestStream())
                {
                    while (total_bytes > 0)
                    {
                        bytes = fs.Read(buffer, 0, buffer.Length);
                        rs.Write(buffer, 0, bytes);
                        total_bytes -= bytes;
                    }
                }

                FtpWebResponse uploadResponse = (FtpWebResponse)ftp.GetResponse();
                uploadResponse.Close();

                Output.SetOutput(true, null, "Sending file successed");

            }
            catch (WebException e)
            {
                Output.SetOutput(false, new { Status = e.Status.ToString() }, e.Message.ToString());
            }
            catch (Exception e)
            {
                Output.SetOutput(false, e, e.Message.ToString());
            }

            return Output;
        }
        #endregion

        #region Delete File on Ftp
        private static OutputModel DeleteFile(string FileName)
        {
            OutputModel o = new OutputModel();

            try
            {
                FtpWebRequest ftp;

                ftp = (FtpWebRequest)FtpWebRequest.Create(ftpUrl + "/" + FileName);

                ftp.Credentials = new NetworkCredential(ftpUsername, ftpPassword);
                ftp.Method = WebRequestMethods.Ftp.DeleteFile;
                ftp.KeepAlive = true;
                ftp.UseBinary = true;

                using (FtpWebResponse response = (FtpWebResponse)ftp.GetResponse())
                {
                    bool sts = (response.StatusCode.ToString() == "FileActionOK") ? true : false;
                    o.SetOutput(sts, null, response.StatusDescription);
                }
            }
            catch (WebException e)
            {
                o.SetOutput(false, new { Status = e.Status.ToString() }, e.Message.ToString());
            }
            catch (Exception e)
            {
                o.SetOutput(false, null, e.Message.ToString());
            }
            return o;
        }
        #endregion

        public static bool HasProperty(object obj, string propertyName)
        {
            return obj.GetType().GetProperty(propertyName) != null;
        }

        public static string ConvertNullString(string param)
        {
            return (param.ToLower() == "null") ? null : param;
        }
    }
}
