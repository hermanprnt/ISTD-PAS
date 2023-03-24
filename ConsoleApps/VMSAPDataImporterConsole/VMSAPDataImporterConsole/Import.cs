using System;
using System.Data;
using System.IO;
using System.Net;
using GPS.Core;
using GPS.Core.GPSLogService;
using GPS.Core.TDKSimplifier;
using Toyota.Common.Configuration;

namespace VMSAPDataImporterConsole
{
    class Import
    {
        public static void ImportDataFromSAP(ILogService logger)
        {
            logger.Info("Process Start");

            string templocation = "";

            try
            {
                #region Download Files
                var repo = new VMSAPImportDataRepository(logger);
                string FtpSettings = repo.GetFtpCredential();
                String[] splittedResult = FtpSettings.Split(';');

                if (splittedResult.Length < 3)
                    throw new NullReferenceException("Bug: Ftp Credential is not set right.");

                NetworkCredential cred = new NetworkCredential(splittedResult[2], splittedResult[3]);

                string module = "0";
                string function = "001005";
                string Ftplocation = splittedResult[0];
                ConfigurationItem tempPathConfig = TDKConfig.GetSystemConfig("TempFilePath") ?? new ConfigurationItem();
                string localLocation = tempPathConfig.Value; 
                string archiveLocation = splittedResult[1];

                templocation = localLocation; // used in finally statement, delete all files

                DownloadFileFromFTP(Ftplocation, localLocation, cred);
                #endregion

                #region Process Data
                Int64 ProcessId = 0;
                string result = ReadFiles(logger, localLocation, module, function);
                if (result.Split('|')[0] == "SUCCESS")
                    ProcessId = Int64.Parse(result.Split('|')[2]);
                else
                    throw new Exception(result.Split('|')[2]);
                #endregion

                #region Move To Archieve
                MoveFileToArchieve(logger, Ftplocation, localLocation, archiveLocation, cred);
                #endregion

                #region Save Data to TB_R_
                //Note : If import to temporary table is success
                if (result != "0")
                {
                    result = repo.SaveData(ProcessId);
                    if (result != "SUCCESS")
                        throw new Exception(result);
                }
                #endregion
            }
            catch (Exception ex)
            {
                logger.Error(ex);
            }
            finally
            { 
                //Note: Delete all file(s) in temp folder, in case there is some error file(s) that left in temp folder
                if(!String.IsNullOrEmpty(templocation))
                   FileExtension.DeleteAllFile(templocation);
            }
        }

        public static void DownloadFileFromFTP(string FtpLocation, string localLocation, NetworkCredential cred)
        {
            FileExtension.CreateDirectory(localLocation);
            FtpHandler.DownloadAllFiles(FtpLocation, localLocation, cred);
        }

        public static void MoveFileToArchieve(ILogService logger, string Ftplocation, string localLocation, string archiveLocation, NetworkCredential cred)
        {
            String[] listFile = Directory.GetFiles(localLocation);

            int i = 0;
            logger.Info("Move Vendor Master SAP file(s) to archieve started");
            foreach (string filename in listFile)
            {
                FtpHandler.Upload(archiveLocation + Path.GetFileName(filename), filename, cred);
                FtpHandler.Delete(Ftplocation + Path.GetFileName(filename), cred);
                File.Delete(filename);
                i++;
            }
            logger.Info("Move data Vendor Master SAP file(s) to archieve finished successfully. Moving " + i.ToString() + " file(s)");
        }

        public static string ReadFiles(ILogService logger, string localLocation, string module, string function)
        {
            String[] listfile = Directory.GetFiles(localLocation);
            int totalSuccess = 0;

            try
            {
                if (listfile != null)
                {
                    var repo = new VMSAPImportDataRepository(logger);
                    Int64 ProcessId = repo.ImportInit(0, "Import Data Vendor Master SAP from SAP started", "SYSTEM", "Import Data Vendor Master SAP", null, "INF", module, function, 1);

                    #region Create Data Table 
                    DataTable table = new DataTable();

                    table.Columns.Add("VENDOR_CD");
                    table.Columns.Add("VENDOR_NAME");
                    table.Columns.Add("VENDOR_PLANT");
                    table.Columns.Add("SAP_VENDOR_ID");
                    table.Columns.Add("PAYMENT_METHOD_CD");
                    table.Columns.Add("PAYMENT_TERM_CD");
                    table.Columns.Add("DELETION_FLAG");            
                    table.Columns.Add("VENDOR_ADDRESS");
                    table.Columns.Add("POSTAL_CODE");
                    table.Columns.Add("CITY");
                    table.Columns.Add("ATTENTION");
                    table.Columns.Add("PHONE");
                    table.Columns.Add("FAX");
                    table.Columns.Add("COUNTRY");
                    table.Columns.Add("EMAIL_ADDR");
                    table.Columns.Add("CREATED_BY");
                    table.Columns.Add("CREATED_DT");
                    table.Columns.Add("STATUS");

                    #endregion

                    int FILE_NO = 1;
                    foreach (var filename in listfile)
                    {
                        try
                        {
                            #region Read file's content and add into data table
                            using (StreamReader reader = new StreamReader(filename))
                            {
                                string RowData;
                                string[] data;

                                int SEQ = 1;
                                while ((RowData = reader.ReadLine()) != null)
                                {
                                    DataRow row = table.NewRow();

                                    data = RowData.Split(new string[] { "\t" }, StringSplitOptions.None);

                                    if (data[0] == "E")
                                        throw new Exception("File not containing data PO");

                                    row["VENDOR_CD"] = data[0];
                                    row["VENDOR_NAME"] = data[2];
                                    row["VENDOR_PLANT"] = data[1];
                                    row["SAP_VENDOR_ID"] = data[0];
                                    row["PAYMENT_METHOD_CD"] = data[11];
                                    row["PAYMENT_TERM_CD"] = data[12];
                                    row["DELETION_FLAG"] = data[13];
                                    row["VENDOR_ADDRESS"] = data[3];
                                    row["POSTAL_CODE"] = data[5];
                                    row["CITY"] = data[4];
                                    row["ATTENTION"] = data[10];
                                    row["PHONE"] = data[7];
                                    row["FAX"] = (data[8].Length>16) ? data[8].Remove(15) : data[8];
                                    row["COUNTRY"] = data[6];
                                    row["EMAIL_ADDR"] = data[9];
                                    row["CREATED_BY"] = "SYSTEM";
                                    row["CREATED_DT"] = DateTime.Now.Date;
                                    row["STATUS"] = "0";

                                    table.Rows.Add(row);
                                    SEQ++;
                                }
                                totalSuccess = totalSuccess + 1;
                            }
                            #endregion
                        }
                        catch (Exception ex)
                        {
                            logger.Info("Error Import Data From File " + filename + " : " + ex.Message);
                        }
                        FILE_NO++;
                    }

                    #region Save Temp Data into Database
                    if (totalSuccess > 0)
                    {
                        string msg = repo.SaveTemp(table);
                        if (msg != "SUCCESS")
                            throw new Exception(msg);
                    }
                    #endregion

                    logger.Info("Import Data Vendor Master SAP Finished Successfully");
                    return "SUCCESS|" + totalSuccess.ToString() + "|" + ProcessId.ToString();
                }
                else
                {
                    return "ERROR|0|No Data Vendor Master SAP to be Imported";
                }
            }
            catch (Exception ex)
            {
                return "ERROR|0|Error import data Vendor Master SAP : " + ex.Message;
            }
        }
    }
}
