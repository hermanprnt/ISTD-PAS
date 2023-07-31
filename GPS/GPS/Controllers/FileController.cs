using System.IO;
using System.Web.Mvc;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers
{
    public class FileController : Controller
    {
        [HttpGet]
        public ActionResult Download(string file)
        {
            if (!System.IO.File.Exists(file))
                return Content($"File {file} not found");
            byte[] fileBytes = System.IO.File.ReadAllBytes(file);
            string fileName = Path.GetFileName(file);
            return File(fileBytes, System.Net.Mime.MediaTypeNames.Application.Octet, fileName);
        }

    }
}
