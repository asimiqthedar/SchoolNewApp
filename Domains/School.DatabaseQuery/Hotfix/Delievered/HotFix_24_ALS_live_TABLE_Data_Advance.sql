
declare @FeeStatementType nvarchar(50)='Fee Paid'
declare @FeeType nvarchar(50)='TUITION FEE'

--delete wrong data processed
delete from tblFeeStatement where FeeType=@FeeType and FeeStatementType=@FeeStatementType and UpdateBy=-2

insert into tblFeeStatement
(
FeeStatementType	,InvoiceNo	,InvoiceDate	,PaymentMethod	,FeeType	,FeeAmount	,PaidAmount	,StudentId	,ParentId	,StudentName	
,ParentName	,AcademicYearId	,GradeId	,IsActive	,IsDeleted	,UpdateDate	,UpdateBy
)
select
FeeStatementType=@FeeStatementType
,InvoiceNo=ad.[Invoice No]
,InvoiceDate=ad.[TRX Date]
,PaymentMethod=PAYMENT
,FeeType=@FeeType
,FeeAmount=0
,PaidAmount=ad.Amount
,StudentId=stu.StudentId
,ParentId=stu.ParentId
,StudentName=stu.StudentName
,ParentName=par.FatherName
,AcademicYearId=sc.SchoolAcademicId
,GradeId=stu.GradeId
,IsActive=1
,IsDeleted=0	
,UpdateDate=GETDATE()
,UpdateBy=-2
from [AdvancePayment] ad
join tblStudent stu on ad.SID=stu.StudentCode
join tblParent par on stu.ParentId=par.ParentId and par.ParentCode=cast(ad.pid as nvarchar(50))
join tblSchoolAcademic sc on ad.[YEAR]=sc.AcademicYear and sc.IsActive=1 and sc.IsDeleted=0

