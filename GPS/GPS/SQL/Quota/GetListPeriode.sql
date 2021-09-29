declare @@yyyy varchar(4),
		@@mm varchar(2),
		@@MMM varchar(2),
		@@month varchar(20),
		@@periode varchar(30),
		@@Flag INT,
		@@Count int,	
		@@LAST_COUNT int

declare @@Tb_t_Quota table(
	CONSUME_MONTH varchar(6),
	CONSUME_MONTH2 varchar(20)
)
		
set @@yyyy = LEFT(@CONSUME_MONTH,4);
set @@mm = RIGHT(@CONSUME_MONTH,2);
set @@Count = 12 - cast(@@mm as int);  
set @@LAST_COUNT = cast(@CONSUME_MONTH as int); 

SET @@Flag = 0 
	WHILE (@@Flag <= @@Count)
		BEGIN 				
			set @@MMM = cast(RIGHT(@@LAST_COUNT,2) as varchar(2))	

			if(@@MMM = '01') set @@month = 'January';
			if(@@MMM = '02') set @@month = 'February';
			if(@@MMM = '03') set @@month = 'March';
			if(@@MMM = '04') set @@month = 'April';
			if(@@MMM = '05') set @@month = 'May';
			if(@@MMM = '06') set @@month = 'June';
			if(@@MMM = '07') set @@month = 'July';
			if(@@MMM = '08') set @@month = 'August';
			if(@@MMM = '09') set @@month = 'September';
			if(@@MMM = '10') set @@month = 'October';
			if(@@MMM = '11') set @@month = 'November';
			if(@@MMM = '12') set @@month = 'December';

			set @@LAST_COUNT = @@LAST_COUNT + 1	
			set  @@periode = @@month + ' ' + @@yyyy; 
		   
		    insert into @@Tb_t_Quota
			select @@LAST_COUNT-1 as CONSUME_MONTH, @@periode as CONSUME_MONTH2
									
			SET @@Flag = @@Flag + 1
		END

select * from @@Tb_t_Quota
