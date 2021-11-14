using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.IO;
using Newtonsoft.Json;
using System.Web;
using Newtonsoft.Json.Linq;
using System.Web.Configuration;
using PR_Creation_Call_WS.Models;

namespace PR_Creation_Call_WS.Models
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

        internal static List<ResponseH> Request(string processId, List<RequestH> data, string method)
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

            //set headers
            request.ContentType = "application/json";
            request.UserAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)";
            request.Method = method;
            //set token
            //request.Headers.Add(HttpRequestHeader.Authorization, "Bearer " + TokenResponse.access_token);

            request.Proxy = WebRequest.DefaultWebProxy;
            request.Credentials = System.Net.CredentialCache.DefaultCredentials; ;
            request.Proxy.Credentials = System.Net.CredentialCache.DefaultCredentials;

            try
            {
                if (data != null && data.Count > 0)
                {
                    //write data to be sent
                    string dataJson = JsonConvert.SerializeObject(data);
                    using (var streamWriter = new StreamWriter(request.GetRequestStream()))
                    {
                        streamWriter.Write(dataJson);
                    }
                }

                //retrieve response
                var response = request.GetResponse() as HttpWebResponse;

                using (StreamReader reader = new StreamReader(response.GetResponseStream()))
                {
                    content = reader.ReadToEnd();
                }
                response.Close();

                ajax_array = JsonConvert.DeserializeObject<List<ResponseH>>(content, settings);
                //ajax_array.Message = null;

                return !string.IsNullOrEmpty(content) ? ajax_array : new List<ResponseH>();

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
                ajax_array = new List<ResponseH>();
                //ajax_array.Message = JsonConvert.DeserializeObject(Errresponse).ToString();

                Msg = LibraryRepo.Instance.GetMessageById("ERR00016");
                Msg.MsgText = string.Format(Msg.MsgText, Convert.ToString(Errresponse));
                LibraryRepo.Instance.GenerateLog(processId, "2", "201002", Msg.MsgId, Msg.MsgText, Msg.MsgType, "Web Service Response", 0, "System");

                return !string.IsNullOrEmpty(Errresponse) ? ajax_array : new List<ResponseH>();
            }
        }

        //public static List<T> Request<T>(Dictionary<string, string> data, string uri, string method) where T : new()
        //{
        //    string WSUri = WebConfigurationManager.AppSettings["WSUri"].ToString();

        //    var settings = new JsonSerializerSettings
        //    {
        //        NullValueHandling = NullValueHandling.Ignore,
        //        MissingMemberHandling = MissingMemberHandling.Ignore
        //    };

        //    string content = string.Empty;
        //    dynamic ajax_array = new Object();

        //    //handle error
        //    string Errresponse = string.Empty;

        //    ServicePointManager.SecurityProtocol = (SecurityProtocolType)3072;
        //    HttpWebRequest request = (HttpWebRequest)WebRequest.Create(WSUri + uri);

        //    //set headers
        //    request.ContentType = "application/json";
        //    request.UserAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)";
        //    request.Method = method;
        //    //set token
        //    //request.Headers.Add(HttpRequestHeader.Authorization, "Bearer " + TokenResponse.access_token);

        //    request.Proxy = WebRequest.DefaultWebProxy;
        //    request.Credentials = System.Net.CredentialCache.DefaultCredentials; ;
        //    request.Proxy.Credentials = System.Net.CredentialCache.DefaultCredentials;

        //    try
        //    {
        //        if (data != null && data.Count > 0)
        //        {
        //            //write data to be sent
        //            string dataJson = JsonConvert.SerializeObject(data);
        //            using (var streamWriter = new StreamWriter(request.GetRequestStream()))
        //            {
        //                streamWriter.Write(dataJson);
        //            }
        //        }

        //        //retrieve response
        //        var response = request.GetResponse() as HttpWebResponse;

        //        using (StreamReader reader = new StreamReader(response.GetResponseStream()))
        //        {
        //            content = reader.ReadToEnd();
        //        }
        //        response.Close();

        //        ajax_array = JsonConvert.DeserializeObject<List<T>>(content, settings);
        //        //ajax_array.Message = null;

        //        return !string.IsNullOrEmpty(content) ? ajax_array : new List<T>();

        //    }
        //    catch (WebException ex)
        //    {
        //        using (var reader = new System.IO.StreamReader(ex.Response.GetResponseStream()))
        //        {
        //            Errresponse = reader.ReadToEnd();
        //        }
        //        //throw ex;
        //        ajax_array = new List<T>();
        //        //ajax_array.Message = JsonConvert.DeserializeObject(Errresponse).ToString();

        //        return !string.IsNullOrEmpty(Errresponse) ? ajax_array : new List<T>();
        //    }
        //}

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
