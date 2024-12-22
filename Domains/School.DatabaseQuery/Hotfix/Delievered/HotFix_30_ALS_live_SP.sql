DROP PROCEDURE IF EXISTS [sp_GetAppDropdown]
GO

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
 SELECT SValue,SText FROM(    
   SELECT tp.ParentId AS SValue        
    ,tp.ParentCode+' - '+tp.FatherName  AS SText     
    ,CAST(ISNULL(tp.ParentCode,0) AS nvarchar(50)) AS ParentCode     
   FROM tblParent tp          
   WHERE tp.IsActive = 1 AND tp.IsDeleted = 0           
  )t    
  ORDER BY t.ParentCode    
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
  and tss.StatusName !='Withdraw'
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
  IF @DropdownType = 16      
 BEGIN        
  SELECT tpmc.PaymentMethodCategoryId AS SValue        
   ,tpmc.CategoryName  AS SText        
  FROM tblPaymentMethodCategory tpmc       
  WHERE  tpmc.IsDeleted = 0 and tpmc.IsActive=1        
 END     
END 
GO

DROP PROCEDURE IF EXISTS [SP_GetStudentParentWise]
GO

CREATE PROCEDURE [dbo].[SP_GetStudentParentWise]    
 @ParentId bigint=0    
 ,@ParentName NVarChar(500)=null    
 ,@FatherIqama NVarChar(100)=null    
 ,@FatherMobile NVarChar(20)=null    
AS    
BEGIN    
 SELECT ts.StudentId    
  ,ts.StudentCode    
  ,ts.StudentName    
  ,tp.ParentId    
  ,tp.FatherName    
  ,tp.FatherIqamaNo    
  ,tp.FatherMobile    
 FROM tblStudent ts    
 INNER JOIN tblParent tp    
  ON ts.ParentId=tp.ParentId    
 WHERE tp.ParentId = CASE WHEN @ParentId>0 THEN @ParentId ELSE tp.ParentId END    
 AND tp.FatherName = CASE WHEN LEN(@ParentName)>0 THEN @ParentName ELSE tp.FatherName END    
 AND tp.FatherIqamaNo = CASE WHEN LEN(@FatherIqama)>0 THEN @FatherIqama ELSE tp.FatherIqamaNo END    
 AND tp.FatherMobile = CASE WHEN LEN(@FatherMobile)>0 THEN @FatherMobile ELSE tp.FatherMobile END    
END 
GO

DROP PROCEDURE IF EXISTS [SP_GeneralReport]
GO

CREATE PROC [dbo].[SP_GeneralReport]    
(    
  @AcademicYear int=0    
 ,@CostCenter int=0    
 ,@Grade int=0    
 ,@Gender int=0    
)    
AS    
BEGIN    
 SELECT     
  AcademicYear    
  ,CostCenter    
  ,Grade    
  ,Gender    
  ,GradeId    
  ,FeeApplied    
  ,DiscountApplied    
  ,AmountPaid    
  ,VatPaid    
  ,Balance    
 INTO #GeneralTbl    
 FROM    
 (    
   SELECT    
   sa.AcademicYear    
   ,cc.CostCenterName AS 'CostCenter'    
   ,gm.GradeName AS 'Grade'    
   ,gtm.GenderTypeName AS 'Gender'    
   ,gm.GradeId    
   ,SUM(CASE WHEN fs.FeeStatementType='Fee Applied' THEN fs.FeeAmount ELSE 0 END) AS 'FeeApplied'    
   ,SUM(CASE WHEN fs.FeeStatementType LIKE '%Discount%' THEN fs.PaidAmount ELSE 0 END) AS 'DiscountApplied'    
   ,SUM(CASE WHEN fs.FeeStatementType='Fee Paid' THEN fs.PaidAmount ELSE 0 END) AS 'AmountPaid'    
   ,SUM(invd.TaxAmount) AS 'VatPaid'    
   ,SUM(CASE WHEN fs.FeeStatementType='Fee Applied' THEN fs.FeeAmount ELSE 0 END)     
   - SUM(CASE WHEN fs.FeeStatementType LIKE '%Discount%' THEN fs.PaidAmount ELSE 0 END)      
   -SUM(CASE WHEN fs.FeeStatementType='Fee Paid' THEN fs.PaidAmount ELSE 0 END)    
   AS 'Balance'    
  FROM tblFeeStatement fs    
  INNER JOIN tblGradeMaster AS gm     
   ON fs.GradeId = gm.GradeId    
  INNER JOIN tblSchoolAcademic AS sa     
   ON fs.AcademicYearId = sa.SchoolAcademicId     
  INNER JOIN tblStudent ts    
   ON ts.StudentId = fs.StudentId    
  INNER JOIN tblCostCenterMaster cc     
   ON ts.CostCenterId=cc.CostCenterId    
  INNER JOIN tblGenderTypeMaster gtm     
   ON gtm.GenderTypeId=ts.GenderId    
  LEFT JOIN INV_InvoiceDetail invd    
   ON invd.StudentId=ts.StudentId AND InvoiceType LIKE '%Tuition%'      
  WHERE fs.AcademicYearId = CASE WHEN @AcademicYear > 0 THEN @AcademicYear ELSE fs.AcademicYearId END      
   AND ts.CostCenterId = CASE WHEN @CostCenter > 0 THEN @CostCenter ELSE ts.CostCenterId END       
   AND fs.GradeId = CASE WHEN @Grade > 0 THEN @Grade ELSE fs.GradeId END       
   AND ts.GenderId = CASE WHEN @Gender > 0 THEN @Gender ELSE ts.GenderId END      
  GROUP BY sa.AcademicYear,cc.CostCenterName,gm.GradeName,gm.GradeId,gtm.GenderTypeName      
      
 )t    
 ORDER BY t.GradeId   
 
 SELECT  AcademicYear    
  ,CostCenter    
  ,Grade    
  ,Gender     
  ,FORMAT(ISNULL(FeeApplied,0),'#,0.00') AS FeeApplied    
  ,FORMAT(ISNULL(DiscountApplied,0),'#,0.00') AS DiscountApplied    
  ,FORMAT(ISNULL(AmountPaid,0),'#,0.00') AS AmountPaid    
  ,FORMAT(ISNULL(VatPaid,0),'#,0.00') AS VatPaid    
  ,FORMAT(ISNULL(Balance,0),'#,0.00') AS Balance    
 FROM  #GeneralTbl    
 UNION ALL    
 SELECT AcademicYear = ' '    
  ,CostCenter = ' '    
  ,Grade = ' '    
  ,Gender ='Total'     
  ,FeeApplied=FORMAT(SUM(ISNULL(FeeApplied,0)),'#,0.00')    
  ,DiscountApplied=FORMAT(SUM(ISNULL(DiscountApplied,0)),'#,0.00')    
  ,AmountPaid=FORMAT(SUM(ISNULL(AmountPaid,0)),'#,0.00')    
  ,VatPaid=FORMAT(SUM(ISNULL(VatPaid,0)),'#,0.00')    
  ,Balance=FORMAT(SUM(ISNULL(Balance,0)),'#,0.00')     
  FROM  #GeneralTbl    
 DROP TABLE IF EXISTS #GeneralTbl;     
END
GO

DROP PROCEDURE IF EXISTS [sp_CSVgeneralreportexport]
GO

CREATE PROCEDURE [dbo].[sp_CSVgeneralreportexport]        
  @AcademicYear int=0    
 ,@CostCenter int=0    
 ,@Grade int=0    
 ,@Gender int=0 AS                                
BEGIN          
EXEC SP_GeneralReport    
  @AcademicYear    
  ,@CostCenter    
  ,@Grade    
  ,@Gender    
END 
GO

DROP PROCEDURE IF EXISTS sp_finalStudentWithdraw
GO

CREATE PROCEDURE sp_finalStudentWithdraw  
 @LoginUserId int  
 ,@StudentId bigint        
 AS  
 BEGIN  
  BEGIN TRY            
 BEGIN TRANSACTION TRANS1     
  declare @TotalAmountPending decimal(18,0)=0        
  select         
   @TotalAmountPending= isnull(sum(isnull(FeeAmount,0)),0)-isnull(sum(isnull(PaidAmount,0)),0)         
  from tblFeeStatement where StudentId=@StudentId        
    
  declare @StudentStatusId int=2  
  select top 1 @StudentStatusId =StudentStatusId  from tblStudentStatus where StatusName='Withdraw'  
  
  if(@TotalAmountPending>0)        
  begin        
   SELECT -2 AS Result, 'Unable to withdraw student as balance pending' AS Response         
  end   
  else if exists(select 1 from tblStudent where StudentId=@StudentId and StudentStatusId=@StudentStatusId )        
  begin        
   SELECT -1 AS Result, 'Student is already marked as withdrawal' AS Response         
  end   
  else  
  begin  
   select top 1 * into #tblStudent from tblStudent where StudentId=@StudentId  
  
   update tblStudent  
   set StudentStatusId=@StudentStatusId   
  
   declare @NotificationTypeId int=0;  
   declare @NotificationGroupId int=0;  
  
   --add record in notification approval  
   if exists(select * from tblNotificationTypeMaster where NotificationType='Student Withdraw' and ActionTable='tblStudent')  
   begin  
    select top 1   
     @NotificationTypeId=NotificationTypeId   
    from tblNotificationTypeMaster where NotificationType='Student Withdraw' and ActionTable='tblStudent'  
  
    select top 1 @NotificationGroupId=NotificationGroupId  
    from tblNotificationGroup  
    where NotificationTypeId=@NotificationTypeId and NotificationAction=3  
  
   end  
   else begin  
    insert into tblNotificationTypeMaster(NotificationType ,ActionTable ,NotificationMsg ,IsActive ,NotificationActionTable)  
    select NotificationType='Student Withdraw' ,ActionTable='tblStudent', NotificationMsg='Student withdraw #N record #Action',  
    IsActive=1, NotificationActionTable='NotificationWithdrawStudent'  
  
    --Get recent NotificationTypeId  
    set @NotificationTypeId=SCOPE_IDENTITY();  
  
    insert into tblNotificationGroup(NotificationTypeId ,NotificationCount ,NotificationAction)  
    select NotificationTypeId=@NotificationTypeId ,NotificationCount=0 ,NotificationAction=3  
     
    set @NotificationGroupId =SCOPE_IDENTITY();  
   end  
  
   insert into tblNotificationGroupDetail  
   (  
    NotificationGroupId ,NotificationTypeId ,NotificationAction ,TableRecordId ,TableRecordColumnName   
    ,OldValueJson ,NewValueJson ,CreatedBy  
   )  
   select  
    NotificationGroupId=@NotificationGroupId   
    ,NotificationTypeId =@NotificationTypeId   
    ,NotificationAction=3   
    ,TableRecordId=os.StudentId   
    ,TableRecordColumnName =null  
    ,NewValueJson= (SELECT * FROM #tblStudent jc where jc.StudentId = os.StudentId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )        
    ,OldValueJson= (SELECT * FROM [tblStudent] jc where jc.StudentId = os.StudentId FOR JSON PATH,WITHOUT_ARRAY_WRAPPER )        
    ,CreatedBy=@LoginUserId  
   from tblStudent os  
   where os.StudentId=@StudentId  
  
  end  
  
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