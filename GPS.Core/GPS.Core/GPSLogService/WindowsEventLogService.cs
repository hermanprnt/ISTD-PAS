using System;
using System.Diagnostics;

namespace GPS.Core.GPSLogService
{
    public class WindowsEventLogService : ILogService
    {
        private readonly EventLog log;

        public WindowsEventLogService(String appName)
        {
            String machineName = Environment.MachineName;
            const String DefaultLogName = "Application";

            if (!EventLog.SourceExists(appName, machineName))
                EventLog.CreateEventSource(appName, DefaultLogName);
            log = new EventLog(DefaultLogName, machineName, appName);
        }

        public void Info(String message)
        {
            if (message != LogExtensions.Break)
                log.WriteEntry(message, EventLogEntryType.Information);
        }

        public void Error(Exception ex)
        {
            log.WriteEntry(ex.GetExceptionMessage(), EventLogEntryType.Error);
        }
    }
}
