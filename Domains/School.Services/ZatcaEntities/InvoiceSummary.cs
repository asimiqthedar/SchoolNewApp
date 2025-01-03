﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace School.Services.ZatcaEntities;

public partial class InvoiceSummary
{
    public long Id { get; set; }

    public long? RefId { get; set; }

    public string InvoiceNo { get; set; }

    public string PaymentMethod { get; set; }

    public string Status { get; set; }

    public string ChequeNo { get; set; }

    public string ParentId { get; set; }

    public string PublishedBy { get; set; }

    public DateTime? InvoiceDate { get; set; }

    public string CreditNo { get; set; }

    public string InvoiceType { get; set; }

    public string CreditReason { get; set; }

    public string CustomerName { get; set; }

    public string ParentName { get; set; }

    public string EmailId { get; set; }

    public string MobileNo { get; set; }

    public string Nationality { get; set; }

    public string Address { get; set; }

    public string GpvoucherNo { get; set; }

    public string Vatno { get; set; }

    public string EncodedInvoice { get; set; }

    public string InvoiceHash { get; set; }

    public string Uuid { get; set; }

    public string ReportingStatus { get; set; }

    public string QrcodePath { get; set; }

    public DateTime? CreatedOn { get; set; }

    public string CreatedBy { get; set; }

    public DateTime? UpdatedOn { get; set; }

    public string UpdatedBy { get; set; }

    public string SignedXmlpath { get; set; }

    public string InvoicePdfPath { get; set; }

    public string IqamaNumber { get; set; }
}