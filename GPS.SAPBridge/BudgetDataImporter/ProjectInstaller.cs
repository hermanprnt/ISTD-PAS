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
                ServiceName = "GPSBudgetDataImporterSvc",
                DisplayName = "GPS Budget Data Importer",
                Description = "Service to import budget data from text file to database.",
                StartType = ServiceStartMode.Automatic
            });
        }
    }
}
