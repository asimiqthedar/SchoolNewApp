﻿DROP PROCEDURE IF EXISTS [sp_ProcessGP_UniformInvoice]
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
                    
 insert into INT_SalesInvoiceSourceTable(SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,UnitPrice,IntegrationStatus,Error,
 QtyOnHand,QtyReturned,QtyInUse,QtyInService,QtyDamaged)
 select                     
  SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,(ItemSubtotal/Quantity),IntegrationStatus,Error
  ,QtyOnHand,QtyReturned,QtyInUse,QtyInService,QtyDamaged
 from #INT_ALS_SalesInvoiceSourceTable                    
                    
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
					,SOPType=@SOPType  
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
  ,SOPType=@SOPType  
  ,DistType=1            
  ,AccountNumber=@VATCreditAccount           
  ,DebitAmount=case when @InvoiceType='Invoice' then 0 else @TotalTaxAmount end
  ,CreditAmount=case when @InvoiceType='Invoice' then @TotalTaxAmount else 0 end
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
  ,SOPType=@SOPType  
  ,DistType=3            
  ,AccountNumber=pm.CreditAccount            
  ,DebitAmount=case when @InvoiceType='Invoice' then PaymentAmount else 0 end
  ,CreditAmount=case when @InvoiceType='Invoice' then 0 else PaymentAmount end
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
     
        
 end TRY                  
 begin catch          
  SELECT -1 AS Result, 'Error!' AS Response              
  EXEC usp_SaveErrorDetail              
  select* from tblErrors                  
  end catch          
end     
GO