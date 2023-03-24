using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.IO;
using Newtonsoft.Json;
using System.Web;
using Newtonsoft.Json.Linq;
using System.Web.Configuration;
using FCManagementTools.Models;
using System.Xml;

namespace FCManagementTools.Models
{
    public class WebAPIUtil
    {
        static MessageModel Msg = new MessageModel();

        public WebAPIUtil()
        {
            //Set default protocol to TLS 1.2
            ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072;
        }

        public class TokenData
        {
            public string access_token { get; set; }

            public string token_type { get; set; }

            public string expires_in { get; set; }
        }

        public static T GetToken<T>(string url) where T : new()
        {
            using (var w = new WebClient())
            {
                var json_data = string.Empty;
                string json = string.Empty;

                try
                {
                    json_data = w.DownloadString(url);

                    JObject obj = JObject.Parse(json_data);

                    json = JsonConvert.SerializeObject(obj.SelectToken("token"));

                }
                catch (Exception) { }

                return !string.IsNullOrEmpty(json_data) ? JsonConvert.DeserializeObject<T>(json) : new T();
            }
        }

        internal static List<document> XMLRequest(string processId, string data, string method)
        {
            string WSUri = WebConfigurationManager.AppSettings["WSUri"].ToString();

            var settings = new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore,
                MissingMemberHandling = MissingMemberHandling.Ignore
            };

            string content = string.Empty;
            dynamic ajax_array = new Object();

            //handle error
            string Errresponse = string.Empty;

            ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072;
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(WSUri);

            System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate { return true; };

            //set headers
            request.ContentType = "text/xml; charset=utf-8";
            request.UserAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)";
            request.Method = method;
            //set token
            //request.Headers.Add(HttpRequestHeader.Authorization, "Bearer " + TokenResponse.access_token);

            request.Proxy = WebRequest.DefaultWebProxy;
            request.Credentials = System.Net.CredentialCache.DefaultCredentials; ;
            request.Proxy.Credentials = System.Net.CredentialCache.DefaultCredentials;

            try
            {
                request.ContentLength = data.Length;

                using (StreamWriter writer = new StreamWriter(request.GetRequestStream()))
                {
                    writer.Write(data);
                }

                HttpWebResponse response = (HttpWebResponse)request.GetResponse();
                using (StreamReader reader = new StreamReader(response.GetResponseStream()))
                {
                    content = reader.ReadToEnd();
                }

                response.Close();

                XmlDocument doc = new XmlDocument();
                doc.LoadXml(content);

                List<document> fullst = new List<document>();

                #region TDEM
                //var nsmgr = new XmlNamespaceManager(doc.NameTable);
                //nsmgr.AddNamespace("ns0", "http://toyota.com/th/projectsystem/fund");

                //XmlNodeList xnList = doc.SelectNodes("/ns0:MaintainFundCommitResp_MT", nsmgr);
                #endregion

                XmlNodeList xnList = doc.GetElementsByTagName("MaintainFundCommitResp_MT");//doc.SelectNodes("/MaintainFundCommitResp_MT");

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

                ajax_array = fullst;
                //ajax_array.Message = null;

                return !string.IsNullOrEmpty(content) ? ajax_array : new List<document>();

            }
            catch (WebException ex)
            {
                if (ex.Response != null)
                {
                    using (var reader = new System.IO.StreamReader(ex.Response.GetResponseStream()))
                    {
                        Errresponse = reader.ReadToEnd();
                    }
                }
                else
                {
                    Errresponse = ex.Message;
                }

                //throw ex;
                ajax_array = new List<document>();
                //ajax_array.Message = JsonConvert.DeserializeObject(Errresponse).ToString();

                Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString(Errresponse));
                LibraryRepo.Instance.GenerateLog(processId, "2", "201002", Msg.MsgId, Msg.MsgText, Msg.MsgType, "Web Service Response", 0, "System");

                return !string.IsNullOrEmpty(Errresponse) ? ajax_array : new List<document>();
            }
        }


        public static T _download_serialized_json_data_token<T>(string url) where T : new()
        {
            using (var w = new WebClient())
            {
                var json_data = string.Empty;
                string json = string.Empty;

                try
                {
                    json_data = w.DownloadString(url);
                    JObject obj = JObject.Parse(json_data);

                    json = JsonConvert.SerializeObject(obj.SelectToken("token"));

                }
                catch (Exception) { }

                return !string.IsNullOrEmpty(json_data) ? JsonConvert.DeserializeObject<T>(json) : new T();
            }
        }
    }
}
