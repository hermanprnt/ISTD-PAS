if not exists(select 1 from TB_M_MATERIAL where MAT_NO = @MAT_NO)
		select 'Error|Material Number not found in System Master'
else if not exists(select 1 from TB_M_VENDOR where VENDOR_CD = @VENDOR_CD)
		select 'Error|Vendor code not found in System Master'
else
begin
	if exists(select 1 from TB_M_SOURCE_LIST 
		      WHERE MAT_NO = @MAT_NO AND VENDOR_CD = @VENDOR_CD)
        begin
			select 'Error|Data is duplicate. Please check mandatory field *)'
		end
		else
		begin
			if not exists(select 1 from TB_M_SOURCE_LIST
					  where MAT_NO = @MAT_NO and VALID_DT_FROM >= @VALID_DT_FROM)
			begin
				UPDATE TB_M_SOURCE_LIST 
					SET VALID_DT_TO = DATEADD(day, -1, @VALID_DT_FROM)
				WHERE MAT_NO = @MAT_NO AND VALID_DT_TO = '9999-12-31'

				INSERT INTO TB_M_SOURCE_LIST 
						([MAT_NO]
						,[VENDOR_CD]
						,[VALID_DT_FROM]
						,[VALID_DT_TO]
						,[CREATED_BY]
						,[CREATED_DT]
						,[CHANGED_BY]
						,[CHANGED_DT])
				VALUES
				(
						@MAT_NO
						,@VENDOR_CD
						,@VALID_DT_FROM
						,'12-31-9999'
						,@username
						,GETDATE()
						,NULL
						,NULL
				)

				 select 'Save Successfully'
			end
			else
			begin
				select 'Error|Cannot entry new sourcelist when valid date equal or lower than existing valid date'
			end
		end
end

