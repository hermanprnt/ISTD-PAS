namespace GPS.CommonFunc
{
    public static class FileManager
    {
        public static byte[] ReadFile(string filePath, string fileName)
        {
            string fullFilePath = string.Format("{0}/{1}", filePath, fileName);
            return System.IO.File.ReadAllBytes(fullFilePath);
        }
    }

    public class FileManagerResult : System.Web.Mvc.ContentResult
    {
        private string fileName;
        private byte[] fileData;

        public FileManagerResult(string fileName, byte[] fileData)
        {
            this.fileName = fileName;
            this.fileData = fileData;
        }

        public override void ExecuteResult(System.Web.Mvc.ControllerContext context)
        {                        
            context.HttpContext.Response.Clear();
            context.HttpContext.Response.ClearHeaders();
            context.HttpContext.Response.ClearContent();
            context.HttpContext.Response.ContentType = "application/octet-stream";
            context.HttpContext.Response.AddHeader("content-disposition", string.Format("attachment; filename=\"{0}\"", this.fileName));
            context.HttpContext.Response.AddHeader("content-length", fileData.Length.ToString());
            context.HttpContext.Response.BinaryWrite(fileData);
            context.HttpContext.Response.Flush();
            context.HttpContext.Response.Close();
            context.HttpContext.Response.End();
        }
    }
}