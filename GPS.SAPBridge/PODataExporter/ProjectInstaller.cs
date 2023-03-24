using System.ComponentModel;
using System.Configuration.Install;
using System.ServiceProcess;

namespace PODataExporter
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
                ServiceName = "GPSPODataExporterSvc",
                DisplayName = "GPS PO Data Exporter",
                Description = "Service to export PO data to text file.",
                StartType = ServiceStartMode.Automatic
            });
        }
    }
}
