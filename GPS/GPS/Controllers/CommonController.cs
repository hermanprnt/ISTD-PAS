using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.Mvc;
using System.Web.UI.WebControls;

namespace GPS.Controllers
{
    public static class CommonController
    {
        public static void DownloadTemplate(Controller controller, String filePath)
        {
            string serverFilePath = controller.HttpContext.Request.MapPath(filePath);
            byte[] fileBytes = File.ReadAllBytes(serverFilePath);
            controller.Response.Clear();
            controller.Response.Cache.SetCacheability(HttpCacheability.Private);
            controller.Response.Expires = -1;
            controller.Response.Buffer = true;
            controller.Response.ContentType = "application/ms-excel";
            controller.Response.AddHeader("Content-Length", Convert.ToString(fileBytes.Length));
            controller.Response.AddHeader("Content-Disposition", string.Format("{0};FileName=\"{1}\"", "attachment", Path.GetFileName(filePath)));
            controller.Response.AddHeader("Set-Cookie", "fileDownload=true; path=/");
            controller.Response.BinaryWrite(fileBytes);
            controller.Response.End();
        }

        public static String DeleteData(Controller controller, String idList, Func<String, Int32> deleteDataFunc)
        {
            Int32 deletedCount = 0;
            var errorList = new List<String>();

            if (!String.IsNullOrEmpty(idList))
            {

                String[] splittedIdList = idList.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                foreach (string id in splittedIdList)
                {
                    try
                    {
                        var r = deleteDataFunc(id); // CostCenterRepository.Instance.DeleteData(CostCenter_CD);
                        if (r > 0)
                            ++deletedCount;
                    }
                    catch (Exception e)
                    {
                        errorList.Add(e.Message);
                    }
                }

                if (deletedCount > 0 && errorList.Count < 1)
                    return deletedCount + " data";

                if (deletedCount < 1 && errorList.Count < 1)
                {
                    controller.Response.StatusCode = 500;
                    return "Cannot delete record, cause unknown";
                }

                return "Delete failed.<br/>\r\n" + String.Join("<br>\r\n", errorList);
            }

            return "You must checked one or more data";
        }
    }
}