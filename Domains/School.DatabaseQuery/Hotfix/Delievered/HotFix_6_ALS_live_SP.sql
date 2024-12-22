 ALTER PROCEDURE [dbo].[sp_GetInvoice]                  
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
        
	SELECT         
		tis.InvoiceId        
		,tis.InvoiceNo        
		,tis.InvoiceDate        
		,tis.Status        
		,tis.PublishedBy        
		,tis.CreditNo        
		,tis.CreditReason        
		,tis.CustomerName        
		,tis.ParentId
		,tis.IqamaNumber        
		,tis.TaxableAmount        
		,tis.TaxAmount        
		,tis.ItemSubtotal        
		,tis.IsDeleted        
		,tis.UpdateDate        
		,tis.UpdateBy       
		,InvoiceType=isnull(tis.InvoiceType,'Invoice')  
    
		,tis.InvoiceRefNo  
		,InvoiceTypeValue=  (select REPLACE(STUFF(CAST((
						SELECT   ', ' +CAST(c.InvoiceType AS VARCHAR(MAX))
						FROM ( 
			SELECT scm.InvoiceType    
				FROM INV_InvoiceDetail AS scm      
				WHERE scm.InvoiceNo = tis.InvoiceNo      
			) c
		FOR XML PATH(''), TYPE) AS VARCHAR(MAX)), 1, 2, ''),' ',' ')),
		CASE 
		WHEN tis.ParentId IS NOT NULL THEN tp.FatherMobile
		ELSE ''
		END AS FatherMobile
	into #InvoiceSummary
	 FROM INV_InvoiceSummary tis               
	 LEFT JOIN tblParent tp ON tis.ParentID = tp.ParentId           
	 WHERE tis.InvoiceId = CASE WHEN @InvoiceId > 0 THEN @InvoiceId ELSE tis.InvoiceId END        
	  AND (@Status IS NULL OR tis.[Status] = @Status)        
	  AND (@InvoiceDateStart IS NULL OR cast(tis.InvoiceDate as date) >= cast(@InvoiceDateStart as date))        
	  AND (@InvoiceDateEnd IS NULL OR cast(tis.InvoiceDate as date) <= cast(@InvoiceDateEnd as date))        
	  AND (@InvoiceType IS NULL OR tis.InvoiceType = @InvoiceType)        
	  AND (@InvoiceNo IS NULL OR tis.InvoiceNo = @InvoiceNo)        
	  AND (@ParentCode IS NULL OR tp.ParentCode = @ParentCode)        
	  AND (@ParentName IS NULL OR tp.FatherName like '%'+@ParentName+'%')     
	  --AND (@FatherMobile IS NULL OR tp.FatherMobile = @FatherMobile)       
	  And (@FatherMobile is null OR (@FatherMobile is not null and tis.InvoiceNo in (select InvoiceNo from INV_InvoiceDetail where FatherMobile = @FatherMobile)  ))
	  AND tis.IsDeleted = 0                  
	
	select 
	t.InvoiceNo, t.FatherMobile,ROW_NUMBER() over(partition by t.InvoiceNo order by  t.InvoiceNo) as RN
	into #INDMobile
	from
	(
		select distinct 
			ins.InvoiceNo, ind.FatherMobile	
		from 
		#InvoiceSummary ins
		join INV_InvoiceDetail ind on ins.InvoiceNo=ind.InvoiceNo
		where ind.FatherMobile is not null OR len( ISNULL(ind.FatherMobile,''))>0
	)t

	delete from #INDMobile where RN>1

	update ins
	set 
		ins.FatherMobile=ind.FatherMobile
	from #InvoiceSummary ins
	join  #INDMobile ind
	on ins.InvoiceNo=ind.InvoiceNo

	select * from #InvoiceSummary ORDER BY InvoiceNo DESC                  
END 
GO