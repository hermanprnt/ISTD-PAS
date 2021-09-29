using Toyota.Common.Web.Platform;

namespace GPS.Controllers
{
    public class ChangePasswordController : PageController
    {
        protected override void Startup()
        {
            Settings.Title = "Change Password";
        }
    }
}
