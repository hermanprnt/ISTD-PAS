-- =============================================
-- Author:		FID) Intan Puspitasari
-- Create date: 21-07-2016
-- Description:	Validation & Saving Data from uploaded file
-- =============================================
CREATE PROCEDURE [dbo].[sp_price_saveUpload] 
	@PriceType VARCHAR(10), 
	@MaterialNo VARCHAR(50), 
	@VendorCd VARCHAR(50), 
	@ProdPurpose VARCHAR(50), 
	@WarpBuyer VARCHAR(50) = 'X',
	@SourceType VARCHAR(10) = '1',
	@PartColorSfx VARCHAR(12) = 'X',
	@PackingType VARCHAR(15) = '0',
	@CurrCd VARCHAR(50),
    @PriceAmt DECIMAL(18,4), 
	@ValidFrom VARCHAR(50),
	@PriceStatus VARCHAR(10) = 'F',
	@UserId VARCHAR(50)
AS
BEGIN
	DECLARE @MESSAGE VARCHAR(MAX) = ''

	BEGIN TRY
		/** DATA VALIDATION **/
		
		IF NOT EXISTS (SELECT 1 FROM TB_M_MATERIAL_PART WHERE MAT_NO = @MaterialNo)
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM TB_M_MATERIAL_NONPART WHERE MAT_NO = @MaterialNo)
			BEGIN
				SET @MESSAGE = @MESSAGE + 'Material No ' + @MaterialNo + ' is not registered yet in Master Material Part/Non Part \n'
			END
		END

		IF NOT EXISTS (SELECT 1 FROM TB_M_VENDOR WHERE VENDOR_CD = @VendorCd)
		BEGIN
			SET @MESSAGE = @MESSAGE + 'Vendor Code ' + @VendorCd + ' is not registered yet in Master Vendor \n'
		END

		IF NOT EXISTS (SELECT 1 FROM TB_M_EXCHANGE_RATE WHERE CURR_CD = @CurrCd)
		BEGIN
			SET @MESSAGE = @MESSAGE + 'Currency ' + @CurrCd + ' is not registered yet in Master Exchange Rate \n'
		END

		IF (@PriceType = 'Draft')
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM TB_M_SYSTEM WHERE FUNCTION_ID = 'PRI01' AND SYSTEM_CD = @PriceStatus)
			BEGIN
				SET @MESSAGE = @MESSAGE + 'Price Status ' + @PriceStatus + ' is not registered yet in System Master \n'
			END
		END

		IF(@MESSAGE = '')
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM TB_M_SOURCE_LIST WHERE MAT_NO = @MaterialNo AND VENDOR_CD = @VendorCd AND GETDATE() >= VALID_DT_FROM AND GETDATE() <= VALID_DT_TO)
			BEGIN
				SET @MESSAGE = @MESSAGE + 'Material No ' + @MaterialNo + ' and Vendor Code ' + @VendorCd + ' is not registered yet in Source List Master \n'
			END

			IF(@PriceType = 'Draft')
			BEGIN
				IF EXISTS (SELECT 1 FROM TB_M_DRAFT_MATERIAL_PRICE WHERE MAT_NO = @MaterialNo AND WARP_BUYER_CD = @WarpBuyer AND
								SOURCE_TYPE = @SourceType AND PART_COLOR_SFX = @PartColorSfx AND PACKING_TYPE = @PackingType AND
								PRODUCTION_PURPOSE = @ProdPurpose AND VENDOR_CD = @VendorCd AND VALID_DT_FROM = @ValidFrom)
				BEGIN
					SET @MESSAGE = @MESSAGE + 'Data already registered in Draft Price'
				END
			END
			ELSE
			BEGIN 
				IF EXISTS (SELECT 1 FROM TB_M_MATERIAL_PRICE WHERE MAT_NO = @MaterialNo AND
								PRODUCTION_PURPOSE = @ProdPurpose AND VENDOR_CD = @VendorCd AND VALID_DT_FROM = @ValidFrom)
				BEGIN
					SET @MESSAGE = @MESSAGE + 'Data already registered in Master Price'
				END
			END
		END

		IF(@MESSAGE = '')
		BEGIN
			DECLARE @LatestDt VARCHAR(20)
			IF(@PriceType = 'Draft')
			BEGIN
				SELECT @LatestDt = CONVERT(VARCHAR, MAX(VALID_DT_FROM))
				FROM TB_M_DRAFT_MATERIAL_PRICE 
				WHERE MAT_NO = @MaterialNo AND
						  VENDOR_CD = @VendorCd AND PRODUCTION_PURPOSE = @ProdPurpose AND WARP_BUYER_CD = @WarpBuyer AND SOURCE_TYPE = @SourceType AND
						  PART_COLOR_SFX = @PartColorSfx AND PACKING_TYPE = @PackingType
			END
			ELSE
			BEGIN
				SELECT @LatestDt = CONVERT(VARCHAR, MAX(VALID_DT_FROM))
				FROM TB_M_MATERIAL_PRICE 
				WHERE MAT_NO = @MaterialNo AND VENDOR_CD = @VendorCd AND PRODUCTION_PURPOSE = @ProdPurpose AND WARP_BUYER_CD = @WarpBuyer AND
						  SOURCE_TYPE = @SourceType AND PART_COLOR_SFX = @PartColorSfx AND PACKING_TYPE = @PackingType
			END

			IF(CONVERT(DATE, @ValidFrom) < CONVERT(DATE, @LatestDt))
			BEGIN
				SET @MESSAGE = @MESSAGE + 'New Valid Date From ' + dbo.fn_date_format(@ValidFrom) + ' Cannot under Latest Valid Date From ' + dbo.fn_date_format(@LatestDt)
			END
		END

		/** END OF DATA VALIDATION **/

		IF(@MESSAGE = '')
		BEGIN
			DECLARE @MaterialDesc VARCHAR(50) = ''

			IF EXISTS(SELECT 1 FROM TB_M_MATERIAL_PART WHERE MAT_NO = @MaterialNo)
			BEGIN
				SELECT TOP 1 @MaterialDesc = MAT_DESC FROM TB_M_MATERIAL_PART
			END
			ELSE
			BEGIN
				SELECT TOP 1 @MaterialDesc = MAT_DESC FROM TB_M_MATERIAL_NONPART
			END

			EXEC [dbo].[sp_price_processingSave] @UserId, @PriceType, @MaterialNo, @MaterialDesc, @VendorCd, @ProdPurpose, @CurrCd,
				 @PriceAmt, @ValidFrom, @WarpBuyer, @PackingType, @PartColorSfx, @SourceType, @PriceStatus

			SELECT 'Insert Data Successfully\n'
		END
		ELSE
		BEGIN
			SELECT @MESSAGE
		END
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() + '\n'
	END CATCH
END