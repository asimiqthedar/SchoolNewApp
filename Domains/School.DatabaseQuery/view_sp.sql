USE [als_dev]
GO
/****** Start: Script Date: 6/28/2024 4:22:39 PM ******/
CREATE PROCEDURE [dbo].[sp_GetAppDropdown]    
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
		,CONCAT_WS(' - ',tg.GradeName, tgt.GenderTypeName)  AS SText    
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
GO

CREATE proc [dbo].[SP_GetVATDetail]
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

CREATE PROCEDURE [dbo].[sp_GetInvoice]          
 @InvoiceId int = 0          
AS          
BEGIN          
 SET NOCOUNT ON;           
 SELECT tis.InvoiceId  
  ,tis.InvoiceNo  
  ,tis.[Status]  
  ,tis.ParentID 
  ,tis.CustomerName
  ,tis.PublishedBy  
  ,tis.InvoiceDate  
  ,tis.CreditNo  
  ,tis.CreditReason  
  ,tis.CustomerName  
  ,tis.UpdateDate  
  ,tis.UpdateBy  
  ,tis.InvoiceType
	,InvoiceRefNo=isnull(tis.InvoiceRefNo,0)
	,ItemSubtotal
	,InvoiceType=isnull(InvoiceType,'Invoice')
 FROM INV_InvoiceSummary tis            
 WHERE tis.InvoiceId = CASE WHEN @InvoiceId > 0 THEN @InvoiceId ELSE tis.InvoiceId END           
  AND tis.IsDeleted = 0          
 ORDER BY tis.InvoiceId          
END   
GO

/****** End : Script Date: 6/28/2024 4:22:39 PM ******/


/****** Object:  View [dbo].[vw_Student]    Script Date: 6/22/2024 4:22:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_Student]
AS
SELECT       
		stu.StudentId      
		,stu.StudentCode      
		,stu.StudentImage      
		,stu.ParentId
		,stu.StudentName      
		,stu.StudentArabicName      
		,stu.StudentEmail      
		,stu.DOB      
		,stu.IqamaNo      
		,stu.NationalityId      
		,tc.CountryName      
		,stu.GenderId      
		,tgt.GenderTypeName      
		,stu.AdmissionDate      
		,stu.CostCenterId      
		,tcc.CostCenterName      
		,stu.GradeId      
		,tg.GradeName      
		,stu.SectionId      
		,ts.SectionName      
		,stu.PassportNo      
		,stu.PassportExpiry      
		,stu.Mobile      
		,stu.StudentAddress      
		,stu.StudentStatusId      
		,tss.StatusName      
		,Fees=isnull(stu.Fees  ,0)    
		,stu.IsGPIntegration      
		,stu.WithdrawDate      
		,WithdrawAt=isnull(stu.WithdrawAt ,0)    
		,tt1.TermName AS WithdrawAtTermName      
		,stu.WithdrawYear      
		,TermId=isnull(stu.TermId  ,0)    
		,tt.TermName      
		,stu.AdmissionYear      
		,PrinceAccount=isnull(stu.PrinceAccount  ,0)    
		,stu.IsActive
		,stu.IsDeleted		

		,tp.ParentCode
		,tp.FatherName
		,tp.FatherArabicName
		,tp.FatherMobile
		,tp.FatherEmail
		,tp.FatherIqamaNo

		,tp.MotherName
		,tp.MotherArabicName
		,tp.MotherMobile
		,tp.MotherEmail		
		,tp.MotherIqamaNo

	FROM tblStudent stu       
	INNER JOIN tblParent tp      
		ON tp.ParentId = stu.ParentId      
	INNER JOIN tblParent tm      
		ON tm.ParentId = stu.ParentId      
	LEFT JOIN tblCountryMaster tc      
		ON tc.CountryId = stu.NationalityId      
	LEFT JOIN tblGenderTypeMaster tgt      
		ON tgt.GenderTypeId = stu.GenderId      
	LEFT JOIN tblCostCenterMaster tcc      
		ON tcc.CostCenterId = stu.CostCenterId      
	LEFT JOIN tblGradeMaster tg      
		ON tg.GradeId = stu.GradeId      
	LEFT JOIN tblSection ts      
		ON ts.SectionId = stu.SectionId      
	LEFT JOIN tblStudentStatus tss      
		ON tss.StudentStatusId = stu.StudentStatusId      
	LEFT JOIN tblTermMaster tt      
		ON tt.TermId=stu.TermId      
	LEFT JOIN tblTermMaster tt1      
		ON tt1.TermId=stu.WithdrawAt  
GO
/****** Object:  StoredProcedure [dbo].[sp_AdjustGrade]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_AdjustGrade]
	@GradeId int
	,@Value int
	,@SequenceNo int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF @Value=-1
			BEGIN
				UPDATE tblGradeMaster SET SequenceNo=SequenceNo+1 
					WHERE GradeId =(SELECT GradeId FROM tblGradeMaster 
									WHERE SequenceNo=@SequenceNo-1)
				UPDATE tblGradeMaster SET SequenceNo=SequenceNo-1 
					WHERE GradeId =@GradeId
			END
			ELSE
			BEGIN
				UPDATE tblGradeMaster SET SequenceNo=SequenceNo-1
					WHERE GradeId =(SELECT GradeId FROM tblGradeMaster 
									WHERE SequenceNo=@SequenceNo+1)
				UPDATE tblGradeMaster SET SequenceNo=SequenceNo+1 
					WHERE GradeId =@GradeId
			END
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
/****** Object:  StoredProcedure [dbo].[sp_ApproveNotification]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_ApproveNotification]              
 @LoginUserId int                
 ,@NotificationIds nvarchar(max)    ='ALL'          
as            
begin              
 BEGIN TRY                
  BEGIN TRANSACTION TRANS1                
    
                
 select distinct isnull(country,nationality) As country into #OpenApplyCountry from [OpenApplyStudents] z              
        
 insert into #OpenApplyCountry        
 select distinct isnull(country,nationality) from OpenApplyParents z         
              
 delete t              
 from #OpenApplyCountry t              
 inner join tblCountryMaster z              
 on t.country COLLATE SQL_Latin1_General_CP1_CI_AS =z.CountryName              
              
 delete from #OpenApplyCountry where country is NULL              
                
 --select '#OpenApplyCountry' as AA, * from #OpenApplyCountry              
                
 if exists(select 1 from #OpenApplyCountry)              
 begin              
  insert into tblCountryMaster(CountryName,CountryCode,IsActive,IsDeleted,UpdateDate,UpdateBy)              
  select country, '' , 1,0, getdate(),@LoginUserId from  #OpenApplyCountry              
 end              
               
  ---End: Master Data- Country            
              
  create table #ApprovableNotification    
  (    
  NotificationId bigint,  
   RecordId nvarchar(400),    
   RecordType nvarchar(400)    
  )    
    
 if(@NotificationIds ='ALL')    
 begin    
  insert into #ApprovableNotification         
  select     
   distinct notific.NotificationId, notific.RecordId,notific.RecordType     
  from                
  [tblNotification] notific      
 end    
 else    
 begin    
  insert into #ApprovableNotification         
  select     
   distinct notific.NotificationId,  notific.RecordId,notific.RecordType     
  from                
  [tblNotification] notific              
  inner join               
  (              
   SELECT cast(value as int)as NotificationId              
   FROM STRING_SPLIT(@NotificationIds, ',')              
   WHERE RTRIM(value) <> ''              
  )t               
  on notific.NotificationId= t.NotificationId         
 end         
          
  --Start : Work for Student              
              
 select *               
 into #student              
 from               
 (              
  select              
   distinct              
   student_id=os.student_id              
   ,case when gender='Male' then 1 else 2 end GenderId              
   --,GradeId=gm.GradeId              
   --,CostCenterId=gm.CostCenterId              
   ,GradeId=1              
   ,CostCenterId=1              
   ,SchoolId=1              
   ,SectionId=1              
   ,StudentName = (ltrim(rtrim(os.first_name))+ ' '+ ltrim(rtrim(os.last_name)))         
   ,StudentArabicName = ltrim(rtrim(os.other_name))      
   ,StudentEmail = ltrim(rtrim( isnull(os.[email],'')))      
   ,DOB = cast(os.birth_date as date)                 
   ,AdmissionDate = cast(os.enrolled_date as date)              
   ,StudentAddress = os.full_address              
   ,StudentStatusId =1         
   ,WithdrawDate = os.withdrawn_date              
   ,WithdrawYear = datepart(year, cast(os.withdrawn_date as date))              
   ,AdmissionYear = os.admitted_date              
   ,IqamaNo=os.IqamaNo  --Update filed when new chnages done              
   --,NationalityId=isnull(tc.CountryId,1)    --Update filed when new chnages done              
   ,NationalityId=999999              
   ,PassportNo=isnull(passport_id,'')  --Update filed when new chnages done              
   ,PassportExpiry=null  --Update filed when new chnages done              
   ,Mobile=os.mobile_phone  --Update filed when new chnages done              
   ,PrinceAccount=os.PrinceAccount  --Update filed when new chnages done                
              
   ,os.grade              
   ,country=isnull(os.country,os.nationality)        
   ,os.p_id_school_parent_id        
  from               
  [dbo].[OpenApplyStudents] os               
  inner join  #ApprovableNotification  notific                
  on os.id=notific.RecordId           
  where notific.RecordType='Student'               
  and os.id is not null               
  and os.[status]='enrolled'              
  and os.student_id is not null               
 )t              
              
 update os              
 set              
  os.GradeId=gm.GradeId              
  ,os.CostCenterId=gm.CostCenterId              
 from #student os              
 inner join tblGradeMaster gm on os.grade COLLATE SQL_Latin1_General_CP1_CI_AS=gm.GradeName              
              
 update os              
 set              
  os.NationalityId=tc.CountryId              
 from #student os              
 inner join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName              
                
 --End : Work for Student              
              
  --Work for Parent              
              
  --Start : Work for Father              
              
   select *         
   into #ParentInfo          
   from (        
    select              
     distinct              
     --ParentId               
     ParentCode =cast( os.p_id_school_parent_id as nvarchar(100))              
     ,ParentImage =cast( '' as nvarchar(100))              
     ,FatherName =cast( '' as nvarchar(100))              
     ,FatherArabicName =cast( '' as nvarchar(100))              
     ,FatherNationalityId=999999              
     ,FatherMobile =cast( '' as nvarchar(50))              
     ,FatherEmail=cast( '' as nvarchar(100))              
     ,IsFatherStaff =0                
               
     ,MotherName =cast( '' as nvarchar(100))              
     ,MotherArabicName =cast( '' as nvarchar(100))              
     ,MotherNationalityId =999999              
     ,MotherMobile =cast( '' as nvarchar(50))              
     ,MotherEmail =cast( '' as nvarchar(100))              
     ,IsMotherStaff =0               
     ,FatherIqamaNo =cast( '' as nvarchar(100))              
     ,MotherIqamaNo =cast( '' as nvarchar(100))              
     ,OpenApplyFatherId =cast( '' as nvarchar(100))              
     ,OpenApplyMotherId =cast( '' as nvarchar(100))              
     ,OpenApplyStudentId=os.student_id              
                 
     ,country=cast( '' as nvarchar(100))               
             
    from              
     #student os            
   )t        
        
  --If more than 1 student for a oarent then delete duplicate        
          
        
        
  select *               
  into #ParentFather              
  from              
  (              
  select              
   distinct              
   --ParentId               
   ParentCode =os.id              
   ,        
   ParentImage =''              
   ,FatherName =(ltrim(rtrim(os.[first_name]))+' '+ltrim(rtrim(os.[last_name])))         
   ,FatherArabicName =os.[other_name]              
                 
   ,FatherMobile =os.mobile_phone              
   ,FatherEmail=ltrim(rtrim(os.[email]))      
   ,IsFatherStaff =0               
              
   ,FatherIqamaNo =os.IqamaNo                 
   ,OpenApplyFatherId =os.id                  
   ,OpenApplyStudentId=os.student_id              
                 
   ,country=isnull(os.country,os.nationality)         
               
  from               
  [OpenApplyParents] os                
  inner join  #ApprovableNotification  notific  on os.id=notific.RecordId               
  inner join #student stu on os.student_id=stu.student_id               
  --left join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName              
  where notific.RecordType='Father'               
  and os.id is not null               
  )t           
          
  ---------------              
              
  update os              
  set              
   --os.ParentCode =tc.ParentCode              
 --,        
   os.ParentImage =tc.ParentImage              
   ,os.FatherName =tc.FatherName              
   ,os.FatherArabicName =tc.FatherArabicName              
   ,os.FatherMobile =tc.FatherMobile              
   ,os.FatherEmail=tc.FatherEmail              
   ,os.IsFatherStaff =tc.IsFatherStaff               
                 
   ,FatherIqamaNo =tc.FatherIqamaNo                 
   ,OpenApplyFatherId =tc.OpenApplyFatherId                  
   ,OpenApplyStudentId=os.OpenApplyStudentId           
   ,country=tc.country        
              
  from #ParentInfo os              
  inner join #ParentFather tc on os.OpenApplyStudentId =tc.OpenApplyStudentId              
          
  update os              
  set              
   os.FatherNationalityId=tc.CountryId              
  from #ParentInfo os              
  inner join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName            
          
  ---Update Father record if father record is not available              
               
  select *               
  into #ParentFatherOther              
  from               
  (              
   select               
   Row_number()Over(partition by OpenApplyStudentId order by OpenApplyStudentId) as RN,              
   * from               
   (              
    select                
     ParentCode =os.id              
     ,ParentImage =''              
     ,FatherName =(ltrim(rtrim(os.[first_name]))+' '+ltrim(rtrim(os.[last_name])))             
     ,FatherArabicName =os.[other_name]              
     ,FatherMobile =os.mobile_phone              
     ,FatherEmail=ltrim(rtrim(os.[email]))              
     ,IsFatherStaff =0                
                  
     ,FatherIqamaNo =os.IqamaNo                 
     ,OpenApplyFatherId =os.id                  
     ,OpenApplyStudentId=os.student_id              
                 
     ,country=isnull(os.country,os.nationality)        
    from               
    [OpenApplyParents] os                
    inner join  #ApprovableNotification  notific  on os.id=notific.RecordId               
   inner join #student stu on os.student_id=stu.student_id               
    --left join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName              
    where notific.RecordType in               
    (              
     'Brother', 'Consultant/recruiter','Grandfather','Legal guardian','Other guardian','Stepfather','Uncle'              
    )                  
   )t              
  )z              
  where z.RN=1 -- get only 1 record               
              
           
          
  update os              
  set              
   --os.ParentCode =tc.ParentCode              
   --,        
   os.ParentImage =tc.ParentImage              
   ,os.FatherName =tc.FatherName      
   ,os.FatherArabicName =tc.FatherArabicName              
   ,os.FatherMobile =tc.FatherMobile              
   ,os.FatherEmail=tc.FatherEmail              
   ,os.IsFatherStaff =tc.IsFatherStaff               
                 
   ,FatherIqamaNo =tc.FatherIqamaNo                 
   ,OpenApplyFatherId =tc.OpenApplyFatherId                  
   ,OpenApplyStudentId=os.OpenApplyStudentId              
 ,country=tc.country        
        
  from #ParentInfo os              
  inner join #ParentFatherOther tc on os.OpenApplyStudentId =tc.OpenApplyStudentId              
  where os.OpenApplyFatherId is null              
              
  update os              
  set              
   os.FatherNationalityId=tc.CountryId              
  from #ParentInfo os              
  inner join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName              
              
           
  --------------Get mother information              
              
  select *               
   into #ParentMother              
  from               
  (        
   select               
   Row_number()Over(partition by OpenApplyStudentId order by OpenApplyStudentId) as RN,              
   * from               
   (              
    select                
     ParentCode =os.id              
     ,ParentImage =''                  
              
     ,MotherName =(ltrim(rtrim(os.[first_name]))+' '+ltrim(rtrim(os.[last_name])))              
     ,MotherArabicName =os.[other_name]                   
     ,MotherMobile =os.mobile_phone              
     ,MotherEmail =ltrim(rtrim(os.[email]))        
     ,IsMotherStaff =0               
     ,MotherIqamaNo =os.IqamaNo                 
     ,OpenApplyMotherId =os.id              
     ,OpenApplyStudentId=os.student_id              
     ,country=isnull(os.country,os.nationality)        
              
    from               
    [OpenApplyParents] os                
    inner join  #ApprovableNotification  notific  on os.id=notific.RecordId              
    inner join #student stu on os.student_id=stu.student_id               
    --left join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName              
    where notific.RecordType in               
    (              
     'Mother'              
    )              
   )t              
  )z              
  where z.RN=1 -- get only 1 record               
             
  update os              
  set              
   --os.ParentCode =tc.ParentCode              
   --,        
   os.ParentImage =tc.ParentImage              
              
   ,os.MotherName =tc.MotherName              
   ,os.MotherArabicName =tc.MotherArabicName              
   ,os.MotherMobile =tc.MotherMobile              
   ,os.MotherEmail=tc.MotherEmail              
   ,os.IsMotherStaff =tc.IsMotherStaff               
                 
   ,MotherIqamaNo =tc.MotherIqamaNo                 
   ,OpenApplyMotherId =tc.OpenApplyMotherId                  
   ,OpenApplyStudentId=os.OpenApplyStudentId         
   ,country=tc.country        
              
  from #ParentInfo os              
  inner join #ParentMother tc on os.OpenApplyStudentId =tc.OpenApplyStudentId              
                
  update os              
  set              
   os.MotherNationalityId=tc.CountryId              
  from #ParentInfo os              
  inner join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName              
              
  --------------Get mother reference information other than mother              
              
  select *               
   into #ParentMotherOther              
  from               
  (              
   select               
   Row_number()Over(partition by OpenApplyStudentId order by OpenApplyStudentId) as RN,              
   * from               
   (              
    select                
     ParentCode =os.id              
     ,ParentImage =''                  
              
     ,MotherName =(ltrim(rtrim(os.[first_name]))+' '+ltrim(rtrim(os.[last_name])))              
     ,MotherArabicName =os.[other_name]              
                  
     ,MotherMobile =os.mobile_phone              
     ,MotherEmail =ltrim(rtrim(os.[email]))                
     ,IsMotherStaff =0               
     ,MotherIqamaNo =os.IqamaNo                 
     ,OpenApplyMotherId =os.id              
     ,OpenApplyStudentId=os.student_id              
     ,country=isnull(os.country,os.nationality)        
    from               
    [OpenApplyParents] os                
    inner join  #ApprovableNotification  notific  on os.id=notific.RecordId               
    inner join #student stu on os.student_id=stu.student_id               
    --left join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName              
    where notific.RecordType in               
    (              
     'Aunt','Consultant/recruiter','Grandmother','Legal guardian','Other guardian','Sister','Stepmother'              
    )              
    and os.id is not null               
   )t              
  )z              
  where z.RN=1 -- get only 1 record           
          
  update os              
  set              
   --os.ParentCode =tc.ParentCode              
   --,        
   os.ParentImage =tc.ParentImage              
              
   ,os.MotherName =tc.MotherName              
   ,os.MotherArabicName =tc.MotherArabicName              
   ,os.MotherMobile =tc.MotherMobile              
   ,os.MotherEmail=tc.MotherEmail        
   ,os.IsMotherStaff =tc.IsMotherStaff               
                 
   ,MotherIqamaNo =tc.MotherIqamaNo                 
   ,OpenApplyMotherId =tc.OpenApplyMotherId                  
   ,OpenApplyStudentId=os.OpenApplyStudentId         
   ,country=tc.country        
              
  from #ParentInfo os              
  inner join #ParentMotherOther tc on os.OpenApplyStudentId =tc.OpenApplyStudentId              
  where os.OpenApplyMotherId is null              
                
  update os              
  set              
   os.MotherNationalityId=tc.CountryId              
  from #ParentInfo os              
  inner join tblCountryMaster tc on os.country COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName              
              
  -----------------------              
                 
  -----Start: Student update              
  MERGE tblStudent AS TARGET              
  USING #student AS SOURCE               
  ON (cast( TARGET.StudentCode as nvarchar(100)) COLLATE SQL_Latin1_General_CP1_CI_AS= cast(SOURCE.student_id as nvarchar(100)))               
  --When records are matched, update the records if there is any change              
  WHEN MATCHED --AND TARGET.ProductName <> SOURCE.ProductName OR TARGET.Rate <> SOURCE.Rate               
  THEN UPDATE               
  SET               
   TARGET.StudentName = SOURCE.StudentName,               
   TARGET.StudentArabicName = SOURCE.StudentArabicName,              
   TARGET.StudentEmail = isnull(SOURCE.StudentEmail,''),              
   TARGET.DOB = SOURCE.DOB,              
   TARGET.GenderId = SOURCE.GenderId,              
   TARGET.AdmissionDate = isnull(SOURCE.AdmissionDate, getdate()),              
   TARGET.StudentAddress =isnull( SOURCE.StudentAddress,''),              
   TARGET.StudentStatusId = SOURCE.StudentStatusId,              
   TARGET.WithdrawDate =SOURCE.WithdrawDate,              
   TARGET.WithdrawYear = SOURCE.WithdrawYear,              
   TARGET.AdmissionYear =SOURCE.AdmissionYear,              
   TARGET.GradeId =SOURCE.GradeId,              
   TARGET.CostCenterId =SOURCE.CostCenterId,              
   TARGET.SectionId =SOURCE.SectionId,              
   TARGET.IqamaNo =SOURCE.IqamaNo,              
   TARGET.NationalityId =SOURCE.NationalityId,              
   TARGET.PassportNo =SOURCE.PassportNo,              
   TARGET.PassportExpiry =SOURCE.PassportExpiry,              
   TARGET.Mobile =SOURCE.Mobile,              
   TARGET.PrinceAccount =SOURCE.PrinceAccount,              
   TARGET.p_id_school_parent_id =SOURCE.p_id_school_parent_id        
                
   --When no records are matched, insert the incoming records from source table to target table              
   WHEN NOT MATCHED BY TARGET               
              
   THEN INSERT               
   (              
    StudentCode ,StudentName,StudentArabicName,StudentEmail ,DOB ,GenderId ,              
    AdmissionDate ,StudentAddress ,StudentStatusId ,WithdrawDate ,WithdrawYear,AdmissionYear,              
    GradeId ,CostCenterId ,SectionId ,IqamaNo ,NationalityId ,PassportNo,PassportExpiry ,              
    Mobile ,PrinceAccount , p_id_school_parent_id,             
    IsActive,IsDeleted,UpdateDate,UpdateBy,              
    IsGPIntegration,TermId         
   )               
   VALUES               
   (               
    SOURCE.student_id,SOURCE.StudentName,isnull( SOURCE.StudentArabicName,''),isnull(SOURCE.StudentEmail,''),              
    SOURCE.DOB,SOURCE.GenderId,              
    isnull(SOURCE.AdmissionDate, getdate()),isnull( SOURCE.StudentAddress,''),SOURCE.StudentStatusId,              
    SOURCE.WithdrawDate,SOURCE.WithdrawYear,SOURCE.AdmissionYear,              
    SOURCE.GradeId,SOURCE.CostCenterId,SOURCE.SectionId,SOURCE.IqamaNo,SOURCE.NationalityId,SOURCE.PassportNo,SOURCE.PassportExpiry,              
    SOURCE.Mobile,SOURCE.PrinceAccount,      source.p_id_school_parent_id,        
    1,0, getdate(),@LoginUserId,              
    0,1              
   );              
  ---End: Student Update              
              
  delete from #ParentInfo where ltrim(rtrim( ParentCode))=''        
          
  delete from #ParentInfo where ltrim(rtrim( ParentCode))<>''         
 and   ltrim(rtrim( FatherName))=''        
 and   ltrim(rtrim( MotherName))=''        
          
  --select '#ParentInfo' as AA, * from #ParentInfo        
        
   select *         
 into #ParentInfo2        
   from (        
   select * from         
   (        
  select ROW_NUMBER() over(partition by ParentCode order by ParentCode)as RN2, * from   #ParentInfo        
        
  )t        
 where RN2=1        
 )z        
        
 --select 'parney info'AA , ROW_NUMBER() over(partition by ParentCode order by ParentCode)as RN, * from   #ParentInfo2        
        
               
  MERGE tblParent AS TARGET              
  USING #ParentInfo2 AS SOURCE               
  ON               
  (              
  cast( TARGET.ParentCode as nvarchar(100)) COLLATE SQL_Latin1_General_CP1_CI_AS= cast(SOURCE.ParentCode as nvarchar(100))              
  --and TARGET.OpenApplyStudentId=   cast( SOURCE.OpenApplyStudentId as bigint)              
  )               
               
  --When records are matched, update the records if there is any change              
  WHEN MATCHED --AND TARGET.ProductName <> SOURCE.ProductName OR TARGET.Rate <> SOURCE.Rate               
  THEN UPDATE               
  SET               
               
  --TARGET.ParentCode=      SOURCE.ParentCode ,              
  TARGET.ParentImage=      SOURCE.ParentImage              
  ,TARGET.FatherName=      SOURCE.FatherName              
  ,TARGET.FatherArabicName=    SOURCE.FatherArabicName              
  ,TARGET.FatherNationalityId=    SOURCE.FatherNationalityId              
  ,TARGET.FatherMobile=     SOURCE.FatherMobile            
  ,TARGET.FatherEmail=      SOURCE.FatherEmail              
  ,TARGET.IsFatherStaff=     SOURCE.IsFatherStaff              
                       
  ,TARGET.MotherName=      SOURCE.MotherName              
  ,TARGET.MotherArabicName=    SOURCE.MotherArabicName              
  ,TARGET.MotherNationalityId=    SOURCE.MotherNationalityId              
  ,TARGET.MotherMobile=     SOURCE.MotherMobile              
  ,TARGET.MotherEmail=      SOURCE.MotherEmail              
  ,TARGET.IsMotherStaff=     SOURCE.IsMotherStaff              
  ,TARGET.FatherIqamaNo=     SOURCE.FatherIqamaNo              
  ,TARGET.MotherIqamaNo=     SOURCE.MotherIqamaNo              
               
  ,TARGET.OpenApplyFatherId=  cast(SOURCE.OpenApplyFatherId as bigint)              
  ,TARGET.OpenApplyMotherId=   cast( SOURCE.OpenApplyMotherId as bigint)              
  ,TARGET.OpenApplyStudentId=   cast( SOURCE.OpenApplyStudentId as bigint)              
              
  --When no records are matched, insert the incoming records from source table to target table              
  WHEN NOT MATCHED BY TARGET               
              
  THEN INSERT               
  (              
   ParentCode,              
   ParentImage,FatherName,FatherArabicName,FatherNationalityId,FatherMobile,FatherEmail,IsFatherStaff              
   ,MotherName,MotherArabicName,MotherNationalityId,MotherMobile,MotherEmail,IsMotherStaff              
   ,FatherIqamaNo,MotherIqamaNo,OpenApplyFatherId,OpenApplyMotherId,OpenApplyStudentId,              
   IsActive,IsDeleted,UpdateDate,UpdateBy              
  )               
  VALUES               
  (               
   SOURCE.ParentCode              
   ,SOURCE.ParentImage,SOURCE.FatherName,SOURCE.FatherArabicName,SOURCE.FatherNationalityId,SOURCE.FatherMobile,SOURCE.FatherEmail,SOURCE.IsFatherStaff              
   ,SOURCE.MotherName,SOURCE.MotherArabicName,SOURCE.MotherNationalityId,SOURCE.MotherMobile,SOURCE.MotherEmail,SOURCE.IsMotherStaff              
   ,SOURCE.FatherIqamaNo,SOURCE.MotherIqamaNo,SOURCE.OpenApplyFatherId,SOURCE.OpenApplyMotherId,SOURCE.OpenApplyStudentId              
   ,1,0, getdate(),@LoginUserId              
  );              
              
  ----------UPdate parent Id              
  update stu              
  set              
   stu.ParentId=par.ParentId              
  from tblStudent stu              
  inner join tblParent par              
  on stu.p_id_school_parent_id COLLATE SQL_Latin1_General_CP1_CI_AS=cast(par.ParentCode    as nvarchar(500))          
              
              
  --Update selected notification as approved              
              
  --update notific              
  --set IsApproved=1              
  --from                
  -- [tblNotification] notific              
  -- inner join #ApprovableNotification app              
  -- on notific.NotificationId=app.NotificationId       
        
 delete notific       
 from [tblNotification] notific              
 inner join #ApprovableNotification app              
 on notific.NotificationId=app.NotificationId           
              
 select notific.NotificationGroupId, count(1) as NotificationGroupCount  into #notificationGroupDetail      
 from tblNotificationGroupDetail notific              
 inner join #ApprovableNotification app              
 on notific.TableRecordId=app.NotificationId        
 group by notific.NotificationGroupId      
      
 update t       
 set      
  t.NotificationCount=t.NotificationCount-isnull(t2.NotificationGroupCount,0)      
 from tblNotificationGroup t      
 inner join #notificationGroupDetail t2 on t.NotificationGroupId=t2.NotificationGroupId      
      
 delete notific       
 from tblNotificationGroupDetail notific              
 inner join #ApprovableNotification app              
 on notific.TableRecordId=app.NotificationId        
               
  COMMIT TRAN TRANS1                
  SELECT 0 AS Result, 'Saved' AS Response    
    
  
  --declare @NotificationIds nvarchar(max)='1,2,3,4,5,6,7,8,9,10,2839,2840,2841,2842,2843,2844,2845,2846,2847,2848'              
              
  IF OBJECT_ID('tempdb.dbo.#ApprovableNotification', 'U') IS NOT NULL              
   DROP TABLE #ApprovableNotification;               
              
  IF OBJECT_ID('tempdb.dbo.#student', 'U') IS NOT NULL              
   DROP TABLE #student;               
              
  IF OBJECT_ID('tempdb.dbo.#OpenApplyCountry', 'U') IS NOT NULL              
   DROP TABLE #OpenApplyCountry;               
              
  IF OBJECT_ID('tempdb.dbo.#student', 'U') IS NOT NULL              
   DROP TABLE #student;               
              
  IF OBJECT_ID('tempdb.dbo.#ParentInfo', 'U') IS NOT NULL              
   DROP TABLE #ParentInfo;               
              
  IF OBJECT_ID('tempdb.dbo.#ParentFather', 'U') IS NOT NULL              
   DROP TABLE #ParentFather;               
              
  IF OBJECT_ID('tempdb.dbo.#ParentFatherOther', 'U') IS NOT NULL              
   DROP TABLE #ParentFatherOther;               
              
  IF OBJECT_ID('tempdb.dbo.#ParentMother', 'U') IS NOT NULL              
   DROP TABLE #ParentMother;               
                
  IF OBJECT_ID('tempdb.dbo.#ParentMotherOther', 'U') IS NOT NULL              
   DROP TABLE #ParentMotherOther;               
             
  IF OBJECT_ID('tempdb.dbo.#ParentInfo2', 'U') IS NOT NULL              
   DROP TABLE #ParentInfo2;               
  ---Start: Master Data- Country         
  
  
 END TRY                
                
 BEGIN CATCH                
           
DECLARE @ErrorMessage NVARCHAR(4000);          
  DECLARE @ErrorSeverity INT;          
  DECLARE @ErrorState INT;          
          
  SELECT           
     @ErrorMessage = ERROR_MESSAGE() + ' occurred at Line_Number: ' + CAST(ERROR_LINE() AS VARCHAR(50)),          
     @ErrorSeverity = ERROR_SEVERITY(),        
     @ErrorState = ERROR_STATE();          
          
  RAISERROR (@ErrorMessage, -- Message text.          
     @ErrorSeverity, -- Severity.          
     @ErrorState -- State.          
  );          
          
          
   ROLLBACK TRAN TRANS1                
   SELECT -1 AS Result, 'Error!' AS Response                
   EXEC usp_SaveErrorDetail                
   RETURN                
 END CATCH                
END 
GO
/****** Object:  StoredProcedure [dbo].[sp_ApproveNotificationById]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[sp_ApproveNotificationById] 1,4
CREATE PROC [dbo].[sp_ApproveNotificationById]
	@LoginUserId int=0
	,@NotificationGroupDetailId int=0
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION TRANS1
	DECLARE @TableToBeUpdate NVARCHAR(500)
	DECLARE @TableRecordId NVARCHAR(200)
	DECLARE @TableRecordColumnName nvarchar(200)
	DECLARE @NotificationAction int
	DECLARE @NotificationGroupId int
	DECLARE @NewJson NVARCHAR(MAX)
	SELECT @TableToBeUpdate=nt.ActionTable,@TableRecordColumnName=ngd.TableRecordColumnName
	,@TableRecordId=ngd.TableRecordId,@NotificationAction=NotificationAction,@NotificationGroupId=NotificationGroupId
	,@NewJson=NewValueJson
	FROM tblNotificationGroupDetail ngd
	INNER JOIN tblNotificationTypeMaster nt
		ON ngd.NotificationTypeId=nt.NotificationTypeId
	WHERE ngd.NotificationGroupDetailId=@NotificationGroupDetailId	
	DECLARE @Query NVARCHAR(MAX)
	SET @Query='UPDATE '+@TableToBeUpdate+' SET IsRejected = 0, IsApproved = 1 WHERE '+@TableRecordColumnName+'='+@TableRecordId
	--PRINT @Query
	EXEC (@Query)		
	IF @NotificationAction=3
	BEGIN
		SET @Query='UPDATE '+@TableToBeUpdate+' SET IsDeleted = 1 WHERE '+@TableRecordColumnName+'='+@TableRecordId
		--PRINT @Query
		EXEC (@Query)
	END
	
	IF (@NotificationAction=2)
	BEGIN
		DECLARE @JsonKeyVal NVARCHAR(MAX);
		DECLARE @JsonKey NVARCHAR(MAX);
		DECLARE @Sql NVARCHAR(MAX);
		DECLARE json_cursor CURSOR FOR
		SELECT [key], value
		FROM OPENJSON(@NewJson);

		OPEN json_cursor;
		FETCH NEXT FROM json_cursor INTO @JsonKey, @JsonKeyVal;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @Sql = 'UPDATE '+@TableToBeUpdate+' SET '+ @JsonKey+ ' = '''+ @JsonKeyVal+ ''' WHERE '+@TableRecordColumnName+'='+@TableRecordId+';'
			EXEC (@Sql)
			--PRINT @Sql
			FETCH NEXT FROM json_cursor INTO @JsonKey, @JsonKeyVal;
		END

		CLOSE json_cursor;
		DEALLOCATE json_cursor;
	END
	DELETE FROM tblNotificationGroupDetail WHERE NotificationGroupDetailId=@NotificationGroupDetailId
	UPDATE tblNotificationGroup SET NotificationCount = NotificationCount-1
	WHERE NotificationGroupId=@NotificationGroupId
	SELECT 0 AS Result, 'Success' AS Response
	COMMIT TRAN TRANS1
		
	END TRY
	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_ApproveNotifications]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [sp_ApproveNotifications] 1,'12,13,14,15'
--exec sp_ApproveNotificationById 1,'12,13,14,15'

CREATE PROC [dbo].[sp_ApproveNotifications]
	@LoginUserId int=0
	,@NotificationGroupDetailIds nvarchar(max)=''
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION TRANS1
	
	if(@NotificationGroupDetailIds = '')
	begin
		SELECT -1 AS Result, 'Error!' AS Response
	end
	else
	begin
		
		select 
			ngd.* , nt.NotificationType       
		into #ApprovableNotificationList         
		from          
		tblNotificationGroupDetail ngd    
		INNER JOIN tblNotificationTypeMaster nt
		ON ngd.NotificationTypeId=nt.NotificationTypeId
		inner join         
		(        
			SELECT cast(value as int)as NotificationGroupDetailId        
			FROM STRING_SPLIT(@NotificationGroupDetailIds, ',')        
			WHERE RTRIM(value) <> ''        
		)t         
		on ngd.NotificationGroupDetailId= t.NotificationGroupDetailId 
		

		DECLARE @NotificationGroupDetailId INT, @TableRecordId INT, @NotificationType NVARCHAR(100), @NotificationIds nvarchar(max)
		set @NotificationIds=''

		--Declare a cursor  
		DECLARE PrintCustomers CURSOR  
		FOR  
		SELECT NotificationGroupDetailId, NotificationType, TableRecordId 
		FROM #ApprovableNotificationList  

		--Open cursor  
		OPEN PrintCustomers  

		--Fetch the record into the variables.  
		FETCH NEXT FROM PrintCustomers INTO  
		@NotificationGroupDetailId, @NotificationType ,@TableRecordId

		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			IF (@NotificationType = 'OpenApplyRecordProcessing'  )
			BEGIN

				if(@NotificationIds = '')
				begin
					set @NotificationIds=cast(@TableRecordId as nvarchar(50))
				end
				else
				begin
					set @NotificationIds=@NotificationIds+','+cast(@TableRecordId as nvarchar(50))
				end
			END  
			else
			begin	
				exec sp_ApproveNotificationById @LoginUserId,  @NotificationGroupDetailId
			end
   
			--Fetch the next record into the variables.  
			FETCH NEXT FROM PrintCustomers INTO  
			@NotificationGroupDetailId, @NotificationType ,@TableRecordId
		END 

		--Close the cursor  
		CLOSE PrintCustomers  
  
		--Deallocate the cursor  
		DEALLOCATE PrintCustomers  

		--In the end call- sp_ApproveNotification
		if(@NotificationIds !='')
		begin
		
		set @NotificationIds=REVERSE(SUBSTRING(  REVERSE(@NotificationIds),    PATINDEX('%[A-Za-z0-9]%',REVERSE(@NotificationIds)),
    LEN(@NotificationIds) - (PATINDEX('%[A-Za-z0-9]%',REVERSE(@NotificationIds)) - 1)   ) )   
			exec sp_ApproveNotification @LoginUserId,@NotificationIds
		end

	end
	
	SELECT 0 AS Result, 'Success' AS Response
	COMMIT TRAN TRANS1
		
	END TRY
	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ClearPreviousOpenApplyNotification]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_ClearPreviousOpenApplyNotification]
as
begin
	delete from [tblNotification]
	where RecordType in ('Father','Student','Mother')

	delete from [OpenApplyStudents]
	delete from [OpenApplyParents]

end

select * from [tblNotification]
GO
/****** Object:  StoredProcedure [dbo].[sp_CreateGLEntry]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_CreateGLEntry]
@GLEntryType nvarchar(50),
@MiscId int
as 
begin
--@GLEntryType = Acedemic year Change
--Then @MiscId - School Id

--@GLEntryType = InvoiceType
--Then @MiscId - Parent Id


	if(@GLEntryType = 'AcedemicYear')
	begin
		select * from [dbo].[tblFeeStructure]
		select * from tblInvoiceTypeMaster

	end

select 1

select * from [dbo].[tblParentAccount]

end


create table [Temp_GL]
(
BACHNUMB	nvarchar(30) null
,JRNENTRY	int null
,TRXDATE	datetime null
,REFRENCE	nvarchar(62) null
,ACTNUMST	nvarchar(258) null
,ACTINDX	int	 null
,DSCRIPTN	nvarchar(62) null
,DEBITAMT	decimal(19   ,5) 
,CRDTAMNT	decimal(19   ,5) null
,SQNCLINE	decimal(19   ,5) 
,ACCTTYPE	int null
,USERID	nvarchar(30)     	     	null
,RowId	int not null
,ARDSCJVD	nvarchar(1000) null
,InterID	nvarchar(10) null
,DTA_GroupID	char null
,DTA_CodeID	char null
,ICTRX	int null
,PostingDesc	char null
,FUNLCURR_T	char null
,FUNCRIDX_T	bigint null
,XCHGRATE	decimal(18   ,7)    	null
,EXGTBLID	nvarchar(30) null
,EXCHDATE	datetime  null
,RATETPID	nvarchar(30) null
,CorrespondingUnit	nvarchar(30) null
,ORDEBITAMT	decimal(18   ,7)    	null
,ORCRDTAMNT	decimal(18   ,7)    	null

)
GO
/****** Object:  StoredProcedure [dbo].[sp_CSVParent]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CSVParent]   
AS  
BEGIN  
 SET NOCOUNT ON;   
 SELECT tp.ParentCode AS [Parent ID]
  ,tp.FatherName AS [Father Name]
  ,tp.FatherArabicName AS [Father Arabic Name]
  ,ftc.CountryName AS [Father Nationality]
  ,tp.FatherMobile  AS [Father Mobile]
  ,tp.FatherEmail  AS [Father Email]
  ,tp.FatherIqamaNo  AS [Father Iqama No]
  ,CASE WHEN tp.IsFatherStaff=1 THEN 'Yes' ELSE 'No' END  [Father Staff]
  ,tp.MotherName  AS [Mother Name]
  ,tp.MotherArabicName  AS [Mother Arabic Name]
  ,mtc.CountryName AS [Mother Nationality]
  ,tp.MotherMobile  AS [Mother Mobile]
  ,tp.MotherEmail  AS [Mother Email]
  ,tp.MotherIqamaNo  AS [Mother Iqama No]
  ,CASE WHEN tp.IsMotherStaff=1 THEN 'Yes' ELSE 'No' END  AS [Mother Staff]
  ,tpa.ReceivableAccount AS [Receivable Account]
  ,tpa.AdvanceAccount AS [Advance Account]
  ,CASE WHEN tp.IsActive=1 THEN 'Active' ELSE 'In-active' END AS [Active]  
 FROM tblParent tp   
 LEFT JOIN tblParentAccount tpa   
  ON tpa.ParentId = tp.ParentId AND tpa.IsDeleted =  0 AND tpa.IsActive = 1 
 LEFT JOIN tblCountryMaster ftc  
  ON ftc.CountryId = tp.FatherNationalityId  
 LEFT JOIN tblCountryMaster mtc  
  ON mtc.CountryId = tp.MotherNationalityId  
 WHERE tp.IsActive =  1  AND tp.IsDeleted =  0  
 ORDER BY tp.ParentCode
END
GO
/****** Object:  StoredProcedure [dbo].[sp_CSVStudent]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CSVStudent]  
AS    
BEGIN    
 SET NOCOUNT ON;     
 SELECT  stu.StudentCode AS [Student ID]  
  ,tp.ParentCode AS [Parent ID]  
  ,stu.StudentName AS [Student Name]  
  ,stu.StudentArabicName   AS [Student Arabic Name]  
  ,stu.StudentEmail  AS [Student Email   
  ,stu.DOB   AS [Date of Birth]  
  ,stu.IqamaNo   AS [Iqama No]  
  ,tc.CountryName  AS [Nationality]   
  ,tgt.GenderTypeName   AS [Gender]  
  ,stu.AdmissionDate   AS [Admission Date]  
  ,tcc.CostCenterName AS [Cost Center]    
  ,tg.GradeName   AS [Grade]  
  ,ts.SectionName   AS [Section]  
  ,stu.PassportNo   AS [Passport No]  
  ,stu.PassportExpiry  AS [Passport Expiry]   
  ,stu.Mobile   AS [Mobile]  
  ,stu.StudentAddress   AS [Address]  
  ,tss.StatusName   AS [Status]   
  ,CASE WHEN stu.IsGPIntegration=1 THEN 'Yes' ELSE 'No' END  AS [GP Integration]    
  ,tt.TermName   AS [Term]  
  ,stu.AdmissionYear   AS [Admission Year]  
  ,CASE WHEN stu.PrinceAccount=1 THEN 'Yes' ELSE 'No' END  AS [PrinceAccount]   
 FROM tblStudent stu     
 LEFT JOIN tblParent tp    
  ON tp.ParentId = stu.ParentId    
 LEFT JOIN tblCountryMaster tc    
  ON tc.CountryId = stu.NationalityId    
 LEFT JOIN tblGenderTypeMaster tgt    
  ON tgt.GenderTypeId = stu.GenderId    
 LEFT JOIN tblCostCenterMaster tcc    
  ON tcc.CostCenterId = stu.CostCenterId    
 LEFT JOIN tblGradeMaster tg    
  ON tg.GradeId = stu.GradeId    
 LEFT JOIN tblSection ts    
  ON ts.SectionId = stu.SectionId    
 LEFT JOIN tblStudentStatus tss    
  ON tss.StudentStatusId = stu.StudentStatusId    
 LEFT JOIN tblTermMaster tt    
  ON tt.TermId=stu.TermId    
 LEFT JOIN tblTermMaster tt1    
  ON tt1.TermId=stu.WithdrawAt    
 WHERE stu.IsDeleted =  0 AND stu.IsActive = 1    
 ORDER BY CAST(stu.StudentCode AS bigint)   
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteAttachements]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_DeleteAttachements]
	@LoginUserId int,
	@UploadedDocId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE  tblUploadDocument SET IsActive=0, IsDeleted=1,UpdateBy=@LoginUserId,UpdateDate=GETDATE() WHERE UploadedDocId = @UploadedDocId;
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
/****** Object:  StoredProcedure [dbo].[sp_DeleteBranch]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteBranch] 
	@LoginUserId int
   ,@BranchId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		DELETE FROM tblBranchMaster WHERE BranchId = @BranchId
		--UPDATE tblBranchMaster
		--	SET IsActive = 0
		--		,IsDeleted = 1
		--		,UpdateBy = @LoginUserId
		--		,UpdateDate = GETDATE()
		--WHERE BranchId = @BranchId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT ERROR_NUMBER() AS Result, 'Error!' AS Response
			--SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteContactInformation]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteContactInformation] 
	@LoginUserId int
   ,@ContactId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblContactInformation
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE ContactId = @ContactId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteCostCenter]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteCostCenter] 
	@LoginUserId int
	,@CostCenterId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY	
			BEGIN TRANSACTION TRANS1
			DELETE FROM tblCostCenterMaster WHERE CostCenterId = @CostCenterId
			--UPDATE tblCostCenterMaster
			--	SET IsActive = 0
			--		,IsDeleted = 1
			--		,UpdateBy = @LoginUserId
			--		,UpdateDate = GETDATE()
			--WHERE CostCenterId = @CostCenterId
					
			COMMIT TRAN TRANS1
			SELECT 0 AS Result, 'Saved' AS Response
		
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT ERROR_NUMBER() AS Result, 'Error!' AS Response
			--SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteDiscount]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteDiscount] 
	@LoginUserId int
   ,@DiscountId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblDiscountMaster
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE DiscountId = @DiscountId

		UPDATE tblDiscountRuleMapping
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE DiscountId = @DiscountId

		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteDocumentType]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteDocumentType] 
	@LoginUserId int
	,@DocumentTypeId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		DELETE FROM tblDocumentTypeMaster WHERE DocumentTypeId = @DocumentTypeId
		--UPDATE tblDocumentTypeMaster
		--	SET IsActive = 0
		--		,IsDeleted = 1
		--		,UpdateBy = @LoginUserId
		--		,UpdateDate = GETDATE()
		--WHERE DocumentTypeId = @DocumentTypeId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT ERROR_NUMBER() AS Result, 'Error!' AS Response
			--SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteFeeDiscount]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteFeeDiscount] 
	@LoginUserId int
   ,@FeeDiscountId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblFeeDiscountMaster
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE FeeDiscountId = @FeeDiscountId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteFeePaymentPlan]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteFeePaymentPlan] 
	@LoginUserId int
   ,@FeePaymentPlanId bigint
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @OldJsonData NVARCHAR(MAX)
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblFeePaymentPlan
			SET IsApproved=0
				,IsRejected=0
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE FeePaymentPlanId = @FeePaymentPlanId
		SELECT 0 AS Result, 'Saved' AS Response
		SELECT @OldJsonData = '{"PaymentPlanAmount": "'+CAST(PaymentPlanAmount AS nvarchar(20))+'", "DueDate": "'+Convert(VARCHAR(10),DueDate,101)+'"}' FROM tblFeePaymentPlan
		WHERE FeePaymentPlanId = @FeePaymentPlanId;
		EXEC sp_SaveNotification @LoginUserId=@LoginUserId,@ActionTable='tblFeePaymentPlan'
		,@NotificationAction='3',@TableRecordId=@FeePaymentPlanId
		,@OldValueJson=@OldJsonData,@NewValueJson='',@TableRecordColumnName='FeePaymentPlanId'		
		COMMIT TRAN TRANS1
		
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteFeePlanWithoutGradewise]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteFeePlanWithoutGradewise] 
	@LoginUserId int
   ,@FeeStructureId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblFeeStructure
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE FeeStructureId = @FeeStructureId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteFeeType]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteFeeType] 
	@LoginUserId int
   ,@FeeTypeId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblFeeTypeMaster
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE FeeTypeId = @FeeTypeId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteFeeTypeDetail]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteFeeTypeDetail] 
	@LoginUserId int
   ,@FeeTypeDetailId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblFeeTypeDetail
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE FeeTypeDetailId = @FeeTypeDetailId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteGender]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteGender] 
	@LoginUserId int
	,@GenderTypeId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblGenderTypeMaster
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE GenderTypeId = @GenderTypeId
					
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
/****** Object:  StoredProcedure [dbo].[sp_DeleteGrade]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteGrade] 
	@LoginUserId int
	,@GradeId int
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY	
		BEGIN TRANSACTION TRANS1
		DELETE FROM tblGradeMaster WHERE GradeId = @GradeId
		--UPDATE tblGradeMaster
		--	SET IsActive = 0
		--		,IsDeleted = 1
		--		,UpdateBy = @LoginUserId
		--		,UpdateDate = GETDATE()
		--WHERE GradeId = @GradeId

		update t
		set 
			t.SequenceNo=p.RN
		from tblGradeMaster t
		join 
		(
			select ROW_NUMBER() over(order by SequenceNo ) as RN, * from tblGradeMaster
			WHERE IsDeleted = 0 and  IsActive = 1
		)p
		on t.GradeId=p.GradeId


		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response		
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT ERROR_NUMBER() AS Result, 'Error!' AS Response
			--SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteInvoice]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteInvoice] 
	@LoginUserId int
   ,@InvoiceId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE INV_InvoiceSummary
			SET 
				IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE InvoiceId = @InvoiceId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteInvoiceDetail]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteInvoiceDetail] 
	@LoginUserId int
   ,@InvoiceDetailId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblInvoiceDetail
			SET 
				IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE InvoiceDetailId = @InvoiceDetailId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteInvoiceType]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteInvoiceType] 
	@LoginUserId int
	,@InvoiceTypeId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblInvoiceTypeMaster
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE InvoiceTypeId = @InvoiceTypeId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteParent]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteParent] 
	@LoginUserId int
	,@ParentId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		DELETE FROM tblParent WHERE ParentId = @ParentId
		DELETE FROM tblUser WHERE UserEmail = (Select FatherEmail from tblParent WHERE ParentId = @ParentId)
		--UPDATE tblParent
		--	SET IsActive = 0
		--		,IsDeleted = 1
		--		,UpdateBy = @LoginUserId
		--		,UpdateDate = GETDATE()
		--WHERE ParentId = @ParentId
		
		--UPDATE tblUser 	
		--SET IsActive = 0
		--	,IsDeleted = 1
		--	,UpdateBy = @LoginUserId
		--	,UpdateDate = GETDATE()
		--WHERE UserEmail = (Select FatherEmail from tblParent WHERE ParentId = @ParentId)

		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response	
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT ERROR_NUMBER() AS Result, 'Error!' AS Response
			--SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteSchool]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteSchool] 
	@LoginUserId int
   ,@SchoolId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		DELETE FROM tblSchoolMaster WHERE SchoolId = @SchoolId
		--UPDATE tblSchoolMaster
		--	SET IsActive = 0
		--		,IsDeleted = 1
		--		,UpdateBy = @LoginUserId
		--		,UpdateDate = GETDATE()
		--WHERE SchoolId = @SchoolId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT ERROR_NUMBER() AS Result, 'Error!' AS Response
			--SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteSchoolAcademic]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteSchoolAcademic] 
	@LoginUserId int
   ,@SchoolAcademicId int
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblSchoolAcademic
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE SchoolAcademicId = @SchoolAcademicId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteSchoolAccountInfo]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteSchoolAccountInfo] 
	@LoginUserId int
   ,@SchoolAccountIId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblSchoolAccountInfo
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE SchoolAccountIId = @SchoolAccountIId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteSchoolLogoImage]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteSchoolLogoImage]
	@SchoolLogoId bigint = 0
AS
BEGIN
	SET NOCOUNT ON;	
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		DELETE FROM tblSchoolLogo	WHERE SchoolLogoId = @SchoolLogoId 	
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
/****** Object:  StoredProcedure [dbo].[sp_DeleteSchoolTermAcademic]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- *** SqlDbx Personal Edition ***
-- !!! Not licensed for commercial use beyound 90 days evaluation period !!!
-- For version limitations please check http://www.sqldbx.com/personal_edition.htm
-- Number of queries executed: 2, number of rows retrieved: 20

CREATE PROCEDURE [dbo].[sp_DeleteSchoolTermAcademic] 
	@LoginUserId int
   ,@SchoolTermAcademicId int
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @OldJsonData NVARCHAR(MAX)
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblSchoolTermAcademic
			SET IsApproved=0
				,IsRejected=0
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE SchoolTermAcademicId = @SchoolTermAcademicId
		SELECT 0 AS Result, 'Saved' AS Response
		
		SELECT @OldJsonData = '{"TermName": "'+ TermName +'", "StartDate": "'+Convert(VARCHAR(10),StartDate,101)+'", "EndDate": "'+Convert(VARCHAR(10),EndDate,101)+'"}' 
		FROM tblSchoolTermAcademic
		WHERE SchoolTermAcademicId = @SchoolTermAcademicId;
		EXEC sp_SaveNotification @LoginUserId=@LoginUserId,@ActionTable='tblSchoolTermAcademic'
		,@NotificationAction='3',@TableRecordId=@SchoolTermAcademicId
		,@OldValueJson=@OldJsonData,@NewValueJson='',@TableRecordColumnName='SchoolTermAcademicId'		
		
		COMMIT TRAN TRANS1
		
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteSection]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteSection] 
	@LoginUserId int
	,@SectionId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY		
		BEGIN TRANSACTION TRANS1
		DELETE FROM tblSection WHERE  SectionId= @SectionId
		--UPDATE tblSection
		--	SET IsActive = 0
		--		,IsDeleted = 1
		--		,UpdateBy = @LoginUserId
		--		,UpdateDate = GETDATE()
		--WHERE SectionId= @SectionId
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT ERROR_NUMBER() AS Result, 'Error!' AS Response
			--SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteStudent]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteStudent] 
	@LoginUserId int
	,@StudentId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		DELETE FROM tblStudent WHERE StudentId = @StudentId
		--UPDATE tblStudent
		--	SET IsActive = 0
		--		,IsDeleted = 1
		--		,UpdateBy = @LoginUserId
		--		,UpdateDate = GETDATE()
		--WHERE StudentId = @StudentId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT ERROR_NUMBER() AS Result, 'Error!' AS Response
			--SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteStudentFeeDetail]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteStudentFeeDetail] 
	@LoginUserId int
   ,@StudentFeeDetailId int
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblStudentFeeDetail
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE StudentFeeDetailId = @StudentFeeDetailId					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY
	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteStudentStatus]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteStudentStatus] 
	@LoginUserId int
	,@StudentStatusId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblStudentStatus
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE StudentStatusId = @StudentStatusId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteUser]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteUser] 
	@LoginUserId int
	,@UserId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblUser
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE UserId = @UserId
					
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
/****** Object:  StoredProcedure [dbo].[sp_DeleteVat]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DeleteVat] 
	@LoginUserId int
   ,@VatId bigint
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblVatMaster
			SET IsActive = 0
				,IsDeleted = 1
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE VatId = @VatId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_getAdminDashboardData]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_getAdminDashboardData]
as
begin
	select  count(1) as TotalStudent
	from tblStudent

	select  count(1) as TotalParent from tblParent

	select 
	case when GenderId=1 then 'Male' else 'Female' end as Gender, GradeName as KeyName, count(1) as KeyValue
	from tblStudent stu
	inner join tblGradeMaster grade
	on stu.GradeId=grade.GradeId

	group by GradeName,GenderId

	select 
	AdmissionYear as KeyName, count(1) as KeyValue
	from tblStudent stu
	group by AdmissionYear

end
GO

/****** Object:  StoredProcedure [dbo].[sp_GetAttachmentByDocForId]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_GetAttachmentByDocForId]
	@DocForId bigint
	,@DocFor int
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT UploadedDocId
      ,DocFor
      ,DocType
      ,DocForId
      ,DocNo
      ,DocPath
      ,ud.UpdateDate
      ,ud.UpdateBy
	  ,dtm.DocumentTypeName
  FROM tblUploadDocument ud
  inner join tblDocumentTypeMaster dtm on dtm.DocumentTypeId=ud.DocType
WHERE ud.DocForId = @DocForId AND ud.IsDeleted=0 AND ud.IsActive = 1 AND ud.DocFor=@DocFor
ORDER BY  ud.DocNo

	
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetAuthDetail]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_GetAuthDetail] 
	@UserEmail [nvarchar](200)
	,@UserPass [nvarchar](500)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT tu.UserId
		,tu.UserName
		,tu.UserArabicName
		,tu.UserEmail
		,tu.UserPhone
		,tr.RoleId
		,tr.RoleName
		,tu.ProfileImg		
	FROM tblUser tu
	INNER JOIN tblRole tr
		ON tr.RoleId = tu.RoleId	
	WHERE tu.IsActive = 1 AND tu.IsDeleted = 0 AND tr.IsActive = 1 AND tr.IsDeleted = 0
		AND tu.UserEmail = @UserEmail AND tu.UserPass = @UserPass
	
	DECLARE @MenuTable 
	TABLE(MenuId int
		,Menu nvarchar(50)
		,MenuCtrl nvarchar(100)
		,MenuAction nvarchar(100)
		,ParentMenuId int
		,DisplaySequence int
		,FaIcon nvarchar(50)
		,AllowAdd bit
		,AllowEdit bit
		,AllowDelete bit)
	INSERT INTO @MenuTable (MenuId, Menu, MenuCtrl, MenuAction, ParentMenuId, DisplaySequence,FaIcon,AllowAdd,AllowEdit,AllowDelete)
	SELECT tm.MenuId
		,tm.Menu
		,tm.MenuCtrl
		,tm.MenuAction
		,tm.ParentMenuId
		,tm.DisplaySequence
		,tm.FaIcon
		,trmm.AllowAdd
		,trmm.AllowEdit
		,trmm.AllowDelete
	FROM tblMenu tm
	INNER JOIN tblRoleMenuMapping trmm
		ON tm.MenuId = trmm.MenuId
	INNER JOIN tblUser tu
		ON tu.RoleId = trmm.RoleId
	WHERE tu.UserEmail = @UserEmail
		AND tm.IsActive = 1 AND trmm.IsActive = 1
		AND tm.IsDeleted =0 AND trmm.IsDeleted = 0
	;WITH  MenuCTE
	AS
	(
		SELECT tm1.MenuId
			,tm1.Menu
			,tm1.MenuCtrl
			,tm1.MenuAction
			,tm1.ParentMenuId
			,tm1.DisplaySequence
			,tm1.FaIcon
			,tm1.AllowAdd
			,tm1.AllowEdit
			,tm1.AllowDelete
			,1 AS [Level]
			,CAST((tm1.Menu) AS VARCHAR(MAX)) AS Hierarchy
		FROM @MenuTable tm1
		WHERE ParentMenuId = 0

		UNION ALL
		SELECT tm2.MenuId
			,tm2.Menu
			,tm2.MenuCtrl
			,tm2.MenuAction
			,tm2.ParentMenuId
			,tm2.DisplaySequence
			,tm2.FaIcon
			,tm2.AllowAdd
			,tm2.AllowEdit
			,tm2.AllowDelete
			,M.[level] + 1 AS [Level]
			,CAST((M.Hierarchy + '->' + tm2.Menu) AS VARCHAR(MAX)) AS Hierarchy
		FROM @MenuTable AS tm2
		JOIN MenuCTE AS M ON tm2.ParentMenuId = M.MenuId   
	)
	SELECT * FROM MenuCTE
	ORDER BY ParentMenuId,DisplaySequence
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetBranch]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetBranch]
	@BranchId bigint = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterIsActive bit=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tbm.BranchId
		,tbm.BranchName	
		,tbm.IsActive	
	FROM tblBranchMaster tbm	
	WHERE tbm.BranchId = CASE WHEN @BranchId > 0 THEN @BranchId ELSE tbm.BranchId END
		--AND (tbm.BranchName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tbm.BranchName END + '%')
		--AND tbm.IsActive =  CASE WHEN @FilterIsActive=-1 OR @BranchId>0 THEN tbm.IsActive ELSE @FilterIsActive  END
		AND tbm.IsDeleted =  0
	 ORDER BY tbm.IsActive desc , tbm.BranchName asc
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetContactInformation]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetContactInformation]
	@SchoolId bigint = 0,
	@ContactId bigint = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterIsActive int=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tci.ContactId
		,tci.SchoolId
		,tci.ContactPerson
		,tci.ContactPosition
		,tci.ContactTelephone
		,tci.ContactEmail
	  ,tci.IsActive		
	FROM tblContactInformation tci		
	WHERE tci.ContactId = CASE WHEN @ContactId> 0 THEN @ContactId ELSE tci.ContactId END	
		AND tci.IsDeleted =  0 AND IsActive=1
		AND  tci.SchoolId=@SchoolId
	 ORDER BY tci.ContactPerson
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetCostCenter]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetCostCenter]  
 @CostCenterId bigint = 0,  
 @FilterSearch NVarChar(200)=null,  
 @FilterIsActive bit=1  
AS  
BEGIN  
 SET NOCOUNT ON;   
 SELECT tcc.CostCenterId  
	,tcc.CostCenterName  
	,tcc.Remarks  
	,tcc.DebitAccount  
	,tcc.CreditAccount  
	,tcc.IsActive    
 FROM tblCostCenterMaster tcc    
 WHERE tcc.CostCenterId = CASE WHEN @CostCenterId > 0 THEN @CostCenterId ELSE tcc.CostCenterId END  
  AND (tcc.CostCenterName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tcc.CostCenterName END + '%'  
  OR tcc.Remarks LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tcc.Remarks END + '%')  
  AND tcc.IsActive =  CASE WHEN @CostCenterId>0 THEN tcc.IsActive ELSE @FilterIsActive  END  
  AND tcc.IsDeleted =  0  
 ORDER BY tcc.CostCenterName  
END  
GO
/****** Object:  StoredProcedure [dbo].[sp_GetDiscount]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetDiscount]
	@DiscountId bigint = 0
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tdm.DiscountId
		,tdm.DiscountName
		,tdm.DiscountPercent
	FROM tblDiscountMaster tdm		
	WHERE tdm.DiscountId = CASE WHEN @DiscountId > 0 THEN @DiscountId ELSE tdm.DiscountId END
		AND tdm.IsDeleted =  0 AND tdm.IsActive=1
	ORDER BY tdm.DiscountName

	SELECT tdrm.DiscountId 
			,tdr.DiscountRuleId 
			,tdr.DiscountRuleDescription
	FROM tblDiscountRuleMapping tdrm      
	INNER JOIN tblDiscountRules tdr      
		ON tdrm.DiscountRuleId = tdr.DiscountRuleId      
	WHERE tdrm.IsActive = 1 AND tdrm.IsDeleted = 0 
		AND tdr.IsActive = 1 AND tdr.IsDeleted = 0 
		AND tdrm.DiscountId = CASE WHEN @DiscountId > 0 THEN @DiscountId ELSE tdrm.DiscountId END
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetDocumentType]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_GetDocumentType]
	@DocumentTypeId bigint = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterIsActive bit=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tdt.DocumentTypeId
		,tdt.DocumentTypeName
		,tdt.Remarks		
		,tdt.IsActive		
	FROM tblDocumentTypeMaster tdt		
	WHERE tdt.DocumentTypeId = CASE WHEN @DocumentTypeId > 0 THEN @DocumentTypeId ELSE tdt.DocumentTypeId END
		AND (tdt.DocumentTypeName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tdt.DocumentTypeName END + '%'
		OR tdt.Remarks LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tdt.Remarks END + '%')
		AND tdt.IsActive =  CASE WHEN @DocumentTypeId>0 THEN tdt.IsActive ELSE @FilterIsActive  END
		AND tdt.IsDeleted =  0
	ORDER BY tdt.DocumentTypeName
END
GO
/****** Object:  StoredProcedure [dbo].[SP_GetFeeAmount]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SP_GetFeeAmount 1016,0,'ENTRANCE'  
--select * from [tblFeeTypeDetail]  
  
CREATE proc [dbo].[SP_GetFeeAmount]  
@AcademicYearId bigint  
,@StudentId bigint,  
@InvoiceTypeName nvarchar(50)  
as  
begin  
	 declare @IsStaffMember bit=0;  
	 declare @GradeId int=0;
	 if(@studentId>0)  
	 begin  
	  select top 1    
		@IsStaffMember= case when p.IsFatherStaff=1 OR p.IsMotherStaff=1 then 1 else 0 end  
		,@GradeId=s.GradeId
	  from  
	  [dbo].[tblParent] p  
	  join [dbo].[tblStudent] s on p.ParentId=s.ParentId  
	  where StudentId= @studentId  
	 end  

	 if(@InvoiceTypeName like '%Tuition%')
	begin

		declare @TotalAcademicYearPaid decimal(18,2)=0
		select  @TotalAcademicYearPaid=isnull(sum( UnitPrice),0) 
		from INV_InvoiceDetail
		where StudentId=@StudentId and AcademicYear=@AcademicYearId
		and IsDeleted=0

		select top 1 
		ftd.FeeTypeDetailId
		,ftd.FeeTypeId
		,ftd.AcademicYearId
		,ftd.GradeId
		,inv.FeeAmount as TermFeeAmount
		,ftd.IsActive
		,ftd.IsDeleted
		,ftd.UpdateDate
		,ftd.UpdateBy
		,inv.FeeAmount as StaffFeeAmount
		,IsStaffMember=@IsStaffMember 
		,FinalFeeAmount=inv.FeeAmount-  @TotalAcademicYearPaid

		from [dbo].[tblFeeTypeDetail] ftd  
		join [dbo].[tblFeeTypeMaster] ftm on ftd.FeeTypeId=ftm.FeeTypeId  
		join  [dbo].[tblStudentFeeDetail] inv on ftm.FeeTypeId=inv.FeeTypeId and ftd.AcademicYearId=inv.AcademicYearId
		where ftd.AcademicYearId=@academicYearId  
		and ftm.FeeTypeName like '%'+@InvoiceTypeName+'%'  

	end
	else 
	begin

		 select top 1 ftd.*,IsStaffMember=@IsStaffMember ,  
		 FinalFeeAmount=case when @IsStaffMember=1 then StaffFeeAmount else TermFeeAmount end   

		 from [dbo].[tblFeeTypeDetail] ftd  
		 join [dbo].[tblFeeTypeMaster] ftm on ftd.FeeTypeId=ftm.FeeTypeId  
		 where AcademicYearId=@academicYearId  
		 and ftm.FeeTypeName like '%'+@InvoiceTypeName+'%'  

	end
end

--select * from [tblFeeTypeMaster]
--select * from [tblFeeTypeDetail]
--select * from [dbo].[tblStudentFeeDetail]


--select * from INV_InvoiceDetail
GO
/****** Object:  StoredProcedure [dbo].[sp_GetFeeDiscount]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetFeeDiscount]
	@FeeDiscountId bigint = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterIsActive bit = 1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tfm.FeeDiscountId
		,tfm.FeeDiscountName
		,tfm.[Percent]
		,tfm.[Rule]
		,tfm.Remarks
	  ,tfm.IsActive		
	FROM tblFeeDiscountMaster tfm		
	WHERE tfm.FeeDiscountId = CASE WHEN @FeeDiscountId > 0 THEN @FeeDiscountId ELSE tfm.FeeDiscountId END
		AND (tfm.FeeDiscountName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tfm.FeeDiscountName END + '%')
		AND tfm.IsActive =  CASE WHEN @FeeDiscountId > 0  THEN tfm.IsActive ELSE @FilterIsActive  END
		AND tfm.IsDeleted =  0
	 ORDER BY tfm.FeeDiscountName
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetFeePaymentPlan]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetFeePaymentPlan]
	@FeeTypeDetailId bigint = 0	
	,@FeePaymentPlanId bigint = 0
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT FeePaymentPlanId
		,FeeTypeDetailId
		,PaymentPlanAmount
		,DueDate
		,IsApproved
		,IsRejected
	FROM tblFeePaymentPlan		
	WHERE FeeTypeDetailId = @FeeTypeDetailId
		AND FeePaymentPlanId = CASE WHEN @FeePaymentPlanId > 0 THEN @FeePaymentPlanId ELSE FeePaymentPlanId END
		AND IsDeleted =  0
	ORDER BY DueDate
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetFeePlanWithGradewise]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetFeePlanWithGradewise]  
 @FeeTypeId bigint
 ,@AcademicYear nvarchar(20)
AS  
BEGIN  
	SET NOCOUNT ON; 
	INSERT INTO [dbo].[tblFeeStructure] 
			([AcademicYear]
			,[FeeTypeId]
			,[IsGradeWise]
			,[IsActive]
			,[IsDeleted]
			,[UpdateDate]
			,[UpdateBy])    

	SELECT @AcademicYear
		,FeeTypeId
		,IsGradeWise
		,1
		,0
		,GETDATE()
		,-1
	FROM tblFeeTypeMaster WHERE FeeTypeId NOT IN (SELECT FeeTypeId FROM tblFeeStructure WHERE AcademicYear = @AcademicYear)
	AND FeeTypeId=@FeeTypeId 

	DECLARE @FeeStructureId bigint
	SELECT @FeeStructureId=FeeStructureId FROM tblFeeStructure 
		WHERE AcademicYear = @AcademicYear AND IsGradeWise=1 AND FeeTypeId=@FeeTypeId
	
	INSERT INTO [dbo].[tblFeeGradewise]
			([FeeTypeId]
			,[FeeStructureId]
			,[GradeId]			 
			,[IsActive]
			,[IsDeleted]
			,[UpdateDate]
			,[UpdateBy])
	SELECT @FeeTypeId
		,@FeeStructureId
		,GradeId		
		,1
		,0
		,GETDATE()
		,-1 
	FROM tblGradeMaster tgm	
	WHERE @FeeStructureId NOT IN (SELECT FeeStructureId FROM [tblFeeGradewise])
	

	SELECT tfg.FeeGradewiseId  
		,tfg.FeeStructureId 
		,tg.GradeName
		,tfg.GradeId   
		,tfg.FirstAmount  
		,tfg.FirstDueDate  
		,tfg.SecondAmount  
		,tfg.SecondDueDate  
		,tfg.ThirdAmount  
		,tfg.ThirdDueDate  
		,tfg.FirstAmount+tfg.SecondAmount+tfg.ThirdAmount AS Total  
		,(tfg.FirstAmount+tfg.SecondAmount+tfg.ThirdAmount)/3 AS TermAmount  
	FROM tblFeeGradewise tfg  
	INNER JOIN tblFeeStructure tfs  
	ON tfs.FeeStructureId = tfg.FeeStructureId  
	INNER JOIN tblGradeMaster tg  
	ON tg.GradeId=tfg.GradeId  
	WHERE  tfs.IsActive=1 AND tfs.IsDeleted=0 AND tfs.AcademicYear= @AcademicYear AND tfg.FeeTypeId=@FeeTypeId  
	ORDER BY tg.SequenceNo 
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetFeePlanWithoutGradewise]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetFeePlanWithoutGradewise]  
 @FeeTypeId bigint,
 @FeeStructureId bigint=0
AS  
BEGIN  
	SET NOCOUNT ON; 
	SELECT tft.FeeTypeId  
		,tft.FeeTypeName  
		,tft.IsGradeWise
		,tfs.FeeStructureId  
		,tfs.AcademicYear  
		,tfs.IsGradeWise AS IsGradeWiseFeeStructure  
		,tfs.FeeAmount   
	FROM tblFeeStructure tfs 
	INNER JOIN tblFeeTypeMaster tft 
		ON tft.FeeTypeId = tfs.FeeTypeId  
	WHERE tft.IsActive=1 AND tft.IsDeleted=0 AND tfs.FeeTypeId=@FeeTypeId AND tfs.IsActive=1 AND tfs.IsDeleted=0  
	AND tfs.FeeStructureId = CASE WHEN @FeeStructureId > 0 THEN @FeeStructureId ELSE tfs.FeeStructureId END	
	ORDER BY ISNULL(tfs.IsGradeWise,0),tft.IsGradeWise 
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetFeeStructure]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetFeeStructure]  
 @AcademicYear nvarchar(20)  
AS  
BEGIN  
	SET NOCOUNT ON;  
	INSERT INTO [dbo].[tblFeeStructure] 
			([AcademicYear]
			,[FeeTypeId]
			--,[FeeAmount]
			,[IsGradeWise]
			,[IsActive]
			,[IsDeleted]
			,[UpdateDate]
			,[UpdateBy])    

	SELECT @AcademicYear
		,FeeTypeId
		--,0
		,IsGradeWise
		,1
		,0
		,GETDATE()
		,-1
	FROM tblFeeTypeMaster WHERE FeeTypeId NOT IN (SELECT FeeTypeId FROM tblFeeStructure WHERE AcademicYear = @AcademicYear);

	DECLARE @FeeStructureId bigint
	DECLARE @FeeTypeId bigint
	DECLARE fetch_cursor CURSOR FOR SELECT FeeStructureId,FeeTypeId FROM tblFeeStructure WHERE AcademicYear = @AcademicYear AND IsGradeWise=1
	OPEN fetch_cursor
	FETCH NEXT FROM fetch_cursor INTO @FeeStructureId,@FeeTypeId
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		INSERT INTO [dbo].[tblFeeGradewise]
			   ([FeeTypeId]
			   ,[FeeStructureId]
			   ,[GradeId]
			   --,[FirstAmount]
			   --,[FirstDueDate]
			   --,[SecondAmount]
			   --,[SecondDueDate]
			   --,[ThirdAmount]
			   --,[ThirdDueDate]
			   ,[IsActive]
			   ,[IsDeleted]
			   ,[UpdateDate]
			   ,[UpdateBy])
		SELECT @FeeTypeId
			,@FeeStructureId
			,GradeId
			--,0
			--,GETDATE()
			--,0
			--,GETDATE()
			--,0
			--,GETDATE()
			,1
			,0
			,GETDATE()
			,-1 
		FROM tblGradeMaster tgm	
		WHERE @FeeStructureId NOT IN (SELECT FeeStructureId FROM [tblFeeGradewise])
		FETCH NEXT FROM fetch_cursor INTO @FeeStructureId,@FeeTypeId
	END
	CLOSE fetch_cursor 
	DEALLOCATE fetch_cursor

	SELECT tft.FeeTypeId  
		,tft.FeeTypeName  
		,tft.IsGradeWise AS IsGradeWiseFeeType  
		,tfs.FeeStructureId  
		,tfs.AcademicYear  
		,tfs.IsGradeWise AS IsGradeWiseFeeStructure  
		,tfs.FeeAmount   
	FROM tblFeeTypeMaster tft  
	INNER JOIN tblFeeStructure tfs  
		ON tft.FeeTypeId = tfs.FeeTypeId  
	WHERE tft.IsActive=1 AND tft.IsDeleted=0 AND tfs.AcademicYear=@AcademicYear AND tfs.IsActive=1 AND tfs.IsDeleted=0  
	ORDER BY ISNULL(tfs.IsGradeWise,0),tft.IsGradeWise 
	
	SELECT tfg.FeeGradewiseId  
		,tfg.FeeStructureId 
		,tg.GradeName
		,tfg.GradeId   
		,tfg.FirstAmount  
		,tfg.FirstDueDate  
		,tfg.SecondAmount  
		,tfg.SecondDueDate  
		,tfg.ThirdAmount  
		,tfg.ThirdDueDate  
		,tfg.FirstAmount+tfg.SecondAmount+tfg.ThirdAmount AS Total  
		,(tfg.FirstAmount+tfg.SecondAmount+tfg.ThirdAmount)/3 AS TermAmount  
	FROM tblFeeGradewise tfg  
	INNER JOIN tblFeeStructure tfs  
	ON tfs.FeeStructureId = tfg.FeeStructureId  
	INNER JOIN tblGradeMaster tg  
	ON tg.GradeId=tfg.GradeId  
	WHERE  tfs.IsActive=1 AND tfs.IsDeleted=0 AND tfs.AcademicYear= @AcademicYear  
	ORDER BY tg.SequenceNo 
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetFeeType]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetFeeType]        
 @FeeTypeId bigint = 0        
AS        
BEGIN        
 SET NOCOUNT ON;         
 SELECT tfm.FeeTypeId        
 ,tfm.FeeTypeName  
 ,tfm.IsPrimary
 ,tfm.IsGradeWise   
 ,tfm.IsTermPlan        
 ,tfm.IsPaymentPlan        
 ,tfm.IsActive   
 ,tfm.DebitAccount  
 ,tfm.CreditAccount  
 FROM tblFeeTypeMaster tfm          
 WHERE tfm.FeeTypeId = CASE WHEN @FeeTypeId > 0 THEN @FeeTypeId ELSE tfm.FeeTypeId END         
  AND tfm.IsDeleted =  0        
  ORDER BY tfm.FeeTypeName        
END 

GO
/****** Object:  StoredProcedure [dbo].[sp_GetFeeTypeDetail]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec sp_GetFeeTypeDetail @FeeTypeId=4  
CREATE PROCEDURE [dbo].[sp_GetFeeTypeDetail]        
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
   
 ORDER BY tfm.FeeTypeName       
   
  
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
/****** Object:  StoredProcedure [dbo].[sp_GetFeeTypeNew]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[sp_GetFeeTypeNew]  
 @FeeTypeId bigint = 0  
AS  
BEGIN  
 SET NOCOUNT ON;   
 SELECT tfm.FeeTypeId  
  ,tfm.FeeTypeName  
  ,tfm.IsTermPlan  
  ,tfm.IsPaymentPlan  
   ,tfm.IsActive    
 FROM tblFeeTypeMaster tfm    
 WHERE tfm.FeeTypeId = CASE WHEN @FeeTypeId > 0 THEN @FeeTypeId ELSE tfm.FeeTypeId END   
  AND tfm.IsDeleted =  0  
  ORDER BY tfm.FeeTypeName  
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetGender]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_GetGender]
	@GenderTypeId bigint = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterIsActive bit=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tgt.GenderTypeId
		,tgt.GenderTypeName
		,tgt.DebitAccount
		,tgt.CreditAccount
		,tgt.IsActive		
	FROM tblGenderTypeMaster tgt		
	WHERE tgt.GenderTypeId = CASE WHEN @GenderTypeId > 0 THEN @GenderTypeId ELSE tgt.GenderTypeId END
		AND (tgt.GenderTypeName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tgt.GenderTypeName END + '%')
		AND tgt.IsActive =  CASE WHEN @GenderTypeId>0 THEN tgt.IsActive ELSE @FilterIsActive  END
		AND tgt.IsDeleted =  0
	ORDER BY tgt.GenderTypeName
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetGenerateFee]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetGenerateFee]
	@FeeGenerateId int=0
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT 
		tfg.FeeGenerateId
		,tfg.SchoolAcademicId
		,tsa.AcademicYear
		,tfg.FeeTypeId
		,tf.FeeTypeName
		,tfg.GradeId
		,CONCAT_WS(' - ',tg.GradeName, tgtm.GenderTypeName) AS GradeName
		,tfg.GenerateStatus
		,tfg.UpdateDate
		,tfg.UpdateBy
		,COUNT(tfgd.FeeGenerateDetailId) AS StudentCount
	FROM tblFeeGenerate tfg
	INNER JOIN tblSchoolAcademic tsa
		ON tfg.SchoolAcademicId = tsa.SchoolAcademicId
	INNER JOIN tblFeeTypeMaster tf
		ON tfg.FeeTypeId = tf.FeeTypeId
	INNER JOIN tblGradeMaster tg
		ON tfg.GradeId = tg.GradeId
	LEFT JOIN tblGenderTypeMaster tgtm   
		ON tgtm.GenderTypeId = tg.GenderTypeId  
	LEFT JOIN tblFeeGenerateDetail tfgd 
		ON tfg.FeeGenerateId = tfgd.FeeGenerateId 
	GROUP BY 
		tfg.FeeGenerateId
		,tfg.SchoolAcademicId
		,tsa.AcademicYear
		,tfg.FeeTypeId
		,tf.FeeTypeName
		,tfg.GradeId
		,CONCAT_WS(' - ',tg.GradeName, tgtm.GenderTypeName) 
		,tfg.GenerateStatus
		,tfg.UpdateDate
		,tfg.UpdateBy
	HAVING tfg.FeeGenerateId=CASE WHEN @FeeGenerateId>0 THEN @FeeGenerateId ELSE tfg.FeeGenerateId END
	IF(@FeeGenerateId>0)
	BEGIN
		SELECT tfg.FeeGenerateDetailId
				,tfg.FeeGenerateId
				,tfg.StudentId
				,tstu.StudentName
				,tfg.SchoolAcademicId
				,tsa.AcademicYear
				,tfg.GradeId
				,CONCAT_WS(' - ',tg.GradeName, tgtm.GenderTypeName) AS GradeName
				,tfg.FeeTypeId
				,tf.FeeTypeName
				,tfg.FeeAmount
				,tfg.UpdateDate
				,tfg.UpdateBy
		FROM tblFeeGenerateDetail tfg
		INNER JOIN tblStudent tstu
			ON tstu.StudentId = tfg.StudentId
		INNER JOIN tblSchoolAcademic tsa
			ON tfg.SchoolAcademicId = tsa.SchoolAcademicId
		INNER JOIN tblFeeTypeMaster tf
			ON tfg.FeeTypeId = tf.FeeTypeId
		INNER JOIN tblGradeMaster tg
			ON tfg.GradeId = tg.GradeId
		LEFT JOIN tblGenderTypeMaster tgtm   
			ON tgtm.GenderTypeId = tg.GenderTypeId 
		WHERE FeeGenerateId=@FeeGenerateId
	END
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetGradeMaxSequenceNo]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetGradeMaxSequenceNo]
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT ISNULL(MAX(SequenceNo),0) AS SequenceNo
	FROM tblGradeMaster WHERE IsActive=1 AND IsDeleted=0
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetGrades]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetGrades]  
 @GradeId int = 0,  
 @FilterSearch NVarChar(200)=null,  
 @FilterCostCenterId int=0,  
 @FilterGenderTypeId int=0,  
 @FilterIsActive bit=1  
AS  
BEGIN  
 SET NOCOUNT ON;   
 SELECT tg.GradeId  
	,tg.GradeName   
	,tg.SequenceNo   
	,tg.DebitAccount
	,tg.CreditAccount
  ,tcc.CostCenterId  
  ,tcc.CostCenterName   
  ,ISNULL(tgt.GenderTypeId,0) GenderTypeId  
  ,tgt.GenderTypeName  
  ,(SELECT MAX(SequenceNo)+1 FROM tblGradeMaster WHERE IsActive=1 AND IsDeleted=0)  AS MaxSequenceNo   
  ,tg.IsActive    
 FROM tblGradeMaster tg  
 INNER JOIN tblCostCenterMaster tcc  
  ON tcc.CostCenterId = tg.CostCenterId  
 LEFT JOIN tblGenderTypeMaster tgt  
  ON tgt.GenderTypeId = tg.GenderTypeId  
 WHERE tg.GradeId = CASE WHEN @GradeId > 0 THEN @GradeId ELSE tg.GradeId END  
  --AND (tg.GradeName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tg.GradeName END + '%'  
  --OR tcc.CostCenterName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tcc.CostCenterName END + '%'  
  --OR tgt.GenderTypeName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tgt.GenderTypeName END + '%'  
  --)  
  AND tg.CostCenterId = CASE WHEN @FilterCostCenterId > 0 THEN @FilterCostCenterId ELSE tg.CostCenterId END  
  AND tg.GenderTypeId = CASE WHEN @FilterGenderTypeId > 0 THEN @FilterGenderTypeId ELSE tg.GenderTypeId END  
  --AND tg.IsActive =  CASE WHEN @GradeId > 0 THEN tg.IsActive ELSE @FilterIsActive  END  
  AND tg.IsDeleted =0 AND tg.IsActive = 1  
 ORDER BY tg.SequenceNo  
  
   
END  
GO

/****** Object:  StoredProcedure [dbo].[sp_GetInvoiceByInvoiceNo]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_GetInvoiceByInvoiceNo]
@InvoiceNo nvarchar(50)
as
begin
	select * from INV_InvoiceSummary where InvoiceNo=@InvoiceNo
	select * from INV_InvoiceDetail where InvoiceNo=@InvoiceNo
	select * from INV_InvoicePayment where InvoiceNo=@InvoiceNo

end
GO
/****** Object:  StoredProcedure [dbo].[sp_getInvoiceData]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[sp_getInvoiceData]
    @StartYear datetime,
    @EndYear datetime
AS
BEGIN
    SELECT
        InvoiceYear,
		InvoiceMonth,
		InvoiceMonthName,
        Discount = SUM(Discount),
        TaxableAmount = SUM(TaxableAmount),
        TaxAmount = SUM(TaxAmount),
        ItemSubtotal = SUM(ItemSubtotal)
    FROM (
        SELECT
            InvoiceYear,
			InvoiceMonth,
			InvoiceMonthName,
            Discount = SUM(Discount),
            TaxableAmount = SUM(TaxableAmount),
            TaxAmount = SUM(TaxAmount),
            ItemSubtotal = SUM(ItemSubtotal)
        FROM (
            SELECT
                InvoiceYear,
				InvoiceMonth,
				InvoiceMonthName,
                Discount = CASE WHEN InvoiceType = 'Return' THEN (Discount * -1) ELSE Discount END,
                TaxableAmount = CASE WHEN InvoiceType = 'Return' THEN (TaxableAmount * -1) ELSE TaxableAmount END,
                TaxAmount = CASE WHEN InvoiceType = 'Return' THEN (TaxAmount * -1) ELSE TaxAmount END,
                ItemSubtotal = CASE WHEN InvoiceType = 'Return' THEN (ItemSubtotal * -1) ELSE ItemSubtotal END
            FROM (
                SELECT
                    YEAR(ts.InvoiceDate) InvoiceYear,
					Month(ts.InvoiceDate) InvoiceMonth,
					datename(month,ts.InvoiceDate) InvoiceMonthName,
                    td.InvoiceType,
                    td.Discount,
                    td.TaxableAmount,
                    td.TaxAmount,
                    td.ItemSubtotal
                FROM tblInvoiceDetail td
                INNER JOIN tblInvoiceSummary ts ON td.InvoiceNo COLLATE SQL_Latin1_General_CP1256_CI_AS = ts.InvoiceNo
                WHERE Status = 'Posted'
                      --AND YEAR(ts.InvoiceDate) BETWEEN @StartYear AND @EndYear
                UNION
                SELECT
                    YEAR(ts.InvoiceDate) InvoiceYear,
					Month(ts.InvoiceDate) InvoiceMonth,
					datename(month,ts.InvoiceDate) InvoiceMonthName,
                    'Uniform' AS InvoiceType,
                    td.Discount,
                    td.TaxableAmount,
                    td.TaxAmount,
                    td.ItemSubtotal
                FROM tblUniformDetails td
                INNER JOIN tblInvoiceSummary ts ON td.InvoiceNo COLLATE SQL_Latin1_General_CP1256_CI_AS = ts.InvoiceNo
                WHERE Status = 'Posted'
                     --AND YEAR(ts.InvoiceDate) BETWEEN @StartYear AND @EndYear
            ) t
        ) finalResult
		 GROUP BY finalResult.InvoiceYear,finalResult.InvoiceMonth,finalResult.InvoiceMonthName,
        finalResult.Discount, finalResult.TaxableAmount, finalResult.TaxAmount,
		finalResult.ItemSubtotal
        UNION
        SELECT
            InvoiceYear,
			InvoiceMonth,
			InvoiceMonthName,
            Discount = SUM(Discount),
            TaxableAmount = SUM(TaxableAmount),
            TaxAmount = SUM(TaxAmount),
            ItemSubtotal = SUM(ItemSubtotal)
        FROM (
            SELECT
                InvoiceYear,
				InvoiceMonth,
				InvoiceMonthName,
                Discount = CASE WHEN InvoiceType = 'Return' THEN (Discount * -1) ELSE Discount END,
                TaxableAmount = CASE WHEN InvoiceType = 'Return' THEN (TaxableAmount * -1) ELSE TaxableAmount END,
                TaxAmount = CASE WHEN InvoiceType = 'Return' THEN (TaxAmount * -1) ELSE TaxAmount END,
                ItemSubtotal = CASE WHEN InvoiceType = 'Return' THEN (ItemSubtotal * -1) ELSE ItemSubtotal END
            FROM (
                SELECT
                    YEAR(ts.InvoiceDate) InvoiceYear,
					Month(ts.InvoiceDate) InvoiceMonth,
					datename(month,ts.InvoiceDate) InvoiceMonthName,
                    ts.InvoiceType,
                    Discount = CAST(td.Discount AS DECIMAL(18, 2)),
                    TaxableAmount = CAST(td.TaxableAmount AS DECIMAL(18, 2)),
                    TaxAmount = CAST(td.TaxAmount AS DECIMAL(18, 2)),
                    ItemSubtotal = CAST(td.ItemSubtotal AS DECIMAL(18, 2))
                FROM INVOICE.dbo.InvoiceDetails td
                INNER JOIN INVOICE.dbo.InvoiceSummary ts ON td.InvoiceNo COLLATE SQL_Latin1_General_CP1256_CI_AS = ts.InvoiceNo
                WHERE Status = 'Posted'
                      --AND YEAR(ts.InvoiceDate) BETWEEN @StartYear AND @EndYear
                UNION
                SELECT
                    YEAR(ts.InvoiceDate) InvoiceYear,
					Month(ts.InvoiceDate) InvoiceMonth,
					datename(month,ts.InvoiceDate) InvoiceMonthName,
                    'Uniform' AS InvoiceType,
                    Discount = CAST(td.Discount AS DECIMAL(18, 2)),
                    TaxableAmount = CAST(td.TaxableAmount AS DECIMAL(18, 2)),
                    TaxAmount = CAST(td.TaxAmount AS DECIMAL(18, 2)),
                    ItemSubtotal = CAST(td.ItemSubtotal AS DECIMAL(18, 2))
                FROM INVOICE.dbo.UniformDetails td
                INNER JOIN INVOICE.dbo.InvoiceSummary ts ON td.InvoiceNo COLLATE SQL_Latin1_General_CP1256_CI_AS = ts.InvoiceNo
                WHERE Status = 'Posted'
                     --AND YEAR(ts.InvoiceDate) BETWEEN @StartYear AND @EndYear
            ) t
        ) finalResult
        GROUP BY finalResult.InvoiceYear,finalResult.InvoiceMonth,finalResult.InvoiceMonthName
    ) t
    GROUP BY t.InvoiceYear,t.InvoiceMonth,t.InvoiceMonthName;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetInvoiceDetail]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetInvoiceDetail]        
 @InvoiceDetailId bigint = 0        
AS        
BEGIN        
 SET NOCOUNT ON;         
 SELECT tid.InvoiceDetailId        
 ,tid.InvoiceType  
 ,tid.AcademicYear
 ,tid.ParentId   
 ,tid.ParentName
 ,tid.StudentId      
 ,tid.StudentName      
 ,tid.Quantity   
 ,tid.TotalVat  
 ,tid.TaxableAmount  
 ,tid.ItemSubtotal
 FROM INV_InvoiceDetail tid          
 WHERE tid.InvoiceDetailId = CASE WHEN @InvoiceDetailId > 0 THEN @InvoiceDetailId ELSE tid.InvoiceDetailId END         
  AND tid.IsDeleted =  0        
  ORDER BY tid.Description        
END 

GO
/****** Object:  StoredProcedure [dbo].[sp_GetInvoiceNo]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_GetInvoiceNo]
as
begin
	
	update INVOICE.[dbo].[Transactions]
	set TransactionNo=TransactionNo+1
	where TransactionID=1

	select TransactionNo as Result 
	from INVOICE.[dbo].[Transactions]
	where TransactionID=1


end
GO
/****** Object:  StoredProcedure [dbo].[sp_GetInvoiceType]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetInvoiceType]
	@InvoiceTypeId bigint = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterIsActive bit=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tit.InvoiceTypeId
		,tit.InvoiceTypeName	
		,tit.ReceivableAccount
		,tit.AdvanceAccount
		,tit.ReceivableAccountRemarks
		,tit.AdvanceAccountRemarks
		,tit.IsActive		
	FROM tblInvoiceTypeMaster tit		
	WHERE tit.InvoiceTypeId = CASE WHEN @InvoiceTypeId > 0 THEN @InvoiceTypeId ELSE tit.InvoiceTypeId END
		AND (tit.InvoiceTypeName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tit.InvoiceTypeName END + '%')
		AND tit.IsActive =  CASE WHEN  @InvoiceTypeId>0 THEN tit.IsActive ELSE @FilterIsActive  END
		AND tit.IsDeleted =  0
	ORDER BY tit.InvoiceTypeName
END
GO
/****** Object:  StoredProcedure [dbo].[Sp_GetItemCodeRecord]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Sp_GetItemCodeRecord]  
@ItemCode nvarchar(200)  
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
 select top 1 @VatPercent=ISNULL(VatTaxPercent,0) from [dbo].[tblFeeTypeMaster] fm
   inner join [dbo].[tblVatMaster] fd on fm.FeeTypeId=fd.FeeTypeId
   where fm.FeeTypeId=1 OR fm.FeeTypeName like '%uniform%'
   and fm.IsActive=1 and fm.IsDeleted=0
   and fd.IsActive=1 and fd.IsDeleted=0  
   
 SELECT top 1   
 A.CURRCOST AS CurrentPrice,  
 A.ITEMNMBR as ItemCode,  
 A.ITEMDESC as ItemDescription,  
 B.QTYONHND as QuantityOnHand,  
 B.ATYALLOC as QuantityAllocated,  
 AvailableQuantity= B.QTYONHND-B.ATYALLOC  ,
 VatPercent = @VatPercent  
 FROM [TWO].[dbo].IV00101 A  
 join [TWO].[dbo].IV00102 B   
 on A.ITEMNMBR=b.ITEMNMBR  
 where A.ITEMNMBR=@ItemCode  
 AND B.LOCNCODE=''  

end
GO
/****** Object:  StoredProcedure [dbo].[sp_GetNotificationGenerateFee]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetNotificationGenerateFee]
	@FeeGenerateId int=0
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT 
		tfg.FeeGenerateId
		,tfg.SchoolAcademicId
		,tsa.AcademicYear
		,tfg.FeeTypeId
		,tf.FeeTypeName
		,tfg.GradeId
		,CONCAT_WS(' - ',tg.GradeName, tgtm.GenderTypeName) AS GradeName
		,tfg.GenerateStatus
		,tfg.UpdateDate
		,tfg.UpdateBy
		,COUNT(tfgd.FeeGenerateDetailId) AS StudentCount
	FROM tblFeeGenerate tfg
	INNER JOIN tblSchoolAcademic tsa
		ON tfg.SchoolAcademicId = tsa.SchoolAcademicId
	INNER JOIN tblFeeTypeMaster tf
		ON tfg.FeeTypeId = tf.FeeTypeId
	INNER JOIN tblGradeMaster tg
		ON tfg.GradeId = tg.GradeId
	LEFT JOIN tblGenderTypeMaster tgtm   
		ON tgtm.GenderTypeId = tg.GenderTypeId  
	LEFT JOIN tblFeeGenerateDetail tfgd 
		ON tfg.FeeGenerateId = tfgd.FeeGenerateId 
	GROUP BY 
		tfg.FeeGenerateId
		,tfg.SchoolAcademicId
		,tsa.AcademicYear
		,tfg.FeeTypeId
		,tf.FeeTypeName
		,tfg.GradeId
		,CONCAT_WS(' - ',tg.GradeName, tgtm.GenderTypeName) 
		,tfg.GenerateStatus
		,tfg.UpdateDate
		,tfg.UpdateBy
	HAVING tfg.FeeGenerateId=CASE WHEN @FeeGenerateId>0 THEN @FeeGenerateId ELSE tfg.FeeGenerateId END
	AND tfg.GenerateStatus=2

	SELECT tfg.FeeGenerateDetailId
			,tfg.FeeGenerateId
			,tfg.StudentId
			,tfg.SchoolAcademicId
			,tsa.AcademicYear
			,tfg.GradeId
			,CONCAT_WS(' - ',tg.GradeName, tgtm.GenderTypeName) AS GradeName
			,tfg.FeeTypeId
			,tf.FeeTypeName
			,tfg.FeeAmount
			,tfg.UpdateDate
			,tfg.UpdateBy
	FROM tblFeeGenerateDetail tfg
	INNER JOIN tblSchoolAcademic tsa
		ON tfg.SchoolAcademicId = tsa.SchoolAcademicId
	INNER JOIN tblFeeTypeMaster tf
		ON tfg.FeeTypeId = tf.FeeTypeId
	INNER JOIN tblGradeMaster tg
		ON tfg.GradeId = tg.GradeId
	LEFT JOIN tblGenderTypeMaster tgtm   
		ON tgtm.GenderTypeId = tg.GenderTypeId 
	WHERE FeeGenerateId=CASE WHEN @FeeGenerateId>0 THEN @FeeGenerateId ELSE FeeGenerateId END
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetNotificationGroup]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetNotificationGroup]
	@LoginUserId int=0
AS
BEGIN
	SELECT 
		ng.NotificationGroupId
		,ng.NotificationTypeId
		,ng.NotificationCount
		,ng.NotificationAction
		,nt.NotificationType
		,nt.ActionTable
		,nt.NotificationActionTable
		,REPLACE(REPLACE(nt.NotificationMsg,'#N',ng.NotificationCount),'#Action',CASE WHEN NotificationAction=1 THEN 'Added' WHEN NotificationAction=2 THEN 'Updated' WHEN NotificationAction=3 THEN 'Deleted' ELSE '' END) AS NotificationMsg
	from tblNotificationGroup ng
	INNER JOIN tblNotificationTypeMaster nt
		ON nt.NotificationTypeId=ng.NotificationTypeId
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetNotificationGroupDetail]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetNotificationGroupDetail]
	@NotificationGroupId int=0
	,@NotificationTypeId int=0
AS
BEGIN
	SELECT ngd.NotificationGroupDetailId
		,ngd.NotificationGroupId
		,ngd.NotificationTypeId
		,ngd.NotificationAction
		,ngd.TableRecordId
		,ngd.OldValueJson
		,ngd.NewValueJson
		,ngd.CreatedBy 
		,nt.NotificationType
		,nt.ActionTable
		,tu.UserName
		,CASE WHEN ngd.NotificationAction=1 THEN 'Added' WHEN ngd.NotificationAction=2 THEN 'Updated' WHEN ngd.NotificationAction=3 THEN 'Deleted' END AS RecordAction
	FROM tblNotificationGroupDetail ngd
	--INNER JOIN tblNotificationGroup ng
	--	ON ng.NotificationGroupId=ngd.NotificationGroupId
	INNER JOIN tblNotificationTypeMaster nt
		ON nt.NotificationTypeId=ngd.NotificationTypeId
	INNER JOIN tblUser tu
		ON tu.UserId =ngd.CreatedBy
	WHERE ngd.NotificationGroupId=@NotificationGroupId AND ngd.NotificationTypeId=@NotificationTypeId
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetNotificationGroupDetailById]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_GetNotificationGroupDetailById]
	@NotificationGroupDetailId bigint
AS
BEGIN
	SELECT ngd.NotificationGroupDetailId
		,ngd.NotificationGroupId
		,ngd.NotificationTypeId
		,ngd.NotificationAction
		,ngd.TableRecordId
		,ngd.OldValueJson
		,ngd.NewValueJson
		,ngd.CreatedBy 
		,nt.NotificationType
		,nt.ActionTable
		,tu.UserName
		,CASE WHEN ngd.NotificationAction=1 THEN 'Added' WHEN ngd.NotificationAction=2 THEN 'Updated' WHEN ngd.NotificationAction=3 THEN 'Deleted' END AS RecordAction
	FROM tblNotificationGroupDetail ngd
	--INNER JOIN tblNotificationGroup ng
	--	ON ng.NotificationGroupId=ngd.NotificationGroupId
	INNER JOIN tblNotificationTypeMaster nt
		ON nt.NotificationTypeId=ngd.NotificationTypeId
	INNER JOIN tblUser tu
		ON tu.UserId =ngd.CreatedBy
	WHERE ngd.NotificationGroupDetailId=@NotificationGroupDetailId
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetNotificationList]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_GetNotificationList]
@UserId int=0
as
begin
	select NotificationId
			,RecordId
			,RecordStatus
			,IsApproved
			,RecordType
			,UpdateDate
			,UpdateBy
			,student_id 
	from tblNotification
	where IsApproved=0 and UpdateDate>=getdate()-1
end
GO
/****** Object:  StoredProcedure [dbo].[sp_GetOpenApply]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetOpenApply]  
 @OpenApplyId bigint = 0,  
 @FilterSearch NVarChar(200)=null,  
 @FilterIsActive bit=1  
AS  
BEGIN  
 SET NOCOUNT ON;   
 SELECT top 1
	tgt.OpenApplyId
	,tgt.GrantType
	,tgt.ClientId
	,tgt.ClientSecret
	,tgt.Audience
	,tgt.OpenApplyJobPath
	,tgt.IsDeleted
	,tgt.IsActive
 FROM [tblOpenApplyMaster] tgt    
 WHERE tgt.OpenApplyId = CASE WHEN @OpenApplyId > 0 THEN @OpenApplyId ELSE tgt.OpenApplyId END   
 and IsDeleted=0 and IsActive=1
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetParent]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec sp_GetParent
--@ParentId=330,
--@FilterSearch=null,
--@FilterNationalityId=0,
--@FilterIsActive=1
--Go

CREATE PROCEDURE [dbo].[sp_GetParent]    
 @ParentId bigint = 0,    
 @FilterSearch NVarChar(200)=null,    
 @FilterIsActive bit=1,    
 @FilterNationalityId int= 0    
AS    
BEGIN    
 SET NOCOUNT ON;     
 SELECT tp.ParentId    
  ,tp.ParentCode    
  ,tp.ParentImage    
  ,tp.FatherName    
  ,tp.FatherArabicName    
  ,tp.FatherNationalityId    
  ,tp.FatherMobile    
  ,tp.FatherEmail    
  ,tp.FatherIqamaNo    
  ,tp.IsFatherStaff     
   ,ftc.CountryName as FatherCountryName

  ,tp.MotherName    
  ,tp.MotherArabicName    
  ,tp.MotherNationalityId    
  ,tp.MotherMobile    
  ,tp.MotherEmail    
  ,tp.MotherIqamaNo    
  ,tp.IsMotherStaff  
  ,mtc.CountryName as MotherCountryName
  ,tp.IsActive    
  ,tp.IsDeleted    
  ,tp.UpdateDate    
  ,tp.UpdateBy      
 FROM tblParent tp     
 LEFT JOIN tblCountryMaster ftc    
  ON ftc.CountryId = tp.FatherNationalityId    
 LEFT JOIN tblCountryMaster mtc    
  ON mtc.CountryId = tp.MotherNationalityId    
 WHERE tp.ParentId = CASE WHEN @ParentId > 0 THEN @ParentId ELSE tp.ParentId END    
  --AND (tp.ParentCode LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.ParentCode END + '%'    
  -- OR tp.FatherName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.FatherName END + '%'    
  -- OR tp.FatherArabicName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.FatherArabicName END + '%'    
  -- OR ftc.CountryName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE ftc.CountryName END + '%'    
  -- OR tp.FatherMobile LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.FatherMobile END + '%'    
  -- OR tp.FatherEmail LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.FatherEmail END + '%'    
  -- OR tp.MotherName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.MotherName END + '%'    
  -- OR mtc.CountryName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE mtc.CountryName END + '%'    
  -- OR tp.MotherMobile LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.MotherMobile END + '%'    
  -- OR tp.MotherEmail LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tp.MotherEmail END + '%'    
  --)    
  AND tp.IsActive =  CASE WHEN  @ParentId > 0 THEN tp.IsActive ELSE @FilterIsActive  END    
  --AND (tp.FatherNationalityId = CASE WHEN @FilterNationalityId > 0 THEN @FilterNationalityId ELSE tp.FatherNationalityId END    
  --OR tp.MotherNationalityId = CASE WHEN @FilterNationalityId > 0 THEN @FilterNationalityId ELSE tp.MotherNationalityId END)    
  AND tp.IsDeleted =  0    
 ORDER BY tp.ParentCode    
 IF @ParentId>0    
 BEGIN    
 SELECT     
  stu.StudentId    
  ,stu.StudentCode    
  ,stu.StudentImage    
  ,stu.ParentId    
  ,tp.ParentCode    
  ,stu.StudentName    
  ,stu.StudentArabicName    
  ,stu.StudentEmail    
  ,stu.DOB    
  ,stu.IqamaNo    
  ,stu.NationalityId    
  ,tc.CountryName    
  ,stu.GenderId    
  ,tgt.GenderTypeName    
  ,stu.AdmissionDate    
  ,stu.CostCenterId    
  ,tcc.CostCenterName    
  ,stu.GradeId    
  ,tg.GradeName    
  ,stu.SectionId    
  ,ts.SectionName    
  ,stu.PassportNo    
  ,stu.PassportExpiry    
  ,stu.Mobile    
  ,stu.StudentAddress    
  ,stu.StudentStatusId    
  ,tss.StatusName    
 ,Fees=isnull(stu.Fees  ,0)    
  ,stu.IsGPIntegration    
  ,stu.WithdrawDate    
  ,WithdrawAt=isnull(stu.WithdrawAt ,0)    
  ,tt1.TermName AS WithdrawAtTermName    
  ,stu.WithdrawYear    
 ,TermId=isnull(stu.TermId  ,0)    
  ,tt.TermName    
  ,stu.AdmissionYear    
   ,PrinceAccount=isnull(stu.PrinceAccount  ,0)    
  ,stu.IsActive     
 FROM tblStudent stu     
 INNER JOIN tblParent tp    
  ON tp.ParentId = stu.ParentId    
 INNER JOIN tblCountryMaster tc    
  ON tc.CountryId = stu.NationalityId    
 INNER JOIN tblGenderTypeMaster tgt    
  ON tgt.GenderTypeId = stu.GenderId    
 LEFT JOIN tblCostCenterMaster tcc    
  ON tcc.CostCenterId = stu.CostCenterId    
 LEFT JOIN tblGradeMaster tg    
  ON tg.GradeId = stu.GradeId    
 LEFT JOIN tblSection ts    
  ON ts.SectionId = stu.SectionId    
 LEFT JOIN tblStudentStatus tss    
  ON tss.StudentStatusId = stu.StudentStatusId    
 LEFT JOIN tblTermMaster tt    
  ON tt.TermId=stu.TermId    
 LEFT JOIN tblTermMaster tt1    
  ON tt1.TermId=stu.WithdrawAt    
 WHERE stu.ParentId=@ParentId     
  AND stu.IsDeleted =  0 AND stu.IsActive = 1    
 ORDER BY stu.StudentName    
 END    
 IF @ParentId>0    
 BEGIN    
 SELECT     
  tpa.ParentId    
  ,tpa.ReceivableAccount    
  ,tpa.AdvanceAccount      
 FROM tblParentAccount tpa      
 WHERE tpa.ParentId=@ParentId     
  AND tpa.IsDeleted =  0 AND tpa.IsActive = 1    
 END    
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetParentById]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create proc [dbo].[sp_GetParentById]
@ParentId bigint
as
begin
select * from tblParent where ParentId = @ParentId
end
GO
/****** Object:  StoredProcedure [dbo].[sp_GetParentLookup]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetParentLookup]  
	@LookupParentId NVarChar(200)=null,
	@LookupFatherName NVarChar(400)=null,
	@LookupFatherArabic NVarChar(400)=null,
	@LookupMotherName NVarChar(400)=null,
	@LookupMotherArabic NVarChar(400)=null
AS  
BEGIN  
 SET NOCOUNT ON; 
 SELECT tp.ParentId
		,tp.ParentCode
		,tp.FatherName
		,tp.FatherArabicName
		,tp.FatherIqamaNo
		,tp.IsFatherStaff	
		,tp.MotherName
		,tp.MotherArabicName
	FROM tblParent tp		
	WHERE  tp.ParentCode LIKE '%'+ CASE WHEN len(@LookupParentId) > 0 THEN @LookupParentId ELSE tp.ParentCode END + '%'
		AND tp.FatherName LIKE '%'+ CASE WHEN len(@LookupFatherName) > 0 THEN @LookupFatherName ELSE tp.FatherName END + '%'
		AND ISNULL(tp.FatherArabicName,0) LIKE '%'+ CASE WHEN len(@LookupFatherArabic) > 0 THEN @LookupFatherArabic ELSE ISNULL(tp.FatherArabicName,0) END + '%'
		AND ISNULL(tp.MotherName,0) LIKE '%'+ CASE WHEN len(@LookupMotherName) > 0 THEN @LookupMotherName ELSE ISNULL(tp.MotherName,0) END + '%'
		AND ISNULL(tp.MotherArabicName,0) LIKE '%'+ CASE WHEN len(@LookupMotherArabic) > 0 THEN @LookupMotherArabic ELSE ISNULL(tp.MotherArabicName,0) END + '%'		
		AND tp.IsActive =  1		
		AND tp.IsDeleted =  0
	ORDER BY tp.ParentCode
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetSchool]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetSchool]
	@SchoolId bigint = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterIsActive bit=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT TOP 1 tsm.SchoolId
		,tsm.SchoolNameEnglish
		,tsm.SchoolNameArabic
		,tsm.BranchId
		,tb.BranchName
		,tsm.CountryId
		,tc.CountryName
		,tsm.City
		,tsm.[Address]
		,tsm.Telephone
		,tsm.SchoolEmail
		,tsm.WebsiteUrl
		,tsm.VatNo
		,tsm.Logo
		,tsm.IsActive
	FROM tblSchoolMaster tsm	
	INNER JOIN tblBranchMaster tb
		ON tb.BranchId=tsm.BranchId
	LEFT JOIN tblCountryMaster tc
		ON tc.CountryId=tsm.CountryId
	WHERE tsm.SchoolId =CASE WHEN @SchoolId > 0 THEN @SchoolId ELSE tsm.SchoolId END		
		AND tsm.IsDeleted =  0 AND tsm.IsActive=1
	ORDER BY tsm.SchoolNameEnglish
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetSchoolAcademic]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetSchoolAcademic]
	@SchoolAcademicId int = 0
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tsa.SchoolAcademicId
			,tsa.AcademicYear
			,tsa.PeriodFrom
			,tsa.PeriodTo
			,tsa.DebitAccount
			,tsa.CreditAccount
			,tsa.IsActive
	FROM tblSchoolAcademic tsa		
	WHERE tsa.SchoolAcademicId = CASE WHEN @SchoolAcademicId> 0 THEN @SchoolAcademicId ELSE tsa.SchoolAcademicId END	
		AND tsa.IsDeleted = 0
	 ORDER BY tsa.SchoolAcademicId
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetSchoolAccountInfo]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetSchoolAccountInfo]  
 @SchoolId bigint = 0,  
 @SchoolAccountIId bigint = 0  
AS  
BEGIN  
 SET NOCOUNT ON;   
 SELECT  
	tsa.SchoolAccountIId  
	,tsa.SchoolId 
	,tsa.ReceivableAccount
	,tsa.AdvanceAccount
	,tsa.CodeDescription  
	,tsa.IsActive    
 FROM tblSchoolAccountInfo tsa    
 WHERE tsa.SchoolAccountIId = CASE WHEN @SchoolAccountIId> 0 THEN @SchoolAccountIId ELSE tsa.SchoolAccountIId END   
  AND tsa.IsDeleted =  0 AND IsActive=1  
  AND  tsa.SchoolId=@SchoolId  
  ORDER BY tsa.CodeDescription  
END  
GO
/****** Object:  StoredProcedure [dbo].[sp_GetSchoolLogoImage]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetSchoolLogoImage]
	@SchoolId bigint = 0
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT [SchoolLogoId]
		,[SchoolId]
		,[LogoName]
		,[LogoPath]
	FROM tblSchoolLogo		
	WHERE SchoolId = @SchoolId AND IsDeleted =  0 AND IsActive=1
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetSchoolTermAcademic]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- *** SqlDbx Personal Edition ***
-- !!! Not licensed for commercial use beyound 90 days evaluation period !!!
-- For version limitations please check http://www.sqldbx.com/personal_edition.htm
-- Number of queries executed: 14, number of rows retrieved: 48

CREATE PROCEDURE [dbo].[sp_GetSchoolTermAcademic]  
 @SchoolTermAcademicId int = 0  
AS  
BEGIN  
 SET NOCOUNT ON;   
 SELECT tsa.SchoolTermAcademicId  
   ,tsa.SchoolAcademicId  
   ,sa.AcademicYear     
   ,tsa.TermName  
   ,tsa.StartDate   
   ,tsa.EndDate  
   ,tsa.IsApproved 
   ,tsa.IsRejected
 FROM tblSchoolTermAcademic tsa   
 INNER JOIN tblSchoolAcademic sa  
  ON sa.SchoolAcademicId=tsa.SchoolAcademicId   
 WHERE tsa.SchoolTermAcademicId = CASE WHEN @SchoolTermAcademicId> 0 THEN @SchoolTermAcademicId ELSE tsa.SchoolTermAcademicId END   
  AND tsa.IsDeleted = 0  
  ORDER BY tsa.SchoolTermAcademicId  
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetSections]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_GetSections]
	@SectionId int = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterIsActive bit=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tgs.SectionId
		,tgs.SectionName	
		,tgs.IsActive		
	FROM tblSection tgs	
	WHERE tgs.SectionId = CASE WHEN @SectionId > 0 THEN @SectionId ELSE tgs.SectionId END
		AND (tgs.SectionName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tgs.SectionName END + '%')	
		AND tgs.IsActive =  CASE WHEN  @SectionId>0 THEN tgs.IsActive ELSE @FilterIsActive  END
		AND tgs.IsDeleted =0 AND tgs.IsDeleted = 0
	ORDER BY tgs.SectionName
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetStudent]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetStudent]      
	@StudentId bigint = 0,      
	@FilterSearch NVarChar(200)=null,      
	@FilterIsActive bit=1,      
	@FilterStatusId int=1,      
	@FilterNationalityId int= 0 ,      
	@FilterGenderId int= 0 ,      
	@FilterGradeId int= 0 ,      
	@FilterCostCenterId int= 0 ,      
	@FilterSectionId int= 0 ,      
	@FilterTermId int= 0  
	,@FilterEmail NvarChar(200)=null 
	,@FilterMobileNumber nvarchar(20) = null
AS      
BEGIN      
	SET NOCOUNT ON;       
	select * from vw_Student stu
	WHERE stu.StudentId= CASE WHEN @StudentId > 0 THEN @StudentId ELSE stu.StudentId END      
		
		--And stu.StudentEmail = CASE WHEN len(@FilterEmail) > 0 THEN @FilterEmail ELSE stu.StudentEmail End
		--And stu.Mobile = CASE WHEN len(@FilterMobileNumber) > 0 THEN @FilterMobileNumber End
		AND stu.IsActive =  CASE WHEN  @StudentId > 0 THEN stu.IsActive ELSE @FilterIsActive  END      
		AND stu.StudentStatusId = CASE WHEN @FilterStatusId > 0 THEN @FilterStatusId ELSE stu.StudentStatusId END     
		AND stu.NationalityId = CASE WHEN @FilterNationalityId > 0 THEN @FilterNationalityId ELSE stu.NationalityId END    
		AND stu.GenderId = CASE WHEN @FilterGenderId > 0 THEN @FilterGenderId ELSE stu.GenderId END    
		AND stu.GradeId = CASE WHEN @FilterGradeId > 0 THEN @FilterGradeId ELSE stu.GradeId END    
		AND stu.CostCenterId = CASE WHEN @FilterCostCenterId > 0 THEN @FilterCostCenterId ELSE stu.CostCenterId END    
		AND stu.SectionId = CASE WHEN @FilterSectionId > 0 THEN @FilterSectionId ELSE stu.SectionId END    
		AND stu.TermId = CASE WHEN @FilterTermId > 0 THEN @FilterTermId ELSE stu.TermId END     
		AND stu.IsDeleted =  0 
		AND stu.IsActive = 1
		
		AND 
		(
			stu.StudentName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE stu.StudentName END + '%'      
			OR ISNULL(stu.StudentArabicName,'') LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE ISNULL(stu.StudentArabicName,'') END + '%'  
			OR stu.IqamaNo LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE stu.IqamaNo END + '%' 
			OR stu.StudentEmail LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE stu.StudentEmail END + '%' 
			OR stu.Mobile LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE stu.Mobile END + '%' 

			----parent search
			OR ISNULL(stu.ParentCode,'') LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE ISNULL(stu.ParentCode,'') END + '%'  
			OR stu.FatherName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE stu.FatherName END + '%' 
			OR stu.FatherArabicName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE stu.FatherArabicName END + '%' 
			OR stu.FatherMobile LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE stu.FatherMobile END + '%' 
			OR stu.FatherEmail LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE stu.FatherEmail END + '%' 
			OR stu.FatherIqamaNo LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE stu.FatherIqamaNo END + '%' 

			----mother search

			OR ISNULL(stu.MotherArabicName,'') LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE ISNULL(stu.MotherArabicName,'') END + '%'  
			OR stu.MotherName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE stu.MotherName END + '%' 
			OR stu.MotherMobile LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE stu.MotherMobile END + '%' 
			OR stu.MotherEmail LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE stu.MotherEmail END + '%' 
			OR stu.MotherIqamaNo LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE stu.MotherIqamaNo END + '%'
		) 

	ORDER BY cast(stu.StudentCode as bigint)
	IF @StudentId>0      
	BEGIN      
		SELECT tp.ParentId      
			,tp.ParentCode      
			,tp.ParentImage      
			,tp.FatherName      
			,tp.FatherArabicName      
			,tp.FatherMobile      
			,tp.FatherEmail      
			,tp.IsFatherStaff       
			,tp.MotherName      
			,tp.MotherArabicName      
			,tp.MotherMobile      
			,tp.MotherEmail      
			,tp.IsMotherStaff      
		FROM tblParent tp       
		INNER JOIN tblStudent stu      
			ON stu.ParentId=tp.ParentId       
		WHERE stu.StudentId = @StudentId       
			AND tp.IsActive =  1 AND tp.IsDeleted =  0  
		
		SELECT       
		stu.StudentId      
		,stu.StudentCode      
		,stu.StudentImage      
		,stu.ParentId      
		,tp.ParentCode      
		,stu.StudentName      
		,stu.StudentArabicName      
		,stu.StudentEmail      
		,stu.DOB      
		,stu.IqamaNo      
		,stu.NationalityId      
		,tc.CountryName      
		,stu.GenderId      
		,tgt.GenderTypeName      
		,stu.AdmissionDate      
		,stu.CostCenterId      
		,tcc.CostCenterName      
		,stu.GradeId      
		,tg.GradeName      
		,stu.SectionId      
		,ts.SectionName      
		,stu.PassportNo      
		,stu.PassportExpiry      
		,stu.Mobile      
		,stu.StudentAddress      
		,stu.StudentStatusId      
		,tss.StatusName      
		,Fees=isnull(stu.Fees  ,0)    
		,stu.IsGPIntegration      
		,stu.WithdrawDate      
		,WithdrawAt=isnull(stu.WithdrawAt ,0)    
		,tt1.TermName AS WithdrawAtTermName      
		,stu.WithdrawYear      
		,TermId=isnull(stu.TermId  ,0)    
		,tt.TermName      
		,stu.AdmissionYear      
		,PrinceAccount=isnull(stu.PrinceAccount  ,0)    
		,stu.IsActive       
	FROM tblStudent stu       
	LEFT JOIN tblParent tp      
		ON tp.ParentId = stu.ParentId      
	LEFT JOIN tblCountryMaster tc      
		ON tc.CountryId = stu.NationalityId      
	LEFT JOIN tblGenderTypeMaster tgt      
		ON tgt.GenderTypeId = stu.GenderId      
	LEFT JOIN tblCostCenterMaster tcc      
		ON tcc.CostCenterId = stu.CostCenterId      
	LEFT JOIN tblGradeMaster tg      
		ON tg.GradeId = stu.GradeId      
	LEFT JOIN tblSection ts      
		ON ts.SectionId = stu.SectionId      
	LEFT JOIN tblStudentStatus tss      
		ON tss.StudentStatusId = stu.StudentStatusId      
	LEFT JOIN tblTermMaster tt      
		ON tt.TermId=stu.TermId      
	LEFT JOIN tblTermMaster tt1      
		ON tt1.TermId=stu.WithdrawAt      
	WHERE stu.ParentId= (SELECT stu1.ParentId FROM tblStudent stu1 WHERE stu1.StudentId=@StudentId)
		AND stu.StudentId<>@StudentId
		AND stu.IsDeleted =  0 AND stu.IsActive = 1  
	ORDER BY cast(stu.StudentCode as bigint)

	END      
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetStudentById]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_GetStudentById]
@StudentId bigint
as
begin
select * from tblStudent where StudentId = @StudentId
end
GO
/****** Object:  StoredProcedure [dbo].[sp_GetStudentByParentId]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_GetStudentByParentId]
@ParentId bigint
as
begin
select * from tblStudent where ParentId = @ParentId
end
GO
/****** Object:  StoredProcedure [dbo].[sp_GetStudentFeeDetail]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetStudentFeeDetail]  
 @StudentId INT
 ,@StudentFeeDetailId INT=0
AS  
BEGIN  
	SET NOCOUNT ON;   
	SELECT tsfd.StudentFeeDetailId  
		,tsfd.AcademicYearId  
		,tsfd.StudentId  
		,tsfd.GradeId  
		,tsfd.FeeTypeId  
		,ftd.FeeTypeName
		,tsfd.FeeAmount  
		,tsfd.IsActive  
		,tgm.GradeName
		,aca.AcademicYear
	FROM tblStudentFeeDetail tsfd   
	INNER JOIN tblGradeMaster tgm  
		ON tsfd.GradeId=tgm.GradeId
	INNER JOIN [tblSchoolAcademic] aca 
		ON tsfd.AcademicYearId=aca.SchoolAcademicId
	INNER JOIN tblFeeTypeMaster ftd 
		ON ftd.FeeTypeId=tsfd.FeeTypeId
	WHERE tsfd.StudentId = @StudentId
		AND tsfd.IsDeleted = 0  
		AND tsfd.StudentFeeDetailId = CASE WHEN @StudentFeeDetailId>0 THEN @StudentFeeDetailId ELSE tsfd.StudentFeeDetailId END
	ORDER BY tsfd.StudentFeeDetailId  
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetStudentFeeTypeAmount]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetStudentFeeTypeAmount] 
	 @StudentId bigint
	,@GradeId bigint
	,@FeeTypeId bigint
	,@AcademicYearId bigint 
AS  
BEGIN  
	SET NOCOUNT ON; 
	DECLARE @IsStaff bit
	SELECT @IsStaff=CASE WHEN tp.IsFatherStaff=1 THEN 1 WHEN tp.IsMotherStaff=1 THEN 1 ELSE 0 END FROM tblStudent st
	INNER JOIN tblParent tp
		ON st.ParentId=tp.ParentId
	WHERE st.StudentId=@StudentId
	
	SELECT CASE WHEN @IsStaff=0 THEN tfd.TermFeeAmount ELSE tfd.StaffFeeAmount END AS FeeAmount
	FROM tblFeeTypeDetail tfd  
	WHERE tfd.FeeTypeId=@FeeTypeId AND tfd.AcademicYearId=@AcademicYearId 
	AND ISNULL(tfd.GradeId,@GradeId)=@GradeId
	AND tfd.IsDeleted = 0  AND tfd.IsActive=1
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetStudentGrade]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetStudentGrade]  
	@StudentId int = 0  
AS  
BEGIN  
	SET NOCOUNT ON;   
	SELECT st.StudentId  
		,st.StudentCode
		,st.StudentName
		,st.GradeId
		,tgm.GradeName
	FROM tblStudent st   
	INNER JOIN tblGradeMaster tgm  
		ON tgm.GradeId=st.GradeId
	WHERE st.StudentId = @StudentId
		AND st.IsDeleted = 0  
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetStudentStatus]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetStudentStatus]
	@StudentStatusId bigint = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterIsActive int=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tss.StudentStatusId
		,tss.StatusName		
		,tss.IsActive		
	FROM tblStudentStatus tss		
	WHERE tss.StudentStatusId = CASE WHEN @StudentStatusId > 0 THEN @StudentStatusId ELSE tss.StudentStatusId END
		AND (tss.StatusName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tss.StatusName END + '%')
		AND tss.IsActive =  CASE WHEN  @StudentStatusId>0 THEN tss.IsActive ELSE @FilterIsActive  END
		AND tss.IsDeleted =  0
	ORDER BY tss.StatusName
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetTotalItemSubtotalsForYear]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_GetTotalItemSubtotalsForYear]
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare variables to hold the total subtotals
    DECLARE @InvoiceItemSubtotal DECIMAL(18, 2);
    DECLARE @UniformItemSubtotal DECIMAL(18, 2);
    DECLARE @TotalItemSubtotal DECIMAL(18, 2);
    DECLARE @ReturnInvoiceSubtotal DECIMAL(18, 2);

    -- Calculate the total item subtotal from tblInvoiceDetail for the specified year
    SELECT @InvoiceItemSubtotal = SUM(d.ItemSubtotal)
    FROM dbo.tblInvoiceDetail d
    JOIN dbo.tblInvoiceSummary s ON d.InvoiceNo = s.InvoiceNo
    WHERE YEAR(s.InvoiceDate) = @Year;

    -- Calculate the total item subtotal from tblUniformDetails for the specified year
    SELECT @UniformItemSubtotal = SUM(CAST(u.ItemSubtotal AS DECIMAL(18, 2)))
    FROM dbo.tblUniformDetails u
    JOIN dbo.tblInvoiceSummary s ON u.InvoiceNo = s.InvoiceNo
    WHERE YEAR(s.InvoiceDate) = @Year;

	-- Calculate the total item subtotal from tblInvoiceDetail for invoices of type 'Return' within the specified year
    SELECT @ReturnInvoiceSubtotal = SUM(d.ItemSubtotal)
    FROM dbo.tblInvoiceDetail d
    JOIN dbo.tblInvoiceSummary s ON d.InvoiceNo = s.InvoiceNo
    WHERE YEAR(s.InvoiceDate) = @Year
      AND d.InvoiceType = 'Return';


    -- Calculate the total of both subtotals
    SET @TotalItemSubtotal = @InvoiceItemSubtotal + @UniformItemSubtotal;

  

    -- Return the results
    SELECT
        @Year AS [Year],
        --@InvoiceItemSubtotal AS [TotalInvoiceItemSubtotal],
        --@UniformItemSubtotal AS [TotalUniformItemSubtotal],
        SUM(@TotalItemSubtotal) AS [TotalItemSubtotalWithinYear],
	   ISNULL(@ReturnInvoiceSubtotal, 0) AS [TotalReturnInvoiceSubtotal];
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetUsers]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_GetUsers]
	@UserId int = 0,
	@FilterSearch NVarChar(200)=null,
	@FilterRoleId int=0,
	@FilterIsActive bit=1
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tu.UserId
		,tu.UserName
		,tu.UserArabicName
		,tu.UserEmail
		,tu.UserPhone
		,tu.UserPass
		,tu.RoleId
		,trl.RoleName
		,tu.ProfileImg				
		,tu.IsActive		
	FROM tblUser tu
	INNER JOIN tblRole trl
		ON trl.RoleId = tu.RoleId	
	WHERE tu.UserId = CASE WHEN @UserId > 0 THEN @UserId ELSE tu.UserId END
		AND (tu.UserName LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tu.UserName END + '%'
		OR tu.UserEmail LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tu.UserEmail END + '%'
		OR tu.UserPhone LIKE '%'+ CASE WHEN len(@FilterSearch) > 0 THEN @FilterSearch ELSE tu.UserPhone END + '%')
		AND tu.RoleId = CASE WHEN @FilterRoleId > 0 THEN @FilterRoleId ELSE tu.RoleId END
		AND tu.IsActive =  CASE WHEN @UserId>0 THEN tu.IsActive ELSE @FilterIsActive  END
		AND tu.IsDeleted =0 AND trl.IsDeleted = 0
	ORDER BY tu.UserName
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetVat]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetVat]  
 @VatId bigint = 0  
AS  
BEGIN  
 SET NOCOUNT ON;   
 SELECT tvm.VatId  
	,tvm.FeeTypeId  
	,tft.FeeTypeName  
	,tvm.VatTaxPercent  
	,isnull(tvm.DebitAccount,'') as DebitAccount
	,isnull(tvm.CreditAccount,'') as CreditAccount
	,tvm.IsActive
	,CountryExcludeCount=(select isnull(count(VatCountryMapId),0) from [dbo].[tblVatCountryExclusionMap] t where  t.IsActive=1 and  t.IsDeleted=0 and t.VatId=tvm.VatId)
 FROM tblVatMaster tvm   
 INNER JOIN tblFeeTypeMaster tft  
  ON tvm.FeeTypeId=tft.FeeTypeId  
 WHERE tvm.VatId = CASE WHEN @VatId > 0 THEN @VatId ELSE tvm.VatId END  
  AND tvm.IsDeleted =  0 AND tvm.IsActive=1  
  ORDER BY tvm.VatTaxPercent  
END 

GO

/****** Object:  StoredProcedure [dbo].[sp_GetVatExemptedNation]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_GetVatExemptedNation]
	@VatId bigint
AS
BEGIN
	SET NOCOUNT ON;
	SELECT @VatId AS VatId

	SELECT tcm.CountryId
		,tcm.CountryName
	FROM tblCountryMaster tcm
	INNER JOIN tblVatCountryExclusionMap tvc
		ON tvc.CountryId = tcm.CountryId
	INNER JOIN tblVatMaster tv
		ON tv.VatId = tvc.VatId
	WHERE tcm.IsActive = 1 AND tcm.IsDeleted = 0
		AND tvc.IsActive = 1 AND tvc.IsDeleted = 0
		AND tv.VatId = @VatId
		AND tv.IsActive = 1 AND tv.IsDeleted = 0
	ORDER BY tcm.CountryName

	SELECT tcm.CountryId
		,tcm.CountryName
	FROM tblCountryMaster tcm
	WHERE tcm.IsActive = 1 AND tcm.IsDeleted = 0			
		
		AND tcm.CountryId NOT IN(SELECT tcm1.CountryId
	FROM tblCountryMaster tcm1
	INNER JOIN tblVatCountryExclusionMap tvc1
		ON tvc1.CountryId = tcm1.CountryId
	INNER JOIN tblVatMaster tv1
		ON tv1.VatId = tvc1.VatId
	WHERE tcm1.IsActive = 1 AND tcm1.IsDeleted = 0
		AND tvc1.IsActive = 1 AND tvc1.IsDeleted = 0
		AND tvc1.VatId = @VatId
		AND tv1.IsActive = 1 AND tv1.IsDeleted = 0)
	ORDER BY tcm.CountryName
END
GO
/****** Object:  StoredProcedure [dbo].[SP_ItemCodeRecords]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[SP_ItemCodeRecords]  
as  
begin  

select ltrim(rtrim(ITEMNMBR)) as ItemCode,	isnull(nullif(ltrim(rtrim(LOCNCODE)),''),ltrim(rtrim(ITEMNMBR))) as ItemCodeDescription 
from [TWO].[dbo].IV00102 where LOCNCODE=''
--select ItemCode,ItemCode as ItemCodeDescription  
--from   
--(  
-- select '100XLG' as ItemCode  
-- Union select '128 SDRAM'       
-- Union select '24X IDE'      
-- Union select '256 SDRAM                  '      
-- Union select '32 SDRAM                   '      
-- Union select '32X IDE                    '      
-- Union select '333PROC                    '      
-- Union select '4.5HD                      '      
-- Union select '400PROC                    '      
-- Union select '40X IDE                    '      
-- Union select '450PROC                    '      
-- Union select '500PROC                    '      
-- Union select '6.5HD                      '      
-- Union select '64 SDRAM                   '      
-- Union select '8.4HD                      '      
-- Union select 'A100                       '      
-- Union select 'ACCS-CRD-12WH              '      
-- Union select 'ACCS-CRD-25BK              '      
-- Union select 'ACCS-HDS-1EAR              '      
-- Union select 'ACCS-HDS-2EAR              '      
-- Union select 'ACCS-RST-DXBK              '      
-- Union select 'ACCS-RST-DXWH              '      
-- Union select 'ANSW-ATT-1000              '      
-- Union select 'ANSW-PAN-1450              '      
-- Union select 'ANSW-PAN-2460              '      
-- Union select 'ASMB-LBR-0001              '      
-- Union select 'BA100G                     '      
-- Union select 'BELL100                    '      
-- Union select 'BK MOUSE                   '      
-- Union select 'BOT100G                    '      
-- Union select 'CAP100                     '      
-- Union select 'CB100                      '      
-- Union select 'CBA100                     '      
-- Union select 'COMPBOOK                   '      
-- Union select 'CORDG                      '      
-- Union select 'COV100G                    '      
-- Union select 'FAXX-CAN-9800              '      
-- Union select 'FAXX-FG3-0001              '      
-- Union select 'FAXX-RIC-060E              '      
-- Union select 'FAXX-SLK-0172              '      
-- Union select 'FAXX-SLK-2100              '      
-- Union select 'FRHT-TWO-0001              '      
-- Union select 'FTRUB                      '      
-- Union select 'HA100G                     '      
-- Union select 'HDWR-ACC-0100              '      
-- Union select 'HDWR-CAB-0001              '      
-- Union select 'HDWR-CIM-0001              '      
-- Union select 'HDWR-DCD-0001              '      
-- Union select 'HDWR-FGC-0001              '      
-- Union select 'HDWR-LDS-0001              '      
-- Union select 'HDWR-PNL-0001              '      
-- Union select 'HDWR-PRO-4862              '      
-- Union select 'HDWR-PRO-4866              '      
-- Union select 'HDWR-RNG-0001              '      
-- Union select 'HDWR-SBD-0001              '      
-- Union select 'HDWR-SRG-0001              '      
-- Union select 'HDWR-SWM-0100              '      
-- Union select 'HDWR-SWM-0250              '      
-- Union select 'HDWR-T1I-0001              '      
-- Union select 'HDWR-TPS-0001              '      
-- Union select 'INST-TWO-0001              '      
-- Union select 'ITCT-CIR-CD85              '      
-- Union select 'KB104                      '      
-- Union select 'KPA100                     '      
-- Union select 'M1500                      '      
-- Union select 'M1700                      '      
-- Union select 'M2100                      '      
-- Union select 'MIC100                     '      
-- Union select 'MISC-TWO-0001              '      
-- Union select 'PHAN-FAX-0001              '      
-- Union select 'PHAN-PHN-0001              '      
-- Union select 'PHON-ATT-0712              '      
-- Union select 'PHON-ATT-5354              '      
-- Union select 'PHON-ATT-53BK              '      
-- Union select 'PHON-ATT-53BL              '      
-- Union select 'PHON-ATT-53RD              '      
-- Union select 'PHON-ATT-53WH              '      
-- Union select 'PHON-BAS-0001              '      
-- Union select 'PHON-BUS-1244              '      
-- Union select 'PHON-BUS-1250              '      
-- Union select 'PHON-FGD-0001              '      
-- Union select 'PHON-FGS-0002              '      
-- Union select 'PHON-GTE-3458              '      
-- Union select 'PHON-GTE-5043              '      
-- Union select 'PHON-PAN-2315              '      
-- Union select 'PHON-PAN-3155              '      
-- Union select 'PHON-PAN-3848              '      
-- Union select 'PHON-RCV-0001              '      
-- Union select 'PHON-RCV-0002              '      
-- Union select 'PHON-SNY-1250              '      
-- Union select 'PHSY-DEL-0001              '      
-- Union select 'PHSY-STD-0001              '      
-- Union select 'PRCT-CIR-0001              '      
-- Union select 'PRO1                       '      
-- Union select 'PSYS-FG1-0001              '      
-- Union select 'REPR-TWO-0001              '      
-- Union select 'REPR-TWO-0002              '      
-- Union select 'RES100                     '      
-- Union select 'RESR-COM-68KM              '      
-- Union select 'RESR-TRR-68KM              '      
-- Union select 'RMTL-CAP-10MF              '      
-- Union select 'SCAN100F                   '      
-- Union select 'SOFT-PHM-0001              '      
-- Union select 'SOLDER                     '      
-- Union select 'SPK100                     '      
-- Union select 'SPLN-TWO-0001              '      
-- Union select 'SPLN-TWO-0002              '      
-- Union select 'TOP100G                    '      
-- Union select 'TRAN-STR-N394              '      
-- Union select 'TRANS100                   '      
-- Union select 'TRANSF100                  '      
-- Union select 'VMSY-FG2-0001              '      
-- Union select 'WIRE-MCD-0001              '      
-- Union select 'WIRE-SCD-0001              '      
-- Union select 'WIRE100                    '      
-- Union select 'OM03215                    '      
-- Union select 'OM01373                    '      
-- Union select 'OM02865                    '      
-- Union select 'OM05849                    '      
-- Union select 'OM08529                    '      
-- Union select 'OM08539                    '      
-- Union select 'OM02536                    '      
-- Union select 'OM04586                    '      
-- Union select 'OM08570                    '      
-- Union select 'OM08575                    '      
-- Union select 'OM08580                    '      
-- Union select 'OM08585                    '      
-- Union select 'OM08590                    '      
-- Union select 'OM08595                    '      
-- Union select 'OM08600                    '      
-- Union select 'OM08605                    '      
-- Union select 'OM08610                    '      
-- Union select 'OM08615                    '      
-- Union select 'OM08620                    '      
-- Union select 'OM08625                    '      
-- Union select 'OM08640                    '      
-- Union select 'OM08645                    '      
-- Union select 'OM08665                    '      
-- Union select 'OM08670                    '      
-- Union select 'OM08685                    '      
-- Union select 'OM08690                    '      
-- Union select 'OM08710                    '      
-- Union select 'OM08715                    '      
-- Union select '1GPROC                     '      
-- Union select '2GPROC                     '      
-- Union select '512 SDRAM                  '      
-- Union select 'ARM                        '      
-- Union select 'BACK ASSEMBLY              '      
-- Union select 'BACK FABRIC                '      
-- Union select 'BACK FRAME                 '      
-- Union select 'BAND-LEATHER               '      
-- Union select 'BAND-METAL                 '      
-- Union select 'BAND-PLASTIC               '      
-- Union select 'BARREL ASSEMBLY            '      
-- Union select 'BATTERY                    '      
-- Union select 'BLACK INK                  '      
-- Union select 'CHAIR                      '      
-- Union select 'CLIP                       '      
-- Union select 'DISPLAY                    '      
-- Union select 'DVD                        '      
-- Union select 'DVD ROM                    '      
-- Union select 'EXTERIOR ASSEMBLY          '      
-- Union select 'FACE-ANALOG                '      
-- Union select 'FACE-DIGITAL               '      
-- Union select 'HARD DRIVE                 '      
-- Union select 'HD-20                      '      
-- Union select 'HD-40                      '      
-- Union select 'HD-60                      '      
-- Union select 'LEG                        '      
-- Union select 'PAINT                      '      
-- Union select 'PEN                        '      
-- Union select 'PEN CAP                    '      
-- Union select 'SEAT ASSEMBLY              '      
-- Union select 'SEAT FABRIC                '      
-- Union select 'SEAT FRAME                 '      
-- Union select 'SPRING                     '      
-- Union select 'STYLE-M                    '      
-- Union select 'STYLE-W'      
-- Union select 'WATCH                      '      
-- Union select 'CDROM                      '      
-- Union select 'COMPDUM                    '      
-- Union select 'COMPUTER                   '      
-- Union select 'DRIVE ASSY                 '      
-- Union select 'FAXX-SHP-0172              '      
-- Union select 'FAXX-SHP-2100              '      
-- Union select 'HDWR-ASP-0100              '      
-- Union select '1-A3261A                   '      
-- Union select '1-A3483A                   '      
-- Union select '2-A3284A                   '      
-- Union select '3-A2440A                   '      
-- Union select '3-A2969A                   '      
-- Union select '3-A2990A                   '      
-- Union select '3-A2998A                   '      
-- Union select '3-A3294A                   '      
-- Union select '3-A3416A                   '      
-- Union select '3-A3542A                   '      
-- Union select '3-B3813A                   '      
-- Union select '3-B3897A                   '      
-- Union select '3-C2786A                   '      
-- Union select '3-C2804A                   '      
-- Union select '3-C2924A                   '      
-- Union select '3-D2094A                   '      
-- Union select '3-D2657A                   '      
-- Union select '3-D2659A                   '      
-- Union select '3-E4471A                   '      
-- Union select '3-E4472A                   '      
-- Union select '3-E4592A                   '      
-- Union select '3-J2094A                   '      
-- Union select '4-A3351A                   '      
-- Union select '4-A3539A                   '      
-- Union select '4-A3666A                   '      
-- Union select '4-E2094A                   '      
-- Union select '4-E5930A                   '      
-- Union select '5-DBLLABOR                 '      
-- Union select '5-FEE                      '      
-- Union select '5-HOTLINE                  '      
-- Union select '5-MILEAGE                  '      
-- Union select '5-OVTLABOR                 '      
-- Union select '5-STDLABOR                 '      
-- Union select '5-SUPPLIES                 '      
-- Union select '5-TRAVEL                   '      
-- Union select '5-TVLLABOR                 '      
-- Union select '5-CONTRACTS                '      
-- Union select '5-ASSY                     '      
-- Union select '5-DEPOT                    '      
-- Union select '5-DIAG                     '      
-- Union select '5-SHIP                     '      
-- Union select '5-TEARDOWN                 '      
-- Union select 'TEST                       '      
-- )t  

end
GO
/****** Object:  StoredProcedure [dbo].[sp_ProcessOpenApplyRecord]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_ProcessOpenApplyRecord]    
as    
begin    
	 --1- added    
	 --2- updated     
	
	-- alter table [tblNotification] add [student_id] nvarchar(100)  
	insert into [tblNotification](RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy],student_id)    
	select     
		id as RecordId,    
		case when [StudentCode] is null then 1 else 2 end RecordStatus,      
		0 as IsApproved,    
		'Student' as RecordType,    
		Getdate(),0 ,  
		student_id  
	from     
	(    
		select 
		stu.[StudentCode],
		os.id 	,
		os.[student_id]
		from [dbo].[OpenApplyStudents] os    
		left join [dbo].[tblStudent] stu    
		on os.[student_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[StudentCode]    
   
	AND     
	(    
		(    
			os.[name] COLLATE SQL_Latin1_General_CP1_CI_AS <>stu.[StudentName]   
			OR os.[other_name]  COLLATE SQL_Latin1_General_CP1_CI_AS <>stu.[StudentArabicName]    
			OR os.[email]  COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[StudentEmail]    
			--OR os.[status] <>stu.[StudentStatusId]    
			--enrolled    
		)    
		OR    
		1=1    
	)   
	)t    
    
	 insert into [tblNotification](RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy],student_id)    
	 select     
		id,    
		case when [ParentCode] is null then 1 else 2 end RecordStatus,  --added/updated  
		--cast(0 as bit) as    
		0 as IsApproved,    
		'Mother' as RecordType,    
		Getdate(),0 ,  
		student_id  
	from     
	(    
		select ROW_NUMBER() over(partition by   student_id,gender order by student_id) as RN,
		stu.[ParentCode],
		os.id 	,
		os.[student_id]
		from [dbo].[OpenApplyParents] os    
		left join [dbo].[tblParent] stu    
		on os.[parent_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[ParentCode] --need to check with record    
		and os.gender='Female'  
		AND     
		(    
			(    
				(os.[first_name]+' '+os.[last_name]) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherName]    
				OR os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherEmail]    
			)    
			OR    
			1=1    
		)
	)t   
	where t.RN=1  
  
	 insert into [tblNotification](RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy],student_id)    
	 select     
		id,    
		case when [ParentCode] is null then 1 else 2 end RecordStatus,    
		--cast(0 as bit) as    
		0 as IsApproved,    
		'Father' as RecordType,    
		Getdate(),0  ,  
		student_id  
	from     
	(    
		select ROW_NUMBER() over(partition by   student_id,gender order by student_id) as RN, 
		stu.[ParentCode],
		os.id 	,
		os.[student_id]
		from [dbo].[OpenApplyParents] os    
		left join [dbo].[tblParent] stu    
		on os.[parent_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[ParentCode] --need to check with record    
		and os.gender='male'  
		AND     
		(    
			(    
				(os.[first_name]+' '+os.[last_name]) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherName]    
				OR os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherEmail]    
			)    
			OR    
			1=1    
		)
	)t   
	where t.RN=1  
  
end
GO
/****** Object:  StoredProcedure [dbo].[sp_ProcessOpenApplyRecordToNotification]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[sp_ProcessOpenApplyRecordToNotification]          
as          
begin          
  --1- added          
  --2- updated           
 BEGIN TRY        
   BEGIN TRANSACTION TRANS1        
   --NotificationAction 1- Add, 2-Edit, 3-deleted    
    
   ----Delete previous record    
   delete from [tblNotification]    
    
   delete t    
 from tblNotificationGroupDetail t    
 inner join tblNotificationTypeMaster  tm on t.NotificationTypeId=tm.NotificationTypeId    
 where tm.ActionTable in ('tblStudent','tblParent')    
    
    delete t    
 from tblNotificationGroup t    
 inner join tblNotificationTypeMaster  tm on t.NotificationTypeId=tm.NotificationTypeId    
 where tm.ActionTable in ('tblStudent','tblParent')    
    
 delete from tblNotificationTypeMaster  where ActionTable in ('tblStudent','tblParent')    
    
-- select * from tblNotificationTypeMaster    
--select * from tblNotificationGroup    
--select * from tblNotificationGroupDetail    
    
 -- alter table [tblNotification] add [student_id] nvarchar(100)        
  --alter table [tblNotification] add OldValueJson nvarchar(max)        
  --alter table [tblNotification] add NewValueJson nvarchar(max)        
    
 insert into [tblNotification](RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy],student_id,OldValueJson ,NewValueJson)          
 select           
  id as RecordId,          
  case when [StudentCode] is null then 1 else 2 end RecordStatus,            
  0 as IsApproved,          
  'Student' as RecordType,          
  Getdate(),    
  0 ,        
  student_id    
  ,OldValueJson=ISNULL(OldValueJson,'')    
  ,NewValueJson=ISNULL(NewValueJson,'')    
 from           
 (          
  select       
   stu.[StudentCode],      
   os.id  ,      
   os.[student_id]      
    
   , NewValueJson= (SELECT * FROM [OpenApplyStudents] jc where jc.[student_id] = os.[student_id] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )    
   , OldValueJson= (SELECT * FROM [tblStudent] jc where jc.[StudentCode] = stu.[StudentCode] FOR JSON PATH,WITHOUT_ARRAY_WRAPPER )    
     
   ,case     
   when ltrim(rtrim(os.[name])) COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentName]     ))    
   then 1 else 0 end NameUpdated    
        
   ,case when ltrim(rtrim(os.[other_name]))  COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentArabicName]   ))     
   then 1 else 0 end  ArabicNameUpdated    
    
   ,case when ltrim(rtrim( isnull(os.[email],'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.[StudentEmail] ,'')))    
   then 1 else 0 end  EmailUpdated    
  
   ,case when ltrim(rtrim( isnull(os.IqamaNo,'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.IqamaNo ,'')))    
   then 1 else 0 end  IqamaNoUpdated    
    
  from [dbo].[OpenApplyStudents] os          
  left join [dbo].[tblStudent] stu          
  on os.[student_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[StudentCode]          
         
  AND           
  (          
   (          
    (ltrim(rtrim(os.first_name))+ ' '+ ltrim(rtrim(os.last_name))) COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentName]     ))    
    OR ltrim(rtrim(os.[other_name]))  COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentArabicName]   ))       
    OR ltrim(rtrim( isnull(os.[email],'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.[StudentEmail] ,'')))  
  OR ltrim(rtrim( isnull(os.IqamaNo,'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.IqamaNo ,'')))  
    --OR os.[status] <>stu.[StudentStatusId]          
    --enrolled          
   )          
   OR          
   1=1          
  )    
 )t      
 where t.NameUpdated=1 OR t.ArabicNameUpdated=1 OR t.EmailUpdated=1   OR t.IqamaNoUpdated=1  
          
 insert into [tblNotification](RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy],student_id,OldValueJson ,NewValueJson)          
 select           
  id,          
  case when [ParentCode] is null then 1 else 2 end RecordStatus,  --added/updated        
  --cast(0 as bit) as          
  0 as IsApproved,          
  'Mother' as RecordType,          
  Getdate(),0 ,        
  student_id     
  ,OldValueJson=ISNULL(OldValueJson,'')    
  ,NewValueJson=ISNULL(NewValueJson,'')    
 from           
 (          
  select     
   ROW_NUMBER() over(partition by   student_id,gender order by student_id) as RN,      
   stu.[ParentCode],      
   os.id  ,      
   os.[student_id]      
       
   ,case when(os.[first_name]+' '+os.[last_name]) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherName          
   then 1 else 0 end  NameUpdated    
        
   ,case when os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherEmail          
   then 1 else 0 end  EmailUpdated    
  
   ,case when ltrim(rtrim( isnull(os.IqamaNo,'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.MotherIqamaNo ,'')))    
   then 1 else 0 end  IqamaNoUpdated    
       
   ,NewValueJson= (SELECT * FROM [OpenApplyParents] jc where jc.[parent_id] = os.[parent_id] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )    
   , OldValueJson= (SELECT * FROM [tblParent] jc where jc.ParentCode = stu.ParentCode FOR JSON PATH,WITHOUT_ARRAY_WRAPPER )    
     
  from [dbo].[OpenApplyParents] os          
  left join [dbo].[tblParent] stu          
  on os.[parent_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[ParentCode] --need to check with record          
  and os.gender='Female'        
  AND           
  (          
   (          
    (ltrim(rtrim(os.[first_name]))+' '+ltrim(rtrim(os.[last_name]))) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherName          
    OR     
    ltrim(rtrim(os.[email])) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherEmail    
 OR     
    ltrim(rtrim(os.IqamaNo)) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherIqamaNo    
   )          
   OR          
   1=1          
  )       
 )t         
 where t.RN=1   OR t.NameUpdated=1 OR t.EmailUpdated=1  OR t.IqamaNoUpdated=1    
        
 insert into [tblNotification](RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy],student_id,OldValueJson ,NewValueJson)          
 select           
  id,          
  case when [ParentCode] is null then 1 else 2 end RecordStatus,          
  --cast(0 as bit) as          
  0 as IsApproved,          
  'Father' as RecordType,          
  Getdate(),    
  0  ,        
  student_id      
  ,OldValueJson=ISNULL(OldValueJson,'')    
  ,NewValueJson=ISNULL(NewValueJson,'')    
 from           
 (          
 select     
  ROW_NUMBER() over(partition by   student_id,gender order by student_id) as RN,       
  stu.[ParentCode],      
  os.id  ,      
  os.[student_id]     
       
  ,case when(os.[first_name]+' '+os.[last_name]) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherName]          
     then 1 else 0 end  NameUpdated    
        
  ,case when os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherEmail]          
   then 1 else 0 end  EmailUpdated   
     
   ,case when ltrim(rtrim( isnull(os.IqamaNo,'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.FatherIqamaNo ,'')))    
   then 1 else 0 end  IqamaNoUpdated   
    
  ,NewValueJson= (SELECT * FROM [OpenApplyParents] jc where jc.[parent_id] = os.[parent_id] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )    
  , OldValueJson= (SELECT * FROM [tblParent] jc where jc.ParentCode = stu.ParentCode FOR JSON PATH,WITHOUT_ARRAY_WRAPPER )    
    
 from [dbo].[OpenApplyParents] os          
 left join [dbo].[tblParent] stu          
 on os.[parent_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[ParentCode] --need to check with record          
 and os.gender='male'        
 AND           
  (          
   (          
    (ltrim(rtrim(os.[first_name]))+' '+ltrim(rtrim(os.[last_name]))) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherName]          
    OR ltrim(rtrim(os.[email])) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherEmail]   
 OR     
    ltrim(rtrim(os.IqamaNo)) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.FatherIqamaNo    
   )          
   OR          
   1=1          
  )       
 )t         
 where t.RN=1   OR t.NameUpdated=1 OR t.EmailUpdated=1  OR t.IqamaNoUpdated=1       
    
    
 ---Process final table to notification table    
    
 ----insert into master record : tblNotificationTypeMaster    
 if not exists(select top 1 * from tblNotificationTypeMaster where NotificationType='OpenApplyRecordProcessing' and  ActionTable='tblStudent')    
 begin     
  insert into tblNotificationTypeMaster(NotificationType ,ActionTable ,NotificationMsg ,IsActive)    
  select  'OpenApplyRecordProcessing', 'tblStudent', 'Student #N record #Action' ,1    
 end    
    
 if not exists(select top 1 * from tblNotificationTypeMaster where NotificationType='OpenApplyRecordProcessing' and  ActionTable='tblParent')    
 begin     
  insert into tblNotificationTypeMaster(NotificationType ,ActionTable ,NotificationMsg ,IsActive)    
  select  'OpenApplyRecordProcessing', 'tblParent', 'Parent #N record #Action' ,1    
 end    
    
 declare @NotificationTypeId int=0;    
    
 --------------Start: Student record    
     
 select top 1 @NotificationTypeId=NotificationTypeId from tblNotificationTypeMaster where NotificationType='OpenApplyRecordProcessing' and  ActionTable='tblStudent'    
    
 --Added new record    
 if not exists(select top 1 * from tblNotificationGroup where NotificationTypeId=@NotificationTypeId and NotificationAction=1)    
 begin    
  insert into tblNotificationGroup(NotificationTypeId ,NotificationCount ,NotificationAction)    
  select @NotificationTypeId as NotificationTypeId,count(1) as NotificationCount, NotificationAction=1  from [tblNotification]    
  where RecordType='Student' and RecordStatus=1    
 end    
     
     
  declare @NotificationGroupId int=0;    
  select top 1 @NotificationGroupId=NotificationGroupId from tblNotificationGroup where NotificationTypeId=@NotificationTypeId and NotificationAction=1    
    
  declare @NotificationCount int=0    
  select @NotificationCount=count(1)     
  from [tblNotification]    
  where RecordType='Student' and RecordStatus=1     
    
  update tblNotificationGroup    
  set NotificationCount=@NotificationCount    
  where  NotificationGroupId=@NotificationGroupId    
      
  insert into tblNotificationGroupDetail(NotificationGroupId ,NotificationTypeId, NotificationAction, TableRecordId, OldValueJson, NewValueJson, CreatedBy)    
  select     
   @NotificationGroupId,@NotificationTypeId as NotificationTypeId,NotificationAction=1,    
   NotificationId as TableRecordId,OldValueJson,NewValueJson,CreatedBy=1    
  from [tblNotification]    
  where RecordType='Student' and RecordStatus=1    
     
    
 --add updated record    
 if not exists(select top 1 * from tblNotificationGroup where NotificationTypeId=@NotificationTypeId and NotificationAction=2)    
 begin    
  insert into tblNotificationGroup(NotificationTypeId ,NotificationCount ,NotificationAction)    
  select @NotificationTypeId as NotificationTypeId,count(1) as NotificationCount, NotificationAction=2  from [tblNotification]    
  where RecordType='Student' and RecordStatus=2    
 end    
     
     
  declare @NotificationGroupId1 int=0;    
  select top 1 @NotificationGroupId1=NotificationGroupId from tblNotificationGroup where NotificationTypeId=@NotificationTypeId and NotificationAction=2    
      
  declare @NotificationCount1 int=0    
  select @NotificationCount1=count(1)     
  from [tblNotification]    
  where RecordType='Student' and RecordStatus=2    
    
  update tblNotificationGroup    
  set NotificationCount=@NotificationCount1    
  where  NotificationGroupId=@NotificationGroupId1    
    
  insert into tblNotificationGroupDetail(NotificationGroupId ,NotificationTypeId, NotificationAction, TableRecordId, OldValueJson, NewValueJson, CreatedBy)    
  select     
   @NotificationGroupId1,@NotificationTypeId as NotificationTypeId,NotificationAction=2,    
   NotificationId as TableRecordId,OldValueJson,NewValueJson,CreatedBy=1    
  from [tblNotification]    
  where RecordType='Student' and RecordStatus=2    
     
     
 --------------End: Student record    
    
 --------------Start: parent record    
     
 select top 1 @NotificationTypeId=NotificationTypeId from tblNotificationTypeMaster where NotificationType='OpenApplyRecordProcessing' and  ActionTable='tblParent'    
    
 --Added new record    
 if not exists(select top 1 * from tblNotificationGroup where NotificationTypeId=@NotificationTypeId and NotificationAction=1)    
 begin    
  insert into tblNotificationGroup(NotificationTypeId ,NotificationCount ,NotificationAction)    
  select @NotificationTypeId as NotificationTypeId,count(1) as NotificationCount, NotificationAction=1  from [tblNotification]    
  where RecordType<>'Student' and RecordStatus=1    
 end    
     
     
  declare @NotificationGroupId2 int=0;    
  select top 1 @NotificationGroupId2=NotificationGroupId from tblNotificationGroup where NotificationTypeId=@NotificationTypeId and NotificationAction=2    
      
  declare @NotificationCount2 int=0    
  select @NotificationCount2=count(1)     
  from [tblNotification]    
  where RecordType<>'Student' and RecordStatus=1    
    
  update tblNotificationGroup    
  set NotificationCount=@NotificationCount2    
  where  NotificationGroupId=@NotificationGroupId2    
    
  insert into tblNotificationGroupDetail(NotificationGroupId ,NotificationTypeId, NotificationAction, TableRecordId, OldValueJson, NewValueJson, CreatedBy)    
  select     
   @NotificationGroupId2,@NotificationTypeId as NotificationTypeId,NotificationAction=1,    
   NotificationId as TableRecordId,OldValueJson,NewValueJson,CreatedBy=1    
  from [tblNotification]    
  where RecordType<>'Student' and RecordStatus=1    
     
    
 --add updated record    
 if not exists(select top 1 * from tblNotificationGroup where NotificationTypeId=@NotificationTypeId and NotificationAction=2)    
 begin    
  insert into tblNotificationGroup(NotificationTypeId ,NotificationCount ,NotificationAction)    
  select @NotificationTypeId as NotificationTypeId,count(1) as NotificationCount, NotificationAction=2  from [tblNotification]    
  where RecordType<>'Student' and RecordStatus=2    
 end    
     
    
     
  declare @NotificationGroupId3 int=0;    
  select top 1 @NotificationGroupId3=NotificationGroupId from tblNotificationGroup where NotificationTypeId=@NotificationTypeId and NotificationAction=2    
      
  declare @NotificationCount3 int=0    
  select @NotificationCount3=count(1)     
  from [tblNotification]    
  where RecordType<>'Student' and RecordStatus=2    
    
  update tblNotificationGroup    
  set NotificationCount=@NotificationCount3    
  where  NotificationGroupId=@NotificationGroupId3    
    
  insert into tblNotificationGroupDetail(NotificationGroupId ,NotificationTypeId, NotificationAction, TableRecordId, OldValueJson, NewValueJson, CreatedBy)    
  select     
   @NotificationGroupId3,@NotificationTypeId as NotificationTypeId,NotificationAction=2,    
   NotificationId as TableRecordId,OldValueJson,NewValueJson,CreatedBy=1    
  from [tblNotification]    
  where RecordType<>'Student' and RecordStatus=2    
     
     
 --------------End: parent record    
    
          
  COMMIT TRAN TRANS1        
  SELECT 0 AS Result, 'Saved' AS Response      
 END TRY        
 BEGIN CATCH        
     ROLLBACK TRAN TRANS1           
     SELECT -1 AS Result, 'Error!' AS Response        
     EXEC usp_SaveErrorDetail        
     RETURN        
 END CATCH       
      
    
    
    
    
    
    
   --------------Start: Student ------------    
 --select           
 --  --  id as RecordId,          
 --  --  case when [StudentCode] is null then 1 else 2 end RecordStatus,            
 --  --  0 as IsApproved,          
 --  --  'Student' as RecordType,          
--  --  Getdate(),0 ,        
 --  --  student_id  ,    
 --  --NewValueJson,OldValueJson    
 --  LoginUserId=0    
 --  ,ActionTable='tblStudent'    
 --  ,NotificationAction= case when [StudentCode] is null then 1 else 2 end    
 --  ,TableRecordId=isnull(StudentId,0)    
 --  ,OldValueJson=OldValueJson    
 --  ,NewValueJson=NewValueJson    
 --  from           
 --  (          
 -- select       
 --  stu.StudentId,      
 --  stu.[StudentCode],      
 --  os.id  ,      
 --  os.[student_id]  ,    
       
 --  NewValueJson= (SELECT * FROM [OpenApplyStudents] jc where jc.[student_id] = os.[student_id] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )    
 --  , OldValueJson=     
 --  (    
 --  SELECT     
 --   StudentId    
 --   ,StudentCode    
 --   ,StudentImage    
 --   ,ParentId    
 --   ,StudentName    
 --   ,StudentArabicName    
 --   ,StudentEmail    
 --   ,DOB    
 --   ,IqamaNo    
 --   ,NationalityId    
 --   ,GenderId    
 --   ,AdmissionDate    
 --   ,GradeId    
 --   ,CostCenterId    
 --   ,SectionId    
 --   ,PassportNo    
 --   ,PassportExpiry    
 --   ,Mobile    
 --   ,StudentAddress    
 --   ,StudentStatusId    
 --   ,WithdrawDate    
 --   ,WithdrawAt    
 --   ,WithdrawYear    
 --   ,Fees    
 --   ,IsGPIntegration    
 --   ,TermId    
 --   ,AdmissionYear    
 --   ,PrinceAccount    
 --   ,IsActive    
 --   ,IsDeleted    
 --   ,UpdateDate    
 --   ,UpdateBy    
 --   ,p_id_school_parent_id    
 --  FROM [tblStudent] jc where jc.[StudentCode] = stu.[StudentCode] FOR JSON PATH,WITHOUT_ARRAY_WRAPPER )    
     
 --  ,os.[name] ,stu.[StudentName]         
 --  ,os.[other_name]  ,stu.[StudentArabicName]          
 --  ,os.[email]  ,stu.[StudentEmail]      
     
 --  ,case     
 --  when ltrim(rtrim(os.[name])) COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentName]     ))    
 --  then 1 else 0 end NameUpdated    
        
 --  ,case when ltrim(rtrim(os.[other_name]))  COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentArabicName]   ))     
 --  then 1 else 0 end  ArabicNameUpdated    
    
 --  ,case when ltrim(rtrim( isnull(os.[email],'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.[StudentEmail] ,'')))    
 --  then 1 else 0 end  EmailUpdated    
    
 --  --,case when   ltrim(rtrim(os.IqamaNo))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(stu.IqamaNo))    
 --  --then 1 else 0 end  IqamaNoUpdated    
    
 -- from [dbo].[OpenApplyStudents] os          
 -- left join [dbo].[tblStudent] stu          
 -- on os.[student_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[StudentCode]          
         
 -- AND           
 -- (          
 --  (          
 --   ltrim(rtrim(os.[name])) COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentName]     ))    
 --   OR ltrim(rtrim(os.[other_name]))  COLLATE SQL_Latin1_General_CP1_CI_AS <>ltrim(rtrim(stu.[StudentArabicName]   ))       
 --   OR ltrim(rtrim( isnull(os.[email],'')))  COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(isnull( stu.[StudentEmail] ,'')))    
 --   --OR  ltrim(rtrim(os.IqamaNo)) COLLATE SQL_Latin1_General_CP1_CI_AS<>ltrim(rtrim(stu.IqamaNo))    
 --   --OR os.[status] <>stu.[StudentStatusId]          
 --   --enrolled          
 --  )          
 --  OR          
 --  1=1    
 -- )         
 --  )t     
 --  where NameUpdated=1 OR ArabicNameUpdated=1 OR EmailUpdated=1 --OR IqamaNoUpdated=1    
 --------------End: Student ------------    
    
 --------------Start: Mother------------    
 --select     
 -- LoginUserId=0    
 -- ,ActionTable='tblParent'    
 -- ,NotificationAction= case when [ParentCode] is null then 1 else 2 end    
 -- ,TableRecordId=isnull(ParentId,0)    
 -- ,OldValueJson=OldValueJson    
 -- ,NewValueJson=NewValueJson    
 -- --id,          
 -- --case when [ParentCode] is null then 1 else 2 end RecordStatus,  --added/updated        
 -- ----cast(0 as bit) as          
 -- --0 as IsApproved,          
 -- --'Mother' as RecordType,          
 -- --Getdate(),0 ,        
 -- --student_id     
 -- --*    
 --from           
 --(          
 -- select     
 --  ROW_NUMBER() over(partition by   student_id,gender order by student_id) as RN    
 --  ,stu.ParentId    
 --  ,stu.[ParentCode]    
 --  ,os.id      
 --  ,os.[student_id]    
       
 --  ,case when(os.[first_name]+' '+os.[last_name]) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherName          
 --   then 1 else 0 end  NameUpdated    
        
 --  ,case when os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherEmail          
 --   then 1 else 0 end  EmailUpdated    
       
 --  ,NewValueJson= (SELECT * FROM [OpenApplyParents] jc where jc.[parent_id] = os.[parent_id] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )    
 --  , OldValueJson= (SELECT * FROM [tblParent] jc where jc.ParentCode = stu.ParentCode FOR JSON PATH,WITHOUT_ARRAY_WRAPPER )    
     
 -- from [dbo].[OpenApplyParents] os          
 -- left join [dbo].[tblParent] stu          
 -- on os.[parent_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[ParentCode] --need to check with record          
 -- and os.gender='Female'        
 -- AND           
 -- (          
 --  (          
 --   (os.[first_name]+' '+os.[last_name]) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherName          
 --   OR     
 --   os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.MotherEmail          
 --  )          
 --  OR          
 --  1=1          
 -- )      
 --)t         
 --where t.RN=1   and t.NameUpdated=1 and t.EmailUpdated=1      
 --------------End: Mother------------      
      
 --------------Start: Father------------    
 --select     
 -- LoginUserId=0    
 -- ,ActionTable='tblParent'    
 -- ,NotificationAction= case when [ParentCode] is null then 1 else 2 end    
 -- ,TableRecordId=isnull(ParentId,0)    
 -- ,OldValueJson=OldValueJson    
 -- ,NewValueJson=NewValueJson    
    
 -- --id,          
 -- --case when [ParentCode] is null then 1 else 2 end RecordStatus,          
 -- ----cast(0 as bit) as          
 -- --0 as IsApproved,          
 -- --'Father' as RecordType,          
 -- --Getdate(),0  ,        
 -- --student_id        
 -- --*    
 --from           
 --(          
 -- select     
 --  ROW_NUMBER() over(partition by   student_id,gender order by student_id) as RN    
 --  ,stu.ParentId    
 --  ,stu.[ParentCode]    
 --  ,os.id      
 --  ,os.[student_id]    
       
 --  ,case when(os.[first_name]+' '+os.[last_name]) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherName]          
 --   then 1 else 0 end  NameUpdated    
        
 --  ,case when os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherEmail]          
 --   then 1 else 0 end  EmailUpdated    
    
 --  ,NewValueJson= (SELECT * FROM [OpenApplyParents] jc where jc.[parent_id] = os.[parent_id] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )    
 --  , OldValueJson= (SELECT * FROM [tblParent] jc where jc.ParentCode = stu.ParentCode FOR JSON PATH,WITHOUT_ARRAY_WRAPPER )    
     
 -- from [dbo].[OpenApplyParents] os          
 -- left join [dbo].[tblParent] stu          
 -- on os.[parent_id] COLLATE SQL_Latin1_General_CP1_CI_AS=stu.[ParentCode] --need to check with record          
 -- and os.gender='male'        
 -- AND           
 -- (          
 --  (          
 --   (os.[first_name]+' '+os.[last_name]) COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherName]          
 --   OR os.[email] COLLATE SQL_Latin1_General_CP1_CI_AS<>stu.[FatherEmail]          
 --  )          
 --  OR          
 --  1=1          
 -- )      
 --)t         
 --where t.RN=1   and t.NameUpdated=1 and t.EmailUpdated=1      
 --------------End: Father------------    
    
END 
GO
/****** Object:  StoredProcedure [dbo].[sp_RejectNotificationById]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_RejectNotificationById]
	@LoginUserId int=0
	,@NotificationGroupDetailId int=0
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION TRANS1
	DECLARE @TableToBeUpdate NVARCHAR(500)
	DECLARE @TableRecordColumnName nvarchar(200)
	DECLARE @TableRecordId NVARCHAR(200)
	DECLARE @NotificationAction int
	DECLARE @NotificationGroupId int
	SELECT @TableToBeUpdate=nt.ActionTable,@TableRecordColumnName=ngd.TableRecordColumnName
	,@TableRecordId=ngd.TableRecordId,@NotificationAction=NotificationAction,@NotificationGroupId=NotificationGroupId
	FROM tblNotificationGroupDetail ngd
	INNER JOIN tblNotificationTypeMaster nt
		ON ngd.NotificationTypeId=nt.NotificationTypeId
	WHERE ngd.NotificationGroupDetailId=@NotificationGroupDetailId
	DECLARE @Query NVARCHAR(MAX)
	SET @Query='UPDATE '+@TableToBeUpdate+' SET IsRejected = 1, IsApproved = 0 WHERE '+@TableRecordColumnName+'='+@TableRecordId
				
	PRINT @Query
	EXEC (@Query)
	IF @NotificationAction=1
	BEGIN
		SET @Query='UPDATE '+@TableToBeUpdate+' SET IsDeleted = 1 WHERE '+@TableRecordColumnName+'='+@TableRecordId
				
		PRINT @Query
		EXEC (@Query)
	END
	DELETE FROM tblNotificationGroupDetail WHERE NotificationGroupDetailId=@NotificationGroupDetailId
	UPDATE tblNotificationGroup SET NotificationCount = NotificationCount-1
	WHERE NotificationGroupId=@NotificationGroupId
	SELECT 0 AS Result, 'Success' AS Response
	COMMIT TRAN TRANS1
		
	END TRY
	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
--sp_RejectNotificationById 1,1
GO
/****** Object:  StoredProcedure [dbo].[sp_SaveBranch]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveBranch]
	@LoginUserId int
	,@BranchId bigint
	,@BranchName nvarchar(200)
	,@IsActive	bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblBranchMaster WHERE BranchName = @BranchName
			AND BranchId <> @BranchId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Branch already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@BranchId = 0)
			BEGIN
				INSERT INTO tblBranchMaster
					   (BranchName						
						,IsActive
						,IsDeleted
						,UpdateDate
						,UpdateBy)
				VALUES
					   (@BranchName											  
					   ,@IsActive	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
			END
			ELSE
			BEGIN
				UPDATE tblBranchMaster
						SET BranchName = @BranchName						
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE BranchId = @BranchId
			END				
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
/****** Object:  StoredProcedure [dbo].[sp_SaveContactInformation]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveContactInformation]
	@LoginUserId int
	,@ContactId bigint
	,@SchoolId bigint
	,@ContactPerson nvarchar(400)
	,@ContactPosition nvarchar(200)
	,@ContactTelephone nvarchar(20)
	,@ContactEmail nvarchar(200)
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblContactInformation WHERE ContactPerson = @ContactPerson AND SchoolId=@SchoolId
			AND ContactId <> @ContactId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Contact Information already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@ContactId = 0)
			BEGIN
				INSERT INTO tblContactInformation
					   (SchoolId
					   ,ContactPerson
					   ,ContactPosition
					   ,ContactTelephone
					   ,ContactEmail
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@SchoolId
					   ,@ContactPerson
					   ,@ContactPosition
					   ,@ContactTelephone
					   ,@ContactEmail								  
					   ,@IsActive	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
			END
			ELSE
			BEGIN
				UPDATE tblContactInformation
						SET SchoolId = @SchoolId
							,ContactPerson = @ContactPerson
							,ContactPosition = @ContactPosition 					
							,ContactTelephone = @ContactTelephone
							,ContactEmail = @ContactEmail
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE ContactId = @ContactId
			END				
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
/****** Object:  StoredProcedure [dbo].[sp_SaveCostCenter]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_SaveCostCenter]  
 @LoginUserId int  
 ,@CostCenterId bigint  
 ,@CostCenterName nvarchar(200)  
 ,@Remarks nvarchar(400)  
	,@DebitAccount nvarchar(200)  
	,@CreditAccount nvarchar(200)  
 ,@IsActive bit  
AS  
BEGIN  
 SET NOCOUNT ON;  
 IF EXISTS(SELECT 1 FROM tblCostCenterMaster WHERE CostCenterName = @CostCenterName  
   AND CostCenterId <> @CostCenterId AND IsActive = 1)  
 BEGIN  
  SELECT -2 AS Result, 'Costcenter already exists!' AS Response  
  RETURN;  
 END  
 BEGIN TRY  
  BEGIN TRANSACTION TRANS1  
   IF(@CostCenterId = 0)  
   BEGIN  
    INSERT INTO tblCostCenterMaster  
        (CostCenterName  
        ,Remarks  
		,DebitAccount
		,CreditAccount
        ,IsActive  
        ,IsDeleted  
        ,UpdateDate  
        ,UpdateBy)  
    VALUES  
        (@CostCenterName  
        ,@Remarks  
		,@DebitAccount
		,@CreditAccount
        ,@IsActive   
        ,0  
        ,GETDATE()  
        ,@LoginUserId)  
   END  
   ELSE  
   BEGIN  
    UPDATE tblCostCenterMaster  
      SET CostCenterName = @CostCenterName  
       ,Remarks = @Remarks   
	   ,DebitAccount = @DebitAccount
		,CreditAccount = @CreditAccount
       ,IsActive = @IsActive  
       ,UpdateDate = GETDATE()  
       ,UpdateBy = @LoginUserId  
    WHERE CostCenterId = @CostCenterId  
   END      
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
/****** Object:  StoredProcedure [dbo].[sp_SaveDiscount]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveDiscount]
	@LoginUserId int
	,@DiscountId bigint
	,@DiscountName nvarchar(200)
	,@DiscountPercent decimal(18,2)
	,@DiscountAssignedRule nvarchar(200)=NULL
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblDiscountMaster WHERE DiscountName = @DiscountName AND DiscountPercent=@DiscountPercent
			AND DiscountId <> @DiscountId AND IsActive = 1 AND IsDeleted=0)
	BEGIN
		SELECT -2 AS Result, 'Discount already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF OBJECT_ID('tempdb..#TempAssignedDiscountRule') IS NOT NULL DROP TABLE TempAssignedDiscountRule
			SELECT * INTO #TempAssignedDiscountRule FROM (SELECT ROW_NUMBER() OVER(ORDER BY OutParam) RN, OutParam FROM SplitString(@DiscountAssignedRule,',')) x    
			
			IF(@DiscountId = 0)
			BEGIN
				INSERT INTO tblDiscountMaster
					   (
					   DiscountName
					   ,DiscountPercent
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (
					   @DiscountName
					   ,@DiscountPercent
					   ,1
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)

				SET @DiscountId = SCOPE_IDENTITY()      
    
				INSERT INTO tblDiscountRuleMapping   
						(DiscountId    
						,DiscountRuleId 
						,[IsActive]    
						,[IsDeleted]    
						,UpdateDate
						,UpdateBy)    
				SELECT @DiscountId,OutParam,1,0,GETDATE(),@LoginUserId FROM   #TempAssignedDiscountRule 
			END
			ELSE
			BEGIN
				UPDATE tblDiscountMaster
						SET DiscountName = @DiscountName
							,DiscountPercent = @DiscountPercent
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE DiscountId = @DiscountId

				DELETE FROM tblDiscountRuleMapping 
				WHERE DiscountId = @DiscountId AND DiscountRuleId NOT IN (SELECT OutParam FROM #TempAssignedDiscountRule)  

				DELETE FROM #TempAssignedDiscountRule    
				WHERE OutParam     
					IN (SELECT DiscountRuleId FROM tblDiscountRuleMapping     
					WHERE  DiscountId = @DiscountId AND IsActive=1 AND IsDeleted=0) 				  
    
				INSERT INTO tblDiscountRuleMapping    
						(DiscountId    
						,DiscountRuleId 
						,[IsActive]    
						,[IsDeleted]    
						,UpdateDate
						,UpdateBy)      
				SELECT @DiscountId,OutParam,1,0,GETDATE(),@LoginUserId FROM   #TempAssignedDiscountRule    
			END				
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
/****** Object:  StoredProcedure [dbo].[sp_SaveDocumentType]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_SaveDocumentType]
	@LoginUserId int
	,@DocumentTypeId bigint
	,@DocumentTypeName nvarchar(200)
	,@Remarks nvarchar(400)
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblDocumentTypeMaster WHERE DocumentTypeName = @DocumentTypeName
			AND DocumentTypeId <> @DocumentTypeId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'DocumentType already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@DocumentTypeId = 0)
			BEGIN
				INSERT INTO tblDocumentTypeMaster
					   (DocumentTypeName
					   ,Remarks							  
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@DocumentTypeName
					   ,@Remarks								  
					   ,@IsActive	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
			END
			ELSE
			BEGIN
				UPDATE tblDocumentTypeMaster
						SET DocumentTypeName = @DocumentTypeName
							,Remarks = @Remarks								
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE DocumentTypeId = @DocumentTypeId
			END				
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
/****** Object:  StoredProcedure [dbo].[sp_SaveFeeDiscount]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveFeeDiscount]
	@LoginUserId int
	,@FeeDiscountId bigint
	,@FeeDiscountName nvarchar(200)
	,@Percent nvarchar(200)
	,@Rule nvarchar(200)
	,@Remarks nvarchar(200)
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblFeeDiscountMaster WHERE FeeDiscountName = @FeeDiscountName
			AND @FeeDiscountId <> @FeeDiscountId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Fee Discount already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@FeeDiscountId = 0)
			BEGIN
				INSERT INTO tblFeeDiscountMaster
					   (
					   FeeDiscountName
					   ,[Percent]
					   ,[Rule]
					   ,Remarks
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (
					   @FeeDiscountName
					   ,@Percent												  
					   ,@Rule	
					   ,@Remarks
					   ,@IsActive
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
			END
			ELSE
			BEGIN
				UPDATE tblFeeDiscountMaster
						SET FeeDiscountName = @FeeDiscountName
							,[Percent] = @Percent
							,[Rule]  = @Rule
							, Remarks = @Remarks
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE FeeDiscountId = @FeeDiscountId
			END				
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
/****** Object:  StoredProcedure [dbo].[sp_SaveFeePaymentPlan]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveFeePaymentPlan]
	@LoginUserId int=1
	,@FeePaymentPlanId bigint=0
	,@FeeTypeDetailId bigint=0
	,@PaymentPlanAmount decimal(18,2)=123
	,@DueDate Datetime='2024-04-20'
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @NewJsonData NVARCHAR(MAX)
	DECLARE @OldJsonData NVARCHAR(MAX)
	DECLARE @ExistingSum decimal(18,2)
	SELECT @ExistingSum=SUM(PaymentPlanAmount) + @PaymentPlanAmount FROM tblFeePaymentPlan WHERE FeeTypeDetailId = @FeeTypeDetailId
			 AND IsDeleted=0
	
	 
	IF EXISTS(SELECT 1 FROM tblFeeTypeDetail WHERE FeeTypeDetailId = @FeeTypeDetailId 
			AND @ExistingSum>TermFeeAmount AND IsActive = 1 AND IsDeleted=0)
	BEGIN
		SELECT -2 AS Result, 'Amount is greater then Fee amount!' AS Response
		RETURN;
	END	
	IF EXISTS(SELECT 1 FROM tblFeePaymentPlan WHERE FeeTypeDetailId = @FeeTypeDetailId 
			AND Convert(date,DueDate)>Convert(date,@DueDate) AND IsDeleted=0)
	BEGIN
		SELECT -3 AS Result, 'Date should be greater of previous date!' AS Response
		RETURN;
	END	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		IF(@FeePaymentPlanId = 0)
		BEGIN
			INSERT INTO tblFeePaymentPlan
					(
					FeeTypeDetailId
					,PaymentPlanAmount
					,DueDate
					,IsDeleted
					,IsApproved
					,IsRejected
					,UpdateDate
					,UpdateBy)
			VALUES
					(
					@FeeTypeDetailId
					,@PaymentPlanAmount
					,@DueDate
					,0
					,0
					,0
					,GETDATE()
					,@LoginUserId)
					SET @FeePaymentPlanId=SCOPE_IDENTITY();
			SELECT 0 AS Result, 'Saved' AS Response
			SELECT @NewJsonData = '{"PaymentPlanAmount": "'+CAST(@PaymentPlanAmount AS NVARCHAR(18))+'", "DueDate": "'+Convert(VARCHAR(10),@DueDate,101)+'"}';
			--select @NewJsonData
			EXEC sp_SaveNotification @LoginUserId=@LoginUserId,@ActionTable='tblFeePaymentPlan',@NotificationAction='1'
			,@TableRecordId=@FeePaymentPlanId,@OldValueJson='',@NewValueJson=@NewJsonData,@TableRecordColumnName='FeePaymentPlanId'
		END
		ELSE
		BEGIN
  			UPDATE tblFeePaymentPlan
					SET --PaymentPlanAmount = @PaymentPlanAmount						
						--,DueDate = @DueDate	
						IsApproved=0
						,IsRejected=0
						,UpdateDate = GETDATE()
						,UpdateBy = @LoginUserId
			WHERE FeePaymentPlanId = @FeePaymentPlanId
			SELECT 0 AS Result, 'Saved' AS Response
			SELECT @NewJsonData = '{"PaymentPlanAmount": "'+CAST(@PaymentPlanAmount AS NVARCHAR(18))+'", "DueDate": "'+Convert(VARCHAR(10),@DueDate,101)+'"}';
			SELECT @OldJsonData = '{"PaymentPlanAmount": "'+CAST(PaymentPlanAmount AS NVARCHAR(18))+'", "DueDate": "'+Convert(VARCHAR(10),DueDate,101)+'"}' FROM tblFeePaymentPlan
			WHERE FeePaymentPlanId = @FeePaymentPlanId;
			EXEC sp_SaveNotification @LoginUserId=@LoginUserId,@ActionTable='tblFeePaymentPlan'
			,@NotificationAction='2',@TableRecordId=@FeePaymentPlanId
			,@OldValueJson=@OldJsonData,@NewValueJson=@NewJsonData,@TableRecordColumnName='FeePaymentPlanId'
		END
		COMMIT TRAN TRANS1
		
	END TRY
	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SaveFeePlanWithoutGradewise]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveFeePlanWithoutGradewise]
	@LoginUserId int
	,@FeeTypeId bigint
	,@FeeStructureId bigint
	,@AcademicYear nvarchar(200)
	,@FeeAmount decimal(18,4)
	,@IsGradeWise bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblFeeStructure WHERE AcademicYear = @AcademicYear AND FeeTypeId=@FeeTypeId
			AND FeeStructureId <> @FeeStructureId  AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Fee already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@FeeStructureId = 0)
			BEGIN
				INSERT INTO tblFeeStructure
					  ([AcademicYear]
					   ,[FeeTypeId]
					   ,[IsGradeWise]
					   ,[FeeAmount]
					   ,[IsActive]
					   ,[IsDeleted]
					   ,[UpdateDate]
					   ,[UpdateBy])
				VALUES
					   (@AcademicYear
					   ,@FeeTypeId
					   ,@IsGradeWise
					   ,@FeeAmount
					   ,1
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
			END
			ELSE
			BEGIN
				UPDATE tblFeeStructure
						SET [AcademicYear] = @AcademicYear
							,[FeeTypeId] = @FeeTypeId
							,IsGradeWise = @IsGradeWise
							,[FeeAmount] = @FeeAmount
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE FeeStructureId = @FeeStructureId
			END				
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
/****** Object:  StoredProcedure [dbo].[sp_SaveFeeStructure]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveFeeStructure] 
	@LoginUserId INT
	,@FeeStructureId BIGINT
	,@FeeAmount DECIMAL(18,4)=NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1			
		UPDATE [dbo].[tblFeeStructure]
				SET [FeeAmount] = @FeeAmount					
					,[UpdateDate] = GETDATE()
					,[UpdateBy] = @LoginUserId
		WHERE FeeStructureId = @FeeStructureId
		SELECT 0 AS Result, 'Saved' AS Response						
		COMMIT TRAN TRANS1
		
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SaveFeeType]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveFeeType]      
	@LoginUserId int      
	,@FeeTypeId bigint      
	,@FeeTypeName nvarchar(200)  
	,@IsPrimary bit  
	,@IsGradeWise bit  
	,@IsTermPlan bit      
	,@IsPaymentPlan bit     
	,@DebitAccount nvarchar(200)    
	,@CreditAccount nvarchar(200)    
AS      
BEGIN      
 SET NOCOUNT ON;      
 IF EXISTS(SELECT 1 FROM tblFeeTypeMaster WHERE FeeTypeName = @FeeTypeName      
   AND @FeeTypeId <> @FeeTypeId AND IsActive = 1)      
 BEGIN      
  SELECT -2 AS Result, 'Fee Type already exists!' AS Response      
  RETURN;      
 END      
 BEGIN TRY      
  BEGIN TRANSACTION TRANS1      
   IF(@FeeTypeId = 0)      
   BEGIN      
    INSERT INTO tblFeeTypeMaster      
        (
			FeeTypeName      
			,IsTermPlan  
			,IsPrimary
			,IsGradeWise
			,IsPaymentPlan    
			,DebitAccount  
			,CreditAccount
  
			,IsActive      
			,IsDeleted      
			,UpdateDate      
			,UpdateBy
		)      
    VALUES      
		(
			@FeeTypeName 
			,@IsPrimary
			,@IsGradeWise
			,@IsTermPlan     
			,@IsPaymentPlan    
			,@DebitAccount  
			,@CreditAccount  
			,1      
			,0      
			,GETDATE()      
			,@LoginUserId
		)      
   END      
   ELSE      
   BEGIN      
 UPDATE tblFeeTypeMaster      
 SET     
  FeeTypeName = @FeeTypeName 
  ,IsPrimary=@IsPrimary
  ,IsGradeWise=@IsGradeWise
  ,IsTermPlan = @IsTermPlan      
  ,IsPaymentPlan = @IsPaymentPlan    
  ,DebitAccount = @DebitAccount  
  ,CreditAccount = @CreditAccount  
  ,UpdateDate = GETDATE()      
  ,UpdateBy = @LoginUserId      
 WHERE FeeTypeId = @FeeTypeId      
   END          
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
/****** Object:  StoredProcedure [dbo].[sp_SaveFeeTypeDetail]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveFeeTypeDetail]  
	@LoginUserId int  
	,@FeeTypeId bigint  
	,@FeeTypeDetailId bigint  
	,@AcademicYearId bigint  
	,@GradeId bigint 
	,@TermFeeAmount decimal(18,2)
	,@StaffFeeAmount decimal(18,2)
    ,@GradeRules nvarchar(400)=NULL  
AS  
BEGIN  
 SET NOCOUNT ON;  
 
 BEGIN TRY  
  BEGIN TRANSACTION TRANS1  

   SELECT * INTO #TempAssignedDiscountRule2 FROM (SELECT ROW_NUMBER() OVER(ORDER BY OutParam) RN, OutParam FROM SplitString(@GradeRules,',')) x      
     
	SELECT 
		@LoginUserId as LoginUserId
		,@FeeTypeId as FeeTypeId
		,@FeeTypeDetailId as FeeTypeDetailId
		,@AcademicYearId as AcademicYearId
		,@TermFeeAmount as TermFeeAmount
		,@StaffFeeAmount as StaffFeeAmount
		,OutParam as GradeId
	INTO #TempAssignedDiscountRuleWithGradeWise
	FROM 
	#TempAssignedDiscountRule2

	select t.* ,t2.IsGradeWise
	into #TempAssignedDiscountRule
	from #TempAssignedDiscountRuleWithGradeWise t
	inner join tblFeeTypeMaster t2
	on t.FeeTypeId = t2.FeeTypeId

	 --Synchronize the target table with refreshed data from source table
	MERGE [tblFeeTypeDetail] AS TARGET
	USING #TempAssignedDiscountRule AS SOURCE 
	ON (TARGET.FeeTypeId = SOURCE.FeeTypeId AND TARGET.AcademicYearId = SOURCE.AcademicYearId 
	AND ((SOURCE.IsGradeWise=0) OR (SOURCE.IsGradeWise =1 and TARGET.GradeId = SOURCE.GradeId)) )
	--When records are matched, update the records if there is any change
	WHEN MATCHED 
	THEN UPDATE SET 
		TARGET.TermFeeAmount = SOURCE.TermFeeAmount, 
		TARGET.StaffFeeAmount = SOURCE.StaffFeeAmount,
		TARGET.IsActive =1,
		TARGET.IsDeleted =0,
		TARGET.UpdateDate =GETDATE(),
		TARGET.UpdateBy =@LoginUserId
	--When no records are matched, insert the incoming records from source table to target table
	WHEN NOT MATCHED BY TARGET 
	THEN INSERT (	FeeTypeId,	AcademicYearId	,GradeId	, TermFeeAmount	, StaffFeeAmount,
	IsActive	,IsDeleted	,UpdateDate,	UpdateBy) 
	VALUES (SOURCE.FeeTypeId, SOURCE.AcademicYearId,isnull( SOURCE.GradeId,0),	SOURCE.TermFeeAmount,  SOURCE.StaffFeeAmount,
	1,0,GETDATE(),@LoginUserId)
	--When there is a row that exists in target and same record does not exist in source then delete this record target
	--WHEN NOT MATCHED BY SOURCE 
	--THEN DELETE 
	--$action specifies a column of type nvarchar(10) in the OUTPUT clause that returns 
	--one of three values for each row: 'INSERT', 'UPDATE', or 'DELETE' according to the action that was performed on that row
	--OUTPUT $action, 
	--DELETED.ProductID AS TargetProductID, 
	--DELETED.ProductName AS TargetProductName, 
	--DELETED.Rate AS TargetRate, 
	--INSERTED.ProductID AS SourceProductID, 
	--INSERTED.ProductName AS SourceProductName, 
	--INSERTED.Rate AS SourceRate; 
	;

	--SELECT @@ROWCOUNT;

  COMMIT TRAN TRANS1  
  SELECT 0 AS Result, 'Saved' AS Response  

     IF OBJECT_ID('tempdb..#TempAssignedDiscountRule') IS NOT NULL DROP TABLE #TempAssignedDiscountRule  
   IF OBJECT_ID('tempdb..#TempAssignedDiscountRule2') IS NOT NULL DROP TABLE #TempAssignedDiscountRule2  
    IF OBJECT_ID('tempdb..#TempAssignedDiscountRuleWithGradeWise') IS NOT NULL DROP TABLE #TempAssignedDiscountRuleWithGradeWise  



 END TRY  
  
 BEGIN CATCH  
   ROLLBACK TRAN TRANS1  
   SELECT -1 AS Result, 'Error!' AS Response  
   EXEC usp_SaveErrorDetail  
   RETURN  
 END CATCH  
END

GO
/****** Object:  StoredProcedure [dbo].[sp_SaveGender]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_SaveGender]
	@LoginUserId int
	,@GenderTypeId bigint
	,@GenderTypeName nvarchar(200)
	,@DebitAccount nvarchar(200)  
   ,@CreditAccount nvarchar(200) 
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblGenderTypeMaster WHERE GenderTypeName = @GenderTypeName
			AND GenderTypeId <> @GenderTypeId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Gender already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@GenderTypeId = 0)
			BEGIN
				INSERT INTO tblGenderTypeMaster
					   (GenderTypeName
					   ,DebitAccount
		                ,CreditAccount
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@GenderTypeName	
					   ,@DebitAccount
	                	,@CreditAccount
					   ,@IsActive	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
			END
			ELSE
			BEGIN
				UPDATE tblGenderTypeMaster
						SET GenderTypeName = @GenderTypeName	
	                         ,DebitAccount = @DebitAccount
		                     ,CreditAccount = @CreditAccount
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE GenderTypeId = @GenderTypeId
			END				
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
/****** Object:  StoredProcedure [dbo].[sp_SaveGenerateFee]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveGenerateFee]
	@LoginUserId int
	,@FeeGenerateId int
	,@SchoolAcademicId bigint = 0
	,@FeeTypeId bigint  = 0
	,@GradeId bigint  = 0
	,@ActionId int --1 Generate,5 Regenerate 
AS
BEGIN
	--1	Generate
	--2	Applied-Pending for Approval
	--3	Applied
	--4	Rejected
	--5	Regenerate
	IF @ActionId=1 AND EXISTS(SELECT 1 FROM tblFeeGenerate WHERE SchoolAcademicId=@SchoolAcademicId AND FeeTypeId=@FeeTypeId AND GradeId=@GradeId) 
	BEGIN
		SELECT -2 AS Result, 'Fee already generated. Please regenrate from grid' AS Response  
		RETURN;  
	END
	SET NOCOUNT ON;	
	BEGIN TRY
	BEGIN TRANSACTION TRANS1
		IF(@ActionId=1)
		BEGIN			
			INSERT INTO tblFeeGenerate
				(SchoolAcademicId, FeeTypeId, GradeId, GenerateStatus, UpdateDate, UpdateBy)
				VALUES (@SchoolAcademicId, @FeeTypeId, @GradeId, 1, GETDATE(), @LoginUserId)	
			SET @FeeGenerateId=SCOPE_IDENTITY();
		END
		ELSE IF(@ActionId=5)
		BEGIN
			DELETE FROM tblFeeGenerateDetail WHERE FeeGenerateId=@FeeGenerateId
			UPDATE tblFeeGenerate SET GenerateStatus=5 WHERE FeeGenerateId=@FeeGenerateId 
		END
		SELECT @SchoolAcademicId=SchoolAcademicId,@FeeTypeId=FeeTypeId,@GradeId=GradeId FROM tblFeeGenerate WHERE FeeGenerateId=@FeeGenerateId
		INSERT INTO tblFeeGenerateDetail(FeeGenerateId,StudentId,SchoolAcademicId,GradeId,FeeTypeId,FeeAmount,UpdateDate,UpdateBy)		
		SELECT
			FeeGenerateId=@FeeGenerateId
			,st.StudentId
			,t.AcademicYearId
			,t.GradeId
			,t.FeeTypeId
			,FeeAmount= CASE WHEN tp.IsFatherStaff=1 OR tp.IsMotherStaff=1 THEN t.StaffFeeAmount ELSE t.TermFeeAmount END
			,UpdateDate=GETDATE()
			,UpdateBy=@LoginUserId
		FROM tblStudent st
		LEFT JOIN tblParent tp
		ON tp.ParentId = st.ParentId
		INNER JOIN (SELECT tf.GradeId,tf.TermFeeAmount,tf.StaffFeeAmount,tf.AcademicYearId,tf.FeeTypeId 
					FROM tblFeeTypeDetail tf 
					WHERE tf.AcademicYearId=@SchoolAcademicId AND tf.FeeTypeId=@FeeTypeId 
						AND tf.GradeId=@GradeId AND tf.IsActive=1 AND tf.IsDeleted=0
		)t
		ON t.GradeId=st.GradeId
		WHERE st.IsActive=1 and st.IsDeleted=0
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
/****** Object:  StoredProcedure [dbo].[sp_SaveGrade]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--alter table tblGradeMaster drop column AdvanceAccountRemarks		

--alter table tblGradeMaster add DebitAccount nvarchar(200)
--alter table tblGradeMaster add CreditAccount nvarchar(200)
--select * from tblGradeMaster

CREATE PROCEDURE [dbo].[sp_SaveGrade]  
 @LoginUserId int  
 ,@GradeId int  
 ,@GradeName nvarchar(200)  
 ,@CostCenterId int  
 ,@GenderTypeId int=0  
  ,@DebitAccount nvarchar(200)  
   ,@CreditAccount nvarchar(200)  
 ,@IsActive bit  
AS  
BEGIN  
 SET NOCOUNT ON;  
   
 IF(@GradeId=0)  
 BEGIN   
  IF EXISTS(SELECT 1 FROM tblGradeMaster WHERE GradeName = @GradeName AND CostCenterId <> @CostCenterId  AND IsActive = 1 AND IsDeleted = 0)  
  BEGIN  
   SELECT -3 AS Result, 'Grade already exist in another Cost Center!' AS Response  
   RETURN;  
  END  
  ELSE IF EXISTS(SELECT 1 FROM tblGradeMaster WHERE GradeName = @GradeName AND CostCenterId = @CostCenterId   
  AND ISNULL(GenderTypeId,0) = ISNULL(@GenderTypeId,0)  AND IsActive = 1 AND IsDeleted = 0)  
  BEGIN  
   SELECT -2 AS Result, 'Grade already exists!' AS Response  
   RETURN;  
  END  
 END   
 ELSE  
 BEGIN  
  IF EXISTS(SELECT 1 FROM tblGradeMaster WHERE GradeName = @GradeName AND CostCenterId = @CostCenterId AND ISNULL(GenderTypeId,0) = ISNULL(@GenderTypeId,0)  
   AND GradeId <> @GradeId AND IsActive = 1 AND IsDeleted = 0)   
  BEGIN  
   SELECT -2 AS Result, 'Grade already exists!' AS Response  
   RETURN;  
  END  
 END  
 BEGIN TRY  
  BEGIN TRANSACTION TRANS1   
    
   IF(@GradeId = 0)  
   BEGIN  
    INSERT INTO tblGradeMaster  
        (GradeName        
        ,CostCenterId        
        ,GenderTypeId   
		,DebitAccount
		,CreditAccount

        ,SequenceNo   
        ,IsActive  
        ,IsDeleted  
        ,UpdateDate  
        ,UpdateBy)  
    VALUES  
        (@GradeName        
        ,@CostCenterId       
        ,@GenderTypeId 
		,@DebitAccount
		,@CreditAccount

        ,(SELECT ISNULL(MAX(SequenceNo),0)+1 FROM tblGradeMaster WHERE IsActive=1 AND IsDeleted=0)  
        ,@IsActive   
        ,0  
        ,GETDATE()  
        ,@LoginUserId)  
  
    SET @GradeId =SCOPE_IDENTITY()  
  
   END  
   ELSE  
   BEGIN  
    UPDATE tblGradeMaster  
      SET GradeName = @GradeName        
       ,CostCenterId = @CostCenterId       
       ,GenderTypeId = @GenderTypeId  

	   ,DebitAccount = @DebitAccount
		,CreditAccount = @CreditAccount

       ,IsActive = @IsActive        
       ,UpdateDate = GETDATE()  
       ,UpdateBy = @LoginUserId  
    WHERE GradeId = @GradeId      
   END  
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
/****** Object:  StoredProcedure [dbo].[sp_SaveGradeWiseFeeStructure]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveGradeWiseFeeStructure]
	@LoginUserId INT
	,@FeeGradewiseId BIGINT
	,@FirstAmount DECIMAL(18,4)=NULL
	,@FirstDueDate DATETIME=NULL
	,@SecondAmount DECIMAL(18,4)=NULL
	,@SecondDueDate DATETIME=NULL
	,@ThirdAmount DECIMAL(18,4)=NULL
	,@ThirdDueDate DATETIME=NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1			
		UPDATE [dbo].[tblFeeGradewise]
				SET [FirstAmount] = @FirstAmount
					,[FirstDueDate] = @FirstDueDate
					,[SecondAmount] = @SecondAmount
					,[SecondDueDate] = @SecondDueDate
					,[ThirdAmount] = @ThirdAmount
					,[ThirdDueDate] = @ThirdDueDate					
					,[UpdateDate] = GETDATE()
					,[UpdateBy] = @LoginUserId
		WHERE FeeGradewiseId = @FeeGradewiseId
		SELECT 0 AS Result, 'Saved' AS Response						
		COMMIT TRAN TRANS1		
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SaveInvoice]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveInvoice] 
	@LoginUserId int 
	,@PaymentMethod	nvarchar(100)
	,@PaymentReferenceNumber	nvarchar(100)
	,@Status	nvarchar(20)	
	,@ParentID	nvarchar(100)
	,@IqamaNumber	nvarchar(100)	
	,@InvoiceDate	datetime	
AS      
BEGIN      
 SET NOCOUNT ON;      
 --IF EXISTS(SELECT 1 FROM tblInvoiceSummary WHERE @InvoiceNo <> InvoiceNo AND IsDeleted = 1)      
 --BEGIN      
 -- SELECT -2 AS Result, 'Invoice already exists!' AS Response      
 -- RETURN;      
 --END      
 BEGIN TRY      
	BEGIN TRANSACTION TRANS1 
	DECLARE @_InvoiceNo int
	IF (@_InvoiceNo IS NULL)
	BEGIN
		SELECT @_InvoiceNo=COUNT(*)+1 FROM tblInvoiceSummary WHERE IsDeleted=0
	END
    INSERT INTO tblInvoiceSummary	
	(
		InvoiceNo
		,PaymentMethod
		,PaymentReferenceNumber
		,[Status]
		,ParentID
		,IqamaNumber
		,InvoiceDate
		,IsDeleted      
		,UpdateDate      
		,UpdateBy
	)      
	VALUES      
	(          
		@_InvoiceNo
		,@PaymentMethod
		,@PaymentReferenceNumber
		,@Status
		,@ParentID
		,@IqamaNumber
		,@InvoiceDate
		,0      
		,GETDATE()      
		,@LoginUserId
	) 
	COMMIT TRAN TRANS1      
	SELECT 0 AS Result, 'Saved' AS Response ,@_InvoiceNo AS InvoiceNo
	END TRY 
	BEGIN CATCH      
		ROLLBACK TRAN TRANS1      
		SELECT -1 AS Result, 'Error!' AS Response      
		EXEC usp_SaveErrorDetail      
		RETURN      
	END CATCH      
END 
GO
/****** Object:  StoredProcedure [dbo].[sp_SaveInvoiceDetail]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_SaveInvoiceDetail]      
	@LoginUserId int      
	,@InvoiceNo	nvarchar(100)
	,@InvoiceType	nvarchar(100)
	,@Description	nvarchar(300)
	,@Discount	decimal(18,2)
	,@Quantity	decimal(18,2)
	,@UnitPrice	decimal(18,2)
	,@StudentId	nvarchar(100)
	,@Grade	nvarchar(100)
	,@TaxableAmount	decimal(18,2)
	,@TaxRate	decimal(18,2)
	,@TaxAmount	decimal(18,2)
	,@ItemSubtotal	decimal(18,2)
AS      
BEGIN      
	SET NOCOUNT ON;      
	IF EXISTS(SELECT 1 FROM tblInvoiceDetail WHERE @InvoiceNo <> InvoiceNo)      
	BEGIN      
		SELECT -2 AS Result, 'Invoice Detail already exists!' AS Response      
		RETURN;      
	END      
	BEGIN TRY      
		BEGIN TRANSACTION TRANS1 
		INSERT INTO tblInvoiceDetail      
		(
			InvoiceNo
			,InvoiceType
			,[Description]
			,Discount
			,Quantity
			,UnitPrice
			,StudentId
			,Grade
			,TaxableAmount
			,TaxRate
			,TaxAmount
			,ItemSubtotal
			,CreatedOn
			,CreatedBy
		)      
		VALUES      
		(          
			@InvoiceNo
			,@InvoiceType
			,@Description
			,@Discount
			,@Quantity
			,@UnitPrice
			,@StudentId
			,@Grade
			,@TaxableAmount
			,@TaxRate
			,@TaxAmount
			,@ItemSubtotal			 
			,GETDATE()      
			,@LoginUserId
		)  
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
/****** Object:  StoredProcedure [dbo].[sp_SaveInvoiceType]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveInvoiceType]
	@LoginUserId int
	,@InvoiceTypeId bigint
	,@InvoiceTypeName nvarchar(200)
	,@ReceivableAccount nvarchar(200)
	,@AdvanceAccount nvarchar(200)
	,@ReceivableAccountRemarks nvarchar(400)
	,@AdvanceAccountRemarks nvarchar(400)
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblInvoiceTypeMaster WHERE InvoiceTypeName = @InvoiceTypeName
			AND InvoiceTypeId <> @InvoiceTypeId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Invoice Type already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@InvoiceTypeId = 0)
			BEGIN
				INSERT INTO tblInvoiceTypeMaster
					   (InvoiceTypeName	
					   ,ReceivableAccount
					   ,AdvanceAccount
					   ,ReceivableAccountRemarks
					   ,AdvanceAccountRemarks
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@InvoiceTypeName
					    ,@ReceivableAccount
					   ,@AdvanceAccount
					   ,@ReceivableAccountRemarks
					   ,@AdvanceAccountRemarks
					   ,@IsActive	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
			END
			ELSE
			BEGIN
				UPDATE tblInvoiceTypeMaster
						SET InvoiceTypeName = @InvoiceTypeName	
						,ReceivableAccount = @ReceivableAccount
					        ,AdvanceAccount = @AdvanceAccount
							,ReceivableAccountRemarks = @ReceivableAccountRemarks   
					        ,AdvanceAccountRemarks = @AdvanceAccountRemarks
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE InvoiceTypeId = @InvoiceTypeId
			END				
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
/****** Object:  StoredProcedure [dbo].[sp_SaveNotification]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveNotification]
	@LoginUserId int
	,@ActionTable nvarchar(200)
	,@NotificationAction nvarchar(200)
	,@TableRecordId bigint
	,@OldValueJson nvarchar(1000)
	,@NewValueJson nvarchar(1000)
	,@TableRecordColumnName nvarchar(200)=null
AS
BEGIN 
	SET NOCOUNT ON;
	DECLARE @NotificationGroupId int=0
	DECLARE @NotificationTypeId int
	BEGIN TRY
		BEGIN TRANSACTION TRANS2
		--Create or Increase Notification Group Count
		BEGIN
			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable=@ActionTable
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=@NotificationAction
			IF (@NotificationGroupId=0)
			BEGIN
				INSERT INTO tblNotificationGroup (NotificationTypeId,NotificationCount,NotificationAction)
				VALUES (@NotificationTypeId,0,@NotificationAction)
				SET @NotificationGroupId=SCOPE_IDENTITY();
			END
			UPDATE tblNotificationGroup SET NotificationCount=NotificationCount+1 WHERE NotificationGroupId=@NotificationGroupId
		END
		--Insert Notification
		BEGIN
			INSERT INTO tblNotificationGroupDetail
					(NotificationGroupId
					,NotificationTypeId
					,NotificationAction
					,TableRecordId
					,OldValueJson
					,NewValueJson
					,TableRecordColumnName
					,CreatedBy)
			VALUES
					(@NotificationGroupId											  
					,@NotificationTypeId	
					,@NotificationAction
					,@TableRecordId
					,@OldValueJson
					,@NewValueJson
					,@TableRecordColumnName
					,@LoginUserId)
		END		
		COMMIT TRAN TRANS2
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS2
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SaveOpenApply]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_SaveOpenApply]  
	@LoginUserId int  
	,@OpenApplyId bigint  
	,@GrantType nvarchar(200)  
	,@ClientId nvarchar(200)  
	,@ClientSecret nvarchar(200)  
	,@Audience nvarchar(200)  
	,@OpenApplyJobPath nvarchar(200)  
	,@IsActive bit  
AS  
BEGIN  
 SET NOCOUNT ON;  
 
 BEGIN TRY  
  BEGIN TRANSACTION TRANS1  
   IF(@OpenApplyId = 0)  
   BEGIN  
    INSERT INTO [tblOpenApplyMaster]  
        (
			GrantType
			,ClientId
			,ClientSecret
			,Audience
			,OpenApplyJobPath

			,IsActive  
			,IsDeleted  
			,UpdateDate  
			,UpdateBy
		)  
    VALUES  
        (
			 @GrantType
			,@ClientId
			,@ClientSecret
			,@Audience
			,@OpenApplyJobPath

			,@IsActive   
			,0  
			,GETDATE()  
			,@LoginUserId
		)  

		--SET @OpenApplyId=SCOPE_IDENTITY();
		--SELECT @OpenApplyId AS Result, 'Saved' AS Response
		SELECT 0 AS Result, 'Saved' AS Response  
   END  
   ELSE  
   BEGIN  
    UPDATE [tblOpenApplyMaster]  
      SET 
		GrantType = @GrantType
		,ClientId = @ClientId
		,ClientSecret = @ClientSecret
		,Audience = @Audience
		,OpenApplyJobPath = @OpenApplyJobPath

       ,IsActive = @IsActive        
       ,UpdateDate = GETDATE()  
       ,UpdateBy = @LoginUserId  
    WHERE OpenApplyId = @OpenApplyId  
   END      
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
/****** Object:  StoredProcedure [dbo].[sp_SaveParent]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveParent]
	@LoginUserId int
	,@ParentId bigint
	,@ParentCode nvarchar(50)
	,@ParentImage nvarchar(500)=NULL
	,@FatherName nvarchar(200)
	,@FatherArabicName nvarchar(200) = NULL
	,@FatherNationalityId int
	,@FatherMobile nvarchar(20)
	,@FatherEmail nvarchar(200)
	,@FatherIqamaNo nvarchar(50)
	,@IsFatherStaff	bit
	,@MotherName nvarchar(200)
	,@MotherArabicName nvarchar(200) = NULL
	,@MotherNationalityId int
	,@MotherMobile nvarchar(20) = NULL
	,@MotherEmail nvarchar(200) = NULL
	,@MotherIqamaNo nvarchar(50) = NULL
	,@IsMotherStaff bit
	,@FPassword nvarchar(500) = NULL
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblParent WHERE  ParentCode = @ParentCode
			AND ParentId <> @ParentId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Parent already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@ParentId = 0)
			BEGIN
			    
				INSERT INTO tblParent
					   (ParentCode
					    ,ParentImage
						,FatherName
						,FatherArabicName
						,FatherNationalityId
						,FatherMobile
						,FatherEmail
						,FatherIqamaNo
						,IsFatherStaff
						,MotherName
						,MotherArabicName
						,MotherNationalityId
						,MotherMobile
						,MotherEmail
						,MotherIqamaNo
						,IsMotherStaff
						,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@ParentCode
					   ,CASE WHEN LEN(ISNULL(@ParentImage,0))>0 THEN @ParentImage ELSE '' END
						,@FatherName
						,@FatherArabicName
						,@FatherNationalityId
						,@FatherMobile
						,@FatherEmail
						,@FatherIqamaNo
						,@IsFatherStaff
						,@MotherName
						,@MotherArabicName
						,@MotherNationalityId
						,@MotherMobile
						,@MotherEmail
						,@MotherIqamaNo
						,@IsMotherStaff
						,@IsActive
					   ,0
					   ,GETDATE()
					   ,@LoginUserId);

				SET @ParentId=SCOPE_IDENTITY();
				--DECLARE @ParentCode VARCHAR(50) =  (SELECT CONCAT(@ParentPrefix, (right('000000'+convert(nvarchar(10),@ParentId),6))));

				--UPDATE tblParent SET ParentCode = @ParentCode WHERE ParentId= @ParentId

				EXEC sp_SaveUser @LoginUserId=@LoginUserId,@UserId=0,@UserName=@FatherName,@UserArabicName=@FatherArabicName,@UserEmail=@FatherEmail
				,@UserPhone=@FatherMobile,@UserPass=@FPassword,@RoleId=3,@IsActive=1
				SELECT @ParentId AS Result, 'Saved' AS Response
			END
			ELSE
			BEGIN
				UPDATE tblParent
						SET FatherName = @FatherName
						,ParentCode = @ParentCode
						,ParentImage=CASE WHEN LEN(ISNULL(@ParentImage,0))>0 THEN ParentImage ELSE @ParentImage END
						,FatherArabicName= @FatherArabicName
						,FatherNationalityId= @FatherNationalityId
						,FatherMobile= @FatherMobile
						,FatherEmail= @FatherEmail
						,FatherIqamaNo=@FatherIqamaNo
						,IsFatherStaff= @IsFatherStaff
						,MotherName= @MotherName
						,MotherArabicName= @MotherArabicName
						,MotherNationalityId= @MotherNationalityId
						,MotherMobile= @MotherMobile
						,MotherEmail= @MotherEmail
						,MotherIqamaNo=@MotherIqamaNo
						,IsMotherStaff= @IsMotherStaff
						,IsActive = @IsActive				
						,UpdateDate = GETDATE()
						,UpdateBy = @LoginUserId
				WHERE ParentId = @ParentId
				SELECT @ParentId AS Result, 'Saved' AS Response
			END				
		COMMIT TRAN TRANS1
		
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SaveParentAccount]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveParentAccount] 
	@LoginUserId int
	,@ParentId bigint
	,@ReceivableAccount nvarchar(200)
	,@AdvanceAccount nvarchar(200)=NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		IF NOT EXISTS(SELECT 1 FROM tblParentAccount WHERE ParentId = @ParentId)
		BEGIN
			INSERT INTO tblParentAccount(ParentId
					,ReceivableAccount
					,AdvanceAccount
					,IsActive
					,IsDeleted
					,UpdateDate
					,UpdateBy)
			VALUES(@ParentId,@ReceivableAccount,@AdvanceAccount,1,0,GETDATE(),@LoginUserId)
			SELECT 0 AS Result, 'Saved' AS Response
		END
		ELSE 
		BEGIN			
			UPDATE tblParentAccount
				SET ReceivableAccount = @ReceivableAccount
					,AdvanceAccount = @AdvanceAccount
					,UpdateBy = @LoginUserId
					,UpdateDate = GETDATE()
			WHERE ParentId = @ParentId		
			SELECT 0 AS Result, 'Saved' AS Response
		END
		COMMIT TRAN TRANS1
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SaveSchool]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveSchool]
	@LoginUserId int
	,@SchoolId bigint
	,@LogoImage nvarchar(500)=NULL
	,@SchoolNameEnglish nvarchar(400)
	,@SchoolNameArabic nvarchar(400)=NULL
	,@BranchId bigint 
	,@CountryId bigint 
	,@City  nvarchar(200) =NULL
	,@Address nvarchar(400) =NULL
	,@Telephone nvarchar(20) =NULL
	,@SchoolEmail nvarchar(200) =NULL
	,@WebsiteUrl nvarchar(400) =NULL
	,@VatNo nvarchar(200) =NULL
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblSchoolMaster WHERE SchoolNameEnglish = @SchoolNameEnglish
			AND SchoolId <> @SchoolId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'School already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@SchoolId = 0)
			BEGIN
				INSERT INTO tblSchoolMaster
					   ([SchoolNameEnglish]
					   ,[SchoolNameArabic]
					   ,Logo
					   ,[BranchId]
					   ,[CountryId]
					   ,[City]
					   ,[Address]
					   ,[Telephone]
					   ,[SchoolEmail]
					   ,[WebsiteUrl]
					   ,[VatNo]
					   ,[IsActive]
					   ,[IsDeleted]
					   ,[UpdateDate]
					   ,[UpdateBy])
				VALUES
					  (@SchoolNameEnglish
					   ,@SchoolNameArabic
					   ,CASE WHEN LEN(ISNULL(@LogoImage,0))>0 THEN @LogoImage ELSE '' END
					   ,@BranchId
					   ,@CountryId
					   ,@City
					   ,@Address
					   ,@Telephone
					   ,@SchoolEmail
					   ,@WebsiteUrl
					   ,@VatNo
					   ,@IsActive
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
					   SET @SchoolId=SCOPE_IDENTITY();
					   SELECT @SchoolId AS Result, 'Saved' AS Response
			END
			ELSE
			BEGIN
				UPDATE tblSchoolMaster
						SET SchoolNameEnglish= @SchoolNameEnglish
						   ,SchoolNameArabic=@SchoolNameArabic
						   	,Logo=CASE WHEN LEN(ISNULL(@LogoImage,0))>0 THEN Logo ELSE @LogoImage END
						   ,BranchId=@BranchId
						   ,CountryId=@CountryId
						   ,City=@City
						   ,[Address]=@Address
						   ,Telephone=@Telephone
						   ,SchoolEmail=@SchoolEmail
						   ,WebsiteUrl=@WebsiteUrl
						   ,VatNo=@VatNo
						   ,IsActive=@IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE SchoolId = @SchoolId
			END				
		COMMIT TRAN TRANS1
		SELECT @SchoolId AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SaveSchoolAcademic]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveSchoolAcademic]  
	@LoginUserId int  
	,@SchoolAcademicId int  
	,@AcademicYear nvarchar(200)    
	,@PeriodFrom datetime  
	,@PeriodTo datetime  
	,@DebitAccount nvarchar(200)  
	,@CreditAccount nvarchar(200)  
	,@IsActive bit  
AS  
BEGIN  
 SET NOCOUNT ON;  
 IF EXISTS(SELECT 1 FROM tblSchoolAcademic WHERE AcademicYear = @AcademicYear  
	AND SchoolAcademicId <> @SchoolAcademicId AND IsActive = 1
		AND 
		(   
			(cast( @PeriodFrom as date) between cast( PeriodFrom as date) AND cast(PeriodTo as date))
		OR
			(cast( @PeriodTo as date) between cast( PeriodFrom as date) AND cast(PeriodTo as date))
		)
	)  
 BEGIN  
  SELECT -2 AS Result, 'Academic year already exists!' AS Response  
  RETURN;  
 END 
 
 IF EXISTS(SELECT 1 FROM tblSchoolAcademic WHERE SchoolAcademicId <> @SchoolAcademicId AND IsActive = 1
		AND 
		(   
			(cast( @PeriodFrom as date) between cast( PeriodFrom as date) AND cast(PeriodTo as date))
		OR
			(cast( @PeriodTo as date) between cast( PeriodFrom as date) AND cast(PeriodTo as date))
		)
	)  
 BEGIN  
  SELECT -4 AS Result, 'Academic year already exists!' AS Response  
  RETURN;  
 END 

 BEGIN TRY  
  BEGIN TRANSACTION TRANS1  
   IF(@SchoolAcademicId = 0)  
   BEGIN  
    INSERT INTO tblSchoolAcademic  
        (AcademicYear  
      ,PeriodFrom  
      ,PeriodTo  
	  ,DebitAccount
		,CreditAccount
        ,IsActive  
        ,IsDeleted  
        ,UpdateDate  
        ,UpdateBy)  
    VALUES  
        (@AcademicYear  
        --,dbo.GetDateTimeFromTimeStamp(@PeriodFrom)  
        --,dbo.GetDateTimeFromTimeStamp(@PeriodTo) 
		,@PeriodFrom
        ,@PeriodTo
		,@DebitAccount
		,@CreditAccount
        ,@IsActive   
        ,0  
        ,GETDATE()  
        ,@LoginUserId)  
   END  
   ELSE  
   BEGIN  
    UPDATE tblSchoolAcademic  
      SET 
       AcademicYear = @AcademicYear  
       --,PeriodFrom = dbo.GetDateTimeFromTimeStamp(@PeriodFrom)        
       --,PeriodTo = dbo.GetDateTimeFromTimeStamp(@PeriodTo)
	   ,PeriodFrom = @PeriodFrom       
       ,PeriodTo =@PeriodTo
	    ,DebitAccount = @DebitAccount
		,CreditAccount = @CreditAccount
       ,IsActive = @IsActive        
       ,UpdateDate = GETDATE()  
       ,UpdateBy = @LoginUserId  
    WHERE SchoolAcademicId = @SchoolAcademicId  
   END      
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
/****** Object:  StoredProcedure [dbo].[sp_SaveSchoolAccountInfo]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveSchoolAccountInfo]  
	@LoginUserId int  
	,@SchoolAccountIId bigint  
	,@SchoolId bigint  
	,@ReceivableAccount nvarchar(50)  
	,@AdvanceAccount nvarchar(50)  
	,@CodeDescription nvarchar(200)  
AS  
BEGIN  
 SET NOCOUNT ON;  
 IF EXISTS(SELECT 1 FROM tblSchoolAccountInfo WHERE CodeDescription = @CodeDescription AND SchoolId=@SchoolId  
   AND SchoolAccountIId <> @SchoolAccountIId AND IsActive = 1)  

 BEGIN  
  SELECT -2 AS Result, 'Account description already exists!' AS Response  
  RETURN;  
 END  
 BEGIN TRY  
  BEGIN TRANSACTION TRANS1  
   IF(@SchoolAccountIId = 0)  
   BEGIN  
    INSERT INTO tblSchoolAccountInfo  
        (SchoolId  
        ,ReceivableAccount
		 ,AdvanceAccount
        ,CodeDescription  
        ,IsActive  
        ,IsDeleted  
        ,UpdateDate  
        ,UpdateBy)  
    VALUES  
        (@SchoolId  
        ,@ReceivableAccount
		,@AdvanceAccount
        ,@CodeDescription           
        ,1   
        ,0  
        ,GETDATE()  
        ,@LoginUserId)  
   END  
   ELSE  
   BEGIN  
    UPDATE tblSchoolAccountInfo  
      SET SchoolId = @SchoolId  
       ,ReceivableAccount = @ReceivableAccount  
	   ,AdvanceAccount=@AdvanceAccount
       ,CodeDescription = @CodeDescription    
       ,UpdateDate = GETDATE()  
       ,UpdateBy = @LoginUserId  
    WHERE SchoolAccountIId = @SchoolAccountIId  
   END      
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
/****** Object:  StoredProcedure [dbo].[sp_SaveSchoolTermAcademic]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- *** SqlDbx Personal Edition ***
-- !!! Not licensed for commercial use beyound 90 days evaluation period !!!
-- For version limitations please check http://www.sqldbx.com/personal_edition.htm
-- Number of queries executed: 15, number of rows retrieved: 48

CREATE PROCEDURE [dbo].[sp_SaveSchoolTermAcademic]      
 @LoginUserId int      
 ,@SchoolTermAcademicId int      
 ,@SchoolAcademicId int      
 ,@TermName nvarchar(100)      
 ,@StartDate datetime      
 ,@EndDate datetime          
AS      
BEGIN      
 SET NOCOUNT ON;      
 IF EXISTS(SELECT 1 FROM tblSchoolTermAcademic WHERE SchoolAcademicId = @SchoolAcademicId AND TermName=@TermName       
   AND SchoolTermAcademicId <> @SchoolTermAcademicId AND IsDeleted = 0)      
 BEGIN      
  SELECT -2 AS Result, 'Term Academic year already exists!' AS Response      
  RETURN;      
 END      
 IF EXISTS(SELECT 1 FROM tblSchoolAcademic sa      
    WHERE sa.SchoolAcademicId = @SchoolAcademicId AND sa.IsActive = 1      
    AND CONVERT(date,@StartDate)<CONVERT(date,sa.PeriodFrom))      
 BEGIN      
  SELECT -4 AS Result, 'Term Start Date can not be less then acadmic start date!' AS Response      
  RETURN;      
 END      
 IF EXISTS(SELECT 1 FROM tblSchoolAcademic sa      
    WHERE sa.SchoolAcademicId = @SchoolAcademicId AND sa.IsActive = 1      
    AND  CONVERT(date,@EndDate)>CONVERT(date,sa.PeriodTo))      
 BEGIN      
  SELECT -5 AS Result, 'Term End Date can not be greater then acadmic end date!' AS Response      
  RETURN;      
 END      
 IF @SchoolTermAcademicId=0      
 BEGIN       
  IF EXISTS(SELECT 1 FROM tblSchoolTermAcademic sta          
     WHERE  SchoolAcademicId = @SchoolAcademicId  AND sta.IsDeleted = 0    
     AND (CONVERT(date,@StartDate) BETWEEN CONVERT(date,sta.StartDate) AND CONVERT(date,sta.EndDate)      
     OR CONVERT(date,@EndDate) BETWEEN CONVERT(date,sta.StartDate) AND CONVERT(date,sta.EndDate)      
     ))      
  BEGIN      
   SELECT -5 AS Result, 'Term already exists' AS Response      
   RETURN;      
  END      
 END      
 BEGIN TRY      
  BEGIN TRANSACTION TRANS1      
   IF(@SchoolTermAcademicId = 0)      
   BEGIN      
    INSERT INTO tblSchoolTermAcademic      
        (      
      SchoolAcademicId      
      ,TermName             
      ,StartDate       
      ,EndDate    
	   ,IsApproved     
        ,IsRejected   
        ,IsDeleted      
        ,UpdateDate      
        ,UpdateBy)      
    VALUES      
        (@SchoolAcademicId      
        ,@TermName       
        ,@StartDate      
        ,@EndDate 
		,1
		,0   
        ,0      
        ,GETDATE()      
        ,@LoginUserId)      
   END      
   ELSE      
   BEGIN      
    UPDATE tblSchoolTermAcademic      
      SET SchoolAcademicId = @SchoolAcademicId      
       ,TermName = @TermName         
       ,StartDate = @StartDate         
       ,EndDate = @EndDate   
       ,UpdateDate = GETDATE()      
       ,UpdateBy = @LoginUserId      
    WHERE SchoolTermAcademicId = @SchoolTermAcademicId      
   END          
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
/****** Object:  StoredProcedure [dbo].[sp_SaveSection]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_SaveSection]
	@LoginUserId int
	,@SectionId int
	,@SectionName nvarchar(200)
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblSection WHERE SectionName = @SectionName 
			AND SectionId <> @SectionId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Section already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1		
			IF(@SectionId = 0)
			BEGIN
				INSERT INTO tblSection
					   (SectionName			  
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@SectionName
					   ,@IsActive	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId);				
			END
			ELSE
			BEGIN
				UPDATE tblSection
						SET SectionName = @SectionName
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE SectionId = @SectionId				  
			END				
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
/****** Object:  StoredProcedure [dbo].[sp_SaveStudent]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveStudent]
	@LoginUserId int
	,@StudentId	bigint
	,@ParentId	int
	,@StudentCode	nvarchar(50)
	,@StudentName	nvarchar(200)
	,@StudentImage nvarchar(500)=NULL
	,@StudentEmail nvarchar(200)=NULL
	,@StudentArabicName	nvarchar(200) =NULL
	,@DOB	datetime
	,@IqamaNo	nvarchar(100)
	,@NationalityId	int
	,@GenderId	int
	,@AdmissionDate	datetime = NULL
	,@GradeId	int
	,@CostCenterId	int
	,@SectionId	int
	,@PassportNo	nvarchar(50)=NULL
	,@PassportExpiry	datetime=NULL
	,@Mobile	nvarchar(20)=NULL
	,@StudentAddress	nvarchar(400)
	,@StudentStatusId	int
	,@WithdrawDate datetime =NULL
	,@WithdrawAt int=null
	,@WithdrawYear nvarchar(20)=NULL
	,@Fees	decimal(12,2)=NULL
	,@IsGPIntegration	bit
	,@TermId	int
	,@AdmissionYear nvarchar(20) = NULL
	,@PrinceAccount bit
	,@UserPass nvarchar(500)= NULL
	,@IsActive	bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblStudent WHERE StudentCode = @StudentCode
			AND StudentId <> @StudentId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Student already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@StudentId = 0)
			BEGIN
			    
				INSERT INTO tblStudent
					             ([StudentCode]
								   ,[StudentImage]
								   ,[ParentId]
								   ,[StudentName]
								   ,[StudentArabicName]
								   ,[StudentEmail]
								   ,[DOB]
								   ,[IqamaNo]
								   ,[NationalityId]
								   ,[GenderId]
								   ,[AdmissionDate]
								   ,[GradeId]
								   ,[CostCenterId]
								   ,[SectionId]
								   ,[PassportNo]
								   ,[PassportExpiry]
								   ,[Mobile]
								   ,[StudentAddress]
								   ,[StudentStatusId]
								   ,[WithdrawDate]
								   ,[WithdrawAt]
								   ,[WithdrawYear]
								   ,[Fees]
								   ,[IsGPIntegration]
								   ,[TermId]
								   ,[AdmissionYear]
								   ,[PrinceAccount]
								   ,[IsActive]
								   ,[IsDeleted]
								   ,[UpdateDate]
								   ,[UpdateBy])
				VALUES			 
					   (@StudentCode						
						,CASE WHEN LEN(ISNULL(@StudentImage,0))>0 THEN @StudentImage ELSE '' END
						,@ParentId
						,@StudentName
						,@StudentArabicName
						,@StudentEmail
						,@DOB
						,@IqamaNo
						,@NationalityId
						,@GenderId
						,CASE WHEN @AdmissionDate IS NULL THEN NULL ELSE  @AdmissionDate END
						,@GradeId
						,@CostCenterId
						,@SectionId
						,@PassportNo
						,CASE WHEN @PassportExpiry IS NULL THEN NULL ELSE @PassportExpiry END
						,@Mobile
						,@StudentAddress
						,@StudentStatusId
						,CASE WHEN @WithdrawDate IS NULL THEN NULL ELSE @WithdrawDate END
						,@WithdrawAt
						,@WithdrawYear
						,@Fees
						,@IsGPIntegration
						,@TermId
						,@AdmissionYear
						,@PrinceAccount
						,@IsActive
					   ,0
					   ,GETDATE()
					   ,@LoginUserId);

				SET @StudentId=SCOPE_IDENTITY();
				
				EXEC sp_SaveUser @LoginUserId=@LoginUserId,@UserId=0,@UserName=@StudentName,@UserArabicName=@StudentArabicName,@UserEmail=@StudentEmail
				,@UserPhone=@Mobile,@UserPass=@UserPass,@RoleId=2,@IsActive=1
				SELECT @StudentId AS Result, 'Saved' AS Response
			END
			ELSE
			BEGIN
				UPDATE tblStudent
						SET 
						ParentId=@ParentId
						,StudentCode = @StudentCode
						,StudentName=@StudentName
						,StudentArabicName=@StudentArabicName
						,StudentImage=CASE WHEN LEN(ISNULL(@StudentImage,0))>0 THEN StudentImage ELSE @StudentImage END					
						,StudentEmail=@StudentEmail
						,DOB=@DOB
						,IqamaNo=@IqamaNo
						,NationalityId=@NationalityId
						,GenderId=@GenderId
						,AdmissionDate=CASE WHEN @AdmissionDate IS NULL THEN NULL ELSE @AdmissionDate END 
						,GradeId=@GradeId
						,CostCenterId=@CostCenterId
						,SectionId=@SectionId
						,PassportNo=@PassportNo
						,PassportExpiry=CASE WHEN @PassportExpiry IS NULL THEN NULL ELSE @PassportExpiry END
						,Mobile=@Mobile
						,StudentAddress=@StudentAddress
						,StudentStatusId=@StudentStatusId
						,WithdrawDate=CASE WHEN @WithdrawDate IS NULL THEN NULL ELSE @WithdrawDate END
						,WithdrawAt=@WithdrawAt
						,WithdrawYear=@WithdrawYear
						,Fees=@Fees
						,IsGPIntegration=@IsGPIntegration
						,TermId=@TermId
						,AdmissionYear=@AdmissionYear
						,PrinceAccount=@PrinceAccount
						,IsActive=@IsActive			
						,UpdateDate = GETDATE()
						,UpdateBy = @LoginUserId
				WHERE StudentId = @StudentId
				SELECT @StudentId AS Result, 'Saved' AS Response
			END				
		COMMIT TRAN TRANS1
		
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1			
			SELECT -1 AS Result, 'Error!' AS Response
			EXEC usp_SaveErrorDetail
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SaveStudentFeeDetail]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveStudentFeeDetail]  
	@LoginUserId int  
	,@StudentFeeDetailId bigint
	,@StudentId bigint  
	,@AcademicYearId bigint
	,@GradeId bigint
	,@FeeTypeId bigint
	,@FeeAmount decimal(18,2)
AS  
BEGIN  
	SET NOCOUNT ON;  
	IF EXISTS(	SELECT 1 FROM tblStudentFeeDetail 
				WHERE StudentId = @StudentId 
					AND AcademicYearId=@AcademicYearId AND GradeId=@GradeId
					AND FeeTypeId =@FeeTypeId
					AND StudentFeeDetailId <> @StudentFeeDetailId 
					AND IsActive = 1 AND IsDeleted = 0)  
	BEGIN  
		SELECT -2 AS Result, 'Fee already exists!' AS Response  
		RETURN;  
	END 
	BEGIN TRY  
	BEGIN TRANSACTION TRANS1  
		IF(@StudentFeeDetailId = 0)  
		BEGIN  
			INSERT INTO tblStudentFeeDetail  
				(StudentId  
				,AcademicYearId  
				,GradeId  
				,FeeTypeId
				,FeeAmount
				,IsActive  
				,IsDeleted  
				,UpdateDate  
				,UpdateBy)  
			VALUES  
				(@StudentId
				,@AcademicYearId
				,@GradeId
				,@FeeTypeId
				,@FeeAmount
				,1   
				,0  
				,GETDATE()  
				,@LoginUserId)  
		END  
		ELSE  
		BEGIN  
			UPDATE tblStudentFeeDetail  
				SET FeeAmount = @FeeAmount
					,UpdateDate = GETDATE()  
					,UpdateBy = @LoginUserId  
			WHERE StudentFeeDetailId = @StudentFeeDetailId  
		END      
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
/****** Object:  StoredProcedure [dbo].[sp_SaveStudentStatus]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_SaveStudentStatus]
	@LoginUserId int
	,@StudentStatusId bigint
	,@StatusName nvarchar(200)
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblStudentStatus WHERE StatusName = @StatusName
			AND StudentStatusId <> @StudentStatusId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'Student Status already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@StudentStatusId = 0)
			BEGIN
				INSERT INTO tblStudentStatus
					   (StatusName						  
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@StatusName							  
					   ,@IsActive	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
			END
			ELSE
			BEGIN
				UPDATE tblStudentStatus
						SET StatusName = @StatusName
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE StudentStatusId = @StudentStatusId
			END				
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
/****** Object:  StoredProcedure [dbo].[sp_SaveUploadDocument]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_SaveUploadDocument]
	@LoginUserId int
	,@UploadedDocId bigint
	,@DocFor nvarchar(50)
	,@DocType int
	,@DocForId bigint
	,@DocNo nvarchar(50)
	,@DocPath nvarchar(400) = NULL
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
		BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@UploadedDocId = 0)
			BEGIN
			    
			
INSERT INTO [dbo].[tblUploadDocument]([DocFor],[DocType],[DocForId],[DocNo],[DocPath]
           ,[IsActive],[IsDeleted],[UpdateDate],[UpdateBy])
     VALUES (
		   @DocFor,@DocType,@DocForId,@DocNo,@DocPath
           ,@IsActive,0 ,GETDATE(),@LoginUserId)

			

			END
			ELSE
			BEGIN
				UPDATE tblUploadDocument
						SET [DocFor] = @DocFor
						,[DocType]= @DocType
						,[DocForId]= @DocForId
						,[DocNo]= @DocNo
						,[DocPath]= @DocPath
						,[IsActive]= @IsActive
						,UpdateDate = GETDATE()
						,UpdateBy = @LoginUserId
				WHERE UploadedDocId = @UploadedDocId
			END				
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
/****** Object:  StoredProcedure [dbo].[sp_SaveUser]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_SaveUser]
	@LoginUserId int
	,@UserId int
	,@UserName nvarchar(200)
	,@UserArabicName nvarchar(500)
	,@UserEmail nvarchar(200)
	,@UserPhone nvarchar(20) = NULL
	,@UserPass nvarchar(500) = NULL
	,@RoleId int
	,@IsActive bit
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblUser WHERE UserEmail = @UserEmail 
			AND UserId <> @UserId AND IsActive = 1)
	BEGIN
		SELECT -2 AS Result, 'User already exists!' AS Response
		RETURN;
	END
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@UserId = 0)
			BEGIN
				INSERT INTO tblUser
					   (UserName
					   ,UserArabicName
					   ,UserEmail
					   ,UserPhone
					   ,UserPass
					   ,RoleId					  
					   ,IsActive
					   ,IsDeleted
					   ,UpdateDate
					   ,UpdateBy)
				VALUES
					   (@UserName
					   ,@UserArabicName
					   ,@UserEmail
					   ,@UserPhone		  
					   ,@UserPass
					   ,@RoleId					  
					   ,@IsActive	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
			END
			ELSE
			BEGIN
				UPDATE tblUser
						SET UserName = @UserName
							,UserArabicName = @UserArabicName
							,UserEmail = @UserEmail
							,UserPhone = @UserPhone
							,UserPass = @UserPass
							,RoleId = @RoleId						
							,IsActive = @IsActive						
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE UserId = @UserId
			END				
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
/****** Object:  StoredProcedure [dbo].[sp_SaveUserImage]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_SaveUserImage] 
	@LoginUserId int
	,@UserId int
	,@ImgPath nvarchar(500)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		UPDATE tblUser
			SET ProfileImg = @ImgPath
				,UpdateBy = @LoginUserId
				,UpdateDate = GETDATE()
		WHERE UserId = @UserId
					
		COMMIT TRAN TRANS1
		SELECT 0 AS Result, 'Saved' AS Response
	END TRY

	BEGIN CATCH
			ROLLBACK TRAN TRANS1
			SELECT -1 AS Result, 'Error!' AS Response
			RETURN
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SaveVat]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--alter table tblVatMaster drop column GLAccount
--alter table tblVatMaster add DebitAccount nvarchar(200)
--alter table tblVatMaster add CreditAccount nvarchar(200)

CREATE PROCEDURE [dbo].[sp_SaveVat]  
 @LoginUserId int  
 ,@VatId bigint  
 ,@FeeTypeId bigint  
 ,@VatTaxPercent decimal(18,2)  
 ,@DebitAccount nvarchar(200)  
  ,@CreditAccount nvarchar(200)  
AS  
BEGIN  
 SET NOCOUNT ON;  
 IF EXISTS(SELECT 1 FROM tblVatMaster WHERE FeeTypeId=@FeeTypeId and VatId<>@VatId AND IsActive = 1 AND IsDeleted=0)  
 BEGIN  
  SELECT -2 AS Result, 'Vat already exists!' AS Response  
  RETURN;  
 END  
 BEGIN TRY  
  BEGIN TRANSACTION TRANS1  
   IF(@VatId = 0)  
   BEGIN  
    INSERT INTO tblVatMaster  
        (  
        FeeTypeId  
        ,VatTaxPercent  
        ,DebitAccount  
		,CreditAccount  
        ,IsActive  
        ,IsDeleted  
        ,UpdateDate  
        ,UpdateBy)  
    VALUES  
        (  
        @FeeTypeId  
        ,@VatTaxPercent                
        ,@DebitAccount   
		,@CreditAccount   
        ,1  
        ,0  
        ,GETDATE()  
        ,@LoginUserId)  
   END  
   ELSE  
   BEGIN  
    UPDATE tblVatMaster  
      SET FeeTypeId = @FeeTypeId  
       ,VatTaxPercent = @VatTaxPercent  
       ,DebitAccount  = @DebitAccount    
	   ,CreditAccount  = @CreditAccount    
       ,UpdateDate = GETDATE()  
       ,UpdateBy = @LoginUserId  
    WHERE VatId = @VatId  
   END      
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
/****** Object:  StoredProcedure [dbo].[sp_UpdateGenerateFee]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateGenerateFee]
	@LoginUserId int
	,@FeeGenerateId int	
	,@ActionId int --2 Applied-Pending for Approval,3 Applied,4 Rejected,6 Deleted
AS
BEGIN
	--1	Generate
	--2	Applied-Pending for Approval
	--3	Applied
	--4	Rejected
	--5	Regenerate
	--6 Deleted
	SET NOCOUNT ON;	
	DECLARE @NotificationGroupId int=0
	DECLARE @NotificationTypeId int
	BEGIN TRY
	BEGIN TRANSACTION TRANS1
		IF(@ActionId=2)
		BEGIN
			UPDATE tblFeeGenerate SET GenerateStatus=2 WHERE FeeGenerateId=@FeeGenerateId 

			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblFeeGenerate'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=1
			IF (@NotificationGroupId=0)
			BEGIN
				INSERT INTO tblNotificationGroup (NotificationTypeId,NotificationCount,NotificationAction)
				VALUES (@NotificationTypeId,0,1)
				SET @NotificationGroupId=SCOPE_IDENTITY();
			END
			UPDATE tblNotificationGroup SET NotificationCount=NotificationCount+1 WHERE NotificationGroupId=@NotificationGroupId
		END
		ELSE IF(@ActionId=3)
		BEGIN
			 UPDATE tblFeeGenerate SET GenerateStatus=3 WHERE FeeGenerateId=@FeeGenerateId 
			-- Copy tblFeeGenerateDetail date to student fee table 		
			 --Synchronize the target table with refreshed data from source table
			MERGE [tblStudentFeeDetail] AS TARGET
			USING tblFeeGenerateDetail AS SOURCE 
			ON (TARGET.StudentId = SOURCE.StudentId AND TARGET.AcademicYearId = SOURCE.SchoolAcademicId 
			AND TARGET.GradeId = SOURCE.GradeId
			AND TARGET.FeeTypeId = SOURCE.FeeTypeId) 
			--When records are matched, update the records if there is any change
			WHEN MATCHED 
			THEN UPDATE SET 
				TARGET.FeeAmount = SOURCE.FeeAmount,
				TARGET.IsActive =1,
				TARGET.IsDeleted =0,
				TARGET.UpdateDate =GETDATE(),
				TARGET.UpdateBy =@LoginUserId
			--When no records are matched, insert the incoming records from source table to target table
			WHEN NOT MATCHED BY TARGET 
			THEN INSERT (	StudentId,AcademicYearId,GradeId,FeeTypeId,FeeAmount,
			IsActive,IsDeleted,UpdateDate,UpdateBy) 
			VALUES (SOURCE.StudentId,SOURCE.SchoolAcademicId,SOURCE.GradeId,SOURCE.FeeTypeId,SOURCE.FeeAmount,
			1,0,GETDATE(),@LoginUserId)
			--When there is a row that exists in target and same record does not exist in source then delete this record target
			WHEN NOT MATCHED BY SOURCE 
			THEN DELETE;
			
			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblFeeGenerate'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=1
			UPDATE tblNotificationGroup SET NotificationCount = NotificationCount-1
			WHERE NotificationGroupId=@NotificationGroupId

		END
		ELSE IF(@ActionId=4)
		BEGIN
			UPDATE tblFeeGenerate SET GenerateStatus=4 WHERE FeeGenerateId=@FeeGenerateId 
			SELECT @NotificationTypeId=NotificationTypeId  FROM tblNotificationTypeMaster WHERE ActionTable='tblFeeGenerate'
			SELECT @NotificationGroupId=NotificationGroupId FROM tblNotificationGroup WHERE NotificationTypeId =@NotificationTypeId AND NotificationAction=1
			UPDATE tblNotificationGroup SET NotificationCount = NotificationCount-1
			WHERE NotificationGroupId=@NotificationGroupId
		END
		ELSE IF(@ActionId=6)
		BEGIN
			DELETE FROM tblFeeGenerate WHERE FeeGenerateId=@FeeGenerateId
			DELETE FROM tblFeeGenerateDetail WHERE FeeGenerateId=@FeeGenerateId
		END
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
/****** Object:  StoredProcedure [dbo].[sp_UpdateParentImage]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_UpdateParentImage]
	@LoginUserId int
	,@ParentId bigint
	,@ImageUrl nvarchar(500)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		
			BEGIN
				UPDATE tblParent
						SET ParentImage= @ImageUrl		
						,UpdateDate = GETDATE()
						,UpdateBy = @LoginUserId
				WHERE ParentId = @ParentId
			END				
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
/****** Object:  StoredProcedure [dbo].[sp_UpdateSchoolLogoImage]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateSchoolLogoImage]  
 @LoginUserId int  
 ,@SchoolId bigint  
 ,@ImageUrl nvarchar(500)  
 ,@LogoName nvarchar(200)
AS  
BEGIN  
 SET NOCOUNT ON;  
   
 BEGIN TRY  
  BEGIN TRANSACTION TRANS1      
  BEGIN 
   --DECLARE @LogoName NVARCHAR(50)='logo_'
   SELECT @LogoName=@LogoName+CAST((COUNT(SchoolId)+1) AS nvarchar) FROM tblSchoolLogo WHERE SchoolId=@SchoolId AND IsActive=1 AND IsDeleted=0
   INSERT INTO [dbo].[tblSchoolLogo]
           ([SchoolId]
           ,[LogoName]
           ,[LogoPath]
           ,[IsActive]
           ,[IsDeleted]
           ,[UpdateDate]
           ,[UpdateBy])
     VALUES
           (@SchoolId
           ,@LogoName
           ,@ImageUrl  
           ,1
           ,0
           ,GETDATE() 
           ,@LoginUserId)   
   END      
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
/****** Object:  StoredProcedure [dbo].[sp_UpdateStudentImage]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateStudentImage]
	@LoginUserId int
	,@StudentId bigint
	,@ImageUrl nvarchar(500)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
		
			BEGIN
				UPDATE tblStudent
						SET StudentImage= @ImageUrl		
						,UpdateDate = GETDATE()
						,UpdateBy = @LoginUserId
				WHERE StudentId = @StudentId
			END				
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
/****** Object:  StoredProcedure [dbo].[sp_VatExemptedNationMapping]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_VatExemptedNationMapping] 
	@LoginUserId int
	,@VatId bigint
	,@MultiSelectLeft nvarchar(1000) = NULL
	,@MultiSelectRight nvarchar(1000) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			DECLARE @FilterDataTable TABLE(CountryId INT)

			INSERT INTO @FilterDataTable
			SELECT CountryId				
			FROM tblCountryMaster tcm
			WHERE tcm.CountryId IN(SELECT * FROM SplitString(@MultiSelectRight,','))

			UPDATE tblVatCountryExclusionMap
				SET IsActive = 0, IsDeleted = 1, UpdateBy = @LoginUserId, UpdateDate = GETDATE()
			WHERE VatId = @VatId AND CountryId NOT IN (SELECT CountryId FROM @FilterDataTable)

			DELETE FROM @FilterDataTable
			WHERE CountryId 
					IN (SELECT CountryId FROM tblVatCountryExclusionMap 
						WHERE VatId = @VatId AND IsDeleted = 0)

			INSERT INTO tblVatCountryExclusionMap 
					(VatId
					,CountryId
					,[IsActive]
					,[IsDeleted]
					,[UpdateDate]
					,[UpdateBy])
			SELECT @VatId,CountryId,1,0,GETDATE(),@LoginUserId
			FROM @FilterDataTable
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
/****** Object:  StoredProcedure [dbo].[usp_SaveErrorDetail]    Script Date: 6/22/2024 4:22:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_SaveErrorDetail]
AS
BEGIN
	SET NOCOUNT ON;	
	INSERT INTO tblErrors
	(	
	[ERROR_NUMBER]
	,[ERROR_SEVERITY]
	,[ERROR_STATE]
	,[ERROR_PROCEDURE]
	,[ERROR_LINE]
	,[ERROR_MESSAGE]
	)
	SELECT	ERROR_NUMBER()
	,ERROR_SEVERITY()
	,ERROR_STATE()
	,ERROR_PROCEDURE()
	,ERROR_LINE()
	,ERROR_MESSAGE()
END
GO
