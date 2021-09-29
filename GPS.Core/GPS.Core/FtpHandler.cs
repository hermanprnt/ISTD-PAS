using System;
using System.IO;
using System.Net;
using System.Text;

namespace GPS.Core
{
    public static class FtpHandler
    {
        public static void Upload(String url, String localFilePath, NetworkCredential ftpCredential)
        {
            var request = (FtpWebRequest)WebRequest.Create(url);
            request.Credentials = ftpCredential;
            request.Method = WebRequestMethods.Ftp.UploadFile;
            request.Proxy = GlobalProxySelection.GetEmptyWebProxy();
            request.UseBinary = true;
            request.UsePassive = true;
            request.KeepAlive = true;

            using (Stream requestStream = request.GetRequestStream())
            {
                using (var localFileStream = new FileStream(localFilePath, FileMode.Open))
                {
                    Int32 bufferSize = 2048;
                    var byteBuffer = new Byte[bufferSize];
                    Int32 bytesSent = localFileStream.Read(byteBuffer, 0, bufferSize);
                    while (bytesSent != 0)
                    {
                        requestStream.Write(byteBuffer, 0, bytesSent);
                        bytesSent = localFileStream.Read(byteBuffer, 0, bufferSize);
                    }
                }
            }
        }

        public static void Download(String url, String localFilePath, NetworkCredential ftpCredential)
        {
            var request = (FtpWebRequest)WebRequest.Create(url);
            request.Credentials = ftpCredential;
            request.Method = WebRequestMethods.Ftp.DownloadFile;
            request.Proxy = WebRequest.DefaultWebProxy;
            request.UseBinary = true;
            request.UsePassive = true;
            request.KeepAlive = true;

            using (var response = (FtpWebResponse)request.GetResponse())
            {
                using (Stream responseStream = response.GetResponseStream())
                {
                    using (var localFileStream = new FileStream(localFilePath, FileMode.Create))
                    {
                        Int32 bufferSize = 2048;
                        var byteBuffer = new Byte[bufferSize];
                        Int32 bytesRead = responseStream.Read(byteBuffer, 0, bufferSize);
                        while (bytesRead > 0)
                        {
                            localFileStream.Write(byteBuffer, 0, bytesRead);
                            bytesRead = responseStream.Read(byteBuffer, 0, bufferSize);
                        }
                    }
                }
            }
        }

        public static void DownloadAllFiles(String url, String localFilePath, NetworkCredential ftpCredential)
        {
            StringBuilder result = new StringBuilder();
            FtpWebRequest reqFTP;

            reqFTP = (FtpWebRequest)FtpWebRequest.Create(new Uri(url));
            reqFTP.UseBinary = true;
            reqFTP.UsePassive = true;
            reqFTP.Proxy = new WebProxy();// GlobalProxySelection.GetEmptyWebProxy();
            reqFTP.Credentials = ftpCredential;
            reqFTP.Method = WebRequestMethods.Ftp.ListDirectory;
            WebResponse response = reqFTP.GetResponse();
            StreamReader reader = new StreamReader(response.GetResponseStream());

            string file = reader.ReadLine();
            while (file != null)
            {
                if (Path.GetExtension(file) == ".txt") //this is dummy. If file extension changed, so code must be changed too
                {
                    result.Append(file);
                    result.Append("\n");
                    Download(url + file, localFilePath + file, ftpCredential);
                }
                file = reader.ReadLine();
            }
            reader.Close();
            response.Close();
        }

        public static void Delete(String url, NetworkCredential ftpCredential)
        {
            FtpWebRequest ftpRequest = (FtpWebRequest)WebRequest.Create(url);
            ftpRequest.Credentials = ftpCredential;
            ftpRequest.UseBinary = true;
            ftpRequest.UsePassive = true;
            ftpRequest.Proxy = GlobalProxySelection.GetEmptyWebProxy();
            ftpRequest.KeepAlive = false;
            ftpRequest.Method = WebRequestMethods.Ftp.DeleteFile;
            FtpWebResponse ftpResponse = (FtpWebResponse)ftpRequest.GetResponse();
            ftpResponse.Close();
            ftpRequest = null;
        }
    }
}