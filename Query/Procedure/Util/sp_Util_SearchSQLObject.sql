CREATE PROCEDURE [dbo].[sp_Util_SearchSQLObject]
    @searchString VARCHAR(MAX),
    @notContain VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON
    
    SELECT DISTINCT
    sysobjects.[name] ObjectName,
    CASE
        WHEN sysobjects.xtype = 'P' THEN 'Stored Procedure'
        WHEN sysobjects.xtype = 'TF' THEN 'Function'
        WHEN sysobjects.xtype = 'TR' THEN 'Trigger'
        WHEN sysobjects.xtype = 'V' THEN 'View'
    END ObjectType,
    '' ObjectDesc
    FROM sysobjects, syscomments
    WHERE sysobjects.[id] = syscomments.[id]
        AND sysobjects.[type] IN ('P','TF','TR','V')
        AND sysobjects.[category] = 0
        AND CHARINDEX(@searchString, syscomments.[text]) > 0
        AND ((CHARINDEX(@notContain, syscomments.[text]) = 0
        OR CHARINDEX(@notContain, syscomments.[text]) <> 0))
    UNION
    SELECT
    j.[name] ObjectName,
    'SQL Job' ObjectType,
    'JobId: ' + CAST(j.job_id AS NVARCHAR(50)) + ', ServName: ' + s.srvname +
    ', StepId: ' + CAST(js.step_id AS NVARCHAR(50)) + ', IsEnabled: ' + CAST(j.[enabled] AS NVARCHAR(50))
    ObjectDesc
    FROM msdb.dbo.sysjobs j
    JOIN msdb.dbo.sysjobsteps js ON js.job_id = j.job_id
    JOIN [master].dbo.sysservers s ON s.srvid = j.originating_server_id
    WHERE js.command LIKE N'%' + @searchString + '%' AND js.command NOT LIKE N'%' + @notContain + '%'
    
    SET NOCOUNT OFF
END