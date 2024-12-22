DROP PROCEDURE IF EXISTS [sp_ProcessGP]
GO

CREATE PROCEDURE [sp_ProcessGP]  
  @invoiceno bigint=0   ,        
  @DestinationDB nvarchar(50) = ''             
AS        
BEGIN        
	declare @Result int=-1
	     
	----Process GP integration  
	if exists(select 1 from INV_InvoiceDetail where invoiceno=@invoiceno and InvoiceType like '%Uniform%')
	begin
		set @Result =0
		exec [sp_ProcessGP_UniformInvoice] @invoiceno,@DestinationDB  
	end

	if exists(select 1 from INV_InvoiceDetail where invoiceno=@invoiceno and InvoiceType like '%entrance%')
	begin
		set @Result =0
		exec [sp_ProcessGP_EntranceInvoice] @invoiceno,@DestinationDB  
	end
 
	if exists(select 1 from INV_InvoiceDetail where invoiceno=@invoiceno and InvoiceType like '%Tuition%')
	begin
		set @Result =0
		exec [sp_ProcessGP_TuitionInvoice] @invoiceno,@DestinationDB  
	end 

	if(@Result =-1)
		select 0 result
end
GO

DROP PROCEDURE IF EXISTS [sp_ProcessGP_EntranceInvoice]
GO

CREATE PROCEDURE [dbo].[sp_ProcessGP_EntranceInvoice]        
(                  
  @invoiceno bigint=0   ,              
  @DestinationDB nvarchar(50) = ''              
)                  
AS                  
BEGIN             
  BEGIN TRY    
     
 declare @invoicenoString nvarchar(100)= cast(@invoiceno as nvarchar(100))    

  delete from INT_GLSourceTable where Reference like  'E.EXAM #'+@invoicenoString +'%'      
          
  --Update database        
  DECLARE @SourceDBName NVARCHAR(50)= 'ALS_LIVE'           
                  
  -----------sales detail processing                  
  declare @SOPType int=3                  
  declare @DocID nvarchar(50)='STDINV'                  
  declare @IntegrationStatus int=0                  
                  
  Declare @InvoiceTypeCount int=0                  
  declare @totalPayableAmount decimal(18,4)=0      
    
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
  ,DistributionRef='UNIFORM SALES FOR INV NO '+cast(invoiceno as nvarchar(50))          
  ,IntegrationStatus=0                  
  ,Error=null      
  ,PaymentMethod=pm.PaymentMethodName    
  ,PaymentReferenceNumber    
 into #INV_InvoicePayment    
 from INV_InvoicePayment tp          
 join tblPaymentMethod pm          
 on tp.PaymentMethod=pm.PaymentMethodName     
 where invoiceno=@invoiceno      
     
 declare @PaymentMethod nvarchar(100)    
 declare @DebitAccountPayment nvarchar(100)    
 declare @DebitAmount decimal(18,4)=0    
    
 select top 1 @PaymentMethod = PaymentMethod, @DebitAccountPayment=DebitAccount,@DebitAmount=DebitAmount      
 from #INV_InvoicePayment where RN=1    
    
 declare @EntranceDebitAccount nvarchar(50)=''          
 declare @EntranceCreditAccount nvarchar(50)=''          
          
 declare @VATDebitAccount nvarchar(50)=''          
 declare @VATCreditAccount nvarchar(50)=''          
          
 select top 1          
  @VATDebitAccount=vat.DebitAccount,          
  @VATCreditAccount=vat.CreditAccount           
 from tblVatMaster vat          
 inner join tblFeeTypeMaster fee           
 on vat.FeeTypeId=fee.FeeTypeId          
 where vat.IsActive=1 and vat.IsDeleted=0          
 and FeeTypeName like '%Entrance%'          
          
 select top 1           
  @EntranceDebitAccount=DebitAccount,          
  @EntranceCreditAccount=CreditAccount           
 from tblFeeTypeMaster          
 where FeeTypeName like '%Entrance%'      
     
 --Row 1- Debit record    
 select     
  SeqNum=1    
  ,Reference='E.EXAM #'+@invoicenoString+' '+@PaymentMethod+' '+ sc.AcademicYear    
  ,JournalNumber=0    
  ,TransactionType=0    
  ,TransactionDate=invS.InvoiceDate    
  ,ReversingDate=null    
  ,AccountNumber=@DebitAccountPayment    
  ,DistributionRef='RV FID#'+invD.IqamaNumber+' INV'+@invoicenoString    
 
 ,CreditAmount=0    
  ,DebitAmount=invd.ItemSubtotal    
  ,IntegrationStatus=0    
  ,Error=null    
 into #INT_GLSourceTable    
 from    
 INV_InvoiceDetail invD    
 join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo    
 join tblSchoolAcademic sc on invD.AcademicYear=sc.SchoolAcademicId    
 where  invS.invoiceno=@invoiceno  
     
 --Row-2: credit record- VAT record if VAT available    
    
 insert into #INT_GLSourceTable    
 select     
  SeqNum=2    
  ,Reference='E.EXAM #'+@invoicenoString+' '+@PaymentMethod+' '+ sc.AcademicYear    
  ,JournalNumber=0    
  ,TransactionType=0    
  ,TransactionDate=invS.InvoiceDate    
  ,ReversingDate=null    
  ,AccountNumber=@VATCreditAccount
  ,DistributionRef='RV FID#'+invD.IqamaNumber+' INV'+@invoicenoString 
  ,CreditAmount=invd.TaxAmount    
  ,DebitAmount=0    
  ,IntegrationStatus=0    ,Error=null    
 from    
 INV_InvoiceDetail invD    
 join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo    
 join tblSchoolAcademic sc on invD.AcademicYear=sc.SchoolAcademicId  
 where  invD.TaxAmount>0   
  and  invS.invoiceno=@invoiceno  
    
 --Row-3: credit record- Tuition Fee    
 insert into #INT_GLSourceTable    
 select     
  SeqNum=3    
  ,Reference='E.EXAM #'+@invoicenoString+' '+@PaymentMethod+' '+ sc.AcademicYear    
  ,JournalNumber=0    
  ,TransactionType=0    
  ,TransactionDate=invS.InvoiceDate    
  ,ReversingDate=null    
  ,AccountNumber=@EntranceCreditAccount  
  ,DistributionRef='RV FID#'+invD.IqamaNumber+' INV'+@invoicenoString  
 
 ,CreditAmount=invd.ItemSubtotal-invd.TaxAmount    
  ,DebitAmount=0    
  ,IntegrationStatus=0    
  ,Error=null    
 from    
 INV_InvoiceDetail invD    
 join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo    
 join tblSchoolAcademic sc on invD.AcademicYear=sc.SchoolAcademicId    

 where  invS.invoiceno=@invoiceno  

 insert into INT_GLSourceTable    
 (    
  SeqNum,Reference,JournalNumber,TransactionType,TransactionDate,ReversingDate,AccountNumber    
  ,DistributionRef,CreditAmount,DebitAmount,IntegrationStatus,Error    
 )    
 select 
  SeqNum,   
  Reference,JournalNumber,TransactionType,TransactionDate,ReversingDate,AccountNumber    
  ,DistributionRef,CreditAmount=sum(CreditAmount),DebitAmount=sum(DebitAmount),IntegrationStatus,Error
 from 
 (
	 select    
	  SeqNum,   
	  Reference,JournalNumber,TransactionType,TransactionDate,ReversingDate,AccountNumber    
	  ,DistributionRef,CreditAmount,DebitAmount,IntegrationStatus,Error=ISNULL(Error,'')    
	 from #INT_GLSourceTable   
 )t
 group by 
  SeqNum,   
  Reference,JournalNumber,TransactionType,TransactionDate,ReversingDate,AccountNumber    
  ,DistributionRef,IntegrationStatus,Error  
  

       
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
    
 end TRY                
 begin catch        
   SELECT -1 AS Result, 'Error!' AS Response            
   EXEC usp_SaveErrorDetail            
   select* from tblErrors                
  end catch        
end   
GO

DROP PROCEDURE IF EXISTS [sp_ProcessGP_TuitionInvoice]
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

	 select top 1 @PaymentMethod=PaymentMethod from INV_InvoicePayment where invoiceno=@invoiceno order by PaymentAmount desc

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
		,Reference='T.FEE #'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName
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
		,Reference='T.FEE #'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName
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
		,Reference='T.FEE #'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=@InvoiceDate
		,ReversingDate=null
		,AccountNumber=case when @InvoiceType='Invoice' then @VATCreditAccount else @VATCreditAccount end
		,DistributionRef='RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)
		,CreditAmount=cast( invd.TaxAmount as decimal(18,0))
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
		,Reference='T.FEE #'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=@InvoiceDate
		,ReversingDate=null
		,AccountNumber=case when invS.InvoiceType='Invoice' then parA.ReceivableAccount else parA.AdvanceAccount end
		,DistributionRef='RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)
		,CreditAmount=invd.ItemSubtotal-cast( invd.TaxAmount as decimal(18,0))
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
		,Reference='ADV #'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName
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
		,Reference='ADV #'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=@InvoiceDate
		,ReversingDate=null
		,AccountNumber=case when invS.InvoiceType='Invoice' then @VATCreditAccount else @VATDebitAccount end
		,DistributionRef='RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)
		,CreditAmount=cast( invd.TaxAmount as decimal(18,0))
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
		,Reference='ADV #'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)+' '+ @AcademicYearName
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=@InvoiceDate
		,ReversingDate=null
		,AccountNumber= case when invS.InvoiceType='Invoice' then parA.AdvanceAccount else parA.ReceivableAccount end
		,DistributionRef='RV PID#'+@parentcode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)
		,CreditAmount=invd.ItemSubtotal-cast( invd.TaxAmount as decimal(18,0))
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

DROP PROCEDURE IF EXISTS [sp_ProcessGP_UniformInvoice]
GO

CREATE PROCEDURE  [dbo].[sp_ProcessGP_UniformInvoice]            
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
 declare @SOPReturnType int=4    
 declare @DocID nvarchar(50)='STDINV'                      
 declare @IntegrationStatus int=0                      
                      
 Declare @InvoiceTypeCount int=0                      
 declare @totalPayableAmount decimal(18,4)=0    
   
 declare @InvoiceType nvarchar(50)    
  declare @InvoiceDate  datetime    
     
   select top 1 @InvoiceType=InvoiceType,@InvoiceDate=InvoiceDate from INV_InvoiceSummary where invoiceno=@invoiceno    
  
 if exists( select 1 from INV_InvoiceSummary where InvoiceNo=@invoiceno and InvoiceType='Return')    
 begin    
  set @SOPType=4;    
 end    
          
 select                       
 SeqNum=ROW_NUMBER() over(partition by invSum.invoiceno,invDet.ItemCode order by InvoiceDetailId)                      
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
 ,QtyOnHand=case when @InvoiceType='Invoice' then 0 ELSE invDet.Quantity END  
 ,QtyReturned=0  
 ,QtyInUse=0  
 ,QtyInService=0  
 ,QtyDamaged=0  
 into #INT_ALS_SalesInvoiceSourceTable                      
 from INV_InvoiceDetail invDet                      
 join INV_InvoiceSummary invSum                      
 on invDet.InvoiceNo=invSum.InvoiceNo                      
 where invDet.InvoiceType like '%Uniform%'                      
 and invSum.invoiceno=@invoiceno                      
                      
	insert into INT_SalesInvoiceSourceTable(SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,UnitPrice,
	IntegrationStatus,Error,   QtyOnHand,QtyReturned,QtyInUse,QtyInService,QtyDamaged)
	select 
		ROW_NUMBER() over(partition by SOPNumber,SOPType,ItemNumber order by SOPNumber)  ,
		SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity=sum(Quantity),UnitPrice=(UnitPrice),IntegrationStatus,Error  
		,QtyOnHand=sum(QtyOnHand),QtyReturned=sum(QtyReturned),QtyInUse=sum(QtyInUse),QtyInService=sum(QtyInService),QtyDamaged=sum(QtyDamaged)  
	from 
	(
		select                       
			
			SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,(ItemSubtotal/Quantity) as UnitPrice,IntegrationStatus,Error  
			,QtyOnHand,QtyReturned,QtyInUse,QtyInService,QtyDamaged  
		from #INT_ALS_SalesInvoiceSourceTable                      
	)t 
	group by SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,IntegrationStatus,Error,UnitPrice
 -----------payment processing                      
               
 select @InvoiceTypeCount=count(InvoiceType) from #INT_ALS_SalesInvoiceSourceTable                       
 select @totalPayableAmount=sum(isnull(ItemSubtotal,0)) from #INT_ALS_SalesInvoiceSourceTable                      
                      
 --4 for Cash payment, 5 for Check payment & bank transfer, and 6 for Credit card payment.                      
 --Bank Transfer =5                      
 --Check=5                      
 --Cash=4                      
 --Visa=6                      
       
 IF(@InvoiceType='Invoice')  
 BEGIN  
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
     ,SOPType=@SOPType    
     ,PaymentType=4
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
     ,SOPType=@SOPType    
     ,PaymentType=4                      
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
 END  
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
  ,SOPType=@SOPType    
  ,DistType=1              
  ,AccountNumber=@UniformCreditAccount              
  ,DebitAmount= case when @InvoiceType='Invoice' then 0 else @TotalTaxableAmount end   
  ,CreditAmount=case when @InvoiceType='Invoice' then @TotalTaxableAmount else 0 end  
  ,DistributionRef=case when @InvoiceType='Invoice' then 'UNIFORM SALES FOR INV NO '+cast(@invoiceno as nvarchar(50))  
  else 'UNIFORM RETURN FOR CR NO '+cast(@invoiceno as nvarchar(50)) end
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
  ,SOPType=@SOPType    
  ,DistType=1              
  ,AccountNumber=@VATCreditAccount             
  ,DebitAmount=case when @InvoiceType='Invoice' then 0 else @TotalTaxAmount end  
  ,CreditAmount=case when @InvoiceType='Invoice' then @TotalTaxAmount else 0 end  
  ,DistributionRef=case when @InvoiceType='Invoice' then'UNIFORM SALES FOR INV NO '+cast(@invoiceno as nvarchar(50))  
  else 'UNIFORM RETURN FOR CR NO '+cast(@invoiceno as nvarchar(50)) end
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
  ,SOPType=@SOPType    
  ,DistType=case when @InvoiceType ='Invoice' then 3 else 2 end
  ,AccountNumber=pm.CreditAccount              
  ,DebitAmount=case when @InvoiceType='Invoice' then PaymentAmount else 0 end  
  ,CreditAmount=case when @InvoiceType='Invoice' then 0 else PaymentAmount end  
  ,DistributionRef=case when @InvoiceType='Invoice' then 'UNIFORM SALES FOR INV NO '+cast(invoiceno as nvarchar(50))              
  else 'UNIFORM RETURN FOR CR NO '+cast(@invoiceno as nvarchar(50)) end
  ,IntegrationStatus=0                      
  ,Error=null              
 from INV_InvoicePayment tp              
 join tblPaymentMethod pm              
 on tp.PaymentMethod=pm.PaymentMethodName         
 where invoiceno=@invoiceno              
      
	  
IF(@InvoiceType !='Invoice')
begin
	--Add 2 new line for cost and inventory
	--14/15
	--Get max seq number for SOPNumber

	declare @MaxSeqNumber int=0

	select @MaxSeqNumber= max(SeqNum) from INT_SalesDistributionSourceTable where SOPNumber=@SOPType 

	--Add 14 Line
	declare @TotalItemCurretCost decimal(18,2)=0
	
	select             
	  @TotalItemCurretCost =sum(b.CURRCOST* a.Quantity)
	 from INV_InvoiceDetail a 
	 join ALS.dbo.IV00101 b
	 on a.ItemCode=b.ITEMNMBR
	 where invoiceno=@invoiceno 

	declare @AccountNumber14 nvarchar(50)='00-3500-0040'
	declare @AccountNumber15 nvarchar(50)='00-1300-0040'

	set @MaxSeqNumber=@MaxSeqNumber+1;
	
	insert into INT_SalesDistributionSourceTable              
	 (            
	  SeqNum,SOPNumber,SOPType,DistType,AccountNumber,DebitAmount,CreditAmount,DistributionRef,IntegrationStatus,Error            
	 )              
	 select              
	  SeqNum=@MaxSeqNumber          
	  ,SOPNumber=@invoiceno              
	  ,SOPType=@SOPType    
	  ,DistType=14              
	  ,AccountNumber=@AccountNumber14              
	  ,DebitAmount=0
	  ,CreditAmount=@TotalItemCurretCost
	  ,DistributionRef=case when @InvoiceType='Invoice' then 'UNIFORM SALES FOR INV NO '+cast(@invoiceno as nvarchar(50))              
	  else 'UNIFORM RETURN FOR CR NO '+cast(@invoiceno as nvarchar(50)) end
	  ,IntegrationStatus=0                      
	  ,Error=null

	--Add 15 line 

	set @MaxSeqNumber=@MaxSeqNumber+1;
	
	insert into INT_SalesDistributionSourceTable              
	 (            
	  SeqNum,SOPNumber,SOPType,DistType,AccountNumber,DebitAmount,CreditAmount,DistributionRef,IntegrationStatus,Error            
	 )              
	 select              
	  SeqNum=@MaxSeqNumber          
	  ,SOPNumber=@invoiceno              
	  ,SOPType=@SOPType    
	  ,DistType=15
	  ,AccountNumber=@AccountNumber15              
	  ,DebitAmount=@TotalItemCurretCost
	  ,CreditAmount=0
	  ,DistributionRef=case when @InvoiceType='Invoice' then 'UNIFORM SALES FOR INV NO '+cast(@invoiceno as nvarchar(50)) 
	  else 'UNIFORM RETURN FOR CR NO '+cast(@invoiceno as nvarchar(50)) end
	  ,IntegrationStatus=0                      
	  ,Error=null              
	

end

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
       
          
 end TRY                    
 begin catch            
  SELECT -1 AS Result, 'Error!' AS Response                
  EXEC usp_SaveErrorDetail                
  select* from tblErrors                    
  end catch            
end       
GO

