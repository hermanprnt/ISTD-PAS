using System;
using System.Collections.Generic;
using System.Linq;
using GPS.Models.Common;
using Toyota.Common.Credential;
using Toyota.Common.Web.Platform;

namespace GPS.CommonFunc
{
    public static class PageControllerExtensions
    {
        public static User GetCurrentUser(this PageController controller)
        {
            User currentUser = controller.Lookup.Get<User>();
            if (currentUser == null)
                throw new InvalidOperationException("Bug: User is null");

            return currentUser;
        }

        public static String GetCurrentUsername(this PageController controller)
        {
            User currentUser = controller.GetCurrentUser();
            return currentUser.Username;
        }

        public static String GetCurrentRegistrationNumber(this PageController controller)
        {
            User currentUser = controller.GetCurrentUser();
            return currentUser.RegistrationNumber;
        }

        public static String GetCurrentUserFullName(this PageController controller)
        {
            User currentUser = controller.GetCurrentUser();
            return currentUser.Name;
        }

        public static UserNameDescription GetCurrentUserNameDescription(this PageController controller, string noReg)
        {
            Toyota.Common.Database.IDBContext db = DatabaseManager.Instance.GetContext();
            IEnumerable<UserNameDescription> result = db.Fetch<UserNameDescription>("Common/GetUserNameDescription", new { NO_REG = noReg });
            db.Close();
            return result.Any() ? result.FirstOrDefault() : new UserNameDescription();
        }
    }
}