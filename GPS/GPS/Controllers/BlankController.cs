using Toyota.Common.Web.Platform;

namespace GPS.Controllers
{
    public class BlankController : PageController
    {
        protected override void Startup()
        {
            Settings.Title = "Blank";
        }

    }
}
