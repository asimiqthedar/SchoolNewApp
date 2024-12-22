DROP PROCEDURE IF EXISTS [SP_MonthlyStatementParentStudent]
GO

CREATE PROCEDURE  [dbo].[SP_MonthlyStatementParentStudent]    
(    
 @ParentId int=0    
 ,@ParentName nvarchar(100)=null 
 ,@AcademicYearId int=0
 ,@StartDate datetime=null    
 ,@EndDate datetime=null    
)    
as    
begin    
  
 set @parentName='%'+@parentName+'%'   
 
 select     
 ParentId ,ParentName ,NameMonth ,NameYear ,
 TaxableAmount=sum(TaxableAmount) ,
 TaxAmount =sum(TaxAmount),ItemSubtotal =sum(ItemSubtotal)    
 into #DiscountTbl
 from    
 (    
  select     
   ParentId=isnull(invDet.ParentCode,0)    
   ,ParentName=isnull(invDet.ParentName,'') 
      
   ,NameMonth=DATENAME(month, invSum.InvoiceDate)    
   ,NameYear=DATENAME(year, invSum.InvoiceDate)

	,TaxableAmount=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.TaxableAmount *-1	ELSE invDet.TaxableAmount	END
	,TaxAmount=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.TaxAmount *-1	ELSE invDet.TaxAmount	END
	,ItemSubtotal=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.ItemSubtotal *-1	ELSE invDet.ItemSubtotal	END

  from INV_InvoiceSummary invSum    
  join INV_InvoiceDetail invDet     
  on invSum.InvoiceNo=invDet.InvoiceNo    
  where    
  invSum.[Status]='Posted'  
 and  
  (    
   (@parentId=0 OR invDet.ParentId=@parentId)
   OR (@AcademicYearId=0 OR invDet.AcademicYear=@AcademicYearId)    
   OR ((@parentName is null OR @parentName='' ) OR invDet.ParentName like @parentName)       
  )    
 )t    
 group by ParentId ,ParentName ,NameMonth ,NameYear   
    

		 SELECT ParentId=' '  
   ,ParentName=' '  
   ,NameMonth =' '  
   ,NameYear='Total'
   ,TaxableAmount=SUM(TaxableAmount)
   ,TaxAmount=SUM(TaxAmount)  
   ,ItemSubtotal=SUM(ItemSubtotal)  
 FROM #DiscountTbl  

  UNION ALL 

  SELECT ParentId 
   ,ParentName 
   ,NameMonth
   ,NameYear
   ,TaxableAmount=(TaxableAmount)
   ,TaxAmount=(TaxAmount)
   ,ItemSubtotal=(ItemSubtotal)
 FROM #DiscountTbl 

end 
GO

DROP PROCEDURE IF EXISTS [SP_AdvanceFeeReport]
GO

CREATE PROCEDURE [dbo].[SP_AdvanceFeeReport]      
(      
 @ParentId int=0      
,@ParentName nvarchar(100)=null      
,@FatherIqama nvarchar(100)=null      
,@StudentName nvarchar(100)=null      
,@AcademicYear int=0      
,@InvoiceNo bigint=0      
,@StartDate datetime=null      
,@EndDate datetime=null      
)      
as      
begin      
      
 select       
  ParentId      
 ,ParentName      
 ,FatherMobile      
 ,IqamaNumber      
 ,StudentId      
 ,StudentName      
 ,GradeName      
 ,CostCenter     
 ,AcademicYear      
 ,IsStaff      
 ,TaxableAmount=sum(TaxableAmount)      
 ,TaxAmount=sum(TaxAmount)      
 ,ItemSubtotal=sum(ItemSubtotal)      
 ,InvoiceType      
 ,InvoiceDate      
 ,InvoiceNo      
 ,PaymentMethod      
 ,InvoiceRefNo = PaymentReferenceNumber 
  into #DiscountTbl
 from      
 (      
  select       
    ParentId=isnull(invDet.ParentCode,0)      
             ,invDet.ParentName      
   ,invDet.FatherMobile      
   ,StudentId = isnull(invDet.StudentCode,0)      
   ,StudentName=isnull(invDet.StudentName,'')      
   ,tgm.GradeName  
    ,CostCenter=tcm.CostCenterName  
   ,tsa.AcademicYear      
   ,invDet.IqamaNumber      
   ,invDet.IsStaff      
  
 ,invSum.InvoiceNo      
 ,invSum.InvoiceDate      
 ,invPay.PaymentMethod      
 ,invPay.PaymentReferenceNumber    
  
 ,InvoiceType = CASE WHEN invSum.InvoiceType='RETURN' THEN invSum.InvoiceType ELSE invDet.InvoiceType END  
 ,TaxableAmount=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.TaxableAmount *-1 ELSE invDet.TaxableAmount END  
 ,TaxAmount=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.TaxAmount *-1 ELSE invDet.TaxAmount END  
 ,ItemSubtotal=CASE WHEN invSum.InvoiceType='RETURN' THEN invDet.ItemSubtotal *-1 ELSE invDet.ItemSubtotal END  
  
  from INV_InvoiceSummary invSum      
  join INV_InvoiceDetail invDet on invSum.InvoiceNo=invDet.InvoiceNo      
  join tblGradeMaster as tgm on invDet.GradeId = tgm.GradeId  
  join tblCostCenterMaster as tcm on tcm.CostCenterId = tgm.CostCenterId  
  join tblSchoolAcademic as tsa on invDet.AcademicYear = tsa.SchoolAcademicId    
  join    
  (    
 select     
  ROW_NUMBER()over(partition by invPay2.InvoiceNo order by invPay2.PaymentAmount desc) as RNPay    
  ,invPay2.InvoiceNo , invPay2.PaymentMethod  ,invPay2.PaymentReferenceNumber     
  from  INV_InvoicePayment as invPay2     
  )invPay     
  on invDet.InvoiceNo = invPay.InvoiceNo  and RNPay=1    
      
  where       
    invDet.InvoiceType = 'Tuition Fee'       
   AND invSum.ParentId = CASE WHEN @ParentId > 0 THEN @ParentId ELSE invSum.ParentId END        
   AND invDet.InvoiceNo = CASE WHEN @InvoiceNo > 0 THEN @InvoiceNo ELSE invDet.InvoiceNo END      
   AND invDet.ParentName LIKE '%'+ CASE WHEN len(@ParentName) > 0 THEN @ParentName ELSE invDet.ParentName  END + '%'        
   AND invDet.IqamaNumber LIKE '%'+ CASE WHEN len(@FatherIqama) > 0 THEN @FatherIqama ELSE invDet.IqamaNumber  END + '%'      
   AND invDet.StudentName LIKE '%'+ CASE WHEN len(@StudentName) > 0 THEN @StudentName ELSE invDet.StudentName  END + '%'        
   AND invDet.AcademicYear = CASE WHEN @AcademicYear > 0 THEN @AcademicYear ELSE invDet.AcademicYear END         
   AND (@StartDate IS NULL OR cast(invSum.InvoiceDate as date) >= cast(@StartDate as date))                    
   AND (@EndDate IS NULL OR cast(invSum.InvoiceDate as date) <= cast(@EndDate as date))        
 )t      
 group by  
	ParentId,      
	ParentName,      
	FatherMobile,      
	IqamaNumber,      
	StudentId,      
	StudentName,      
	GradeName,
	CostCenter,
	AcademicYear,      
	IsStaff,      
	InvoiceType      
	,InvoiceDate      
	,InvoiceNo      
	,PaymentMethod      
	,PaymentReferenceNumber  
	

	SELECT 
		ParentId=' '  
	   ,ParentName=' '  
	   ,FatherMobile =' '  
	   ,IqamaNumber =' '  
	   ,StudentId =' '  
	   ,StudentName =' '  
	   ,GradeName='Total'
	   ,CostCenter=' '
	   ,AcademicYear=' '
	   ,IsStaff=' '

	   ,InvoiceType=' '
	   ,InvoiceDate=' '
	   ,InvoiceNo=' '
	   ,PaymentMethod=' '
	   ,InvoiceRefNo=' '

	   ,TaxableAmount=SUM(TaxableAmount)
	   ,TaxAmount=SUM(TaxAmount)  
	   ,ItemSubtotal=SUM(ItemSubtotal)  
	 FROM #DiscountTbl  

  UNION ALL 

	select 
	ParentId	,ParentName	,FatherMobile	,IqamaNumber	,StudentId	,StudentName	,GradeName	,CostCenter	
	,AcademicYear	,case when IsStaff=0 then 'False' else 'True' end
	,InvoiceType	,InvoiceDate= Convert(varchar,InvoiceDate,103) 	,InvoiceNo=cast(InvoiceNo as nvarchar(50))	,PaymentMethod	,InvoiceRefNo
	,TaxableAmount	,TaxAmount	,ItemSubtotal	
	from #DiscountTbl


end      
GO

DROP PROCEDURE IF EXISTS [SP_ParentStudentReport]
GO

CREATE PROCEDURE  [dbo].[SP_ParentStudentReport]
(
	@ParentId int=0
	,@StudentId int=0
	,@AcademicYear int=0
	,@CostCenter int=0
	,@Grade int=0
	,@Gender int=0
	 ,@StartDate datetime=null      
	,@EndDate datetime=null  
)
AS
BEGIN
	SELECT 
		InvoiceNo=ISNULL(InvoiceNo,0),AcademicYearId,GradeId,StudentId,ParentId
		,FeeApplied
		,DiscountApplied
		,AmountPaid
	INTO #tempFeeStatement
	FROM 
	(
		SELECT 
			InvoiceNo,AcademicYearId,GradeId,StudentId,ParentId
			,FeeApplied=feeamount
			,DiscountApplied=CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END
			,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END
		FROM tblFeeStatement 
		where isnull(InvoiceNo,0)=0
	)t

	insert into #tempFeeStatement
	SELECT 
		f.InvoiceNo,AcademicYearId,GradeId,StudentId,f.ParentId
		,FeeApplied=feeamount
		,DiscountApplied=CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END
		,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END
	FROM tblFeeStatement f
	join INV_InvoiceSummary i on f.InvoiceNo=i.InvoiceNo and i.Status='Posted'
	where cast(i.InvoiceDate as date) between cast(@StartDate as date) and cast(@EndDate as date)

	SELECT 
		sa.AcademicYear	
		,CostCenter=cc.CostCenterName	
		,Grade=gm.GradeName
		,Gender=gtm.GenderTypeName	
		,par.ParentCode
		,stu.StudentCode
		,a.FeeApplied
		,a.DiscountApplied
		,a.AmountPaid
		,VatPaid=0--ISNULL(tax.VatPaid	,0)
		,Balance=ISNULL(a.FeeApplied,0)-ISNULL(a.DiscountApplied,0)-ISNULL(a.AmountPaid,0) 
	INTO #finalResult
	FROM #tempFeeStatement a
	--LEFT JOIN #VatDetail tax 
	--	ON a.InvoiceNo=tax.InvoiceNo and a.ParentId=tax.ParentId and a.StudentId=tax.StudentId
	INNER JOIN tblGradeMaster gm 
		ON a.GradeId=gm.GradeId
	JOIN tblParent par 
		ON a.ParentId=par.ParentId
	JOIN tblStudent stu 
		ON a.StudentId=stu.StudentId
	INNER JOIN tblSchoolAcademic AS sa     
		ON a.AcademicYearId = sa.SchoolAcademicId 
	INNER JOIN tblCostCenterMaster cc     
		ON gm.CostCenterId=cc.CostCenterId    
	INNER JOIN tblGenderTypeMaster gtm     
		ON gtm.GenderTypeId=stu.GenderId    

	WHERE a.AcademicYearId = CASE WHEN @AcademicYear > 0 THEN @AcademicYear ELSE a.AcademicYearId END      
   AND gm.CostCenterId = CASE WHEN @CostCenter > 0 THEN @CostCenter ELSE gm.CostCenterId END       
   AND a.GradeId = CASE WHEN @Grade > 0 THEN @Grade ELSE a.GradeId END       
   AND stu.GenderId = CASE WHEN @Gender > 0 THEN @Gender ELSE stu.GenderId END      

  
	SELECT ParentCode = ' '    
		,StudentCode = ' '    
		,AcademicYear = ' '    
	,CostCenter = ' '    
	,Grade = ' '    
	,Gender ='Total'     
	,FeeApplied=FORMAT(SUM(ISNULL(FeeApplied,0)),'#,0.00')    
	,DiscountApplied=FORMAT(SUM(ISNULL(DiscountApplied,0)),'#,0.00')    
	,AmountPaid=FORMAT(SUM(ISNULL(AmountPaid,0)),'#,0.00')    
	,VatPaid=FORMAT(SUM(ISNULL(VatPaid,0)),'#,0.00')    
	,Balance=FORMAT(SUM(ISNULL(Balance,0)),'#,0.00')     
	FROM  #finalResult    
	   UNION ALL  
	SELECT ParentCode
		,StudentCode
		,AcademicYear	
		,CostCenter	
		,Grade
		,Gender		
		,FeeApplied=FORMAT(SUM(FeeApplied),'#,0.00')
		,DiscountApplied=FORMAT(SUM(DiscountApplied),'#,0.00')
		,AmountPaid=FORMAT(SUM(AmountPaid),'#,0.00')
		,VatPaid=FORMAT(SUM(VatPaid),'#,0.00')
		,Balance=FORMAT(Sum(Balance),'#,0.00')
	FROM #finalResult
	GROUP BY ParentCode,StudentCode	,AcademicYear,CostCenter,Grade,Gender

	

	DROP TABLE IF EXISTS #tempFeeStatement
	DROP TABLE IF EXISTS #VatDetail
	DROP TABLE IF EXISTS #finalResult
END
GO


DROP PROCEDURE IF EXISTS [SP_GeneralReport]
GO

CREATE PROCEDURE  [dbo].[SP_GeneralReport]      
(      
  @AcademicYear int=0      
 ,@CostCenter int=0      
 ,@Grade int=0      
 ,@Gender int=0      
)      
AS      
BEGIN    
 SELECT   
  InvoiceNo=ISNULL(InvoiceNo,0),AcademicYearId,GradeId,StudentId,ParentId  
  ,FeeApplied  
  ,DiscountApplied  
  ,AmountPaid  
 INTO #tempFeeStatement  
 FROM   
 (  
  SELECT   
   InvoiceNo,AcademicYearId,GradeId,StudentId,ParentId  
   ,FeeApplied=feeamount  
   ,DiscountApplied=CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END  
   ,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END  
  FROM tblFeeStatement   
  where isnull(InvoiceNo,0)=0  
 )t  
  
 INSERT INTO #tempFeeStatement  
 SELECT   
  f.InvoiceNo,AcademicYearId,GradeId,StudentId,f.ParentId  
  ,FeeApplied=feeamount  
  ,DiscountApplied=CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END  
  ,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END  
 FROM tblFeeStatement f  
 join INV_InvoiceSummary i on f.InvoiceNo=i.InvoiceNo and i.Status='Posted'  
  
 SELECT   
  sa.AcademicYear   
  ,CostCenter=cc.CostCenterName   
  ,Grade=gm.GradeName  
  ,Gender=gtm.GenderTypeName   
  ,par.ParentCode  
  ,stu.StudentCode  
  ,a.FeeApplied  
  ,a.DiscountApplied  
  ,a.AmountPaid  
  ,VatPaid=0  
  ,Balance=ISNULL(a.FeeApplied,0)-ISNULL(a.DiscountApplied,0)-ISNULL(a.AmountPaid,0)   
 INTO #finalResult  
 FROM #tempFeeStatement a  
 INNER JOIN tblGradeMaster gm   
  ON a.GradeId=gm.GradeId  
 JOIN tblParent par   
  ON a.ParentId=par.ParentId  
 JOIN tblStudent stu   
  ON a.StudentId=stu.StudentId  
 INNER JOIN tblSchoolAcademic AS sa       
  ON a.AcademicYearId = sa.SchoolAcademicId   
 INNER JOIN tblCostCenterMaster cc       
  ON gm.CostCenterId=cc.CostCenterId      
 INNER JOIN tblGenderTypeMaster gtm       
  ON gtm.GenderTypeId=stu.GenderId      
  
 WHERE a.AcademicYearId = CASE WHEN @AcademicYear > 0 THEN @AcademicYear ELSE a.AcademicYearId END        
   AND gm.CostCenterId = CASE WHEN @CostCenter > 0 THEN @CostCenter ELSE gm.CostCenterId END         
   AND a.GradeId = CASE WHEN @Grade > 0 THEN @Grade ELSE a.GradeId END         
   AND stu.GenderId = CASE WHEN @Gender > 0 THEN @Gender ELSE stu.GenderId END        
  
    
 SELECT AcademicYear = ' '      
 ,CostCenter = ' '      
 ,Grade = ' '      
 ,Gender ='Total'       
 ,FeeApplied=FORMAT(SUM(ISNULL(FeeApplied,0)),'#,0.00')      
 ,DiscountApplied=FORMAT(SUM(ISNULL(DiscountApplied,0)),'#,0.00')      
 ,AmountPaid=FORMAT(SUM(ISNULL(AmountPaid,0)),'#,0.00')      
 ,VatPaid=FORMAT(SUM(ISNULL(VatPaid,0)),'#,0.00')      
 ,Balance=FORMAT(SUM(ISNULL(Balance,0)),'#,0.00')       
 FROM  #finalResult  
   UNION ALL  
 SELECT   
  AcademicYear   
  ,CostCenter   
  ,Grade  
  ,Gender    
  ,FeeApplied=FORMAT(SUM(FeeApplied),'#,0.00')  
  ,DiscountApplied=FORMAT(SUM(DiscountApplied),'#,0.00')  
  ,AmountPaid=FORMAT(SUM(AmountPaid),'#,0.00')  
  ,VatPaid=FORMAT(SUM(VatPaid),'#,0.00')  
  ,Balance=FORMAT(Sum(Balance),'#,0.00')  
 FROM #finalResult  
 GROUP BY AcademicYear,CostCenter,Grade,Gender  
  
     
  
 DROP TABLE IF EXISTS #tempFeeStatement  
 DROP TABLE IF EXISTS #VatDetail  
 DROP TABLE IF EXISTS #finalResult  
END  
GO

DROP PROCEDURE IF EXISTS [sp_getAdminDashboardData]
GO

CREATE PROCEDURE [dbo].[sp_getAdminDashboardData]        
as        
begin        
	select  count(1) as TotalStudent        
	from tblStudent   stu   
	where stu.IsActive=1 and stu.IsDeleted=0  
        
	select  count(1) as TotalParent from tblParent  stu   
	where stu.IsActive=1 and stu.IsDeleted=0       
        
	select         
		case when GenderId=1 then 'Male' else 'Female' end as Gender, GradeName as KeyName, count(1) as KeyValue        
	from tblStudent stu        
	inner join tblGradeMaster grade        
	on stu.GradeId=grade.GradeId  
	where stu.IsActive=1 and stu.IsDeleted=0     
	group by GradeName,GenderId   
        
	select 
	KeyName, count(1) as KeyValue 
	from
	(      
		select         
			datepart(year, AdmissionDate) as KeyName      
		from tblStudent stu    
		where stu.IsActive=1 and stu.IsDeleted=0     
	)t      
	group by KeyName         
        
	declare @currentDate datetime;
	declare @lastdateOfMonth datetime;
	declare @firstdateOfMonth datetime;
	set @currentDate =getdate()  
  
	select @lastdateOfMonth=dateadd(month,1+datediff(month,0,getdate()),-1)  
	SELECT @firstdateOfMonth=DATEADD(DAY,1,EOMONTH(@currentDate,-1))  
  
	SELECT          
		ISNULL(SUM(CASE WHEN ind.InvoiceType = 'Entrance Fee' THEN 
		case when ins.InvoiceType='Invoice' then isnull(ind.TaxableAmount,0)  else isnull(ind.TaxableAmount,0)*-1 end
		ELSE 0 END),0) AS MonthlyEntranceRevenue,         

		ISNULL(SUM(CASE WHEN ind.InvoiceType = 'Uniform Fee' THEN 
		case when ins.InvoiceType='Invoice' then isnull(ind.TaxableAmount,0)  else isnull(ind.TaxableAmount,0)*-1 end
		ELSE 0 END),0) AS MonthlyUniformRevenue,    
		
		ISNULL(SUM(CASE WHEN ind.InvoiceType = 'Tuition Fee' THEN 
		case when ins.InvoiceType='Invoice' then isnull(ind.TaxableAmount,0)  else isnull(ind.TaxableAmount,0)*-1 end
		ELSE 0 END),0) AS MonthlyTuitionRevenue        
	FROM INV_InvoiceDetail ind  
	join INV_InvoiceSummary ins on ins.InvoiceNo=ind.InvoiceNo  
	where cast(ins.InvoiceDate as date) between cast(@firstdateOfMonth as date) and cast(@lastdateOfMonth as date)  
	and ins.Status='posted'  
   
	select   
	StatusName ,StatusCount  
	from  
	(  
		select   
			StatusName='Active',StatusCount=Count(1)  
		from tblstudent stu  
		join [dbo].[tblStudentStatus] sta  
		on stu.StudentStatusId=sta.StudentStatusId  
		where StatusName='Active'  
		and stu.IsActive=1 and stu.IsDeleted=0  
  
		UNION ALL  
  
		select   
			StatusName='Hold',StatusCount=Count(1)  
		from tblstudent stu  
		join [dbo].[tblStudentStatus] sta  
		on stu.StudentStatusId=sta.StudentStatusId  
		where StatusName='Hold'  
		and stu.IsActive=1 and stu.IsDeleted=0  
   
		UNION ALL  
  
		select   
			StatusName='Withdraw',StatusCount=Count(1)  
		from tblstudent stu  
		join [dbo].[tblStudentStatus] sta  
		on stu.StudentStatusId=sta.StudentStatusId  
		where StatusName='Withdraw'  
		and stu.IsActive=1 and stu.IsDeleted=0  
	)t  
  
	--Start: Get CUrrent Academic year record
	declare @SchoolAcademicId bigint=0
	declare @PeriodFrom	datetime;
	declare @PeriodTo datetime;
	declare @TotalAppliedFee decimal(18,2)=0
	select top 1 @SchoolAcademicId =SchoolAcademicId,@PeriodFrom=PeriodFrom, @PeriodTo=PeriodTo from tblSchoolAcademic where IsCurrentYear=1
  
	--Get applied fee
	select @TotalAppliedFee = isnull(sum(FeeAmount),0) from tblFeeStatement where FeeStatementType='Fee Applied' and IsActive=1 and IsDeleted=0
	and cast(UpdateDate as date) between cast(@PeriodFrom as date) and cast(@PeriodTo as date)
	and AcademicYearId=@SchoolAcademicId 

	SELECT  
		TotalYearlyAppliedFee=@TotalAppliedFee 
		,ISNULL(SUM(CASE WHEN ind.InvoiceType = 'Entrance Fee' 
		THEN 
			case when ins.InvoiceType='Invoice' then isnull(ind.TaxableAmount,0)  else isnull(ind.TaxableAmount,0)*-1 end		
		ELSE 0 END),0) AS YearlyEntranceRevenue,         
		
		ISNULL(SUM(CASE WHEN ind.InvoiceType = 'Uniform Fee' 
		THEN 
			case when ins.InvoiceType='Invoice' then isnull(ind.TaxableAmount,0)  else isnull(ind.TaxableAmount,0)*-1 end
		ELSE 0 END),0) AS YearlyUniformRevenue,         
		
		ISNULL(SUM(CASE WHEN ind.InvoiceType = 'Tuition Fee' 
		THEN 
			case when ins.InvoiceType='Invoice' then isnull(ind.TaxableAmount,0)  else isnull(ind.TaxableAmount,0)*-1 end
		ELSE 0 END),0) AS YearlyTuitionRevenue        
	FROM INV_InvoiceDetail ind  
	join INV_InvoiceSummary ins on ins.InvoiceNo=ind.InvoiceNo  
	where cast(ins.InvoiceDate as date) between cast(@PeriodFrom as date) and cast(@PeriodTo as date)  
	and ins.Status='posted'  
 
	--End: Get CUrrent Academic year record

end   
GO

DROP PROCEDURE IF EXISTS [SP_ParentReport]
GO

CREATE PROCEDURE [dbo].[SP_ParentReport]
(
	@ParentId int=0
	,@AcademicYear int=0
	 ,@StartDate datetime=null      
	,@EndDate datetime=null      
)
AS
BEGIN
	SELECT 
		InvoiceNo=ISNULL(InvoiceNo,0),AcademicYearId,GradeId,StudentId,ParentId
		,FeeApplied
		,DiscountApplied
		,AmountPaid
	INTO #tempFeeStatement
	FROM 
	(
		SELECT 
			f.InvoiceNo,AcademicYearId,GradeId,StudentId,f.ParentId
			,FeeApplied=feeamount
			,DiscountApplied=CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END
			,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END
		FROM tblFeeStatement f
		where isnull(f.InvoiceNo,0)=0
		--and cast(UpdateDate as date) between cast(@StartDate as date) and cast(@EndDate as date)
	)t

	insert into #tempFeeStatement
	SELECT 
			f.InvoiceNo,AcademicYearId,GradeId,StudentId,f.ParentId
			,FeeApplied=feeamount
			,DiscountApplied=CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END
			,AmountPaid=CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END
		FROM tblFeeStatement f
		join INV_InvoiceSummary i on f.InvoiceNo=i.InvoiceNo and i.Status='Posted'
		where cast(i.InvoiceDate as date) between cast(@StartDate as date) and cast(@EndDate as date)

	SELECT 
		p.ParentCode
		,FeeApplied=sum(feeamount)
		,DiscountApplied=sum(CASE WHEN FeeStatementType LIKE '%Discount%' THEN paidamount ELSE 0 END)
		,AmountPaid=sum(CASE WHEN FeeStatementType LIKE '%Discount%' THEN 0 ELSE paidamount END)
	INTO #tempFeeStatementOpening
	FROM tblFeeStatement f
	left join tblparent p on f.ParentId=p.ParentId
	where cast(F.UpdateDate as date) < cast(@StartDate as date) 
	group by p.ParentCode

	SELECT sa.AcademicYear	
		,CostCenter=cc.CostCenterName	
		,Grade=gm.GradeName
		,Gender=gtm.GenderTypeName	
		,par.ParentCode
		,stu.StudentCode
		,a.FeeApplied
		,a.DiscountApplied
		,a.AmountPaid
		,VatPaid=0--ISNULL(tax.VatPaid	,0)
		,Balance=ISNULL(a.FeeApplied,0)-ISNULL(a.DiscountApplied,0)-ISNULL(a.AmountPaid,0) 
	INTO #finalResult
	FROM #tempFeeStatement a
	--LEFT JOIN #VatDetail tax 
	--	ON a.InvoiceNo=tax.InvoiceNo and a.ParentId=tax.ParentId and a.StudentId=tax.StudentId
	INNER JOIN tblGradeMaster gm 
		ON a.GradeId=gm.GradeId
	JOIN tblParent par 
		ON a.ParentId=par.ParentId
	JOIN tblStudent stu 
		ON a.StudentId=stu.StudentId
	INNER JOIN tblSchoolAcademic AS sa     
		ON a.AcademicYearId = sa.SchoolAcademicId 
	INNER JOIN tblCostCenterMaster cc     
		ON gm.CostCenterId=cc.CostCenterId    
	INNER JOIN tblGenderTypeMaster gtm     
		ON gtm.GenderTypeId=stu.GenderId    

	WHERE a.AcademicYearId = CASE WHEN @AcademicYear > 0 THEN @AcademicYear ELSE a.AcademicYearId END      
   AND par.ParentId = CASE WHEN @ParentId > 0 THEN @ParentId ELSE par.ParentId END

   declare @OpeningBalance decimal(18,2)=0

   select @OpeningBalance =isnull(sum((isnull(p.FeeApplied,0)-isnull(p.DiscountApplied,0)-isnull(p.AmountPaid,0))),0)
   from 
   #tempFeeStatementOpening p

 

	SELECT ParentCode= ' '
	,AcademicYear ='Total'  
	,OpeningBalance=@OpeningBalance
	,FeeApplied=FORMAT(SUM(ISNULL(FeeApplied,0)),'#,0.00')    
	,DiscountApplied=FORMAT(SUM(ISNULL(DiscountApplied,0)),'#,0.00')    
	,AmountPaid=FORMAT(SUM(ISNULL(AmountPaid,0)),'#,0.00')    
	,VatPaid=FORMAT(SUM(ISNULL(VatPaid,0)),'#,0.00')    
	,Balance=FORMAT(SUM(ISNULL(Balance,0)),'#,0.00')     
	FROM  #finalResult 
	
	  UNION ALL    
	SELECT
		t.ParentCode
		,AcademicYear
		,OpeningBalance=isnull(sum((isnull(p.FeeApplied,0)-isnull(p.DiscountApplied,0)-isnull(p.AmountPaid,0))),0)
		,FeeApplied=FORMAT(SUM(t.FeeApplied),'#,0.00')
		,DiscountApplied=FORMAT(SUM(t.DiscountApplied),'#,0.00')
		,AmountPaid=FORMAT(SUM(t.AmountPaid),'#,0.00')
		,VatPaid=FORMAT(SUM(VatPaid),'#,0.00')
		,Balance=FORMAT(Sum(Balance),'#,0.00')
	FROM #finalResult t
	left join #tempFeeStatementOpening p on t.ParentCode=p.ParentCode
	GROUP BY t.ParentCode,AcademicYear

	

	DROP TABLE IF EXISTS #tempFeeStatement
	DROP TABLE IF EXISTS #VatDetail
	DROP TABLE IF EXISTS #finalResult	
END
GO
