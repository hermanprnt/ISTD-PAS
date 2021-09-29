using System;
using System.Collections.Generic;
using GPS.Core;
using System.Configuration;
using System.IO;
using System.Net;
using System.Data;
using GPS.Core.GPSLogService;
using GPS.Core.TDKSimplifier;
using Toyota.Common.Configuration;

namespace BudgetDataImporter
{
    class Import
    {
        public static void ImportData(ILogService logger)
        {
            logger.Info(LogExtensions.Break);
            logger.Info("Process Start");

            string templocation = "";

            try
            {
                #region Download Files
                var repo = new BudgetImportDataRepository(logger);
                int ProcessId = repo.InsertLog(0, "INF", "Budget Data Importer Service", "Budget Data Importer Service Started");

                repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "Download File(s) from FTP Started");

                string FtpSettings = repo.GetFtpCredential();
                String[] splittedResult = FtpSettings.Split(';');

                if (splittedResult.Length < 3)
                    throw new NullReferenceException("Bug: Ftp Credential is not set right.");

                NetworkCredential cred = new NetworkCredential(splittedResult[1], splittedResult[2]);

                ConfigurationItem tempPathConfig = TDKConfig.GetSystemConfig("TempFilePath") ?? new ConfigurationItem();
                String tempPath = tempPathConfig.Value;
                string Ftplocation = splittedResult[0] + "OUTBOUND/";
                string localLocation = tempPath;
                string archiveLocation = splittedResult[0] + "ARCHIVES/";

                templocation = localLocation; // used in finally statement, delete all files

                DownloadFileFromFTP(Ftplocation, localLocation, cred);

                repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "Download File(s) from FTP Finished");
                #endregion

                #region Process Data
                string result = ReadFiles(repo, logger, localLocation, ProcessId);
                if (result.Split('|')[0] != "SUCCESS")
                    throw new Exception(result.Split('|')[1]);
                else
                    MoveFileToArchieve(logger, Ftplocation, localLocation, archiveLocation, cred);
                #endregion
            }
            catch (Exception ex)
            {
                logger.Error(ex);
            }
            finally
            {
                //Note: Delete all file(s) in temp folder, in case there is some error file(s) that left in temp folder
                if (!String.IsNullOrEmpty(templocation))
                    FileExtension.DeleteAllFile(templocation);
            }
        }

        public static void DownloadFileFromFTP(string FtpLocation, string localLocation, NetworkCredential cred)
        {
            FileExtension.CreateDirectory(localLocation);
            FtpHandler.DownloadAllFiles(FtpLocation, localLocation, cred);
        }

        public static string ReadFiles(BudgetImportDataRepository repo, ILogService logger, string localLocation, int ProcessId)
        {
            String[] listfile = Directory.GetFiles(localLocation);
            int totaldoc = 0; int totalsuccess = 0; int totalfail = 0;

            try
            {
                repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "Processing file(s) from FTP Started");

                if (listfile.Length > 0)
                {
                    foreach (var filename in listfile)
                    {
                        repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "Processing data from File " + filename + " started");
                        logger.Info("Processing data from File " + filename + " started");

                        try
                        {
                            #region Read file's content and update into database
                            using (StreamReader reader = new StreamReader(filename))
                            {
                                string RowData;
                                string[] data;

                                while ((RowData = reader.ReadLine()) != null)
                                {
                                    data = RowData.Split(new string[] { "\t" }, StringSplitOptions.None);

                                    if (data[0] == "E")
                                        throw new Exception("File not containing data Budget SAP");

                                    Budget dataBudget = new Budget();

                                    dataBudget.WBS_NO = data[0];
                                    dataBudget.ORIGINAL_WBS_NO = data[1];
                                    dataBudget.WBS_YEAR = data[2];
                                    dataBudget.CURRENCY = data[3];
                                    dataBudget.INITIAL_AMOUNT = data[4].Trim() == "" ? 0 : Double.Parse(data[4].Trim());
                                    dataBudget.INITIAL_RATE = data[5].Trim() == "" ? 0 : Double.Parse(data[5].Trim());
                                    dataBudget.INITIAL_BUDGET = data[6].Trim() == "" ? 0 : Double.Parse(data[6].Trim());
                                    dataBudget.ADJUSTED_BUDGET = data[7].Trim() == "" ? 0 : Double.Parse(data[7].Trim());
                                    dataBudget.REMAINING_BUDGET_ACTUAL = data[8].Trim() == "" ? 0 : Double.Parse(data[8].Trim());
                                    dataBudget.REMAINING_BUDGET_INITIAL_RATE = data[9].Trim() == "" ? 0 : Double.Parse(data[9].Trim());
                                    dataBudget.BUDGET_CONSUME_GR_SA = data[10].Trim() == "" ? 0 : Double.Parse(data[10].Trim());
                                    dataBudget.BUDGET_CONSUME_INITIAL_RATE = data[11].Trim() == "" ? 0 : Double.Parse(data[11].Trim());
                                    dataBudget.BUDGET_COMMITMENT_PR_PO = data[12].Trim() == "" ? 0 : Double.Parse(data[12].Trim());
                                    dataBudget.BUDGET_COMMITMENT_INITIAL_RATE = data[13].Trim() == "" ? 0 : Double.Parse(data[13].Trim());

                                    repo.SaveData(ProcessId, dataBudget);
                                }
                            }
                            #endregion
                            totalsuccess = totalsuccess + 1;
                            repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "Processing data from file " + filename + " finished");
                            logger.Info("Processing data from file " + filename + " finished");
                        }
                        catch (Exception ex)
                        {
                            totalfail = totalfail + 1;
                            logger.Info("Processing data from file " + filename + " failed : " + ex.Message);
                        }
                        finally
                        {
                            totaldoc = totaldoc + 1;
                        }
                    }

                    repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "Import Data Budget Finished Successfully");
                    logger.Info("Import Data Budget Finished Successfully");
                    logger.Info("Total Proceed File : " + totaldoc.ToString() + " file(s). Total Success : " + totalsuccess.ToString() + " file(s). Total Fail : " + totalfail.ToString() + " file(s).");
                    return "SUCCESS|";
                }
                else
                {
                    repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "No Data Budget to be Imported");
                    return "ERROR|No Data Budget to be Imported";
                }
            }
            catch (Exception ex)
            {
                repo.InsertLog(ProcessId, "ERR", "Budget Data Importer Service", "Error import data budget : " + ex.Message);
                return "ERROR|Error import data budget : " + ex.Message;
            }
        }

        public static void MoveFileToArchieve(ILogService logger, string Ftplocation, string localLocation, string archiveLocation, NetworkCredential cred)
        {
            String[] listFile = Directory.GetFiles(localLocation);

            int i = 0;
            logger.Info("Move file(s) to archieve started");
            foreach (string filename in listFile)
            {
                FtpHandler.Upload(archiveLocation + Path.GetFileName(filename), filename, cred);
                FtpHandler.Delete(Ftplocation + Path.GetFileName(filename), cred);
                File.Delete(filename);
                i++;
            }
            logger.Info("Move file(s) to archieve finished successfully. Moving " + i.ToString() + " file(s)");
        }
    }
}
