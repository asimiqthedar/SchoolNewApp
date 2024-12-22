SELECT        RN, t .InvoiceNo, InvoiceDate, Status, PublishedBy, CreditNo, CreditReason, CustomerName = isnull(CustomerName, ParentName), PaymentMethod, ChequeNo, ParentID, InvoiceType, EmailID, 
                         MobileNo, ParentName, Nationality = ISNULL(Nationality, ''), Address = '', GPVoucherNo, VATNo, EncodedInvoice, InvoiceHash, UUID, ReportingStatus = ISNULL(ReportingStatus, 'Not Reported'), QRCodePath, 
                         SignedXMLPath, UpdateDate, UpdateBy, TotalItemSubtotal, TotalTaxableAmount, TotalTaxAmount, FatherIQAMA
FROM            (SELECT DISTINCT 
                                                    RN, InvoiceId,  InvoiceNo, PaymentMethod, Status, ChequeNo, ParentID, PublishedBy, InvoiceDate, CreditNo, InvoiceType, CreditReason, CustomerName, EmailID, MobileNo, GPVoucherNo, VATNo, 
                                                    EncodedInvoice, InvoiceHash, UUID, ReportingStatus, QRCodePath, SignedXMLPath, UpdateDate, UpdateBy, TotalItemSubtotal, TotalTaxableAmount, TotalTaxAmount, 
                                                    ParentName, FatherIQAMA, Nationality
                           FROM            (SELECT        ROW_NUMBER() OVER (partition BY s.InvoiceNo
                                                      ORDER BY s.InvoiceNo  DESC) AS RN, s.InvoiceId, InvoiceNo = s.InvoiceNo , PaymentMethod = isnull(tis.PaymentMethod, s.PaymentMethod), s.Status, 
                                                    ChequeNo = isnull(s.ChequeNo, tis.PaymentReferenceNumber), s.ParentID, s.PublishedBy, s.InvoiceDate, s.CreditNo, s.InvoiceType, s.CreditReason, s.CustomerName, s.EmailID, s.MobileNo, 
                                                    s.GPVoucherNo, s.VATNo, s.EncodedInvoice, s.InvoiceHash, s.UUID, s.ReportingStatus, s.QRCodePath, s.SignedXMLPath, s.UpdateDate, s.UpdateBy, 
                                                    TotalItemSubtotal = CASE WHEN isnull(t .TotalItemSubtotal, 0) = 0 THEN isnull(tUniform.TotalItemSubtotal, 0) ELSE isnull(t .TotalItemSubtotal, 0) END, 
                                                    TotalTaxableAmount = CASE WHEN isnull(t .TotalTaxableAmount, 0) = 0 THEN isnull(tUniform.TotalTaxableAmount, 0) ELSE isnull(t .TotalTaxableAmount, 0) END, 
                                                    TotalTaxAmount = CASE WHEN isnull(t .TotalTaxAmount, 0) = 0 THEN isnull(tUniform.TotalTaxAmount, 0) ELSE isnull(t .TotalTaxAmount, 0) END, ParentName = COALESCE (par.ParentName, 
                                                    s.ParentName), FatherIQAMA = ISNULL(par.FatherIqamaNo, ISNULL(parentIqama.IqamaNumber, '')), Nationality = isnull(par.Nationality, s.Nationality)
                           FROM            INV_InvoiceSummary s LEFT JOIN
                                                        (SELECT        InvoiceNo, TotalTaxableAmount = sum(isnull(TaxableAmount, 0)), TotalTaxAmount = sum(isnull(TaxAmount, 0)), TotalItemSubtotal = sum(isnull(ItemSubtotal, 0))
                                                           FROM            [INV_InvoiceDetail]
                                                           GROUP BY InvoiceNo) t ON s.InvoiceNo = t .InvoiceNo LEFT JOIN
                                                        (SELECT        InvoiceNo, TotalTaxableAmount = sum(cast(isnull(TaxableAmount, 0) AS decimal)), TotalTaxAmount = sum(cast(isnull(TaxAmount, 0) AS decimal)), 
                                                                                    TotalItemSubtotal = sum(cast(isnull(ItemSubtotal, 0) AS decimal))
                                                           FROM           UniformDetails
                                                           GROUP BY InvoiceNo) tUniform ON s.InvoiceNo = tUniform.InvoiceNo /* where s.Status='Posted'     */ LEFT JOIN
                                                        (SELECT DISTINCT ParentId = ParentCode, FatherIqamaNo, ParentName = FatherName, Nationality = COU.CountryName
                                                           FROM            ALS_LIVE.DBO.TBLPARENT P JOIN
                                                                                    ALS_LIVE.DBO.tblCountryMaster COU ON P.FatherNationalityId = COU.CountryId) par ON s.ParentID = par.ParentId LEFT JOIN
                                                        (SELECT        InvoiceNo, PaymentReferenceNumber, PaymentMethod
                                                           FROM            (SELECT        ROW_NUMBER() OVER (partition BY tis.InvoiceNo
                                                                                      ORDER BY tis.PaymentAmount DESC) AS RN, tis.InvoiceNo, tis.PaymentReferenceNumber, tis.PaymentMethod
                                                           FROM            INV_InvoicePayment tis) t
                           WHERE        t .RN = 1) tis ON tis.InvoiceNo = s.InvoiceNo LEFT JOIN
                             (SELECT        InvoiceNo, IqamaNumber, ParentName, ParentCode
                                FROM            (SELECT        ROW_NUMBER() OVER (partition BY tis.InvoiceNo
                                                           ORDER BY tis.InvoiceNo DESC) AS RN, tis.InvoiceNo, tis.IqamaNumber, tis.ParentName, tis.ParentCode
                                FROM            ALS_LIVE.DBO.INV_InvoiceDetail tis) t
WHERE        t .RN = 1) parentIqama ON tis.InvoiceNo = s.InvoiceNo) t
WHERE        t .RN = 1) t LEFT JOIN
    (SELECT DISTINCT InvoiceNo, [Description]
       FROM            [INV_InvoiceDetail]
       WHERE        [Description] LIKE '%#%') tDesc ON tDesc.InvoiceNo = t .InvoiceNo