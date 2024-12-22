DROP PROCEDURE IF EXISTS  [dbo].[sp_GetInvoice]
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
	@FatherMobile nvarchar(200) = NULL            
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
	join #InvoiceSummary2 invSum    
	on tis.InvoiceNo=invSum.InvoiceNo    
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