﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace School.Services.Entities;

public partial class InvInvoicePayment
{
    public long InvoicePaymentId { get; set; }

    public long InvoiceNo { get; set; }

    public string PaymentMethod { get; set; }

    public string PaymentReferenceNumber { get; set; }

    public decimal PaymentAmount { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime UpdateDate { get; set; }

    public int UpdateBy { get; set; }

    public long? InvoiceRefNo { get; set; }

    public long? InvoicePaymentRefId { get; set; }

    public long? PaymentMethodId { get; set; }
}