DECLARE @@DIVISION TABLE (
	DIVISION_ID INT,
	DIVISION_NAME VARCHAR(100)
)

INSERT INTO @@DIVISION
EXEC [dbo].[sp_common_getListDivision] ''

SELECT * FROM (
	SELECT DISTINCT 
		   ROW_NUMBER() OVER (ORDER BY A.CREATED_DT DESC) AS Number,
		   A.COST_CENTER_GRP_CD AS CostCenterGroupCd,
		   A.COST_CENTER_GRP_DESC AS CostCenterGroupDesc,
		   A.DIVISION_CD AS DivisionCd,
		   B.DIVISION_NAME AS DivisionName,
		   A.CREATED_BY AS CreatedBy,
		   A.CREATED_DT AS CreatedDt,
		   A.CHANGED_BY AS ChangedBy,
		   A.CHANGED_DT AS ChangedDt
	FROM TB_M_COST_CENTER_GRP A
		left JOIN @@DIVISION B
		ON A.DIVISION_CD = B.DIVISION_ID
		AND ((A.COST_CENTER_GRP_CD = @CostGroup
				AND isnull(@CostGroup, '') <> ''
				OR (isnull(@CostGroup, '') = '')))
		AND ((A.DIVISION_CD = @DivisionCd
			  AND isnull(@DivisionCd, '') <> ''
			  OR (isnull(@DivisionCd, '') = '')))
) tbl WHERE tbl.Number >= @Start AND tbl.Number <= @Length