﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace School.Services.Entities;

public partial class TblSiblingDiscountDetail
{
    public long SiblingDiscountDetailId { get; set; }

    public long SiblingDiscountId { get; set; }

    public long StudentId { get; set; }

    public long SchoolAcademicId { get; set; }

    public long GradeId { get; set; }

    public long FeeTypeId { get; set; }

    public decimal? DiscountPercent { get; set; }

    public decimal? DiscountAmount { get; set; }

    public DateTime UpdateDate { get; set; }

    public int UpdateBy { get; set; }

    public bool? IsActive { get; set; }

    public bool? IsDeleted { get; set; }
}