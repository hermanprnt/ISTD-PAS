using System.Web.Mvc;

namespace GPS.Controllers
{
    public class ErrorController : Controller
    {
        public ViewResult Index()
        {
            ViewBag.Title = "Error";
            return View("ErrorDefault");
        }

        public ViewResult GenericError(HandleErrorInfo exception)
        {
            ViewBag.Title = "Error";
            return View("ErrorDefault", exception);
        }

        public ViewResult NotFound(HandleErrorInfo exception)
        {
            ViewBag.Title = "Page Not Found";
            Response.ContentType = "text/html";
            return View("ErrorDefault", exception);
        }
    }
}
