using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;
using GPS.Core.TDKSimplifier;
using Toyota.Common.Configuration;
using Toyota.Common.Database;
using Toyota.Common.Web.Platform;

namespace GPS.CommonFunc
{
    // NOTE: this class created because TDK DbContext doesn't have function to retrieve as DataTable
    public class DummyDatabaseAgent : IDisposable
    {
        private DbConnection connection;
        private DbProviderFactory factory;

        private readonly LocationConstants defaultLocation = new LocationConstants();
        private readonly Regex queryParamRgx = new Regex("(?<!@)@\\w+", RegexOptions.Compiled);

        public DummyDatabaseAgent()
        {
            ConnectionDescriptor connectionDesc = TDKConfig.GetConnectionDescriptor();
            Open(connectionDesc);
        }

        private void Open(ConnectionDescriptor connectionDesc)
        {
            factory = DbProviderFactories.GetFactory(connectionDesc.ProviderName);
            connection = factory.CreateConnection();
            if (connection == null)
                throw new Exception("Connection creation from factory failed.");

            connection.ConnectionString = connectionDesc.ConnectionString;
            connection.Open();
        }

        private void Close()
        {
            if (connection != null)
            {
                if (connection.State == ConnectionState.Open)
                    connection.Close();

                connection.Dispose();
                connection = null;
            }
        }

        public DataTable FetchDataTable(String sqlFileOrString, params Object[] args)
        {
            String queryString = GetQueryString(sqlFileOrString);

            var dt = new DataTable();
            using (DbCommand cmd = BuildSqlCommand(queryString, args))
            {
                using (DbDataAdapter dataAdapter = BuildSelectDataAdapter(cmd))
                    dataAdapter.Fill(dt);
            }

            return dt;
        }

        private String GetQueryString(String sqlFileOrString)
        {
            ISqlLoader sqlLoader = new FileSqlLoader(defaultLocation.SQLStatement);
            String queryString = sqlLoader.LoadScript(sqlFileOrString);
            if (String.IsNullOrEmpty(queryString))
                queryString = sqlFileOrString;

            return queryString;
        }

        private DbCommand BuildSqlCommand(String queryString, Object[] queryParams)
        {
            DbCommand builtSqlCommand = connection.CreateCommand();
            builtSqlCommand.CommandText = queryString;
            builtSqlCommand.CommandType = CommandType.Text;
            BuildSqlCommandParameter(ref builtSqlCommand, queryParams);

            return builtSqlCommand;
        }

        private void BuildSqlCommandParameter(ref DbCommand builtSqlCommand, Object[] queryParams)
        {
            builtSqlCommand.Parameters.Clear();
            MatchCollection matches = queryParamRgx.Matches(builtSqlCommand.CommandText);
            foreach (Match match in matches)
            {
                DbParameter dbParam = builtSqlCommand.CreateParameter();

                String paramAlias = match.Value.Replace("@", "");
                Int32 paramIdx = 0;
                Object currentParam;
                if (Int32.TryParse(paramAlias, out paramIdx))
                {
                    dbParam.ParameterName = paramIdx.ToString();
                    dbParam.Value = queryParams[paramIdx] ?? DBNull.Value;
                }
                else
                {
                    dbParam.ParameterName = paramAlias;
                    foreach (Object param in queryParams)
                    {
                        PropertyInfo prop = param.GetType().GetProperty(paramAlias);
                        if (prop != null)
                        {
                            dbParam.Value = prop.GetValue(param, null) ?? DBNull.Value;
                            break;
                        }
                    }
                }

                builtSqlCommand.Parameters.Add(dbParam);
            }
        }

        private DbDataAdapter BuildSelectDataAdapter(DbCommand builtSqlCommand)
        {
            DbDataAdapter builtDataAdapter = factory.CreateDataAdapter();
            if (builtDataAdapter == null)
                throw new Exception("Data Adapter creation from factory failed.");

            builtDataAdapter.SelectCommand = builtSqlCommand;
            return builtDataAdapter;
        }

        public void Dispose()
        {
            Close();
            GC.SuppressFinalize(this);
        }
    }
}