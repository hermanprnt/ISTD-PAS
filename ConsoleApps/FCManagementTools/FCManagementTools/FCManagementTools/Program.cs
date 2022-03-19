using FCManagementTools.Models;
using FCManagementTools.Controller;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Configuration;

namespace FCManagementTools
{
    class Program
    {
        static void Main(string[] args)
        {
            string Folder = WebConfigurationManager.AppSettings["LogDir"];
            string FileName = "LogFCManagement_" + DateTime.Now.ToLongDateString();
            try
            {
                Console.WriteLine("Starting FC Management Tool..\n");
                LibraryRepo.GenerateLog("Starting FC Management Tool..\n", Folder + FileName);
                FC.Instance.ExecFundCommitment(Folder + FileName);
                Console.WriteLine("Finishing FC Management Tool..\n");
                LibraryRepo.GenerateLog("Finishing FC Management Tool..\n", Folder + FileName);
            }
            catch (Exception ex)
            {                
                if (ex.InnerException != null)
                {
                    if (ex.InnerException.InnerException != null)
                    {
                        Console.WriteLine(ex.InnerException.InnerException);
                        LibraryRepo.GenerateLog(ex.InnerException.InnerException.ToString(), Folder + FileName);
                    }
                    Console.WriteLine(ex.InnerException);
                    LibraryRepo.GenerateLog(ex.InnerException.ToString(), Folder + FileName);
                }
                else
                {
                    Console.WriteLine(ex.Message);
                    LibraryRepo.GenerateLog(ex.Message.ToString(), Folder + FileName);                
                }
            }
            Environment.Exit(0);
        }
    }
}
