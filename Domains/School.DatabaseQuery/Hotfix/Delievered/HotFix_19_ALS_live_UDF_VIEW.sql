----VIews
IF EXISTS(select * FROM sys.views where name = 'vw_GetStudentOpenApplyParentInfo')
    drop view vw_GetStudentOpenApplyParentInfo
GO

CREATE view [dbo].[vw_GetStudentOpenApplyParentInfo]
as
	select 
	distinct
		OpenApplyStudentId=student.id,
		StudentCode=student.student_id	,ParentCode=student.p_id_school_parent_id,
		ParentImage=isnull(father.ParentImage,'')	,
		FatherName=isnull(FatherName,'')	,
		FatherArabicName=isnull(FatherArabicName,'')	,
		FatherNationalityId=isnull(FatherNationalityId,99999)	,
		FatherMobile=isnull(FatherMobile,'')	,
		FatherEmail=isnull(FatherEmail,'')	,
		IsFatherStaff=isnull(IsFatherStaff,0)	,
		FatherIqamaNo=isnull(FatherIqamaNo,'')	,
		OpenApplyFatherId=isnull(OpenApplyFatherId,0)	,
		MotherName=isnull(MotherName,'')	,
		MotherArabicName=isnull(MotherArabicName,'')	,
		MotherNationalityId=isnull(MotherNationalityId,99999)	,
		MotherMobile=isnull(MotherMobile,'')	,
		MotherEmail=isnull(MotherEmail,'')	,
		IsMotherStaff=isnull(IsMotherStaff,0)	,
		MotherIqamaNo=isnull(MotherIqamaNo,'')	,
		OpenApplyMotherId=isnull(OpenApplyMotherId,0)

from OpenApplyStudents student
left join
(
  select     
	FatherRowNo
	,OpenApplyStudentId=OpenApplyStudentId
	,ParentCode=parent_id
	,ParentImage =''      
	,FatherName =(ltrim(rtrim(isnull([first_name],'')))+' '+ltrim(rtrim(isnull([last_name],''))))      
	,FatherArabicName =isnull([other_name],'')      
	,FatherNationalityId =isnull(CountryId, 0)        
	,FatherMobile =isnull(mobile_phone,'')      
	,FatherEmail =ltrim(rtrim(isnull([email],'')))      
	,IsFatherStaff =0      
	,FatherIqamaNo=IqamaNo      
	,OpenApplyFatherId =id
  from      
  (      
   select       
		ROW_NUMBER() over(partition by stuMap.OpenApplyStudentId order by stuParent.id asc) as FatherRowNo      
		,stuParent.Newid	,stuParent.id	,stuParent.first_name	,stuParent.last_name	,stuParent.other_name	,stuParent.preferred_name	
		,stuParent.parent_id	,stuParent.gender	,stuParent.prefix	,stuParent.phone	,stuParent.mobile_phone	,stuParent.address	
		,stuParent.address_ii	,stuParent.city	,stuParent.state	,stuParent.postal_code	,stuParent.country	,stuParent.email	,stuParent.employer	
		,stuParent.birth_date	,stuParent.work_phone	,stuParent.nationality	,stuParent.arabic_title	,stuParent.home_telephone	,stuParent.IqamaNo	
		,stuParent.student_id	,stuParent.Passport_id	
		,CountryId=isnull(tc.CountryId ,0)  
		,stuMap.OpenApplyStudentId
		--,student.p_id_school_parent_id
    from      
	--OpenApplyStudents stu 
 --   inner join 
	[OpenApplyStudentParentMap] stuMap --on stuMap.OpenApplyStudentId=stu.id
    inner join OpenApplyparents stuParent on stumap.OpenApplyParentId=stuParent.id      
    left join tblCountryMaster tc on stuParent.nationality COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName        
   where stuParent.gender='Male'
   and stuParent.first_name is not null
  )tFather
  where FatherRowNo=1
  )father
  on student.id=father.OpenApplyStudentId

  left join
  (
   select 
	MotherRowNo
    ,OpenApplyStudentId=OpenApplyStudentId   
	,ParentCode=parent_id
	,ParentImage =''      
    ,MotherName =(ltrim(rtrim([first_name]))+' '+ltrim(rtrim([last_name])))      
    ,MotherArabicName =isnull([other_name],'')      
    ,MotherNationalityId =isnull(CountryId, 0)        
    ,MotherMobile =mobile_phone      
    ,MotherEmail =ltrim(rtrim([email]))      
    ,IsMotherStaff =0      
    ,MotherIqamaNo=IqamaNo      
    ,OpenApplyMotherId =id
   from      
   (      
    select 
		ROW_NUMBER() over(partition by stuMap.OpenApplyStudentId order by stuParent.id asc)  as MotherRowNo      
		,stuParent.Newid	,stuParent.id	,stuParent.first_name	,stuParent.last_name	,stuParent.other_name	,stuParent.preferred_name	
		,stuParent.parent_id	,stuParent.gender	,stuParent.prefix	,stuParent.phone	,stuParent.mobile_phone	,stuParent.address	
		,stuParent.address_ii	,stuParent.city	,stuParent.state	,stuParent.postal_code	,stuParent.country	,stuParent.email	,stuParent.employer	
		,stuParent.birth_date	,stuParent.work_phone	,stuParent.nationality	,stuParent.arabic_title	,stuParent.home_telephone	,stuParent.IqamaNo	
		,stuParent.student_id	,stuParent.Passport_id	
		,CountryId=isnull(tc.CountryId ,0)  
		,stuMap.OpenApplyStudentId
		--,stu.p_id_school_parent_id
     from       
    -- OpenApplyStudents stu 
    --inner join 
	[OpenApplyStudentParentMap] stuMap --on stuMap.OpenApplyStudentId=stu.id
    inner join OpenApplyparents stuParent on stumap.OpenApplyParentId=stuParent.id      
    left join tblCountryMaster tc on stuParent.nationality COLLATE SQL_Latin1_General_CP1_CI_AS=tc.CountryName        
	where stuParent.gender='Female'
	and stuParent.first_name is not null
   )tMother 
   where MotherRowNo=1
   )mother
   on student.id=mother.OpenApplyStudentId
GO

IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'[uf_ReportStudentStatement]')
                  AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  DROP FUNCTION uf_ReportStudentStatement
GO 

CREATE FUNCTION [dbo].[uf_ReportStudentStatement](
    @AcademicYearId INT = 0,
    @ParentId INT,
    @StudentId INT
)
RETURNS TABLE
AS
RETURN
(
    WITH AcademicYearCTE AS (
        SELECT TOP 1 PeriodFrom, AcademicYear
        FROM tblSchoolAcademic
        WHERE @AcademicYearId = 0 OR SchoolAcademicId = @AcademicYearId
        ORDER BY PeriodFrom ASC
    ),
    PreviousAcademicYearCTE AS (
        SELECT AcademicYear
        FROM tblSchoolAcademic
        WHERE CAST(PeriodTo AS DATE) < 
              (SELECT ISNULL(PeriodFrom, CAST('1990-01-01' AS DATE))
               FROM AcademicYearCTE)
          AND IsActive = 1
          AND IsDeleted = 0
        --ORDER BY PeriodTo DESC
    ),
    StudentTableCTE AS (
        SELECT StudentId
        FROM tblStudent
        WHERE StudentId = @StudentId
           OR (@StudentId = 0 AND ParentId = @ParentId)
    ),
    StudentOpeningFeesBalanceCTE AS (
        SELECT StudentId,
               NULL AS RecordDate,
               'TUITION FEE - OPENING BALANCE' AS FeeTypeName,
               SUM(ISNULL(FeeAmount, 0)) AS FeeAmount,
               SUM(ISNULL(PaidAmount, 0)) AS PaidAmount
        FROM tblFeeStatement
        WHERE StudentId IN (SELECT StudentId FROM StudentTableCTE)
          AND AcademicYearId IN (SELECT AcademicYearId FROM PreviousAcademicYearCTE)
          AND IsActive = 1
          AND IsDeleted = 0
        GROUP BY StudentId
    ),
    OpeningBalanceCTE AS (
        SELECT st.StudentId,
               ISNULL(s.StudentName, '') AS StudentName,
               SUM(ISNULL(ofb.FeeAmount, 0)) - SUM(ISNULL(ofb.PaidAmount, 0)) AS OpeningBalance
        FROM StudentTableCTE st
        LEFT JOIN tblStudent s ON st.StudentId = s.StudentId
        LEFT JOIN StudentOpeningFeesBalanceCTE ofb ON st.StudentId = ofb.StudentId
        GROUP BY st.StudentId, s.StudentName
    )
    SELECT StudentId,
           StudentName,
           '' AS InvoiceNo,
           '' AS PaymentMethod,
           (SELECT TOP 1 AcademicYear FROM PreviousAcademicYearCTE) AS AcademicYear,
           NULL AS RecordDate,
           'TUITION FEE - OPENING BALANCE' AS FeeTypeName,
           CASE WHEN OpeningBalance > 0 THEN OpeningBalance ELSE 0 END AS FeeAmount,
           CASE WHEN OpeningBalance < 0 THEN OpeningBalance ELSE 0 END AS PaidAmount,
           0 AS BalanceAmount
    FROM OpeningBalanceCTE
    UNION ALL
    SELECT fs.StudentId,
           s.StudentName,
           fs.InvoiceNo,
           fs.PaymentMethod,
           sa.AcademicYear,
           fs.UpdateDate AS RecordDate,
           fs.FeeStatementType AS FeeTypeName,
           fs.FeeAmount,
           fs.PaidAmount,
           0 AS BalanceAmount
    FROM tblFeeStatement fs
    INNER JOIN tblSchoolAcademic sa ON sa.SchoolAcademicId = fs.AcademicYearId
    INNER JOIN tblStudent s ON fs.StudentId = s.StudentId
    WHERE fs.StudentId IN (SELECT StudentId FROM StudentTableCTE)
      AND (@AcademicYearId = 0 OR fs.AcademicYearId = @AcademicYearId)
      AND fs.IsActive = 1
      AND fs.IsDeleted = 0
);
GO
