using System;
using System.Configuration;
using System.Net;
using System.Net.Http;
using System.Security.Principal;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.Http.Controllers;
using System.Web.Http.Filters;

namespace NETFrameworkDummyWS.App_Start
{
    public class BasicAuthenticationAttribute : AuthorizationFilterAttribute
    {
        public override void OnAuthorization(HttpActionContext actionContext)
        {
            if (actionContext.Request.Headers.Authorization == null)
            {
                actionContext.Response = actionContext.Request.CreateResponse(HttpStatusCode.Unauthorized);

                actionContext.Response.Headers.Add("Error", "No credentials provided");
            }
            else
            {
                string authorizationVal = actionContext.Request.Headers
                    .Authorization.Parameter;

                string usernamePasswordString = Encoding.UTF8.GetString(Convert.FromBase64String(authorizationVal));

                string username = usernamePasswordString.Split(':')[0];

                string password = usernamePasswordString.Split(':')[1];

                if (AuthenticateUser(username, password))
                {
                    var identity = new GenericIdentity(username);
                    IPrincipal principal = new GenericPrincipal(identity, null);
                    Thread.CurrentPrincipal = principal;
                    if (HttpContext.Current != null)
                    {
                        HttpContext.Current.User = principal;
                    }
                }
                else
                {
                    actionContext.Response = actionContext.Request
                        .CreateResponse(HttpStatusCode.Unauthorized);

                    actionContext.Response.Headers.Add("Error", "Incorrect Username/password");
                }
            }
        }

        private bool AuthenticateUser(string username, string password)
        {
            return username == ConfigurationManager.AppSettings.Get("UserName") && password == ConfigurationManager.AppSettings.Get("Password");
        }
    }
}