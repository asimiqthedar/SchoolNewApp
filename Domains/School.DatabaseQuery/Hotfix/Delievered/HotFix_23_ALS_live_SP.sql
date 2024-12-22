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
 declare @SOPReturnType int=4
 declare @DocID nvarchar(50)='STDINV'                  
 declare @IntegrationStatus int=0                  
                  
 Declare @InvoiceTypeCount int=0                  
 declare @totalPayableAmount decimal(18,4)=0     
 
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
  ,SOPType=@SOPType
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
  ,SOPType=@SOPType
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

DROP PROCEDURE IF EXISTS  [dbo].[sp_SaveGenerateSiblingDiscount]
GO

CREATE PROCEDURE [dbo].[sp_SaveGenerateSiblingDiscount]  
 @LoginUserId int  
 ,@SiblingDiscountId int  
 ,@SchoolAcademicId bigint = 0  
 ,@ActionId int --1 Generate,5 Regenerate   
AS  
BEGIN  
 --1 Generate  
 --2 Applied-Pending for Approval  
 --3 Applied  
 --4 Rejected  
 --5 Regenerate  
  
 DECLARE @FeeTypeId INT =3  
 SELECT TOP 1  @FeeTypeId=ISNULL(FeeTypeId,3) FROM tblFeeTypeMaster WHERE  FeeTypeName LIKE '%TUITION%'   
  
 IF @ActionId=1 AND EXISTS(SELECT 1 FROM tblSiblingDiscount WHERE SchoolAcademicId=@SchoolAcademicId AND FeeTypeId=@FeeTypeId)   
 BEGIN  
  SELECT -2 AS Result, 'Sibling Discount already generated. Please regenrate from grid' AS Response    
  RETURN;    
 END  
 SET NOCOUNT ON;   
 BEGIN TRY  
 BEGIN TRANSACTION TRANS1  
  IF(@ActionId=1)  
  BEGIN  
   INSERT INTO tblSiblingDiscount  
    (SchoolAcademicId, FeeTypeId,  GenerateStatus, UpdateDate, UpdateBy)  
    VALUES (@SchoolAcademicId, @FeeTypeId, 1, GETDATE(), @LoginUserId)   
   SET @SiblingDiscountId=SCOPE_IDENTITY();  
  END  
  ELSE IF(@ActionId=5)  
  BEGIN  
   DELETE FROM tblSiblingDiscountDetail WHERE SiblingDiscountId=@SiblingDiscountId  
   UPDATE tblSiblingDiscount SET GenerateStatus=5 WHERE SiblingDiscountId=@SiblingDiscountId  
   SELECT @SchoolAcademicId=SchoolAcademicId FROM tblSiblingDiscount WHERE SiblingDiscountId=@SiblingDiscountId  
  END  
    
  INSERT INTO tblSiblingDiscountDetail(SiblingDiscountId,StudentId,SchoolAcademicId,GradeId,FeeTypeId,DiscountPercent,DiscountAmount,UpdateDate,UpdateBy)    
    
  SELECT   
   SiblingDiscountId=@SiblingDiscountId,  
   StudentId, AcademicYearId, GradeId, FeetYpeId,DiscountPercent, 0 as DiscountAmount, getdate() as Updatedate, @LoginUserId as UpdateBy  
  FROM   
  (  
   SELECT   
    ROW_NUMBER() OVER( PARTITION BY ParentId ORDER BY ParentId, gm.SequenceNo,tbl.StudentId) AS StuentChildNo  
    ,tbl.StudentId  
    ,fee.AcademicYearId  
    ,fee.GradeId  
    ,FeetYpeId=@FeeTypeId  
   FROM tblStudent tbl  
   JOIN tblStudentFeeDetail fee ON tbl.StudentId=fee.StudentId AND tbl.GradeId=fee.GradeId  
   join tblGradeMaster gm on tbl.GradeId=gm.GradeId
   WHERE fee.AcademicYearId=@SchoolAcademicId  
   AND fee.IsActive=1 AND fee.IsDeleted=0  
  )t  
  LEFT JOIN tblSiblingDiscountMaster mas  
   ON t.StuentChildNo =mas.ChildrenNo   
   AND mas.IsActive=1   
   AND mas.IsDeleted=0 --and t.AcademicYearId=mas.AcademicYearId  
  
  
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