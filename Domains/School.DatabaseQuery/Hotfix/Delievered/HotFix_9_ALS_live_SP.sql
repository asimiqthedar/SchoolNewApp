alter PROCEDURE [dbo].[SP_ItemCodeRecords]     
 @UniformDB nvarchar(100)  
as      
begin      
  
 DECLARE @Query nvarchar(max)  
 --DECLARE @ParmDefinition NVARCHAR(500);  
  
 --/* Build the SQL string once */  
 --SET @Query = N'select ltrim(rtrim(ITEMNMBR)) as ItemCode,    
 -- isnull(nullif(ltrim(rtrim(LOCNCODE)),''''),ltrim(rtrim(ITEMNMBR))) as ItemCodeDescription    
 -- from '+@UniformDB+'.[dbo].IV00102 where LOCNCODE=''''' ;  
 ----SET @ParmDefinition = N'@UniformDBinput nvarchar(500)';  
 --/* Execute the string with the first parameter value. */  

   --Production 
    SET @Query = N'select ltrim(rtrim(ITEMNMBR)) as ItemCode,    
  isnull(nullif(ltrim(rtrim(ITEMDESC)),''''),ltrim(rtrim(ITEMNMBR))) as ItemCodeDescription    
  from '+@UniformDB+'.[dbo].IV00101 where LOCNCODE=''''' ;  
                                                                                       
  --select * from two.dbo.IV00101
 EXECUTE sp_executesql @Query; 
  
end    
GO
 
alter proc [dbo].[Sp_GetItemCodeRecord]      
@ItemCode nvarchar(200)      
,@nationalId int  
, @UniformDB nvarchar(100)    
as      
begin  
 declare @VatPercent decimal(18,2)=0;    
 declare @VatID int=0;    
 declare @ExcludedCountryCount int=0;    
  
 select top 1   
  @VatPercent=ISNULL(VatTaxPercent,0),  
  @VatID =fd.VatId  
 from [dbo].[tblFeeTypeMaster] fm    
 inner join [dbo].[tblVatMaster] fd on fm.FeeTypeId=fd.FeeTypeId    
 where fm.FeeTypeId=1 OR fm.FeeTypeName like '%uniform%'    
 and fm.IsActive=1 and fm.IsDeleted=0    
 and fd.IsActive=1 and fd.IsDeleted=0      
  
   if(@VatID>0)    
   begin    
	select @ExcludedCountryCount=count(CountryId) from tblVatCountryExclusionMap where VatID=@VatID AND IsActive=1 and IsDeleted=0    
   end  
  
   --select * from tblVatCountryExclusionMap where VatID=@VatID AND IsActive=1 and IsDeleted=0 and CountryId=@nationalId  
  
   ----check if country excempted from tax  
   if exists(select 1 from tblVatCountryExclusionMap where VatID=@VatID AND IsActive=1 and IsDeleted=0 and CountryId=@nationalId)  
   begin  
 set @VatPercent=0  
   end  
  
 DECLARE @Query nvarchar(max)   
 declare @VatPercent2 nvarchar(500)    
 declare @ExcludedCountryCount2 nvarchar(500)    
 DECLARE @VatID2 nvarchar(500)    
    
 SELECT @VatPercent2=cast( @VatPercent as nvarchar(50))    
    
 SELECT @ExcludedCountryCount2=cast( @ExcludedCountryCount as nvarchar(50))    
 SELECT @VatID2=cast( @VatID as nvarchar(50))    
    
  --/* Build the SQL string once */    
  --SET @Query = N'SELECT top 1       
  --A.CURRCOST AS CurrentPrice,      
  --A.ITEMNMBR as ItemCode,      
  --A.ITEMDESC as ItemDescription,      
  --B.QTYONHND as QuantityOnHand,      
  --B.ATYALLOC as QuantityAllocated,      
  --AvailableQuantity= B.QTYONHND-B.ATYALLOC    
    
  --,VatPercent = '+@VatPercent2+'    
  --,ExcludedCountryCount='+@ExcludedCountryCount2+'    
  --,VatID='+@VatID2+'    
    
  --FROM '+@UniformDB+'.[dbo].IV00101 A      
  --join '+@UniformDB+'.[dbo].IV00102 B       
  --on A.ITEMNMBR=b.ITEMNMBR      
  --where A.ITEMNMBR like ''%'+@ItemCode+'%''    
  --and B.LOCNCODE=''''' ;  
  

  --Production

    /* Build the SQL string once */    
  SET @Query = N'SELECT top 1       
  A.STNDCOST  AS CurrentPrice,      
  A.ITEMNMBR as ItemCode,      
  A.ITEMDESC as ItemDescription,      
  B.QTYONHND as QuantityOnHand,      
  B.ATYALLOC as QuantityAllocated,      
  AvailableQuantity= B.QTYONHND-B.ATYALLOC    
    
  ,VatPercent = '+@VatPercent2+'    
  ,ExcludedCountryCount='+@ExcludedCountryCount2+'    
  ,VatID='+@VatID2+'    
    
  FROM '+@UniformDB+'.[dbo].IV00101 A      
  join '+@UniformDB+'.[dbo].IV00102 B       
  on A.ITEMNMBR=b.ITEMNMBR      
  where A.ITEMNMBR like ''%'+@ItemCode+'%''    
  and B.LOCNCODE='''' 
  and A.LOCNCODE=''''' ;    

  print @query    

  EXECUTE sp_executesql @Query;    
  
end   
GO

alter PROCEDURE [dbo].[sp_GetInvoice]                      
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
  --,tis.ParentId    
  --,ParentCode=isnull(tp.ParentCode,0)  
  ,tis.IqamaNumber            
  ,tis.TaxableAmount            
  ,tis.TaxAmount            
  ,tis.ItemSubtotal            
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
   --AND (@ParentCode IS NULL OR tp.ParentCode = @ParentCode)            
   --AND (@ParentName IS NULL OR tp.FatherName like '%'+@ParentName+'%')     
   --AND (@FatherMobile IS NULL OR tp.FatherMobile = @FatherMobile)           
   --And (@FatherMobile is null OR (@FatherMobile is not null and tis.InvoiceNo in (select InvoiceNo from INV_InvoiceDetail where FatherMobile = @FatherMobile)  ))    
   AND tis.IsDeleted = 0                      
     
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
    ,StudentName= case when ts.StudentName COLLATE SQL_Latin1_General_CP1256_CI_AS  is null then ind.StudentName  else ts.StudentName COLLATE SQL_Latin1_General_CP1256_CI_AS end  
    ,StudentCode= case when ts.StudentCode is null then ''  else ts.StudentCode end    
     
    ,InvoiceTypeValue=  (select REPLACE(STUFF(CAST((    
     SELECT   ', ' +CAST(c.InvoiceType AS VARCHAR(MAX))    
     FROM (     
    SELECT distinct scm.InvoiceType        
    FROM INV_InvoiceDetail AS scm          
    WHERE scm.InvoiceNo = ins.InvoiceNo          
    ) c    
    FOR XML PATH(''), TYPE) AS VARCHAR(MAX)), 1, 2, ''),' ',' '))  
    from     
    #InvoiceSummary ins    
    join INV_InvoiceDetail ind on ins.InvoiceNo=ind.InvoiceNo    
    LEFT JOIN tblParent tp ON ind.ParentID = tp.ParentId     
	AND (@ParentCode IS NULL OR tp.ParentCode = @ParentCode)   
	AND (@ParentName IS NULL OR tp.FatherName like '%'+@ParentName+'%')             
  
    LEFT JOIN tblStudent ts ON ind.StudentId = ts.StudentId  
  
    where ind.FatherMobile is null OR len( ISNULL(ind.FatherMobile,''))>0    
  )t    
    

 delete from #INDMobile where RN>1    
  


 select ins.*  
 ,ParentID=cast( isnull(ind.ParentID  ,'') as nvarchar(100))  
 ,ParentName=isnull(ind.ParentName  ,'')  
 ,FatherMobile=isnull(ind.FatherMobile  ,'')  
 ,ParentCode=isnull(ind.ParentCode  ,'')  
 ,StudentId=isnull(ind.StudentId  ,'')  
 ,StudentName=isnull(ind.StudentName  ,'')  
 ,StudentCode=isnull(ind.StudentCode,'')  
 ,InvoiceTypeValue=ind.InvoiceTypeValue  
 from #InvoiceSummary ins    
 left join  #INDMobile ind    
 on ins.InvoiceNo=ind.InvoiceNo    
  ORDER BY ins.InvoiceNo DESC   
   
 drop table #InvoiceSummary  
 drop table #INDMobile  
END 
GO