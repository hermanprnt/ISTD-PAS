using System.ComponentModel;
using System.Configuration.Install;
using System.ServiceProcess;

namespace SAPDataImporter
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
                ServiceName = "GPSPOSAPDataImporterSvc",
                DisplayName = "GPS PO SAP Data Importer",
                Description = "Service to import PO data from SAP (text file) to database.",
                StartType = ServiceStartMode.Automatic
            });
        }
    }
}
