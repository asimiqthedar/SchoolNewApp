﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace School.Services.Entities;

public partial class TblOpenApplyMaster
{
    public long OpenApplyId { get; set; }

    public string GrantType { get; set; }

    public string ClientId { get; set; }

    public string ClientSecret { get; set; }

    public string Audience { get; set; }

    public string OpenApplyJobPath { get; set; }

    public bool IsDeleted { get; set; }

    public bool IsActive { get; set; }

    public DateTime UpdateDate { get; set; }

    public int UpdateBy { get; set; }
}