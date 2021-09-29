using Toyota.Common.Web.Platform;

namespace GPS.Controllers.Home
{
    public class DashboardController : PageController
    {
        protected override void Startup()
        {
            Settings.Title = "Dashboard";
        }
    }
}