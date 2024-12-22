DROP PROCEDURE IF EXISTS  [dbo].[sp_ProcessGP_UniformInvoice]
GO

CREATE PROCEDURE [dbo].[sp_ProcessGP_UniformInvoice]      
(                
  @invoiceno bigint=0   ,            
  @DestinationDB nvarchar(50) = ''            
)                
AS                
BEGIN           
  BEGIN TRY           
          
 IF OBJECT_ID('tempdb..#INT_ALS_SalesInvoiceSourceTable') IS NOT NULL        
 DROP TABLE #INT_ALS_SalesInvoiceSourceTable        
    
 delete from INT_SalesInvoiceSourceTable where SOPNumber=@invoiceno    
 delete from INT_SalesPaymentSourceTable where SOPNumber=@invoiceno    
 delete from INT_SalesDistributionSourceTable where SOPNumber=@invoiceno    
        
 --Update database      
 DECLARE @SourceDBName NVARCHAR(50)= 'ALS_LIVE'         
                
 -----------sales detail processing                
 declare @SOPType int=3                
 declare @DocID nvarchar(50)='STDINV'                
 declare @IntegrationStatus int=0                
                
 Declare @InvoiceTypeCount int=0                
 declare @totalPayableAmount decimal(18,4)=0                
                
 select                 
  SeqNum=ROW_NUMBER() over(partition by invSum.invoiceno order by InvoiceDetailId)                
  ,SOPNumber=invSum.invoiceno                
  ,SOPType=@SOPType                
  ,DocID=@DocID                
  ,DocDate= cast(invSum.InvoiceDate as date)                
  ,CustomerNumber='CASH CUSTOMER'                
  ,ItemNumber=invDet.ItemCode                
  ,Quantity=invDet.Quantity                 
  ,UnitPrice=invDet.ItemSubtotal-invDet.TaxAmount        
  ,ItemSubtotal=invDet.ItemSubtotal                
  ,IntegrationStatus=@IntegrationStatus                
  ,Error=0                
  ,invDet.InvoiceType                
 into #INT_ALS_SalesInvoiceSourceTable                
 from INV_InvoiceDetail invDet                
 join INV_InvoiceSummary invSum                
 on invDet.InvoiceNo=invSum.InvoiceNo                
 where invDet.InvoiceType like '%Uniform%'                
 and invSum.invoiceno=@invoiceno                
                
 insert into INT_SalesInvoiceSourceTable(SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,UnitPrice,IntegrationStatus,Error)                
 select                 
  SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,(ItemSubtotal/Quantity),IntegrationStatus,Error                
 from #INT_ALS_SalesInvoiceSourceTable                
                
 -----------payment processing                
         
 select @InvoiceTypeCount=count(InvoiceType) from #INT_ALS_SalesInvoiceSourceTable                 
 select @totalPayableAmount=sum(isnull(ItemSubtotal,0)) from #INT_ALS_SalesInvoiceSourceTable                
                
 --4 for Cash payment, 5 for Check payment & bank transfer, and 6 for Credit card payment.                
 --Bank Transfer =5                
 --Check=5                
 --Cash=4                
 --Visa=6                
                  
 if(@InvoiceTypeCount>1)                
 begin                
  insert into INT_SalesPaymentSourceTable                
  (                
   SeqNum,SOPNumber,SOPType,PaymentType,PaymentAmount,CheckbookID,CardName,CheckNumber,CreditCardNumber,                
   AuthorizationCode,ExpirationDate,IntegrationStatus,Error                
  )                
  select                 
   SeqNum                
   ,SOPNumber                
   ,SOPType                
   ,PaymentType                
   ,PaymentAmount         
   ,CheckbookID        
   ,CardName                
   ,CheckNumber                
   ,CreditCardNumber                
   ,AuthorizationCode                
   ,ExpirationDate                
   ,IntegrationStatus                
   ,Error                
  from                 
  (                
   select top 1                 
    SeqNum=1                
    ,SOPNumber=invoiceno                
    ,SOPType=3                
    ,PaymentType=case when PaymentMethod='Cash' then 4 when PaymentMethod='Visa' then 6 else 5 end       
    ,PaymentAmount=@totalPayableAmount                
    ,CheckbookID=PaymentMethod        
    ,CardName=''             
    ,CheckNumber=PaymentReferenceNumber                
    ,CreditCardNumber=null                
    ,AuthorizationCode=null                
    ,ExpirationDate=null                
    ,IntegrationStatus=0                
    ,Error=null                
   from als_live.dbo.INV_InvoicePayment                
   where invoiceno=@invoiceno                
  )t      
 end                
 else                
 begin                
  insert into INT_SalesPaymentSourceTable                
  (                
   SeqNum,SOPNumber,SOPType,PaymentType,PaymentAmount,CheckbookID,CardName,CheckNumber,CreditCardNumber,                
   AuthorizationCode,ExpirationDate,IntegrationStatus,Error                
  )                
  select      
   SeqNum                
   ,SOPNumber                
   ,SOPType                
   ,PaymentType                
   ,PaymentAmount        
   ,CheckbookID        
   ,CardName                
   ,CheckNumber                
   ,CreditCardNumber                
   ,AuthorizationCode                
   ,ExpirationDate                
   ,IntegrationStatus                
   ,Error                
  from                 
  (                
   select                
    SeqNum=ROW_NUMBER() over(partition by invoiceno order by InvoicePaymentId asc)                
    ,SOPNumber=invoiceno                
    ,SOPType=3                
    ,PaymentType=case when PaymentMethod='Cash' then 4 when PaymentMethod='Visa' then 6 else 5 end                
    ,PaymentAmount=@totalPayableAmount                
    ,CheckbookID=PaymentMethod        
    ,CardName=''                
    ,CheckNumber=PaymentReferenceNumber                
    ,CreditCardNumber=null                
    ,AuthorizationCode=null                
    ,ExpirationDate=null                
    ,IntegrationStatus=0                
    ,Error=null                
   from INV_InvoicePayment                
   where invoiceno=@invoiceno                 
  )t           
 end      
      
 --payment information can be multiple with their debit account number and payment amount        
        
 declare @UniformDebitAccount nvarchar(50)=''        
 declare @UniformCreditAccount nvarchar(50)=''        
        
 declare @VATDebitAccount nvarchar(50)=''        
 declare @VATCreditAccount nvarchar(50)=''        
        
 select top 1        
  @VATDebitAccount=vat.DebitAccount,        
  @VATCreditAccount=vat.CreditAccount         
 from tblVatMaster vat        
 inner join tblFeeTypeMaster fee         
 on vat.FeeTypeId=fee.FeeTypeId        
 where vat.IsActive=1 and vat.IsDeleted=0        
 and FeeTypeName like '%UNIFORM%'        
        
 select top 1         
  @UniformDebitAccount=DebitAccount,        
  @UniformCreditAccount=CreditAccount         
 from tblFeeTypeMaster        
 where FeeTypeName like '%UNIFORM%'        
        
 declare @TotalTaxableAmount decimal(18,2)=0        
 declare @TotalTaxAmount decimal(18,2)=0        
       
 select       
  @TotalTaxableAmount =sum(ItemSubtotal), @TotalTaxAmount=sum(TaxAmount)       
 from INV_InvoiceDetail where invoiceno=@invoiceno          
       
 set @TotalTaxableAmount =@TotalTaxableAmount -@TotalTaxAmount -- total payment +tax +taxable amount        
        
 ---Add credit side-- taxable amount with uniform credit account        
 insert into INT_SalesDistributionSourceTable        
 (      
  SeqNum,SOPNumber,SOPType,DistType,AccountNumber,DebitAmount,CreditAmount,DistributionRef,IntegrationStatus,Error      
 )        
 select        
  SeqNum=1 -- only 1 row will push                
  ,SOPNumber=@invoiceno        
  ,SOPType=3           
  ,DistType=1        
  ,AccountNumber=@UniformCreditAccount        
  ,DebitAmount= 0        
  ,CreditAmount=@TotalTaxableAmount        
  ,DistributionRef='UNIFORM SALES FOR INV NO '+cast(@invoiceno as nvarchar(50))        
  ,IntegrationStatus=0                
  ,Error=null           
        
 ---Add credit side-- VAT amount with VAT credit account        
 insert into INT_SalesDistributionSourceTable        
 (      
  SeqNum,SOPNumber,SOPType,DistType,AccountNumber,DebitAmount,CreditAmount,DistributionRef,IntegrationStatus,Error      
 )        
 select        
  SeqNum=2 -- only 1 row will push                
  ,SOPNumber=@invoiceno        
  ,SOPType=3           
  ,DistType=1        
  ,AccountNumber=@VATCreditAccount       
  ,DebitAmount=0         
  ,CreditAmount=@TotalTaxAmount        
  ,DistributionRef='UNIFORM SALES FOR INV NO '+cast(@invoiceno as nvarchar(50))        
  ,IntegrationStatus=0                
  ,Error=null           
         
 -- Debit record will be added for payment method        
 ---Add credit side-- from payment method         
 --Multiple record as per payment category        
 insert into INT_SalesDistributionSourceTable        
 (      
  SeqNum,SOPNumber,SOPType,DistType,AccountNumber,DebitAmount,CreditAmount,DistributionRef,IntegrationStatus,Error      
 )        
 select        
  SeqNum=ROW_NUMBER() over(partition by invoiceno order by InvoicePaymentId asc)      +2          
  ,SOPNumber=invoiceno        
  ,SOPType=3        
  ,DistType=3        
  ,AccountNumber=pm.CreditAccount        
  ,DebitAmount=PaymentAmount        
  ,CreditAmount=0        
  ,DistributionRef='UNIFORM SALES FOR INV NO '+cast(invoiceno as nvarchar(50))        
  ,IntegrationStatus=0                
  ,Error=null        
 from INV_InvoicePayment tp        
 join tblPaymentMethod pm        
 on tp.PaymentMethod=pm.PaymentMethodName   
 where invoiceno=@invoiceno        
        
 declare @FromDateRange Datetime = '01/01/1900'            
 declare @ToDateRange Datetime = '01/01/1900'                
            
 --exec INT_CreateSalesInvoiceInGP @CallFrom=1, @SourceDB='als_live',@DestDB= @DestinationDB,@FromDate = @FromDateRange ,@ToDate = @ToDateRange            
            
 select         
  @FromDateRange= InvoiceDate,        
  @ToDateRange= InvoiceDate         
 from INV_InvoiceSummary invSum                
 where invSum.invoiceno=@invoiceno        
        
 DECLARE @sql AS NVARCHAR(MAX)            
        
 /*            
 Use sp_executesql to dynamically pass in the db and stored procedure            
 to execute while also defining the values and assigning to local variables.            
 */            
 SET @sql = N'EXEC ' + @DestinationDB + '.dbo.[INT_CreateSalesInvoiceInGP] @CallFrom , @SourceDB, @DestDB, @FromDate, @ToDate'            
 EXEC sp_executesql @sql            
 , N'@CallFrom AS INT, @SourceDB as CHAR(30), @DestDB as CHAR(30),@FromDate as Datetime ,@ToDate as Datetime  '            
 , @CallFrom = 0            
 , @SourceDB = @SourceDBName            
 , @DestDB = @DestinationDB            
 , @FromDate = @FromDateRange            
 , @ToDate = @ToDateRange            
            
 print @sql           
         
  select 0 result        
      
  SELECT    
   CallFrom = 0            
 , SourceDB = @SourceDBName            
 , DestDB = @DestinationDB            
 , FromDate = @FromDateRange            
 , ToDate = @ToDateRange      
    
 end TRY              
 begin catch      
  SELECT -1 AS Result, 'Error!' AS Response          
  EXEC usp_SaveErrorDetail          
  select* from tblErrors              
  end catch      
end 
GO

DROP PROCEDURE IF EXISTS  [dbo].[sp_ProcessGP_TuitionInvoice]
GO

CREATE PROCEDURE [dbo].[sp_ProcessGP_TuitionInvoice]    
(              
  @invoiceno bigint=0   ,          
  @DestinationDB nvarchar(50) = ''          
)              
AS              
BEGIN         
  BEGIN TRY
	
	declare @invoicenoString nvarchar(100)= cast(@invoiceno as nvarchar(100))
	
	 --Update database    
	 DECLARE @SourceDBName NVARCHAR(50)= 'ALS_LIVE'       
              
	 -----------sales detail processing              
	 declare @SOPType int=3              
	 declare @DocID nvarchar(50)='STDINV'              
	 declare @IntegrationStatus int=0              
              
	 Declare @InvoiceTypeCount int=0              
	 declare @totalPayableAmount decimal(18,4)=0 

	 declare @AcademicYear bigint
	 
	 declare @parentcode nvarchar(50)
	 declare @AcademicYearName nvarchar(50)
	 
	 declare @InvoiceType nvarchar(50)
	 declare @InvoiceDate  datetime
	 declare @PaymentMethod nvarchar(50)	

	 select top 1 @PaymentMethod=PaymentMethod from INV_InvoicePayment order by PaymentAmount desc

	 select top 1 @InvoiceType=InvoiceType,@InvoiceDate=InvoiceDate from INV_InvoiceSummary where invoiceno=@invoiceno

	 select top 1 @AcademicYear =AcademicYear  from INV_InvoiceDetail where invoiceno=@invoiceno
	 select top 1 * into #INV_InvoiceDetail from INV_InvoiceDetail where invoiceno=@invoiceno
	 select top 1 *,invoiceno=@invoiceno into #tblSchoolAcademic from tblSchoolAcademic where SchoolAcademicId=@AcademicYear

	 select top 1 @AcademicYearName=AcademicYear from #tblSchoolAcademic
	 
	declare @CurrentAcademicYearEndDate datetime
	select top 1 @CurrentAcademicYearEndDate =PeriodTo from tblSchoolAcademic where IsCurrentYear=1	

	declare @IsAdvance int=0
	if exists(select * from tblSchoolAcademic where cast(PeriodFrom as date)> cast(@CurrentAcademicYearEndDate as date) and SchoolAcademicId=@AcademicYear)
	begin
		set @IsAdvance =1;
	end

	select top 1  @parentcode=parentcode from #INV_InvoiceDetail

	select      
		RN=ROW_NUMBER() over(partition by invoiceno order by PaymentAmount asc)        
		,SOPNumber=invoiceno      
		,SOPType=3      
		,DistType=3      
		,AccountNumber=pm.CreditAccount  
		,CreditAccount=pm.CreditAccount
		,DebitAccount=pm.DebitAccount
		,DebitAmount=PaymentAmount      
		,CreditAmount=0
		,IntegrationStatus=0              
		,Error=null  
		,PaymentMethod=pm.PaymentMethodName
		,PaymentReferenceNumber
		,invoiceno
		,AcademicYear=@AcademicYear
	into #INV_InvoicePayment
	from INV_InvoicePayment tp      
	join tblPaymentMethod pm      
	on tp.PaymentMethod=pm.PaymentMethodName 
	where invoiceno=@invoiceno

	declare @TuitionDebitAccount nvarchar(50)=''      
	declare @TuitionCreditAccount nvarchar(50)=''      
      
	declare @VATDebitAccount nvarchar(50)=''      
	declare @VATCreditAccount nvarchar(50)=''      
      
	select top 1      
		@VATDebitAccount=vat.DebitAccount,      
		@VATCreditAccount=vat.CreditAccount       
	from tblVatMaster vat      
	inner join tblFeeTypeMaster fee       
	on vat.FeeTypeId=fee.FeeTypeId      
	where vat.IsActive=1 and vat.IsDeleted=0      
	and FeeTypeName like '%Tuition%'      
      
	select top 1       
		@TuitionDebitAccount=DebitAccount,      
		@TuitionCreditAccount=CreditAccount       
	from tblFeeTypeMaster      
	where FeeTypeName like '%Tuition%'  

	select  top 0
		SeqNum=1
		,Reference='T.FEE INV-'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=@InvoiceDate
		,ReversingDate=null
		,AccountNumber=case when @InvoiceType='Invoice' then invD.DebitAccount else invD.CreditAccount end
		,DistributionRef='RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(PaymentMethod, 1, 4)
		,CreditAmount=0
		,DebitAmount=invd.DebitAmount
		,IntegrationStatus=0
		,Error=null
	into #INT_GLSourceTable
	from
	#INV_InvoicePayment invD

if(@IsAdvance=0)
begin
	--Row 1- Debit record

	insert into #INT_GLSourceTable
	select 
		SeqNum=1
		,Reference='T.FEE INV-'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=@InvoiceDate
		,ReversingDate=null
		,AccountNumber=case when @InvoiceType='Invoice' then invD.DebitAccount else invD.CreditAccount end
		,DistributionRef='RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(PaymentMethod, 1, 4)
		,CreditAmount=0
		,DebitAmount=invd.DebitAmount
		,IntegrationStatus=0
		,Error=null
	
	from
	#INV_InvoicePayment invD

	--Row-2: credit record- VAT record if VAT available

	insert into #INT_GLSourceTable
	select 
		SeqNum=2
		,Reference='T.FEE INV-'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=@InvoiceDate
		,ReversingDate=null
		,AccountNumber=case when @InvoiceType='Invoice' then @VATCreditAccount else @VATCreditAccount end
		,DistributionRef='RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)
		,CreditAmount=invd.TaxAmount
		,DebitAmount=0
		,IntegrationStatus=0
		,Error=null
	from
	INV_InvoiceDetail invD
	join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo	
	and invD.TaxAmount>0
	 where invD.invoiceno=@invoiceno

	--Row-3: credit record- Tuition Fee
	insert into #INT_GLSourceTable
	select 
		SeqNum=3
		,Reference='T.FEE INV-'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=@InvoiceDate
		,ReversingDate=null
		,AccountNumber=case when invS.InvoiceType='Invoice' then parA.ReceivableAccount else parA.AdvanceAccount end
		,DistributionRef='RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)
		,CreditAmount=invd.ItemSubtotal-invd.TaxAmount
		,DebitAmount=0
		,IntegrationStatus=0
		,Error=null
	from
	INV_InvoiceDetail invD
	join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo
	join tblParent par on invD.ParentId=par.ParentId
	join tblParentAccount parA on par.ParentId=parA.ParentId
	where invD.invoiceno=@invoiceno 
end
else

begin
	---Case 2 Start:- When Advance available:
	--Row 1- Debit record
	insert into #INT_GLSourceTable
	select 
		SeqNum=4
		,Reference='ADV INV-'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=@InvoiceDate
		,ReversingDate=null
		,AccountNumber=case when @InvoiceType='Invoice' then invD.DebitAccount else invD.CreditAccount end
		,DistributionRef='RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(PaymentMethod, 1, 4)
		,CreditAmount=0
		,DebitAmount=invd.DebitAmount
		,IntegrationStatus=0
		,Error=null
	from
	#INV_InvoicePayment invD

	--Row-2: credit record- VAT record if VAT available
	insert into #INT_GLSourceTable
	select 
		SeqNum=5
		,Reference='ADV INV-'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=@InvoiceDate
		,ReversingDate=null
		,AccountNumber=case when invS.InvoiceType='Invoice' then @VATCreditAccount else @VATDebitAccount end
		,DistributionRef='RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)
		,CreditAmount=invd.TaxAmount
		,DebitAmount=0
		,IntegrationStatus=0
		,Error=null
	from
	INV_InvoiceDetail invD
	join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo	
	and invD.TaxAmount>0
	 where invD.invoiceno=@invoiceno

	--Row-3: credit record- Tuition Fee
	insert into #INT_GLSourceTable
	select 
		SeqNum=6
		,Reference='ADV INV-'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=@InvoiceDate
		,ReversingDate=null
		,AccountNumber= case when invS.InvoiceType='Invoice' then parA.AdvanceAccount else parA.ReceivableAccount end
		,DistributionRef='RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)
		,CreditAmount=invd.ItemSubtotal-invd.TaxAmount
		,DebitAmount=0
		,IntegrationStatus=0
		,Error=null
	from
	INV_InvoiceDetail invD
	join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo
	join tblParent par on invD.ParentId=par.ParentId
	join tblParentAccount parA on par.ParentId=parA.ParentId
	where invD.invoiceno=@invoiceno 

end
	---Case 2 End:- When Advance available:

	insert into INT_GLSourceTable
	(
		SeqNum,Reference,JournalNumber,TransactionType,TransactionDate,ReversingDate,AccountNumber
		,DistributionRef,CreditAmount,DebitAmount,IntegrationStatus,Error
	)
	select
		SeqNum=ROW_NUMBER() over(order by SeqNum),Reference	,JournalNumber	,TransactionType	,TransactionDate	,ReversingDate	,AccountNumber	
		,DistributionRef	,CreditAmount	=sum(CreditAmount),DebitAmount	=sum(DebitAmount),IntegrationStatus	,Error
	from
	(
		select 
			SeqNum,Reference	,JournalNumber	,TransactionType	,TransactionDate	,ReversingDate	,AccountNumber	,DistributionRef	
			,CreditAmount	,DebitAmount	,IntegrationStatus	,Error
		from #INT_GLSourceTable
	)t
	group by 
	SeqNum,Reference,JournalNumber	,TransactionType	,TransactionDate	,ReversingDate	,AccountNumber	
	,DistributionRef	,IntegrationStatus	,Error
   
	 -----------payment processing 

	 declare @FromDateRange Datetime = '01/01/1900'          
	 declare @ToDateRange Datetime = '01/01/1900'              
   
	 select       
	  @FromDateRange= InvoiceDate,      
	  @ToDateRange= InvoiceDate       
	 from INV_InvoiceSummary invSum              
	 where invSum.invoiceno=@invoiceno      
      
	 DECLARE @sql AS NVARCHAR(MAX)          
      --Could not find stored procedure 'two.dbo.INT_CreateGLInGP'.
	 /*          
	 Use sp_executesql to dynamically pass in the db and stored procedure          
	 to execute while also defining the values and assigning to local variables.          
	 */      

	 SET @sql = N'EXEC ' + @DestinationDB + '.dbo.INT_CreateGLInGP @CallFrom , @SourceDB, @DestDB, @FromDate, @ToDate'          
	 EXEC sp_executesql @sql          
	 , N'@CallFrom AS INT, @SourceDB as CHAR(30), @DestDB as CHAR(30),@FromDate as Datetime ,@ToDate as Datetime  '          
	 , @CallFrom = 0          
	 , @SourceDB = @SourceDBName          
	 , @DestDB = @DestinationDB          
	 , @FromDate = @FromDateRange          
	 , @ToDate = @ToDateRange          
          
	 print @sql         
       
	select 0 result  
	 
	 DROP TABLE #INV_InvoicePayment
	 DROP TABLE #INT_GLSourceTable
	 DROP TABLE #INV_InvoiceDetail
	 DROP TABLE #tblSchoolAcademic
	
	 --select * from INT_GLSourceTable

	 truncate table tblerrors

 end TRY            
 begin catch    
	  SELECT -1 AS Result, 'Error!' AS Response        
	  EXEC usp_SaveErrorDetail        
	  select* from tblErrors            
  end catch    
end  
GO

DROP PROCEDURE IF EXISTS [dbo].[sp_GetParentMonthwiseFeeInfo]
GO

CREATE PROCEDURE [dbo].[sp_GetParentMonthwiseFeeInfo]  
@parentId bigint  
AS    
BEGIN    
   
SELECT   
    ParentId,
    [MonthName] = DATENAME(month, UpdateDate),
    TotalFee = SUM(TotalFee),  
    FeePaid = SUM(FeePaid),  
    Discount = SUM(DiscountCollected) - SUM(DiscountReturn),  
    PendingAmount = SUM(TotalFee) - SUM(FeePaid) - (SUM(DiscountCollected) - SUM(DiscountReturn))  
FROM   
(  
    SELECT  
        ParentId,  
        UpdateDate,
        TotalFee = CASE WHEN FeeStatementType = 'Fee Applied' THEN FeeAmount ELSE 0 END,  
        FeePaid = CASE WHEN FeeStatementType = 'Fee Paid' THEN PaidAmount ELSE 0 END,  
        DiscountCollected = CASE WHEN FeeStatementType IN ('Sibling Discount Applied', 'Management Discount Applied') THEN PaidAmount ELSE 0 END,  
        DiscountReturn = CASE WHEN FeeStatementType = 'Management Discount Cancelled' THEN PaidAmount ELSE 0 END,  
        PendingAmount = 0  
    FROM tblFeeStatement  
    WHERE ParentId = @parentId  
) t  
GROUP BY ParentId, DATENAME(month, UpdateDate)

END
GO

DROP PROCEDURE IF EXISTS [dbo].[sp_GetTotalParentFeeInfo]
GO

CREATE PROCEDURE [dbo].[sp_GetTotalParentFeeInfo]  
@parentId bigint  
AS    
BEGIN    
   
select   
ParentId 
,TotalFee =sum(TotalFee)  
,FeePaid =sum(FeePaid)  
,Discount =sum(DiscountCollected)-sum(DiscountReturn)  
,PendingAmount=sum(TotalFee)-sum(FeePaid)-(sum(DiscountCollected)-sum(DiscountReturn))  
from   
(  
select  
ParentId  
,TotalFee=case when FeeStatementType='Fee Applied' then  FeeAmount else 0 end  
,FeePaid=case when FeeStatementType='Fee Paid' then  PaidAmount else 0 end  
,DiscountCollected=case when FeeStatementType='Sibling Discount Applied' OR FeeStatementType='Management Discount Applied' then  PaidAmount else 0 end  
,DiscountReturn=case when FeeStatementType='Management Discount Cancelled'  then  PaidAmount else 0 end  
,PendingAmount=0  
  
from tblFeeStatement  
where ParentId=@parentId  
)t  
group by ParentId
  
END    
GO

DROP PROCEDURE IF EXISTS [dbo].[sp_GetParentYearwiseFeeInfo]
GO

CREATE PROCEDURE [dbo].[sp_GetParentYearwiseFeeInfo]  
@parentId bigint  
AS    
BEGIN    
   
select   
ParentId 
,YearNumber
,TotalFee =sum(TotalFee)  
,FeePaid =sum(FeePaid)  
,Discount =sum(DiscountCollected)-sum(DiscountReturn)  
,PendingAmount=sum(TotalFee)-sum(FeePaid)-(sum(DiscountCollected)-sum(DiscountReturn))  
from   
(  
select  
ParentId  
,YearNumber= datepart(year,UpdateDate)
,TotalFee=case when FeeStatementType='Fee Applied' then  FeeAmount else 0 end  
,FeePaid=case when FeeStatementType='Fee Paid' then  PaidAmount else 0 end  
,DiscountCollected=case when FeeStatementType='Sibling Discount Applied' OR FeeStatementType='Management Discount Applied' then  PaidAmount else 0 end  
,DiscountReturn=case when FeeStatementType='Management Discount Cancelled'  then  PaidAmount else 0 end  
,PendingAmount=0  
  
from tblFeeStatement  
where ParentId=@parentId  
)t  
group by ParentId  ,YearNumber
  
END    
GO

DROP PROCEDURE IF EXISTS  [dbo].[sp_GetParentFeeInfo]
GO

CREATE PROCEDURE [dbo].[sp_GetParentFeeInfo]  
 @parentId bigint
AS  
BEGIN  
	
select 
ParentId
,TotalFee	=sum(TotalFee)
,FeePaid	=sum(FeePaid)
,Discount	=sum(DiscountCollected)-sum(DiscountReturn)
,PendingAmount=sum(TotalFee)-sum(FeePaid)-(sum(DiscountCollected)-sum(DiscountReturn))
from 
(
select
ParentId
,TotalFee=case when FeeStatementType='Fee Applied' then  FeeAmount else 0 end
,FeePaid=case when FeeStatementType='Fee Paid' then  PaidAmount else 0 end
,DiscountCollected=case when FeeStatementType='Sibling Discount Applied' OR FeeStatementType='Management Discount Applied' then  PaidAmount else 0 end
,DiscountReturn=case when FeeStatementType='Management Discount Cancelled'  then  PaidAmount else 0 end
,PendingAmount=0

from tblFeeStatement
where ParentId=@parentId
)t
group by ParentId

END  
GO

DROP PROCEDURE IF EXISTS [dbo].[sp_ProcessGP_UniformInvoice]
GO

CREATE PROCEDURE [dbo].[sp_ProcessGP_UniformInvoice]      
(                
  @invoiceno bigint=0   ,            
  @DestinationDB nvarchar(50) = ''            
)                
AS                
BEGIN           
  BEGIN TRY           
          
 IF OBJECT_ID('tempdb..#INT_ALS_SalesInvoiceSourceTable') IS NOT NULL        
 DROP TABLE #INT_ALS_SalesInvoiceSourceTable        
    
 delete from INT_SalesInvoiceSourceTable where SOPNumber=8116    
 delete from INT_SalesPaymentSourceTable where SOPNumber=@invoiceno    
 delete from INT_SalesDistributionSourceTable where SOPNumber=@invoiceno    
        
 --Update database      
 DECLARE @SourceDBName NVARCHAR(50)= 'ALS_LIVE'         
                
 -----------sales detail processing                
 declare @SOPType int=3                
 declare @DocID nvarchar(50)='STDINV'                
 declare @IntegrationStatus int=0                
                
 Declare @InvoiceTypeCount int=0                
 declare @totalPayableAmount decimal(18,4)=0                
                
 select                 
  SeqNum=ROW_NUMBER() over(partition by invSum.invoiceno order by InvoiceDetailId)                
  ,SOPNumber=invSum.invoiceno                
  ,SOPType=@SOPType                
  ,DocID=@DocID                
  ,DocDate= cast(invSum.InvoiceDate as date)                
  ,CustomerNumber='CASH CUSTOMER'                
  ,ItemNumber=invDet.ItemCode                
  ,Quantity=invDet.Quantity                 
  ,UnitPrice=invDet.ItemSubtotal-invDet.TaxAmount        
  ,ItemSubtotal=invDet.ItemSubtotal                
  ,IntegrationStatus=@IntegrationStatus                
  ,Error=0                
  ,invDet.InvoiceType                
 into #INT_ALS_SalesInvoiceSourceTable                
 from INV_InvoiceDetail invDet                
 join INV_InvoiceSummary invSum                
 on invDet.InvoiceNo=invSum.InvoiceNo                
 where invDet.InvoiceType like '%Uniform%'                
 and invSum.invoiceno=@invoiceno                
                
 insert into INT_SalesInvoiceSourceTable(SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,UnitPrice,IntegrationStatus,Error)                
 select                 
  SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,(ItemSubtotal/Quantity),IntegrationStatus,Error                
 from #INT_ALS_SalesInvoiceSourceTable                
                
 -----------payment processing                
         
 select @InvoiceTypeCount=count(InvoiceType) from #INT_ALS_SalesInvoiceSourceTable                 
 select @totalPayableAmount=sum(isnull(ItemSubtotal,0)) from #INT_ALS_SalesInvoiceSourceTable                
                
 --4 for Cash payment, 5 for Check payment & bank transfer, and 6 for Credit card payment.                
 --Bank Transfer =5                
 --Check=5                
 --Cash=4                
 --Visa=6                
                  
 if(@InvoiceTypeCount>1)                
 begin                
  insert into INT_SalesPaymentSourceTable                
  (                
   SeqNum,SOPNumber,SOPType,PaymentType,PaymentAmount,CheckbookID,CardName,CheckNumber,CreditCardNumber,                
   AuthorizationCode,ExpirationDate,IntegrationStatus,Error                
  )                
  select                 
   SeqNum                
   ,SOPNumber                
   ,SOPType                
   ,PaymentType                
   ,PaymentAmount         
   ,CheckbookID        
   ,CardName                
   ,CheckNumber                
   ,CreditCardNumber                
   ,AuthorizationCode                
   ,ExpirationDate                
   ,IntegrationStatus                
   ,Error                
  from                 
  (                
   select top 1                 
    SeqNum=1                
    ,SOPNumber=invoiceno                
    ,SOPType=3                
    ,PaymentType=case when PaymentMethod='Cash' then 4 when PaymentMethod='Visa' then 6 else 5 end       
    ,PaymentAmount=@totalPayableAmount                
    ,CheckbookID=PaymentMethod        
    ,CardName=''             
    ,CheckNumber=PaymentReferenceNumber                
    ,CreditCardNumber=null                
    ,AuthorizationCode=null                
    ,ExpirationDate=null                
    ,IntegrationStatus=0                
    ,Error=null                
   from als_live.dbo.INV_InvoicePayment                
   where invoiceno=@invoiceno                
  )t      
 end                
 else                
 begin                
  insert into INT_SalesPaymentSourceTable                
  (                
   SeqNum,SOPNumber,SOPType,PaymentType,PaymentAmount,CheckbookID,CardName,CheckNumber,CreditCardNumber,                
   AuthorizationCode,ExpirationDate,IntegrationStatus,Error                
  )                
  select      
   SeqNum                
   ,SOPNumber                
   ,SOPType                
   ,PaymentType                
   ,PaymentAmount        
   ,CheckbookID        
   ,CardName                
   ,CheckNumber                
   ,CreditCardNumber                
   ,AuthorizationCode                
   ,ExpirationDate                
   ,IntegrationStatus                
   ,Error                
  from                 
  (                
   select                
    SeqNum=ROW_NUMBER() over(partition by invoiceno order by InvoicePaymentId asc)                
    ,SOPNumber=invoiceno                
    ,SOPType=3                
    ,PaymentType=case when PaymentMethod='Cash' then 4 when PaymentMethod='Visa' then 6 else 5 end                
    ,PaymentAmount=@totalPayableAmount                
    ,CheckbookID=PaymentMethod        
    ,CardName=''                
    ,CheckNumber=PaymentReferenceNumber                
    ,CreditCardNumber=null                
    ,AuthorizationCode=null                
    ,ExpirationDate=null                
    ,IntegrationStatus=0                
    ,Error=null                
   from INV_InvoicePayment                
   where invoiceno=@invoiceno                 
  )t           
 end      
      
 --payment information can be multiple with their debit account number and payment amount        
        
 declare @UniformDebitAccount nvarchar(50)=''        
 declare @UniformCreditAccount nvarchar(50)=''        
        
 declare @VATDebitAccount nvarchar(50)=''        
 declare @VATCreditAccount nvarchar(50)=''        
        
 select top 1        
  @VATDebitAccount=vat.DebitAccount,        
  @VATCreditAccount=vat.CreditAccount         
 from tblVatMaster vat        
 inner join tblFeeTypeMaster fee         
 on vat.FeeTypeId=fee.FeeTypeId        
 where vat.IsActive=1 and vat.IsDeleted=0        
 and FeeTypeName like '%UNIFORM%'        
        
 select top 1         
  @UniformDebitAccount=DebitAccount,        
  @UniformCreditAccount=CreditAccount         
 from tblFeeTypeMaster        
 where FeeTypeName like '%UNIFORM%'        
        
 declare @TotalTaxableAmount decimal(18,2)=0        
 declare @TotalTaxAmount decimal(18,2)=0        
       
 select       
  @TotalTaxableAmount =sum(ItemSubtotal), @TotalTaxAmount=sum(TaxAmount)       
 from INV_InvoiceDetail where invoiceno=@invoiceno          
       
 set @TotalTaxableAmount =@TotalTaxableAmount -@TotalTaxAmount -- total payment +tax +taxable amount        
        
 ---Add credit side-- taxable amount with uniform credit account        
 insert into INT_SalesDistributionSourceTable        
 (      
  SeqNum,SOPNumber,SOPType,DistType,AccountNumber,DebitAmount,CreditAmount,DistributionRef,IntegrationStatus,Error      
 )        
 select        
  SeqNum=1 -- only 1 row will push                
  ,SOPNumber=@invoiceno        
  ,SOPType=3           
  ,DistType=1        
  ,AccountNumber=@UniformCreditAccount        
  ,DebitAmount= 0        
  ,CreditAmount=@TotalTaxableAmount        
  ,DistributionRef='UNIFORM SALES FOR INV NO '+cast(@invoiceno as nvarchar(50))        
  ,IntegrationStatus=0                
  ,Error=null           
        
 ---Add credit side-- VAT amount with VAT credit account        
 insert into INT_SalesDistributionSourceTable        
 (      
  SeqNum,SOPNumber,SOPType,DistType,AccountNumber,DebitAmount,CreditAmount,DistributionRef,IntegrationStatus,Error      
 )        
 select        
  SeqNum=2 -- only 1 row will push                
  ,SOPNumber=@invoiceno        
  ,SOPType=3           
  ,DistType=1        
  ,AccountNumber=@VATCreditAccount       
  ,DebitAmount=0         
  ,CreditAmount=@TotalTaxAmount        
  ,DistributionRef='UNIFORM SALES FOR INV NO '+cast(@invoiceno as nvarchar(50))        
  ,IntegrationStatus=0                
  ,Error=null           
         
 -- Debit record will be added for payment method        
 ---Add credit side-- from payment method         
 --Multiple record as per payment category        
 insert into INT_SalesDistributionSourceTable        
 (      
  SeqNum,SOPNumber,SOPType,DistType,AccountNumber,DebitAmount,CreditAmount,DistributionRef,IntegrationStatus,Error      
 )        
 select        
  SeqNum=ROW_NUMBER() over(partition by invoiceno order by InvoicePaymentId asc)      +2          
  ,SOPNumber=invoiceno        
  ,SOPType=3        
  ,DistType=3        
  ,AccountNumber=pm.CreditAccount        
  ,DebitAmount=PaymentAmount        
  ,CreditAmount=0        
  ,DistributionRef='UNIFORM SALES FOR INV NO '+cast(invoiceno as nvarchar(50))        
  ,IntegrationStatus=0                
  ,Error=null        
 from INV_InvoicePayment tp        
 join tblPaymentMethod pm        
 on tp.PaymentMethod=pm.PaymentMethodName   
 where invoiceno=@invoiceno        
        
 declare @FromDateRange Datetime = '01/01/1900'            
 declare @ToDateRange Datetime = '01/01/1900'                
            
 --exec INT_CreateSalesInvoiceInGP @CallFrom=1, @SourceDB='als_live',@DestDB= @DestinationDB,@FromDate = @FromDateRange ,@ToDate = @ToDateRange            
            
 select         
  @FromDateRange= InvoiceDate,        
  @ToDateRange= InvoiceDate         
 from INV_InvoiceSummary invSum                
 where invSum.invoiceno=@invoiceno        
        
 DECLARE @sql AS NVARCHAR(MAX)            
        
 /*            
 Use sp_executesql to dynamically pass in the db and stored procedure            
 to execute while also defining the values and assigning to local variables.            
 */            
 SET @sql = N'EXEC ' + @DestinationDB + '.dbo.[INT_CreateSalesInvoiceInGP] @CallFrom , @SourceDB, @DestDB, @FromDate, @ToDate'            
 EXEC sp_executesql @sql            
 , N'@CallFrom AS INT, @SourceDB as CHAR(30), @DestDB as CHAR(30),@FromDate as Datetime ,@ToDate as Datetime  '            
 , @CallFrom = 0            
 , @SourceDB = @SourceDBName            
 , @DestDB = @DestinationDB            
 , @FromDate = @FromDateRange            
 , @ToDate = @ToDateRange            
            
 print @sql           
         
  select 0 result        
      
  SELECT    
   CallFrom = 0            
 , SourceDB = @SourceDBName            
 , DestDB = @DestinationDB            
 , FromDate = @FromDateRange            
 , ToDate = @ToDateRange      
    
 end TRY              
 begin catch      
  SELECT -1 AS Result, 'Error!' AS Response          
  EXEC usp_SaveErrorDetail          
  select* from tblErrors              
  end catch      
end 
GO

DROP PROCEDURE IF EXISTS  [dbo].[sp_GetStudentByParentId]
GO

CREATE PROCEDURE [dbo].[sp_GetStudentByParentId]
@ParentId bigint
as
begin
select *, tgm.GradeName from tblStudent as ts 
join tblGradeMaster as tgm on ts.GradeId = tgm.GradeId
where ParentId = @ParentId

end
GO

DROP PROCEDURE IF EXISTS  [dbo].[sp_GetCostCenterFees]
GO

CREATE PROCEDURE [dbo].[sp_GetCostCenterFees]
AS
BEGIN
	SELECT 
		tccm.CostCenterId, 
		tccm.CostCenterName,
		SUM(tfgd.FeeAmount) as 'TotalAppliedFee',
		SUM(tfs.PaidAmount) AS 'TotalPaidAmount'
	FROM tblGradeMaster AS tgm
	JOIN tblCostCenterMaster AS tccm 
		ON tgm.CostCenterId = tccm.CostCenterId
	JOIN tblFeeGenerateDetail AS tfgd 
		ON tgm.GradeId = tfgd.GradeId
	JOIN tblFeeStatement AS tfs 
		ON tgm.GradeId = tfs.GradeId
	GROUP BY tccm.CostCenterId, 
		tccm.CostCenterName
	ORDER BY tccm.CostCenterId
END
GO

DROP PROCEDURE IF EXISTS  [dbo].[sp_GetGradeFees]
GO

CREATE PROCEDURE [dbo].[sp_GetGradeFees]
AS
BEGIN
    SELECT 
        tgm.GradeId, 
		tgm.SequenceNo,
        tgm.GradeName,   
        SUM(tfgd.FeeAmount) AS TotalAppliedFee, 
        SUM(tfs.PaidAmount) AS TotalPaidAmount
    FROM 
        tblGradeMaster AS tgm
    JOIN 
        tblFeeGenerateDetail AS tfgd 
    ON 
        tgm.GradeId = tfgd.GradeId
    JOIN 
        tblFeeStatement AS tfs 
    ON 
        tgm.GradeId = tfs.GradeId
    GROUP BY 
        tgm.GradeId,
        tgm.GradeName,
		tgm.SequenceNo
   ORDER BY 
	    tgm.SequenceNo 
END;
GO

DROP PROCEDURE IF EXISTS  [dbo].[sp_SaveSchoolAcademic]
GO

CREATE PROCEDURE [dbo].[sp_SaveSchoolAcademic]  
	@LoginUserId int  
	,@SchoolAcademicId int  
	,@AcademicYear nvarchar(200)    
	,@PeriodFrom datetime  
	,@PeriodTo datetime  
	,@DebitAccount nvarchar(200)  
	,@CreditAccount nvarchar(200)  
	,@IsActive bit
	,@IsCurrentYear bit
AS  
BEGIN  
 SET NOCOUNT ON;  
 IF EXISTS(SELECT 1 FROM tblSchoolAcademic WHERE AcademicYear = @AcademicYear  
	AND SchoolAcademicId <> @SchoolAcademicId AND IsActive = 1
		AND 
		(   
			(cast( @PeriodFrom as date) between cast( PeriodFrom as date) AND cast(PeriodTo as date))
		OR
			(cast( @PeriodTo as date) between cast( PeriodFrom as date) AND cast(PeriodTo as date))
		)
	)  
 BEGIN  
  SELECT -2 AS Result, 'Academic year already exists!' AS Response  
  RETURN;  
 END 
 
 IF EXISTS(SELECT 1 FROM tblSchoolAcademic WHERE SchoolAcademicId <> @SchoolAcademicId AND IsActive = 1
		AND 
		(   
			(cast( @PeriodFrom as date) between cast( PeriodFrom as date) AND cast(PeriodTo as date))
		OR
			(cast( @PeriodTo as date) between cast( PeriodFrom as date) AND cast(PeriodTo as date))
		)
	)  
 BEGIN  
  SELECT -4 AS Result, 'Academic year already exists!' AS Response  
  RETURN;  
 END 


 IF (@IsCurrentYear = 1) 
 AND EXISTS (SELECT 1 FROM tblSchoolAcademic 
             WHERE IsCurrentYear = 1 AND SchoolAcademicId <> @SchoolAcademicId AND IsActive = 1)
 BEGIN  
  SELECT -5 AS Result, 'Current year is already selected!' AS Response  
  RETURN;  
 END 

 BEGIN TRY  
  BEGIN TRANSACTION TRANS1  
   IF(@SchoolAcademicId = 0)  
   BEGIN  
    INSERT INTO tblSchoolAcademic  
      (AcademicYear  
      ,PeriodFrom  
      ,PeriodTo  
	  ,DebitAccount
	  ,CreditAccount
      ,IsActive  
	  ,IsCurrentYear
      ,IsDeleted  
      ,UpdateDate  
      ,UpdateBy)  
    VALUES  
        (@AcademicYear  
        --,dbo.GetDateTimeFromTimeStamp(@PeriodFrom)  
        --,dbo.GetDateTimeFromTimeStamp(@PeriodTo) 
		,@PeriodFrom
        ,@PeriodTo
		,@DebitAccount
		,@CreditAccount
        ,@IsActive 
		,@IsCurrentYear
        ,0  
        ,GETDATE()  
        ,@LoginUserId)  
   END  
   ELSE  
   BEGIN  
    UPDATE tblSchoolAcademic  
      SET 
       AcademicYear = @AcademicYear  
       --,PeriodFrom = dbo.GetDateTimeFromTimeStamp(@PeriodFrom)        
       --,PeriodTo = dbo.GetDateTimeFromTimeStamp(@PeriodTo)
	   ,PeriodFrom = @PeriodFrom       
       ,PeriodTo =@PeriodTo
	    ,DebitAccount = @DebitAccount
		,CreditAccount = @CreditAccount
       ,IsActive = @IsActive 
	   ,IsCurrentYear = @IsCurrentYear
       ,UpdateDate = GETDATE()  
       ,UpdateBy = @LoginUserId  
    WHERE SchoolAcademicId = @SchoolAcademicId  
   END      
  COMMIT TRAN TRANS1  
  SELECT 0 AS Result, 'Saved' AS Response  
 END TRY  
  
 BEGIN CATCH  
   ROLLBACK TRAN TRANS1  
   SELECT -1 AS Result, 'Error!' AS Response  
   EXEC usp_SaveErrorDetail  
   RETURN  
 END CATCH  
END
GO

DROP PROCEDURE IF EXISTS  [dbo].[sp_GetSchoolAcademic]
GO

CREATE PROCEDURE [dbo].[sp_GetSchoolAcademic]
	@SchoolAcademicId int = 0
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tsa.SchoolAcademicId
			,tsa.AcademicYear
			,tsa.PeriodFrom
			,tsa.PeriodTo
			,tsa.DebitAccount
			,tsa.CreditAccount
			,tsa.IsActive
			,tsa.IsCurrentYear
	FROM tblSchoolAcademic tsa		
	WHERE tsa.SchoolAcademicId = CASE WHEN @SchoolAcademicId> 0 THEN @SchoolAcademicId ELSE tsa.SchoolAcademicId END	
		AND tsa.IsDeleted = 0
	 ORDER BY tsa.SchoolAcademicId
END
GO

DROP PROCEDURE IF EXISTS  [dbo].[sp_GetParent]
GO
  
CREATE PROCEDURE [dbo].[sp_GetParent]      
 @ParentId bigint = 0,      
 @FilterSearch NVarChar(200)=null,      
 @FilterIsActive bit=1,      
 @FilterNationalityId int= 0      
AS      
BEGIN      
 SET NOCOUNT ON;       
 SELECT tp.ParentId      
  ,tp.ParentCode      
  ,tp.ParentImage      
  ,tp.FatherName      
  ,tp.FatherArabicName      
  ,tp.FatherNationalityId      
  ,tp.FatherMobile      
  ,tp.FatherEmail      
  ,tp.FatherIqamaNo      
  ,IsFatherStaff=cast(tp.IsFatherStaff  as bit)
   ,ftc.CountryName as FatherCountryName  
  
  ,tp.MotherName      
  ,MotherArabicName=isnull(tp.MotherArabicName,'')
  ,tp.MotherNationalityId      
  ,tp.MotherMobile      
  ,tp.MotherEmail      
  ,tp.MotherIqamaNo      
  ,IsMotherStaff =  cast(tp.IsMotherStaff  as bit) 
  ,mtc.CountryName as MotherCountryName  
  ,tp.IsActive      
  ,tp.IsDeleted      
  ,tp.UpdateDate      
  ,tp.UpdateBy        
 FROM tblParent tp       
 LEFT JOIN tblCountryMaster ftc      
  ON ftc.CountryId = tp.FatherNationalityId      
 LEFT JOIN tblCountryMaster mtc      
  ON mtc.CountryId = tp.MotherNationalityId      
 WHERE tp.ParentId = CASE WHEN @ParentId > 0 THEN @ParentId ELSE tp.ParentId END      
  --AND (tp.ParentCode LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.ParentCode END + '%'      
  -- OR tp.FatherName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.FatherName END + '%'      
  -- OR tp.FatherArabicName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.FatherArabicName END + '%'      
  -- OR ftc.CountryName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE ftc.CountryName END + '%'      
  -- OR tp.FatherMobile LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.FatherMobile END + '%'      
  -- OR tp.FatherEmail LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.FatherEmail END + '%'      
  -- OR tp.MotherName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.MotherName END + '%'      
  -- OR mtc.CountryName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE mtc.CountryName END + '%'      
  -- OR tp.MotherMobile LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.MotherMobile END + '%'      
  -- OR tp.MotherEmail LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.MotherEmail END + '%'      
  --)      
  AND tp.IsActive =  CASE WHEN  @ParentId > 0 THEN tp.IsActive ELSE @FilterIsActive  END      
  --AND (tp.FatherNationalityId = CASE WHEN @FilterNationalityId > 0 THEN @FilterNationalityId ELSE tp.FatherNationalityId END      
  --OR tp.MotherNationalityId = CASE WHEN @FilterNationalityId > 0 THEN @FilterNationalityId ELSE tp.MotherNationalityId END)      
  AND tp.IsDeleted =  0      
 ORDER BY tp.ParentCode      
 IF @ParentId>0      
 BEGIN      
 SELECT       
  stu.StudentId      
  ,stu.StudentCode      
  ,stu.StudentImage      
  ,stu.ParentId      
  ,tp.ParentCode      
  ,stu.StudentName      
  ,stu.StudentArabicName      
  ,stu.StudentEmail      
  ,stu.DOB      
  ,stu.IqamaNo      
  ,stu.NationalityId      
  ,tc.CountryName      
  ,stu.GenderId      
  ,tgt.GenderTypeName      
  ,stu.AdmissionDate      
  ,stu.CostCenterId      
  ,tcc.CostCenterName      
  ,stu.GradeId      
  ,tg.GradeName      
  ,stu.SectionId      
  ,ts.SectionName      
  ,stu.PassportNo      
  ,PassportExpiry=isnull(stu.PassportExpiry,'')
  ,Mobile=isnull(stu.Mobile,'')
  ,stu.StudentAddress      
  ,stu.StudentStatusId      
  ,tss.StatusName      
 ,Fees=isnull(stu.Fees  ,0)      
  ,stu.IsGPIntegration      
  ,WithdrawDate=isnull(stu.WithdrawDate   ,'1/1/1990')   
  ,WithdrawAt=isnull(stu.WithdrawAt ,0)      
  ,isnull(tt1.TermName,'') AS WithdrawAtTermName      
  ,WithdrawYear=isnull(stu.WithdrawYear,'')
 ,TermId=isnull(stu.TermId  ,0)      
  ,tt.TermName      
  ,stu.AdmissionYear      
   ,PrinceAccount=isnull(stu.PrinceAccount  ,0)      
  ,stu.IsActive       
 FROM tblStudent stu       
 INNER JOIN tblParent tp      
  ON tp.ParentId = stu.ParentId      
 INNER JOIN tblCountryMaster tc      
  ON tc.CountryId = stu.NationalityId      
 INNER JOIN tblGenderTypeMaster tgt      
  ON tgt.GenderTypeId = stu.GenderId      
 LEFT JOIN tblCostCenterMaster tcc      
  ON tcc.CostCenterId = stu.CostCenterId      
 LEFT JOIN tblGradeMaster tg      
  ON tg.GradeId = stu.GradeId      
 LEFT JOIN tblSection ts      
  ON ts.SectionId = stu.SectionId      
 LEFT JOIN tblStudentStatus tss      
  ON tss.StudentStatusId = stu.StudentStatusId      
 LEFT JOIN tblTermMaster tt      
  ON tt.TermId=stu.TermId      
 LEFT JOIN tblTermMaster tt1      
  ON tt1.TermId=stu.WithdrawAt      
 WHERE stu.ParentId=@ParentId       
  AND stu.IsDeleted =  0 AND stu.IsActive = 1      
 ORDER BY stu.StudentName      
 END      
 IF @ParentId>0      
 BEGIN      
 SELECT       
  tpa.ParentId      
  ,tpa.ReceivableAccount      
  ,tpa.AdvanceAccount        
 FROM tblParentAccount tpa        
 WHERE tpa.ParentId=@ParentId       
  AND tpa.IsDeleted =  0 AND tpa.IsActive = 1      
 END      
END  
GO

DROP PROCEDURE IF EXISTS  [dbo].[sp_getAdminDashboardData]
GO

CREATE PROCEDURE [dbo].[sp_getAdminDashboardData]  
as  
begin  
 select  count(1) as TotalStudent  
 from tblStudent  
  
 select  count(1) as TotalParent from tblParent  
  
 select   
 case when GenderId=1 then 'Male' else 'Female' end as Gender, GradeName as KeyName, count(1) as KeyValue  
 from tblStudent stu  
 inner join tblGradeMaster grade  
 on stu.GradeId=grade.GradeId  
  
 group by GradeName,GenderId  
  
  
  select KeyName, count(1) as KeyValue from 
  (
 select   
  datepart(year, AdmissionYear) as KeyName
 from tblStudent stu  
 )t
 group by KeyName   
  
 SELECT    
	ISNULL(SUM(CASE WHEN InvoiceType = 'Entrance Fee' THEN ItemSubtotal ELSE 0 END),0) AS MonthlyEntranceRevenue,   
	ISNULL(SUM(CASE WHEN InvoiceType = 'Uniform Fee' THEN ItemSubtotal ELSE 0 END),0) AS MonthlyUniformRevenue,   
	ISNULL(SUM(CASE WHEN InvoiceType = 'Tuition Fee' THEN ItemSubtotal ELSE 0 END),0) AS MonthlyTuitionRevenue  
FROM INV_InvoiceDetail  
WHERE DATEPART(YEAR, CAST(UpdateDate AS DATE)) = DATEPART(YEAR, CAST(GETDATE() AS DATE))   
AND DATEPART(MONTH, CAST(UpdateDate AS DATE)) = DATEPART(MONTH, CAST(GETDATE() AS DATE))  

end 
GO

DROP PROCEDURE IF EXISTS  [dbo].[sp_SaveUser]
GO

CREATE PROCEDURE [dbo].[sp_SaveUser]  
 @LoginUserId int  
 ,@UserId int  
 ,@UserName nvarchar(200)  
 ,@UserArabicName nvarchar(500) = NULL  
 ,@UserEmail nvarchar(200)  
 ,@UserPhone nvarchar(20) = NULL  
 ,@UserPass nvarchar(500) = NULL  
 ,@RoleId int  
 ,@IsActive bit  
 ,@IsApprover bit  
AS  
BEGIN  
 SET NOCOUNT ON;  
 IF EXISTS(SELECT 1 FROM tblUser WHERE UserEmail = @UserEmail   
   AND UserId <> @UserId AND IsActive = 1)  
 BEGIN  
  SELECT -2 AS Result, 'User already exists!' AS Response  
  RETURN;  
 END  
 BEGIN TRY  
  BEGIN TRANSACTION TRANS1  
   IF(@UserId = 0)  
   BEGIN  
    INSERT INTO tblUser  
        (UserName  
        ,UserArabicName  
        ,UserEmail  
        ,UserPhone  
        ,UserPass  
        ,RoleId         
        ,IsApprover        
        ,IsActive  
        ,IsDeleted  
        ,UpdateDate  
        ,UpdateBy)  
    VALUES  
        (@UserName  
        ,isnull(@UserArabicName  ,'')
        ,@UserEmail  
        ,@UserPhone      
        ,@UserPass  
        ,@RoleId         
        ,@IsApprover        
        ,@IsActive   
        ,0  
        ,GETDATE()  
        ,@LoginUserId)  
   END  
   ELSE  

   BEGIN  
    UPDATE tblUser  
      SET UserName = @UserName  
       ,UserArabicName = isnull(@UserArabicName  ,'')  
       ,UserEmail = @UserEmail  
       ,UserPhone = @UserPhone  
       ,UserPass = @UserPass  
       ,RoleId = @RoleId        
       ,IsApprover = @IsApprover        
       ,IsActive = @IsActive       
       ,UpdateDate = GETDATE()  
       ,UpdateBy = @LoginUserId  
    WHERE UserId = @UserId  
   END      
  COMMIT TRAN TRANS1  
  SELECT 0 AS Result, 'Saved' AS Response  
 END TRY  
  
 BEGIN CATCH  
   ROLLBACK TRAN TRANS1  
   SELECT -1 AS Result, 'Error!' AS Response  
   EXEC usp_SaveErrorDetail  
   RETURN  
 END CATCH  
END
GO

DROP PROCEDURE IF EXISTS  [dbo].[sp_GetInvoiceDataYearly]
GO

CREATE PROCEDURE [dbo].[sp_GetInvoiceDataYearly]  
AS  
BEGIN  
  
	DECLARE @PeriodFrom DATE  
	DECLARE @PeriodTo DATE  
	SELECT TOP 1   
		@PeriodFrom=CAST(PeriodFrom AS DATE)  
		,@PeriodTo=CAST(PeriodTo AS DATE)  
	FROM tblSchoolAcademic   
	WHERE IsActive=1 and IsDeleted=0  
	AND ( CAST(GETDATE() AS DATE) BETWEEN CAST(PeriodFrom AS DATE)  and CAST(PeriodTo AS DATE)  )
  
    SELECT    
	DATEPART(YEAR, CAST(UpdateDate AS DATE)) AS AYear,    
	DATENAME(MONTH, CAST(UpdateDate AS DATE)) AS [MonthName],   
	SUM(CASE WHEN InvoiceType = 'Entrance Fee' THEN ItemSubtotal ELSE 0 END) AS MonthlyEntranceRevenue,   
	SUM(CASE WHEN InvoiceType = 'Uniform Fee' THEN ItemSubtotal ELSE 0 END) AS MonthlyUniformRevenue,   
	SUM(CASE WHEN InvoiceType = 'Tuition Fee' THEN ItemSubtotal ELSE 0 END) AS MonthlyTuitionRevenue  
	FROM INV_InvoiceDetail  
	where  CAST(UpdateDate AS DATE) BETWEEN CAST(@PeriodFrom AS DATE) AND CAST(@PeriodTo AS DATE)   
	GROUP BY    DATEPART(YEAR, CAST(UpdateDate AS DATE)),    DATENAME(MONTH, CAST(UpdateDate AS DATE))  
END  
GO

DROP PROCEDURE IF EXISTS  [dbo].[sp_GetCostCenterFees]
GO

CREATE PROCEDURE [dbo].[sp_GetCostCenterFees]  
AS  
BEGIN  
	--SELECT    
	--	tccm.CostCenterId,    
	--	tccm.CostCenterName,   
	--	SUM(tfgd.FeeAmount) as 'TotalAppliedFee',   
	--	SUM(tfs.PaidAmount) AS 'TotalPaidAmount'  
	--FROM tblGradeMaster AS tgm  
	--JOIN tblCostCenterMaster AS tccm ON tgm.CostCenterId = tccm.CostCenterId  
	--JOIN tblFeeGenerateDetail AS tfgd ON tgm.GradeId = tfgd.GradeId  
	--JOIN tblFeeStatement AS tfs ON tgm.GradeId = tfs.GradeId 
	--where tfs.IsActive=1 and tfs.IsDeleted=0
	--GROUP BY tccm.CostCenterId,    tccm.CostCenterName  
	--ORDER BY tccm.CostCenterId

	DECLARE @SchoolAcademicId bigint
	SELECT TOP 1   
	@SchoolAcademicId=SchoolAcademicId 
	FROM tblSchoolAcademic   
	WHERE IsActive=1 and IsDeleted=0  
	AND ( CAST(GETDATE() AS DATE) BETWEEN CAST(PeriodFrom AS DATE)  and CAST(PeriodTo AS DATE)  )
	
	select CostCenterId,CostCenterName, GradeId,GradeName, FeeAmount=sum(FeeAmount), PaidAmount=sum(PaidAmount) 
	into #AmountApplied
	from 
	(
		select grade.GradeId,grade.GradeName, cost.CostCenterId, cost.CostCenterName, fee.FeeAmount, fee.PaidAmount  
		from tblFeeStatement fee 
		join tblGradeMaster grade on fee.GradeId=grade.GradeId
		join tblCostCenterMaster cost on grade.CostCenterId=cost.CostCenterId
		where fee.IsActive=1 and fee.IsDeleted=0
		and grade.IsActive=1 and grade.IsDeleted=0
		and cost.IsActive=1 and grade.IsDeleted=0
		and FeeStatementType='Fee Applied'
		and fee.AcademicYearId=@SchoolAcademicId
	)t
	group by GradeId,GradeName, CostCenterId,CostCenterName

	select CostCenterId,CostCenterName, GradeId,GradeName, FeeAmount=sum(FeeAmount), PaidAmount=sum(PaidAmount) 
	into #AmountPaid
	from 
	(
		select grade.GradeId,grade.GradeName, cost.CostCenterId, cost.CostCenterName, fee.FeeAmount, fee.PaidAmount   
		from tblFeeStatement fee 
		join tblGradeMaster grade on fee.GradeId=grade.GradeId
		join tblCostCenterMaster cost on grade.CostCenterId=cost.CostCenterId
		where fee.IsActive=1 and fee.IsDeleted=0
		and grade.IsActive=1 and grade.IsDeleted=0
		and cost.IsActive=1 and grade.IsDeleted=0
		and FeeStatementType='Fee Paid'
		and fee.AcademicYearId=@SchoolAcademicId
	)t
	group by GradeId,GradeName, CostCenterId,CostCenterName

	select cons.CostCenterId,cons.CostCenterName
	, TotalAppliedFee=isnull(sum(isnull(aa.FeeAmount,0)),0)
	, TotalPaidAmount=isnull(sum(isnull(AP.PaidAmount,0)),0)
	from 
	tblCostCenterMaster cons
	left join #AmountApplied AA on cons.CostCenterId=AA.CostCenterId
	left join #AmountPaid AP on cons.CostCenterId=AP.CostCenterId
	group by cons.CostCenterId,cons.CostCenterName

	drop table #AmountApplied
	drop table #AmountPaid
END  
GO

DROP PROCEDURE IF EXISTS  [dbo].sp_GetGradeFees
GO

CREATE PROCEDURE  sp_GetGradeFees  
AS  
BEGIN  
  --  SELECT   
  --      tgm.GradeId,   
  --tgm.SequenceNo,  
  --      tgm.GradeName,     
  --      SUM(tfgd.FeeAmount) AS TotalAppliedFee,   
  --      SUM(tfs.PaidAmount) AS TotalPaidAmount  
  --  FROM   
  --      tblGradeMaster AS tgm  
  --  JOIN   
  --      tblFeeGenerateDetail AS tfgd   
  --  ON   
  --      tgm.GradeId = tfgd.GradeId  
  --  JOIN   
  --      tblFeeStatement AS tfs   
  --  ON   
  --      tgm.GradeId = tfs.GradeId  
  --  GROUP BY   
  --      tgm.GradeId,  
  --      tgm.GradeName,  
  --tgm.SequenceNo  
  -- ORDER BY   
  --   tgm.SequenceNo   

  DECLARE @SchoolAcademicId bigint
	SELECT TOP 1   
	@SchoolAcademicId=SchoolAcademicId 
	FROM tblSchoolAcademic   
	WHERE IsActive=1 and IsDeleted=0  
	AND ( CAST(GETDATE() AS DATE) BETWEEN CAST(PeriodFrom AS DATE)  and CAST(PeriodTo AS DATE)  )
	
	select CostCenterId,CostCenterName, GradeId,GradeName, FeeAmount=sum(FeeAmount), PaidAmount=sum(PaidAmount) 
	into #AmountApplied
	from 
	(
		select grade.GradeId,grade.GradeName, cost.CostCenterId, cost.CostCenterName, fee.FeeAmount, fee.PaidAmount  
		from tblFeeStatement fee 
		join tblGradeMaster grade on fee.GradeId=grade.GradeId
		join tblCostCenterMaster cost on grade.CostCenterId=cost.CostCenterId
		where fee.IsActive=1 and fee.IsDeleted=0
		and grade.IsActive=1 and grade.IsDeleted=0
		and cost.IsActive=1 and grade.IsDeleted=0
		and FeeStatementType='Fee Applied'
		and fee.AcademicYearId=@SchoolAcademicId
	)t
	group by GradeId,GradeName, CostCenterId,CostCenterName

	select CostCenterId,CostCenterName, GradeId,GradeName, FeeAmount=sum(FeeAmount), PaidAmount=sum(PaidAmount) 
	into #AmountPaid
	from 
	(
		select grade.GradeId,grade.GradeName, cost.CostCenterId, cost.CostCenterName, fee.FeeAmount, fee.PaidAmount   
		from tblFeeStatement fee 
		join tblGradeMaster grade on fee.GradeId=grade.GradeId
		join tblCostCenterMaster cost on grade.CostCenterId=cost.CostCenterId
		where fee.IsActive=1 and fee.IsDeleted=0
		and grade.IsActive=1 and grade.IsDeleted=0
		and cost.IsActive=1 and grade.IsDeleted=0
		and FeeStatementType='Fee Paid'
		and fee.AcademicYearId=@SchoolAcademicId
	)t
	group by GradeId,GradeName, CostCenterId,CostCenterName

	select cons.GradeName,cons.SequenceNo, TotalAppliedFee=isnull(sum(isnull(aa.FeeAmount,0)),0), TotalPaidAmount=isnull(sum(isnull(AP.PaidAmount,0)),0)
	from 
	tblGradeMaster cons
	left join #AmountApplied AA on cons.GradeId=AA.GradeId
	left join #AmountPaid AP on cons.GradeId=AP.GradeId
	group by cons.GradeName,cons.SequenceNo
	order by cons.SequenceNo	

	drop table #AmountApplied
	drop table #AmountPaid

END;  
GO

DROP PROCEDURE IF EXISTS  [dbo].[SP_GetFeeAmount]
GO

CREATE PROCEDURE [dbo].[SP_GetFeeAmount]
	@AcademicYearId bigint
	,@StudentId bigint,
	@InvoiceTypeName nvarchar(50)
as
begin
	DECLARE @IsStaffMember bit=0;
	DECLARE @GradeId int=0;
	DECLARE @TotalAcademicYearPaid decimal(18,2)=0
	DECLARE @InvoiceTypeId bigint=2008

	DECLARE @PeriodFrom DATE
	DECLARE @PeriodTo DATE

	declare @CurrentAcademicYearEndDate datetime
	select top 1 @CurrentAcademicYearEndDate =PeriodTo from tblSchoolAcademic where IsCurrentYear=1
	
	declare @IsAdvance int=0
	if exists(select * from tblSchoolAcademic where cast(PeriodFrom as date)> cast(@CurrentAcademicYearEndDate as date) and SchoolAcademicId=@AcademicYearId)
	begin
		set @IsAdvance =1;
	end

	SELECT TOP 1 
		@PeriodFrom=CAST(PeriodFrom AS DATE)
		,@PeriodTo=CAST(PeriodTo AS DATE)
	FROM tblSchoolAcademic 
	WHERE IsActive=1 and IsDeleted=0
	AND CAST(GETDATE() AS DATE) BETWEEN CAST(PeriodFrom AS DATE)and CAST(PeriodTo AS DATE)

	if(@studentId>0)
	begin
		select top 1
			@IsStaffMember= case when p.IsFatherStaff=1 OR p.IsMotherStaff=1 then 1 else 0 end
			,@GradeId=s.GradeId
		from
		[dbo].[tblParent] p
		join [dbo].[tblStudent] s on p.ParentId=s.ParentId
		where StudentId= @studentId
	end

	if(@InvoiceTypeName like '%Tuition%')
	begin 
		DECLARE @FinalFeeAmount decimal(18,2)=0
		
		select @FinalFeeAmount=SUM(FeeAmount)-SUM(PaidAmount) 
		from tblFeeStatement where StudentId=@StudentId 
		and IsActive=1 and IsDeleted=0
	
		select top 1 
			ftd.FeeTypeDetailId
			,ftd.FeeTypeId
			,ftd.AcademicYearId
			,ftd.GradeId
			,inv.FeeAmount as TermFeeAmount
			,ftd.IsActive
			,ftd.IsDeleted
			,ftd.UpdateDate
			,ftd.UpdateBy
			,inv.FeeAmount as StaffFeeAmount			
			,FinalFeeAmount=@FinalFeeAmount	
		into #FinalAmount
		from [dbo].[tblFeeTypeDetail] ftd
		join [dbo].[tblFeeTypeMaster] ftm on ftd.FeeTypeId=ftm.FeeTypeId
		join [dbo].[tblStudentFeeDetail] inv on ftm.FeeTypeId=inv.FeeTypeId 
		and inv.StudentId=@StudentId
		and ftd.AcademicYearId=inv.AcademicYearId
		where 
		--ftd.AcademicYearId=@academicYearId
		--and 
		ftm.FeeTypeName like '%'+@InvoiceTypeName+'%'

		select  
			FeeTypeDetailId	
			,FeeTypeId	
			,AcademicYearId	
			,GradeId	
			,TermFeeAmount	
			,IsActive	
			,IsDeleted	
			,UpdateDate	
			,UpdateBy	
			,StaffFeeAmount
			,FinalFeeAmount			
			,IsAdvance=cast(@IsAdvance as bit)
		from #FinalAmount

		 IF OBJECT_ID('tempdb..#FinalAmount') IS NOT NULL        
			DROP TABLE #FinalAmount

	end
	else 
	begin
		select top 1 
			ftd.*,IsStaffMember=@IsStaffMember
			,FinalFeeAmount=case when @IsStaffMember=1 then StaffFeeAmount else TermFeeAmount end
			,DiscountPercent=0
			,IsAdvance=cast(0  as bit)
		from [dbo].[tblFeeTypeDetail] ftd
		join [dbo].[tblFeeTypeMaster] ftm on ftd.FeeTypeId=ftm.FeeTypeId
		where AcademicYearId=@academicYearId
		and ftm.FeeTypeName like '%'+@InvoiceTypeName+'%'
	end
end 
GO

  
DROP PROCEDURE IF EXISTS  [dbo].[sp_getAdminDashboardData]
GO

CREATE PROCEDURE [dbo].[sp_getAdminDashboardData]    
as    
begin    
 select  count(1) as TotalStudent    
 from tblStudent    
    
 select  count(1) as TotalParent from tblParent    
    
 select     
 case when GenderId=1 then 'Male' else 'Female' end as Gender, GradeName as KeyName, count(1) as KeyValue    
 from tblStudent stu    
 inner join tblGradeMaster grade    
 on stu.GradeId=grade.GradeId    
    
 group by GradeName,GenderId 
	
	update t
	set t.AdmissionYear=cast( LEFT(AdmissionYear, Len(AdmissionYear)-1)   + Replace(RIGHT(AdmissionYear, 1), '.', '') as datetime)
	from tblStudent t
	where right(AdmissionYear ,1)='.'
  
  select KeyName, count(1) as KeyValue from   
  (  
 select     
  datepart(year, AdmissionYear) as KeyName  
 from tblStudent stu    
 )t  
 group by KeyName     
    
 SELECT      
 ISNULL(SUM(CASE WHEN InvoiceType = 'Entrance Fee' THEN ItemSubtotal ELSE 0 END),0) AS MonthlyEntranceRevenue,     
 ISNULL(SUM(CASE WHEN InvoiceType = 'Uniform Fee' THEN ItemSubtotal ELSE 0 END),0) AS MonthlyUniformRevenue,     
 ISNULL(SUM(CASE WHEN InvoiceType = 'Tuition Fee' THEN ItemSubtotal ELSE 0 END),0) AS MonthlyTuitionRevenue    
FROM INV_InvoiceDetail    
WHERE DATEPART(YEAR, CAST(UpdateDate AS DATE)) = DATEPART(YEAR, CAST(GETDATE() AS DATE))     
AND DATEPART(MONTH, CAST(UpdateDate AS DATE)) = DATEPART(MONTH, CAST(GETDATE() AS DATE))    
  
end   
GO