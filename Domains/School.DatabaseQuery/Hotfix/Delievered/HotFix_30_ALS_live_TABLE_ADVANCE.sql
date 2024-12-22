
declare @FeeStatementType nvarchar(50)='Fee Paid'
declare @FeeType nvarchar(50)='TUITION FEE'

--delete wrong data processed
delete from tblFeeStatement where FeeType=@FeeType and FeeStatementType=@FeeStatementType and UpdateBy=-2
delete from INV_InvoiceSummary where UpdateBy=-2
delete from INV_InvoicePayment where  UpdateBy=-2
delete from tblFeeStatement where  UpdateBy=-2

select
FeeStatementType=@FeeStatementType
,InvoiceNo=ad.[Invoice No]
,InvoiceDate=ad.[TRX Date]
,PaymentMethod=case when PAYMENT='NBD' then 'BANK TRANSFER' end
,PaymentMethodRef=PAYMENT
,FeeType=@FeeType
,FeeAmount=0
,PaidAmount=ad.Amount
,StudentId=0--ad.SID--stu.StudentId
,ParentId=0--ad.PID--stu.ParentId
,StudentName=cast('' as nvarchar(500))--stu.StudentName
,ParentName=cast('' as nvarchar(500))--par.FatherName
,AcademicYearId=0--sc.SchoolAcademicId
,AcademicYear=ad.[YEAR]--sc.SchoolAcademicId
,GradeId=0--stu.GradeId
,IsActive=1
,IsDeleted=0	
,UpdateDate=GETDATE()
,UpdateBy=-2
,NationalityId=0--par.FatherNationalityId
,IqamaNumber=cast('' as nvarchar(500))--par.FatherIqamaNo
,IsStaff=0--case when par.IsFatherStaff=1 OR par.IsMotherStaff=1 then 1 else 0 end
,FatherMobile=cast('' as nvarchar(500))--par.FatherMobile
,StudentCode=cast(ad.SID as nvarchar(500))--stu.StudentCode
,ParentCode=cast(ad.PID as nvarchar(500))--par.ParentCode
,IsAdvance=1
,Reference
,Description
into #temp
from [AdvancePayment] ad
--join tblStudent stu on ad.SID=stu.StudentCode
--join tblParent par on stu.ParentId=par.ParentId and par.ParentCode=cast(ad.pid as nvarchar(50))
--join tblSchoolAcademic sc on ad.[YEAR]=sc.AcademicYear and sc.IsActive=1 and sc.IsDeleted=0
where ad.[Invoice No] is not null
--and stu.StudentId >0
--and par.ParentId>0

update t
set 
	t.GradeId=stu.GradeId
	,t.StudentCode=stu.StudentCode
	,t.StudentName=stu.StudentName
	,t.StudentId=stu.StudentId
from #temp t join tblStudent stu
on t.StudentCode=stu.StudentCode

update t
set 
	t.ParentCode=stu.ParentCode	
	,t.FatherMobile=stu.FatherMobile
	,t.IqamaNumber=stu.FatherIqamaNo
	,t.NationalityId=stu.FatherNationalityId
	,t.ParentName=stu.FatherName
	,t.ParentId=stu.ParentId
from #temp t join tblParent stu
on t.ParentCode=stu.ParentCode

update t
set 
	t.AcademicYearId=stu.SchoolAcademicId	
from #temp t join tblSchoolAcademic stu
on t.AcademicYear=stu.AcademicYear and stu.IsActive=1 and stu.IsDeleted=0

delete from #temp
where InvoiceNo not in 
(
	select  t.InvoiceNo from #temp t
	join tblStudent s on t.StudentId=s.StudentId
	join tblParent sp on t.ParentId=sp.ParentId and s.ParentId=sp.ParentId
)

select top 0 * into #INV_InvoiceSummary from INV_InvoiceSummary
select top 0 * into #INV_InvoiceDetail from INV_InvoiceDetail
select top 0 * into #INV_InvoicePayment from INV_InvoicePayment
select top 0 * into #tblFeeStatement from tblFeeStatement

insert into #INV_InvoiceDetail
(
	InvoiceNo	,AcademicYear	,InvoiceType	,Description	,ItemCode	,StudentId	,Discount	,Quantity	
	,UnitPrice	,TaxableAmount	,	TaxRate	,TaxAmount	,ItemSubtotal	
	,IsDeleted	,UpdateDate	,UpdateBy	
	,ParentId	,StudentName	,ParentName	,GradeId	,NationalityId	,
	IqamaNumber	,InvoiceDetailRefId	,InvoiceRefNo	,IsStaff	,FatherMobile	,StudentCode	,ParentCode	,IsAdvance
)
select 
	InvoiceNo, AcademicYearId,FeeType as InvoiceType,Description=Reference,ItemCode=null,StudentId,0 as Discount,1 as Quantity
	,PaidAmount as UnitPrice,PaidAmount as TaxableAmount,0 as TaxRate,0 as TaxAmount,PaidAmount as ItemSubtotal
	,IsDeleted,UpdateDate,UpdateBy
	,ParentId, StudentName, ParentName, GradeId, NationalityId
	,IqamaNumber,0 as InvoiceDetailRefId,'' as InvoiceRefNo,cast(IsStaff as bit), FatherMobile,StudentCode,ParentCode,IsAdvance
from #temp

insert into #INV_InvoiceSummary
(
InvoiceNo	,InvoiceDate	,Status	,PublishedBy	,CreditNo	,CreditReason	,CustomerName	,ParentId	,IqamaNumber	,TaxableAmount	,
TaxAmount	,ItemSubtotal	,IsDeleted	,UpdateDate	,UpdateBy	,InvoiceType	,InvoiceRefNo
)
select 
	InvoiceNo	,InvoiceDate	,Status	,PublishedBy	,CreditNo	,CreditReason	,CustomerName	,ParentId	,IqamaNumber	,
	sum(TaxableAmount	) as TaxableAmount,sum(TaxAmount	) as TaxAmount,sum(ItemSubtotal	) as ItemSubtotal,
	IsDeleted	,UpdateDate	,UpdateBy	,InvoiceType	,InvoiceRefNo
from
(
select 
	InvoiceNo,InvoiceDate,Status='Posted',PublishedBy=12, NULL as CreditNo,NULL as CreditReason,NULL as CustomerName
	,ParentId=isnull(ParentId,0), IqamaNumber=isnull(IqamaNumber,''),
	PaidAmount as TaxableAmount,0 as TaxAmount,PaidAmount as ItemSubtotal,IsDeleted	,UpdateDate	,UpdateBy	,InvoiceType='Invoice'	,0 as InvoiceRefNo
from 
#temp
where InvoiceNo is not null
)t
group by 
InvoiceNo	,InvoiceDate	,Status	,PublishedBy	,CreditNo	,CreditReason	,CustomerName	,ParentId	,IqamaNumber	,
IsDeleted	,UpdateDate	,UpdateBy	,InvoiceType	,InvoiceRefNo

insert into #INV_InvoicePayment
(
	InvoiceNo,PaymentMethod,PaymentReferenceNumber,PaymentAmount,IsDeleted,UpdateDate,UpdateBy,InvoiceRefNo,InvoicePaymentRefId,PaymentMethodId
)
select 
	InvoiceNo,PaymentMethod,PaymentMethodRef as PaymentReferenceNumber,PaidAmount as PaymentAmount
	,t.IsDeleted	,t.UpdateDate	,t.UpdateBy	,0 as InvoiceRefNo,0 as InvoicePaymentRefId,p.PaymentMethodId as PaymentMethodId
from 
#temp t
join tblPaymentMethod p on t.PaymentMethod=p.PaymentMethodName
where InvoiceNo is not null

insert into #tblFeeStatement
(
	FeeStatementType	,InvoiceNo	,InvoiceDate	,PaymentMethod	,FeeType	,FeeAmount	,PaidAmount	,StudentId	,ParentId	,StudentName	
	,ParentName	,AcademicYearId	,GradeId	,IsActive	,IsDeleted	,UpdateDate	,UpdateBy
)
select
	FeeStatementType=@FeeStatementType,InvoiceNo,InvoiceDate,PaymentMethod,FeeType=@FeeType,FeeAmount=0,PaidAmount,StudentId,ParentId,StudentName
	,ParentName,AcademicYearId,GradeId,IsActive=1,IsDeleted=0	,UpdateDate=GETDATE(),UpdateBy=-2
from #temp

----------Final insert into table
insert into INV_InvoiceSummary
(
	InvoiceNo,InvoiceDate,Status,PublishedBy,CreditNo,CreditReason,CustomerName,ParentId,IqamaNumber
	,TaxableAmount,TaxAmount,ItemSubtotal,IsDeleted,UpdateDate,UpdateBy,InvoiceType,InvoiceRefNo
)
select 
	InvoiceNo,InvoiceDate,Status,PublishedBy,CreditNo,CreditReason,CustomerName,ParentId,IqamaNumber
	,TaxableAmount,TaxAmount,ItemSubtotal,IsDeleted,UpdateDate,UpdateBy,InvoiceType,InvoiceRefNo
from #INV_InvoiceSummary

insert into INV_InvoiceDetail
(
	InvoiceNo,AcademicYear,InvoiceType,Description,ItemCode,StudentId,Discount,Quantity,UnitPrice,TaxableAmount,TaxRate
	,TaxAmount,ItemSubtotal,IsDeleted,UpdateDate,UpdateBy,ParentId,StudentName,ParentName,GradeId,NationalityId
	,IqamaNumber,InvoiceDetailRefId,InvoiceRefNo,IsStaff,FatherMobile,StudentCode,ParentCode,IsAdvance
)
select 
	InvoiceNo,AcademicYear,InvoiceType,Description,ItemCode,StudentId,Discount,Quantity,UnitPrice,TaxableAmount,TaxRate
	,TaxAmount,ItemSubtotal,IsDeleted,UpdateDate,UpdateBy,ParentId,StudentName,ParentName,GradeId,NationalityId
	,IqamaNumber,InvoiceDetailRefId,InvoiceRefNo,IsStaff,FatherMobile,StudentCode,ParentCode,IsAdvance
from #INV_InvoiceDetail

insert into INV_InvoicePayment
(
	InvoiceNo,PaymentMethod,PaymentReferenceNumber,PaymentAmount,IsDeleted,UpdateDate,UpdateBy,InvoiceRefNo,InvoicePaymentRefId,PaymentMethodId
)
select 
	InvoiceNo,PaymentMethod,PaymentReferenceNumber,PaymentAmount,IsDeleted,UpdateDate,UpdateBy,InvoiceRefNo,InvoicePaymentRefId,PaymentMethodId
from #INV_InvoicePayment

insert into tblFeeStatement
(
	FeeStatementType,InvoiceNo,InvoiceDate,PaymentMethod,FeeType,FeeAmount,PaidAmount,StudentId,ParentId
	,StudentName,ParentName,AcademicYearId,GradeId,IsActive,IsDeleted,UpdateDate,UpdateBy
)
select 
	FeeStatementType,InvoiceNo,InvoiceDate,PaymentMethod,FeeType,FeeAmount,PaidAmount,StudentId,ParentId
	,StudentName,ParentName,AcademicYearId,GradeId,IsActive,IsDeleted,UpdateDate,UpdateBy
from #tblFeeStatement


drop table #temp
drop table #INV_InvoiceSummary
drop table #INV_InvoiceDetail
drop table #INV_InvoicePayment
drop table #tblFeeStatement
