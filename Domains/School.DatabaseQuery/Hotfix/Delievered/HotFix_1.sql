--exec sp_GetFeeTypeDetail @FeeTypeId=4  
alter PROCEDURE [dbo].[sp_GetFeeTypeDetail]        
 @FeeTypeId bigint = 0        
 ,@FeeTypeDetailId bigint = 0      
AS        
BEGIN        
 SET NOCOUNT ON;         
 SELECT   
  tfm.FeeTypeId        
  ,tfm.FeeTypeName        
    
  ,tfm.IsTermPlan        
  ,tfm.IsPaymentPlan   
  ,tfm.IsGradeWise  
     
  ,isnull(tyd.FeeTypeDetailId,0) as FeeTypeDetailId  
  ,isnull(tyd.AcademicYearId,0) as AcademicYearId  
  ,CAST(isnull(tyd.TermFeeAmount,0) as DECIMAL(10,2))  as TermFeeAmount  
     ,CAST(isnull(tyd.StaffFeeAmount,0) as DECIMAL(10,2))  as StaffFeeAmount  
  ,isnull(tyd.GradeId,0) GradeId  
  ,isnull(tgm.GradeName,'')GradeName  
  
  ,tfm.IsActive    
    
  ,isnull(ac.AcademicYear,'')AcademicYear  
  ,TotalTerm=  
   (  
   select count(1)   
   from   
    [tblSchoolTermAcademic] tac    
   where ac.SchoolAcademicId=tac.SchoolAcademicId  
   and ac.IsActive=1 and ac.IsDeleted=0  
   and tac.IsDeleted=0  
  
   )  
 FROM  tblFeeTypeMaster tfm  
 inner join [tblFeeTypeDetail] tyd ON tfm.FeeTypeId=tyd.FeeTypeId    
 AND tyd.FeeTypeDetailId = CASE WHEN @FeeTypeDetailId > 0 THEN @FeeTypeDetailId ELSE tyd.FeeTypeDetailId END   
 AND tyd.IsDeleted =  0  
 AND tyd.IsActive=1  
 inner join [tblSchoolAcademic] ac ON  ac.SchoolAcademicId=tyd.AcademicYearId  
 left join tblGradeMaster tgm ON tyd.GradeId=tgm.GradeId    
 WHERE   
 tfm.FeeTypeId = CASE WHEN @FeeTypeId > 0 THEN @FeeTypeId ELSE tfm.FeeTypeId END   
   
 AND tfm.IsDeleted =  0    
 AND tfm.IsActive =  1   
   
 ORDER BY tfm.FeeTypeName   , tgm.GradeName   
   
  
 select  distinct sta.*   
 from [dbo].[tblSchoolTermAcademic] sta  
 inner join [tblFeeTypeDetail] ftd   
 on sta.SchoolAcademicId=ftd.AcademicYearId  
 where  sta.IsDeleted=0  
   and ftd.IsActive=1 and ftd.IsDeleted=0  
   and ftd.FeeTypeId=@FeeTypeId  
   order by StartDate  
  
END
GO

alter PROCEDURE [dbo].[SP_ItemCodeRecords]   
	@UniformDB nvarchar(100)
as    
begin    

 DECLARE @Query nvarchar(max)
 --DECLARE @ParmDefinition NVARCHAR(500);

	/* Build the SQL string once */
	SET @Query = N'select ltrim(rtrim(ITEMNMBR)) as ItemCode,  
	 isnull(nullif(ltrim(rtrim(LOCNCODE)),''''),ltrim(rtrim(ITEMNMBR))) as ItemCodeDescription  
	 from '+@UniformDB+'.[dbo].IV00102 where LOCNCODE=''''' ;
	--SET @ParmDefinition = N'@UniformDBinput nvarchar(500)';
	/* Execute the string with the first parameter value. */
	
	EXECUTE sp_executesql @Query;
	--,
	--    @ParmDefinition,
	--    @UniformDBinput = @UniformDB;

end  
GO


alter proc [dbo].[Sp_GetItemCodeRecord]  
@ItemCode nvarchar(200)  
,	@UniformDB nvarchar(100)
as  
begin  
 --SELECT top 1   
 -- 50 AS CurrentPrice,  
 -- 'T-ShirtCode Desc' as ItemDescription,  
 -- 'T-ShirtCode' as ItemCode,  
 -- 50 as QuantityOnHand,  
 -- 20 as QuantityAllocated,  
 -- AvailableQuantity= 30,  
 -- VatPercent = 15  

 declare @VatPercent decimal(18,2)=0;
 declare @VatID int=0;
  declare @ExcludedCountryCount int=0;
 select top 1 @VatPercent=ISNULL(VatTaxPercent,0), 
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
   
 --SELECT top 1   
 --A.CURRCOST AS CurrentPrice,  
 --A.ITEMNMBR as ItemCode,  
 --A.ITEMDESC as ItemDescription,  
 --B.QTYONHND as QuantityOnHand,  
 --B.ATYALLOC as QuantityAllocated,  
 --AvailableQuantity= B.QTYONHND-B.ATYALLOC  ,
 --VatPercent = @VatPercent,
 --ExcludedCountryCount=@ExcludedCountryCount,
 --VatID=@VatID
 --FROM [TWO].[dbo].IV00101 A  
 --join [TWO].[dbo].IV00102 B   
 --on A.ITEMNMBR=b.ITEMNMBR  
 --where A.ITEMNMBR=@ItemCode  
 --AND B.LOCNCODE=''  


 DECLARE @Query nvarchar(max)
 --DECLARE @ParmDefinition NVARCHAR(500);

	--/* Build the SQL string once */
	--SET @Query = N'SELECT top 1   
 --A.CURRCOST AS CurrentPrice,  
 --A.ITEMNMBR as ItemCode,  
 --A.ITEMDESC as ItemDescription,  
 --B.QTYONHND as QuantityOnHand,  
 --B.ATYALLOC as QuantityAllocated,  
 --AvailableQuantity= B.QTYONHND-B.ATYALLOC  ,
 --VatPercent = '+@VatPercent+',
 --ExcludedCountryCount='+@ExcludedCountryCount+',
 --VatID='+@VatID+'
	--FROM '+@UniformDB+'.[dbo].IV00101 A  
 --join '+@UniformDB+'.[dbo].IV00102 B   
 --on A.ITEMNMBR=b.ITEMNMBR  
 --where A.ITEMNMBR='+@ItemCode+'  
 --andLOCNCODE=''''' ;

 declare @VatPercent2 nvarchar(500)
  declare @ExcludedCountryCount2 nvarchar(500)
   declare @VatID2 nvarchar(500)

 select @VatPercent2=cast( @VatPercent as nvarchar(50))

  select @ExcludedCountryCount2=cast( @ExcludedCountryCount as nvarchar(50))
    select @VatID2=cast( @VatID as nvarchar(50))

	/* Build the SQL string once */
	SET @Query = N'SELECT top 1   
 A.CURRCOST AS CurrentPrice,  
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
 and B.LOCNCODE=''''' ;
 print @query
	 EXECUTE sp_executesql @Query;
end
GO

alter PROCEDURE [dbo].[sp_GetAppDropdown]    
 @DropdownType int    
 ,@ReferenceId int    
AS    
BEGIN    
 SET NOCOUNT ON;    
 IF @DropdownType = 1    
 BEGIN    
  SELECT trl.RoleId AS SValue    
   ,trl.RoleName AS SText    
  FROM tblRole trl    
  WHERE trl.IsActive = 1 AND trl.IsDeleted = 0    
  ORDER BY trl.RoleName    
 END    
 IF @DropdownType = 2    
 BEGIN    
  SELECT tcc.CostCenterId AS SValue    
   ,tcc.CostCenterName AS SText    
  FROM tblCostCenterMaster tcc    
  WHERE tcc.IsActive = 1 AND tcc.IsDeleted = 0    
  ORDER BY tcc.CostCenterName    
 END    
 IF @DropdownType = 3    
 BEGIN    
  SELECT tgt.GenderTypeId AS SValue    
   ,tgt.GenderTypeName AS SText    
  FROM tblGenderTypeMaster tgt    
  WHERE tgt.IsActive = 1 AND tgt.IsDeleted = 0    
  ORDER BY tgt.GenderTypeName    
 END    
 IF @DropdownType = 4    
 BEGIN    
  SELECT tg.GradeId AS SValue    
   --,tg.GradeName AS SText    
  -- ,CONCAT_WS(' - ',tg.GradeName, tgt.GenderTypeName)  AS SText    
  ,case when tgt.GenderTypeName is null then  isnull(tg.GradeName,'') else (isnull(tg.GradeName,'') +' - '+isnull(tgt.GenderTypeName,'')) end AS SText    
  FROM tblGradeMaster tg    
  INNER JOIN tblCostCenterMaster tcc    
   ON tcc.CostCenterId = tg.CostCenterId    
  LEFT JOIN tblGenderTypeMaster tgt    
   ON tgt.GenderTypeId = tg.GenderTypeId    
  WHERE tg.IsActive = 1 AND tg.IsDeleted = 0    
   AND tg.CostCenterId = CASE WHEN @ReferenceId > 0 THEN @ReferenceId ELSE tg.CostCenterId END     
  ORDER BY tg.SequenceNo    ASC
 END    
 IF @DropdownType = 5    
 BEGIN    
  SELECT tc.CountryId AS SValue    
   --,CONCAT_WS(' - ',tc.CountryName, tc.CountryCode)  AS SText   
   ,tc.CountryName  AS SText   
  FROM tblCountryMaster tc      
  WHERE tc.IsActive = 1 AND tc.IsDeleted = 0       
  ORDER BY tc.CountryName    
 END    
 IF @DropdownType = 6    
 BEGIN    
  SELECT dt.DocumentTypeId AS SValue    
   ,dt.DocumentTypeName  AS SText    
  FROM tblDocumentTypeMaster dt      
  WHERE dt.IsActive = 1 AND dt.IsDeleted = 0       
  ORDER BY dt.DocumentTypeName    
 END   
 IF @DropdownType = 7    
 BEGIN    
  SELECT tp.ParentId AS SValue    
   ,tp.ParentCode+' - '+tp.FatherName  AS SText    
  FROM tblParent tp      
  WHERE tp.IsActive = 1 AND tp.IsDeleted = 0       
  ORDER BY tp.ParentCode    
 END   
 IF @DropdownType = 8    
 BEGIN    
  SELECT tgs.SectionId AS SValue    
   ,tgs.SectionName  AS SText    
  FROM tblSection tgs     
  WHERE tgs.IsActive = 1 AND tgs.IsDeleted = 0       
  ORDER BY tgs.SectionName    
 END   
 IF @DropdownType = 9    
 BEGIN    
  SELECT tss.StudentStatusId AS SValue    
   ,tss.StatusName  AS SText    
  FROM tblStudentStatus tss      
  WHERE tss.IsActive = 1 AND tss.IsDeleted = 0       
  ORDER BY tss.StatusName    
 END   
 IF @DropdownType = 10    
 BEGIN    
  SELECT trm.TermId AS SValue    
   ,trm.TermName  AS SText    
  FROM tblTermMaster trm    
  WHERE trm.IsActive = 1 AND trm.IsDeleted = 0       
  ORDER BY trm.TermName    
 END   
 IF @DropdownType = 11    
 BEGIN    
  SELECT trm.BranchId AS SValue    
   ,trm.BranchName  AS SText    
  FROM tblBranchMaster trm    
  WHERE trm.IsActive = 1 AND trm.IsDeleted = 0       
  ORDER BY trm.BranchName    
 END   
 IF @DropdownType = 12    
 BEGIN    
  SELECT trm.SchoolAcademicId AS SValue    
   ,trm.AcademicYear  AS SText    
  FROM tblSchoolAcademic trm    
  WHERE  trm.IsDeleted = 0 and trm.IsActive=1 --AND trm.SchoolId=@ReferenceId     
 END  
 IF @DropdownType = 13    
 BEGIN    
  SELECT FeeTypeId AS SValue    
  ,FeeTypeName  AS SText    
  FROM tblFeeTypeMaster    
  WHERE  IsDeleted = 0 AND IsActive=1    
 END   
 IF @DropdownType = 14    
 BEGIN    
  SELECT DiscountRuleId AS SValue    
  ,DiscountRuleDescription  AS SText    
  FROM tblDiscountRules  
  WHERE  IsDeleted = 0 AND IsActive=1    
 END  
 IF @DropdownType = 15    
 BEGIN    
  SELECT tp.StudentId AS SValue    
   ,tp.StudentCode  AS SText    
  FROM tblStudent tp      
  WHERE tp.IsActive = 1 AND tp.IsDeleted = 0       
  ORDER BY tp.StudentCode    
 END 
END