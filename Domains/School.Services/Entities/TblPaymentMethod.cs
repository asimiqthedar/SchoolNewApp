﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace School.Services.Entities;

public partial class TblPaymentMethod
{
    public long PaymentMethodId { get; set; }

    public long PaymentMethodCategoryId { get; set; }

    public string PaymentMethodName { get; set; }

    public string DebitAccount { get; set; }

    public string CreditAccount { get; set; }

    public bool IsActive { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime UpdateDate { get; set; }

    public int UpdateBy { get; set; }
}