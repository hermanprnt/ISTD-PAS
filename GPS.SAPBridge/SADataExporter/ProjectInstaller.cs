using System.ComponentModel;
using System.Configuration.Install;
using System.ServiceProcess;

namespace SADataExporter
{
    [RunInstaller(true)]
    public partial class ProjectInstaller : Installer
    {
        public ProjectInstaller()
        {
            InitializeComponent();

            Installers.Add(new ServiceProcessInstaller
            {
                Account = ServiceAccount.LocalService,
                Username = null,
                Password = null
            });

            Installers.Add(new ServiceInstaller
            {
                ServiceName = "GPSSADataExporterSvc",
                DisplayName = "GPS SA Data Exporter",
                Description = "Service to export SA data to text file.",
                StartType = ServiceStartMode.Automatic
            });
        }
    }
}
