using System.ComponentModel;
using System.Configuration.Install;
using System.ServiceProcess;

namespace GRDataExporter
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
                ServiceName = "GPSGRDataExporterSvc",
                DisplayName = "GPS GR Data Exporter",
                Description = "Service to export GR data to text file.",
                StartType = ServiceStartMode.Automatic
            });
        }
    }
}
