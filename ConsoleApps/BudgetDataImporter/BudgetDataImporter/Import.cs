using System;
using System.Data;
using System.IO;
using System.Net;
using GPS.Core;
using GPS.Core.GPSLogService;
using GPS.Core.TDKSimplifier;
using Toyota.Common.Configuration;
using System.Collections.Generic;

namespace BudgetDataImporter
{
    class Import
    {
        private const String FunctionId = "BudgetControl";

        public static void ImportBCSData(ILogService logger)
        {
            //logger.Info(LogExtensions.Break);
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

                NetworkCredential cred = new NetworkCredential(splittedResult[2], splittedResult[3]);

                ConfigurationItem tempPathConfig = TDKConfig.GetSystemConfig("TempFilePath") ?? new ConfigurationItem();
                String tempPath = tempPathConfig.Value;
                string Ftplocation = splittedResult[0];
                string localLocation = tempPath;
                string archiveLocation = splittedResult[1];

                templocation = localLocation; // used in finally statement, delete all files

                DownloadFileFromFTP(Ftplocation, localLocation, cred);

                repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "Download File(s) from FTP Finished");
                #endregion

                #region Process Data
                List<string> result = ReadFiles(repo, logger, localLocation, ProcessId);
                
				try
				{
					MoveFileToArchieve(logger, Ftplocation, localLocation, archiveLocation, cred);
                    repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "Moving to Archive Success");
                }
				catch (Exception ex)
				{
					logger.Error(ex);
                    repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "Moving to Archive Error : " + ex.Message);
                }
				
				try
				{
					String emailResult = repo.SendEmail(ProcessId, FunctionId, result);
					logger.Info("Send email status: " + emailResult);
                    repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "Send Email Success");
                }
				catch (Exception ex)
				{
					logger.Error(ex);
                    repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "Send Email Error : " + ex.Message);
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
                if (!String.IsNullOrEmpty(templocation))
                    FileExtension.DeleteAllFile(templocation);
            }
        }

        public static void DownloadFileFromFTP(string FtpLocation, string localLocation, NetworkCredential cred)
        {
            FileExtension.CreateDirectory(localLocation);
            FtpHandler.DownloadAllFiles(FtpLocation, localLocation, cred);
        }

        public static List<string> ReadFiles(BudgetImportDataRepository repo, ILogService logger, string localLocation, int ProcessId)
        {
            String[] listfile = Directory.GetFiles(localLocation);
            int totaldoc = 0;
            int totalsuccess = 0;
            int totalfail = 0;
            int totalWbsFail = 0;
            int totalWbsSuccess = 0;
            string wbs_no_error_log = "";
            string wbs_year_error_log = "";
            List<string> Error_WBS = new List<string>();
            

            try
            {
                repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "Processing file(s) from FTP Started");

                if (listfile.Length > 0)
                {
                    foreach (var filename in listfile)
                    {
                        wbs_no_error_log = "";
                        wbs_year_error_log = "";
                        totalWbsFail = 0;
                        totalWbsSuccess = 0;

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
                                    wbs_no_error_log = "";
                                    wbs_year_error_log = "";
                                    data = RowData.Split(new string[] { "\t" }, StringSplitOptions.None);

                                    if (data[0] == "E")
                                        throw new Exception("File not containing data Budget SAP");

                                    try
                                    {
                                        Budget dataBudget = new Budget();

                                        dataBudget.WBS_NO = data[0];
                                        wbs_no_error_log = data[0];
                                        dataBudget.ORIGINAL_WBS_NO = data[1];
                                        dataBudget.WBS_YEAR = data[2];
                                        wbs_year_error_log = data[2];
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
                                        dataBudget.WBS_DESCRIPTION = data[14].Trim();
                                        dataBudget.WBS_DIVISION = data[15].Trim() == "" ? 0 : int.Parse(data[15].Trim());
                                        dataBudget.EOA_FLAG = data[16].Trim();
                                        dataBudget.WBS_LEVEL = data[17].Trim() == "" ? 0 : int.Parse(data[17].Trim());

                                        repo.SaveData(ProcessId, dataBudget);
                                        totalWbsSuccess = totalWbsSuccess + 1;
                                        repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "Processing data from file " + filename + ", WBS No " + wbs_no_error_log + " and WBS Year " + wbs_year_error_log + " Success");
                                        logger.Info("Processing data from file " + filename + ", WBS No " + wbs_no_error_log + " and WBS Year " + wbs_year_error_log + " Success");
                                    }
                                    catch (Exception wbsEx)
                                    {
                                        String[] filenamee = filename.Split('/');


                                        Error_WBS.Add(filename + "|" + wbs_no_error_log + "|" + wbs_year_error_log + "|" + wbsEx.Message);
                                        totalWbsFail = totalWbsFail + 1;
                                        repo.InsertLog(ProcessId, "ERR", "Budget Data Importer Service", "Processing data from file " + filename + ", WBS No " + wbs_no_error_log + "and WBS Year " + wbs_year_error_log + ", Error : " + wbsEx.Message);
                                        logger.Info("Processing data from file " + filename + ", WBS No " + wbs_no_error_log + "and WBS Year " + wbs_year_error_log + ", Error : " + wbsEx.Message);
                                    }
                                }
                            }
                            #endregion

                            if (totalWbsFail == 0)
                            {
                                totalsuccess = totalsuccess + 1;
                            }
                            else {
                                totalfail = totalfail + 1;
                            }

                            repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "Processing data from file " + filename + " finished, " + totalWbsFail + " WBS No Failed, " + totalWbsSuccess + " WBS No Success");
                            logger.Info("Processing data from file " + filename + " finished, " + totalWbsFail + " WBS No Failed, " + totalWbsSuccess + " WBS No Success");
                        }
                        catch (Exception fileEx)
                        {
                            Error_WBS.Add(filename + "|" + fileEx.Message);
                            totalfail = totalfail + 1;
                            String message = "Processing data from file " + filename + " Error : " + fileEx.Message;
                            repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", message);
                            logger.Info(message);

                            /*String emailResult = repo.SendEmail(FunctionId, message);
                            logger.Info(emailResult);*/
                        }
                        finally
                        {
                            totaldoc = totaldoc + 1;
                        }
                    }

                    repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "Import Data Budget Finished Successfully");
                    logger.Info("Import Data Budget Finished Successfully");
                    logger.Info("Total Proceed File : " + totaldoc.ToString() + " file(s). Total Success : " + totalsuccess.ToString() + " file(s). Total Fail : " + totalfail.ToString() + " file(s).");
                }
                else
                {
                    Error_WBS.Add("No Data Budget to be Imported");
                    repo.InsertLog(ProcessId, "INF", "Budget Data Importer Service", "No Data Budget to be Imported");
                }
            }
            catch (Exception ex)
            {
                Error_WBS.Add("Error import data budget : " + ex.Message);
                repo.InsertLog(ProcessId, "ERR", "Budget Data Importer Service", "Error import data budget : " + ex.Message);
            }

            return Error_WBS;
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
