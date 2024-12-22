
drop view if exists [vw_Invoices]
GO

CREATE view  [dbo].[vw_Invoices]      
as    
  
      
select       
RN,ID,  
RefID,t.InvoiceNo,InvoiceDate,Status,PublishedBy,  
CreditNo,CreditReason,CustomerName=isnull(CustomerName,ParentName)  
  
,PaymentMethod,ChequeNo,ParentID,InvoiceType  
,EmailID,MobileNo  
,ParentName,Nationality=ISNULL(Nationality,''),Address=''  
,GPVoucherNo,VATNo,EncodedInvoice,InvoiceHash,UUID,      
ReportingStatus=ISNULL(ReportingStatus,'Not Reported'),QRCodePath,SignedXMLPath,CreatedOn,CreatedBy,UpdatedOn,UpdatedBy,TotalItemSubtotal,TotalTaxableAmount,TotalTaxAmount     
  ,FatherIQAMA   
    
from(      
 SELECT distinct       
 RN,ID,RefID,InvoiceNo,PaymentMethod,Status,ChequeNo,ParentID,PublishedBy,InvoiceDate,CreditNo,InvoiceType,CreditReason,CustomerName  
,EmailID,MobileNo  
 ,GPVoucherNo,VATNo,EncodedInvoice,InvoiceHash,UUID,ReportingStatus,QRCodePath,SignedXMLPath,CreatedOn,CreatedBy,UpdatedOn,UpdatedBy,TotalItemSubtotal,TotalTaxableAmount,TotalTaxAmount      
 ,ParentName,FatherIQAMA  
 ,Nationality  
  
 from       
 (      
  select       
   ROW_NUMBER() over(partition by s.InvoiceNo order by cast( s.InvoiceNo as int) desc) as RN,      
   s.ID      
   ,s.RefID      
   ,InvoiceNo=cast(s.InvoiceNo as int)      
   ,PaymentMethod=isnull(tis.PaymentMethod, s.PaymentMethod)  
   ,s.Status      
   ,ChequeNo=isnull(s.ChequeNo ,tis.PaymentReferenceNumber   )  
   ,s.ParentID      
   ,s.PublishedBy      
   ,s.InvoiceDate      
   ,s.CreditNo      
   ,s.InvoiceType      
   ,s.CreditReason      
   ,s.CustomerName   
   ,s.EmailID      
   ,s.MobileNo   
   ,s.GPVoucherNo      
   ,s.VATNo      
   ,s.EncodedInvoice      
   ,s.InvoiceHash      
   ,s.UUID      
   ,s.ReportingStatus      
   ,s.QRCodePath      
   ,s.SignedXMLPath      
   ,s.CreatedOn      
   ,s.CreatedBy      
   ,s.UpdatedOn      
   ,s.UpdatedBy      
   ,TotalItemSubtotal=case when  isnull(t.TotalItemSubtotal,0) =0 then isnull(tUniform.TotalItemSubtotal,0) else isnull(t.TotalItemSubtotal,0) end      
   ,TotalTaxableAmount=case when  isnull(t.TotalTaxableAmount,0) =0 then isnull(tUniform.TotalTaxableAmount,0) else isnull(t.TotalTaxableAmount,0) end      
   ,TotalTaxAmount  =case when  isnull(t.TotalTaxAmount,0) =0 then isnull(tUniform.TotalTaxAmount,0) else isnull(t.TotalTaxAmount,0) end      
,ParentName=coalesce(par.ParentName ,s.ParentName)      
 ,FatherIQAMA=ISNULL(par.FatherIqamaNo,'')      
,Nationality=isnull(par.Nationality,s.Nationality)  
  
  from InvoiceSummary s      
  left join       
  (      
   select       
    InvoiceNo      
    ,TotalTaxableAmount=sum(isnull(TaxableAmount,0))       
    ,TotalTaxAmount =sum(isnull(TaxAmount,0))       
    ,TotalItemSubtotal =sum(isnull(ItemSubtotal,0))       
   from [InvoiceDetail]      
   group by InvoiceNo      
  )t      
  on s.InvoiceNo collate SQL_Latin1_General_CP1_CI_AS=t.InvoiceNo      
      
  left join       
  (      
   select       
    InvoiceNo      
    ,TotalTaxableAmount=sum( cast (isnull(TaxableAmount,0) as decimal))      
    ,TotalTaxAmount =sum( cast (isnull(TaxAmount,0) as decimal))      
    ,TotalItemSubtotal =sum( cast (isnull(ItemSubtotal,0) as decimal))      
   from UniformDetails      
   group by InvoiceNo      
  )tUniform      
  on s.InvoiceNo collate SQL_Latin1_General_CP1_CI_AS=tUniform.InvoiceNo  
  --left join      
  --(      
  -- select distinct ParentId ,Nationality,Address ,cast(ParentName collate SQL_Latin1_General_CP1_CI_AS as nvarchar(400)) as ParentName      
  -- from   INVOICE.dbo.Parents par      
  --)par       
  --on  s.ParentID collate SQL_Latin1_General_CP1_CI_AS=par.ParentId      
 -- where s.Status='Posted'     
   
   left join      
  (      
   select distinct ParentId =ParentCode ,FatherIqamaNo,ParentName=FatherName   ,Nationality=COU.CountryName   
   from   ALS_LIVE.DBO.TBLPARENT P  
   JOIN ALS_LIVE.DBO.tblCountryMaster COU ON P.FatherNationalityId=COU.CountryId  
  )par       
  on  s.ParentID collate SQL_Latin1_General_CP1_CI_AS=par.ParentId      
    
  LEFT JOIN  
  (  
   select   
  InvoiceNo ,PaymentReferenceNumber ,PaymentMethod  
   from  
   (  
     select      
    ROW_NUMBER() over(partition by tis.InvoiceNo order by  tis.PaymentAmount desc) as RN              
    ,tis.InvoiceNo         
    ,tis.PaymentReferenceNumber    
    ,tis.PaymentMethod  
    from InvoicePayment tis  
  )t  
  where t.RN=1  
  ) tis  
  on tis.InvoiceNo=s.InvoiceNo      
  
  
 -- where s.Status='Posted'     
 )t       
      
 where       
 t.RN=1      
)t      
left join       
(      
 select distinct      
 InvoiceNo,      
  [Description]      
 from [InvoiceDetail]      
 where [Description] like '%#%'      
)tDesc      
on tDesc.InvoiceNo collate SQL_Latin1_General_CP1_CI_AS=t.InvoiceNo      
GO