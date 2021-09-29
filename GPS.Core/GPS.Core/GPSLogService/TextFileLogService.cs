using System;
using System.IO;
using System.Text;
using GPS.Core.TDKSimplifier;

namespace GPS.Core.GPSLogService
{
    public class TextFileLogService : ILogService
    {
        private readonly String logFilepath;

        public TextFileLogService()
        {
            logFilepath = TDKConfig.GetTextLogFilepath();
        }

        public void Info(String message)
        {
            WriteLog(message);
        }

        public void Error(Exception ex)
        {
            WriteLog(ex.Message);
        }

        public void RawError(Exception ex)
        {
            WriteLog(ex.GetExceptionMessage());
        }

        private void WriteLog(String message)
        {
            String dirpath = logFilepath.Replace(Path.GetFileName(logFilepath), String.Empty);
            if (!Directory.Exists(dirpath))
                Directory.CreateDirectory(dirpath);
            Int32 currentYear = DateTime.Now.Year;
            String lastYearLog = logFilepath.Replace(currentYear.ToString(), (currentYear - 1).ToString());
            if (File.Exists(lastYearLog))
                File.Delete(lastYearLog);
            var writer = File.Exists(logFilepath) ? File.AppendText(logFilepath) : new StreamWriter(logFilepath, false, Encoding.UTF8);
            using (writer)
                if (message == LogExtensions.Break)
                    writer.WriteLine();
                else
                    writer.WriteLine(DateTime.Now + " --> " + message);
        }
    }
}