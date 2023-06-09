﻿--DECLARE @@message varchar(1);
--IF EXISTS( select * from tb_R_PO_H WHERE PO_NO=@PO)
--BEGIN
--	SET @@message='1';
--END
--ELSE
--BEGIN 
--	SET @@message='2';
--END

--select @@message;


DECLARE @@PO VARCHAR(20),
		@@POREFF VARCHAR(20),
		@@PO_NO VARCHAR(10),
		@@WBS VARCHAR(30),
		@@VALID_TO VARCHAR(10)=convert( varchar(10),getdate(),112),
		@@RESULT VARCHAR(3),
		@@REFF VARCHAR(20);

SET @@PO=@PO;
SET @@REFF=@REFF;
DECLARE @@A INT,@@B INT;
--SET @@POREFF=(SELECT ISNULL(PO_NO,0) FROM TB_R_PO_H WHERE REF_NO='a');
SET @@B=(SELECT COUNT(1) FROM TB_R_PO_H WHERE PO_NO=@@PO OR REF_NO=@@REFF);
	IF @@B=0
	BEGIN
		SELECT '1' AS PO_NO -- PO or Ref no not found
	END
	ELSE
	BEGIN
			IF @@PO<>''
			BEGIN
				--SET @@A=(select COUNT(*) from TB_R_PO_H WHERE PO_NO=@@PO AND RELEASED_FLAG = 'Y');
				SET @@A=(select COUNT(*) from TB_R_PO_H WHERE PO_NO=@@PO AND PO_STATUS='44');
				SET @@PO=@@PO;
				IF @@A=0
				BEGIN
					SELECT '2' -- PO NOT YET RELEASE
				END
				ELSE
				BEGIN
					IF (SELECT DISTINCT 1 FROM TB_R_PO_ITEM WHERE PO_NO=@@PO AND ITEM_CLASS='S')=1
					BEGIN
						DECLARE l_cursor CURSOR LOCAL FAST_FORWARD
						FOR 
							SELECT 
								[PO_NO],
								[WBS_NO]
							FROM 
								TB_R_PO_SUBITEM
							WHERE PO_NO = @@PO
								
  
						OPEN l_cursor
						FETCH NEXT FROM l_cursor INTO
							@@PO_NO,
							@@WBS
						BEGIN
						WHILE @@@@FETCH_STATUS = 0
						  BEGIN
							IF EXISTS (SELECT PO_NO, WBS_NO FROM TB_M_WBS_CARRYOVER WHERE WBS_NO = @@WBS AND PO_NO = @@PO_NO)
							BEGIN
								IF ( @@VALID_TO > (SELECT VALID_TO FROM TB_M_WBS_CARRYOVER WHERE PO_NO = @@PO_NO AND WBS_NO = @@WBS) )
								BEGIN
									SET @@RESULT = '7' 
									BREAK
								END
								ELSE
								BEGIN
									SET @@RESULT = '4'
									BREAK
								END
							END
							ELSE IF EXISTS (SELECT WBS_NO FROM TB_M_WBS_CARRYOVER WHERE WBS_NO = @@WBS)
							BEGIN
								SET @@RESULT = '7' 
								BREAK
							END
							ELSE
							BEGIN
								SET @@RESULT = '4'
								BREAK
							END
							END
							end
						  FETCH NEXT FROM l_cursor INTO
							@@PO_NO,
							@@WBS
						CLOSE l_cursor
						DEALLOCATE l_cursor

						IF @@RESULT = 7
						BEGIN
							SELECT '7'
						END
						ELSE
						BEGIN
							SELECT '4'-- SUCCESS
						END
					END
					ELSE
					BEGIN
						SELECT '3' -- PO IS NOT FOR SA
					END
				END
			END
			ELSE IF @@PO=''
			BEGIN	
				SET @@A=(SELECT COUNT(*) FROM TB_R_PO_H WHERE ref_no=@@REFF AND RELEASED_FLAG = 'Y');
				--SET @@PO=@@POREFF;
			END
			IF @@A>1
			BEGIN 
				select '5' --   DATA PO RELESEASE HAVE MORE THAN 1 RECORD BY REF_NO
			END
			ELSE IF @@A=1 and @@PO=''
			BEGIN 
				SELECT '6' --GET FROM REFF
			END
			ELSE if  @@A=0 and @@PO=''
			BEGIN
				SELECT '2' -- PO NOT YET RELEASE
			END
	END
