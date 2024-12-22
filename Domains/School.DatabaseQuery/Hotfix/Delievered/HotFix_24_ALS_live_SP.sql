DROP PROCEDURE IF EXISTS  [dbo].[sp_GetSiblingDiscount]
GO

CREATE PROCEDURE [dbo].[sp_GetSiblingDiscount]
	@DiscountId int = 0
AS
BEGIN
	SET NOCOUNT ON;	
	SELECT tdr.DiscountId
		,tdr.ChildrenNo
		,tdr.DiscountPercent
		,tdr.StaffDiscountPercent
		,tdr.IsActive
		,tdr.IsDeleted
	FROM tblSiblingDiscountMaster tdr		
	WHERE tdr.DiscountId = CASE WHEN @DiscountId > 0 THEN @DiscountId ELSE tdr.DiscountId END
		AND tdr.IsDeleted =  0 AND tdr.IsActive=1
	ORDER BY tdr.ChildrenNo
END
GO

DROP PROCEDURE IF EXISTS  [dbo].[sp_SaveSiblingDiscount]
GO

CREATE PROCEDURE [dbo].[sp_SaveSiblingDiscount]
	@LoginUserId int
	,@DiscountId int
	,@ChildrenNo int
	,@DiscountPercent decimal(5,2)
	,@StaffDiscountPercent decimal(5,2)
AS
BEGIN
	--DiscountId	ChildrenNo	DiscountPercent	IsActive	IsDeleted	UpdateDate	UpdateBy
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM tblSiblingDiscountMaster WHERE ChildrenNo = @ChildrenNo AND IsActive = 1 AND IsDeleted=0 AND @DiscountId=0)
	BEGIN
		SELECT -2 AS Result, 'Discount already exists for this children!' AS Response
		RETURN;
	END	
	IF EXISTS(SELECT 1 FROM tblSiblingDiscountMaster WHERE ChildrenNo = @ChildrenNo AND DiscountPercent = @DiscountPercent AND  StaffDiscountPercent = @StaffDiscountPercent AND IsActive = 1 
	AND IsDeleted=0 AND @DiscountId>0)
	BEGIN
		SELECT -2 AS Result, 'Discount already exists for this children!' AS Response
		RETURN;
	END	
	BEGIN TRY
		BEGIN TRANSACTION TRANS1
			IF(@DiscountId = 0)
			BEGIN
				INSERT INTO tblSiblingDiscountMaster
					   (ChildrenNo
					   ,DiscountPercent
					   ,StaffDiscountPercent
						,IsActive
						,IsDeleted
						,UpdateDate
						,UpdateBy)
				VALUES
					   (@ChildrenNo	
					   ,@DiscountPercent
					   ,@StaffDiscountPercent
					   ,1	
					   ,0
					   ,GETDATE()
					   ,@LoginUserId)
			END
			ELSE
			BEGIN
				UPDATE tblSiblingDiscountMaster
						SET ChildrenNo = @ChildrenNo
							,DiscountPercent=@DiscountPercent
							,StaffDiscountPercent=@StaffDiscountPercent
							,UpdateDate = GETDATE()
							,UpdateBy = @LoginUserId
				WHERE DiscountId = @DiscountId
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
   StudentId, AcademicYearId, GradeId, FeetYpeId,
   case when IsStaff=1 then isnull(mas.StaffDiscountPercent, isnull(mas.DiscountPercent ,0)) else isnull(mas.DiscountPercent ,0) end 
   ,0 as DiscountAmount, getdate() as Updatedate, @LoginUserId as UpdateBy    
  FROM     
  (    
   SELECT     
    ROW_NUMBER() OVER( PARTITION BY tbl.ParentId ORDER BY tbl.ParentId, gm.SequenceNo,tbl.StudentId) AS StuentChildNo    
    ,tbl.StudentId    
    ,fee.AcademicYearId    
    ,fee.GradeId    
    ,FeetYpeId=@FeeTypeId
	,IsStaff= case when par.IsFatherStaff=1 OR par.IsMotherStaff=1 then 1 else 0 end
   FROM tblStudent tbl  
   join tblParent par on tbl.ParentId=par.ParentId
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