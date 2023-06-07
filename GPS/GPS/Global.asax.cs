using GPS.CommonFunc;
using System.Web.Mvc;
using Toyota.Common.Credential;
using Toyota.Common.Web.Platform;
using Toyota.Common.Web;
using Toyota.Common;
using System;
using System.Web;
using System.Web.Routing;
using GPS.Controllers;

namespace GPS
{
    public class MvcApplication : WebApplication
    {
        public MvcApplication()
        {
            ApplicationSettings.Instance.Name = "Procurement Application System";
            ApplicationSettings.Instance.Alias = "PAS";
            ApplicationSettings.Instance.OwnerName = "Toyota Motor Manufacturing Indonesia";
            ApplicationSettings.Instance.OwnerAlias = "TMMIN";
            ApplicationSettings.Instance.OwnerEmail = "tdk@toyota.co.id";
            ApplicationSettings.Instance.Menu.Enabled = true;

            ApplicationSettings.Instance.Security.EnableAuthentication = true;
            ApplicationSettings.Instance.Security.IgnoreAuthorization = true;
            //ApplicationSettings.Instance.Security.EnableSingleSignOn = false;
            //BypassLogin(true);
        }
        private void BypassLogin(bool isBypass)
        {
            if (isBypass)   
            {
                ApplicationSettings.Instance.Security.IgnoreAuthorization = true;
                ApplicationSettings.Instance.Security.SimulateAuthenticatedSession = true;
                ApplicationSettings.Instance.Security.SimulatedAuthenticatedUser = new User()
                {
                    //Username = "danny.fahmi",
                    //Username = "christian_gunawan",   
                    Username = "tony_a",
                    Password = "toyota",
                    FirstName = "Anonymous",
                    LastName = "User",
                    //RegistrationNumber = "00819327"
                    //RegistrationNumber = "09507444"
                    RegistrationNumber = "00212592"
                };



                ApplicationSettings.Instance.Security.SimulatedAuthenticatedUser.Company = new Toyota.Common.Generalist.CompanyInfo()
                {
                    Id = "1000"
                };

            }
            else
            {
                ApplicationSettings.Instance.Security.IgnoreAuthorization = false;
                ApplicationSettings.Instance.Security.SimulateAuthenticatedSession = false;
                ApplicationSettings.Instance.Security.EnableSingleSignOn = false;
            }
        }
        protected new void Application_Start()
        {
            base.Application_Start();

            ModelBinders.Binders.Add(typeof(decimal), new DecimalModelBinder());
            ModelBinders.Binders.Add(typeof(decimal?), new DecimalModelBinder());
        }

        protected void Application_PreSendRequestHeaders(Object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.AppendCacheExtension("no-store, must-revalidate");
            Response.AppendHeader("Pragma", "no-cache");
            Response.AppendHeader("Expires", "0");
        }

        protected override void Startup()
        {
            //ProviderRegistry.Instance.Register<UILayout>(typeof(BootstrapLayout));
            //BootstrapLayout layout = (BootstrapLayout)ApplicationSettings.Instance.UI.GetLayout(); 
            ProviderRegistry.Instance.Register<IUserProvider>(typeof(UserProvider), DatabaseManager.Instance, "SecurityCenter");
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            if (HttpContext.Current.IsCustomErrorEnabled)
            {
                var httpContext = ((MvcApplication)sender).Context;
                var currentController = " ";
                var currentAction = " ";
                var currentRouteData = RouteTable.Routes.GetRouteData(new HttpContextWrapper(httpContext));

                if (currentRouteData != null)
                {
                    if (currentRouteData.Values["controller"] != null && !String.IsNullOrEmpty(currentRouteData.Values["controller"].ToString()))
                    {
                        currentController = currentRouteData.Values["controller"].ToString();
                    }

                    if (currentRouteData.Values["action"] != null && !String.IsNullOrEmpty(currentRouteData.Values["action"].ToString()))
                    {
                        currentAction = currentRouteData.Values["action"].ToString();
                    }
                }

                var ex = Server.GetLastError();
                //var controller = new ErrorController();
                var routeData = new RouteData();
                var action = "GenericError";

                if (ex is HttpException)
                {
                    var httpEx = ex as HttpException;

                    switch (httpEx.GetHttpCode())
                    {
                        case 404:
                            action = "NotFound";
                            break;

                            // others if any
                    }
                }

                httpContext.ClearError();
                httpContext.Response.Clear();
                httpContext.Response.StatusCode = ex is HttpException ? ((HttpException)ex).GetHttpCode() : 500;
                httpContext.Response.TrySkipIisCustomErrors = true;

                routeData.Values["controller"] = "Error";
                routeData.Values["action"] = action;
                routeData.Values["exception"] = new HandleErrorInfo(ex, currentController, currentAction);

                IController errormanagerController = new ErrorController();
                HttpContextWrapper wrapper = new HttpContextWrapper(httpContext);
                var rc = new RequestContext(wrapper, routeData);
                errormanagerController.Execute(rc);
            }
        }
    }
}