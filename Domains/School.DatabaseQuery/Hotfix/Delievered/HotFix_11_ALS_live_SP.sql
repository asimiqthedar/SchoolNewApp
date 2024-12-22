    
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
order by VatId desc

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

alter proc [dbo].[SP_GetVATDetail]  
 @InvoiceTypeName nvarchar(50),  
 @NationalityId int=0  
as  
begin  
  
 declare @VatPercent decimal(18,2)=0;  
 select   
 top 1   
  fd.VatId  
  ,fd.FeeTypeId    
  ,fd.IsActive  
  ,fd.IsDeleted  
  ,fd.UpdateDate  
  ,fd.UpdateBy  
  ,fd.DebitAccount  
  ,fd.CreditAccount  
  ,ISNULL(VatTaxPercent,0)VatTaxPercent   
 into #tempVat  
 from [dbo].[tblFeeTypeMaster] fm  
 left join [dbo].[tblVatMaster] fd on fm.FeeTypeId=fd.FeeTypeId  
 where fm.FeeTypeId=1 OR fm.FeeTypeName like '%'+@InvoiceTypeName+'%'  
 and fm.IsActive=1 and fm.IsDeleted=0  
 and fd.IsActive=1 and fd.IsDeleted=0   
order by VatId desc
   
 if exists(select VatId from tblVatCountryExclusionMap where VatId in (select vatid from #tempVat) and CountryId=@NationalityId  
 and IsDeleted=0 and IsActive=1)  
 begin  
  set @VatPercent=0  
 end  
 else  
 begin  
  select @VatPercent=VatTaxPercent from #tempVat  
 end  
   
 select   
  fd.VatId  
  ,fd.FeeTypeId    
  ,fd.IsActive  
  ,fd.IsDeleted  
  ,fd.UpdateDate  
  ,fd.UpdateBy  
  ,fd.DebitAccount  
  ,fd.CreditAccount  
  ,ISNULL(@VatPercent,0)VatTaxPercent   
 from #tempVat fd  
  
 drop table #tempVat  
end  
GO
