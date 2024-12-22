DROP PROCEDURE IF EXISTS  [dbo].[sp_ProcessGP_TuitionInvoice]
GO

CREATE proc [dbo].[sp_ProcessGP_TuitionInvoice]    
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
	declare @CreditAccountPayment nvarchar(100)
	declare @DebitAmount decimal(18,4)=0

	select top 1 @PaymentMethod = PaymentMethod, @DebitAccountPayment=DebitAccount,
	@CreditAccountPayment=CreditAccount,
	@DebitAmount=DebitAmount  from #INV_InvoicePayment where RN=1

	set @PaymentMethod= SUBSTRING(@PaymentMethod,1,4)

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

	declare @CurrentAcademicYearEndDate datetime
	select top 1 @CurrentAcademicYearEndDate =PeriodTo from tblSchoolAcademic where IsCurrentYear=1
	
	
	--Row 1- Debit record
	select 
		SeqNum=1
		,Reference='T.FEE INV-'+@invoicenoString+' '+@PaymentMethod+' '+ sc.AcademicYear
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=invS.InvoiceDate
		,ReversingDate=null
		,AccountNumber=case when invS.InvoiceType='Invoice' then @DebitAccountPayment else @CreditAccountPayment end
		,DistributionRef='RV PID#'+par.ParentCode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)
		,CreditAmount=0
		,DebitAmount=invd.ItemSubtotal
		,IntegrationStatus=0
		,Error=null
	into #INT_GLSourceTable
	from
	INV_InvoiceDetail invD
	join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo
	join tblSchoolAcademic sc on invD.AcademicYear=sc.SchoolAcademicId
	join tblParent par on invD.ParentId=par.ParentId
	where cast(sc.PeriodTo as date)<= cast(@CurrentAcademicYearEndDate as date)
	and sc.IsActive=1 and sc.IsDeleted=0 and invD.invoiceno=@invoiceno 

	--Row-2: credit record- VAT record if VAT available

	insert into #INT_GLSourceTable
	select 
		SeqNum=2
		,Reference='T.FEE INV-'+@invoicenoString+' '+@PaymentMethod+' '+ sc.AcademicYear
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=invS.InvoiceDate
		,ReversingDate=null
		,AccountNumber=case when invS.InvoiceType='Invoice' then @VATCreditAccount else @VATCreditAccount end
		,DistributionRef='RV PID#'+par.ParentCode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)
		,CreditAmount=invd.TaxAmount
		,DebitAmount=0
		,IntegrationStatus=0
		,Error=null
	from
	INV_InvoiceDetail invD
	join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo
	join tblSchoolAcademic sc on invD.AcademicYear=sc.SchoolAcademicId
	join tblParent par on invD.ParentId=par.ParentId
	where cast(sc.PeriodTo as date)<= cast(@CurrentAcademicYearEndDate as date)
	and invD.TaxAmount>0
	and sc.IsActive=1 and sc.IsDeleted=0 and invD.invoiceno=@invoiceno

	--Row-3: credit record- Tuition Fee
	insert into #INT_GLSourceTable
	select 
		SeqNum=3
		,Reference='T.FEE INV-'+@invoicenoString+' '+@PaymentMethod+' '+ sc.AcademicYear
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=invS.InvoiceDate
		,ReversingDate=null
		,AccountNumber=case when invS.InvoiceType='Invoice' then parA.ReceivableAccount else parA.AdvanceAccount end
		,DistributionRef='RV PID#'+par.ParentCode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)
		,CreditAmount=invd.ItemSubtotal-invd.TaxAmount
		,DebitAmount=0
		,IntegrationStatus=0
		,Error=null
	from
	INV_InvoiceDetail invD
	join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo
	join tblSchoolAcademic sc on invD.AcademicYear=sc.SchoolAcademicId
	join tblParent par on invD.ParentId=par.ParentId
	join tblParentAccount parA on par.ParentId=parA.ParentId
	where cast(sc.PeriodTo as date)<= cast(@CurrentAcademicYearEndDate as date)
	and sc.IsActive=1 and sc.IsDeleted=0 and invD.invoiceno=@invoiceno 
	
	---Case 2 Start:- When Advance available:

	--Row 1- Debit record
	insert into #INT_GLSourceTable
	select 
		SeqNum=4
		,Reference='ADV.FEE INV-'+@invoicenoString+' '+@PaymentMethod+' '+ sc.AcademicYear
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=invS.InvoiceDate
		,ReversingDate=null
		,AccountNumber=case when invS.InvoiceType='Invoice' then @DebitAccountPayment else @CreditAccountPayment end
		,DistributionRef='RV PID#'+par.ParentCode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)
		,CreditAmount=0
		,DebitAmount=invd.ItemSubtotal
		,IntegrationStatus=0
		,Error=null
	from
	INV_InvoiceDetail invD
	join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo
	join tblSchoolAcademic sc on invD.AcademicYear=sc.SchoolAcademicId
	join tblParent par on invD.ParentId=par.ParentId
	where cast(sc.PeriodTo as date)> cast(@CurrentAcademicYearEndDate as date)
	and sc.IsActive=1 and sc.IsDeleted=0 and invD.invoiceno=@invoiceno 

	--Row-2: credit record- VAT record if VAT available
	insert into #INT_GLSourceTable
	select 
		SeqNum=5
		,Reference='ADV.FEE INV-'+@invoicenoString+' '+@PaymentMethod+' '+ sc.AcademicYear
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=invS.InvoiceDate
		,ReversingDate=null
		,AccountNumber=case when invS.InvoiceType='Invoice' then @VATCreditAccount else @VATDebitAccount end
		,DistributionRef='RV PID#'+par.ParentCode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)
		,CreditAmount=invd.TaxAmount
		,DebitAmount=0
		,IntegrationStatus=0
		,Error=null
	from
	INV_InvoiceDetail invD
	join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo
	join tblSchoolAcademic sc on invD.AcademicYear=sc.SchoolAcademicId
	join tblParent par on invD.ParentId=par.ParentId
	where cast(sc.PeriodTo as date)> cast(@CurrentAcademicYearEndDate as date)
	and invD.TaxAmount>0
	and sc.IsActive=1 and sc.IsDeleted=0 and invD.invoiceno=@invoiceno

	--Row-3: credit record- Tuition Fee
	insert into #INT_GLSourceTable
	select 
		SeqNum=6
		,Reference='T.FEE INV-'+@invoicenoString+' '+@PaymentMethod+' '+ sc.AcademicYear
		,JournalNumber=0
		,TransactionType=0
		,TransactionDate=invS.InvoiceDate
		,ReversingDate=null
		,AccountNumber= case when invS.InvoiceType='Invoice' then parA.AdvanceAccount else parA.ReceivableAccount end
		,DistributionRef='RV PID#'+par.ParentCode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)
		,CreditAmount=invd.ItemSubtotal-invd.TaxAmount
		,DebitAmount=0
		,IntegrationStatus=0
		,Error=null
	from
	INV_InvoiceDetail invD
	join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo
	join tblSchoolAcademic sc on invD.AcademicYear=sc.SchoolAcademicId
	join tblParent par on invD.ParentId=par.ParentId
	join tblParentAccount parA on par.ParentId=parA.ParentId
	where cast(sc.PeriodTo as date)> cast(@CurrentAcademicYearEndDate as date)
	and sc.IsActive=1 and sc.IsDeleted=0 and invD.invoiceno=@invoiceno 

	---Case 2 End:- When Advance available:
	
	insert into INT_GLSourceTable
	(
		SeqNum,Reference,JournalNumber,TransactionType,TransactionDate,ReversingDate,AccountNumber
		,DistributionRef,CreditAmount,DebitAmount,IntegrationStatus,Error
	)
	select
		SeqNum= ROW_NUMBER() over(order by SeqNum),
		Reference,JournalNumber,TransactionType,
		TransactionDate=convert(varchar,TransactionDate, 120),
		ReversingDate=case when ReversingDate is null then null else  convert(varchar,ReversingDate, 120) end,
		AccountNumber,DistributionRef,CreditAmount,DebitAmount,IntegrationStatus,Error
	from #INT_GLSourceTable
   
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
	 --select * from INT_GLSourceTable

 end TRY            
 begin catch    
	  SELECT -1 AS Result, 'Error!' AS Response        
	  EXEC usp_SaveErrorDetail        
	  select* from tblErrors            
  end catch    
end  
GO

DROP PROCEDURE IF EXISTS  [dbo].[sp_ProcessGP_EntranceInvoice]
GO

CREATE proc [dbo].[sp_ProcessGP_EntranceInvoice]      
(                
  @invoiceno bigint=0   ,            
  @DestinationDB nvarchar(50) = ''            
)                
AS                
BEGIN           
  BEGIN TRY  
   
 declare @invoicenoString nvarchar(100)= cast(@invoiceno as nvarchar(100))  
 select * from INT_GLSourceTable where Reference like  '%'+@invoicenoString +'%'    
  
  delete from INT_GLSourceTable where Reference like  '%'+@invoicenoString +'%'    
        
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
  ,Reference='E.EXAM INV-'+@invoicenoString+' '+@PaymentMethod+' '+ sc.AcademicYear  
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
 --join tblParent par on invD.ParentId=par.ParentId  
 where  cast(getdate() as date) between cast(sc.PeriodFrom as date) and cast(sc.PeriodTo as date)  
   
 --Row-2: credit record- VAT record if VAT available  
  
 insert into #INT_GLSourceTable  
 select   
  SeqNum=2  
  ,Reference='E.EXAM INV-'+@invoicenoString+' '+@PaymentMethod+' '+ sc.AcademicYear  
  ,JournalNumber=0  
  ,TransactionType=0  
  ,TransactionDate=invS.InvoiceDate  
  ,ReversingDate=null  
  ,AccountNumber=@VATCreditAccount  
  ,DistributionRef='RV PID#'+par.ParentCode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)  
  ,CreditAmount=invd.TaxAmount  
  ,DebitAmount=0  
  ,IntegrationStatus=0    ,Error=null  
 from  
 INV_InvoiceDetail invD  
 join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo  
 join tblSchoolAcademic sc on invD.AcademicYear=sc.SchoolAcademicId  
 join tblParent par on invD.ParentId=par.ParentId  
 where  cast(getdate() as date) between cast(sc.PeriodFrom as date) and cast(sc.PeriodTo as date)  
 and invD.TaxAmount>0  
  
 --Row-3: credit record- Tuition Fee  
 insert into #INT_GLSourceTable  
 select   
  SeqNum=3  
  ,Reference='E.EXAM INV-'+@invoicenoString+' '+@PaymentMethod+' '+ sc.AcademicYear  
  ,JournalNumber=0  
  ,TransactionType=0  
  ,TransactionDate=invS.InvoiceDate  
  ,ReversingDate=null  
  ,AccountNumber=parA.ReceivableAccount  
  ,DistributionRef='RV PID#'+par.ParentCode+' INV'+@invoicenoString+' '+SUBSTRING(@PaymentMethod, 1, 4)  
  ,CreditAmount=invd.ItemSubtotal-invd.TaxAmount  
  ,DebitAmount=0  
  ,IntegrationStatus=0  
  ,Error=null  
 from  
 INV_InvoiceDetail invD  
 join INV_InvoiceSummary invS on invd.InvoiceNo=invS.InvoiceNo  
 join tblSchoolAcademic sc on invD.AcademicYear=sc.SchoolAcademicId  
 join tblParent par on invD.ParentId=par.ParentId  
 join tblParentAccount parA on par.ParentId=parA.ParentId  
 where  cast(getdate() as date) between cast(sc.PeriodFrom as date) and cast(sc.PeriodTo as date)  
  
 insert into INT_GLSourceTable  
 (  
  SeqNum,Reference,JournalNumber,TransactionType,TransactionDate,ReversingDate,AccountNumber  
  ,DistributionRef,CreditAmount,DebitAmount,IntegrationStatus,Error  
 )  
 select  
  SeqNum= ROW_NUMBER() over(order by SeqNum),  
  Reference,JournalNumber,TransactionType,TransactionDate,ReversingDate,AccountNumber  
  ,DistributionRef,CreditAmount,DebitAmount,IntegrationStatus,Error  
 from #INT_GLSourceTable  
     
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
      
   SELECT    
    CallFrom = 0            
  , SourceDB = @SourceDBName            
  , DestDB = @DestinationDB            
  , FromDate = @FromDateRange            
  , ToDate = @ToDateRange    
    
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

DROP PROCEDURE IF EXISTS  [dbo].[sp_ProcessGP_UniformInvoice]
GO

CREATE proc [dbo].[sp_ProcessGP_UniformInvoice]      
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
  SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,ItemSubtotal,IntegrationStatus,Error                
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

DROP PROCEDURE IF EXISTS  [dbo].[sp_ProcessGP]
GO

CREATE PROCEDURE [dbo].[sp_ProcessGP]  
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

