DROP PROCEDURE IF EXISTS sp_ApproveWithdrawStudent
GO

CREATE proc sp_ApproveWithdrawStudent    
@LoginUserId int=0    
,@NotificationGroupDetailId int    
as    
begin    
  BEGIN TRY    
  BEGIN TRANSACTION TRANS1     
    
   declare @NotificationGroupId  int=0;    
   declare @NotificationTypeId int=0;    
   declare @NotificationAction int=0;    
   declare @TableRecordId int=0;      
    
   select top 1       
    @NotificationGroupId=NotificationGroupId     
    ,@NotificationTypeId=NotificationTypeId     
    ,@NotificationAction=NotificationAction     
    ,@TableRecordId=TableRecordId    
   from tblNotificationGroupDetail    
   where NotificationGroupDetailId=@NotificationGroupDetailId    
  
   --update student status  
   declare @StudentStatusId int=2;  
   select top 1 @StudentStatusId =StudentStatusId  from tblStudentStatus where StatusName='Withdraw'  
  
   update tblStudent  
   set  
 StudentStatusId=@StudentStatusId  
   where StudentId=@TableRecordId  
          
   delete from tblNotification where NotificationId=@TableRecordId    
   delete from tblNotificationGroupDetail where NotificationGroupDetailId=@NotificationGroupDetailId    
    
   update tblNotificationGroup    
   set NotificationCount=NotificationCount-1    
   where NotificationGroupId=@NotificationGroupId    
       
   COMMIT TRAN TRANS1                          
   SELECT 0 AS Result, 'Saved' AS Response     
    
  END TRY                       
  BEGIN CATCH        
      
   ROLLBACK TRAN TRANS1                             
   SELECT -1 AS Result, 'Error!' AS Response                          
   EXEC usp_SaveErrorDetail                          
   RETURN       
       
  END CATCH            
    
end 
GO

DROP PROCEDURE IF EXISTS sp_RejectWithdrawStudent
GO

CREATE proc sp_RejectWithdrawStudent    
@LoginUserId int=0    
,@NotificationGroupDetailId int    
as    
begin    
  BEGIN TRY    
  BEGIN TRANSACTION TRANS1     
    
   declare @NotificationGroupId  int=0;    
   declare @NotificationTypeId int=0;    
   declare @NotificationAction int=0;    
   declare @TableRecordId int=0;      
    
   select top 1       
    @NotificationGroupId=NotificationGroupId     
    ,@NotificationTypeId=NotificationTypeId     
    ,@NotificationAction=NotificationAction     
    ,@TableRecordId=TableRecordId    
   from tblNotificationGroupDetail    
   where NotificationGroupDetailId=@NotificationGroupDetailId    
          
   delete from tblNotification where NotificationId=@TableRecordId    
   delete from tblNotificationGroupDetail where NotificationGroupDetailId=@NotificationGroupDetailId    
    
   update tblNotificationGroup    
   set NotificationCount=NotificationCount-1    
   where NotificationGroupId=@NotificationGroupId    
       
   COMMIT TRAN TRANS1                          
   SELECT 0 AS Result, 'Saved' AS Response     
    
  END TRY                       
  BEGIN CATCH        
      
   ROLLBACK TRAN TRANS1                             
   SELECT -1 AS Result, 'Error!' AS Response                          
   EXEC usp_SaveErrorDetail                          
   RETURN       
       
  END CATCH            
    
end 
GO

DROP PROCEDURE IF EXISTS sp_GetNotificationWithdrawStudent
GO

CREATE procedure sp_GetNotificationWithdrawStudent  
 @NotificationTypeId int=0        
,@NotificationGroupId int=0        
,@NotificationGroupDetailId int=0        
AS        
BEGIN        
 SET NOCOUNT ON;       
 select       
  tgd.OldValueJson, tgd.NewValueJson,tgd.NotificationAction,      
  tgd.NotificationTypeId,tgd.NotificationGroupId,tgd.NotificationGroupDetailId,      
  stu.*       
 from tblNotificationGroupDetail tgd      
 join tblNotificationGroup tg on tgd.NotificationGroupId=tg.NotificationGroupId      
 join tblNotificationTypeMaster tgm on tg.NotificationTypeId=tgm.NotificationTypeId      
 join tblStudent stu on tgd.TableRecordId=stu.StudentId  
 where   
 --NotificationType='Student'      
 --and   
 tgd.NotificationTypeId=@NotificationTypeId      
 and tgd.NotificationGroupId=@NotificationGroupId      
 and (@NotificationGroupDetailId=0 OR tgd.NotificationGroupDetailId=@NotificationGroupDetailId)      
      
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
   SELECT -3 AS Result, 'Student is already marked as withdrawal' AS Response           
  end     
  else    
  begin    
   select top 1 * into #tblStudent from tblStudent where StudentId=@StudentId    
      
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
  
   update tblNotificationGroup  
   set NotificationCount=NotificationCount+1  
   where NotificationTypeId=@NotificationTypeId and NotificationTypeId =@NotificationTypeId and   
   NotificationAction=3  
    
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

DROP PROCEDURE IF EXISTS [sp_GetInvoice]
GO

CREATE PROCEDURE [dbo].[sp_GetInvoice]      
	@InvoiceId bigint = 0,                    
	@Status nvarchar(50) = NULL,                    
	@InvoiceDateStart date = NULL,                    
	@InvoiceDateEnd date = NULL,                    
	@InvoiceType nvarchar(50) = NULL,                    
	@InvoiceNo nvarchar(50) = NULL,                    
	@ParentCode nvarchar(50) = NUll,                    
	@ParentName nvarchar(400) = NULL,            
	@FatherMobile nvarchar(200) = NULL,
	@FatherIqama nvarchar(200) = NULL
AS      
BEGIN                              
SET NOCOUNT ON;                               
	-------------Start: invoice summary                     
	SELECT                     
		tis.InvoiceId                    
		,tis.InvoiceNo                    
		,tis.InvoiceDate                    
		,tis.Status                    
		,tis.PublishedBy                    
		,tis.CreditNo                    
		,tis.CreditReason                    
		,tis.CustomerName                
		,tis.IqamaNumber    
		,tis.IsDeleted                    
		,tis.UpdateDate                    
		,tis.UpdateBy                   
		,InvoiceType=isnull(tis.InvoiceType,'Invoice')  
		,tis.InvoiceRefNo  
	into #InvoiceSummary2            
	FROM INV_InvoiceSummary tis                                                
	WHERE tis.InvoiceId = CASE WHEN @InvoiceId > 0 THEN @InvoiceId ELSE tis.InvoiceId END                    
	AND (@Status IS NULL OR tis.[Status] = @Status)                    
	AND (@InvoiceDateStart IS NULL OR cast(tis.InvoiceDate as date) >= cast(@InvoiceDateStart as date))                    
	AND (@InvoiceDateEnd IS NULL OR cast(tis.InvoiceDate as date) <= cast(@InvoiceDateEnd as date))                    
	AND (@InvoiceType IS NULL OR tis.InvoiceType = @InvoiceType)                    
	AND (@InvoiceNo IS NULL OR tis.InvoiceNo = @InvoiceNo)                    
	AND tis.IsDeleted = 0

	SELECT    
		tis.InvoiceNo       
		,TaxableAmount=sum(tis.TaxableAmount)    
		,TaxAmount=sum(tis.TaxAmount)    
		,ItemSubtotal=sum(tis.ItemSubtotal)    
	into #InvoiceDetail    
	from INV_InvoiceDetail tis    
	join #InvoiceSummary2 invSum on tis.InvoiceNo=invSum.InvoiceNo    
	where (@FatherIqama IS NULL OR tis.IqamaNumber like '%'+ @FatherIqama+'%')    
	group by tis.InvoiceNo 

	select 
		ROW_NUMBER() over(partition by ins.InvoiceNo order by  ins.InvoiceNo desc) as RN   
		,ins.InvoiceNo  
		,InvoiceTypeValue=      
		(
			select REPLACE(STUFF(CAST((            
			SELECT   ', ' +CAST(c.InvoiceType AS VARCHAR(MAX))            
			FROM (             
			SELECT distinct scm.InvoiceType                
			FROM INV_InvoiceDetail AS scm                  
			WHERE scm.InvoiceNo = ins.InvoiceNo          
         
			) c            
			FOR XML PATH(''), TYPE) AS VARCHAR(MAX)), 1, 2, ''),' ',' ')    
		)   
	into #InvoiceTypeDetail
	from 	 
	#InvoiceSummary2 ins 

	delete from #InvoiceTypeDetail where RN>1

	----Get Max payemtn info  
	select    
		ROW_NUMBER() over(partition by tis.InvoiceNo order by  tis.PaymentAmount desc) as RN            
		,tis.InvoiceNo       
		,tis.PaymentReferenceNumber  
		,tis.PaymentMethod  
	into #InvoicePayment    
	from INV_InvoicePayment tis    
	join #InvoiceSummary2 invSum    
	on tis.InvoiceNo=invSum.InvoiceNo    
  
	delete from #InvoicePayment where RN>1  

	select 
		ins.*
		,indt.InvoiceTypeValue
		,ind.ItemSubtotal,ind.TaxableAmount,ind.TaxAmount,
		inp.PaymentMethod,inp.PaymentReferenceNumber
	into #InvoiceSummary
	from 
	#InvoiceSummary2 ins
	join #InvoiceTypeDetail indt on ins.InvoiceNo=indt.InvoiceNo  
	join #InvoiceDetail ind on ins.InvoiceNo=ind.InvoiceNo  
	join #InvoicePayment inp on ins.InvoiceNo=inp.InvoiceNo  
	
	-------------End invoice summary 
	
	-------------Start parent Info
	---- Tuition fee
	select 
		ROW_NUMBER() over(partition by ins.InvoiceNo  order by  tis.StudentId asc) as RN        
		,tis.InvoiceNo,ParentId=isnull(tis.ParentId, par.ParentId)
		,ParentName=isnull(tis.ParentName,par.FatherName)
		,FatherMobile=isnull(tis.FatherMobile,par.FatherMobile)
		,ParentCode=isnull(tis.ParentId,par.ParentCode)
		,StudentName=isnull(tis.StudentName,stu.StudentName)	
		,StudentId=isnull(tis.StudentId,stu.StudentId)
		,StudentCode=isnull(tis.StudentCode,stu.StudentCode)	
	into #InvoiceParentInfoTuitionFee
	from INV_InvoiceDetail tis    
	join #InvoiceSummary ins on tis.InvoiceNo=ins.InvoiceNo 
	left join tblParent par on tis.ParentId=par.ParentId
	left join tblStudent stu on tis.StudentId=stu.StudentId
	where tis.InvoiceType like '%tuition%'
	and tis.ParentId>0

	delete from #InvoiceParentInfoTuitionFee where RN>1

	select 
		ROW_NUMBER() over(partition by ins.InvoiceNo  order by  tis.StudentId asc) as RN        
		,tis.InvoiceNo,ParentId,	StudentName	,ParentName,	FatherMobile	,StudentId,StudentCode	,ParentCode
	into #InvoiceParentInfoUniformFee
	from INV_InvoiceDetail tis    
	join #InvoiceSummary ins
	on tis.InvoiceNo=ins.InvoiceNo 
	where tis.InvoiceType not like '%tuition%'

	delete from #InvoiceParentInfoUniformFee where RN>1
	  
	select       
		ins.* 
		,ParentID=cast( isnull(ind.ParentID  ,null) as nvarchar(100))          
		,ParentName=isnull(ind.ParentName  ,null)          
		,FatherMobile=isnull(ind.FatherMobile  ,null)          
		,ParentCode=isnull(isnull(ind.ParentCode  ,null),'')
		,StudentId=isnull(isnull(ind.StudentId  ,null),'')
		,StudentName=case when ins.InvoiceTypeValue like '%Uniform %' then null else isnull(ind.StudentName  ,'')    end      
		,StudentCode=isnull(ind.StudentCode,'')
	into #InvoiceSummaryFinal
	from #InvoiceSummary ins
	left join  #InvoiceParentInfoTuitionFee ind on ins.InvoiceNo=ind.InvoiceNo

	-------------End parent Info

	-------------Start Final Query
	select       
		ins.InvoiceId	,ins.InvoiceNo	,ins.InvoiceDate	,ins.Status	,ins.PublishedBy	,ins.CreditNo	,ins.CreditReason	,ins.CustomerName	
		,ins.IqamaNumber	,ins.IsDeleted	,ins.UpdateDate	,ins.UpdateBy	,ins.InvoiceType	,ins.InvoiceRefNo	,ins.InvoiceTypeValue	
		,ins.ItemSubtotal	,ins.TaxableAmount	,ins.TaxAmount	,ins.PaymentMethod	,ins.PaymentReferenceNumber
		,ParentID=cast( isnull(isnull(ins.ParentID  , ind.ParentID)  ,0) as nvarchar(100))          
		,ParentName=isnull(ins.ParentName  ,ind.ParentName)
		,FatherMobile=isnull(ins.FatherMobile  ,ind.FatherMobile)
		,ParentCode=isnull(ins.ParentCode  ,ind.ParentCode)
		,StudentId=isnull(ins.StudentId  ,ind.StudentId )          
		,StudentName=case when ins.InvoiceTypeValue like '%Uniform %' then '' else isnull(ind.StudentName  ,'')    end      
		,StudentCode=isnull(ind.StudentCode,'')
	into #InvoiceSummaryFinal2
	from #InvoiceSummaryFinal ins
	left join  #InvoiceParentInfoUniformFee ind on ins.InvoiceNo=ind.InvoiceNo
	
	SELECT* FROM #InvoiceSummaryFinal2
	WHERE       
	--isnull(ParentCode,'')=CASE WHEN @ParentCode IS NULL OR @ParentCode='' THEN ParentCode ELSE @ParentCode END      
	(@ParentCode IS NULL OR isnull(ParentCode,'') like '%' + @ParentCode  +'%'   )      
	and (@FatherMobile IS NULL OR isnull(FatherMobile,'') like '%' + @FatherMobile  +'%'   )      
	and (@ParentName IS NULL OR isnull(ParentName,'') like '%' + @ParentName  +'%'   )      
	--AND isnull(FatherMobile,'') like '%' + CASE WHEN @FatherMobile IS NULL OR @FatherMobile='' THEN FatherMobile ELSE @FatherMobile END  +'%'        
	--AND isnull(ParentName,'') like '%' + CASE WHEN @ParentName IS NULL OR @ParentName='' THEN ParentName ELSE @ParentName END +'%'        
	ORDER BY InvoiceNo DESC 
	
	-------------End Final Query
      
	drop table #InvoiceSummary
	drop table #InvoiceSummary2
	drop table #InvoiceDetail    
	drop table #InvoicePayment    
	drop table #InvoiceTypeDetail

	drop table #InvoiceParentInfoTuitionFee
	drop table #InvoiceParentInfoUniformFee
	drop table #InvoiceSummaryFinal
	drop table #InvoiceSummaryFinal2
END  
GO

DROP PROCEDURE IF EXISTS [sp_CSVInvoiceExport]
GO

CREATE PROCEDURE [dbo].[sp_CSVInvoiceExport]      
  @InvoiceId bigint = 0,                  
  @Status nvarchar(50) = NULL,                  
  @InvoiceDateStart date = NULL,                  
  @InvoiceDateEnd date = NULL,                  
  @InvoiceType nvarchar(50) = NULL,                  
  @InvoiceNo nvarchar(50) = NULL,                  
  @ParentCode nvarchar(50) = NUll,                  
  @ParentName nvarchar(400) = NULL,          
  @FatherMobile nvarchar(200) = NULL  ,
	@FatherIqama nvarchar(200) = NULL      
 AS    
 BEGIN                              
 SET NOCOUNT ON;                               
               
 SELECT                     
  tis.InvoiceId                    
  ,tis.InvoiceNo                    
  ,InvoiceDate= convert(varchar, tis.InvoiceDate, 103)       
  ,tis.Status                    
  ,tis.PublishedBy                    
  ,tis.CreditNo                    
  ,tis.CreditReason                    
  ,tis.CustomerName                
  ,tis.IqamaNumber    
  ,tis.IsDeleted                    
  ,tis.UpdateDate                    
  ,tis.UpdateBy                   
  ,InvoiceType=isnull(tis.InvoiceType,'Invoice')  
  ,tis.InvoiceRefNo  
 into #InvoiceSummary            
 FROM INV_InvoiceSummary tis                           
 --LEFT JOIN tblParent tp ON tis.ParentID = tp.ParentId                       
 WHERE tis.InvoiceId = CASE WHEN @InvoiceId > 0 THEN @InvoiceId ELSE tis.InvoiceId END                    
 AND (@Status IS NULL OR tis.[Status] = @Status)                    
 AND (@InvoiceDateStart IS NULL OR cast(tis.InvoiceDate as date) >= cast(@InvoiceDateStart as date))                    
 AND (@InvoiceDateEnd IS NULL OR cast(tis.InvoiceDate as date) <= cast(@InvoiceDateEnd as date))                    
 AND (@InvoiceType IS NULL OR tis.InvoiceType = @InvoiceType)                    
 AND (@InvoiceNo IS NULL OR tis.InvoiceNo = @InvoiceNo)                    
 AND tis.IsDeleted = 0           
    
 select    
 tis.InvoiceNo       
 ,TaxableAmount=sum(tis.TaxableAmount)    
 ,TaxAmount=sum(tis.TaxAmount)    
 ,ItemSubtotal=sum(tis.ItemSubtotal)    
 into #InvoiceDetail    
 from INV_InvoiceDetail tis    
 join #InvoiceSummary invSum    
 on tis.InvoiceNo=invSum.InvoiceNo    
 where (@FatherIqama IS NULL OR tis.IqamaNumber like '%'+ @FatherIqama+'%')    
	group by tis.InvoiceNo   
       
     --select  @ParentCode          
 select         
  t.InvoiceNo, t.ParentID,t.ParentName,t.FatherMobile,t.ParentCode,t.StudentId,t.StudentName,t.StudentCode,t.InvoiceTypeValue,          
  ROW_NUMBER() over(partition by t.InvoiceNo order by  t.InvoiceNo) as RN            
 into #INDMobile            
 from            
 (            
  select distinct             
   ins.InvoiceNo          
   ,ParentID= case when tp.ParentID is null then ind.ParentID  else tp.ParentID end          
   ,ParentName= case when tp.FatherName COLLATE SQL_Latin1_General_CP1256_CI_AS  is null then ind.ParentName  else tp.FatherName COLLATE SQL_Latin1_General_CP1256_CI_AS  end          
   ,FatherMobile= case when tp.FatherMobile is null then ind.FatherMobile  else tp.FatherMobile end          
   ,ParentCode= case when tp.ParentCode is null then ''  else tp.ParentCode end          
                
   ,StudentId= case when ts.StudentId is null then ind.StudentId  else ts.StudentId end          
   ,StudentName=case when ind.InvoiceType like '%Uniform%' then '' else    
  case when ts.StudentName COLLATE SQL_Latin1_General_CP1256_CI_AS  is null then ind.StudentName      
  else ts.StudentName COLLATE SQL_Latin1_General_CP1256_CI_AS     
  end         
 end    
   ,StudentCode= case when ts.StudentCode is null then ''  else ts.StudentCode end            
             
   ,InvoiceTypeValue=      
   (select REPLACE(STUFF(CAST((            
    SELECT   ', ' +CAST(c.InvoiceType AS VARCHAR(MAX))            
     FROM (             
     SELECT distinct scm.InvoiceType                
    FROM INV_InvoiceDetail AS scm                  
    WHERE scm.InvoiceNo = ins.InvoiceNo          
         
   ) c            
  FOR XML PATH(''), TYPE) AS VARCHAR(MAX)), 1, 2, ''),' ',' ')    
 )    
 from             
 #InvoiceSummary ins            
 join INV_InvoiceDetail ind on ins.InvoiceNo=ind.InvoiceNo            
 LEFT JOIN tblParent tp ON ind.ParentID = tp.ParentId            
 AND tp.ParentCode=CASE WHEN @ParentCode IS NULL OR @ParentCode='' THEN tp.ParentCode ELSE @ParentCode END        
 AND ind.FatherMobile=CASE WHEN @FatherMobile IS NULL OR @FatherMobile='' THEN ind.FatherMobile ELSE @FatherMobile END        
 AND tp.FatherName like '%' + CASE WHEN @ParentName IS NULL OR @ParentName='' THEN tp.FatherName ELSE @ParentName END +'%'        
 LEFT JOIN tblStudent ts ON ind.StudentId = ts.StudentId          
          
 where ind.FatherMobile is null OR len( ISNULL(ind.FatherMobile,''))>0            
 )t      
      
 delete from #INDMobile where RN>1       
  
 ----Get Max payemtn info  
 select    
 ROW_NUMBER() over(partition by tis.InvoiceNo order by  tis.PaymentAmount desc) as RN            
 ,tis.InvoiceNo       
 ,tis.PaymentReferenceNumber  
 ,tis.PaymentMethod  
 into #InvoicePayment    
 from INV_InvoicePayment tis    
 join #InvoiceSummary invSum    
 on tis.InvoiceNo=invSum.InvoiceNo    
  
  delete from #InvoicePayment where RN>1      
        
 select       
  ins.*    
   
  ,ParentID=cast( isnull(ind.ParentID  ,'') as nvarchar(100))          
  ,ParentName=isnull(ind.ParentName  ,'')          
  ,FatherMobile=isnull(ind.FatherMobile  ,'')          
  ,ParentCode=isnull(ind.ParentCode  ,'')          
  ,StudentId=isnull(ind.StudentId  ,'')          
  ,StudentName=isnull(ind.StudentName  ,'')          
  ,StudentCode=isnull(ind.StudentCode,'')          
  ,InvoiceTypeValue=ind.InvoiceTypeValue  
  ,indPay.PaymentMethod  
  ,indPay.PaymentReferenceNumber  
  ,invDet.TaxableAmount    
  ,invDet.TaxAmount    
  ,invDet.ItemSubtotal    
 from #InvoiceSummary ins     
 join #InvoiceDetail invDet on ins.InvoiceNo=invDet.InvoiceNo    
 left join  #INDMobile ind on ins.InvoiceNo=ind.InvoiceNo    
  left join  #InvoicePayment indPay on ins.InvoiceNo=indPay.InvoiceNo       
 WHERE       
 --isnull(ParentCode,'')=CASE WHEN @ParentCode IS NULL OR @ParentCode='' THEN ParentCode ELSE @ParentCode END      
  (@ParentCode IS NULL OR isnull(ParentCode,'') like '%' + @ParentCode  +'%'   )      
 and (@FatherMobile IS NULL OR isnull(FatherMobile,'') like '%' + @FatherMobile  +'%'   )      
 and (@ParentName IS NULL OR isnull(ParentName,'') like '%' + @ParentName  +'%'   )      
 --AND isnull(FatherMobile,'') like '%' + CASE WHEN @FatherMobile IS NULL OR @FatherMobile='' THEN FatherMobile ELSE @FatherMobile END  +'%'        
 --AND isnull(ParentName,'') like '%' + CASE WHEN @ParentName IS NULL OR @ParentName='' THEN ParentName ELSE @ParentName END +'%'        
  ORDER BY ins.InvoiceNo DESC           
      
      
 drop table #InvoiceSummary          
 drop table #INDMobile    
 drop table #InvoiceDetail    
    
END  
Go