create proc sp_ProcessOpenApplyRecord
as
begin
	--1- added
	--2- updated	

	insert into [tblNotification]
	(RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy])
	select 
		[student_id] as RecordId,
		case when [StudentCode] is null then 1 else 2 end RecordStatus,		
		0 as IsApproved,
		'Student' as RecordType,
		Getdate(),0
	from 
	(
		select * from [dbo].[OpenApplyStudents] os
		left join [dbo].[tblStudent] stu
		on os.[student_id]=stu.[StudentCode]

		AND	
		(
			(
				os.[name]	<>stu.[StudentName] 
				OR	os.[other_name]	<>stu.[StudentArabicName]
				OR	os.[email]	<>stu.[StudentEmail]
				--OR	os.[status]	<>stu.[StudentStatusId]
				--enrolled
			)
			OR
			1=1
		)
	)t

	insert into [tblNotification]
	(RecordId,RecordStatus,IsApproved,RecordType,[UpdateDate],[UpdateBy])
	select 
		[parent_id],
		case when [ParentCode] is null then 1 else 2 end RecordStatus,
		--cast(0 as bit) as
		0 as IsApproved,
		'Parent' as RecordType,
		Getdate(),0
	from 
	(
		select * from [dbo].[OpenApplyParents] os
		left join [dbo].[tblParent] stu
		on os.[parent_id]=stu.[ParentCode] --need to check with record

		AND	
		(
			(
				os.[name]	<>stu.[FatherName]
				OR	os.[email]	<>stu.[FatherEmail]
			)
			OR
			1=1
		)
	)t
end