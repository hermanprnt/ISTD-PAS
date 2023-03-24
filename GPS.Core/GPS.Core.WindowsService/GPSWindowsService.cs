using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Threading.Tasks;
using System.Timers;
using GPS.Core.GPSLogService;
using GPS.Core.ViewModel;

namespace GPS.Core.WindowsService
{
    public abstract class GPSWindowsService : ServiceBase
    {
        private readonly Timer scheduleChecker;
        private readonly SchedulerRepository repo = new SchedulerRepository();

        protected List<string> logtemp { get; set; }
        protected ILogService Logger { get; set; }
        protected ITask CurrentTask { get; set; }
        protected String ProcessId { get; set; }

        protected GPSWindowsService()
        {
            Logger = new DummyLogService();
            logtemp = new List<string>();

            const Int32 OneMinuteSpan = 60 * 1000;
            scheduleChecker = new Timer(OneMinuteSpan);
            scheduleChecker.AutoReset = true;
            scheduleChecker.Enabled = true;
            scheduleChecker.Elapsed += (sender, args) => { CheckApproachingSchedule(); };
        }

        private void CheckApproachingSchedule()
        {
            try
            {
                logtemp.Add(LogExtensions.Break);
                logtemp.Add("Check approaching schedule: begin");

                logtemp.Add("Get schedule list: begin");
                CurrentTask.ScheduleList = repo.GetScheduleList(CurrentTask.FunctionId);
                logtemp.Add("Get schedule list: end");

                var approaching = GetApproachingSchedule(CurrentTask, isIncludeOneMinuteBehind: true);
                IList<RegisteredSchedule> registeredSchList = repo.GetRegisteredSchedule(approaching.FunctionId);
                Boolean canRunNow = approaching.Datetime.IsInRunningTimeFrame();
                Boolean isRegistered = registeredSchList.Any(sch => sch.SystemCode == approaching.SystemCode);
                Boolean isAnyRunning = registeredSchList.Any(sch => sch.Status == TaskStatus.Running);
                Boolean isAnyQueue = registeredSchList.Any(sch => sch.Status == TaskStatus.Queued);

                if (isRegistered)
                {
                    approaching = GetApproachingSchedule(CurrentTask, isIncludeOneMinuteBehind: false);
                    isRegistered = registeredSchList.Any(sch => sch.SystemCode == approaching.SystemCode);
                }

                if ((!canRunNow && !isRegistered && !isAnyRunning && !isAnyQueue) ||
                    (!canRunNow && !isRegistered && isAnyRunning && !isAnyQueue))
                {
                    logtemp.Clear();
                    return;
                }

                foreach (string log in logtemp)
                {
                    Logger.Info(log);
                }

                var registeredSchedule = new RegisteredSchedule
                {
                    ProcessId = ProcessId,
                    FunctionId = approaching.FunctionId,
                    SystemCode = approaching.SystemCode,
                    PlanExecutionTime = approaching.Datetime
                };

                if (canRunNow && !isRegistered && !isAnyRunning && !isAnyQueue)
                {
                    registeredSchedule.Status = TaskStatus.Running;
                    registeredSchedule.ActualExecutionTime = DateTime.Now;
                    repo.RegisterNew(registeredSchedule);

                    Logger.Info("Register new task then run immediately");

                    RunImmediately(registeredSchedule, CurrentTask);
                }
                else if (canRunNow && !isRegistered && isAnyRunning)
                {
                    registeredSchedule.Status = TaskStatus.Queued;
                    repo.RegisterNew(registeredSchedule);
                }

                if (isAnyQueue)
                {
                    var queued =
                        registeredSchList.OrderBy(sch => sch.PlanExecutionTime)
                            .First(sch => sch.Status == TaskStatus.Queued);

                    queued.FunctionId = approaching.FunctionId;
                    queued.Status = TaskStatus.Running;
                    queued.ActualExecutionTime = DateTime.Now;
                    repo.UpdateQueuedToRun(queued);

                    Logger.Info("Running queued task");

                    RunImmediately(queued, CurrentTask);
                }

                Logger.Info("Check approaching schedule: end");
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
            }
        }

        private void RunImmediately(RegisteredSchedule scheduledToBeRun, ITask currentTask)
        {
            Task.Factory.StartNew(() =>
            {
                Logger.Info("Running task: begin");

                var stopwatch = new Stopwatch();
                try
                {
                    var realTask = Task.Factory.StartNew(currentTask.OnSchedule, currentTask.TaskControl);
                    realTask.Wait();

                    stopwatch.Stop();
                    scheduledToBeRun.Status = TaskStatus.Finish;
                    scheduledToBeRun.ActualExecutionTime = DateTime.Now;
                    var internalRepo = new SchedulerRepository();
                    internalRepo.UpdateRunningToFinish(scheduledToBeRun);

                    Logger.Info("Running task: end " + stopwatch.ElapsedMilliseconds.ToString() + "ms");
                }
                catch (Exception ex)
                {
                    Logger.Error(ex);
                }
            });
        }

        private Schedule GetApproachingSchedule(ITask currentTask, Boolean isIncludeOneMinuteBehind)
        {
            IList<NameValueItem> scheduleList = currentTask.ScheduleList ?? new List<NameValueItem>();
            if (scheduleList.Count == 0)
                throw new InvalidOperationException("Schedule list is empty.");

            IList<Schedule> timeSpanList = GenerateTimeSpanList(currentTask.FunctionId, scheduleList, isForToday: true);
            IList<Schedule> inTimeFrameScheduleList = GetInTimeFrameScheduleList(isIncludeOneMinuteBehind, timeSpanList);
            if (!inTimeFrameScheduleList.Any())
                timeSpanList = GenerateTimeSpanList(currentTask.FunctionId, scheduleList, isForToday: false);

            inTimeFrameScheduleList = GetInTimeFrameScheduleList(isIncludeOneMinuteBehind, timeSpanList);
            Schedule approaching = timeSpanList.SingleOrDefault(sch => sch.Span == inTimeFrameScheduleList.Min(schi => schi.Span));

            return approaching;
        }

        private IList<Schedule> GetInTimeFrameScheduleList(Boolean isIncludeOneMinuteBehind, IList<Schedule> timeSpanList)
        {
            return (isIncludeOneMinuteBehind
                ? timeSpanList.Where(schi => schi.Datetime.IsInScheduleTimeFrame())
                : timeSpanList.Where(schi => schi.Span > 0)).ToList();
        }

        private IList<Schedule> GenerateTimeSpanList(String functionId, IList<NameValueItem> scheduleList, Boolean isForToday)
        {
            return scheduleList
                .Select(tl =>
                    new Schedule
                    {
                        FunctionId = functionId,
                        SystemCode = tl.Name,
                        Datetime = isForToday ? ConvertToCurrentDatetime(tl.Value) : ConvertToCurrentDatetime(tl.Value).AddDays(1),
                        Span = (isForToday ? ConvertToCurrentDatetime(tl.Value) : ConvertToCurrentDatetime(tl.Value).AddDays(1)).GetMillisecondSpan()
                    })
                .ToList();
        }

        private DateTime ConvertToCurrentDatetime(String scheduledTime)
        {
            String[] splittedTime = scheduledTime.Split(':');
            Int32 hour = Convert.ToInt32(splittedTime[0]);
            Int32 minute = Convert.ToInt32(splittedTime[1]);
            var now = DateTime.Now;
            var dt = new DateTime(now.Year, now.Month, now.Day, hour, minute, 0);

            return dt;
        }

        public void StartScheduler(string log)
        {
            logtemp.Clear();
            logtemp.Add(log);

            scheduleChecker.Start();
            ProcessId = repo.GetNewProcessId(ServiceName, CurrentTask.FunctionId);
            CheckApproachingSchedule();
        }

        protected void StopScheduler()
        {
            scheduleChecker.Enabled = false;
            scheduleChecker.Stop();
            scheduleChecker.Close();
        }

        protected override void OnStart(string[] args)
        {
            StartScheduler("");
        }

        protected override void OnStop()
        {
            StopScheduler();
        }
    }
}