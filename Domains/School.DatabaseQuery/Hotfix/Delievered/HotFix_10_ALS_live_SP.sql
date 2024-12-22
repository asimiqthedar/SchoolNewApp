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
 where fm.FeeTypeName like '%'+@InvoiceTypeName+'%'  
 and fm.IsActive=1 and fm.IsDeleted=0  
 and fd.IsActive=1 and fd.IsDeleted=0   
 order by 1 desc
   
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