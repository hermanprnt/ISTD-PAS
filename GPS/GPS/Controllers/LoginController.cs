using System;
using System.Web.Mvc;
using GPS.Core;
using GPS.Core.ViewModel;
using GPS.Models;
using Toyota.Common.Credential;
using Toyota.Common.Web.Platform;

namespace GPS.Controllers
{
    public class LoginController : LoginPageController
    {
        protected override void Startup()
        {
            base.Startup();
            Settings.Title = "Login";
            string autolog = Request.Params["autologin"];
            string username = Request.Params["username"];
            string password = Request.Params["password"];
            ViewData["autologin"] = autolog;
            ViewData["username"] = username;
            ViewData["password"] = password;
        }

        [HttpPost]
        public ActionResult OnChange(String newpassword, String confirmpassword)
        {
            try
            {
                (new LoginRepository()).ChangePasssword(Lookup.Get<User>().Username, confirmpassword, 0);
                return Json(new ActionResponseViewModel { ResponseType = ActionResponseViewModel.Success, Message = "Password has changed." });
            }
            catch (Exception ex)
            {
                return Json(ex.AsActionResponseViewModel());
            }
        }
    }
}
