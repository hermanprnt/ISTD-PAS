BEGIN TRANSACTION
BEGIN TRY
	IF(@TYPE = 'ITEM')
	BEGIN
		INSERT INTO TB_T_PR_ITEM
				([PROCESS_ID]
				,[ITEM_NO]
				,[ITEM_TYPE]
				,[IS_PARENT]
				,[PROCUREMENT_PURPOSE]
				,[MAT_NO]
				,[MAT_DESC]
				,[COST_CENTER_CD]
				,[WBS_NO]
				,[WBS_NAME]
				,[GL_ACCOUNT]
				,[ITEM_CLASS]
				,[ITEM_CLASS_DESC]
				,[VALUATION_CLASS]
				,[VALUATION_CLASS_DESC]
				,[SOURCE_TYPE]
				,[PACKING_TYPE]
				,[PART_COLOR_SFX]
				,[SPECIAL_PROC_TYPE]
				,[CAR_FAMILY_CD]
				,[MAT_TYPE_CD]
				,[MAT_GRP_CD]
				,[ORI_ITEM_QTY]
				,[NEW_ITEM_QTY]
				,[ITEM_UOM]
				,[ORI_CURR_CD]
				,[ORI_PRICE_PER_UOM]
				,[NEW_PRICE_PER_UOM]
				,[ORI_AMOUNT]
				,[NEW_AMOUNT]
				,[LOCAL_CURR_CD]
				,[EXCHANGE_RATE]
				,[ORI_LOCAL_AMOUNT]
				,[NEW_LOCAL_AMOUNT]
				,[DELIVERY_PLAN_DT]
				,[VENDOR_CD]
				,[VENDOR_NAME]
				,[RELEASE_FLAG]
				,[QUOTA_FLAG]
				,[NEW_FLAG]
				,[UPDATE_FLAG]
				,[DELETE_FLAG]
				,[CREATED_BY]
				,[CREATED_DT]
				,[CHANGED_BY]
				,[CHANGED_DT]
				,[ASSET_CATEGORY]
				,[ASSET_CLASS]
				,[ASSET_LOCATION]
				,[ASSET_NO]
				,[PR_NEXT_STATUS]
				,[COMPLETION]
				,[OPEN_QTY]
				,[USED_QTY]
				,[BUDGET_REF])
		SELECT @PROCESS_ID
				,@NEW_ITEM_NO
				,ITEM_TYPE
				,IS_PARENT
				,PROCUREMENT_PURPOSE
				,MAT_NO
				,MAT_DESC
				,COST_CENTER_CD
				,WBS_NO
				,WBS_NAME
				,GL_ACCOUNT
				,ITEM_CLASS
				,ITEM_CLASS_DESC
				,VALUATION_CLASS
				,VALUATION_CLASS_DESC
				,SOURCE_TYPE
				,PACKING_TYPE
				,PART_COLOR_SFX
				,SPECIAL_PROC_TYPE
				,CAR_FAMILY_CD
				,MAT_TYPE_CD
				,MAT_GRP_CD
				,0				--ori item qty
				,NEW_ITEM_QTY
				,ITEM_UOM
				,ORI_CURR_CD
				,0				--ori price 
				,NEW_PRICE_PER_UOM
				,0				--ori amount
				,NEW_AMOUNT
				,LOCAL_CURR_CD
				,EXCHANGE_RATE
				,0				--ori local amount
				,NEW_LOCAL_AMOUNT
				,DELIVERY_PLAN_DT
				,VENDOR_CD
				,VENDOR_NAME
				,'N'				--release flag
				,QUOTA_FLAG
				,'Y'				--new flag
				,'N'				--update flag
				,'N'				--delete flag
				,@USER_ID
				,GETDATE()
				,NULL
				,NULL
				,ASSET_CATEGORY
				,ASSET_CLASS
				,ASSET_LOCATION
				,ASSET_NO
				,'11'			--pr next status
				,COMPLETION
				,0				--open qty
				,0				--used qty
				,BUDGET_REF
		FROM TB_T_PR_ITEM WHERE PROCESS_ID = @PROCESS_ID AND ITEM_NO = @ITEM_NO

		INSERT INTO [dbo].[TB_T_PR_SUBITEM]
			   ([PROCESS_ID]
			   ,[ITEM_NO]
			   ,[SUBITEM_NO]
			   ,[MAT_NO]
			   ,[MAT_DESC]
			   ,[COST_CENTER_CD]
			   ,[WBS_NO]
			   ,[GL_ACCOUNT]
			   ,[ORI_SUBITEM_QTY]
			   ,[NEW_SUBITEM_QTY]
			   ,[SUBITEM_UOM]
			   ,[ORI_PRICE_PER_UOM]
			   ,[NEW_PRICE_PER_UOM]
			   ,[ORI_AMOUNT]
			   ,[NEW_AMOUNT]
			   ,[ORI_LOCAL_AMOUNT]
			   ,[NEW_LOCAL_AMOUNT]
			   ,[NEW_FLAG]
			   ,[UPDATE_FLAG]
			   ,[DELETE_FLAG]
			   ,[CREATED_BY]
			   ,[CREATED_DT]
			   ,[CHANGED_BY]
			   ,[CHANGED_DT])
		SELECT @PROCESS_ID
			   ,@NEW_ITEM_NO
			   ,SUBITEM_NO
			   ,MAT_NO
			   ,MAT_DESC
			   ,COST_CENTER_CD
			   ,WBS_NO
			   ,GL_ACCOUNT
			   ,0		--ori subitem qty
			   ,NEW_SUBITEM_QTY
			   ,SUBITEM_UOM
			   ,0		--ori price
			   ,NEW_PRICE_PER_UOM
			   ,0		--ori amount
			   ,NEW_AMOUNT
			   ,0		--ori local amount
			   ,NEW_LOCAL_AMOUNT
			   ,'Y'		--new flag
			   ,'N'		--update flag
			   ,DELETE_FLAG
			   ,@USER_ID
			   ,GETDATE()
			   ,NULL
			   ,NULL
		FROM TB_T_PR_SUBITEM WHERE ITEM_NO = @ITEM_NO AND PROCESS_ID = @PROCESS_ID
	END
	ELSE
	BEGIN
		DECLARE @@NEW_SUBITEM_NO VARCHAR(5) 
		SELECT @@NEW_SUBITEM_NO = ISNULL(MAX(CAST(SUBITEM_NO AS INT)), 0) + 1 from TB_T_PR_SUBITEM WHERE ITEM_NO = @ITEM_NO AND PROCESS_ID = @PROCESS_ID

		INSERT INTO [dbo].[TB_T_PR_SUBITEM]
			   ([PROCESS_ID]
			   ,[ITEM_NO]
			   ,[SUBITEM_NO]
			   ,[MAT_NO]
			   ,[MAT_DESC]
			   ,[COST_CENTER_CD]
			   ,[WBS_NO]
			   ,[GL_ACCOUNT]
			   ,[ORI_SUBITEM_QTY]
			   ,[NEW_SUBITEM_QTY]
			   ,[SUBITEM_UOM]
			   ,[ORI_PRICE_PER_UOM]
			   ,[NEW_PRICE_PER_UOM]
			   ,[ORI_AMOUNT]
			   ,[NEW_AMOUNT]
			   ,[ORI_LOCAL_AMOUNT]
			   ,[NEW_LOCAL_AMOUNT]
			   ,[NEW_FLAG]
			   ,[UPDATE_FLAG]
			   ,[DELETE_FLAG]
			   ,[CREATED_BY]
			   ,[CREATED_DT]
			   ,[CHANGED_BY]
			   ,[CHANGED_DT])
		SELECT @PROCESS_ID
			   ,ITEM_NO
			   ,@NEW_SUBITEM_NO
			   ,MAT_NO
			   ,MAT_DESC
			   ,COST_CENTER_CD
			   ,WBS_NO
			   ,GL_ACCOUNT
			   ,0		--ori subitem qty
			   ,NEW_SUBITEM_QTY
			   ,SUBITEM_UOM
			   ,0		--ori price
			   ,NEW_PRICE_PER_UOM
			   ,0		--ori amount
			   ,NEW_AMOUNT
			   ,0		--ori local amount
			   ,NEW_LOCAL_AMOUNT
			   ,'Y'		--new flag
			   ,'N'		--update flag
			   ,'N'		--delete flag
			   ,@USER_ID
			   ,GETDATE()
			   ,NULL
			   ,NULL
		FROM TB_T_PR_SUBITEM WHERE ITEM_NO = @ITEM_NO AND SUBITEM_NO = @SUBITEM_NO AND PROCESS_ID = @PROCESS_ID
	END

	COMMIT TRANSACTION
	SELECT 'SUCCESS'
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	SELECT ERROR_MESSAGE()
END CATCH