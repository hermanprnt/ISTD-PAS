IF OBJECT_ID('tempdb..#tmpMaterial') IS NULL
BEGIN
	CREATE TABLE #tmpMaterial
	(
		MaterialNo VARCHAR(23),
		MaterialDesc VARCHAR(50),
		UoM VARCHAR(3),
		CarFamilyCode VARCHAR(4),
		MaterialTypeCode VARCHAR(4),
		MaterialGroupCode VARCHAR(9),
		MRPType VARCHAR(2),
		ReorderValue DECIMAL(18,2),
		ReorderMethod VARCHAR(2),
		StandardDelivTime INT,
		AvgDeliveryConsump DECIMAL(18,2),
		MinStock DECIMAL(18,2),
		MaxStock DECIMAL(18,2),
		PcsPerKanban DECIMAL(18,2),
		MRPFlag CHAR(1),
		ValuationClass VARCHAR(20),
		StockFlag CHAR(1),
		AssetFlag CHAR(1),
		QuotaFlag CHAR(1),
		ConsignmentCode VARCHAR(1),
		DeletionFlag CHAR(1),
		CreatedBy VARCHAR(20),
		CreatedDate DATETIME,
		ChangedBy VARCHAR(20),
		ChangedDate DATETIME
	)
END