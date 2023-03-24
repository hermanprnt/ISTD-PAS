using System;
using System.Web.Mvc;
using GPS.Models.Master;

namespace GPS.Controllers.Master
{
    public class DisplayMessageController : Controller
    {
        [HttpPost]
        public String GetDisplayMessage(String messageId)
        {
            DisplayMessage message = DisplayMessageRepository.Instance.GetDisplayMessage(messageId);
            if (message == null)
                return String.Empty;

            return message.MESSAGE_TEXT;
        }
    }
}