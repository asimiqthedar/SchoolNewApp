﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace School.Services.Entities;

public partial class TblSchoolAccountInfo
{
    public int SchoolAccountIid { get; set; }

    public long? SchoolId { get; set; }

    public string CodeDescription { get; set; }

    public bool IsActive { get; set; }

    public bool IsDeleted { get; set; }

    public DateTime UpdateDate { get; set; }

    public int UpdateBy { get; set; }

    public string ReceivableAccount { get; set; }

    public string AdvanceAccount { get; set; }

    public virtual TblSchoolMaster School { get; set; }
}