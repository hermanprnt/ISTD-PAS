using System;
using System.Data;
using System.IO;
using System.Net;
using GPS.Core;
using GPS.Core.GPSLogService;
using GPS.Core.TDKSimplifier;
using Toyota.Common.Configuration;

namespace SAPDataImporterConsole
{
    class Import
    {
        public static void ImportDataFromSAP(ILogService logger)
        {
            logger.Info(LogExtensions.Break);
            logger.Info("Process Start");

            try
            {
                ImportData(logger, "PO");
                ImportData(logger, "GR");
                ImportData(logger, "SA");
                ImportData(logger, "IR");
                ImportData(logger, "SL");
            }
            catch (Exception ex)
            {
                logger.Error(ex);
            }
        }

        public static void ImportData(ILogService logger, string type)
        {
            string module = "";
            string function = "";
            string Ftplocation = "";
            string localLocation = "";
            string archiveLocation = "";

            logger.Info("Start Download Data " + type);

            try
            {
                var repo = new SAPImportDataRepository(logger);
                string FtpSettings = repo.GetFtpCredential();
                String[] splittedResult = FtpSettings.Split(';');

                if (splittedResult.Length < 3)
                    throw new NullReferenceException("Bug: Ftp Credential is not set right.");

                NetworkCredential cred = new NetworkCredential(splittedResult[1], splittedResult[2]);

                ConfigurationItem tempPathConfig = TDKConfig.GetSystemConfig("TempFilePath") ?? new ConfigurationItem();
                String tempPath = tempPathConfig.Value;
                switch (type)
                {
                    case "PO":
                        module = POConstant.ModuleId;
                        function = POConstant.FunctionId;
                        Ftplocation = splittedResult[0] + POConstant.FTPLocation;
                        localLocation = tempPath + POConstant.LocalLocation;
                        archiveLocation = splittedResult[0] + POConstant.ArchieveLocation;

                        break;
                    case "GR":
                        module = GRConstant.ModuleId;
                        function = GRConstant.FunctionId;
                        Ftplocation = splittedResult[0] + GRConstant.FTPLocation;
                        localLocation = tempPath + GRConstant.LocalLocation;
                        archiveLocation = splittedResult[0] + GRConstant.ArchieveLocation;

                        break;
                    case "SA":
                        module = SAConstant.ModuleId;
                        function = SAConstant.FunctionId;
                        Ftplocation = splittedResult[0] + SAConstant.FTPLocation;
                        localLocation = tempPath + SAConstant.LocalLocation;
                        archiveLocation = splittedResult[0] + SAConstant.ArchieveLocation;

                        break;
                    case "IR":
                        module = Global_Constant.ModuleId;
                        function = Global_Constant.FunctionId;
                        ConfigurationItem tempPathConfigFtp = TDKConfig.GetSystemConfig("FTPLocationIR") ?? new ConfigurationItem();
                        ConfigurationItem tempPathConfiglocal = TDKConfig.GetSystemConfig("LocalLocationIR") ?? new ConfigurationItem();
                        ConfigurationItem tempPathConfigArchieve = TDKConfig.GetSystemConfig("ArchieveLocationIR") ?? new ConfigurationItem();

                        Ftplocation = splittedResult[0] + tempPathConfigFtp.Value;
                        localLocation = tempPath + tempPathConfiglocal.Value;
                        archiveLocation = splittedResult[0] + tempPathConfigArchieve.Value;

                        break;
                    case "SL":
                        module = Global_Constant.ModuleId;
                        function = Global_Constant.FunctionId;
                        ConfigurationItem tempSLPathConfigFtp = TDKConfig.GetSystemConfig("FTPLocationSL") ?? new ConfigurationItem();
                        ConfigurationItem tempSLPathConfiglocal = TDKConfig.GetSystemConfig("LocalLocationSL") ?? new ConfigurationItem();
                        ConfigurationItem tempSLPathConfigArchieve = TDKConfig.GetSystemConfig("ArchieveLocationSL") ?? new ConfigurationItem();

                        Ftplocation = splittedResult[0] + tempSLPathConfigFtp.Value;
                        localLocation = tempPath + tempSLPathConfiglocal.Value;
                        archiveLocation = splittedResult[0] + tempSLPathConfigArchieve.Value;

                        break;
                }

                DownloadFileFromFTP(Ftplocation, localLocation, cred);
                logger.Info("Data " + type + " Successfully downloaded into temp Folder");

                ReadFiles(logger, type, localLocation, module, function);

                MoveFileToArchieve(logger, type, Ftplocation, localLocation, archiveLocation, cred);
            }
            catch (Exception ex)
            {
                logger.Error(ex);
            }
            finally 
            {
                if (!String.IsNullOrEmpty(localLocation))
                    FileExtension.DeleteAllFile(localLocation);
            }
        }

        public static void DownloadFileFromFTP(string FtpLocation, string localLocation, NetworkCredential cred) 
        {
            FileExtension.CreateDirectory(localLocation);
            FtpHandler.DownloadAllFiles(FtpLocation, localLocation, cred);
        }

        public static void ReadFiles(ILogService logger, string type, string localLocation, string module, string function)
        {
            String[] listfile = Directory.GetFiles(localLocation);
            int totalSuccess = 0;

            try
            {
                if (listfile != null)
                {
                    var repo = new SAPImportDataRepository(logger);
                    Int64 ProcessId = repo.ImportInit(0, "Import Data " + type + " from SAP started", "SYSTEM", "Import Data " + type, null, "INF", module, function, 1);

                    #region Create Data Table 
                    DataTable table = new DataTable();

                    table.Columns.Add("PO_NO");
                    table.Columns.Add("SAP_PO_NO");
                    table.Columns.Add("REF_DOC_NO");
                    table.Columns.Add("MAT_DOC_NO");
                    table.Columns.Add("DOC_YEAR");
                    table.Columns.Add("PO_ITEM");
                    table.Columns.Add("ENTRY_SHEET");
                    table.Columns.Add("STATUS");
                    table.Columns.Add("MESSAGE");
                    table.Columns.Add("IS_DONE");
                    #endregion

                    foreach (var filename in listfile)
                    {
                        try
                        {
                            #region Read file's content and add into data table
                            using (StreamReader reader = new StreamReader(filename))
                            {
                                string RowData;
                                string[] data;

                                while ((RowData = reader.ReadLine()) != null)
                                {
                                    DataRow row = table.NewRow();

                                    data = RowData.Split(new string[] { "\t" }, StringSplitOptions.None);
                                    if (data[0] == "E")
                                        throw new Exception("File not containing data " + type);
                                    switch (type)
                                    {
                                        case "PO":
                                            row["PO_NO"] = data[0];
                                            row["SAP_PO_NO"] = data[1];
                                            row["STATUS"] = data[2];
                                            row["MESSAGE"] = data[3];
                                            break;
                                        case "GR":
                                            row["REF_DOC_NO"] = data[0];
                                            row["MAT_DOC_NO"] = data[1];
                                            row["DOC_YEAR"] = data[2];
                                            row["PO_NO"] = data[3];
                                            row["PO_ITEM"] = data[4];
                                            row["STATUS"] = data[5];
                                            row["MESSAGE"] = data[6];
                                            break;
                                        case "SA":
                                            row["REF_DOC_NO"] = data[0];
                                            row["PO_NO"] = data[1];
                                            row["PO_ITEM"] = data[2];
                                            row["ENTRY_SHEET"] = data[3];
                                            row["STATUS"] = data[4];
                                            row["MESSAGE"] = data[5];
                                            break;
                                        case "IR":
                                            row["REF_DOC_NO"] = data[0];
                                            row["STATUS"] = data[1];
                                            row["ENTRY_SHEET"] = data[2];
                                            row["MESSAGE"] = "["+ Path.GetFileName(filename) + "] "+data[3];
                                            break;
                                        case "SL":
                                            row["REF_DOC_NO"] = data[0];
                                            row["STATUS"] = data[1];
                                            row["MESSAGE"] = "[" + Path.GetFileName(filename) + "] " + data[2];
                                            break;
                                    }
                                    row["IS_DONE"] = "N";
                                    table.Rows.Add(row);
                                }
                                totalSuccess = totalSuccess + 1;
                            }
                            #endregion
                        }
                        catch (Exception ex)
                        {
                            logger.Info("Error Import Data From File " + filename + " : " + ex.Message);
                        }
                    }

                    #region Save Data into Database
                    if (totalSuccess > 0)
                    {
                        string msg = repo.SaveData(type, table, ProcessId, module, function);
                        if (msg != "SUCCESS")
                            throw new Exception(msg);
                    }
                    #endregion

                    logger.Info("Import Data " + type + " Finished Successfully");
                }
                else
                {
                    throw new Exception("No Data " + type + " to be Imported From SAP");
                }
            }
            catch (Exception ex)
            {
                throw new Exception ("Error import data " + type + " : " + ex.Message);
            }
        }

        public static void MoveFileToArchieve(ILogService logger, string type, string Ftplocation, string localLocation, string archiveLocation, NetworkCredential cred)
        {
            String[] listFile = Directory.GetFiles(localLocation);

            int i = 1;
            logger.Info("Move data " + type + " to archieve started");
            foreach (string filename in listFile)
            { 
                FtpHandler.Upload(archiveLocation + Path.GetFileName(filename), filename, cred);
                FtpHandler.Delete(Ftplocation + Path.GetFileName(filename), cred);
                File.Delete(filename);
                i++;
            }
            logger.Info("Move data " + type + " to archieve finished successfully. Moving " + i.ToString() + " file(s)");
        }

    }
}
