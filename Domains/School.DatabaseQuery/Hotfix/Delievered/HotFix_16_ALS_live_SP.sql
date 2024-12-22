ALTER proc sp_ProcessGP_UniformInvoice  
(  
  @invoiceno int=0  
)  
as  
begin  
  
  begin try
  
	--SeqNum, SOPNumber and SOPType are the Primary Keys.  
--SOPType = 3 for Invoice and 4 for Return.  
--DocID should be the value which is already available in GP, example is “STDINV”.  
--DocDate, CustomerNumber and ItemNumber are mandatory.  
 -- IntegrationStatus = 0, always insert value 0. 0 = New, 1 = Integrated To GP and 2 = Failed.  
 --declare @invoiceno int=6633  
   
  
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
	  ,UnitPrice=invDet.UnitPrice  
	  ,ItemSubtotal=invDet.ItemSubtotal  
	  ,IntegrationStatus=@IntegrationStatus  
	  ,Error=0  
	  ,invDet.InvoiceType  
	 into #INT_SalesInvoiceSourceTable  
	 from INV_InvoiceDetail invDet  
	 join INV_InvoiceSummary invSum  
	 on invDet.InvoiceNo=invSum.InvoiceNo  
	 where invDet.InvoiceType like '%Uniform%'  
	 and invSum.invoiceno=@invoiceno  
  
	 insert into INT_SalesInvoiceSourceTable(SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,UnitPrice,IntegrationStatus,Error)  
	 select   
	  SeqNum,SOPNumber,SOPType,DocID,DocDate,CustomerNumber,ItemNumber,Quantity,UnitPrice,IntegrationStatus,Error  
	 from #INT_SalesInvoiceSourceTable  
  
	 -----------payment processing  
	 --If uniform available with other invoice type then we need to process a signle payment record which ever is first in our payment table  
	 -- If Uniform invoice type only available in detail then we need to process all record from our payment table  
   
	 select @InvoiceTypeCount=count(InvoiceType) from #INT_SalesInvoiceSourceTable   
	 select @totalPayableAmount=sum(isnull(ItemSubtotal,0)) from #INT_SalesInvoiceSourceTable  
  
	 --4 for Cash payment, 5 for Check payment & bank transfer, and 6 for Credit card payment.  
	 --Bank Transfer =5  
	 --Check=5  
	 --Cash=4  
	 --Visa=6  
    
	 if(@InvoiceTypeCount>1)  
	 begin  
	  insert into INT_SalesPaymentSourceTable  
	  (  
	   SeqNum,SOPNumber,SOPType,PaymentType,PaymentAmount,CardName,CheckNumber,CreditCardNumber,  
	   AuthorizationCode,ExpirationDate,IntegrationStatus,Error  
	  )  
	  select   
	   SeqNum  
	   ,SOPNumber  
	   ,SOPType  
	   ,PaymentType  
	   ,PaymentAmount  
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
	   SeqNum,SOPNumber,SOPType,PaymentType,PaymentAmount,CardName,CheckNumber,CreditCardNumber,  
	   AuthorizationCode,ExpirationDate,IntegrationStatus,Error  
	  )  
	  select   
	   SeqNum  
	   ,SOPNumber  
	   ,SOPType  
	   ,PaymentType  
	   ,PaymentAmount  
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
	 select 0 result
	 end TRY
	 begin catch
 
		select -1 result
	 end catch

end
go

ALTER PROCEDURE [dbo].[sp_GetInvoice]    
 @InvoiceId bigint = 0,                  
 @Status nvarchar(50) = NULL,                  
 @InvoiceDateStart date = NULL,                  
 @InvoiceDateEnd date = NULL,                  
 @InvoiceType nvarchar(50) = NULL,                  
 @InvoiceNo nvarchar(50) = NULL,                  
 @ParentCode nvarchar(50) = NUll,                  
 @ParentName nvarchar(400) = NULL,          
 @FatherMobile nvarchar(200) = NULL          
 AS    
BEGIN                            
 SET NOCOUNT ON;                             
                  
	SELECT                   
		tis.InvoiceId                  
		,tis.InvoiceNo                  
		,tis.InvoiceDate                  
		,tis.Status                  
		,tis.PublishedBy                  
		,tis.CreditNo                  
		,tis.CreditReason                  
		,tis.CustomerName              
		,tis.IqamaNumber  
		,tis.IsDeleted                  
		,tis.UpdateDate                  
		,tis.UpdateBy                 
		,InvoiceType=isnull(tis.InvoiceType,'Invoice')
		,tis.InvoiceRefNo
	into #InvoiceSummary          
	FROM INV_InvoiceSummary tis                         
	--LEFT JOIN tblParent tp ON tis.ParentID = tp.ParentId                     
	WHERE tis.InvoiceId = CASE WHEN @InvoiceId > 0 THEN @InvoiceId ELSE tis.InvoiceId END                  
	AND (@Status IS NULL OR tis.[Status] = @Status)                  
	AND (@InvoiceDateStart IS NULL OR cast(tis.InvoiceDate as date) >= cast(@InvoiceDateStart as date))                  
	AND (@InvoiceDateEnd IS NULL OR cast(tis.InvoiceDate as date) <= cast(@InvoiceDateEnd as date))                  
	AND (@InvoiceType IS NULL OR tis.InvoiceType = @InvoiceType)                  
	AND (@InvoiceNo IS NULL OR tis.InvoiceNo = @InvoiceNo)                  
	AND tis.IsDeleted = 0         
  
	select  
	tis.InvoiceNo     
	,TaxableAmount=sum(tis.TaxableAmount)  
	,TaxAmount=sum(tis.TaxAmount)  
	,ItemSubtotal=sum(tis.ItemSubtotal)  
	into #InvoiceDetail  
	from INV_InvoiceDetail tis  
	join #InvoiceSummary invSum  
	on tis.InvoiceNo=invSum.InvoiceNo  
	group by tis.InvoiceNo  
     
     --select  @ParentCode        
 select       
  t.InvoiceNo, t.ParentID,t.ParentName,t.FatherMobile,t.ParentCode,t.StudentId,t.StudentName,t.StudentCode,t.InvoiceTypeValue,        
  ROW_NUMBER() over(partition by t.InvoiceNo order by  t.InvoiceNo) as RN          
 into #INDMobile          
 from          
 (          
  select distinct           
   ins.InvoiceNo        
   ,ParentID= case when tp.ParentID is null then ind.ParentID  else tp.ParentID end        
   ,ParentName= case when tp.FatherName COLLATE SQL_Latin1_General_CP1256_CI_AS  is null then ind.ParentName  else tp.FatherName COLLATE SQL_Latin1_General_CP1256_CI_AS  end        
   ,FatherMobile= case when tp.FatherMobile is null then ind.FatherMobile  else tp.FatherMobile end        
   ,ParentCode= case when tp.ParentCode is null then ''  else tp.ParentCode end        
              
   ,StudentId= case when ts.StudentId is null then ind.StudentId  else ts.StudentId end        
   ,StudentName=case when ind.InvoiceType like '%Uniform%' then '' else  
  case when ts.StudentName COLLATE SQL_Latin1_General_CP1256_CI_AS  is null then ind.StudentName    
  else ts.StudentName COLLATE SQL_Latin1_General_CP1256_CI_AS   
  end       
 end  
   ,StudentCode= case when ts.StudentCode is null then ''  else ts.StudentCode end          
           
   ,InvoiceTypeValue=    
   (select REPLACE(STUFF(CAST((          
    SELECT   ', ' +CAST(c.InvoiceType AS VARCHAR(MAX))          
     FROM (           
     SELECT distinct scm.InvoiceType              
    FROM INV_InvoiceDetail AS scm                
    WHERE scm.InvoiceNo = ins.InvoiceNo        
       
   ) c          
  FOR XML PATH(''), TYPE) AS VARCHAR(MAX)), 1, 2, ''),' ',' ')  
 )  
 from           
 #InvoiceSummary ins          
 join INV_InvoiceDetail ind on ins.InvoiceNo=ind.InvoiceNo          
 LEFT JOIN tblParent tp ON ind.ParentID = tp.ParentId          
 AND tp.ParentCode=CASE WHEN @ParentCode IS NULL OR @ParentCode='' THEN tp.ParentCode ELSE @ParentCode END      
 AND ind.FatherMobile=CASE WHEN @FatherMobile IS NULL OR @FatherMobile='' THEN ind.FatherMobile ELSE @FatherMobile END      
 AND tp.FatherName like '%' + CASE WHEN @ParentName IS NULL OR @ParentName='' THEN tp.FatherName ELSE @ParentName END +'%'      
 LEFT JOIN tblStudent ts ON ind.StudentId = ts.StudentId        
        
 where ind.FatherMobile is null OR len( ISNULL(ind.FatherMobile,''))>0          
 )t    
    
 delete from #INDMobile where RN>1     

 ----Get Max payemtn info
 select  
 ROW_NUMBER() over(partition by tis.InvoiceNo order by  tis.PaymentAmount desc) as RN          
	,tis.InvoiceNo     
	,tis.PaymentReferenceNumber
	,tis.PaymentMethod
	into #InvoicePayment  
	from INV_InvoicePayment tis  
	join #InvoiceSummary invSum  
	on tis.InvoiceNo=invSum.InvoiceNo  

	 delete from #InvoicePayment where RN>1    
      
 select     
  ins.*  
 
  ,ParentID=cast( isnull(ind.ParentID  ,'') as nvarchar(100))        
  ,ParentName=isnull(ind.ParentName  ,'')        
  ,FatherMobile=isnull(ind.FatherMobile  ,'')        
  ,ParentCode=isnull(ind.ParentCode  ,'')        
  ,StudentId=isnull(ind.StudentId  ,'')        
  ,StudentName=isnull(ind.StudentName  ,'')        
  ,StudentCode=isnull(ind.StudentCode,'')        
  ,InvoiceTypeValue=ind.InvoiceTypeValue
  ,indPay.PaymentMethod
  ,indPay.PaymentReferenceNumber
  ,invDet.TaxableAmount  
  ,invDet.TaxAmount  
  ,invDet.ItemSubtotal  
 from #InvoiceSummary ins   
 join #InvoiceDetail invDet on ins.InvoiceNo=invDet.InvoiceNo  
 left join  #INDMobile ind on ins.InvoiceNo=ind.InvoiceNo  
  left join  #InvoicePayment indPay on ins.InvoiceNo=indPay.InvoiceNo     
 WHERE     
 --isnull(ParentCode,'')=CASE WHEN @ParentCode IS NULL OR @ParentCode='' THEN ParentCode ELSE @ParentCode END    
  (@ParentCode IS NULL OR isnull(ParentCode,'') like '%' + @ParentCode  +'%'   )    
 and (@FatherMobile IS NULL OR isnull(FatherMobile,'') like '%' + @FatherMobile  +'%'   )    
 and (@ParentName IS NULL OR isnull(ParentName,'') like '%' + @ParentName  +'%'   )    
 --AND isnull(FatherMobile,'') like '%' + CASE WHEN @FatherMobile IS NULL OR @FatherMobile='' THEN FatherMobile ELSE @FatherMobile END  +'%'      
 --AND isnull(ParentName,'') like '%' + CASE WHEN @ParentName IS NULL OR @ParentName='' THEN ParentName ELSE @ParentName END +'%'      
  ORDER BY ins.InvoiceNo DESC         
    
    
 drop table #InvoiceSummary        
 drop table #INDMobile  
 drop table #InvoiceDetail  
  
END 
GO


ALTER PROCEDURE [dbo].sp_CSVInvoiceExport
	 @InvoiceId bigint = 0,                
	 @Status nvarchar(50) = NULL,                
	 @InvoiceDateStart date = NULL,                
	 @InvoiceDateEnd date = NULL,                
	 @InvoiceType nvarchar(50) = NULL,                
	 @InvoiceNo nvarchar(50) = NULL,                
	 @ParentCode nvarchar(50) = NUll,                
	 @ParentName nvarchar(400) = NULL,        
	 @FatherMobile nvarchar(200) = NULL      
 AS  
 BEGIN                            
 SET NOCOUNT ON;                             
             
	SELECT                   
		tis.InvoiceId                  
		,tis.InvoiceNo                  
		,InvoiceDate= convert(varchar, tis.InvoiceDate, 103)     
		,tis.Status                  
		,tis.PublishedBy                  
		,tis.CreditNo                  
		,tis.CreditReason                  
		,tis.CustomerName              
		,tis.IqamaNumber  
		,tis.IsDeleted                  
		,tis.UpdateDate                  
		,tis.UpdateBy                 
		,InvoiceType=isnull(tis.InvoiceType,'Invoice')
		,tis.InvoiceRefNo
	into #InvoiceSummary          
	FROM INV_InvoiceSummary tis                         
	--LEFT JOIN tblParent tp ON tis.ParentID = tp.ParentId                     
	WHERE tis.InvoiceId = CASE WHEN @InvoiceId > 0 THEN @InvoiceId ELSE tis.InvoiceId END                  
	AND (@Status IS NULL OR tis.[Status] = @Status)                  
	AND (@InvoiceDateStart IS NULL OR cast(tis.InvoiceDate as date) >= cast(@InvoiceDateStart as date))                  
	AND (@InvoiceDateEnd IS NULL OR cast(tis.InvoiceDate as date) <= cast(@InvoiceDateEnd as date))                  
	AND (@InvoiceType IS NULL OR tis.InvoiceType = @InvoiceType)                  
	AND (@InvoiceNo IS NULL OR tis.InvoiceNo = @InvoiceNo)                  
	AND tis.IsDeleted = 0         
  
	select  
	tis.InvoiceNo     
	,TaxableAmount=sum(tis.TaxableAmount)  
	,TaxAmount=sum(tis.TaxAmount)  
	,ItemSubtotal=sum(tis.ItemSubtotal)  
	into #InvoiceDetail  
	from INV_InvoiceDetail tis  
	join #InvoiceSummary invSum  
	on tis.InvoiceNo=invSum.InvoiceNo  
	group by tis.InvoiceNo  
     
     --select  @ParentCode        
 select       
  t.InvoiceNo, t.ParentID,t.ParentName,t.FatherMobile,t.ParentCode,t.StudentId,t.StudentName,t.StudentCode,t.InvoiceTypeValue,        
  ROW_NUMBER() over(partition by t.InvoiceNo order by  t.InvoiceNo) as RN          
 into #INDMobile          
 from          
 (          
  select distinct           
   ins.InvoiceNo        
   ,ParentID= case when tp.ParentID is null then ind.ParentID  else tp.ParentID end        
   ,ParentName= case when tp.FatherName COLLATE SQL_Latin1_General_CP1256_CI_AS  is null then ind.ParentName  else tp.FatherName COLLATE SQL_Latin1_General_CP1256_CI_AS  end        
   ,FatherMobile= case when tp.FatherMobile is null then ind.FatherMobile  else tp.FatherMobile end        
   ,ParentCode= case when tp.ParentCode is null then ''  else tp.ParentCode end        
              
   ,StudentId= case when ts.StudentId is null then ind.StudentId  else ts.StudentId end        
   ,StudentName=case when ind.InvoiceType like '%Uniform%' then '' else  
  case when ts.StudentName COLLATE SQL_Latin1_General_CP1256_CI_AS  is null then ind.StudentName    
  else ts.StudentName COLLATE SQL_Latin1_General_CP1256_CI_AS   
  end       
 end  
   ,StudentCode= case when ts.StudentCode is null then ''  else ts.StudentCode end          
           
   ,InvoiceTypeValue=    
   (select REPLACE(STUFF(CAST((          
    SELECT   ', ' +CAST(c.InvoiceType AS VARCHAR(MAX))          
     FROM (           
     SELECT distinct scm.InvoiceType              
    FROM INV_InvoiceDetail AS scm                
    WHERE scm.InvoiceNo = ins.InvoiceNo        
       
   ) c          
  FOR XML PATH(''), TYPE) AS VARCHAR(MAX)), 1, 2, ''),' ',' ')  
 )  
 from           
 #InvoiceSummary ins          
 join INV_InvoiceDetail ind on ins.InvoiceNo=ind.InvoiceNo          
 LEFT JOIN tblParent tp ON ind.ParentID = tp.ParentId          
 AND tp.ParentCode=CASE WHEN @ParentCode IS NULL OR @ParentCode='' THEN tp.ParentCode ELSE @ParentCode END      
 AND ind.FatherMobile=CASE WHEN @FatherMobile IS NULL OR @FatherMobile='' THEN ind.FatherMobile ELSE @FatherMobile END      
 AND tp.FatherName like '%' + CASE WHEN @ParentName IS NULL OR @ParentName='' THEN tp.FatherName ELSE @ParentName END +'%'      
 LEFT JOIN tblStudent ts ON ind.StudentId = ts.StudentId        
        
 where ind.FatherMobile is null OR len( ISNULL(ind.FatherMobile,''))>0          
 )t    
    
 delete from #INDMobile where RN>1     

 ----Get Max payemtn info
 select  
 ROW_NUMBER() over(partition by tis.InvoiceNo order by  tis.PaymentAmount desc) as RN          
	,tis.InvoiceNo     
	,tis.PaymentReferenceNumber
	,tis.PaymentMethod
	into #InvoicePayment  
	from INV_InvoicePayment tis  
	join #InvoiceSummary invSum  
	on tis.InvoiceNo=invSum.InvoiceNo  

	 delete from #InvoicePayment where RN>1    
      
 select     
  ins.*  
 
  ,ParentID=cast( isnull(ind.ParentID  ,'') as nvarchar(100))        
  ,ParentName=isnull(ind.ParentName  ,'')        
  ,FatherMobile=isnull(ind.FatherMobile  ,'')        
  ,ParentCode=isnull(ind.ParentCode  ,'')        
  ,StudentId=isnull(ind.StudentId  ,'')        
  ,StudentName=isnull(ind.StudentName  ,'')        
  ,StudentCode=isnull(ind.StudentCode,'')        
  ,InvoiceTypeValue=ind.InvoiceTypeValue
  ,indPay.PaymentMethod
  ,indPay.PaymentReferenceNumber
  ,invDet.TaxableAmount  
  ,invDet.TaxAmount  
  ,invDet.ItemSubtotal  
 from #InvoiceSummary ins   
 join #InvoiceDetail invDet on ins.InvoiceNo=invDet.InvoiceNo  
 left join  #INDMobile ind on ins.InvoiceNo=ind.InvoiceNo  
  left join  #InvoicePayment indPay on ins.InvoiceNo=indPay.InvoiceNo     
 WHERE     
 --isnull(ParentCode,'')=CASE WHEN @ParentCode IS NULL OR @ParentCode='' THEN ParentCode ELSE @ParentCode END    
  (@ParentCode IS NULL OR isnull(ParentCode,'') like '%' + @ParentCode  +'%'   )    
 and (@FatherMobile IS NULL OR isnull(FatherMobile,'') like '%' + @FatherMobile  +'%'   )    
 and (@ParentName IS NULL OR isnull(ParentName,'') like '%' + @ParentName  +'%'   )    
 --AND isnull(FatherMobile,'') like '%' + CASE WHEN @FatherMobile IS NULL OR @FatherMobile='' THEN FatherMobile ELSE @FatherMobile END  +'%'      
 --AND isnull(ParentName,'') like '%' + CASE WHEN @ParentName IS NULL OR @ParentName='' THEN ParentName ELSE @ParentName END +'%'      
  ORDER BY ins.InvoiceNo DESC         
    
    
 drop table #InvoiceSummary        
 drop table #INDMobile  
 drop table #InvoiceDetail  
  
END 
GO